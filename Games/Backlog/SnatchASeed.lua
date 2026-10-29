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
getgenv().TempoHoodSubtitle = "SNATCH A SEED"
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
local GameInfoGroup, Bq_15, Bq_24, Bq_37, Bq_57, Bq_70, Bq_79
local qD
local rk
local qk
local q1
local rJ
local connection
local GearData
local q7
local qq
local qP
local CollectionService
local qw
local rd
local rV
local qV
local Library
local qj
local r0
local DataService
local qI
local rp
local qp
local SaveManager
local GetFarm
local rv
local qv
local sc
local Label
local rB
local connection6
local ri
local r_
local qH
local ro
local qo
local connection2
local rN
local qu
local rb
local HttpService
local rA
local qA
local PlayerGui
local qh
local qZ
local rG
local rZ
local qG
local rn
local EggData
local q4
local Rebirth
local qM
local Workspace
local ShovelSwing
local ra
local qS
local rz
local qz
local sg
local rg
local RebirthConfig
local Options
local connection3
local rm
local r3
local q3
local qm
local qL
local rs
local connection5
local r9
local rR
local qR
local sf
local rX
local qE
local rl
local UserInputService
local Toggles
local r8
local rQ
local rx
local SeedData
local re
local VirtualUser
local connection4
local TweenService
function fns.onRenderStepped(kg)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local zx_1 = qH()
        if zx_1 then
            zx_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local zx_3 = qm()
        local zy = qH()
        local CurrentCamera = Workspace.CurrentCamera
        if zx_3 and zy and CurrentCamera then
            zy.PlatformStand = true
            local zy_1 = Vector3.zero
            local zF = if UserInputService:IsKeyDown(Enum.KeyCode.W) then 1 else 0
            if zF == 1 then
                zy_1 += CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                zy_1 -= CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                zy_1 -= CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                zy_1 += CurrentCamera.CFrame.RightVector
            end
            local zI = if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
            if zI == 1 then
                zy_1 += Vector3.new(0, 1, 0)
            end
            local zL = if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then 1 else 0
            if zL == 1 then
                zy_1 -= Vector3.new(0, 1, 0)
            end
            zx_3.Velocity = Vector3.zero
            if zy_1.Magnitude > 0 then
                zx_3.CFrame = zx_3.CFrame + zy_1.Unit * Options.FlySpeed.Value * kg
            end
        end
    end
end
function fns.onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local zs_1 = qH()
        if zs_1 then
            zs_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
function fns.onCopyBitcoinAddress()
    qk(qz, "Copied Bitcoin address")
end
function fns.antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local A6 = tick() - rN
            local A7 = tick() - rG
            if A6 >= 300 and A7 >= 60 then
                pcall(ri)
            else
                if A6 < 300 and A7 >= 300 then
                    pcall(ri)
                end
            end
        end
    end
end
function fns.fn120()
    local t3 = qV()
    local t4 = t3 and t3:FindFirstChild("HumanoidRootPart")
    return t4
end
function fns.fn122(cf)
    local uq = SeedData[cf]
    local ur = uq and tonumber(uq.Value)
    local uq_1 = ur
    local uv = if uq_1 then 1 else 0
    local ut = 1012 * uv + 668 * (1 - uv)
    local uu = 2770 * uv + 3707 * (1 - uv)
    if not ((ut * 2713 + uu * 1036 + ut * uu) % 16777213 == 8418516) then
        uq_1 = 0
    end
    return uq_1
end
function fns.fn134()
    Library.ScreenGui.Parent = PlayerGui
end
function fns.fn143()
    local wl = qD()
    if not wl then
        return nil
    end
    local wm = wl:FindFirstChild("Main") and wl.Main:FindFirstChild("Farmer_Platforms")
    if not wm then
        return nil
    end
    for i, player in qh:GetPlayers() do
        if player ~= rn then
            local Character = player.Character
            local wn = Character and Character:FindFirstChild("HumanoidRootPart")
            if wn then
                if Character:GetAttribute("CarryingFarmer") == true then
                    return player, wn
                end
                for i, child in wm:GetChildren() do
                    local Farmer = child:FindFirstChild("Farmer")
                    local wn_1 = Farmer and Farmer:FindFirstChild("HumanoidRootPart")
                    local wm_3 = wn_1
                    if wn_1 then
                        wn_1 = (wn.Position - wm_3.Position).Magnitude <= 14
                    end
                    if wn_1 then
                        return player, wn
                    end
                end
            end
        end
    end
    return nil
end
function fns.fn149(dS)
    local vR = GearData[dS]
    local vS = vR and tonumber(vR.Price)
    return vS or 0
end
function fns.fn158()
    local t0 = qV()
    local t1 = t0 and t0:FindFirstChildOfClass("Humanoid")
    return t1
end
function fns.fn159()
    local leaderstats = rn:FindFirstChild("leaderstats")
    local ud_2
    local ue = leaderstats and leaderstats:FindFirstChild("Rebirths")
    local ue_2
    if ue then
        local ue_1 = tonumber(ue.Value) or 0
        return ue_1
    end
    ud_2, ue_2 = pcall(function()
        return DataService:GetData()
    end)
    local uf = ud_2 and type(ue_2) == "table"
    if uf then
        local ud_3 = tonumber(ue_2.Rebirths) or 0
        return ud_3
    end
    return 0
end
function fns.onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = rn.Character
        if Character then
            for i, descendant in Character:GetDescendants() do
                local zk_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if zk_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
function fns.fn184(dw)
    local Size = dw.Size
    local dy = Vector3.new((math.random() - 0.5) * Size.X * 0.7, 0, (math.random() - 0.5) * Size.Z * 0.7)
    return dw.CFrame:PointToWorldSpace(dy)
end
function fns.fn190()
    local wD_1
    local wC_1
    wC_1, wD_1 = rA()
    if not (wC_1 and wD_1) then
        return false
    end
    local wC_2 = qZ(function(e4)
        return e4.Name == "Garden Shovel"
    end)
    r_(wC_2)
    rR(CFrame.new(wD_1.Position + Vector3.new(0, 3, 4), wD_1.Position))
    if os.clock() - qS >= 0.45 then
        qS = os.clock()
        pcall(function()
            ShovelSwing:FireServer()
        end)
    end
    return true
end
function fns.fn204(d1)
    if not rd("BuyFarmerList", d1) then
        return false
    end
    local vX = qo(d1)
    local vY = vX and not rd("BuyFarmerRarities", vX)
    if vY then
        return false
    end
    return true
end
function fns.fn218()
    Library.ScreenGui.Parent = PlayerGui
end
function fns.fn243()
    local At = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local Au = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if Au then
                local Au_1 = rx(k, v)
                if Au_1 then
                    At[#At + 1] = Au_1
                end
            end
        end
    end
    table.sort(At, function(lA, lB)
        if lA.type ~= lB.type then
            return lA.type < lB.type
        end
        return lA.idx < lB.idx
    end)
    return { objects = At }
end
function fns.fn273()
    if os.clock() - qq < 2 then
        return
    end
    local xy = qD()
    local xz = xy and xy:FindFirstChild("Main") and xy.Main:FindFirstChild("Farmer_Platforms")
    if not xz then
        return
    end
    qq = os.clock()
    for i, child in xz:GetChildren() do
        local Farmer = child:FindFirstChild("Farmer")
        local xz_1 = Farmer and Farmer:FindFirstChild("HumanoidRootPart")
        local xy_3 = xz_1
        if xz_1 then
            xz_1 = xy_3:FindFirstChild("ClaimSeedPrompt")
        end
        local xA = xz_1
        if xz_1 then
            xz_1 = xA.Enabled
        end
        if xz_1 then
            rb(xy_3.CFrame + Vector3.new(0, 3, 3))
            r9(xA)
            task.wait(0.15)
        end
    end
end
function fns.fn300()
    qk(qR, "Copied Discord invite to clipboard")
end
function fns.fn307(ca)
    local uk = SeedData[ca]
    local uk_1 = uk and uk.SeedRarity
    local up = if uk_1 then 1 else 0
    local un = 2091 * up + 1451 * (1 - up)
    local uo = 2744 * up + 206 * (1 - up)
    if not ((un * 2762 + uo * 1137 + un * uo) % 16777213 == 14632974) then
        uk_1 = nil
    end
    return uk_1
end
function fns.fn315()
    ra(false)
    qI(false)
    if connection then
        connection:Disconnect()
    end
    if connection2 then
        connection2:Disconnect()
    end
    if connection3 then
        connection3:Disconnect()
    end
    if connection4 then
        connection4:Disconnect()
    end
    if connection5 then
        connection5:Disconnect()
    end
    if q1 then
        q1:Disconnect()
    end
    if connection6 then
        connection6:Disconnect()
    end
    select("#", "Unloaded!")
end
function fns.onImportConfigFromClipboardTex()
    local AW_1
    local AU = Options.SaveManager_ImportSource.Value
    local AU_1
    local A_ = if AU then 1 else 0
    local AY = 2905 * A_ + 3590 * (1 - A_)
    local AZ = 1207 * A_ + 374 * (1 - A_)
    if not ((AY * 3894 + AZ * 567 + AY * AZ) % 16777213 == 15502774) then
        AU = ""
    end
    local AV = tostring(AU):match("^%s*(.-)%s*$")
    if AV == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    AU_1, AW_1 = pcall(HttpService.JSONDecode, HttpService, AV)
    local AV_1 = not AU_1 or type(AW_1) ~= "table" or type(AW_1.objects) ~= "table"
    if AV_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local AU_2 = 0
    for i, v in ipairs(AW_1.objects) do
        if sc(v) then
            AU_2 += 1
        end
    end
    if AU_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local AW_2 = AU_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(AU_2, AW_2), 6)
end
function fns.onRscripts()
    if setclipboard then
        setclipboard(qL)
    elseif toclipboard then
        toclipboard(qL)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
function fns.onCopyLitecoinAddress()
    qk(qE, "Copied Litecoin address")
end
function fns.onCopyUSDTAddress()
    qk(qp, "Copied USDT address")
end
function fns.fn421(ex)
    local wa = {}
    local wb = {}
    if not ex then
        return wb, { median = 0 }
    end
    for k, v in CollectionService:GetTagged("CollectPrompt") do
        local wc_1 = v:IsA("ProximityPrompt") and v:IsDescendantOf(ex) and v:GetAttribute("Collected") ~= true
        if wc_1 then
            local Model = v:FindFirstAncestorOfClass("Model")
            local wd_1 = Model and Model:IsDescendantOf(Workspace) and not Model:GetAttribute("Locked")
            if wd_1 then
                wb[#wb + 1] = Model
                wa[#wa + 1] = rz(Model)
            end
        end
    end
    table.sort(wa)
    local wc_3 = 0
    if #wa > 0 then
        local wd_2 = math.ceil(#wa / 2)
        wc_3 = wa[wd_2]
    end
    return wb, { median = wc_3 }
end
function fns.fn453(d7)
    return rd("LuckyBlockList", d7)
end
function fns.fn455()
    local y3_1
    local y2_1
    if identifyexecutor then
        y3_1, y2_1 = identifyexecutor()
        local y4 = y3_1 ~= ""
        local y5 = type(y3_1) == "string" and y4
        if y5 then
            local y4_1 = type(y2_1) == "string" and y2_1 ~= "" and y3_1 .. " " .. y2_1
            qu = y4_1 or y3_1
        end
    end
end
function fns.fn456(ea)
    if not rd("PlantList", ea) then
        return false
    end
    local v_ = qo(ea)
    local v0 = v_ and not rd("PlantRarities", v_)
    if v0 then
        return false
    end
    return true
end
function fns.fn463(a5, a6)
    return string.format('<font color="%s">%s</font>', a6, a5)
end
function fns.worker()
    local zg_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local zf = math.floor(os.clock() - rk)
        if zf < 60 then
            zg_1 = zf .. "s"
        elseif zf < 3600 then
            zg_1 = string.format("%dm %ds", math.floor((zf) / (60)), zf % 60)
        else
            zg_1 = string.format("%dh %dm", math.floor((zf) / (3600)), math.floor((zf % 3600) / (60)))
        end
        Label:SetText(rv("Session time", zg_1, rl))
    end
end
function fns.onInputBegan()
    rN = tick()
end
function fns.fn514()
    local xs_1
    local xr = qD()
    local xr_1
    if #q4(xr) == 0 then
        return
    end
    xr_1, xs_1 = rB(nil, false)
    if xr_1 and xs_1 then
        local xr_2 = sg(xs_1, 2)
        if xr_2 then
            rm(xr_2)
        end
    end
end
function fns.fn531(cO)
    local uO = qm()
    if not uO then
        return false
    end
    uO.CFrame = cO
    return true
end
function fns.onCopyJoinScript_JobID()
    local za = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, rQ)
    if setclipboard then
        setclipboard(za)
    elseif toclipboard then
        toclipboard(za)
    end
    Library:Notify("Copied join script to clipboard")
end
function fns.fn571()
    ra(Toggles.AntiGameplayPause.Value)
end
function fns.fn594()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    rG = tick()
end
function fns.fn615()
    gethui = function()
        return PlayerGui
    end
end
function fns.fn625(eg, eh)
    if eg:GetAttribute("Locked") then
        return false
    end
    local v2 = rV("CollectMode", "All")
    local v3 = qo(eg.Name)
    if v2 == "Rarity" then
        local v4_1 = v3 ~= nil and rd("CollectRarities", v3)
        return v4_1
    elseif v2 == "Cheap" then
        local v3_1 = rz(eg)
        local v4_3 = eh and eh.median or 0
        if v4_3 > 0 then
            return v3_1 <= v4_3
        end
        return rZ(eg.Name) < 1000
    elseif v2 == "High Value" then
        local v2_1 = rz(eg)
        local v4_4 = eh and eh.median or 0
        if v4_4 > 0 then
            return v2_1 >= v4_4
        end
        return rZ(eg.Name) >= 5000
    else
        return true
    end
end
function fns.fn633(bd)
    if Library.Unloaded then
        return false
    end
    local tC = Toggles[bd]
    return tC ~= nil and tC.Value == true
end
function fns.fn656()
    rB(nil, true)
end
function fns.fn663()
    return rn.Character
end
function fns.fn665(a8, a9, ba)
    return string.format("<b>%s</b> %s %s", a8, rJ("-", "#5a6070"), rJ(a9, ba))
end
function fns.fn685()
    if not Toggles.Fly.Value then
        local zM = qH()
        if zM then
            zM.PlatformStand = false
        end
    end
end
function fns.fn708(dA)
    local vE_1
    local vD_1
    vD_1, vE_1 = pcall(function()
        return DataService:GetData()
    end)
    local vF = vD_1 and type(vE_1) == "table" and vE_1.GearStock and vE_1.GearStock.Stocks
    if not vF then
        return 0
    end
    local vD_2 = vE_1.GearStock.Stocks[dA]
    local vE_2 = type(vD_2) == "table" and tonumber(vD_2.Stock)
    return vE_2 or 0
end
function fns.fn710(bs, bt)
    local tX = Options[bs]
    if tX == nil or tX.Value == nil then
        return bt
    end
    return tX.Value
end
function fns.fn724(az, aA)
    return az[2] < aA[2]
end
function fns.fn808(cG)
    local uL = qm()
    if not uL then
        return false
    end
    local uM = rV("AttackTravel", "Teleport")
    if uM == "Tween" then
        local uM_1 = TweenService:Create(uL, TweenInfo.new(0.35, Enum.EasingStyle.Linear), { CFrame = cG })
        uM_1:Play()
        uM_1.Completed:Wait()
    else
        uL.CFrame = cG
    end
    return true
end
function fns.onUnload()
    Library:Unload()
end
function fns.onPlayerRemoving()
    task.wait(0.3)
    if Library.Unloaded then
        return
    end
    if Options.GiftPlayers then
        Options.GiftPlayers:SetValues(rp())
    end
end
function fns.fn854(dn)
    local vt = dn
    local vu = {}
    if vt then
        vt = dn:FindFirstChild("Main")
    end
    if vt then
        vt = dn.Main:FindFirstChild("Plant_Spaces")
    end
    local vv = vt
    if not vv then
        return vu
    end
    for i, child in vv:GetChildren() do
        if child.Name:find("Plant_Area") then
            vu[#vu + 1] = child
        end
    end
    return vu
end
function fns.fn878()
    return GetFarm(rn)
end
function fns.fn924(i4)
    local DiscordGroup = i4:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = r0 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = r0 })
end
function fns.fn942(bB, bC)
    if not rs(bB) then
        return true
    end
    return qG(bB)[bC] == true
end
function fns.onExportConfigToClipboard()
    local AR_1
    local AQ_1
    AQ_1, AR_1 = pcall(HttpService.JSONEncode, HttpService, rg())
    if not AQ_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local AQ_2 = setclipboard or toclipboard
    local AQ_3 = type(AQ_2) ~= "function" or not pcall(AQ_2, AR_1)
    if AQ_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
function fns.fn969(df)
    local vj = df
    local vk = {}
    if vj then
        vj = df:FindFirstChild("Main")
    end
    if vj then
        vj = df.Main:FindFirstChild("Farmer_Platforms")
    end
    local vl = vj
    if not vl then
        return vk
    end
    for i, child in vl:GetChildren() do
        local vj_1 = child:GetAttribute("Occupied") ~= true and not child:FindFirstChild("Farmer")
        if vj_1 then
            vk[#vk + 1] = child
        end
    end
    return vk
end
function fns.onInputChanged(k6)
    local UserInputType = k6.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        rN = tick()
    end
end
function fns.onCopyPayPalLink()
    qk(sf, "Copied PayPal link")
end
function fns.fn1000()
    if not Toggles.WalkSpeedEnabled.Value then
        local zO = qH()
        if zO then
            zO.WalkSpeed = 16
        end
    end
end
function fns.onPlayerAdded()
    task.wait(0.3)
    if Library.Unloaded then
        return
    end
    if Options.GiftPlayers then
        Options.GiftPlayers:SetValues(rp())
    end
end
function fns.onCopySolanaAddress()
    qk(qj, "Copied Solana address")
end
function fns.fn1064()
    local t7_1
    local attr = rn:GetAttribute("Cash")
    local t6_1
    if type(attr) == "number" then
        return attr
    end
    t6_1, t7_1 = pcall(function()
        return DataService:GetData()
    end)
    local t8 = t6_1 and type(t7_1) == "table"
    if t8 then
        local t6_2 = tonumber(t7_1.Cash) or 0
        return t6_2
    end
    return 0
end
function fns.fn1067(dJ)
    local vL_1
    local vK_1
    vK_1, vL_1 = pcall(function()
        return DataService:GetData()
    end)
    local vM = vK_1 and type(vL_1) == "table" and vL_1.EggStock and vL_1.EggStock.Stocks
    if not vM then
        return 0
    end
    local vK_2 = vL_1.EggStock.Stocks[dJ]
    local vL_2 = type(vK_2) == "table" and tonumber(vK_2.Stock)
    return vL_2 or 0
end
function fns.fn1069()
    qI(Toggles.AutoImmune.Value)
    if Toggles.AutoImmune.Value then
        rX()
    end
end
function fns.fn1071()
    local wG = qD()
    local wH = wG and wG:FindFirstChild("Main") and wG.Main:FindFirstChild("Farmer_Platforms")
    if not wH then
        return
    end
    for i, child in wH:GetChildren() do
        local Farmer = child:FindFirstChild("Farmer")
        local wH_1 = Farmer and Farmer:GetAttribute("SeedName")
        if type(wH_1) == "string" then
            q7[child.Name] = wH_1
        elseif q7[child.Name] then
            q3[#q3 + 1] = q7[child.Name]
            q7[child.Name] = nil
        end
    end
end
function fns.fn1087()
    local u8 = {}
    for i, player in qh:GetPlayers() do
        if player ~= rn then
            u8[#u8 + 1] = player.Name
        end
    end
    table.sort(u8)
    if #u8 == 0 then
        u8[1] = "None"
    end
    return u8
end
function fns.fn1089()
    local xp_1
    local xo_1
    if #q3 == 0 then
        return
    end
    local xn = table.remove(q3, 1)
    xo_1, xp_1 = rB(xn, false)
    if xo_1 then
        local xo_2 = xp_1 or xn
        local xp_2 = sg(xo_2, 2)
        if xp_2 then
            rm(xp_2)
        end
    else
        q3[#q3 + 1] = xn
    end
end
function fns.fn1094(aZ, a_)
    if setclipboard then
        setclipboard(aZ)
    elseif toclipboard then
        toclipboard(aZ)
    end
    Library:Notify(a_)
end
function fns.fn1119()
    if os.clock() - qw < 2 then
        return
    end
    local yu = ro()
    local yv = tonumber(RebirthConfig.MaxRebirths) or 5
    if yu >= yv then
        return
    end
    local yv_1 = RebirthConfig.Levels[yu + 1]
    local yu_1 = yv_1 and tonumber(yv_1.Cash)
    local yv_2 = yu_1 or 0
    if r3() < yv_2 then
        return
    end
    qw = os.clock()
    pcall(function()
        Rebirth:InvokeServer()
    end)
end
function fns.fn1121()
    if os.clock() - qA < 0.8 then
        return
    end
    local yA = qG("GiftPlayers")
    if next(yA) == nil then
        return
    end
    local yB = qG("GiftTypes")
    local yC = yB.Farmer == true or not rs("GiftTypes")
    local yC_1 = yB.Fruits == true or not rs("GiftTypes")
    local yE
    if yC then
        yE = qZ(function(it)
            return CollectionService:HasTag(it, "FarmerTool")
        end)
    end
    local yC_2 = not yE
    if yC_2 ~= false then
        yC_2 = yC_1
    end
    if yC_2 then
        yE = qZ(function(iw)
            local yy = iw:FindFirstChild("Weight") ~= nil or iw:FindFirstChild("Item_String") ~= nil
            return yy
        end)
    end
    if not yE then
        return
    end
    r_(yE)
    for i, player in qh:GetPlayers() do
        if yA[player.Name] then
            local yB_2 = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local yC_3 = yB_2
            if yB_2 then
                yB_2 = yC_3:FindFirstChild("GiftPrompt")
            end
            local yD_1 = yB_2
            if yC_3 then
                qA = os.clock()
                rb(yC_3.CFrame + Vector3.new(0, 3, 4))
                task.wait(0.15)
                if yD_1 then
                    yD_1.Enabled = true
                    r9(yD_1)
                end
                return
            end
        end
    end
end
function fns.onCopyVenmoLink()
    qk(r8, "Copied Venmo link")
end
function fns.fn1169(lm, ln)
    local Type = ln.Type
    if Type == "Toggle" then
        return { idx = lm, type = "Toggle", value = ln.Value == true }
    elseif Type == "Slider" then
        return { idx = lm, type = "Slider", value = tostring(ln.Value) }
    elseif Type == "Dropdown" then
        return { idx = lm, type = "Dropdown", multi = ln.Multi == true, value = ln.Value }
    elseif Type == "Input" then
        local An = ln.Value or ""
        return { idx = lm, type = "Input", text = tostring(An) }
    elseif Type == "ColorPicker" then
        return { idx = lm, type = "ColorPicker", value = ln.Value:ToHex(), transparency = ln.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = lm,
            type = "KeyPicker",
            mode = ln.Mode,
            key = ln.Value,
            modifiers = ln.Modifiers,
            toggled = ln.Toggled
        }
    else
        return nil
    end
end
function fns.antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            ra(true)
        end
    end
end
function fns.onCopyEthereumAddress()
    qk(qv, "Copied Ethereum address")
end
function fns.fn1200(fV, fW)
    local xa_1
    local w9_1
    local w8_1
    if os.clock() - qM < 0.35 then
        return false
    end
    local Farmers = Workspace:FindFirstChild("Farmers")
    if not Farmers then
        return false
    end
    local w7 = r3()
    xa_1, w9_1, w8_1 = nil, nil, nil
    local xb = qm()
    for i, child in Farmers:GetChildren() do
        local HumanoidRootPart = child:FindFirstChild("HumanoidRootPart")
        local xc = HumanoidRootPart and HumanoidRootPart:FindFirstChildOfClass("ProximityPrompt")
        local xd = HumanoidRootPart
        if xd then
            xd = xc
        end
        if xd then
            xd = xc.Enabled
        end
        if xd then
            local xc_1 = tonumber(child:GetAttribute("HirePrice")) or 0
            if w7 >= xc_1 then
                local xc_2 = child:GetAttribute("IsLuckyBlockFarmer") == true or child.Name == "LuckyBlockFarmer"
                local xd_2 = xc_2
                if fW then
                    if xc_2 then
                        xc_2 = qP(child:GetAttribute("LuckyBlockName"))
                    end
                    if xc_2 then
                        local xe_1 = xb and (xb.Position - HumanoidRootPart.Position).Magnitude or 0
                        local xc_4 = not xa_1
                        if not xc_4 then
                            xc_4 = xe_1 < w8_1
                        end
                        if xc_4 then
                            xa_1, w9_1, w8_1 = child, HumanoidRootPart, xe_1
                        end
                    end
                elseif not xd_2 then
                    local attr = child:GetAttribute("SeedName")
                    local xd_3 = type(attr) == "string" and re(attr)
                    if xd_3 and (fV == nil or attr == fV) then
                        local xd_4 = xb and (xb.Position - HumanoidRootPart.Position).Magnitude or 0
                        local xc_8 = not xa_1
                        if not xc_8 then
                            xc_8 = xd_4 < w8_1
                        end
                        if xc_8 then
                            xa_1, w9_1, w8_1 = child, HumanoidRootPart, xd_4
                        end
                    end
                end
            end
        end
    end
    if not (xa_1 and w9_1) then
        return false
    end
    qM = os.clock()
    rb(w9_1.CFrame + Vector3.new(0, 3, 3))
    task.wait(0.1)
    local ProximityPrompt = w9_1:FindFirstChildOfClass("ProximityPrompt")
    r9(ProximityPrompt)
    return true, xa_1:GetAttribute("SeedName")
end
function fns.fn1226(by)
    return next(qG(by)) ~= nil
end
function fns.fn1231()
    local w1 = qD()
    local w5 = if #q4(w1) == 0 then 1 else 0
    if w5 == 1 then
        return
    end
    local w1_1 = qZ(function(fP)
        return CollectionService:HasTag(fP, "FarmerTool")
    end)
    if w1_1 then
        rm(w1_1)
    end
end
function fns.fn1232(dX)
    local vU = EggData.Tiers[dX]
    local vV = vU and tonumber(vU.Price)
    return vV or 0
end
function fns.fn1257(bj)
    local tF = Options[bj]
    local tG = tF and tF.Value
    local tF_1 = {}
    if type(tG) ~= "table" then
        local tG_1 = tG ~= ""
        local tI_1 = type(tG) == "string" and tG_1
        if tI_1 and tG ~= "None" then
            tF_1[tG] = true
        end
        return tF_1
    end
    for k, v in tG do
        local tG_3 = v == true
        local tH_1 = type(k) == "string" and tG_3
        if tH_1 and k ~= "None" then
            tF_1[k] = true
        else
            local tG_5 = v ~= "None"
            local tH_2 = type(v) == "string" and tG_5
            if tH_2 then
                tF_1[v] = true
            end
        end
    end
    return tF_1
end
function fns.fn1262(le, lf)
    local Ad_1 = (le == "Toggle" and Toggles or Options)[lf]
    local Ac_2 = type(Ad_1) == "table" and Ad_1.Type == le
    local Ac_3 = Ac_2 and Ad_1
    local Al = if Ac_3 then 1 else 0
    local Aj = 1011 * Al + 3494 * (1 - Al)
    local Ak = 2801 * Al + 3013 * (1 - Al)
    if not ((Aj * 2270 + Ak * 555 + Aj * Ak) % 16777213 == 6681336) then
        Ac_3 = nil
    end
    return Ac_3
end
function fns.fn1277(aH, aI)
    return aH[2] < aI[2]
end
qh = nil
qj = nil
qk = nil
qm = nil
Rebirth = nil
qo = nil
qp = nil
qq = nil
connection5 = nil
ShovelSwing = nil
qu = nil
qv = nil
qw = nil
qz = nil
qA = nil
connection6 = nil
qD = nil
qE = nil
qG = nil
qH = nil
qI = nil
qL = nil
qM = nil
qP = nil
qR = nil
qS = nil
qV = nil
connection4 = nil
Options = nil
qZ = nil
q1 = nil
Toggles = nil
q3 = nil
local Ragdoll, ql, qr, qx, SellCategories, BuyEggStock, qF, BuyGearStock, qK, qN, qO, FarmerAction, qT, qU, Plant, q_, q0
q4 = nil
connection2 = nil
SaveManager = nil
q7 = nil
ra = nil
rb = nil
rd = nil
re = nil
rg = nil
PlayerGui = nil
ri = nil
Library = nil
rk = nil
rl = nil
rm = nil
rn = nil
ro = nil
rp = nil
connection = nil
rs = nil
Workspace = nil
rv = nil
CollectionService = nil
rx = nil
rz = nil
rA = nil
rB = nil
TweenService = nil
connection3 = nil
rG = nil
DataService = nil
rJ = nil
rN = nil
GetFarm = nil
rQ = nil
rR = nil
local q8, q9, rc, rf, rr, Client, Mutations, rC, Item_Module, CoreGui, rK, rL, GuiService, rP
HttpService = nil
Label = nil
rV = nil
VirtualUser = nil
rX = nil
RebirthConfig = nil
rZ = nil
r_ = nil
r0 = nil
UserInputService = nil
r3 = nil
EggData = nil
GearData = nil
r8 = nil
r9 = nil
sc = nil
SeedData = nil
sf = nil
sg = nil
local rS, r1, r5, r6, sa, sb
rS = nil
r1 = nil
r5 = nil
r6 = nil
sa = nil
sb = nil
local sd
qh, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, TweenService, CollectionService, Workspace, rn, PlayerGui = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
qh = game:GetService("Players")
local Bq_26 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
TweenService = game:GetService("TweenService")
CollectionService = game:GetService("CollectionService")
Workspace = game:GetService("Workspace")
rn = qh.LocalPlayer
PlayerGui = rn:WaitForChild("PlayerGui")
if getgenv then
    getgenv().gethui = function()
        return PlayerGui
    end
end
Plant, FarmerAction, BuyGearStock, BuyEggStock, SellCategories, ShovelSwing, Rebirth, Ragdoll, SeedData, GearData, EggData, RebirthConfig, GetFarm, DataService, Item_Module, Mutations, Client, Library = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pcall(fns.fn615)
local Bq_43 = "Snatch a Seed"
local Bq_39 = Bq_26:WaitForChild("Events")
Plant = Bq_39:WaitForChild("Plant")
FarmerAction = Bq_39:WaitForChild("FarmerAction")
BuyGearStock = Bq_39:WaitForChild("BuyGearStock")
BuyEggStock = Bq_39:WaitForChild("BuyEggStock")
SellCategories = Bq_39:WaitForChild("SellCategories")
ShovelSwing = Bq_39:WaitForChild("ShovelSwing")
Rebirth = Bq_39:WaitForChild("Rebirth")
Ragdoll = Bq_39:WaitForChild("Ragdoll")
SeedData = require(Bq_26:WaitForChild("Data"):WaitForChild("SeedData"))
GearData = require(Bq_26:WaitForChild("Data"):WaitForChild("GearData"))
EggData = require(Bq_26:WaitForChild("Data"):WaitForChild("EggData"))
RebirthConfig = require(Bq_26:WaitForChild("Data"):WaitForChild("RebirthConfig"))
local Bq_56 = require(Bq_26:WaitForChild("FarmerModules"):WaitForChild("Config"))
GetFarm = require(Bq_26:WaitForChild("Modules"):WaitForChild("GetFarm"))
DataService = require(Bq_26:WaitForChild("Modules"):WaitForChild("DataService"))
Item_Module = require(Bq_26:WaitForChild("Item_Module"))
Mutations = require(Bq_26:WaitForChild("Modules"):WaitForChild("Mutations"))
Client = require(Bq_26:WaitForChild("Blink"):WaitForChild("Blink"):WaitForChild("Client"))
Library = getgenv().Library
pcall(fns.fn134)
if setthreadidentity then
    setthreadidentity(8)
end
SaveManager, Toggles, Options, qR, qL, qE, qz, qv, qp, qj, sf, r8, rl = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Bq_26 = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
qR = "https://discord.gg/K7Qxnxkk46"
qL = "https://discord.gg/K7Qxnxkk46"
qE = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
qz = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
qv = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
qp = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
qj = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
sf = ""
r8 = ""
local Bq_63 = "#345d9d"
local Bq_76 = "#f7931a"
local Bq_8 = "#627eea"
local Bq_21 = "#26a17b"
local Bq_34 = "#14f195"
local Bq_47 = "#0070ba"
local Bq_59 = "#008cff"
local Bq_72 = "#7fd47f"
local Bq_5 = "#6ec1ff"
rl = "#e8a34d"
local Bq_17 = "#8b93a3"
local Bq_30 = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Prismatic", "Secret", "Godly" }
local Bq_1 = {}
for k in SeedData do
    Bq_1[#Bq_1 + 1] = k
end
table.sort(Bq_1)
Bq_39 = {}
for k in Bq_56.SeedConfigs do
    Bq_39[#Bq_39 + 1] = k
end
table.sort(Bq_39)
local Bq_68 = {}
for k in Bq_56.LuckyBlockConfigs do
    Bq_68[#Bq_68 + 1] = k
end
table.sort(Bq_68)
Bq_56 = {}
local Bq_51 = {}
for k, v in GearData do
    Bq_37 = #Bq_51 + 1
    Bq_24 = tonumber(v.LayoutOrder) or 99
    Bq_51[Bq_37] = { k, Bq_24 }
end
local Bq_11 = 5
repeat
    if (Bq_11 * 1 + 7) * 21 % 4 == ((Bq_11 * 1 + 7) * 21 + 4) % 4 then
        table.sort(Bq_51, fns.fn724)
    else
        table.sort(Bq_51, fns.fn724)
    end
    Bq_11 = (Bq_11 + 4) % 8
until (Bq_11 * 5 + 0) % 8 == 5
for k, v in Bq_51 do
    Bq_56[#Bq_56 + 1] = v[1]
end
Bq_51 = {}
Bq_37 = {}
for k, v in EggData.Tiers do
    Bq_24 = #Bq_37 + 1
    Bq_11 = tonumber(v.LayoutOrder) or 99
    Bq_37[Bq_24] = { k, Bq_11 }
end
table.sort(Bq_37, fns.fn1277)
for k, v in Bq_37 do
    Bq_51[#Bq_51 + 1] = v[1]
end
q7, q3, q0, qS, qM, qF, qA, qw, qq, Bq_79, qk, r0, rJ, rv, q9, qG, rV, rs, rd, qV, qH, qm, r3, ro, qD, qo, rZ, rz, r9, rR, rb, qZ, r_, rp, q4, ql, rK, rr, qN, r1, rC, re, qP, qx, r5, qK, rA, sa, rc, sg, rm, qr, rB, qO, r6, rf, q8, rP, sb, q_, rS, qT, rL, qU, qI, rX = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Bq_28 = { "All", "Rarity", "Cheap", "High Value" }
local Bq_41 = { "Teleport", "Tween" }
local Bq_54 = { "Farmer", "Fruits" }
local Bq_66 = { "Fruits", "Farmers", "Pets" }
q7 = {}
q3 = {}
q0 = 0
qS = 0
qM = 0
qF = 0
qA = 0
qw = 0
qq = 0
qk = fns.fn1094
r0 = fns.fn300
rJ = fns.fn463
rv = fns.fn665
q9 = fns.fn633
qG = fns.fn1257
rV = fns.fn710
rs = fns.fn1226
rd = fns.fn942
if (not q9 or not q9) and (qH or not qr) or (Bq_79 or not Bq_79) and (qr and not qr) or not ((not q9 or not q9) and (qH or not qr) or (Bq_79 or not Bq_79) and (qr and not qr)) then
    qV = fns.fn663
end
qH = fns.fn158
qm = fns.fn120
r3 = fns.fn1064
ro = fns.fn159
qD = fns.fn878
qo = fns.fn307
rZ = fns.fn122
rz = function(ck)
    local uz_1, uz_2
    if not ck then
        return 0
    end
    local Weight = ck:FindFirstChild("Weight")
    local uw_2
    local ux = Weight and tonumber(Weight.Value)
    local ux_1
    local uw_1 = ux or 1
    uw_2, uz_1 = pcall(Item_Module.Return_Data, Item_Module, ck.Name)
    local uA = uw_2 and type(uz_1) == "table" and tonumber(uz_1[3])
    local uA_1
    if uA then
        ux_1 = uz_1[3]
    else
        ux_1 = rZ(ck.Name)
    end
    local uw_3 = 1
    uz_2, uA_1 = pcall(function()
        return Mutations:CalcValueMulti(ck)
    end)
    local uB = uz_2 and type(uA_1) == "number"
    if uB then
        uw_3 = uA_1
    end
    return math.round(ux_1 * uw_3 * uw_1)
end
r9 = function(cC)
    local uJ = cC and cC:IsA("ProximityPrompt") and cC.Enabled
    if not uJ then
        return false
    elseif fireproximityprompt then
        pcall(fireproximityprompt, cC)
        return true
    else
        pcall(function()
            cC:InputHoldBegin()
            task.wait(cC.HoldDuration + 0.05)
            cC:InputHoldEnd()
        end)
        return true
    end
end
rR = fns.fn808
rb = fns.fn531
if (qF and r3 or not qF and rK) and (not rK or qF or (rK or qF)) and not ((qF and r3 or not qF and rK) and (not rK or qF or (rK or qF))) then
    rb = function(cS)
        local function u0(cU)
            if not cU then
                return nil
            end
            for i, child in cU:GetChildren() do
                local uQ = child:IsA("Tool") and cS(child)
                if uQ then
                    return child
                end
            end
            return nil
        end
        local u1 = u0(qV()) or u0(rn:FindFirstChild("Backpack"))
        return u1
    end
else
    qZ = function(cS)
        local function u0(cU)
            if not cU then
                return nil
            end
            for i, child in cU:GetChildren() do
                local uQ = child:IsA("Tool") and cS(child)
                if uQ then
                    return child
                end
            end
            return nil
        end
        local u1 = u0(qV()) or u0(rn:FindFirstChild("Backpack"))
        return u1
    end
end
r_ = function(c2)
    local u3
    if not c2 then
        return false
    elseif c2.Parent == qV() then
        return true
    else
        u3 = qH()
        if not u3 then
            return false
        end
        pcall(function()
            u3:EquipTool(c2)
        end)
        return c2.Parent == qV()
    end
end
rp = fns.fn1087
q4 = fns.fn969
ql = fns.fn854
rK = fns.fn184
rr = fns.fn708
qN = fns.fn1067
r1 = fns.fn149
rC = fns.fn1232
if ((ro or not q8 or (not ro or not q9)) and (q8 or qx or q9 and not q8) or (q8 and not q9 and (not q8 and q9) or not rA and false and (rX or q8)) or ((q8 or ro) and (q9 and rA) or (not q9 and rX or not qx and not qx)) and (q8 and q8 and (q9 and not qx) and ((rX or not ro) and (not rA and not rA)))) and not ((ro or not q8 or (not ro or not q9)) and (q8 or qx or q9 and not q8) or (q8 and not q9 and (not q8 and q9) or not rA and false and (rX or q8)) or ((q8 or ro) and (q9 and rA) or (not q9 and rX or not qx and not qx)) and (q8 and q8 and (q9 and not qx) and ((rX or not ro) and (not rA and not rA)))) then
    qP = fns.fn204
    re = fns.fn453
else
    re = fns.fn204
    qP = fns.fn453
end
qx = fns.fn456
r5 = fns.fn625
qK = fns.fn421
rA = fns.fn143
sa = fns.fn190
rc = fns.fn1071
sg = function(fo, fp)
    local wR = os.clock()
    local wT = wR + (fp or 1.5)
    while os.clock() < wT do
        local wR_1 = qZ(function(fs)
            local wP = CollectionService:HasTag(fs, "FarmerTool") and fs:GetAttribute("SeedName") == fo
            return wP
        end)
        if wR_1 then
            return wR_1
        end
        task.wait(0.1)
    end
    return nil
end
rm = function(fz)
    local wV
    local wW = qD()
    local wX = q4(wW)
    if #wX == 0 then
        return false
    end
    wV = wX[1]
    r_(fz)
    task.wait(0.1)
    rb(wV.CFrame + Vector3.new(0, 4, 0))
    pcall(function()
        FarmerAction:FireServer("PlaceFromTool", wV.Name)
    end)
    return true
end
qr = fns.fn1231
rB = fns.fn1200
qO = fns.fn1089
r6 = fns.fn514
rf = fns.fn656
q8 = fns.fn273
rP = function()
    local xL, attr
    if os.clock() - q0 < 0.2 then
        return
    end
    local xN = qD()
    local xO = ql(xN)
    if #xO == 0 then
        return
    end
    local xN_1 = qZ(function(gY)
        if gY:GetAttribute("ItemType") ~= "Seed" then
            return false
        end
        local xI = tonumber(gY:GetAttribute("Quantity")) or 0
        if xI < 1 then
            return false
        end
        return qx(gY:GetAttribute("Seed"))
    end)
    if not xN_1 then
        return
    end
    attr = xN_1:GetAttribute("Seed")
    if type(attr) ~= "string" then
        return
    end
    r_(xN_1)
    xL = xO[math.random(1, #xO)]
    q0 = os.clock()
    pcall(function()
        Plant:FireServer(rK(xL), attr, xL.Name)
    end)
end
sb = function()
    local xT
    local xW_1
    local xV_1
    local xU = qD()
    xV_1, xW_1 = qK(xU)
    xT = {}
    for k, v in xV_1 do
        if r5(v, xW_1) then
            xT[#xT + 1] = v
            if #xT >= 20 then
                break
            end
        end
    end
    if #xT == 0 then
        return
    end
    local xU_1 = xT[1]
    local pivot = xU_1:GetPivot()
    rb(pivot + Vector3.new(0, 4, 0))
    pcall(function()
        Client.Collect.Fire(xT)
    end)
end
q_ = function()
    if not rs("BuyGears") then
        return
    end
    local x6 = r3()
    for k in qG("BuyGears") do
        local yd = k
        local x7 = r1(yd)
        local x8 = rr(yd) > 0 and x6 >= x7
        if x8 then
            pcall(function()
                BuyGearStock:FireServer(yd)
            end)
            x6 -= x7
            task.wait(0.2)
        end
    end
end
rS = function()
    if not rs("BuyEggs") then
        return
    end
    local ye = r3()
    for k in qG("BuyEggs") do
        local yl = k
        local yf = rC(yl)
        local yg = qN(yl) > 0 and ye >= yf
        if yg then
            pcall(function()
                BuyEggStock:FireServer(yl)
            end)
            ye -= yf
            task.wait(0.2)
        end
    end
end
qT = function()
    local ym
    if os.clock() - qF < 2 then
        return
    end
    ym = {}
    for k in qG("SellTypes") do
        ym[#ym + 1] = k
    end
    if #ym == 0 then
        return
    end
    qF = os.clock()
    local StandTeleports = Workspace:FindFirstChild("StandTeleports")
    local yo = StandTeleports and StandTeleports:FindFirstChild("Sell")
    if yo then
        rb(yo.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.1)
    end
    pcall(function()
        SellCategories:FireServer({ Categories = ym })
    end)
end
rL = fns.fn1119
qU = fns.fn1121
qI = function(iJ)
    pcall(function()
        for k, v in getconnections(Ragdoll.OnClientEvent) do
            local yT = v
            pcall(function()
                if iJ then
                    yT:Disable()
                else
                    yT:Enable()
                end
            end)
        end
    end)
end
rX = function()
    qI(true)
    local yV = qV()
    if not yV then
        return
    end
    local Humanoid = yV:FindFirstChildOfClass("Humanoid")
    if Humanoid then
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        Humanoid.PlatformStand = false
        pcall(function()
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end
    for i, descendant in yV:GetDescendants() do
        if descendant.Name == "RagdollConstraint" or descendant.Name == "RagdollAttachment" then
            descendant:Destroy()
        end
    end
end
Bq_37 = Library:CreateWindow({
    Title = "[Beta]Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = qR, Copyable = true }, "|", Bq_43 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
pcall(fns.fn218)
Bq_79 = {
    Info = Bq_37:AddTab("Info", "info"),
    Farm = Bq_37:AddTab("Farm", "sprout"),
    Shop = Bq_37:AddTab("Shop", "shopping-cart"),
    Gift = Bq_37:AddTab("Gift", "gift"),
    Player = Bq_37:AddTab("Player", "person-standing"),
    Settings = Bq_37:AddTab("Settings", "settings")
}
Bq_11 = fns.fn924
for k, v in Bq_79 do
    Bq_11(v)
end
qu, Bq_37, GameInfoGroup, Label, rQ, Bq_15 = nil, nil, nil, nil, nil, nil
Bq_24 = 11
repeat
    Bq_11 = (Bq_24 * 1 + 0) % 3 + 1
    if Bq_11 <= 2 then
        if Bq_11 <= 1 then
            local C1 = bit32.rrotate(bit32.bxor(bit32.lrotate(Bq_24, 8), string.byte(tostring(Bq_37))), 14)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(C1, 1919112341), 1196513445), (bit32.bxor(bit32.band(C1, 2375854954), 2909330736))), 1196513445), 2909330736) == C1 then
                rQ = tostring(game.JobId)
            else
                Bq_15 = tostring(game.JobId)
            end
            Bq_24 = (Bq_24 + 7) % 12
        else
            Bq_11 = {
                "szuqjbromv",
                "vzawvluzgfl",
                "xguaftc",
                "zfynsdxioq",
                "gzwjxcfsm",
                "ahgsr",
                "rujelmsjrnh",
                "ssyvdfx"
            }
            local B7 = Bq_24
            Bq_70 = Bq_11[B7 % 8 + 1]
            if Bq_70:len() <= Bq_70:reverse():rep(B7 % 3 + 2):len() then
                Bq_15 = #rQ > 18
            else
                rQ = #Bq_15 > 18
            end
            Bq_24 = (Bq_24 + 10) % 12
        end
    else
        if (Bq_24 * 2 + 3) * 4 % 3 == ((Bq_24 * 2 + 3) * 4 + 4) % 3 then
            rl = "Unknown"
            pcall(fns.fn455)
            rJ = (nil):AddLeftGroupbox("Account", "circle-user")
            rJ:AddLabel(Bq_37("User", Label.Name, qu), true)
            rJ:AddLabel(Bq_37("Status", "Keyless", qu), true)
            rJ:AddLabel(Bq_37("Executor", rl, qu), true)
            rn = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
            rn:AddLabel(GameInfoGroup(Bq_72 .. " [" .. tostring(game.PlaceId) .. "]", Bq_79), true)
            rn:AddLabel(Bq_37("Place ID", tostring(game.PlaceId), Bq_79), true)
            Bq_43 = rn:AddLabel(Bq_37("Session time", "0s", rv), true)
        else
            qu = "Unknown"
            pcall(fns.fn455)
            Bq_37 = Bq_79.Info:AddLeftGroupbox("Account", "circle-user")
            Bq_37:AddLabel(rv("User", rn.Name, Bq_72), true)
            Bq_37:AddLabel(rv("Status", "Keyless", Bq_72), true)
            Bq_37:AddLabel(rv("Executor", qu, Bq_72), true)
            GameInfoGroup = Bq_79.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            GameInfoGroup:AddLabel(rJ(Bq_43 .. " [" .. tostring(game.PlaceId) .. "]", Bq_5), true)
            GameInfoGroup:AddLabel(rv("Place ID", tostring(game.PlaceId), Bq_5), true)
            Label = GameInfoGroup:AddLabel(rv("Session time", "0s", rl), true)
        end
        Bq_24 = (Bq_24 + 7) % 12
    end
until (Bq_24 * 5 + 3) % 12 == 10
if Bq_15 then
    Bq_37 = 2
    repeat
        Bq_24 = (vector.create((Bq_37 * 7 + 5) % 11 + 1, (Bq_37 * 11 + 3) % 13 + 1, (Bq_37 * 6 + 1) % 17 + 1))
        Bq_11 = (vector.create((Bq_37 * 7 + 4) % 11 + 1, (Bq_37 * 7 + 6) % 13 + 1, (Bq_37 * 8 + 4) % 17 + 1))
        Bq_70 = (vector.create((Bq_37 * 1 + 6) % 11 + 1, (Bq_37 * 5 + 5) % 13 + 1, (Bq_37 * 7 + 6) % 17 + 1))
        Bq_57 = (vector.create((Bq_37 * 3 + 8) % 11 + 1, (Bq_37 * 6 + 13) % 13 + 1, (Bq_37 * 15 + 16) % 17 + 1))
        if vector.dot(vector.cross(Bq_24, Bq_11), (vector.cross(Bq_70, Bq_57))) == vector.dot(Bq_24, Bq_70) * vector.dot(Bq_11, Bq_57) - vector.dot(Bq_24, Bq_57) * vector.dot(Bq_11, Bq_70) + 2 then
            rQ = string.sub(Bq_15, 1, 18) .. "..."
        else
            Bq_15 = string.sub(rQ, 1, 18) .. "..."
        end
        Bq_37 = (Bq_37 + 0) % 4
    until (Bq_37 * 3 + 1) % 4 == 3
end
Bq_37 = Bq_15 or rQ
rk, Bq_57, connection, connection2, connection3, rN, rG, connection4, connection5, q1, connection6, ra, ri, sd, rx, rg, sc = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Bq_23 = Bq_37
GameInfoGroup:AddLabel(rv("Server", Bq_23, Bq_17), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
rk = os.clock()
task.spawn(fns.worker)
local ScriptsGroup = Bq_79.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(rJ("Included in this hub", Bq_17), true)
ScriptsGroup:AddLabel(rJ(Bq_43, Bq_5), true)
local FeaturesGroup = Bq_79.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(rJ("Auto Farm", Bq_5), true)
FeaturesGroup:AddLabel(rJ("Auto Shop", rl), true)
FeaturesGroup:AddLabel(rJ("Auto Gift", Bq_72), true)
FeaturesGroup:AddLabel(rJ("Misc Utilities", Bq_17), true)
local SocialsGroup = Bq_79.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = r0 })
SocialsGroup:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
Bq_11 = Bq_79.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
Bq_11:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
Bq_11:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
Bq_11:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
Bq_11:AddButton({ Text = "Copy Discord Invite", Func = r0 })
local DonationsGroup = Bq_79.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(rJ("All donations are optional but appreciated.", rl), true)
DonationsGroup:AddLabel(rJ("If you donate you get a special role, just PING after you donate.", Bq_72), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(rJ("LTC / Litecoin", Bq_63), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = fns.onCopyLitecoinAddress })
DonationsGroup:AddLabel(rJ("BTC / Bitcoin", Bq_76), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = fns.onCopyBitcoinAddress })
DonationsGroup:AddLabel(rJ("ETH / Ethereum", Bq_8), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = fns.onCopyEthereumAddress })
DonationsGroup:AddLabel(rJ("USDT", Bq_21), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = fns.onCopyUSDTAddress })
DonationsGroup:AddLabel(rJ("Solana", Bq_34), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = fns.onCopySolanaAddress })
DonationsGroup:AddLabel(rJ("PayPal", Bq_47), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = fns.onCopyPayPalLink })
DonationsGroup:AddLabel(rJ("Venmo", Bq_59), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = fns.onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(rJ("Don't have any of the listed currencies but still wanna donate?", Bq_17), true)
DonationsGroup:AddLabel(rJ("DM me and we'll work something out.", Bq_5), true)
local FaqGroup = Bq_79.Info:AddRightGroupbox("FAQ", "circle-help")
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
local FarmGroup = Bq_79.Farm:AddLeftGroupbox("Farm", "sprout")
FarmGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
FarmGroup:AddToggle("AutoBuyFarmers", { Text = "Auto Buy Farmers", Default = false })
FarmGroup:AddDropdown("BuyFarmerRarities", { Text = "Farmer Rarities", Values = Bq_30, Multi = true, Default = {}, Expandable = true })
FarmGroup:AddDropdown("BuyFarmerList", { Text = "Farmers", Values = Bq_39, Multi = true, Default = {}, Expandable = true })
FarmGroup:AddToggle("AutoBuyLuckyBlockFarmer", { Text = "Auto Buy Lucky Block Farmer", Default = false })
FarmGroup:AddDropdown("LuckyBlockList", { Text = "Lucky Blocks", Values = Bq_68, Multi = true, Default = {}, Expandable = true })
local CropsGroup = Bq_79.Farm:AddRightGroupbox("Crops", "leaf")
CropsGroup:AddToggle("AutoPlant", { Text = "Auto Plant", Default = false })
CropsGroup:AddDropdown("PlantList", { Text = "Plants", Values = Bq_1, Multi = true, Default = {}, Expandable = true })
CropsGroup:AddDropdown("PlantRarities", { Text = "Plant Rarities", Values = Bq_30, Multi = true, Default = {}, Expandable = true })
CropsGroup:AddToggle("AutoCollect", { Text = "Auto Collect Fruits", Default = false })
CropsGroup:AddDropdown("CollectMode", { Text = "Collect Mode", Values = Bq_28, Default = "All" })
CropsGroup:AddDropdown("CollectRarities", { Text = "Collect Rarities", Values = Bq_30, Multi = true, Default = {}, Expandable = true })
local DefendGroup = Bq_79.Farm:AddRightGroupbox("Defend", "shield")
if (CropsGroup and connection or (connection or CropsGroup)) and (rk or not rk or not CropsGroup and connection) or not ((CropsGroup and connection or (connection or CropsGroup)) and (rk or not rk or not CropsGroup and connection)) then
    DefendGroup:AddToggle("AutoAttackSnatchers", { Text = "Auto Attack Snatchers", Default = false })
    DefendGroup:AddDropdown("AttackTravel", { Text = "Travel", Values = Bq_41, Default = "Teleport" })
    DefendGroup:AddToggle("AutoRebuyFarmer", { Text = "Auto Re-buy Farmer when stolen", Default = false })
    DefendGroup:AddToggle("AutoImmune", { Text = "Auto Immune on Players Attack", Default = false })
    Toggles.AutoImmune:OnChanged(fns.fn1069)
    Bq_57 = Bq_79.Shop:AddLeftGroupbox("Shop", "store")
else
    Bq_41:AddToggle("AutoAttackSnatchers", { Text = "Auto Attack Snatchers", Default = false })
    Bq_41:AddDropdown("AttackTravel", { Text = "Travel", Values = DefendGroup, Default = "Teleport" })
    Bq_41:AddToggle("AutoRebuyFarmer", { Text = "Auto Re-buy Farmer when stolen", Default = false })
    Bq_41:AddToggle("AutoImmune", { Text = "Auto Immune on Players Attack", Default = false })
    Bq_57.AutoImmune:OnChanged(fns.fn1069)
    Bq_79 = Toggles.Shop:AddLeftGroupbox("Shop", "store")
end
Bq_57:AddToggle("AutoBuyGears", { Text = "Auto Buy Gears", Default = false })
Bq_57:AddDropdown("BuyGears", { Text = "Gears", Values = Bq_56, Multi = true, Default = {}, Expandable = true })
Bq_57:AddToggle("AutoBuyPets", { Text = "Auto Buy Pets", Default = false })
Bq_57:AddDropdown("BuyEggs", { Text = "Eggs", Values = Bq_51, Multi = true, Default = {}, Expandable = true })
Bq_70 = Bq_79.Shop:AddRightGroupbox("Sell", "circle-dollar-sign")
Bq_70:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
Bq_70:AddDropdown("SellTypes", { Text = "Sell", Values = Bq_66, Multi = true, Default = { Fruits = true } })
Bq_15 = Bq_79.Gift:AddLeftGroupbox("Gift", "gift")
Bq_15:AddToggle("AutoGift", { Text = "Auto Gift", Default = false })
Bq_15:AddDropdown("GiftPlayers", { Text = "Players", Values = rp(), Multi = true, Default = {}, Expandable = true })
Bq_15:AddDropdown("GiftTypes", { Text = "Gift", Values = Bq_54, Multi = true, Default = { Farmer = true } })
local MovementGroup = Bq_79.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = Bq_79.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
connection = RunService.Stepped:Connect(fns.onStepped)
connection2 = UserInputService.JumpRequest:Connect(fns.onJumpRequest)
connection3 = RunService.RenderStepped:Connect(fns.onRenderStepped)
Toggles.Fly:OnChanged(fns.fn685)
Toggles.WalkSpeedEnabled:OnChanged(fns.fn1000)
ra = function(kE)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not kE)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not kE
        end
    end)
    if not kE then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(rn, "GameplayPaused", false)
        else
            rn.GameplayPaused = false
        end
    end)
end
Toggles.AntiGameplayPause:OnChanged(fns.fn571)
task.spawn(fns.antiGameplayPauseLoop)
local MenuGroup = Bq_79.Settings:AddLeftGroupbox("Menu", "menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
rN = tick()
rG = tick()
pcall(function()
    for k, v in getconnections(rn.Idled) do
        local z6 = v
        pcall(function()
            z6:Disable()
        end)
    end
end)
ri = fns.fn594
connection4 = UserInputService.InputBegan:Connect(fns.onInputBegan)
connection5 = UserInputService.InputChanged:Connect(fns.onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", fns.onUnload)
Bq_26:SetLibrary(Library)
Bq_26:SetFolder("TempoHub")
Bq_26:SaveDefault("Evil Hello Kitty")
Bq_26:ApplyToTab(Bq_79.Settings)
Bq_26:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/SnatchASeed")
Bq_24 = SaveManager:BuildConfigSection(Bq_79.Settings)
sd = fns.fn1262
if (not FlyGroup or not FlyGroup or (Bq_23 or not connection5)) and (not FlyGroup or not connection5 or DefendGroup) or not ((not FlyGroup or not FlyGroup or (Bq_23 or not connection5)) and (not FlyGroup or not connection5 or DefendGroup)) then
    rx = fns.fn1169
    rg = fns.fn243
    sc = function(lD)
        local AN
        AN = nil
        local AO = type(lD) ~= "table" or type(lD.idx) ~= "string" or type(lD.type) ~= "string" or SaveManager.Ignore[lD.idx]
        if AO then
            return false
        end
        AN = sd(lD.type, lD.idx)
        if not AN then
            return false
        end
        local AO_2 = pcall(function()
            if lD.type == "Input" then
                if type(lD.text) ~= "string" then
                    return
                end
                AN:SetValue(lD.text)
            elseif lD.type == "ColorPicker" then
                AN:SetValueRGB(Color3.fromHex(lD.value), lD.transparency)
            elseif lD.type == "KeyPicker" then
                AN:SetValue({ lD.key, lD.mode, lD.modifiers })
                if lD.mode == "Toggle" and lD.toggled ~= nil then
                    AN.Toggled = lD.toggled
                    AN:Update()
                end
            else
                AN:SetValue(lD.value)
            end
        end)
        return AO_2
    end
    Bq_24:AddDivider()
    Bq_24:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    Bq_24:AddButton("Export Config to Clipboard", fns.onExportConfigToClipboard)
    Bq_24:AddButton("Import Config from Clipboard Text", fns.onImportConfigFromClipboardTex)
    task.spawn(fns.antiAfkLoop)
    q1 = qh.PlayerAdded:Connect(fns.onPlayerAdded)
else
    qh = fns.fn1169
    q1 = fns.fn243
    rg = function(lD)
        local AN
        AN = nil
        local AO = type(lD) ~= "table" or type(lD.idx) ~= "string" or type(lD.type) ~= "string" or SaveManager.Ignore[lD.idx]
        if AO then
            return false
        end
        AN = sd(lD.type, lD.idx)
        if not AN then
            return false
        end
        local AO_1 = pcall(function()
            if lD.type == "Input" then
                if type(lD.text) ~= "string" then
                    return
                end
                AN:SetValue(lD.text)
            elseif lD.type == "ColorPicker" then
                AN:SetValueRGB(Color3.fromHex(lD.value), lD.transparency)
            elseif lD.type == "KeyPicker" then
                AN:SetValue({ lD.key, lD.mode, lD.modifiers })
                if lD.mode == "Toggle" and lD.toggled ~= nil then
                    AN.Toggled = lD.toggled
                    AN:Update()
                end
            else
                AN:SetValue(lD.value)
            end
        end)
        return AO_1
    end
    rx:AddDivider()
    rx:AddInput("SaveManager_ImportSource", { AllowEmpty = true, Finished = true, Text = "Paste exported config here" })
    rx:AddButton("Export Config to Clipboard", fns.onExportConfigToClipboard)
    rx:AddButton("Import Config from Clipboard Text", fns.onImportConfigFromClipboardTex)
    task.spawn(fns.antiAfkLoop)
    sc = Bq_24.PlayerAdded:Connect(fns.onPlayerAdded)
end
connection6 = qh.PlayerRemoving:Connect(fns.onPlayerRemoving)
task.spawn(function()
    local Bi = false
    repeat
        local Bf
        if not Library.Unloaded then
            if q9("AutoImmune") then
                rX()
            end
            if q9("AutoAttackSnatchers") then
                Bf = false
                pcall(function()
                    Bf = sa()
                end)
                if Bf then
                    task.wait(0.2)
                else
                    rc()
                    if q9("AutoRebuyFarmer") then
                        pcall(qO)
                    end
                    if q9("AutoBuyFarmers") then
                        pcall(r6)
                        pcall(qr)
                    end
                    if q9("AutoBuyLuckyBlockFarmer") then
                        pcall(rf)
                    end
                    if q9("AutoPlant") then
                        pcall(q8)
                        pcall(rP)
                    end
                    if q9("AutoCollect") then
                        pcall(sb)
                    end
                    if q9("AutoBuyGears") then
                        pcall(q_)
                    end
                    if q9("AutoBuyPets") then
                        pcall(rS)
                    end
                    if q9("AutoSell") then
                        pcall(qT)
                    end
                    if q9("AutoRebirth") then
                        pcall(rL)
                    end
                    if q9("AutoGift") then
                        pcall(qU)
                    end
                    task.wait(0.35)
                end
            else
                rc()
                if q9("AutoRebuyFarmer") then
                    pcall(qO)
                end
                if q9("AutoBuyFarmers") then
                    pcall(r6)
                    pcall(qr)
                end
                if q9("AutoBuyLuckyBlockFarmer") then
                    pcall(rf)
                end
                if q9("AutoPlant") then
                    pcall(q8)
                    pcall(rP)
                end
                if q9("AutoCollect") then
                    pcall(sb)
                end
                if q9("AutoBuyGears") then
                    pcall(q_)
                end
                if q9("AutoBuyPets") then
                    pcall(rS)
                end
                if q9("AutoSell") then
                    pcall(qT)
                end
                if q9("AutoRebirth") then
                    pcall(rL)
                end
                if q9("AutoGift") then
                    pcall(qU)
                end
                task.wait(0.35)
            end
        else
            Bi = true
        end
    until Bi
end)
Library:OnUnload(fns.fn315)
SaveManager:LoadAutoloadConfig()
end)(...)

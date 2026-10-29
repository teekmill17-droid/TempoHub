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
getgenv().TempoHoodSubtitle = "AUTOMATE A RESTAURANT"
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
local mT
local nC
local nj
local n0
local mZ
local nI
local mG
local SeedRollMessage
local getBackyardCellUpgradeCost
local PlayerUpgradeMessage
local getCropUpgradeCost
local mM
local ClientPlayerUpgradeState
local nU
local mS
local nB
local ni
local n_
local ClientPlotState
local getPlayerUpgradeCost
local no
local n5
local nN
local mL
local nu
local m9
local Workspace
local mR
local nA
local nh
local VirtualUser
local mX
local nG
local Library
local nn
local n4
local Label
local mK
local nt
local m8
local nS
local mQ
local connection
local ng
local nY
local mW
local nF
local getPlayerUpgradeLevel
local seedRollMessages
local getBackyardCellMaxLevel
local playerUpgradeMessages
local nL
local mJ
local ns
local m7
local nR
local mP
local clientPlayerMoney
local nf
local nX
local mV
local nE
local mC
local nl
local Toggles
local m0
local nK
local mI
local nr
local m6
local nQ
local mO
local nx
local Options
local mU
local ClientSeedRollState
local mB
local connection2
local m_
local nJ
local mH
local nq
local m5
local nP
local mN
local nd
local cropCatalog
function fns.fn1(eY)
    local s2 = nE(eY)
    if #s2 == 0 then
        return false
    end
    local s3
    for k, v in nQ() do
        if mI("PlantCrops", v.cropId) then
            s3 = v
            break
        end
    end
    if not s3 then
        return false
    end
    local s4 = s2[1]
    if s4.cframe then
        ni(s4.cframe, 3)
        mC(0.12)
    end
    m6(s3.tool)
    task.wait(0.08)
    seedRollMessages.server:emit(SeedRollMessage.SeedPacketPlantRequested, { plotId = eY.plotId, cellId = s4.cellId, inventoryItemUid = s3.inventoryItemUid })
    return true
end
function fns.worker3()
    while not Library.Unloaded do
        pcall(n4)
        task.wait(nX("CycleDelay", 0.2))
    end
end
function fns.fn41(bN)
    local qh = bN or nX("ZoneDwell", 0.4)
    task.wait(qh)
end
function fns.worker()
    local vH_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local vG = math.floor(os.clock() - n5)
        if vG < 60 then
            vH_1 = vG .. "s"
        elseif vG < 3600 then
            vH_1 = string.format("%dm %ds", math.floor((vG) / (60)), vG % 60)
        else
            vH_1 = string.format("%dh %dm", math.floor((vG) / (3600)), math.floor((vG % 3600) / (60)))
        end
        Label:SetText(ng("Session time", vH_1, mT))
    end
end
function fns.fn99(dY)
    local r2 = dY and dY.drones and dY.drones.farmer and typeof(dY.drones.farmer.pickUpCFrame) == "CFrame"
    if r2 then
        return dY.drones.farmer.pickUpCFrame
    end
    local r2_1 = dY and nL(dY.plotId)
    if not r2_1 then
        return nil
    end
    local DronePickUp = r2_1:FindFirstChild("DronePickUp")
    local r4 = DronePickUp and DronePickUp:IsA("BasePart")
    if r4 then
        return DronePickUp.CFrame
    end
    local DroneDropOffStack = r2_1:FindFirstChild("DroneDropOffStack")
    local r3_1 = DroneDropOffStack and DroneDropOffStack:IsA("BasePart")
    if r3_1 then
        return DroneDropOffStack.CFrame
    end
    return nil
end
function fns.fn103(aF, aG)
    if setclipboard then
        setclipboard(aF)
    elseif toclipboard then
        toclipboard(aF)
    end
    Library:Notify(aG)
end
function fns.fn104(eH)
    local sR = ClientSeedRollState.getRoll()
    if not sR or not eH or sR.plotId ~= eH.plotId or not sR.actionable then
        return false
    end
    local sS_1 = n_(sR, false)
    if not sS_1 then
        return false
    end
    seedRollMessages.server:emit(SeedRollMessage.SeedOfferPurchaseRequested, { plotId = sR.plotId, rollId = sR.rollId, offerId = sS_1.offerId })
    return true
end
function fns.fn117()
    local p_ = nS()
    local p0 = p_ and p_:FindFirstChild("HumanoidRootPart")
    return p0
end
function fns.fn144()
    local p5 = nS()
    local p6 = p5 and p5:FindFirstChildOfClass("Humanoid")
    return p6
end
function fns.fn149(a8)
    local pE = Options[a8]
    return pE and pE.Value
end
function fns.fn171(a2, a3)
    local pB = Options[a2]
    local pC = pB and tonumber(pB.Value)
    return pC or a3
end
function fns.fn187()
    connection:Disconnect()
    connection2:Disconnect()
end
function fns.fn188(h0)
    local vq = h0 and type(h0.customerCashSlots) == "table"
    if vq then
        mP("customerCash", h0.customerCashSlots)
    end
end
function fns.fn207(ix)
    local DiscordGroup = ix:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = nA })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = nA })
end
function fns.fn226(dK)
    local rO = dK and type(dK.customerCashSlots) == "table"
    if rO then
        for k, v in dK.customerCashSlots do
            local rO_1 = v.payload and v.payload.value
            if rO_1 == nil or rO_1 > 0 then
                return true
            end
        end
    end
    for k, v in mV.customerCash do
        local rO_3 = v.payload and v.payload.value
        if rO_3 == nil or rO_3 > 0 then
            return true
        end
    end
    return false
end
function fns.fn235(c8)
    local rn = not c8
    local ro = {}
    if not rn then
        rn = not c8.plantedBackyardCellsById
    end
    if not rn then
        rn = not c8.backyardCellsById
    end
    if rn then
        return ro
    end
    for k in c8.plantedBackyardCellsById do
        local rn_1 = c8.backyardCellsById[k]
        if rn_1 then
            table.insert(ro, { cellId = k, cframe = rn_1.cframe })
        end
    end
    table.sort(ro, function(dd, de)
        return mL(dd.cellId, de.cellId)
    end)
    return ro
end
function fns.onUnload()
    Library:Unload()
end
local function fn269(cA, cB)
    local qP = tonumber(string.match(cA, "%d+")) or 0
    local qP_1 = tonumber(string.match(cB, "%d+")) or 0
    return qP < qP_1
end
local function fn297(hL)
    local vf = nd()
    if not vf then
        return false
    end
    local vg = nt()
    for k, v in mZ() do
        local vh = getPlayerUpgradeLevel(vf, v)
        local vi = getPlayerUpgradeCost(v, vh)
        if vi ~= nil and vi <= vg then
            playerUpgradeMessages.server:emit(PlayerUpgradeMessage.PurchaseRequested, { plotId = hL.plotId, upgradeId = v })
            return true
        end
    end
    return false
end
local function fn298()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    mK = tick()
end
local function onCopyJoinScript_JobID()
    local iO = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, mW)
    nR(iO, "Copied join script to clipboard")
end
local function fn310(hs)
    local uZ = nB(hs)
    if not uZ then
        return false
    end
    ni(uZ, 2)
    mC(nX("ZoneDwell", 0.4) + 0.1)
    return true
end
local function fn321(ah)
    local o6 = not ah
    local pa = if o6 then 1 else 0
    local o8 = 1813 * pa + 1324 * (1 - pa)
    local o9 = 3340 * pa + 3660 * (1 - pa)
    if not ((o8 * 2817 + o9 * 2329 + o8 * o9) % 16777213 == 2164288) then
        o6 = not ah.stackKind
    end
    if o6 then
        return
    end
    local o6_1 = mV[ah.stackKind]
    if not o6_1 then
        o6_1 = {}
        mV[ah.stackKind] = o6_1
    end
    if type(ah.slots) == "table" then
        for k, v in ah.slots do
            table.insert(o6_1, v)
        end
    end
end
local function fn332()
    return ClientPlotState.get()
end
local function fn340(bd)
    local pK = Options[bd]
    return pK and pK.Value or {}
end
local function fn347(aY)
    local py = Toggles[aY]
    return py ~= nil and py.Value == true
end
local function fn350()
    local qn_1
    local qm_1
    qm_1, qn_1 = pcall(clientPlayerMoney)
    local qo = qm_1 and type(qn_1) == "number"
    if qo then
        return qn_1
    end
    return 0
end
local function fn395()
    local vC_1
    local vB_1
    if identifyexecutor then
        vC_1, vB_1 = identifyexecutor()
        local vD = vC_1 ~= ""
        local vE = type(vC_1) == "string" and vD
        if vE then
            local vD_1 = type(vB_1) == "string" and vB_1 ~= "" and vC_1 .. " " .. vB_1
            no = vD_1 or vC_1
        end
    end
end
local function fn396(an)
    if not an or not an.stackKind then
        return
    end
    local ph_1 = mV[an.stackKind]
    local pi = not ph_1 or type(an.slots) ~= "table"
    if pi then
        return
    end
    local pi_1 = {}
    for k, v in an.slots do
        pi_1[v.stackIndex] = true
    end
    local pj = {}
    for k, v in ph_1 do
        if not pi_1[v.stackIndex] then
            table.insert(pj, v)
        end
    end
    mV[an.stackKind] = pj
end
local function fn419(g7)
    local uG = not g7.customer or typeof(g7.customer.registerCFrame) ~= "CFrame"
    if uG then
        return false
    end
    ni(g7.customer.registerCFrame, 2)
    mC()
    return true
end
local function fn451(ey)
    if not ey or not ey.plotId then
        return false
    end
    local sK_1 = mN(ey.plotId)
    if not sK_1 then
        return false
    end
    local Parent = sK_1.Parent
    local sM = Parent and Parent:IsA("BasePart")
    if sM then
        ni(Parent.CFrame, 2)
        mC(0.15)
    end
    m5(sK_1)
    return true
end
local function fn452(eQ)
    if not mG("AutoSkipUnaffordable") then
        return false
    end
    local sX = ClientSeedRollState.getRoll()
    local sY = not sX or not eQ
    local s1 = if sY then 1 else 0
    local s_ = 4030 * s1 + 2911 * (1 - s1)
    local s0 = 641 * s1 + 693 * (1 - s1)
    if not ((s_ * 1593 + s0 * 3620 + s_ * s0) % 16777213 == 11323440) then
        sY = sX.plotId ~= eQ.plotId
    end
    if not sY then
        sY = not sX.actionable
    end
    if sY then
        return false
    end
    if not sX.offers or #sX.offers == 0 then
        return false
    elseif n_(sX, false) then
        return false
    else
        local s1_1 = if n_(sX, true) then 1 else 0
        if s1_1 == 1 then
            return true
        end
        return false
    end
end
local function onInputChanged(jn)
    local UserInputType = jn.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        mS = tick()
    end
end
local function fn510(cv)
    local qL = nu()
    if not qL or not cv then
        return false
    elseif cv.Parent == nS() then
        return true
    else
        qL:EquipTool(cv)
        return true
    end
end
local function fn559(bm, bn)
    local pV = nh(bm)
    local pZ = if not m0(pV) then 1 else 0
    if pZ == 1 then
        return true
    end
    return pV[bn] == true
end
local function worker2()
    while not Library.Unloaded do
        task.wait(2)
        if mG("AntiAfk") then
            local vV = tick() - mS
            local vW = tick() - mK
            if vV >= 300 and vW >= 60 then
                pcall(n0)
            else
                if vV < 300 and vW >= 300 then
                    pcall(n0)
                end
            end
        end
    end
end
local function onInputBegan()
    mS = tick()
end
local function fn630(di)
    local ru = di
    local rv = {}
    if ru then
        ru = type(di.customerCashSlots) == "table"
    end
    if ru then
        for k, v in di.customerCashSlots do
            local ru_1 = v.payload and v.payload.value
            local ru_2 = typeof(v.landingCFrame) == "CFrame"
            if ru_2 then
                ru_2 = ru_1 == nil or ru_1 > 0
            end
            if ru_2 then
                table.insert(rv, v.landingCFrame)
            end
        end
    end
    for k, v in mV.customerCash do
        local ru_3 = v.payload and v.payload.value
        local ru_4 = typeof(v.landingCFrame) == "CFrame"
        if ru_4 then
            ru_4 = ru_3 == nil or ru_3 > 0
        end
        if ru_4 then
            table.insert(rv, v.landingCFrame)
        end
    end
    if #rv == 0 and di and di.customer then
        if typeof(di.customer.cashCFrame) == "CFrame" then
            table.insert(rv, di.customer.cashCFrame)
        end
        if typeof(di.customer.withdrawalCFrame) == "CFrame" then
            table.insert(rv, di.customer.withdrawalCFrame)
        end
    end
    local ru_6 = di and nL(di.plotId)
    if ru_6 then
        local Earned_Cash = ru_6:FindFirstChild("Earned Cash")
        local rx_3 = Earned_Cash and Earned_Cash:IsA("BasePart")
        if rx_3 then
            table.insert(rv, Earned_Cash.CFrame)
        end
        local Cash = ru_6:FindFirstChild("Cash")
        local rw_4 = Cash and Cash:IsA("BasePart")
        if rw_4 then
            table.insert(rv, Cash.CFrame)
        end
    end
    return rv
end
local function fn631()
    nR(nG, "Copied Discord invite to clipboard")
end
local function fn639(cF)
    local qT = cF
    local qU = 0
    if qT then
        qT = cF.ownedBackyardCellIds
    end
    if qT then
        for k in cF.ownedBackyardCellIds do
            qU += 1
        end
    end
    return qU
end
local function fn640(gR)
    local ut = nF(gR)
    if #ut == 0 then
        return false
    end
    if mO > #ut then
        mO = 1
    end
    local uu = ut[mO]
    mO += 1
    if uu and uu.cframe then
        ni(uu.cframe, 3)
        mC()
        return true
    end
    return false
end
local function fn646(d7, d8)
    if not d7 then
        return false
    end
    local r9 = d7.cropId or d7.displayName
    local sf = if not mI("SeedCrops", r9) then 1 else 0
    if sf == 1 then
        return false
    end
    local r9_1 = tonumber(d7.cost) or 0
    if r9_1 > nX("SeedMaxCost", 1000000000000) then
        return false
    end
    local r9_2 = tonumber(d7.chanceOneIn) or 1
    if r9_2 < nX("SeedMinChance", 1) then
        return false
    elseif r9_2 > nX("SeedMaxChance", 1e+18) then
        return false
    else
        local r9_3 = not d8
        if r9_3 ~= false then
            r9_3 = r9_1 > nt()
        end
        if r9_3 then
            return false
        end
        return true
    end
end
local function fn683(cK)
    local q_ = not cK
    local q0 = {}
    local q5 = if q_ then 1 else 0
    local q3 = 458 * q5 + 4026 * (1 - q5)
    local q4 = 879 * q5 + 603 * (1 - q5)
    if not ((q3 * 1723 + q4 * 389 + q3 * q4) % 16777213 == 1533647) then
        q_ = not cK.ownedBackyardCellIds
    end
    if not q_ then
        q_ = not cK.backyardCellsById
    end
    if q_ then
        return q0
    end
    for k in cK.ownedBackyardCellIds do
        if (cK.plantedBackyardCellsById and cK.plantedBackyardCellsById[k]) == nil then
            local q__2 = cK.backyardCellsById[k]
            if q__2 then
                table.insert(q0, { cellId = k, cframe = q__2.cframe })
            end
        end
    end
    table.sort(q0, function(cR, cS)
        return mL(cR.cellId, cS.cellId)
    end)
    return q0
end
local function fn691(cW)
    local rb = not cW
    local rc = {}
    if not rb then
        rb = not cW.backyardCellsById
    end
    if rb then
        return rc
    end
    for k, v in cW.backyardCellsById do
        local rb_2 = not (cW.ownedBackyardCellIds and cW.ownedBackyardCellIds[k])
        if rb_2 ~= false then
            rb_2 = v.expanded == true
        end
        if rb_2 then
            local insert = table.insert
            local cframe = v.cframe
            local re = v.expansionLevel or 0
            local rf = v.floor or 1
            insert(rc, { cellId = k, cframe = cframe, expansionLevel = re, floor = rf })
        end
    end
    table.sort(rc, function(c3, c4)
        if c3.expansionLevel == c4.expansionLevel then
            if c3.floor == c4.floor then
                return mL(c3.cellId, c4.cellId)
            end
            return c3.floor < c4.floor
        end
        return c3.expansionLevel < c4.expansionLevel
    end)
    return rc
end
local function fn715(bT)
    local Plots = Workspace:FindFirstChild("Plots")
    local qk = Plots and Plots:FindFirstChild(bT)
    return qk
end
local function fn719(hc)
    local uI = m7(hc)
    if #uI == 0 then
        return false
    end
    local uJ = nL(hc.plotId)
    if uJ then
        local Earned_Cash = uJ:FindFirstChild("Earned Cash")
        local uL = Earned_Cash and Earned_Cash:IsA("BasePart")
        if uL then
            mU(Earned_Cash)
            mC(nX("ZoneDwell", 0.4) + 0.15)
        end
        local Withdrawl = uJ:FindFirstChild("Withdrawl")
        local uJ_1 = Withdrawl and Withdrawl:IsA("BasePart")
        if uJ_1 then
            mU(Withdrawl)
            mC(0.2)
        end
    end
    for k, v in uI do
        if k > 4 then
            break
        end
        ni(v, 1.5)
        mC(0.2)
    end
    return true
end
local function fn733(aM, aN)
    return string.format('<font color="%s">%s</font>', aN, aM)
end
local function fn734(g2)
    local uB = not g2.hotPot or typeof(g2.hotPot.dishPickupCFrame) ~= "CFrame"
    if uB then
        return false
    end
    ni(g2.hotPot.dishPickupCFrame, 2)
    mC()
    return true
end
local function fn782()
    local u0 = nh("BuyUpgrades")
    local u1 = {}
    if not m0(u0) then
        for k, v in nf do
            table.insert(u1, v.id)
        end
        return u1
    end
    for k, v in pairs(u0) do
        if v then
            local u0_1 = m8[k]
            if u0_1 then
                table.insert(u1, u0_1)
            end
        end
    end
    return u1
end
local function fn793(Y, Z)
    local oX = {}
    if type(Z) == "table" then
        for k, v in Z do
            table.insert(oX, v)
        end
    end
    mV[Y] = oX
end
local function fn799(gY)
    local uz = not gY.hotPot or typeof(gY.hotPot.interactCFrame) ~= "CFrame"
    if uz then
        return false
    end
    ni(gY.hotPot.interactCFrame, 2)
    mC()
    return true
end
local function onRscripts()
    nR(nC, "Copied Rscripts profile to clipboard")
end
local function fn820(aP, aQ, aR)
    return string.format("<b>%s</b> %s %s", aP, ns("-", "#5a6070"), ns(aQ, aR))
end
local function fn841(bi)
    for k, v in pairs(bi) do
        if v then
            return true
        end
    end
    return false
end
local function fn845()
    return ClientPlayerUpgradeState.get()
end
local function fn857(fD)
    local tt = not fD
    local tu = {}
    if not tt then
        tt = not fD.ownedBackyardCellIds
    end
    if not tt then
        tt = not fD.backyardCellsById
    end
    if tt then
        return tu
    end
    for k in fD.ownedBackyardCellIds do
        local tt_1 = fD.backyardCellsById[k]
        if tt_1 then
            local cframe = tt_1.cframe
            local tx = tonumber(tt_1.level) or 0
            local ty = tonumber(tt_1.floor) or 1
            table.insert(tu, { cellId = k, cframe = cframe, level = tx, floor = ty })
        end
    end
    table.sort(tu, function(fI, fJ)
        if fI.level == fJ.level then
            return mL(fI.cellId, fJ.cellId)
        end
        return fI.level < fJ.level
    end)
    return tu
end
local function fn870(bC, bD)
    local p8 = nK()
    local p9 = not p8
    local qd = if p9 then 1 else 0
    local qb = 2191 * qd + 2907 * (1 - qd)
    local qc = 2003 * qd + 1360 * (1 - qd)
    if not ((qb * 2997 + qc * 124 + qb * qc) % 16777213 == 11203372) then
        p9 = typeof(bC) ~= "CFrame"
    end
    if p9 then
        return false
    end
    local p9_1 = bD
    if p9_1 == nil then
        p9_1 = 2
    end
    p8.AssemblyLinearVelocity = Vector3.zero
    p8.AssemblyAngularVelocity = Vector3.zero
    p8.CFrame = CFrame.new(bC.Position + Vector3.new(0, p9_1, 0))
    return true
end
local function fn871(gC)
    local uf = nX("SeedUpgradeMaxLevel", 100)
    local ug = nX("SeedUpgradeMaxCost", 1000000000000)
    local uh = nt()
    for k, v in mH(gC) do
        local ui = v.level < uf and mI("SeedUpgradeCrops", v.cropId)
        if ui then
            local ui_1 = cropCatalog[v.cropId]
            if ui_1 then
                local uj = tonumber(ui_1.maxLevel) or uf
                local uj_1
                local uk_1
                if not (v.level >= uj) then
                    uj_1, uk_1 = pcall(getCropUpgradeCost, ui_1, v.level)
                    if not (uj_1 and uk_1 == nil) then
                        local ui_3 = uj_1 and type(uk_1) == "number"
                        if not ui_3 then
                            return nx("upgrade", gC, v.cellId, v.cframe)
                        end
                        local ui_4 = mG("AutoSkipUnaffordable") and uk_1 > uh
                        if not ui_4 then
                            if not (uk_1 > ug) then
                                if not (uk_1 > uh) then
                                    return nx("upgrade", gC, v.cellId, v.cframe)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end
local function fn878()
    return nN.Character
end
local function fn899(bJ)
    local qe = not bJ or not bJ:IsA("BasePart")
    if qe then
        return false
    end
    return ni(bJ.CFrame, math.clamp(bJ.Size.Y * 0.15, 1.5, 3))
end
local function fn940()
    select("#", "Unloaded!")
end
local function fn943()
    local vs = nU()
    local vt = not vs
    local vA = if vt then 1 else 0
    local vy = 1559 * vA + 3470 * (1 - vA)
    local vz = 809 * vA + 2143 * (1 - vA)
    if not ((vy * 2765 + vz * 407 + vy * vz) % 16777213 == 5901129) then
        vt = not vs.plotId
    end
    if vt then
        return
    end
    mM(vs)
    local vt_1 = mG("AutoCollectMoney") and m_(vs)
    if vt_1 then
        mQ(vs)
        local vt_2 = (nU())
        local vA_1 = if vt_2 then 1 else 0
        local vy_1 = 3863 * vA_1 + 1467 * (1 - vA_1)
        local vz_1 = 2005 * vA_1 + 1119 * (1 - vA_1)
        if not ((vy_1 * 2928 + vz_1 * 3892 + vy_1 * vz_1) % 16777213 == 10082426) then
            vt_2 = vs
        end
        vs = vt_2
    end
    if mG("AutoCollectFood") then
        mJ(vs)
        local vt_3 = nU() or vs
        vs = vt_3
    end
    if mG("AutoCollectStorage") then
        nn(vs)
        local vt_4 = nU() or vs
        vs = vt_4
    end
    if mG("AutoPutSeedsInPot") then
        nI(vs)
        local vt_5 = nU() or vs
        vs = vt_5
    end
    if mG("AutoPutFoodForCustomers") then
        nq(vs)
        local vt_6 = nU() or vs
        m9(vt_6)
        local vt_7 = nU() or vt_6
        vs = vt_7
    end
    if mG("AutoCollectMoney") then
        mQ(vs)
        local vt_8 = nU() or vs
        vs = vt_8
    end
    if mG("AutoEquipSeed") then
        mR(vs)
        local vt_9 = nU() or vs
        vs = vt_9
    end
    if mG("AutoUpgradePlacedSeeds") then
        mB(vs)
        local vt_10 = nU() or vs
        vs = vt_10
    end
    if mG("AutoUpgradeCells") then
        nY(vs)
        local vt_11 = nU() or vs
        vs = vt_11
    end
    local vt_12 = false
    if mG("AutoBuySeed") then
        vt_12 = nP(vs)
    end
    local vu = ClientSeedRollState.getRoll()
    local vv = vu and vu.actionable and vu.plotId == vs.plotId and vu.offers and #vu.offers > 0
    local vv_1 = nj(vs)
    if vv_1 then
        mX(vs)
        local vv_2 = nU() or vs
        vs = vv_2
    else
        local vv_3 = not vv
        local vw = mG("AutoPullLever") and vv_3
        if vw and not vt_12 then
            mX(vs)
            local vt_13 = nU() or vs
            vs = vt_13
        end
    end
    if mG("AutoBuyBackyardCells") then
        nr(vs)
        local vt_14 = nU() or vs
        vs = vt_14
    end
    if mG("AutoBuyUpgrades") then
        nJ(vs)
    end
end
local function fn951(b8)
    local qx = nL(b8)
    if not qx then
        return nil
    end
    local RollerCase = qx:FindFirstChild("RollerCase")
    local qx_1 = RollerCase and RollerCase:FindFirstChild("Lever")
    local qy_1 = qx_1
    if qx_1 then
        qx_1 = qy_1:FindFirstChild("SeedRollPrompt")
    end
    return qx_1
end
local function fn953(ae)
    if ae and ae.stackKind then
        mP(ae.stackKind, ae.slots)
    end
end
local function fn986(fN)
    local tF = not fN
    local tG = {}
    if not tF then
        tF = not fN.plantedBackyardCellsById
    end
    if not tF then
        tF = not fN.backyardCellsById
    end
    if tF then
        return tG
    end
    for k, v in fN.plantedBackyardCellsById do
        local tF_1 = fN.backyardCellsById[k]
        if tF_1 and v then
            local insert = table.insert
            local cframe = tF_1.cframe
            local cropId = v.cropId
            local tK = tonumber(v.level) or 1
            insert(tG, { cellId = k, cframe = cframe, cropId = cropId, level = tK })
        end
    end
    table.sort(tG, function(fT, fU)
        if fT.level == fU.level then
            return mL(fT.cellId, fU.cellId)
        end
        return fT.level < fU.level
    end)
    return tG
end
local function fn988(gg)
    local t2_1, t2_2
    local t3_1
    local tZ = nX("CellUpgradeMaxLevel", 10)
    local tZ_1
    local t_ = nX("CellUpgradeMaxCost", 1000000000000)
    local t0 = nt()
    local t1 = tZ
    if type(getBackyardCellMaxLevel) == "function" then
        t2_1, t3_1 = pcall(getBackyardCellMaxLevel)
        local t4_1 = t2_1 and type(t3_1) == "number"
        if t4_1 then
            t1 = math.min(tZ, t3_1)
        end
    end
    for k, v in nl(gg) do
        if v.level < t1 then
            tZ_1, t2_2 = pcall(getBackyardCellUpgradeCost, v.level, v.floor)
            if not (tZ_1 and t2_2 == nil) then
                local t3_3 = tZ_1 and type(t2_2) == "number"
                if not t3_3 then
                    return nx("upgradeCell", gg, v.cellId, v.cframe)
                end
                local tZ_2 = mG("AutoSkipUnaffordable") and t2_2 > t0
                if not tZ_2 then
                    if not (t2_2 > t_) then
                        if not (t2_2 > t0) then
                            return nx("upgradeCell", gg, v.cellId, v.cframe)
                        end
                    end
                end
            end
        end
    end
    return false
end
mB = nil
mC = nil
getPlayerUpgradeLevel = nil
Library = nil
getPlayerUpgradeCost = nil
mG = nil
mH = nil
mI = nil
mJ = nil
mK = nil
mL = nil
mM = nil
mN = nil
mO = nil
mP = nil
mQ = nil
mR = nil
mS = nil
mT = nil
mU = nil
mV = nil
mW = nil
mX = nil
mZ = nil
m_ = nil
m0 = nil
playerUpgradeMessages = nil
Label = nil
PlayerUpgradeMessage = nil
m5 = nil
m6 = nil
m7 = nil
m8 = nil
m9 = nil
nd = nil
nf = nil
ng = nil
nh = nil
ni = nil
nj = nil
connection2 = nil
nl = nil
seedRollMessages = nil
nn = nil
no = nil
SeedRollMessage = nil
local mY, m3, backyardCellMessages, BackyardCellMessage
nq = nil
nr = nil
ns = nil
nt = nil
nu = nil
ClientPlayerUpgradeState = nil
nx = nil
clientPlayerMoney = nil
connection = nil
nA = nil
nB = nil
nC = nil
ClientSeedRollState = nil
nE = nil
nF = nil
nG = nil
ClientPlotState = nil
nI = nil
nJ = nil
nK = nil
nL = nil
nN = nil
getCropUpgradeCost = nil
nP = nil
nQ = nil
nR = nil
nS = nil
Workspace = nil
nU = nil
cropCatalog = nil
Options = nil
nX = nil
nY = nil
VirtualUser = nil
n_ = nil
n0 = nil
Toggles = nil
getBackyardCellMaxLevel = nil
n4 = nil
n5 = nil
getBackyardCellUpgradeCost = nil
local nw, getBackyardCellPurchaseCost, n1
nw = nil
getBackyardCellPurchaseCost = nil
n1 = nil
local SocialsGroup
VirtualUser, Workspace, nN, nG, nC, SeedRollMessage, seedRollMessages, BackyardCellMessage, backyardCellMessages, PlayerUpgradeMessage, playerUpgradeMessages, getPlayerUpgradeCost, getPlayerUpgradeLevel, getBackyardCellUpgradeCost, getBackyardCellMaxLevel, cropCatalog, getCropUpgradeCost, getBackyardCellPurchaseCost, ClientPlotState, ClientSeedRollState, clientPlayerMoney, ClientPlayerUpgradeState = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local v7_16 = game:GetService("Players")
local v7_9 = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
Workspace = game:GetService("Workspace")
nN = v7_16.LocalPlayer
local om = "Automate a Restaurant"
nG = "https://discord.gg/K7Qxnxkk46"
nC = "https://discord.gg/K7Qxnxkk46"
local v7_15 = v7_9:WaitForChild("TS")
local v7_7 = nN:WaitForChild("PlayerScripts"):WaitForChild("TS")
local v7_20 = require(v7_15.network:WaitForChild("seed-rolls"))
SeedRollMessage = v7_20.SeedRollMessage
seedRollMessages = v7_20.seedRollMessages
local v7_5 = require(v7_15.network:WaitForChild("backyard-cells"))
BackyardCellMessage = v7_5.BackyardCellMessage
backyardCellMessages = v7_5.backyardCellMessages
local v7_18 = require(v7_15.network:WaitForChild("player-upgrades"))
PlayerUpgradeMessage = v7_18.PlayerUpgradeMessage
playerUpgradeMessages = v7_18.playerUpgradeMessages
local v7_11 = require(v7_15.network:WaitForChild("world-stack"))
local v7_6 = v7_11.WorldStackMessage
local v7_17 = v7_11.worldStackMessages
local v7_2 = require(v7_15:WaitForChild("upgrades"))
getPlayerUpgradeCost = v7_2.getPlayerUpgradeCost
getPlayerUpgradeLevel = v7_2.getPlayerUpgradeLevel
getBackyardCellUpgradeCost = v7_2.getBackyardCellUpgradeCost
getBackyardCellMaxLevel = v7_2.getBackyardCellMaxLevel
local v7_1 = require(v7_15:WaitForChild("crops"))
cropCatalog = v7_1.cropCatalog
getCropUpgradeCost = v7_1.getCropUpgradeCost
getBackyardCellPurchaseCost = v7_1.getBackyardCellPurchaseCost
ClientPlotState = require(v7_7.plots:WaitForChild("client-plot-state")).ClientPlotState
ClientSeedRollState = require(v7_7.seeds:WaitForChild("client-seed-roll-state")).ClientSeedRollState
clientPlayerMoney = require(v7_7["player-data"]:WaitForChild("client-player-money")).clientPlayerMoney
ClientPlayerUpgradeState = require(v7_7.upgrades:WaitForChild("client-player-upgrades")).ClientPlayerUpgradeState
local v7_12 = {}
for k, v in cropCatalog do
    v7_16 = type(v) == "table" and v.hidden ~= true
    if v7_16 then
        table.insert(v7_12, k)
    end
end
table.sort(v7_12)
nf, m8 = nil, nil
nf = {
    { id = "storagePalletStorageSize", label = "Storage Size" },
    { id = "giantWokCookingSpeed", label = "Cooking Speed" },
    { id = "giantWokQuality", label = "Quality" },
    { id = "frontDeskAdvertising", label = "Advertising" },
    { id = "frontDeskSecondLine", label = "Second Line" },
    { id = "seedRollerLuckBoost", label = "Luck Boost" },
    { id = "seedRollerRollAmount", label = "Roll Amount" },
    { id = "backyardSprinklers", label = "Sprinklers" },
    { id = "backyardExpansion", label = "Expansion" },
    { id = "playerCarrySize", label = "Player Carry Size" },
    { id = "backyardSecondFloorSprinklers", label = "2F Sprinklers" }
}
v7_2 = {}
m8 = {}
for k, v in nf do
    table.insert(v7_2, v.label)
    m8[v.label] = v.id
end
mV, Library, Toggles, Options, mT, mO, mP, nR, nA, ns, ng, mG, nX, nw, nh, m0, mI, nS, nK, nu, ni, mU, mC, nU, nL, nt, nd, m5, mN, nQ, m6, mL, n1, nE, mY, nF, m7, m_, nB, m3, n_, mX, nP, nj, mR, nr, nl, mH, nx, nY, mB, mJ, nI, nq, m9, mQ, nn, mZ, nJ, mM, n4 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
v7_15 = { "Cheapest", "Rarest", "First" }
mV = { customerCash = {}, droneDropOff = {}, hotPotOutput = {} }
mP = fn793
v7_17.client:on(v7_6.Snapshot, fn953)
v7_17.client:on(v7_6.Deposited, fn321)
v7_17.client:on(v7_6.Collected, fn396)
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
v7_9 = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
nR = fns.fn103
nA = fn631
ns = fn733
ng = fn820
local v7_13 = "#7fd47f"
v7_7 = "#6ec1ff"
mT = "#e8a34d"
v7_20 = "#8b93a3"
mG = fn347
nX = fns.fn171
nw = fns.fn149
nh = fn340
m0 = fn841
mI = fn559
nS = fn878
nK = fns.fn117
nu = fns.fn144
ni = fn870
mU = fn899
mC = fns.fn41
nU = fn332
nL = fn715
nt = fn350
nd = fn845
m5 = function(b4)
    if not b4 then
        return false
    elseif fireproximityprompt then
        fireproximityprompt(b4)
        return true
    else
        pcall(function()
            b4:InputHoldBegin()
        end)
        local qv = b4.HoldDuration or 0
        task.wait(math.max(0.05, qv))
        pcall(function()
            b4:InputHoldEnd()
        end)
        return true
    end
end
mN = fn951
nQ = function()
    local ci
    ci = {}
    local function cj(ck)
        if not ck then
            return
        end
        for i, child in ck:GetChildren() do
            local qA = child:IsA("Tool") and child:GetAttribute("SeedPacket") == true
            if qA then
                local attr2 = child:GetAttribute("InventoryItemUid")
                local attr = child:GetAttribute("SeedCropId")
                local qC = type(attr2) == "string" and type(attr) == "string"
                if qC then
                    local insert = table.insert
                    local qD = child:GetAttribute("SeedLevel") or 1
                    insert(ci, { tool = child, inventoryItemUid = attr2, cropId = attr, level = qD })
                end
            end
        end
    end
    cj(nN:FindFirstChild("Backpack"))
    cj(nS())
    return ci
end
m6 = fn510
mL = fn269
n1 = fn639
nE = fn683
mY = fn691
nF = fns.fn235
m7 = fn630
m_ = fns.fn226
nB = fns.fn99
m3 = fn646
n_ = function(eh, ei)
    local sx
    sx = nil
    if not eh or not eh.offers then
        return nil
    end
    local sy_1 = {}
    for k, v in eh.offers do
        if m3(v, ei) then
            table.insert(sy_1, v)
        end
    end
    if #sy_1 == 0 then
        return nil
    end
    local sz = nw("SeedPreferMode") or "Cheapest"
    sx = sz
    if sx == "First" then
        return sy_1[1]
    end
    table.sort(sy_1, function(eq, er)
        if sx == "Rarest" then
            local sj_1 = tonumber(eq.chanceOneIn) or 0
            local sj_2 = tonumber(er.chanceOneIn) or 0
            if sj_1 == sj_2 then
                local sj_3 = tonumber(eq.cost) or 0
                local sm_1 = tonumber(er.cost) or 0
                return sj_3 < sm_1
            end
            return sj_1 > sj_2
        end
        local sj_4 = (tonumber(eq.cost))
        local sq = if sj_4 then 1 else 0
        local so = 1135 * sq + 877 * (1 - sq)
        local sp = 2117 * sq + 2210 * (1 - sq)
        if not ((so * 2535 + sp * 2329 + so * sp) % 16777213 == 10210513) then
            sj_4 = 0
        end
        local sk_2 = sj_4
        local sj_5 = (tonumber(er.cost))
        local st = if sj_5 then 1 else 0
        local sr = 3745 * st + 86 * (1 - st)
        local ss = 3925 * st + 767 * (1 - st)
        if not ((sr * 951 + ss * 2691 + sr * ss) % 16777213 == 12045582) then
            sj_5 = 0
        end
        local sl_2 = sj_5
        if sk_2 == sl_2 then
            local sj_6 = tonumber(eq.chanceOneIn) or 0
            local sm_2 = (tonumber(er.chanceOneIn))
            local sw = if sm_2 then 1 else 0
            local su = 2708 * sw + 2729 * (1 - sw)
            local sv = 1803 * sw + 4075 * (1 - sw)
            if not ((su * 1249 + sv * 2774 + su * sv) % 16777213 == 13266338) then
                sm_2 = 0
            end
            return sj_6 > sm_2
        end
        return sk_2 < sl_2
    end)
    return sy_1[1]
end
mX = fn451
nP = fns.fn104
nj = fn452
mR = fns.fn1
nr = function(fc)
    local th
    local ti
    th = nil
    ti = nil
    local tn_1
    local tm_1
    local tj = mY(fc)
    local tj_8
    if #tj == 0 then
        return false
    end
    local tk = n1(fc)
    local tl = nt()
    local tl_3
    if type(getBackyardCellPurchaseCost) == "function" then
        tm_1, tn_1 = pcall(getBackyardCellPurchaseCost, tk)
        local tk_1 = tm_1 and type(tn_1) == "number"
        if tk_1 then
            if tn_1 > tl then
                return false
            end
            ti = tj[1]
            th = nil
            local tj_1 = backyardCellMessages.client:on(BackyardCellMessage.BackyardCellInteractionResult, function(fr)
                if fr and fr.cellId == ti.cellId then
                    th = fr
                end
            end)
            if ti.cframe then
                ni(ti.cframe, 3)
                mC(0.1)
            end
            backyardCellMessages.server:emit(BackyardCellMessage.BackyardCellPurchaseRequested, { plotId = fc.plotId, cellId = ti.cellId })
            local tk_2 = os.clock()
            while true do
                local tl_1 = th == nil and os.clock() - tk_2 < 1.25
                if tl_3 then
                    task.wait(0.05)
                    continue
                end
                break
            end
            tj_1()
            if tj_8 then
                return false
            end
            return th == nil or th.ok == true
        end
        ti = tj[1]
        th = nil
        local tj_4 = backyardCellMessages.client:on(BackyardCellMessage.BackyardCellInteractionResult, function(fr)
            if fr and fr.cellId == ti.cellId then
                th = fr
            end
        end)
        if ti.cframe then
            ni(ti.cframe, 3)
            mC(0.1)
        end
        backyardCellMessages.server:emit(BackyardCellMessage.BackyardCellPurchaseRequested, { plotId = fc.plotId, cellId = ti.cellId })
        local tk_3 = os.clock()
        while true do
            local tl_2 = th == nil and os.clock() - tk_3 < 1.25
            if tl_3 then
                task.wait(0.05)
                continue
            end
            break
        end
        tj_4()
        if tj_8 then
            return false
        end
        return th == nil or th.ok == true
    end
    ti = tj[1]
    th = nil
    local tj_7 = backyardCellMessages.client:on(BackyardCellMessage.BackyardCellInteractionResult, function(fr)
        if fr and fr.cellId == ti.cellId then
            th = fr
        end
    end)
    if ti.cframe then
        ni(ti.cframe, 3)
        mC(0.1)
    end
    backyardCellMessages.server:emit(BackyardCellMessage.BackyardCellPurchaseRequested, { plotId = fc.plotId, cellId = ti.cellId })
    local tk_4 = os.clock()
    while true do
        tl_3 = th == nil and os.clock() - tk_4 < 1.25
        if tl_3 then
            task.wait(0.05)
            continue
        end
        break
    end
    tj_7()
    tj_8 = th and th.ok == false and th.reason == "not_enough_money"
    if tj_8 then
        return false
    end
    return th == nil or th.ok == true
end
nl = fn857
mH = fn986
nx = function(fY, fZ, f_, f0)
    local tU
    tU = nil
    tU = nil
    local tV = backyardCellMessages.client:on(BackyardCellMessage.BackyardCellInteractionResult, function(f4)
        if f4 and f4.cellId == f_ then
            tU = f4
        end
    end)
    if f0 then
        ni(f0, 3)
        mC(0.1)
    end
    local tW = BackyardCellMessage.BackyardCellRemoveRequested
    if fY == "upgradeCell" then
        tW = BackyardCellMessage.BackyardCellYieldUpgradeRequested
    elseif fY == "upgrade" then
        tW = BackyardCellMessage.BackyardCellUpgradeRequested
    elseif fY == "buy" then
        tW = BackyardCellMessage.BackyardCellPurchaseRequested
    end
    backyardCellMessages.server:emit(tW, { plotId = fZ.plotId, cellId = f_ })
    local tW_1 = os.clock()
    while true do
        local tX = tU == nil and os.clock() - tW_1 < 1.25
        if tX then
            task.wait(0.05)
            continue
        end
        break
    end
    tV()
    if tU and tU.ok == false then
        return false
    end
    return true
end
nY = fn988
if ((not nU or nu or not nU) and (not nU and not nu or (not nu or not nU)) or (not nA and nR or (not nA or false)) and (not nu and nu and (not nu))) and not ((not nU or nu or not nU) and (not nU and not nu or (not nu or not nU)) or (not nA and nR or (not nA or false)) and (not nu and nu and (not nu))) then
    nI = fn871
    nq = 1
    mO = fn640
    mB = fn799
    mJ = fn734
else
    mB = fn871
    mO = 1
    mJ = fn640
    nI = fn799
    nq = fn734
end
if (v7_15 or m6 or (false or v7_15) or m6 and not m6 and (v7_15 and v7_15)) and ((m6 or false or not nU and mG) and ((false or not nU) and (v7_15 and not m6))) and not ((v7_15 or m6 or (false or v7_15) or m6 and not m6 and (v7_15 and v7_15)) and ((m6 or false or not nU and mG) and ((false or not nU) and (v7_15 and not m6)))) then
    mQ = fn419
    m9 = fn719
else
    m9 = fn419
    mQ = fn719
end
nn = fn310
mZ = fn782
nJ = fn297
mM = fns.fn188
n4 = fn943
v7_18 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = nG, Copyable = true }, "|", om },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
v7_1 = {
    Info = v7_18:AddTab("Info", "info"),
    Main = v7_18:AddTab("Main", "utensils"),
    Settings = v7_18:AddTab("Settings", "settings")
}
v7_1.Farm = v7_1.Main:AddSubTab("Farm", "sprout")
v7_1.Restaurant = v7_1.Main:AddSubTab("Restaurant", "cooking-pot")
v7_1.Shop = v7_1.Main:AddSubTab("Shop", "shopping-cart")
v7_5 = fns.fn207
for k, v in { v7_1.Info, v7_1.Farm, v7_1.Restaurant, v7_1.Shop, v7_1.Settings } do
    v7_5(v)
end
no, v7_11, v7_17, Label, mW, v7_18 = nil, nil, nil, nil, nil, nil
v7_16 = 6
repeat
    v7_5 = (v7_16 * 1 + 2) % 3 + 1
    if v7_5 <= 2 then
        if v7_5 <= 1 then
            v7_5 = {
                "vuugrtjymg",
                "xkwrkfyie",
                "wadb",
                "yksiwxe",
                "uppheropytu",
                "tlfl",
                "alyn",
                "jslmvet",
                "qfgmppqtzoa"
            }
            local w4 = v7_16
            v7_6 = v7_5[w4 % 9 + 1]
            if v7_6:len() <= v7_6:gsub("(.)", "%1%1", w4 % 3 % 2 + 1):len() then
                mW = tostring(game.JobId)
            else
                v7_11 = tostring(game.JobId)
            end
            v7_16 = (v7_16 + 7) % 12
        else
            v7_5 = {
                "urkp",
                "kku",
                "tfhqtkepstw",
                "yxfvnnvlqgy",
                "lkharbwhud",
                "ixyqzvopbj",
                "edrrzpdykv",
                "gfa",
                "sky",
                "banvrwcld",
                "vcqxreldfzu"
            }
            local wR = v7_16
            v7_6 = v7_5[wR % 11 + 1]
            if v7_6:len() <= v7_6:reverse():rep(wR % 3 + 2):len() then
                v7_18 = #mW > 18
            else
                mW = #v7_18 > 18
            end
            v7_16 = (v7_16 + 4) % 12
        end
    else
        v7_5 = {
            "yvrekhv",
            "icpyghpesj",
            "wldffvvnwk",
            "lyqhadhqah",
            "cpxgkxruj",
            "gkfcdojxxowh",
            "ddjcpwzlc",
            "whz"
        }
        if v7_5[(v7_16 * 81 + 64) % 8 + 1] < v7_5[(v7_16 * 81 + 64) % 8 + 1] then
            nN = "Unknown"
            pcall(fn395)
            ns = v7_17.Info:AddLeftGroupbox("Account", "circle-user")
            ns:AddLabel(mT("User", v7_1.Name, v7_11), true)
            ns:AddLabel(mT("Status", "Keyless", v7_11), true)
            ns:AddLabel(mT("Executor", nN, v7_11), true)
            no = v7_17.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            no:AddLabel(v7_7(v7_13 .. " [" .. tostring(game.PlaceId) .. "]", ng), true)
            no:AddLabel(mT("Place ID", tostring(game.PlaceId), ng), true)
            om = no:AddLabel(mT("Session time", "0s", Label), true)
        else
            no = "Unknown"
            pcall(fn395)
            v7_11 = v7_1.Info:AddLeftGroupbox("Account", "circle-user")
            v7_11:AddLabel(ng("User", nN.Name, v7_13), true)
            v7_11:AddLabel(ng("Status", "Keyless", v7_13), true)
            v7_11:AddLabel(ng("Executor", no, v7_13), true)
            v7_17 = v7_1.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            v7_17:AddLabel(ns(om .. " [" .. tostring(game.PlaceId) .. "]", v7_7), true)
            v7_17:AddLabel(ng("Place ID", tostring(game.PlaceId), v7_7), true)
            Label = v7_17:AddLabel(ng("Session time", "0s", mT), true)
        end
        v7_16 = (v7_16 + 4) % 12
    end
until (v7_16 * 7 + 10) % 12 == 1
if v7_18 then
    v7_16 = 0
    repeat
        if (v7_16 * 2 + 6) * 13 % 3 == ((v7_16 * 2 + 6) * 13 + 2) % 3 then
            mW = string.sub(v7_18, 1, 18) .. "..."
        else
            v7_18 = string.sub(mW, 1, 18) .. "..."
        end
        v7_16 = (v7_16 + 5) % 8
    until (v7_16 * 3 + 5) % 8 == 4
end
v7_16 = v7_18
local oS = if v7_16 then 1 else 0
local oQ = 1118 * oS + 2159 * (1 - oS)
local oR = 3315 * oS + 69 * (1 - oS)
if not ((oQ * 1042 + oR * 1203 + oQ * oR) % 16777213 == 8859071) then
    v7_16 = mW
end
v7_11, n5, SocialsGroup, mS, mK, connection, connection2, n0 = nil, nil, nil, nil, nil, nil, nil, nil
if (not SocialsGroup or SocialsGroup or not connection2 and not mS) and (not connection2 and not mS) and not ((not SocialsGroup or SocialsGroup or not connection2 and not mS) and (not connection2 and not mS)) then
    v7_16 = n5
    ng:AddLabel(v7_20("Server", v7_16, v7_11), true)
    ng:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
    os.clock()
else
    v7_11 = v7_16
    v7_17:AddLabel(ng("Server", v7_11, v7_20), true)
    v7_17:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
    n5 = os.clock()
end
task.spawn(fns.worker)
local ScriptsGroup = v7_1.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(ns("Included in this hub", v7_20), true)
ScriptsGroup:AddLabel(ns(om, v7_7), true)
local FeaturesGroup = v7_1.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(ns("Seed Automation", v7_7), true)
FeaturesGroup:AddLabel(ns("Bed / Plot Farming", mT), true)
FeaturesGroup:AddLabel(ns("Restaurant Service", v7_7), true)
FeaturesGroup:AddLabel(ns("Upgrade Buying", mT), true)
SocialsGroup = v7_1.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = nA })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = v7_1.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = nA })
local FaqGroup = v7_1.Info:AddRightGroupbox("FAQ", "circle-help")
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
local SeedsGroup = v7_1.Farm:AddLeftGroupbox("Seeds", "leaf")
SeedsGroup:AddToggle("AutoPullLever", { Text = "Auto Pull Lever", Default = false })
SeedsGroup:AddToggle("AutoBuySeed", { Text = "Auto Buy Seed", Default = false })
SeedsGroup:AddToggle("AutoSkipUnaffordable", { Text = "Auto Skip Unaffordable", Default = true })
SeedsGroup:AddDropdown("SeedCrops", {
    Text = "Seed crops",
    Values = v7_12,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true
})
SeedsGroup:AddDropdown("SeedPreferMode", { Text = "Prefer", Values = v7_15, Default = "Cheapest" })
SeedsGroup:AddSlider("SeedMaxCost", {
    Text = "Max seed cost",
    Default = 1000000,
    Min = 1,
    Max = 1000000000000,
    Rounding = 0,
    Compact = true
})
SeedsGroup:AddSlider("SeedMinChance", { Text = "Min 1 in", Default = 1, Min = 1, Max = 1000000000000, Rounding = 0, Compact = true })
SeedsGroup:AddSlider("SeedMaxChance", {
    Text = "Max 1 in",
    Default = 1000000000000,
    Min = 1,
    Max = 1000000000000,
    Rounding = 0,
    Compact = true
})
v7_6 = v7_1.Farm:AddRightGroupbox("Beds", "sprout")
v7_6:AddToggle("AutoEquipSeed", { Text = "Auto Equip Seed on Beds", Default = false })
v7_6:AddDropdown("PlantCrops", {
    Text = "Plant crops",
    Values = v7_12,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true
})
v7_6:AddToggle("AutoBuyBackyardCells", { Text = "Auto Buy Backyard Cells", Default = false })
v7_6:AddToggle("AutoUpgradeCells", { Text = "Auto Upgrade Cells", Default = false })
v7_6:AddSlider("CellUpgradeMaxLevel", { Text = "Cell max level", Default = 10, Min = 1, Max = 10, Rounding = 0 })
v7_6:AddSlider("CellUpgradeMaxCost", {
    Text = "Cell max cost",
    Default = 1000000,
    Min = 1,
    Max = 1000000000000,
    Rounding = 0,
    Compact = true
})
v7_6:AddToggle("AutoUpgradePlacedSeeds", { Text = "Auto Upgrade Placed Seeds", Default = false })
v7_6:AddDropdown("SeedUpgradeCrops", {
    Text = "Upgrade crops",
    Values = v7_12,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true
})
v7_6:AddSlider("SeedUpgradeMaxLevel", { Text = "Seed max level", Default = 100, Min = 1, Max = 100, Rounding = 0 })
v7_6:AddSlider("SeedUpgradeMaxCost", {
    Text = "Seed max cost",
    Default = 1000000,
    Min = 1,
    Max = 1000000000000,
    Rounding = 0,
    Compact = true
})
v7_6:AddToggle("AutoCollectFood", { Text = "Auto Collect Food", Default = false })
v7_6:AddToggle("AutoCollectStorage", { Text = "Auto Collect Storage", Default = false })
v7_13 = v7_1.Restaurant:AddLeftGroupbox("Service", "hand-platter")
v7_13:AddToggle("AutoPutSeedsInPot", { Text = "Auto Put Seeds in Pot", Default = false })
v7_13:AddToggle("AutoPutFoodForCustomers", { Text = "Auto Put Food for Customers", Default = false })
v7_13:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
v7_13:AddSlider("CycleDelay", { Text = "Cycle delay", Default = 0.2, Min = 0.05, Max = 3, Rounding = 2, Suffix = "s" })
v7_13:AddSlider("ZoneDwell", { Text = "Zone dwell", Default = 0.4, Min = 0.1, Max = 3, Rounding = 2, Suffix = "s" })
v7_5 = v7_1.Shop:AddLeftGroupbox("Upgrades", "arrow-up")
v7_5:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
v7_5:AddDropdown("BuyUpgrades", {
    Text = "Upgrades",
    Values = v7_2,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true
})
v7_18 = v7_1.Settings:AddLeftGroupbox("Menu", "settings")
v7_18:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
v7_18:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
v7_18:AddButton("Unload", fns.onUnload)
Library:OnUnload(fn940)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(v7_1.Settings)
ThemeManager:LoadDefault()
v7_9:SetLibrary(Library)
v7_9:IgnoreThemeSettings()
v7_9:SetIgnoreIndexes({ "MenuKeybind" })
v7_9:SetFolder("TempoHub/AutomateARestaurant")
v7_9:BuildConfigSection(v7_1.Settings)
v7_9:LoadAutoloadConfig()
mS = tick()
mK = tick()
pcall(function()
    for i, v in ipairs(getconnections(nN.Idled)) do
        local vP = v
        pcall(function()
            vP:Disable()
        end)
    end
end)
n0 = fn298
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
Library:OnUnload(fns.fn187)
task.spawn(worker2)
task.spawn(fns.worker3)
Library:Notify(om .. " loaded")
end)(...)

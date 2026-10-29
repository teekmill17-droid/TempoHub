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
getgenv().TempoHoodSubtitle = "IDLE MAFIA GAME"
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
local H9_2, H9_3, H9_26, H9_29, H9_34, H9_37, H9_47, H9_57, H9_60, H9_66
H9_2 = nil
H9_3 = nil
local AllocateSkillPoint
local vM
local uM
local ua
local vz
local uz
local uY
local tY
local vm
local vL
local u9
local t9
local vy
local uy
local tX
local vl
local ul
local vK
local uK
local Options
local list
local ux
local uW
local tW
local vk
local vJ
local uJ
local family
local Config
local vw
local uw
local vV
local uV
local tV
local vj
local uj
local vI
local u6
local t6
local vv
local uv
local vU
local uU
local State
local vi
local ui
local vH
local uH
local Deposit
local t5
local vu
local uu
local vT
local tT
local BuyShopItem
local uh
local vG
local u4
local t4
local ut
local Attack
local tS
local vF
local uF
local t3
local vs
local us
local vR
local Library
local tR
local Toggles
local uf
local uE
local u2
local t2
local ur
local vQ
local uQ
local tQ
local ve
local ue
local vD
local ClaimTrophy
local GameData
local vq
local uq
local vP
local ShopItemListDropdown
local DoJob
local vd
local ud
local vC
local uC
local u0
local t0
local vp
local up
local vO
local uO
local tO
local vc
local uc
local vB
local uB
local u_
local t_
local CoreGui
local uo
local uN
local vb
local ub
local CollectOperation
local uA
function fns.fn1()
    local yh = vv()
    local yi = not yh
    local ys = if yi then 1 else 0
    local yq = 1498 * ys + 3405 * (1 - ys)
    local yr = 498 * ys + 2410 * (1 - ys)
    if not ((yq * 74 + yr * 714 + yq * yr) % 16777213 == 1212428) then
        yi = not yh.pools
    end
    if yi then
        return false
    end
    local yi_1 = yh.pools.energy or 0
    if yi_1 < 1 then
        return false
    end
    local yi_2 = uC("JobList")
    if not t2(yi_2) then
        return false
    end
    local yk = -1
    local yl
    for i, v in ipairs(GameData.JOBS) do
        local ym = yi_2[v.name]
        if ym then
            ym = yh.level >= (v.level or 1)
        end
        if ym then
            local ym_2 = (yh.jobs or {})[v.id]
            local ym_3 = ym_2 and ym_2.masteryTier or 0
            local yn_4 = vi(v, ym_3)
            if yn_4 <= yi_1 then
                local yo_2 = (v.cash or 0) / yn_4
                if yo_2 > yk then
                    yk = yo_2
                    yl = v
                end
            end
        end
    end
    if not yl then
        return false
    end
    local yh_1 = vk(DoJob, yl.id)
    return yh_1 ~= nil and yh_1.ok == true
end
function fns.fn12(ci, cj)
    local xE = cj
    local xM = if xE then 1 else 0
    local xK = 2380 * xM + 3300 * (1 - xM)
    local xL = 4080 * xM + 487 * (1 - xM)
    if not ((xK * 2531 + xL * 2533 + xK * xL) % 16777213 == 9291607) then
        xE = 0
    end
    local xF = xE
    local max = math.max
    local energy = ci.energy
    local xF_1 = xF >= 2 and 0.05
    local xM_1 = if xF_1 then 1 else 0
    local xK_1 = 692 * xM_1 + 2653 * (1 - xM_1)
    local xL_1 = 2969 * xM_1 + 4070 * (1 - xM_1)
    if not ((xK_1 * 579 + xL_1 * 2905 + xK_1 * xL_1) % 16777213 == 11080161) then
        xF_1 = 0
    end
    return max(1, math.floor(energy * (1 - xF_1) + 0.5))
end
function fns.fn18()
    local DX = u4("SkillPointStat", vj[1])
    local DY = vd[DX]
    local D1 = if DY then 1 else 0
    local D_ = 918 * D1 + 474 * (1 - D1)
    local D0 = 1725 * D1 + 19 * (1 - D1)
    if not ((D_ * 65 + D0 * 3241 + D_ * D0) % 16777213 == 7233945) then
        DY = "energy"
    end
    return DY
end
function fns.fn24(j4)
    local DiscordGroup = j4:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = vR })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = vR })
end
function fns.fn30()
    t0(up, "Copied Discord invite to clipboard")
end
function fns.fn36(cD)
    local yb_1 = (cD.playtime or {}).todaySeconds or 0
    return yb_1 + State.sinceSync()
end
function fns.fn44(eN, eO)
    if eN.level < (eO.level or 1) then
        return false
    end
    local Ak_1 = eO.order
    local Ar = if Ak_1 then 1 else 0
    local Ap = 2192 * Ar + 3211 * (1 - Ar)
    local Ap_2
    local Aq = 2628 * Ar + 2663 * (1 - Ar)
    local Aq_2
    if not ((Ap * 3489 + Aq * 617 + Ap * Aq) % 16777213 == 15029940) then
        Ak_1 = 1
    end
    if Ak_1 > 1 then
        local Am_1 = GameData.BOSSES[(eO.order or 1) - 1]
        local Ak_3 = Am_1
        if Ak_3 then
            Ak_3 = (eN.bosses or {})[Am_1.id]
        end
        local Al_3 = Ak_3
        local Ak_4 = not Al_3
        if not Ak_4 then
            Ak_4 = (Al_3.kills or 0) < 1
        end
        if Ak_4 then
            return false
        end
        local Ak_5 = {}
        local Al_4 = eN.bosses
        if not ((Ap_2 * 1978 + Aq_2 * 183 + Ap_2 * Aq_2) % 16777213 == 8450392) then
            Al_4 = Ak_5
        end
        local Ak_6 = Al_4[eO.id]
        local Al_5 = Ak_6
        if Al_5 then
            local Am_3 = tX(eN)
            Al_5 = Am_3 < (Ak_6.respawnAt or 0)
        end
        if Al_5 then
            return false
        end
        return true
    end
    local Ak_7 = {}
    local Al_6 = eN.bosses
    local Ar_2 = if Al_6 then 1 else 0
    Ap_2 = 3230 * Ar_2 + 3207 * (1 - Ar_2)
    Aq_2 = 604 * Ar_2 + 2746 * (1 - Ar_2)
    if not ((Ap_2 * 1978 + Aq_2 * 183 + Ap_2 * Aq_2) % 16777213 == 8450392) then
        Al_6 = Ak_7
    end
    local Ak_8 = Al_6[eO.id]
    local Al_7 = Ak_8
    if Al_7 then
        local Am_4 = tX(eN)
        Al_7 = Am_4 < (Ak_8.respawnAt or 0)
    end
    if Al_7 then
        return false
    end
    return true
end
function fns.worker()
    while Library and not Library.Unloaded do
        uK()
        task.wait(1)
    end
end
function fns.fn115()
    local Ad = false
    if vb() then
        Ad = true
    end
    local Ae = vk(uH)
    if Ae and Ae.ok then
        Ad = true
    end
    if uO() then
        Ad = true
    end
    return Ad
end
function fns.fn228(da)
    local yz = not da
    if yz ~= false then
        yz = list
    end
    if yz then
        yz = os.clock() - t3 < 8
    end
    if yz then
        return list
    end
    local yz_1 = vk(vO)
    local yA = yz_1 and yz_1.ok and type(yz_1.list) == "table"
    if yA then
        list = yz_1.list
        t3 = os.clock()
        return list
    end
    return list
end
function fns.fn289()
    local EL = Options.ShopSearch.Value or ""
    local EM = tostring(EL):lower():gsub("^%s*(.-)%s*$", "%1")
    if EM == "" then
        ShopItemListDropdown:SetValues(vP)
    else
        local EL_1 = {}
        for i, v in ipairs(vP) do
            if v:lower():find(EM, 1, true) then
                EL_1[#EL_1 + 1] = v
            end
        end
        ShopItemListDropdown:SetValues(EL_1)
    end
end
function fns.fn314()
    return CoreGui
end
function fns.fn335()
    if os.clock() - vq < 1.25 then
        return false
    end
    local DT = vv()
    if not DT or not DT.pools then
        return false
    elseif DT.level < 12 then
        return false
    else
        local DU_1 = uh(false)
        if not DU_1 or DU_1.ok == false then
            return false
        elseif vl(DU_1, DT) then
            vq = os.clock()
            return true
        else
            local DV_1 = uh(false) or DU_1
            if tS(DV_1, DT) then
                vq = os.clock()
                return true
            end
            return false
        end
    end
end
function fns.fn342(cb, cc)
    if type(cb) ~= "string" then
        return cc
    end
    local xy = cb:gsub("[,$%s_]", "")
    local xz = tonumber(xy)
    if xz == nil then
        return cc
    end
    return math.max(0, math.floor(xz))
end
function fns.fn390()
    local zt = vv()
    if not zt then
        return false
    end
    local zu = zt.playtime and zt.playtime.laddersClaimed
    local zv = {}
    local zw = zu
    local zB = if zw then 1 else 0
    local zz = 3369 * zB + 330 * (1 - zB)
    local zA = 315 * zB + 1648 * (1 - zB)
    if not ((zz * 1494 + zA * 3935 + zz * zA) % 16777213 == 7334046) then
        zw = zv
    end
    local zu_1 = zw
    local zv_1 = vI(zt)
    local zt_1 = false
    for i, v in ipairs(Config.LADDER) do
        local zw_1 = v.seconds or 0
        local zx = zv_1 >= zw_1 and not zu_1[tostring(i)]
        if zx then
            local zw_2 = vk(uN, i)
            if zw_2 and zw_2.ok then
                zt_1 = true
                task.wait(0.15)
            end
        end
    end
    return zt_1
end
function fns.fn438(b0)
    local xk = u4(b0, {})
    if typeof(xk) ~= "table" then
        return {}
    end
    local xl = {}
    for k, v in xk do
        if v == true then
            xl[k] = true
        else
            local xk_1 = typeof(k) == "number" and typeof(v) == "string"
            if xk_1 then
                xl[v] = true
            end
        end
    end
    return xl
end
function fns.fn442(eg, eh)
    local zI = GameData.CITY_SETS[eh]
    if type(zI) ~= "table" then
        return false
    end
    local zJ = 0
    local zK = 0
    for i, v in ipairs(zI) do
        local zI_1 = GameData.ITEMS_BY_ID[v]
        local zL = zI_1
        if zL then
            zL = (zI_1.rarity or 0) < 7
        end
        if zL then
            zK += 1
            if (eg.inventory[v] or 0) + ((eg.inventoryBound or {})[v] or 0) > 0 then
                zJ += 1
            end
        end
    end
    return zK > 0 and zJ >= zK
end
function fns.fn502()
    local A5 = u4("CrewMinRarity", tW[1])
    local A6 = tR[A5]
    local Ba = if A6 then 1 else 0
    local A8 = 3933 * Ba + 3605 * (1 - Ba)
    local A9 = 3064 * Ba + 441 * (1 - Ba)
    if not ((A8 * 3281 + A9 * 2840 + A8 * A9) % 16777213 == 102219) then
        A6 = 1
    end
    return A6
end
function fns.worker2()
    while not Library.Unloaded do
        local GU = false
        local GV = vy("AutoClaimOperation") and ub()
        if GV then
            GU = true
        end
        local GV_1 = vy("AutoClaimRewards") and u6()
        if GV_1 then
            GU = true
        end
        local GV_2 = vy("AutoJob") and uE()
        if GV_2 then
            GU = true
        end
        local GV_3 = vy("AutoFight") and t9()
        if GV_3 then
            GU = true
        end
        local GV_4 = vy("AutoBoss") and vL()
        if GV_4 then
            GU = true
        end
        local GV_5 = vy("AutoHeist") and uW()
        if GV_5 then
            GU = true
        end
        local GV_6 = vy("AutoAllocatePoints") and vU()
        if GV_6 then
            GU = true
        end
        if vy("AutoOperation") then
            if ub() then
                GU = true
            end
            if u2() then
                GU = true
            end
        end
        local GV_7 = vy("AutoBuyProperties") and ut()
        if GV_7 then
            GU = true
        end
        local GV_8 = vy("AutoBuyShop") and tO()
        if GV_8 then
            GU = true
        end
        local GV_9 = vy("AutoOpenCrates") and ur()
        if GV_9 then
            GU = true
        end
        local GV_10 = vy("AutoEquipCrew") and uu()
        if GV_10 then
            GU = true
        end
        local GV_11 = vy("AutoRollCrew") and uz()
        if GV_11 then
            GU = true
        end
        local GV_12 = vy("AutoBankDeposit") and vz()
        if GV_12 then
            GU = true
        end
        local GV_13 = vy("AutoFamilyStamina") and vs()
        if GV_13 then
            GU = true
        end
        local wait = task.wait
        local GU_1 = GU and 0.35 or 0.75
        wait(GU_1)
    end
end
function fns.fn546()
    local zX = vv()
    if not zX then
        return false
    end
    local zY = false
    local z0 = zX.derived and zX.derived.trophyReady or {}
    local zZ_1 = {}
    if type(z0) == "table" then
        for k, v in z0 do
            local z__2 = nil
            local z0_1 = type(k) == "number" and type(v) == "string"
            if z0_1 then
                z__2 = v
            else
                local z0_2 = v == true
                local z1 = type(k) == "string" and z0_2
                if z1 then
                    z__2 = k
                elseif type(v) == "string" then
                    z__2 = v
                end
            end
            if z__2 and not zZ_1[z__2] then
                zZ_1[z__2] = true
                local z0_4 = vk(ClaimTrophy, z__2)
                if z0_4 and z0_4.ok then
                    zY = true
                    task.wait(0.15)
                end
            end
        end
    end
    local zZ_2 = vv() or zX
    local zX_1 = zZ_2
    for k in GameData.CITY_SETS do
        if tV(zX_1, k) then
            local zZ_3 = vk(uw, k)
            if zZ_3 and zZ_3.ok then
                zY = true
                task.wait(0.15)
                local zZ_4 = vv() or zX_1
                zX_1 = zZ_4
            end
        end
    end
    return zY
end
function fns.fn557(h5)
    if type(h5.net) == "number" then
        return h5.net
    end
    local C9 = Config.HEIST.sabotageHelpPenalty or 2
    local C9_1 = h5.helpCount or 0
    local Db = h5.saboCount
    local Df = if Db then 1 else 0
    local Dd = 3368 * Df + 2360 * (1 - Df)
    local De = 3673 * Df + 2998 * (1 - Df)
    if not ((Dd * 588 + De * 1995 + Dd * De) % 16777213 == 4901470) then
        Db = 0
    end
    return C9_1 - Db * C9
end
function fns.fn606(bW, bX)
    local xi = Options[bW]
    if xi == nil then
        return bX
    end
    return xi.Value
end
function fns.fn662(bF, bG, bH)
    return string.format("<b>%s</b> %s %s", bF, uA("-", "#5a6070"), uA(bG, bH))
end
function fns.fn671(cm)
    local xN = 1
    if cm.level >= Config.OPERATION_SLOTS.level15 then
        xN += 1
    end
    if cm.level >= Config.OPERATION_SLOTS.level30 then
        xN += 1
    end
    local xO = {}
    local xP = cm.derived
    local xT = if xP then 1 else 0
    local xR = 3139 * xT + 2705 * (1 - xT)
    local xS = 3751 * xT + 1273 * (1 - xT)
    if not ((xR * 2655 + xS * 4056 + xR * xS) % 16777213 == 1768064) then
        xP = xO
    end
    if xP.fourthSlot then
        xN += 1
    end
    return xN
end
function fns.fn685(g9, ha)
    if not vy("WebhookEnabled") then
        return false
    end
    local Cg = ha and u_()
    local Ch = Cg or nil
    return uF({ username = "Tempo Hub", content = Ch, embeds = { g9 } })
end
function fns.fn734()
    local yC = vv()
    if not yC or not yC.pools then
        return false
    end
    local yD_1 = yC.pools.stamina or 0
    local yD_2 = yC.pools.health or 0
    if yD_1 < (Config.COMBAT.staminaCost or 1) then
        return false
    end
    if yD_2 <= (Config.COMBAT.hospitalHealth or 20) then
        return false
    end
    local yC_2 = uQ(false)
    if type(yC_2) ~= "table" then
        return false
    end
    local yD_5 = os.clock()
    local yF = math.huge
    local yG
    for i, v in ipairs(yC_2) do
        local userId = v.userId
        local yH = userId
        if yH then
            yH = (t_[userId] or 0) <= yD_5
        end
        if yH then
            if (v.stamina or Config.COMBAT.staminaCost or 1) <= yD_1 then
                local yJ = (v.level or 1) * 1000 + (v.respect or 0)
                if yJ < yF then
                    yF = yJ
                    yG = v
                end
            end
        end
    end
    if not yG then
        return false
    end
    local yC_7 = vk(Attack, yG.userId)
    local userId = yG.userId
    local yF_1 = Config.COMBAT.targetCooldown or 30
    t_[userId] = yD_5 + yF_1
    if yC_7 and yC_7.ok then
        t3 = 0
        return true
    end
    return false
end
function fns.fn824()
    local C2 = if os.clock() - vT < 2 then 1 else 0
    if C2 == 1 then
        return false
    end
    local CV = vv()
    if not CV then
        return false
    end
    local CW = tQ(u4("BankDepositThreshold", "1000000"), 1000000)
    local CX = tQ(u4("BankKeepCash", "0"), 0)
    local CZ = CV.cash
    local C2_1 = if CZ then 1 else 0
    local C0 = 3817 * C2_1 + 2892 * (1 - C2_1)
    local C1 = 1775 * C2_1 + 2371 * (1 - C2_1)
    if not ((C0 * 3652 + C1 * 1483 + C0 * C1) % 16777213 == 6569971) then
        CZ = 0
    end
    local CV_1 = math.floor(CZ)
    if CV_1 < CW then
        return false
    end
    local CW_1 = CV_1 - CX
    if CW_1 < 1 then
        return false
    end
    vT = os.clock()
    local CV_2 = vk(Deposit, CW_1)
    return CV_2 ~= nil and CV_2.ok == true
end
function fns.fn851()
    local AI = vv()
    if not AI then
        return false
    end
    local AJ = AI.propertyCap or Config.PROPERTY.maxOwned
    if uf(AI) >= AJ then
        return false
    end
    local AJ_1 = uC("PropertyList")
    if not t2(AJ_1) then
        return false
    end
    local AK_1 = AI.cash or 0
    local AL = math.huge
    local AM
    for i, v in ipairs(GameData.PROPERTIES) do
        local AK_2 = AJ_1[v.name]
        if AK_2 then
            AK_2 = AI.level >= (v.level or 1)
        end
        if AK_2 then
            local AK_5 = ((AI.properties or {})[v.id] or {}).owned or 0
            if AK_5 < (Config.PROPERTY.maxOwned or 10) then
                local AK_7 = ux(v, AK_5)
                if AK_7 <= AK_1 and AK_7 < AL then
                    AL = AK_7
                    AM = v
                end
            end
        end
    end
    if not AM then
        return false
    end
    local AI_1 = vk(vp, AM.id)
    return AI_1 ~= nil and AI_1.ok == true
end
function fns.fn870()
    local Ec = family and os.clock() - u0 < 5
    if Ec then
        return family
    end
    local Ec_1 = vk(ui, "info")
    if Ec_1 and Ec_1.ok and Ec_1.family then
        family = Ec_1.family
        u0 = os.clock()
        return family
    end
    return nil
end
function fns.fn871()
    local y7 = vv()
    if not y7 or not y7.operations then
        return false
    end
    local y8_1 = uV(y7)
    local za = y7.operations.active or {}
    local y9_1 = 0
    local zh = 1
    while zh <= y8_1 do
        if za[zh] then
            y9_1 += 1
        end
        zh += 1
    end
    if y9_1 >= y8_1 then
        return false
    end
    local y8_2 = uC("OperationList")
    if not t2(y8_2) then
        return false
    end
    local y9_2 = y7.cash or 0
    local za_1 = -1
    local y9_3 = nil
    for i, v in ipairs(GameData.OPERATIONS) do
        local zc_1 = y8_2[v.name] and y7.level >= (v.level or 1)
        if zc_1 then
            zc_1 = (v.cost or 0) <= y9_2
        end
        if zc_1 then
            zc_1 = (v.cash or 0) > za_1
        end
        if zc_1 then
            za_1 = v.cash or 0
            y9_3 = v
        end
    end
    if not y9_3 then
        return false
    end
    local y7_1 = vk(vF, y9_3.id)
    return y7_1 ~= nil and y7_1.ok == true
end
function fns.fn906(b8)
    for k in b8 do
        return true
    end
    return false
end
function fns.fn917()
    if os.clock() - tY < 3 then
        return false
    end
    tY = os.clock()
    local A_ = vk(H9_2)
    return A_ ~= nil and A_.ok ~= false
end
function fns.fn934()
    local Bb = u4("CrewKeepRarity", tW[#tW])
    return tR[Bb] or #tW
end
function fns.fn975(jj, jk)
    local Ei = jj and jj[jk]
    if typeof(Ei) == "number" then
        return Ei
    elseif typeof(Ei) == "table" then
        return Ei.level or 0
    else
        return 0
    end
end
function fns.fn983()
    local Bs_1
    local Br_1
    local Bq_1
    local BH = if os.clock() - vQ < 1.25 then 1 else 0
    if BH == 1 then
        return false
    end
    local Bo = vv()
    if not Bo then
        return false
    end
    local Bp = uC("ShopItemList")
    if not t2(Bp) then
        return false
    end
    Br_1, Bq_1, Bs_1 = H9_3.shopStock(GameData, workspace:GetServerTimeNow())
    if type(Br_1) ~= "table" then
        return false
    end
    local shopRotation = Bo.shopRotation
    local Bt = shopRotation
    local Bu = {}
    if Bt then
        Bt = shopRotation.slot == Bs_1
    end
    if Bt then
        Bt = type(shopRotation.bought) == "table"
    end
    if Bt then
        Bu = shopRotation.bought
    end
    local Bq_3 = Bo.level or 1
    local Bq_4 = Bo.cash or 0
    local Bq_5 = t6(Bo)
    local Bo_1 = ul()
    local Bw = tQ(u4("ShopSpendLimitCash", ""), math.huge)
    local Bx = tQ(u4("ShopSpendLimitGold", ""), math.huge)
    local By = math.huge
    local Bz = math.huge
    local BA
    local BB
    for k in Bp do
        local Bp_1 = vK[k]
        if Bp_1 and Br_1[Bp_1.item] and Bu[Bp_1.item] ~= true then
            if Bp_1.level == nil or Bq_3 >= Bp_1.level then
                if Bp_1.goldPrice then
                    if Bp_1.goldPrice <= Bq_5 and Bp_1.goldPrice <= Bx and Bp_1.goldPrice < Bz then
                        BA = Bp_1
                        Bz = Bp_1.goldPrice
                    end
                else
                    local BC_3 = H9_3.discountedPrice(H9_3.shopPrice(Bp_1, Bs_1), Bo_1)
                    if BC_3 <= Bq_4 and BC_3 <= Bw and BC_3 < By then
                        BB = Bp_1
                        By = BC_3
                    end
                end
            end
        end
    end
    local BB_1 = BB or BA
    if not BB_1 then
        return false
    end
    vQ = os.clock()
    local Bo_3 = vk(BuyShopItem, BB_1.item)
    return Bo_3 ~= nil and Bo_3.ok == true
end
function fns.fn1004(fS)
    local Bi = fS.inventory or {}
    local Bi_1 = {}
    local Bj = fS.inventoryBound
    local Bn = if Bj then 1 else 0
    local Bl = 1164 * Bn + 3928 * (1 - Bn)
    local Bm = 261 * Bn + 469 * (1 - Bn)
    if not ((Bl * 2049 + Bm * 3789 + Bl * Bm) % 16777213 == 3677769) then
        Bj = Bi_1
    end
    return (Bi.gold_bar or 0) + (Bj.gold_bar or 0)
end
function fns.fn1045()
    return u4("CrewRollMode", uJ[1])
end
function fns.fn1047(h_)
    local C3 = not h_
    if C3 ~= false then
        C3 = vC
    end
    if C3 then
        C3 = os.clock() - vw < 5
    end
    if C3 then
        return vC
    end
    local C3_1 = vk(uq, "board")
    if C3_1 and C3_1.ok then
        vC = C3_1
        vw = os.clock()
        return vC
    end
    if C3_1 and C3_1.msg then
        vC = C3_1
        vw = os.clock()
    end
    return vC
end
function fns.fn1055()
    local Av = vv()
    if not Av or not Av.pools then
        return false
    end
    if (Av.pools.stamina or 0) < (Config.BOSS.staminaCost or 1) then
        return false
    end
    local Aw_2 = Av.pools.health
    local AB = if Aw_2 then 1 else 0
    local Az = 262 * AB + 1320 * (1 - AB)
    local AA = 3622 * AB + 718 * (1 - AB)
    if not ((Az * 1619 + AA * 921 + Az * AA) % 16777213 == 4709004) then
        Aw_2 = 0
    end
    if Aw_2 <= (Config.COMBAT.hospitalHealth or 20) then
        return false
    end
    for i, v in ipairs(GameData.BOSSES) do
        if uo(Av, v) then
            local Aw_3 = vk(vu, "attack", v.id)
            return Aw_3 ~= nil and Aw_3.ok == true
        end
    end
    return false
end
function fns.fn1070(bC, bD)
    return string.format('<font color="%s">%s</font>', bD, bC)
end
function fns.fn1077()
    local BY_1
    local BX_1
    if os.clock() - vM < 1.25 then
        return false
    end
    local BV = vv()
    if not BV then
        return false
    end
    local function BW(gv, gw)
        if type(gv) ~= "table" then
            return nil
        end
        for k, v in gv do
            if (v or 0) > 0 then
                local BM_1 = GameData.ITEMS_BY_ID[k]
                if BM_1 and BM_1.kind == "crate" then
                    return k, gw
                end
            end
        end
        return nil
    end
    BY_1, BX_1 = BW(BV.inventory, false)
    if not BY_1 then
        BY_1, BX_1 = BW(BV.inventoryBound, true)
    end
    if not BY_1 then
        return false
    end
    vM = os.clock()
    local BV_1 = vk(vc, BY_1, BX_1)
    BW = BV_1 ~= nil and BV_1.ok == true
    return BW
end
function fns.fn1099(iu, iv)
    local Dx = iu.favorsLeft or 0
    local Dz = iu.helpFavorCost or Config.HEIST.favorCostHelp
    local DJ = if Dz then 1 else 0
    local DH = 2315 * DJ + 1396 * (1 - DJ)
    local DI = 1902 * DJ + 1318 * (1 - DJ)
    if not ((DH * 1088 + DI * 2991 + DH * DI) % 16777213 == 12610732) then
        Dz = 1
    end
    local Dx_2 = Dz
    local Dz_1 = iu.helpEnergyCost or 0
    local DB = iu.helpMaxPerHeist or Config.HEIST.maxHelpsPerHeist or 5
    local DC = iv.pools and iv.pools.energy
    local DM = if DC then 1 else 0
    local DK = 3220 * DM + 658 * (1 - DM)
    local DL = 3831 * DM + 2341 * (1 - DM)
    if not ((DK * 2449 + DL * 2157 + DK * DL) % 16777213 == 11707854) then
        DC = 0
    end
    if Dx < Dx_2 or DC < Dz_1 then
        return false
    end
    local rows = iu.rows
    if type(rows) ~= "table" then
        return false
    end
    local Dy_1 = nil
    local DA_1 = -math.huge
    for i, v in ipairs(rows) do
        local Dx_4 = v.helpsUsed
        if not Dx_4 then
            Dx_4 = v.helped and 1 or 0
        end
        local DB_4 = Dx_4
        local Dx_5 = v.sabosUsed
        if not Dx_5 then
            Dx_5 = v.sabotaged and 1 or 0
        end
        if Dx_5 < 1 and DB_4 < DB then
            local Dx_7 = GameData.HEISTS_BY_ID[v.heistId]
            local DC_5 = Dx_7
            if DC_5 then
                DC_5 = Dx_7.helpGoal or 1
            end
            local DD_3 = DC_5 or 1
            local DD_4 = vG(v)
            if DD_4 < DD_3 then
                local DE_1 = Dx_7 and (Dx_7.helpCash or 0) or 0
                if v.friend then
                    DE_1 += 1000000000000
                end
                if v.famRel == "family" then
                    DE_1 += 100000000000
                elseif v.famRel == "war" then
                    DE_1 -= 10000000000
                end
                DE_1 += (DD_3 - DD_4) * 1000
                DE_1 -= DB_4 * 10
                if DE_1 > DA_1 then
                    DA_1 = DE_1
                    Dy_1 = v
                end
            end
        end
    end
    if not Dy_1 then
        return false
    end
    local Dx_9 = vk(uq, "help", Dy_1.id)
    vw = 0
    return Dx_9 ~= nil and Dx_9.ok == true
end
function fns.fn1131()
    if vy("WebhookPingEveryone") then
        return "@everyone"
    end
    local Ca = Options.WebhookPingId
    if Ca then
        local Cb_1 = Options.WebhookPingId.Value
        local Cf = if Cb_1 then 1 else 0
        local Cd = 1289 * Cf + 3498 * (1 - Cf)
        local Ce = 3220 * Cf + 812 * (1 - Cf)
        if not ((Cd * 3135 + Ce * 289 + Cd * Ce) % 16777213 == 9122175) then
            Cb_1 = ""
        end
        Ca = tostring(Cb_1):gsub("%D", "")
    end
    local Cb_2 = Ca or ""
    if Cb_2 ~= "" then
        return "<@" .. Cb_2 .. ">"
    end
    return nil
end
function fns.fn1168()
    local WebhookGroup = vJ.Webhook:AddLeftGroupbox("Webhook", "webhook")
    WebhookGroup:AddToggle("WebhookEnabled", { Text = "Enable Webhook", Default = false })
    WebhookGroup:AddInput("WebhookUrl", {
        Text = "Webhook URL",
        Default = "",
        Placeholder = "https://discord.com/api/webhooks/...",
        Finished = true
    })
    WebhookGroup:AddInput("WebhookPingId", { Text = "Ping User ID", Default = "", Placeholder = "Discord user id (optional)", Finished = true })
    WebhookGroup:AddToggle("WebhookPingEveryone", { Text = "Ping @everyone", Default = false })
    WebhookGroup:AddButton({
        Text = "Send Test Message",
        Func = function()
            local GL = Options.WebhookUrl
            if GL then
                local GM_1 = Options.WebhookUrl.Value
                local GQ = if GM_1 then 1 else 0
                local GO = 325 * GQ + 3528 * (1 - GQ)
                local GP = 1554 * GQ + 3594 * (1 - GQ)
                if not ((GO * 190 + GP * 2672 + GO * GP) % 16777213 == 4719088) then
                    GM_1 = ""
                end
                GL = tostring(GM_1)
            end
            local GM_2 = GL
            local GT = if GM_2 then 1 else 0
            local GR = 3690 * GT + 1702 * (1 - GT)
            local GS = 251 * GT + 3366 * (1 - GT)
            if not ((GR * 1762 + GS * 1081 + GR * GS) % 16777213 == 7699301) then
                GM_2 = ""
            end
            if GM_2 == "" then
                Library:Notify("Set a webhook URL first")
                return
            end
            if uF({
                username = "Tempo Hub",
                content = u_(),
                embeds = {
                    {
                        title = "Webhook Connected",
                        description = "Idle Mafia Game crew roll webhooks are ready.",
                        color = 5793266,
                        fields = {
                            { name = "Player", value = uY.Name, inline = true },
                            { name = "Place", value = tostring(game.PlaceId), inline = true }
                        },
                        footer = { text = "Idle Mafia Game | Tempo Hub" }
                    }
                }
            }) then
                Library:Notify("Webhook test sent")
            else
                Library:Notify("Webhook test failed")
            end
        end
    })
    local RarityFiltersGroup = vJ.Webhook:AddRightGroupbox("Rarity Filters", "list-filter")
    RarityFiltersGroup:AddDropdown("WebhookRarities", {
        Text = "Log Rarities",
        Values = tW,
        Default = vB,
        Multi = true,
        AllowNull = true,
        Expandable = true,
        ExpandColumns = 2
    })
end
function fns.fn1171()
    local Be = tonumber(ud:GetAttribute("GlobalShopDiscount")) or 0
    if Be <= 0 or Be >= 1 then
        return 0
    end
    return Be
end
function fns.fn1174()
    local D7_1
    if os.clock() - vm < 0.2 then
        return false
    end
    local D2 = vv()
    local D2_2
    if not D2 then
        return false
    end
    local D3 = D2.skillPoints or 0
    if D3 < 1 then
        return false
    end
    local D3_1 = ua()
    local D2_1 = (D2.allocs or {})[D3_1] or 0
    local D5_1 = 1
    D2_2, D7_1 = pcall(Config.allocCost, D3_1, D2_1)
    local D6_2 = D2_2 and type(D7_1) == "number"
    if D6_2 then
        D5_1 = D7_1
    end
    if D3 < D5_1 then
        return false
    end
    vm = os.clock()
    local D2_3 = vk(AllocateSkillPoint, D3_1, 1)
    return D2_3 ~= nil and D2_3.ok == true
end
local function fn1188(cu)
    local xZ = 0
    local x0 = cu.properties or {}
    for k, v in x0 do
        local x__1 = v.owned or 0
        xZ += x__1
    end
    return xZ
end
local function fn1237(hf, hg)
    local Cj = Library.Unloaded
    local Cq = if Cj then 1 else 0
    local Co = 1954 * Cq + 836 * (1 - Cq)
    local Cp = 3621 * Cq + 2844 * (1 - Cq)
    if not ((Co * 3266 + Cp * 506 + Co * Cp) % 16777213 == 15289424) then
        Cj = not vy("WebhookEnabled")
    end
    if Cj then
        return
    end
    if type(hf) ~= "table" then
        return
    end
    local Cj_1 = tonumber(hf.rarity) or 0
    local Cj_2 = GameData.RARITY_NAMES[Cj_1] or "#" .. tostring(Cj_1)
    local Cj_3 = uC("WebhookRarities")
    if not Cj_3[Cj_2] then
        return
    end
    local Cj_4 = hf.name or "Unknown"
    local Cl = {
        { name = "Crew", value = tostring(Cj_4), inline = true },
        { name = "Rarity", value = Cj_2, inline = true },
        { name = "Player", value = uY.Name, inline = true }
    }
    if hg ~= nil then
        Cl[#Cl + 1] = { name = "Slot", value = tostring(hg), inline = true }
    end
    if hf.atk ~= nil then
        Cl[#Cl + 1] = { name = "ATK", value = tostring(hf.atk), inline = true }
    end
    if hf.def ~= nil then
        Cl[#Cl + 1] = { name = "DEF", value = tostring(hf.def), inline = true }
    end
    local Cm = Cj_2 == "Secret" or Cj_2 == "Forbidden"
    local Cm_1 = vH[Cj_2] or 5793266
    uy({
        title = "Crew Hired",
        color = Cm_1,
        fields = Cl,
        footer = { text = "Idle Mafia Game | Tempo Hub" },
        timestamp = DateTime.now():ToIsoDate()
    }, Cm)
end
local function fn1238(bK, bL)
    if setclipboard then
        setclipboard(bK)
    elseif toclipboard then
        toclipboard(bK)
    end
    Library:Notify(bL)
end
local function fn1280()
    local yU = vv()
    local yV = not yU
    local y1 = if yV then 1 else 0
    local y_ = 3460 * y1 + 3607 * (1 - y1)
    local y0 = 941 * y1 + 548 * (1 - y1)
    if not ((y_ * 1776 + y0 * 3884 + y_ * y0) % 16777213 == 13055664) then
        yV = not yU.operations
    end
    if yV then
        return false
    end
    local yV_1 = {}
    local yW = yU.operations.active
    local y1_1 = if yW then 1 else 0
    local y__1 = 1416 * y1_1 + 2922 * (1 - y1_1)
    local y0_1 = 4004 * y1_1 + 3472 * (1 - y1_1)
    if not ((y__1 * 2316 + y0_1 * 2232 + y__1 * y0_1) % 16777213 == 1108835) then
        yW = yV_1
    end
    local yU_1 = false
    local yV_2 = yW
    local y4 = 1
    while y4 <= 4 do
        local y5 = y4
        local yW_1 = yV_2[y5]
        if yW_1 then
            local max = math.max
            local yY = yW_1.remaining or 0
            local yW_2 = max(0, yY - State.sinceSync())
            if yW_2 <= 0 then
                local yW_3 = vk(CollectOperation, y5)
                if yW_3 and yW_3.ok then
                    yU_1 = true
                    task.wait(0.2)
                end
            end
        end
        y4 += 1
    end
    return yU_1
end
local function fn1290(cz)
    local x8 = cz.serverNow or os.time()
    return x8 + State.sinceSync()
end
local function fn1332()
    return State.data
end
local function fn1345()
    local A2 = u4("CrewHireTier", ue[1])
    return uc[A2] or Config.CREW.hireTiers[1]
end
local function fn1353(h9, ia)
    if h9.mine ~= nil then
        return false
    end
    if (h9.bustWait or 0) > 0 then
        return false
    end
    if h9.startsLeft ~= nil and h9.startsLeft < 1 then
        return false
    end
    local Dg_2 = ia.cash or 0
    local Di = ia.pools and ia.pools.energy or 0
    local Dg_4 = nil
    local Dj = -1
    for i, v in ipairs(GameData.HEISTS) do
        local Dm = ia.level >= (v.level or 1)
        if Dm then
            Dm = Dg_2 >= (v.stake or 0)
        end
        if Dm then
            Dm = Di >= (v.energy or 0)
        end
        if Dm then
            Dm = (v.cash or 0) > Dj
        end
        if Dm then
            Dj = v.cash or 0
            Dg_4 = v
        end
    end
    if not Dg_4 then
        return false
    end
    local Dh_1 = vk(uq, "start", Dg_4.id)
    vw = 0
    return Dh_1 ~= nil and Dh_1.ok == true
end
local function fn1391()
    local CO, CT
    local CQ_7, CQ_8
    local CH_7
    local CG_7
    local CD_13, CD_14
    local CI = if os.clock() - tT < 1.25 then 1 else 0
    if CI == 1 then
        return false
    end
    local Cu = vv()
    if not Cu then
        return false
    end
    local Cw = Cu.crew or {}
    local Cw_28
    local Cw_1 = math.max(#Cw, 1)
    local Cx = Cu.cash or 0
    local Cy_7, Cy_8
    local Cx_1 = t5()
    local Cz = vD()
    local CA = u9()
    local CB = uB() == uJ[1]
    local CB_13, CB_14, CB_15
    local CC = Config.COMBAT.crewCap or 30
    local CC_26, CC_27
    if Cw_1 < CC then
        local CC_1 = false
        local CL = 2
        while CL <= Cw_1 do
            local CD_1 = Cw[CL]
            if not CD_1 or CD_1.rarity == nil then
                CC_1 = true
                break
            end
            CL += 1
        end
        if not CC_1 then
            local CC_2 = Config.crewSlotCost(Cw_1)
            if CC_2 <= Cx then
                local CC_3 = vk(uU, "buyslot", nil)
                if CC_3 and CC_3.ok then
                    tT = os.clock()
                    return true
                end
                local CC_4 = (vv())
                if not ((CG_7 * 1284 + CH_7 * 3506 + CG_7 * CH_7) % 16777213 == 3497496) then
                    CC_4 = Cu
                end
                local Cu_1 = CC_4
                local CD_3 = Cu_1.crew or {}
                local Cw_2 = math.max(#CD_3, 1)
                CO = Cw_2
                while CQ_7 <= CO do
                    if CD_13 then
                        if CC_26 <= Cy_7 then
                            local CC_9 = vk(uU, "hire", Cx_1.id)
                            tT = os.clock()
                            if CD_14 then
                                if type(CC_27.member) == "table" then
                                    task.spawn(t4, CC_9.member, CC_9.index)
                                end
                                return true
                            end
                            return false
                        end
                        return false
                    end
                end
                if CB then
                    return false
                end
                local CQ_2 = 2
                while true do
                    if not (CQ_8 <= CO) then
                        return false
                    end
                    CT = CQ_2
                    if CB_13 then
                        break
                    end
                    CQ_2 += 1
                end
                local CU_2 = CT
                vk(uU, "dismiss", CU_2)
                if not CB_14 then
                    return false
                end
                task.wait(0.2)
                local Cw_5 = vv() or Cu_1
                if Cw_28 > Cy_8 then
                    tT = os.clock()
                    return true
                end
                local Cw_8 = vk(uU, "hire", Cx_1.id)
                tT = os.clock()
                if CB_15 then
                    task.spawn(t4, Cw_8.member, Cw_8.index)
                end
                return Cw_8 ~= nil and Cw_8.ok == true
            end
            local CC_10 = (vv())
            if not ((CG_7 * 1284 + CH_7 * 3506 + CG_7 * CH_7) % 16777213 == 3497496) then
                CC_10 = Cu
            end
            local Cu_3 = CC_10
            local CD_6 = Cu_3.crew or {}
            local Cw_9 = math.max(#CD_6, 1)
            CO = Cw_9
            while CQ_7 <= CO do
                if CD_13 then
                    if CC_26 <= Cy_7 then
                        local CC_15 = vk(uU, "hire", Cx_1.id)
                        tT = os.clock()
                        if CD_14 then
                            if type(CC_27.member) == "table" then
                                task.spawn(t4, CC_15.member, CC_15.index)
                            end
                            return true
                        end
                        return false
                    end
                    return false
                end
            end
            if CB then
                return false
            end
            local CQ_4 = 2
            while true do
                if not (CQ_8 <= CO) then
                    return false
                end
                CT = CQ_4
                if CB_13 then
                    break
                end
                CQ_4 += 1
            end
            local CU_4 = CT
            vk(uU, "dismiss", CU_4)
            if not CB_14 then
                return false
            end
            task.wait(0.2)
            local Cw_12 = vv() or Cu_3
            if Cw_28 > Cy_8 then
                tT = os.clock()
                return true
            end
            local Cw_15 = vk(uU, "hire", Cx_1.id)
            tT = os.clock()
            if CB_15 then
                task.spawn(t4, Cw_15.member, Cw_15.index)
            end
            return Cw_15 ~= nil and Cw_15.ok == true
        end
        local CC_16 = (vv())
        if not ((CG_7 * 1284 + CH_7 * 3506 + CG_7 * CH_7) % 16777213 == 3497496) then
            CC_16 = Cu
        end
        local Cu_5 = CC_16
        local CD_9 = Cu_5.crew or {}
        local Cw_16 = math.max(#CD_9, 1)
        CO = Cw_16
        while CQ_7 <= CO do
            if CD_13 then
                if CC_26 <= Cy_7 then
                    local CC_21 = vk(uU, "hire", Cx_1.id)
                    tT = os.clock()
                    if CD_14 then
                        if type(CC_27.member) == "table" then
                            task.spawn(t4, CC_21.member, CC_21.index)
                        end
                        return true
                    end
                    return false
                end
                return false
            end
        end
        if CB then
            return false
        end
        local CQ_6 = 2
        while true do
            if not (CQ_8 <= CO) then
                return false
            end
            CT = CQ_6
            if CB_13 then
                break
            end
            CQ_6 += 1
        end
        local CU_6 = CT
        vk(uU, "dismiss", CU_6)
        if not CB_14 then
            return false
        end
        task.wait(0.2)
        local Cw_19 = vv() or Cu_5
        if Cw_28 > Cy_8 then
            tT = os.clock()
            return true
        end
        local Cw_22 = vk(uU, "hire", Cx_1.id)
        tT = os.clock()
        if CB_15 then
            task.spawn(t4, Cw_22.member, Cw_22.index)
        end
        return Cw_22 ~= nil and Cw_22.ok == true
    end
    local CC_22 = (vv())
    local CI_7 = if CC_22 then 1 else 0
    CG_7 = 1544 * CI_7 + 3910 * (1 - CI_7)
    CH_7 = 300 * CI_7 + 1935 * (1 - CI_7)
    if not ((CG_7 * 1284 + CH_7 * 3506 + CG_7 * CH_7) % 16777213 == 3497496) then
        CC_22 = Cu
    end
    local Cu_7 = CC_22
    local CD_12 = Cu_7.crew or {}
    local Cw_23 = math.max(#CD_12, 1)
    local CC_24 = Cu_7.cash
    local CI_8 = if CC_24 then 1 else 0
    local CG_8 = 1526 * CI_8 + 2911 * (1 - CI_8)
    local CH_8 = 1382 * CI_8 + 3026 * (1 - CI_8)
    if not ((CG_8 * 777 + CH_8 * 2051 + CG_8 * CH_8) % 16777213 == 6129116) then
        CC_24 = 0
    end
    Cy_7 = CC_24
    CQ_7 = 2
    CO = Cw_23
    while CQ_7 <= CO do
        local CC_25 = CD_12[CQ_7]
        CD_13 = not CC_25 or CC_25.rarity == nil
        if CD_13 then
            CC_26 = Cx_1.cost or 0
            if CC_26 <= Cy_7 then
                CC_27 = vk(uU, "hire", Cx_1.id)
                tT = os.clock()
                CD_14 = CC_27 and CC_27.ok
                if CD_14 then
                    if type(CC_27.member) == "table" then
                        task.spawn(t4, CC_27.member, CC_27.index)
                    end
                    return true
                end
                return false
            end
            return false
        end
        CQ_7 += 1
    end
    if CB then
        return false
    end
    CQ_8 = 2
    while true do
        if not (CQ_8 <= CO) then
            return false
        end
        CT = CQ_8
        local Cw_24 = CD_12[CT]
        CB_13 = Cw_24 and Cw_24.rarity ~= nil and Cw_24.rarity < Cz and Cw_24.rarity < CA
        if CB_13 then
            break
        end
        CQ_8 += 1
    end
    local CU_8 = CT
    local Cw_25 = vk(uU, "dismiss", CU_8)
    CB_14 = Cw_25 and Cw_25.ok
    if not CB_14 then
        return false
    end
    task.wait(0.2)
    local Cw_26 = vv() or Cu_7
    Cy_8 = Cw_26.cash or 0
    Cw_28 = Cx_1.cost or 0
    if Cw_28 > Cy_8 then
        tT = os.clock()
        return true
    end
    local Cw_29 = vk(uU, "hire", Cx_1.id)
    tT = os.clock()
    CB_15 = Cw_29 and Cw_29.ok and type(Cw_29.member) == "table"
    if CB_15 then
        task.spawn(t4, Cw_29.member, Cw_29.index)
    end
    return Cw_29 ~= nil and Cw_29.ok == true
end
local function fn1398(bR)
    local xf = Toggles[bR]
    return xf ~= nil and xf.Value == true
end
local function fn1412(cq, cr)
    local baseCost = cq.baseCost
    local costGrowth = Config.PROPERTY.costGrowth
    local xX = cr or 0
    return math.floor(baseCost * costGrowth ^ xX + 0.5)
end
local function fn1419()
    if os.clock() - ve < 1.25 then
        return false
    end
    local El = vv()
    if not El then
        return false
    end
    if not El.family or not El.family.role then
        return false
    end
    local En = El.pools and El.pools.stamina or 0
    local En_1 = tQ(u4("FamilyStaminaKeep", "0"), 0)
    local Eo = En - En_1
    if Eo < 1 then
        return false
    end
    local Em_3 = uC("FamilyStaminaPerks")
    if not t2(Em_3) then
        return false
    end
    local En_2 = uj() or El.family
    local Ep = En_2.perks or {}
    local Eq = En_2.perkProgress or {}
    local Eq_1 = En_2.staminaPerkCosts
    local ED = if Eq_1 then 1 else 0
    local EB = 2063 * ED + 3624 * (1 - ED)
    local EC = 781 * ED + 173 * (1 - ED)
    if not ((EB * 908 + EC * 2702 + EB * EC) % 16777213 == 5594669) then
        Eq_1 = Config.FAMILY.staminaPerkCosts
    end
    local Es = Eq_1 or {}
    local El_2 = En_2.maxPerkLevel or Config.FAMILY.maxPerkLevel
    local ED_1 = if El_2 then 1 else 0
    local EB_1 = 1790 * ED_1 + 914 * (1 - ED_1)
    local EC_1 = 147 * ED_1 + 1267 * (1 - ED_1)
    if not ((EB_1 * 3879 + EC_1 * 1650 + EB_1 * EC_1) % 16777213 == 7449090) then
        El_2 = 20
    end
    local Er_2 = El_2
    local El_3 = Config.FAMILY.contributeMax or 25
    local Es_1 = nil
    local Et = math.huge
    local Eu = math.huge
    for k in Em_3 do
        local El_4 = us[k]
        if El_4 then
            local Em_4 = vV(Ep, El_4)
            if Em_4 < Er_2 then
                local Ew = Es[Em_4 + 1]
                local Ex = Eq[El_4] or 0
                local Ey = Ew
                if Ey then
                    Ey = math.max(1, Ew - Ex)
                end
                local Ew_1 = Ey or 1
                local Ew_2 = Em_4 < Eu
                if not Ew_2 then
                    Ew_2 = Em_4 == Eu and Ew_1 < Et
                end
                if Ew_2 then
                    Eu = Em_4
                    Et = Ew_1
                    Es_1 = El_4
                end
            end
        end
    end
    if not Es_1 then
        return false
    end
    local El_5 = math.min(Eo, Et, El_3)
    if El_5 < 1 then
        return false
    end
    ve = os.clock()
    local Em_5 = vk(ui, "contribute", Es_1, El_5)
    if Em_5 and Em_5.ok then
        u0 = 0
    end
    return Em_5 ~= nil and Em_5.ok == true
end
tO = nil
DoJob = nil
tQ = nil
tR = nil
tS = nil
tT = nil
State = nil
tV = nil
tW = nil
tX = nil
tY = nil
H9_3 = nil
t_ = nil
t0 = nil
GameData = nil
t2 = nil
t3 = nil
t4 = nil
t5 = nil
t6 = nil
Config = nil
list = nil
t9 = nil
ua = nil
ub = nil
uc = nil
ud = nil
ue = nil
uf = nil
uh = nil
ui = nil
uj = nil
ul = nil
AllocateSkillPoint = nil
uo = nil
up = nil
uq = nil
ur = nil
us = nil
ut = nil
uu = nil
uv = nil
uw = nil
ux = nil
uy = nil
uz = nil
local Players, ug, uk, um
uA = nil
uB = nil
uC = nil
ClaimTrophy = nil
uE = nil
uF = nil
uH = nil
uJ = nil
uK = nil
uM = nil
uN = nil
uO = nil
ShopItemListDropdown = nil
uQ = nil
Library = nil
uU = nil
uV = nil
uW = nil
uY = nil
H9_2 = nil
u_ = nil
u0 = nil
u2 = nil
u4 = nil
Deposit = nil
u6 = nil
family = nil
Options = nil
u9 = nil
vb = nil
vc = nil
vd = nil
ve = nil
Toggles = nil
BuyShopItem = nil
vi = nil
vj = nil
vk = nil
vl = nil
vm = nil
local uG, uI, uL, uS, PlayerGui, uX, u1, Workspace, TeleportService, GuiService
CoreGui = nil
vp = nil
vq = nil
vs = nil
vu = nil
vv = nil
vw = nil
vy = nil
vz = nil
CollectOperation = nil
vB = nil
vC = nil
vD = nil
vF = nil
vG = nil
vH = nil
vI = nil
vJ = nil
vK = nil
vL = nil
vM = nil
vO = nil
vP = nil
vQ = nil
vR = nil
Attack = nil
vT = nil
vU = nil
vV = nil
local vn, vr, HttpService, VirtualUser, UserInputService, RunService
vn = nil
vr = nil
HttpService = nil
VirtualUser = nil
UserInputService = nil
RunService = nil
Players, RunService, UserInputService, VirtualUser, HttpService, CoreGui, GuiService, TeleportService, Workspace, uY, PlayerGui, uM = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local H9_23 = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
CoreGui = game:GetService("CoreGui")
GuiService = game:GetService("GuiService")
TeleportService = game:GetService("TeleportService")
Workspace = game:GetService("Workspace")
uY = Players.LocalPlayer
PlayerGui = uY:WaitForChild("PlayerGui")
uM = fns.fn314
if getgenv then
    getgenv().gethui = uM
end
pcall(function()
    gethui = uM
end)
if setthreadidentity then
    setthreadidentity(8)
end
uv, up, um, ug, ud, H9_34, Config, GameData, H9_3, State, DoJob, Attack, vO, vF, CollectOperation, vu, vp, BuyShopItem, vc, Deposit, H9_2, uU, uN, uH, ClaimTrophy, uw, uq, AllocateSkillPoint, ui, ue, uc = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local H9_12 = 9
repeat
    H9_66 = (H9_12 * 2 + 2) % 13 + 1
    if H9_66 <= 7 then
        if H9_66 <= 4 then
            if H9_66 <= 2 then
                if H9_66 <= 1 then
                    H9_57 = (vector.create((H9_12 * 7 + 9) % 11 + 1, (H9_12 * 1 + 11) % 13 + 1, (H9_12 * 5 + 7) % 17 + 1))
                    H9_47 = (vector.create((H9_12 * 4 + 9) % 11 + 1, (H9_12 * 4 + 4) % 13 + 1, (H9_12 * 1 + 16) % 17 + 1))
                    local Kw = vector.dot(H9_57, H9_47)
                    if Kw * Kw <= vector.dot(H9_57, H9_57) * vector.dot(H9_47, H9_47) then
                        H9_3 = require(ud:WaitForChild("Util"))
                        State = require(uY:WaitForChild("PlayerScripts"):WaitForChild("MWClient"):WaitForChild("State"))
                        DoJob = H9_34:WaitForChild("DoJob")
                        Attack = H9_34:WaitForChild("Attack")
                        vO = H9_34:WaitForChild("GetHitList")
                    else
                        ud = require(Attack:WaitForChild("Util"))
                        uY = require(DoJob:WaitForChild("PlayerScripts"):WaitForChild("MWClient"):WaitForChild("State"))
                        H9_34 = State:WaitForChild("DoJob")
                        vO = State:WaitForChild("Attack")
                        H9_3 = State:WaitForChild("GetHitList")
                    end
                    H9_12 = (H9_12 + 85) % 104
                else
                    if H9_12 * 89712853 + 11 + 7 >= H9_12 * 89712853 + 11 + 7 + 1 then
                        H9_34 = CollectOperation:WaitForChild("StartOperation")
                        vF = CollectOperation:WaitForChild("CollectOperation")
                    else
                        vF = H9_34:WaitForChild("StartOperation")
                        CollectOperation = H9_34:WaitForChild("CollectOperation")
                    end
                    H9_12 = (H9_12 + 85) % 104
                end
            elseif H9_66 <= 3 then
                if H9_12 * 37760813 + 5 + 7 <= H9_12 * 37760813 + 5 + 7 + 5 then
                    vu = H9_34:WaitForChild("BossAction")
                    vp = H9_34:WaitForChild("BuyProperty")
                    BuyShopItem = H9_34:WaitForChild("BuyShopItem")
                else
                    H9_34 = BuyShopItem:WaitForChild("BossAction")
                    vu = BuyShopItem:WaitForChild("BuyProperty")
                    vp = BuyShopItem:WaitForChild("BuyShopItem")
                end
                H9_12 = (H9_12 + 98) % 104
            else
                local JM = bit32.rrotate(bit32.bxor(bit32.lrotate(H9_12, 29), string.byte(tostring(uN))), 6)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(JM, 2002248793), 2590768706), (bit32.bxor(bit32.band(JM, 2292718502), 688782297))), 2590768706), 688782297) ~= JM then
                    H9_2 = Deposit:WaitForChild("OpenCrate")
                    vc = Deposit:WaitForChild("Deposit")
                    H9_34 = Deposit:WaitForChild("AutoEquipCrew")
                else
                    vc = H9_34:WaitForChild("OpenCrate")
                    Deposit = H9_34:WaitForChild("Deposit")
                    H9_2 = H9_34:WaitForChild("AutoEquipCrew")
                end
                H9_12 = (H9_12 + 33) % 104
            end
        elseif H9_66 <= 6 then
            if H9_66 <= 5 then
                if (not up or up or (not up or not uw)) and (vF or not uw or vF and H9_3) and (not vF and not H9_3 or (not up or vF) or (H9_3 or uw or (not up or uw))) or not ((not up or up or (not up or not uw)) and (vF or not uw or vF and H9_3) and (not vF and not H9_3 or (not up or vF) or (H9_3 or uw or (not up or uw)))) then
                    uU = H9_34:WaitForChild("CrewAction")
                    uN = H9_34:WaitForChild("ClaimLadder")
                    uH = H9_34:WaitForChild("ClaimGroupBonus")
                    ClaimTrophy = H9_34:WaitForChild("ClaimTrophy")
                    uw = H9_34:WaitForChild("ClaimSetTrophy")
                else
                    uN = ClaimTrophy:WaitForChild("CrewAction")
                    uU = ClaimTrophy:WaitForChild("ClaimLadder")
                    uw = ClaimTrophy:WaitForChild("ClaimGroupBonus")
                    uH = ClaimTrophy:WaitForChild("ClaimTrophy")
                    H9_34 = ClaimTrophy:WaitForChild("ClaimSetTrophy")
                end
                H9_12 = (H9_12 + 85) % 104
            else
                if H9_12 * 11035809 + 11 + 3 >= H9_12 * 11035809 + 11 + 3 + 4 then
                    H9_34 = AllocateSkillPoint:WaitForChild("HeistAction")
                    uq = AllocateSkillPoint:WaitForChild("AllocateSkillPoint")
                else
                    uq = H9_34:WaitForChild("HeistAction")
                    AllocateSkillPoint = H9_34:WaitForChild("AllocateSkillPoint")
                end
                H9_12 = (H9_12 + 46) % 104
            end
        else
            local Ky = bit32.rrotate(bit32.bxor(bit32.lrotate(H9_12, 28), string.byte(tostring(uc))), 2)
            if bit32.bxor(bit32.lrotate(bit32.bxor(Ky, 3750979446), 28), 1845048951) ~= bit32.lrotate(Ky, 28) then
                ue = uc:WaitForChild("FamilyAction")
                H9_34 = {}
                ui = {}
            else
                ui = H9_34:WaitForChild("FamilyAction")
                ue = {}
                uc = {}
            end
            H9_12 = (H9_12 + 98) % 104
        end
    elseif H9_66 <= 10 then
        if H9_66 <= 9 then
            if H9_66 <= 8 then
                H9_57 = (vector.create((H9_12 * 2 + 1) % 11 + 1, (H9_12 * 2 + 10) % 13 + 1, (H9_12 * 7 + 9) % 17 + 1))
                H9_47 = (vector.create((H9_12 * 5 + 6) % 11 + 1, (H9_12 * 11 + 10) % 13 + 1, (H9_12 * 8 + 17) % 17 + 1))
                H9_37 = (vector.create((H9_12 * 6 + 8) % 11 + 1, (H9_12 * 1 + 8) % 13 + 1, (H9_12 * 9 + 16) % 17 + 1))
                H9_26 = (vector.create((H9_12 * 1 + 4) % 5 + 1, (H9_12 * 2 + 2) % 7 + 1, (H9_12 * 5 + 1) % 9 + 1))
                if vector.dot(vector.cross(H9_57, (vector.cross(H9_47, H9_37))), H9_26) == vector.dot(H9_47 * vector.dot(H9_57, H9_37) - H9_37 * vector.dot(H9_57, H9_47), H9_26) + 1 then
                    vF = "Idle Mafia Game"
                else
                    uv = "Idle Mafia Game"
                end
                H9_12 = (H9_12 + 85) % 104
            else
                if (Config and not uq and (Deposit or not uq) or (not uq or ug) and (not Deposit or uq)) and (ug and not uN or Config and not uq or (not uq and not uN or (not ug or ug))) and not ((Config and not uq and (Deposit or not uq) or (not uq or ug) and (not Deposit or uq)) and (ug and not uN or Config and not uq or (not uq and not uN or (not ug or ug)))) then
                    ug = "https://discord.gg/K7Qxnxkk46"
                    up = "https://discord.gg/K7Qxnxkk46"
                    um = "https://tempohub.shop"
                else
                    up = "https://discord.gg/K7Qxnxkk46"
                    um = "https://discord.gg/K7Qxnxkk46"
                    ug = "https://tempohub.shop"
                end
                H9_12 = (H9_12 + 20) % 104
            end
        else
            if (H9_12 * 3 + 8) * 9 % 4 == ((H9_12 * 3 + 8) * 9 + 0) % 4 then
                ud = H9_23:WaitForChild("MW")
            else
                H9_23 = ud:WaitForChild("MW")
            end
            H9_12 = (H9_12 + 59) % 104
        end
    elseif H9_66 <= 12 then
        if H9_66 <= 11 then
            H9_66 = (vector.create((H9_12 * 1 + 7) % 11 + 1, (H9_12 * 10 + 7) % 13 + 1, (H9_12 * 2 + 2) % 17 + 1))
            H9_57 = (vector.create((H9_12 * 7 + 6) % 11 + 1, (H9_12 * 9 + 1) % 13 + 1, (H9_12 * 7 + 2) % 17 + 1))
            H9_47 = (vector.create((H9_12 * 3 + 6) % 11 + 1, (H9_12 * 11 + 8) % 13 + 1, (H9_12 * 12 + 6) % 17 + 1))
            if vector.dot(vector.cross(H9_66, H9_57), H9_47) == vector.dot(vector.cross(H9_57, H9_47), H9_66) + 4 then
                ud = H9_34:WaitForChild("Remotes")
            else
                H9_34 = ud:WaitForChild("Remotes")
            end
            H9_12 = (H9_12 + 72) % 104
        else
            H9_66 = (vector.create((H9_12 * 3 + 3) % 11 + 1, (H9_12 * 4 + 4) % 13 + 1, (H9_12 * 4 + 2) % 17 + 1))
            H9_57 = (vector.create((H9_12 * 1 + 2) % 11 + 1, (H9_12 * 5 + 12) % 13 + 1, (H9_12 * 8 + 6) % 17 + 1))
            H9_47 = (vector.create((H9_12 * 4 + 6) % 11 + 1, (H9_12 * 10 + 13) % 13 + 1, (H9_12 * 3 + 10) % 17 + 1))
            H9_37 = (vector.create((H9_12 * 5 + 1) % 11 + 1, (H9_12 * 9 + 10) % 13 + 1, (H9_12 * 8 + 5) % 17 + 1))
            if vector.dot(vector.cross(H9_66, H9_57), (vector.cross(H9_47, H9_37))) == vector.dot(H9_66, H9_47) * vector.dot(H9_57, H9_37) - vector.dot(H9_66, H9_37) * vector.dot(H9_57, H9_47) then
                Config = require(ud:WaitForChild("Config"))
            else
                ud = require(Config:WaitForChild("Config"))
            end
            H9_12 = (H9_12 + 46) % 104
        end
    else
        H9_66 = { "gum", "gepop", "srqg", "gocxjv", "ranvsul", "vkkupbe", "vnmzd", "glu" }
        if H9_66[(H9_12 * 86 + 63) % 8 + 1] <= H9_66[(H9_12 * 86 + 63) % 8 + 1] then
            GameData = require(ud:WaitForChild("GameData"))
        else
            ud = require(GameData:WaitForChild("GameData"))
        end
        H9_12 = (H9_12 + 20) % 104
    end
until (H9_12 * 55 + 36) % 104 == 11
for i, v in ipairs(Config.CREW.hireTiers) do
    H9_34 = v.name
    table.insert(ue, H9_34)
    uc[H9_34] = v
end
tR = {}
tW = {}
for i, v in ipairs(GameData.RARITY_NAMES) do
    table.insert(tW, v)
    tR[v] = i
end
vH, vB = nil, nil
H9_34 = 13
repeat
    H9_23 = (H9_34 * 1 + 1) % 2 + 1
    if H9_23 <= 1 then
        H9_23 = { "hamn", "twabjxngc", "zmpkhjvpm", "mzl", "qddyrsffok", "oory", "lgboq" }
        local KB = H9_34
        H9_12 = H9_23[KB % 7 + 1]
        if H9_12:len() >= H9_12:gsub("(.)", "%1%1", KB % 3 % 2 + 1):len() then
            vB = {
                Uncommon = 5763719,
                Legendary = 15844367,
                Secret = 10038562,
                Common = 9807270,
                Mythic = 15105570,
                Epic = 10181046,
                Forbidden = 15548997,
                Rare = 3447003
            }
        else
            vH = {
                Common = 9807270,
                Uncommon = 5763719,
                Rare = 3447003,
                Epic = 10181046,
                Legendary = 15844367,
                Mythic = 15105570,
                Secret = 10038562,
                Forbidden = 15548997
            }
        end
        H9_34 = (H9_34 + 9) % 16
    else
        H9_23 = (vector.create((H9_34 * 7 + 6) % 11 + 1, (H9_34 * 6 + 4) % 13 + 1, (H9_34 * 11 + 2) % 17 + 1))
        H9_12 = (vector.create((H9_34 * 7 + 4) % 11 + 1, (H9_34 * 11 + 10) % 13 + 1, (H9_34 * 8 + 8) % 17 + 1))
        H9_66 = (vector.create((H9_34 * 7 + 8) % 11 + 1, (H9_34 * 6 + 10) % 13 + 1, (H9_34 * 14 + 16) % 17 + 1))
        if vector.dot(vector.cross(H9_23, H9_12), H9_66) == vector.dot(vector.cross(H9_12, H9_66), H9_23) then
            vB = {}
        else
            vH = {}
        end
        H9_34 = (H9_34 + 11) % 16
    end
until (H9_34 * 11 + 5) % 16 == 0
for i, v in ipairs(tW) do
    H9_34 = v == "Forbidden"
    H9_23 = v == "Secret" or H9_34
    if H9_23 then
        vB[v] = true
    end
end
vj, vd, H9_66, H9_23, H9_12 = nil, nil, nil, nil, nil
H9_34 = 6
repeat
    H9_57 = (H9_34 * 1 + 0) % 2 + 1
    if H9_57 <= 1 then
        local Jr = bit32.rrotate(bit32.bxor(bit32.lrotate(H9_34, 20), string.byte(tostring(vj))), 12)
        if bit32.bxor(bit32.lrotate(bit32.bxor(Jr, 3999280797), 4), 3858950622) ~= bit32.lrotate(Jr, 4) then
            H9_66 = { "Energy", "Property", "Health", "Stamina", "Defense", "Attack" }
            vj = {
                Property = "property",
                Stamina = "stamina",
                Attack = "attack",
                Defense = "defense",
                Energy = "energy",
                Health = "health"
            }
            vd = {}
        else
            vj = { "Energy", "Stamina", "Health", "Attack", "Defense", "Property" }
            vd = {
                Energy = "energy",
                Stamina = "stamina",
                Health = "health",
                Attack = "attack",
                Defense = "defense",
                Property = "property"
            }
            H9_66 = {}
        end
        H9_34 = (H9_34 + 7) % 8
    else
        local JQ = bit32.rrotate(bit32.bxor(bit32.lrotate(H9_34, 25), string.byte(tostring(vj))), 8)
        if bit32.bxor(bit32.lrotate(bit32.bxor(JQ, 4002714726), 26), 2612679249) == bit32.lrotate(JQ, 26) then
            H9_23 = {}
            H9_12 = {}
        else
            H9_12 = {}
            H9_23 = {}
        end
        H9_34 = (H9_34 + 5) % 8
    end
until (H9_34 * 7 + 7) % 8 == 5
for i, v in ipairs(GameData.JOBS) do
    H9_34 = v.name
    table.insert(H9_66, H9_34)
    H9_23[H9_34] = v
    H9_12[H9_34] = true
end
H9_26 = {}
H9_47 = {}
H9_37 = {}
for i, v in ipairs(GameData.PROPERTIES) do
    H9_34 = v.name
    table.insert(H9_26, H9_34)
    H9_47[H9_34] = v
    H9_37[H9_34] = true
end
local H9_4 = {}
H9_57 = {}
local H9_15 = {}
for i, v in ipairs(GameData.OPERATIONS) do
    H9_34 = v.name
    table.insert(H9_4, H9_34)
    H9_57[H9_34] = v
    H9_15[H9_34] = true
end
vP, vK, H9_47 = nil, nil, nil
H9_23 = 0
repeat
    H9_34 = (vector.create((H9_23 * 4 + 9) % 11 + 1, (H9_23 * 2 + 13) % 13 + 1, (H9_23 * 15 + 13) % 17 + 1))
    H9_57 = (vector.create((H9_23 * 7 + 9) % 11 + 1, (H9_23 * 4 + 1) % 13 + 1, (H9_23 * 7 + 11) % 17 + 1))
    H9_60 = (vector.create((H9_23 * 7 + 8) % 11 + 1, (H9_23 * 9 + 2) % 13 + 1, (H9_23 * 14 + 7) % 17 + 1))
    if vector.dot(vector.cross(H9_34, H9_57), H9_60) == vector.dot(vector.cross(H9_57, H9_60), H9_34) + 4 then
        H9_47 = {}
        vP = {}
        vK = {}
    else
        vP = {}
        vK = {}
        H9_47 = {}
    end
    H9_23 = (H9_23 + 2) % 4
until (H9_23 * 3 + 2) % 4 == 0
for i, v in ipairs(GameData.SHOP) do
    H9_34 = GameData.ITEMS_BY_ID[v.item]
    H9_23 = H9_34 and H9_34.name
    H9_34 = H9_23 or v.item
    H9_23 = H9_34
    H9_34 = v.goldPrice and "(Gold)"
    H9_57 = H9_34 or "(Cash)"
    H9_34 = H9_57
    H9_57 = H9_23 .. " " .. H9_34
    if vK[H9_57] == nil then
        table.insert(vP, H9_57)
        vK[H9_57] = v
        H9_47[H9_57] = true
    end
end
uJ, us = nil, nil
uJ = { "Empty Slots Only", "Replace One By One" }
H9_23 = {}
local H9_50 = {}
us = {}
H9_60 = {}
H9_34 = {}
H9_57 = Config.FAMILY.perkTracks
local H9_41 = if H9_57 then 1 else 0
local H9_61 = 562 * H9_41 + 4021 * (1 - H9_41)
local H9_51 = 1267 * H9_41 + 3970 * (1 - H9_41)
if not ((H9_61 * 4052 + H9_51 * 1298 + H9_61 * H9_51) % 16777213 == 4633844) then
    H9_57 = H9_34
end
for k, v in pairs(H9_57) do
    if v.kind == "stamina" then
        H9_34 = v.name
        table.insert(H9_23, k)
        table.insert(H9_50, H9_34)
        us[H9_34] = k
        H9_60[H9_34] = true
    end
end
list, t3, t_, tY, tT, vT, vQ, vM, vC, vw, vq, vm, ve, family, u0, H9_57, Library, vr, vn, Toggles, Options, u1, uX, uS, uL, uG, H9_29, uK, uA, uk, t0, vR, vy, u4, uC, t2, tQ, vv, vi, uV, ux, uf, tX, vI, vk, uE, uQ, t9, ub, u2, vb, tV, uO, u6, uo, vL, ut, uu, t5, vD, u9, uB, ul, t6, tO, ur = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
table.sort(H9_50)
list = nil
t3 = 0
if (not H9_57 or list or not H9_57 and not H9_29 or not t9 and H9_29 and (uf or H9_57)) and (not uf and not H9_29 and (not H9_57 and list) and (not H9_57 or not H9_57 or (H9_57 or not H9_29))) and (list and H9_57 or (not t9 or not list) or (H9_57 or H9_57) and (not list or uf) or ((not H9_57 or H9_57) and (not t9 and t9) or (uf or not list) and (not list and t9))) and not ((not H9_57 or list or not H9_57 and not H9_29 or not t9 and H9_29 and (uf or H9_57)) and (not uf and not H9_29 and (not H9_57 and list) and (not H9_57 or not H9_57 or (H9_57 or not H9_29))) and (list and H9_57 or (not t9 or not list) or (H9_57 or H9_57) and (not list or uf) or ((not H9_57 or H9_57) and (not t9 and t9) or (uf or not list) and (not list and t9)))) then
    tY = {}
    t_ = 0
    vT = 0
    vQ = 0
    tT = 0
else
    t_ = {}
    tY = 0
    tT = 0
    vT = 0
    vQ = 0
end
vM = 0
vC = nil
vw = 0
vq = 0
vm = 0
ve = 0
family = nil
u0 = 0
H9_57 = ""
if (ve and ve and (uA or not vI) and (uA or vI or not vI and ve) or (not H9_29 or not uA or (vI or not ve)) and ((not ve or not H9_29) and (not ve or vI))) and ((ve and uA or (H9_29 or not H9_29)) and (not ve and not vI and (not uA and ve)) or uA and not H9_29 and (uA or not ve) and (not H9_29 or not vI or (vI or not vI))) and not ((ve and ve and (uA or not vI) and (uA or vI or not vI and ve) or (not H9_29 or not uA or (vI or not ve)) and ((not ve or not H9_29) and (not ve or vI))) and ((ve and uA or (H9_29 or not H9_29)) and (not ve and not vI and (not uA and ve)) or uA and not H9_29 and (uA or not ve) and (not H9_29 or not vI or (vI or not vI)))) then
    H9_57 = getgenv().Library
else
    Library = getgenv().Library
end
uK = function()
    local function w2(bc)
        local wY = not bc or not bc:IsA("ScreenGui")
        if wY then
            return
        end
        bc.ResetOnSpawn = false
        bc.IgnoreGuiInset = true
        bc.DisplayOrder = math.max(bc.DisplayOrder, 1000)
        pcall(function()
            bc.ClipToDeviceSafeArea = false
        end)
        pcall(function()
            bc.ScreenInsets = Enum.ScreenInsets.None
        end)
        if bc.Parent ~= CoreGui then
            bc.Parent = CoreGui
        end
    end
    w2(Library.ScreenGui)
    if Library.ActiveLoading and Library.ActiveLoading.ScreenGui then
        w2(Library.ActiveLoading.ScreenGui)
    end
    for i, v in ipairs({ "Obsidian", "ObsidianLoading" }) do
        local w3_1 = CoreGui:FindFirstChild(v) or PlayerGui:FindFirstChild(v)
        if w3_1 then
            w2(w3_1)
        end
    end
end
uK()
task.spawn(fns.worker)
vr = getgenv().ThemeManager
vn = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
u1 = "#7fd47f"
uX = "#6ec1ff"
uS = "#e8a34d"
uL = "#8b93a3"
uG = "#e05a5a"
uA = fns.fn1070
uk = fns.fn662
t0 = fn1238
vR = fns.fn30
vy = fn1398
if (u1 and not u1 or not uu and u1 or (u1 and uk or u1 and vL) or (not u1 or not ve or (not uQ or not uk) or (uk and uQ or not uu and vL))) and ((u1 and not ve or ve and uQ or (vL or uk or uQ and not u1)) and ((not uk or not uu) and (ve and not uk) or (uQ or not uk or (vL or not uu)))) or not ((u1 and not u1 or not uu and u1 or (u1 and uk or u1 and vL) or (not u1 or not ve or (not uQ or not uk) or (uk and uQ or not uu and vL))) and ((u1 and not ve or ve and uQ or (vL or uk or uQ and not u1)) and ((not uk or not uu) and (ve and not uk) or (uQ or not uk or (vL or not uu))))) then
    u4 = fns.fn606
    uC = fns.fn438
    t2 = fns.fn906
else
    t2 = fns.fn606
    u4 = fns.fn438
    uC = fns.fn906
end
tQ = fns.fn342
vv = fn1332
vi = fns.fn12
uV = fns.fn671
ux = fn1412
uf = fn1188
tX = fn1290
vI = fns.fn36
vk = function(cH, ...)
    local yd
    yd = nil
    local yf_1
    local ye_1
    yd = table.pack(...)
    ye_1, yf_1 = pcall(function()
        return cH:InvokeServer(table.unpack(yd, 1, yd.n))
    end)
    if not ye_1 then
        return nil
    end
    return yf_1
end
uE = fns.fn1
uQ = fns.fn228
t9 = fns.fn734
ub = fn1280
u2 = fns.fn871
vb = fns.fn390
tV = fns.fn442
uO = fns.fn546
u6 = fns.fn115
uo = fns.fn44
vL = fns.fn1055
ut = fns.fn851
uu = fns.fn917
t5 = fn1345
vD = fns.fn502
u9 = fns.fn934
uB = fns.fn1045
ul = fns.fn1171
t6 = fns.fn1004
tO = fns.fn983
ur = fns.fn1077
if (uu or not vm) and (not vm or not uu) or not uu and false and "#8b93a3" or false and ((uu or not vm) and (false and vm)) or not ((uu or not vm) and (not vm or not uu) or not uu and false and "#8b93a3" or false and ((uu or not vm) and (false and vm))) then
    H9_29 = syn
else
    u1 = syn
end
if H9_29 then
    H9_29 = syn.request
end
H9_34 = H9_29
if not H9_34 then
    H9_23 = http and http.request
    H9_34 = H9_23
end
if not H9_34 then
    H9_34 = http_request
end
local H9_10 = if H9_34 then 1 else 0
local H9_32 = 1631 * H9_10 + 1180 * (1 - H9_10)
local H9_21 = 2253 * H9_10 + 1407 * (1 - H9_10)
if not ((H9_32 * 2309 + H9_21 * 3765 + H9_32 * H9_21) % 16777213 == 15923167) then
    H9_34 = request
end
uI, vJ, uF, u_, uy, t4, uz, vz, uh, vG, vl, tS, uW, ua, vU, uj, vV, vs = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
uI = H9_34
if (not uh or vV or (uh or not vV)) and (uh and vV or uh and not uh) and (uh and not vV or (uh or vV) or (vV and uh or not vV and not vV)) or not ((not uh or vV or (uh or not vV)) and (uh and vV or uh and not uh) and (uh and not vV or (uh or vV) or (vV and uh or not vV and not vV))) then
    uF = function(gK)
        local B2
        local B4_9
        local B3 = Options.WebhookUrl
        local B3_8
        if B3 then
            local B4_6 = Options.WebhookUrl.Value
            local B9 = if B4_6 then 1 else 0
            local B7 = 3191 * B9 + 200 * (1 - B9)
            local B8 = 2187 * B9 + 2674 * (1 - B9)
            if not ((B7 * 4074 + B8 * 24 + B7 * B8) % 16777213 == 3254126) then
                B4_6 = ""
            end
            B3 = tostring(B4_6)
        end
        B2 = B3 or ""
        local B3_6 = B2 == ""
        local B4_8 = typeof(uI) ~= "function" or B3_6
        if B4_8 then
            return false
        end
        local B3_7 = not string.find(B2, "discord.com/api/webhooks/", 1, true) and not string.find(B2, "discordapp.com/api/webhooks/", 1, true)
        if B3_7 then
            return false
        end
        B3_8, B4_9 = pcall(function()
            return uI({
                Url = B2,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(gK)
            })
        end)
        if not B3_8 then
            return false
        end
        local B3_9 = B4_9
        if B3_9 then
            B3_9 = B4_9.StatusCode or B4_9.Status
        end
        local B4_10 = B3_9
        local B3_10 = B4_10 == nil
        if not B3_10 then
            B3_10 = B4_10 >= 200 and B4_10 < 300
        end
        return B3_10
    end
    u_ = fns.fn1131
else
    u_ = function(gK)
        local B2
        local B4_4
        local B3 = Options.WebhookUrl
        local B3_3
        if B3 then
            local B4_1 = Options.WebhookUrl.Value
            local B9 = if B4_1 then 1 else 0
            local B7 = 3191 * B9 + 200 * (1 - B9)
            local B8 = 2187 * B9 + 2674 * (1 - B9)
            if not ((B7 * 4074 + B8 * 24 + B7 * B8) % 16777213 == 3254126) then
                B4_1 = ""
            end
            B3 = tostring(B4_1)
        end
        B2 = B3 or ""
        local B3_1 = B2 == ""
        local B4_3 = typeof(uI) ~= "function" or B3_1
        if B4_3 then
            return false
        end
        local B3_2 = not string.find(B2, "discord.com/api/webhooks/", 1, true) and not string.find(B2, "discordapp.com/api/webhooks/", 1, true)
        if B3_2 then
            return false
        end
        B3_3, B4_4 = pcall(function()
            return uI({
                Url = B2,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(gK)
            })
        end)
        if not B3_3 then
            return false
        end
        local B3_4 = B4_4
        if B3_4 then
            B3_4 = B4_4.StatusCode or B4_4.Status
        end
        local B4_5 = B3_4
        local B3_5 = B4_5 == nil
        if not B3_5 then
            B3_5 = B4_5 >= 200 and B4_5 < 300
        end
        return B3_5
    end
    uF = fns.fn1131
end
uy = fns.fn685
t4 = fn1237
uz = fn1391
vz = fns.fn824
uh = fns.fn1047
vG = fns.fn557
vl = fn1353
tS = fns.fn1099
if (uz and 45 and (u_ or not uz) or (not uz or not uy and not uz) or (uz or uy) and (vz or u_) and (uy or not vz or (vz or not uy)) or (u_ or not uz) and (not uy) and false and ((uz or not vz) and (not vz and not vz) and (vz and vz or false))) and not (uz and 45 and (u_ or not uz) or (not uz or not uy and not uz) or (uz or uy) and (vz or u_) and (uy or not vz or (vz or not uy)) or (u_ or not uz) and (not uy) and false and ((uz or not vz) and (not vz and not vz) and (vz and vz or false))) then
    ua = fns.fn335
    uW = fns.fn18
else
    uW = fns.fn335
    ua = fns.fn18
end
vU = fns.fn1174
uj = fns.fn870
vV = fns.fn975
vs = fn1419
H9_57 = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = up, Copyable = true }, "|", uv },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
vJ = {
    Info = H9_57:AddTab("Info", "info"),
    Main = H9_57:AddTab("Main", "gavel"),
    Webhook = H9_57:AddTab("Webhook", "webhook"),
    Player = H9_57:AddTab("Player", "person-standing"),
    Settings = H9_57:AddTab("Settings", "settings")
}
local H9_40 = fns.fn24
for k, v in vJ do
    if k ~= "Info" then
        H9_40(v)
    end
end
ShopItemListDropdown = nil
H9_29 = vJ.Main:AddLeftGroupbox("Automation", "bot")
H9_29:AddToggle("AutoJob", { Text = "Auto Job", Default = false })
H9_29:AddDropdown("JobList", {
    Text = "Jobs",
    Values = H9_66,
    Default = H9_12,
    Multi = true,
    Expandable = true,
    ExpandColumns = 2
})
H9_29:AddToggle("AutoFight", { Text = "Auto Fight", Default = false })
H9_29:AddToggle("AutoOperation", { Text = "Auto Operation", Default = false })
H9_29:AddDropdown("OperationList", {
    Text = "Operations",
    Values = H9_4,
    Default = H9_15,
    Multi = true,
    Expandable = true,
    ExpandColumns = 2
})
H9_29:AddToggle("AutoClaimOperation", { Text = "Auto Claim Operation Rewards", Default = false })
H9_29:AddToggle("AutoClaimRewards", { Text = "Auto Claim Rewards", Default = false })
H9_29:AddToggle("AutoBoss", { Text = "Auto Boss", Default = false })
H9_29:AddToggle("AutoHeist", { Text = "Auto Heist", Default = false })
H9_29:AddToggle("AutoAllocatePoints", { Text = "Auto Allocate Points", Default = false })
H9_29:AddDropdown("SkillPointStat", { Text = "Allocate Into", Values = vj, Default = vj[1] })
H9_29:AddDivider("Family")
H9_29:AddToggle("AutoFamilyStamina", { Text = "Auto Donate Stamina", Default = false })
H9_29:AddDropdown("FamilyStaminaPerks", {
    Text = "Stamina Perks",
    Values = H9_50,
    Default = H9_60,
    Multi = true,
    Expandable = true,
    ExpandColumns = 2
})
H9_29:AddInput("FamilyStaminaKeep", { Text = "Keep Stamina", Default = "0", Numeric = false, Finished = true })
H9_57 = vJ.Main:AddRightGroupbox("Economy", "landmark")
H9_57:AddToggle("AutoBuyProperties", { Text = "Auto Buy Properties", Default = false })
H9_57:AddDropdown("PropertyList", {
    Text = "Properties",
    Values = H9_26,
    Default = H9_37,
    Multi = true,
    Expandable = true,
    ExpandColumns = 2
})
H9_57:AddDivider("Shop")
H9_57:AddToggle("AutoBuyShop", { Text = "Auto Buy Shop Items", Default = false })
H9_57:AddInput("ShopSpendLimitCash", {
    Text = "Max Cash Per Item",
    Default = "",
    Placeholder = "No limit",
    Numeric = false,
    Finished = true
})
H9_57:AddInput("ShopSpendLimitGold", {
    Text = "Max Gold Per Item",
    Default = "",
    Placeholder = "No limit",
    Numeric = false,
    Finished = true
})
H9_57:AddInput("ShopSearch", {
    Text = "Search Items",
    Default = "",
    Placeholder = "Filter shop items...",
    Numeric = false,
    Finished = false
})
ShopItemListDropdown = H9_57:AddDropdown("ShopItemList", {
    Text = "Shop Items",
    Values = vP,
    Default = H9_47,
    Multi = true,
    Expandable = true,
    ExpandColumns = 2
})
Options.ShopSearch:OnChanged(fns.fn289)
H9_57:AddToggle("AutoOpenCrates", { Text = "Auto Open Crates", Default = false })
H9_57:AddDivider("Bank")
H9_57:AddToggle("AutoBankDeposit", { Text = "Auto Bank Deposit", Default = false })
H9_57:AddInput("BankDepositThreshold", { Text = "Deposit Threshold", Default = "1000000", Numeric = false, Finished = true })
H9_57:AddInput("BankKeepCash", { Text = "Keep Cash", Default = "0", Numeric = false, Finished = true })
H9_23 = vJ.Main:AddRightGroupbox("Crew", "users")
H9_23:AddToggle("AutoEquipCrew", { Text = "Auto Equip Best Crew Gear", Default = false })
H9_23:AddToggle("AutoRollCrew", { Text = "Auto Roll Crew Rarity", Default = false })
H9_23:AddDropdown("CrewRollMode", { Text = "Roll Mode", Values = uJ, Default = uJ[1] })
H9_23:AddDropdown("CrewHireTier", { Text = "Hire Tier", Values = ue, Default = ue[1] })
H9_23:AddDropdown("CrewMinRarity", { Text = "Min Rarity", Values = tW, Default = tW[1] })
H9_23:AddDropdown("CrewKeepRarity", { Text = "Keep Rarity", Values = tW, Default = tW[#tW] })
H9_40 = function()
    local FQ
    local FP
    FP = nil
    FQ = nil
    local FO, Label, Label2, Label3, FU
    local function FV()
        local EX = hookfunction ~= nil
        local EY = hookmetamethod ~= nil
        local EZ = getrawmetatable ~= nil
        local E_ = setrawmetatable ~= nil
        local E0 = getgc ~= nil
        local E1 = getgenv ~= nil
        local E2 = getreg ~= nil
        local E3 = getconnections ~= nil
        local E4 = firesignal ~= nil
        local E5 = getcallbackvalue ~= nil
        local E6 = setclipboard ~= nil
        local E7 = getcustomasset ~= nil
        local E8 = getnamecallmethod ~= nil
        local E9 = isexecutorclosure ~= nil
        local Fa = fireproximityprompt ~= nil
        local Fb = firetouchinterest ~= nil
        local Fc = WebSocket ~= nil
        local Fd = readfile ~= nil
        local Fe = writefile ~= nil
        local Fg = (request or http_request) ~= nil
        local Fi = (debug and debug.getupvalues) ~= nil
        local Fk = (debug and debug.setupvalue) ~= nil
        local Fl = 0
        local Fm = { EX, EY, EZ, E_, E0, E1, E2, E3, E4, E5, E6, E7, E8, E9, Fa, Fb, Fc, Fd, Fe, Fg, Fi, Fk }
        for i, v in ipairs(Fm) do
            if v then
                Fl += 1
            end
        end
        local EX_1 = Fl / #Fm
        if EX_1 >= 0.9 then
            return uA("Full Support", u1)
        elseif EX_1 >= 0.6 then
            return uA("Half Support", uS)
        else
            return uA("Low Support", uG)
        end
    end
    FP = "Unknown"
    pcall(function()
        local Fy_1
        local Fx_1
        if identifyexecutor then
            Fy_1, Fx_1 = identifyexecutor()
            local Fz = Fy_1 ~= ""
            local FA = type(Fy_1) == "string" and Fz
            if FA then
                local Fz_1 = type(Fx_1) == "string" and Fx_1 ~= "" and Fy_1 .. " " .. Fx_1
                FP = Fz_1 or Fy_1
            end
        end
    end)
    local FW = FV()
    FQ = os.clock()
    FU = function()
        local FF = math.floor(os.clock() - FQ)
        if FF < 60 then
            return FF .. "s"
        elseif FF < 3600 then
            return string.format("%dm %ds", math.floor((FF) / (60)), FF % 60)
        else
            return string.format("%dh %dm", math.floor((FF) / (3600)), math.floor((FF % 3600) / (60)))
        end
    end
    local UserGroup = vJ.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = uY, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(uk("User", uY.DisplayName .. " @" .. uY.Name, u1), true)
    UserGroup:AddLabel(uk("UserId", tostring(uY.UserId), uX), true)
    UserGroup:AddLabel(uk("Executor", FP .. "  " .. FW, u1), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(uk("Session", FU(), uS), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            t0(uY.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            t0("https://www.roblox.com/users/" .. tostring(uY.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = vJ.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(uk("Game", uv, uX), true)
    Label2 = SessionGroup:AddLabel(uk("Players", "0/0", u1), true)
    FO = tostring(game.JobId)
    local FW_1 = #FO > 18 and string.sub(FO, 1, 18) .. "..."
    local FW_2 = FW_1 or FO
    SessionGroup:AddLabel(uk("Job", FW_2, uL), true)
    Label = SessionGroup:AddLabel(uk("Ping", "0 ms", uS), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            TeleportService:Teleport(game.PlaceId, uY)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            t0(FO, "Copied Job ID")
        end
    })
    task.spawn(function()
        local FL_1
        local FK_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(uk("Session", FU(), uS))
            Label2:SetText(uk("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), u1))
            FK_1, FL_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local FK_2 = FK_1 and FL_1 .. " ms" or "n/a"
            Label:SetText(uk("Ping", FK_2, uS))
        end
    end)
    local SocialsGroup = vJ.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = vR })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            t0(um, "Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            t0(ug, "Copied website link")
        end
    })
end
local function H9_18()
    local function lx()
        local Character = uY.Character
        local F_ = Character and Character:FindFirstChildOfClass("Humanoid")
        return F_
    end
    local function lC()
        local Character = uY.Character
        local F2 = Character and Character:FindFirstChild("HumanoidRootPart")
        return F2
    end
    local MovementGroup = vJ.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = vJ.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local CurrentCamera = Workspace.CurrentCamera
    local connection
    local function lM(lN)
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not lN)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not lN
            end
        end)
        if not lN then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(uY, "GameplayPaused", false)
            else
                uY.GameplayPaused = false
            end
        end)
    end
    local function lZ(l_)
        if not l_:IsA("ProximityPrompt") then
            return
        end
        l_.HoldDuration = 0
        l_.MaxActivationDistance = 50
        l_.RequiresLineOfSight = false
    end
    RunService.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if vy("NoClip") then
            local Character = uY.Character
            if Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    local Gc_1 = descendant:IsA("BasePart") and descendant.CanCollide
                    if Gc_1 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    UserInputService.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if vy("InfJump") then
            local Gk = lx()
            if Gk then
                Gk:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    RunService.RenderStepped:Connect(function(mf)
        if Library.Unloaded then
            return
        end
        if vy("WalkSpeedEnabled") then
            local Gm_1 = lx()
            if Gm_1 then
                Gm_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if vy("Fly") then
            local Gm_2 = lC()
            local Gn = lx()
            if Gm_2 and Gn then
                Gn.PlatformStand = true
                local Gn_1 = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    Gn_1 += CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    Gn_1 -= CurrentCamera.CFrame.LookVector
                end
                local Gs = if UserInputService:IsKeyDown(Enum.KeyCode.A) then 1 else 0
                if Gs == 1 then
                    Gn_1 -= CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    Gn_1 += CurrentCamera.CFrame.RightVector
                end
                local Gs_1 = if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
                if Gs_1 == 1 then
                    Gn_1 += Vector3.new(0, 1, 0)
                end
                local Gs_2 = if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then 1 else 0
                if Gs_2 == 1 then
                    Gn_1 -= Vector3.new(0, 1, 0)
                end
                Gm_2.AssemblyLinearVelocity = Vector3.zero
                if Gn_1.Magnitude > 0 then
                    Gm_2.CFrame = Gm_2.CFrame + Gn_1.Unit * Options.FlySpeed.Value * mf
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local Gt = lx()
            if Gt then
                Gt.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local Gv = lx()
            if Gv then
                Gv.WalkSpeed = 16
            end
        end
    end)
    Toggles.AntiGameplayPause:OnChanged(function()
        lM(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if vy("AntiGameplayPause") then
                lM(true)
            end
        end
    end)
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in ipairs(Workspace:GetDescendants()) do
                pcall(lZ, descendant)
            end
            connection = Workspace.DescendantAdded:Connect(function(mK)
                if vy("InstantProximityPrompt") then
                    pcall(lZ, mK)
                end
            end)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    Library:OnUnload(function()
        lM(false)
        if connection then
            connection:Disconnect()
            connection = nil
        end
        local GJ = lx()
        if GJ then
            GJ.PlatformStand = false
            GJ.WalkSpeed = 16
        end
    end)
end
H9_40()
H9_18()
fns.fn1168()
task.spawn(fns.worker2)
local function H9_63()
    local connection
    local MenuGroup = vJ.Settings:AddLeftGroupbox("Menu")
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    local nE = 0
    local nF = tick()
    local Label
    local function nH()
        local CurrentCamera = Workspace.CurrentCamera
        if not CurrentCamera then
            return
        end
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        nE += 1
        nF = tick()
        if Label then
            pcall(function()
                Label:SetText("AFK triggers: " .. nE)
            end)
        end
    end
    connection = uY.Idled:Connect(function()
        local G5 = if vy("AntiAfk") then 1 else 0
        if G5 == 1 then
            pcall(nH)
        end
    end)
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    Label = MenuGroup:AddLabel("AFK triggers: 0")
    MenuGroup:AddButton({
        Text = "Unload UI",
        Func = function()
            Library:Unload()
        end
    })
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local G6 = vy("AntiAfk") and tick() - nF >= 60
            if G6 then
                pcall(nH)
            end
        end
    end)
    Library:OnUnload(function()
        if connection then
            connection:Disconnect()
        end
    end)
    vr:SetLibrary(Library)
    vr:SetFolder("TempoHub")
    vr:SaveDefault("Evil Hello Kitty")
    vr:ApplyToTab(vJ.Settings)
    vr:LoadDefault()
    vn:SetLibrary(Library)
    vn:IgnoreThemeSettings()
    vn:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource", "WebhookUrl" })
    vn:SetFolder("TempoHub/IdleMafiaGame")
    local n3 = vn:BuildConfigSection(vJ.Settings)
    local function n4(n5, n6)
        local Ha_1 = (n5 == "Toggle" and Toggles or Options)[n6]
        local G9_2 = type(Ha_1) == "table" and Ha_1.Type == n5
        return G9_2 and Ha_1 or nil
    end
    local function od(oe, of)
        local Type = of.Type
        if Type == "Toggle" then
            return { idx = oe, type = "Toggle", value = of.Value == true }
        elseif Type == "Slider" then
            return { idx = oe, type = "Slider", value = tostring(of.Value) }
        elseif Type == "Dropdown" then
            return { idx = oe, type = "Dropdown", multi = of.Multi == true, value = of.Value }
        elseif Type == "Input" then
            local He = of.Value or ""
            return { idx = oe, type = "Input", text = tostring(He) }
        elseif Type == "ColorPicker" then
            return { idx = oe, type = "ColorPicker", value = of.Value:ToHex(), transparency = of.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = oe,
                type = "KeyPicker",
                mode = of.Mode,
                key = of.Value,
                modifiers = of.Modifiers,
                toggled = of.Toggled
            }
        else
            return nil
        end
    end
    local function oh()
        local Hk = {}
        for i, v in ipairs({ Toggles, Options }) do
            for k, v in pairs(v) do
                local Hl = type(v) == "table" and type(v.Type) == "string" and not vn.Ignore[k]
                if Hl then
                    local Hl_1 = od(k, v)
                    if Hl_1 then
                        Hk[#Hk + 1] = Hl_1
                    end
                end
            end
        end
        table.sort(Hk, function(ow, ox)
            if ow.type ~= ox.type then
                return ow.type < ox.type
            end
            return ow.idx < ox.idx
        end)
        return { objects = Hk }
    end
    local function oy(oz)
        local HB
        HB = nil
        local HC = type(oz) ~= "table" or type(oz.idx) ~= "string" or type(oz.type) ~= "string" or vn.Ignore[oz.idx]
        if HC then
            return false
        end
        HB = n4(oz.type, oz.idx)
        if not HB then
            return false
        end
        local HC_1 = pcall(function()
            if oz.type == "Input" then
                if type(oz.text) ~= "string" then
                    return
                end
                HB:SetValue(oz.text)
            elseif oz.type == "ColorPicker" then
                HB:SetValueRGB(Color3.fromHex(oz.value), oz.transparency)
            elseif oz.type == "KeyPicker" then
                HB:SetValue({ oz.key, oz.mode, oz.modifiers })
                if oz.mode == "Toggle" and oz.toggled ~= nil then
                    HB.Toggled = oz.toggled
                    HB:Update()
                end
            else
                HB:SetValue(oz.value)
            end
        end)
        return HC_1
    end
    n3:AddDivider()
    n3:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    n3:AddButton({
        Text = "Export Config to Clipboard",
        Func = function()
            local HI_1
            local HH_1
            HH_1, HI_1 = pcall(HttpService.JSONEncode, HttpService, oh())
            if not HH_1 then
                Library:Notify("Failed to encode the config")
                return
            end
            local HH_2 = setclipboard or toclipboard
            local HH_3 = type(HH_2) ~= "function"
            local HN = if HH_3 then 1 else 0
            local HL = 202 * HN + 3425 * (1 - HN)
            local HM = 2862 * HN + 2768 * (1 - HN)
            if not ((HL * 3840 + HM * 600 + HL * HM) % 16777213 == 3071004) then
                HH_3 = not pcall(HH_2, HI_1)
            end
            if HH_3 then
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Config copied to clipboard", 6)
        end
    })
    n3:AddButton({
        Text = "Import Config from Clipboard Field",
        Func = function()
            local HQ_1
            local HO = Options.SaveManager_ImportSource.Value or ""
            local HO_1
            local HP = tostring(HO):match("^%s*(.-)%s*$")
            if HP == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            HO_1, HQ_1 = pcall(HttpService.JSONDecode, HttpService, HP)
            local HP_1 = not HO_1 or type(HQ_1) ~= "table"
            local HU = if HP_1 then 1 else 0
            local HS = 3135 * HU + 2328 * (1 - HU)
            local HT = 2735 * HU + 1096 * (1 - HU)
            if not ((HS * 1262 + HT * 2050 + HS * HT) % 16777213 == 1360132) then
                HP_1 = type(HQ_1.objects) ~= "table"
            end
            if HP_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            local HO_2 = 0
            for i, v in ipairs(HQ_1.objects) do
                if oy(v) then
                    HO_2 += 1
                end
            end
            if HO_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local HQ_2 = HO_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(HO_2, HQ_2), 6)
        end
    })
    vn:LoadAutoloadConfig()
end
H9_63()
end)(...)

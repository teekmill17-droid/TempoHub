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
getgenv().TempoHoodSubtitle = "ROLL AN ARMY"
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
local sC_1, sC_4, sC_6, sC_7, sC_9, sC_11, sC_12, sC_15, sC_17, sC_19
local l2
local SaveManager
local mr
local EquipUnit
local l8
local k8
local lQ
local mx
local lx
local me
local le
local lW
local mD
local lD
local mk
local lk
local l1
local lJ
local mq
local connection2
local l7
local lP
local mw
local lw
local ld
local lV
local mC
local lC
local mj
local lj
local l0
local connection
local mp
local lp
local CurrentCamera2
local lO
local mv
local lv
local mc
local lc
local lU
local mB
local lB
local mi
local li
local l_
local lH
local mo
local lo
local l5
local lN
local mu
local MergeAll
local lb
local lT
local Options
local mh
local ResearchStart
local lZ
local Toggles
local mn
local ln
local l4
local lM
local mt
local lt
local ma
local la
local Library
local mz
local lz
local mg
local Label
local lY
local mF
local lF
local SwordSwingEvent
local lm
local l3
local lL
local ms
local ls
local l9
local ResearchComplete
local UnitConfig
local my
local ly
local mf
local lf
local lX
local mE
local lE
local ml
local ll
function fns.fn8()
    local pK = if lY("RebirthMaxed", false) == true then 1 else 0
    if pK == 1 then
        return
    end
    local pF = lY("HeartsNeed", 50) or 50
    if ld() >= pF then
        mE:FireServer()
    end
end
function fns.onInputBegan()
    mv = tick()
end
function fns.fn15(L, M)
    return L.order < M.order
end
function fns.fn22()
    local rP = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local rQ = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if rQ then
                local rQ_1 = l0(k, v)
                if rQ_1 then
                    rP[#rP + 1] = rQ_1
                end
            end
        end
    end
    table.sort(rP, function(hl, hm)
        if hl.type ~= hm.type then
            return hl.type < hm.type
        end
        return hl.idx < hm.idx
    end)
    return { objects = rP }
end
function fns.fn47()
    for i, child in l9:GetChildren() do
        local nQ = child:IsA("Folder") and child.Name:match("^Plot%d+$") and child:GetAttribute("OwnerId") == l4.UserId
        if nQ then
            return child
        end
    end
end
function fns.worker2()
    local qM_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local qL = math.floor(os.clock() - mf)
        if qL < 60 then
            qM_1 = qL .. "s"
        elseif qL < 3600 then
            qM_1 = string.format("%dm %ds", math.floor((qL) / (60)), qL % 60)
        else
            qM_1 = string.format("%dh %dm", math.floor((qL) / (3600)), math.floor((qL % 3600) / (60)))
        end
        Label:SetText(mz("Session time", qM_1, l1))
    end
end
function fns.onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = l4.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local rb_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if rb_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
function fns.fn95()
    return l4.Character
end
function fns.onUnload()
    Library:Unload()
end
function fns.fn110()
    local CurrentCamera = l9.CurrentCamera
    if not CurrentCamera then
        return
    end
    mq:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    mq:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    mo = tick()
end
function fns.fn116(bH)
    local Upgrades = l4:FindFirstChild("Upgrades")
    local ok = Upgrades and Upgrades:FindFirstChild(bH)
    if not ok then
        return 0
    end
    local op = if ok:IsA("BoolValue") then 1 else 0
    if op == 1 then
        return ok.Value and 1 or 0
    end
    local ok_2 = tonumber(ok.Value) or 0
    return ok_2
end
function fns.fn119()
    lw(l_, "Copied Discord invite to clipboard")
end
function fns.antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            mj(true)
        end
    end
end
function fns.fn128()
    local p4 = (lY("MaxZone", 1))
    local qb = if p4 then 1 else 0
    local p9 = 258 * qb + 1915 * (1 - qb)
    local qa = 1255 * qb + 2159 * (1 - qb)
    if not ((p9 * 3951 + qa * 3940 + p9 * qa) % 16777213 == 6287848) then
        p4 = 1
    end
    local p5 = p4
    local p4_1 = lQ()
    local p6 = p4_1
    if p6 then
        local p7 = p4_1:GetAttribute("Zone") or 1
        p6 = p7
    end
    if (p6 or 1) ~= p5 then
        ms:FireServer(p5)
    end
end
function fns.fn130()
    local name
    for k, v in me do
        if ma(v.name) then
            name = v.name
        end
    end
    if not name then
        return
    end
    local o0 = lY("EquippedSword", "Blade") or "Blade"
    if o0 == name then
        return
    end
    ln:FireServer(name)
end
function fns.fn135()
    if not Toggles.Fly.Value then
        local rv = mi()
        if rv then
            rv.PlatformStand = false
        end
    end
end
function fns.fn136()
    local Shards = l4:FindFirstChild("Shards")
    local nF = Shards and tonumber(Shards.Value)
    return nF or 0
end
function fns.fn137(dU)
    local qe = (dU:FindFirstChild("HumanoidRootPart"))
    local qi = if qe then 1 else 0
    local qg = 3155 * qi + 992 * (1 - qi)
    local qh = 622 * qi + 3774 * (1 - qi)
    if not ((qg * 1362 + qh * 1048 + qg * qh) % 16777213 == 6911376) then
        qe = dU.PrimaryPart
    end
    return qe
end
function fns.fn145(aM, aN)
    local attr = l4:GetAttribute(aM)
    if attr == nil then
        return aN
    end
    return attr
end
function fns.fn178(aB)
    local nt = Toggles[aB]
    return nt ~= nil and nt.Value == true
end
function fns.fn198()
    local qE_1
    local qD_1
    if identifyexecutor then
        qE_1, qD_1 = identifyexecutor()
        local qF = qE_1 ~= ""
        local qG = type(qE_1) == "string" and qF
        if qG then
            local qF_1 = type(qD_1) == "string" and qD_1 ~= "" and qE_1 .. " " .. qD_1
            lB = qF_1 or qE_1
        end
    end
end
function fns.fn234()
    local pk = lY("ResearchActive", "") or ""
    if pk == "" then
        return true
    elseif lY("PassSecondScientist", false) then
        local pk_1 = lY("ResearchActive2", "") or ""
        return pk_1 == ""
    else
        return false
    end
end
function fns.onInputChanged(fG)
    local UserInputType = fG.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        mv = tick()
    end
end
function fns.onCopyJoinScript_JobID()
    local eG = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, lc)
    lw(eG, "Copied join script to clipboard")
end
function fns.worker4()
    while not Library.Unloaded do
        task.wait(0.45)
        if mF("AutoMerge") then
            pcall(la)
        end
    end
end
function fns.fn307(ha, hb)
    local Type = hb.Type
    if Type == "Toggle" then
        return { idx = ha, type = "Toggle", value = hb.Value == true }
    elseif Type == "Slider" then
        return { idx = ha, type = "Slider", value = tostring(hb.Value) }
    elseif Type == "Dropdown" then
        return { idx = ha, type = "Dropdown", multi = hb.Multi == true, value = hb.Value }
    elseif Type == "Input" then
        local rJ = hb.Value or ""
        return { idx = ha, type = "Input", text = tostring(rJ) }
    elseif Type == "ColorPicker" then
        return { idx = ha, type = "ColorPicker", value = hb.Value:ToHex(), transparency = hb.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = ha,
            type = "KeyPicker",
            mode = hb.Mode,
            key = hb.Value,
            modifiers = hb.Modifiers,
            toggled = hb.Toggled
        }
    else
        return nil
    end
end
function fns.onCopyVenmoLink()
    lw(lx, "Copied Venmo link")
end
function fns.fn328()
    local Coins = l4:FindFirstChild("Coins")
    local nC = Coins and tonumber(Coins.Value)
    return nC or 0
end
local function fn343(dX, dY)
    local qj = lQ()
    local qk = qj and qj:FindFirstChild("ActiveEnemies")
    if not qk then
        return nil, math.huge
    end
    local qk_1 = nil
    local ql = dY
    for i, child in qk:GetChildren() do
        local qj_2 = child:IsA("Model") and le(child)
        if qj_2 then
            local qj_3 = mB(child)
            if qj_3 then
                local Magnitude = (qj_3.Position - dX).Magnitude
                if Magnitude <= ql then
                    qk_1 = qj_3
                    ql = Magnitude
                end
            end
        end
    end
    return qk_1, ql
end
local function fn347(c_)
    return lY("Research" .. c_, false) == true
end
local function onExportConfigToClipboard()
    local sf_1
    local se_1
    se_1, sf_1 = pcall(mk.JSONEncode, mk, lM())
    if not se_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local se_2 = setclipboard
    local sk = if se_2 then 1 else 0
    local si = 3597 * sk + 3681 * (1 - sk)
    local sj = 1524 * sk + 3067 * (1 - sk)
    if not ((si * 2168 + sj * 919 + si * sj) % 16777213 == 14680680) then
        se_2 = toclipboard
    end
    local sg = se_2
    local se_3 = type(sg) ~= "function" or not pcall(sg, sf_1)
    if se_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function fn357()
    local Hearts = l4:FindFirstChild("Hearts")
    local nI = Hearts and tonumber(Hearts.Value)
    return nI or 0
end
local function fn359()
    pcall(function()
        connection:Disconnect()
    end)
    pcall(function()
        connection2:Disconnect()
    end)
    mj(false)
    local sy = mi()
    if sy then
        sy.PlatformStand = false
        sy.WalkSpeed = 16
    end
end
local function onCopySolanaAddress()
    lw(lH, "Copied Solana address")
end
local function onCopyBitcoinAddress()
    lw(lT, "Copied Bitcoin address")
end
local function fn433(dR)
    local Humanoid = dR:FindFirstChildOfClass("Humanoid")
    if Humanoid then
        return Humanoid.Health > 0
    end
    return true
end
local function fn443()
    local qu = l2()
    local qv = mi()
    local qv_1
    local qw = not qu or not qv or qv.Health <= 0
    local qw_1
    if qw then
        return
    end
    qw_1, qv_1 = ml(qu.Position, mh("KillAuraRange", 80))
    if not qw_1 then
        return
    end
    local qx = Vector3.new(qw_1.Position.X, qu.Position.Y, qw_1.Position.Z)
    if qv_1 > 8 then
        local qv_2 = Vector3.new(qw_1.Position.X - qu.Position.X, 0, qw_1.Position.Z - qu.Position.Z)
        if qv_2.Magnitude > 0.05 then
            local qy = qw_1.Position - qv_2.Unit * 5
            qu.CFrame = CFrame.lookAt(Vector3.new(qy.X, qu.Position.Y, qy.Z), qx)
        end
    elseif (qx - qu.Position).Magnitude > 0.05 then
        qu.CFrame = CFrame.lookAt(qu.Position, qx)
    end
    local qu_1 = lY("UpPlayerSwing", 0) or 0
    local qv_3 = 0.45 / (1 + qu_1)
    local qu_2 = os.clock()
    if qu_2 - lo < qv_3 then
        return
    end
    lo = qu_2
    SwordSwingEvent:FireServer()
end
local function fn451(bP, bQ)
    if bQ.Repeat then
        return lN.repeatCost(bQ, lt(bP))
    end
    return bQ.Cost or 0
end
local function fn483()
    mj(Toggles.AntiGameplayPause.Value)
end
local function fn522(ab, ac)
    return string.format('<font color="%s">%s</font>', ac, ab)
end
local function onCopyPayPalLink()
    lw(lC, "Copied PayPal link")
end
local function fn557(g4, g5)
    local rF_1 = (g4 == "Toggle" and Toggles or Options)[g5]
    local rE_2 = type(rF_1) == "table" and rF_1.Type == g4
    return rE_2 and rF_1 or nil
end
local function onImportConfigFromClipboardTex()
    local sn_1
    local sl = Options.SaveManager_ImportSource.Value or ""
    local sl_1
    local sm = tostring(sl):match("^%s*(.-)%s*$")
    if sm == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    sl_1, sn_1 = pcall(mk.JSONDecode, mk, sm)
    local sm_1 = not sl_1 or type(sn_1) ~= "table" or type(sn_1.objects) ~= "table"
    if sm_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local sl_2 = 0
    for i, v in ipairs(sn_1.objects) do
        if mt(v) then
            sl_2 += 1
        end
    end
    if sl_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local sn_2 = sl_2 == 1 and ""
    local sx = if sn_2 then 1 else 0
    local sv = 3558 * sx + 1699 * (1 - sx)
    local sw = 931 * sx + 2730 * (1 - sx)
    if not ((sv * 2050 + sw * 703 + sv * sw) % 16777213 == 11260891) then
        sn_2 = "s"
    end
    Library:Notify(("Imported %d setting%s"):format(sl_2, sn_2), 6)
end
local function worker6()
    while not Library.Unloaded do
        task.wait(0.05)
        if mF("SwordKillAura") then
            pcall(ll)
        end
    end
end
local function fn588(fc)
    local DiscordGroup = fc:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = lm })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = lm })
end
local function fn605(bi)
    local nZ_1
    local nY_1
    nY_1, nZ_1 = UnitConfig.parseKey(bi)
    local n_ = UnitConfig.Units[nY_1]
    if not n_ then
        return 0
    end
    local nY_2 = nZ_1 and UnitConfig.Enchants[nZ_1]
    local n2_1 = n_.Damage * (nY_2 and nY_2.DamageMult or 1) / (n_.SwingEvery / (nY_2 and nY_2.SpeedMult or 1))
    local nY_5 = n_.EffMult
    local n6 = if nY_5 then 1 else 0
    local n4 = 735 * n6 + 1046 * (1 - n6)
    local n5 = 3984 * n6 + 3406 * (1 - n6)
    if not ((n4 * 3982 + n5 * 2886 + n4 * n5) % 16777213 == 575621) then
        nY_5 = 1
    end
    return n2_1 * nY_5
end
local function fn644(aG, aH)
    local nw = Options[aG]
    local nx = nw and tonumber(nw.Value)
    return nx or aH
end
local function onRscripts()
    lw(lW, "Copied Rscripts profile to clipboard")
end
local function fn665(bv)
    if bv == "Blade" then
        return true
    end
    local oa = lY("OwnedSwordsList", "") or ""
    for k in oa:gmatch("[^|]+") do
        if k == bv then
            return true
        end
    end
    return false
end
local function fn678()
    local o8 = lD()
    local o9 = lp()
    for k, v in lN.Upgrades do
        if not (v.Auto or v.Hub) then
            local pa_1 = v.NeedsGlitched and lY("ResearchGlitched", false) ~= true
            if not pa_1 then
                if not not k8(v) then
                    local pa_2 = not v.Repeat
                    if pa_2 ~= false then
                        pa_2 = lZ(k)
                    end
                    if not pa_2 then
                        local pa_3 = mr(k, v)
                        if pa_3 <= (v.Tree == "Shards" and o9 or o8) then
                            lk:FireServer(k)
                            if v.Tree == "Shards" then
                                o9 -= pa_3
                            else
                                o8 -= pa_3
                            end
                        end
                    end
                end
            end
        end
    end
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local rj_1 = mi()
        if rj_1 then
            rj_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn687()
    local n7 = lY("UpSlots", 0) or 0
    local n8 = 1 + n7
    if lY("ResearchSlot7", false) then
        n8 += 1
    end
    if lY("ResearchSlot8", false) then
        n8 += 1
    end
    return n8
end
local function fn690(bM)
    local Requires = bM.Requires
    local ot = Requires == ""
    local ou = type(Requires) ~= "string" or ot
    if ou then
        return true
    end
    return lZ(Requires)
end
local function worker3()
    while not Library.Unloaded do
        if mF("AutoRoll") then
            pcall(li)
            task.wait(mh("RollDelay", 0.15))
        else
            task.wait(0.2)
        end
    end
end
local function fn717()
    for k, v in lF.Tiers do
        local id = v.id
        if not (lY("IndexClaim_" .. id, false) == true) then
            local pM = 0
            for k, v in lF.unitsFor(id) do
                if lO(v, id) then
                    pM += 1
                end
            end
            if (v.Req or 0) <= pM then
                mx:FireServer(id)
            end
        end
    end
end
local function onOnClientEvent(bS)
    if type(bS) == "table" then
        l5 = bS
    elseif type(bS) == "string" then
        l5[bS] = true
    end
end
local function onCopyUSDTAddress()
    lw(lL, "Copied USDT address")
end
local function fn750()
    lv:FireServer()
end
local function fn754()
    local nK = mu()
    local nL = nK and nK:FindFirstChildOfClass("Humanoid")
    return nL
end
local function onCopyEthereumAddress()
    lw(lP, "Copied Ethereum address")
end
local function fn798(ae, af, ag)
    return string.format("<b>%s</b> %s %s", ae, lb("-", "#5a6070"), lb(af, ag))
end
local function fn811(U, V)
    if setclipboard then
        setclipboard(U)
    elseif toclipboard then
        toclipboard(U)
    end
    Library:Notify(V)
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local q2 = tick() - mv
            local q3 = tick() - mo
            if q2 >= 300 and q3 >= 60 then
                pcall(l3)
            else
                if q2 < 300 and q3 >= 300 then
                    pcall(l3)
                end
            end
        end
    end
end
local function fn816()
    local p0 = lY("MaxZone", 1) or 1
    local p0_1 = p0 + 1
    local p1_1 = lz[p0_1]
    if type(p1_1) ~= "table" then
        return
    end
    local p2 = p1_1.Price or 0
    if p2 <= lD() then
        ms:FireServer(p0_1)
    end
end
local function fn819(bz)
    local og = lN.Upgrades[bz]
    if not og then
        return false
    elseif og.Auto then
        return true
    else
        local Upgrades = l4:FindFirstChild("Upgrades")
        local oh = Upgrades and Upgrades:FindFirstChild(bz)
        if not oh then
            return false
        elseif oh:IsA("BoolValue") then
            return oh.Value == true
        else
            local oh_1 = tonumber(oh.Value) or 0
            return oh_1 > 0
        end
    end
end
local function worker5()
    while not Library.Unloaded do
        task.wait(1)
        if mF("AutoEquipTroops") then
            pcall(my)
        end
        if mF("AutoEquipSword") then
            pcall(mn)
        end
    end
end
local function worker()
    l4:WaitForChild("Coins", 60)
    task.wait(1)
    mC:FireServer()
end
local function onRenderStepped(gn)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local ro_1 = mi()
        if ro_1 then
            ro_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local ro_3 = l2()
        local rp = mi()
        if ro_3 and rp then
            rp.PlatformStand = true
            local rp_1 = Vector3.zero
            if mw:IsKeyDown(Enum.KeyCode.W) then
                rp_1 = rp_1 + CurrentCamera2.CFrame.LookVector
            end
            if mw:IsKeyDown(Enum.KeyCode.S) then
                rp_1 = rp_1 - CurrentCamera2.CFrame.LookVector
            end
            if mw:IsKeyDown(Enum.KeyCode.A) then
                rp_1 = rp_1 - CurrentCamera2.CFrame.RightVector
            end
            if mw:IsKeyDown(Enum.KeyCode.D) then
                rp_1 = rp_1 + CurrentCamera2.CFrame.RightVector
            end
            if mw:IsKeyDown(Enum.KeyCode.Space) then
                rp_1 = rp_1 + Vector3.new(0, 1, 0)
            end
            if mw:IsKeyDown(Enum.KeyCode.LeftControl) then
                rp_1 = rp_1 - Vector3.new(0, 1, 0)
            end
            ro_3.Velocity = Vector3.zero
            if rp_1.Magnitude > 0 then
                ro_3.CFrame = ro_3.CFrame + rp_1.Unit * Options.FlySpeed.Value * gn
            end
        end
    end
end
local function fn853()
    MergeAll:FireServer()
end
local function fn860()
    if not Toggles.WalkSpeedEnabled.Value then
        local rx = mi()
        if rx then
            rx.WalkSpeed = 16
        end
    end
end
local function fn887(bX, bY)
    local oz = lF.keyFor(bX, bY)
    if l5[oz] then
        return true
    end
    local UnitCounts = l4:FindFirstChild("UnitCounts")
    local oB = UnitCounts ~= nil and UnitCounts:FindFirstChild(oz) ~= nil
    return oB
end
local function onCopyLitecoinAddress()
    lw(lX, "Copied Litecoin address")
end
local function fn905()
    local nN = mu()
    local nO = nN and nN:FindFirstChild("HumanoidRootPart")
    return nO
end
local function fn908()
    local pn = os.time()
    local po = lY("ResearchActive", "") or ""
    local po_1 = (lY("ResearchEndsAt", 0))
    local py = if po_1 then 1 else 0
    local pw = 1775 * py + 121 * (1 - py)
    local px = 4069 * py + 1246 * (1 - py)
    if not ((pw * 2209 + px * 3588 + pw * px) % 16777213 == 8965809) then
        po_1 = 0
    end
    local pq = po_1
    if po ~= "" and pq > 0 and pn >= pq then
        ResearchComplete:FireServer(po)
    end
    local po_3 = lY("ResearchActive2", "") or ""
    local po_4 = lY("ResearchEndsAt2", 0) or 0
    if po_3 ~= "" and po_4 > 0 and pn >= po_4 then
        ResearchComplete:FireServer(po_3)
    end
    local pn_1 = lY("ScientistLevel", 0) or 0
    if pn_1 < lJ.Scientist.MaxLevel then
        local pn_3 = lJ.Scientist.Costs[pn_1 + 1]
        local po_7 = type(pn_3) == "number" and pn_3 <= lD()
        if po_7 then
            lf:FireServer()
        end
    end
    if not l7() then
        return
    end
    local pn_4 = lY("Rebirths", 0) or 0
    local pn_5 = lD()
    for k, v in mc do
        local id = v.id
        local ps = lJ.Projects[id]
        if not not ps then
            if not mg(id) then
                if not (po == id or po_3 == id) then
                    local pt_1 = ps.Requires and not mg(ps.Requires)
                    if not pt_1 then
                        local pt_2 = not ps.Starter
                        if pt_2 ~= false then
                            pt_2 = pn_4 < (lJ.RequireRebirths or 1)
                        end
                        if not pt_2 then
                            if (ps.Price or 0) <= pn_5 then
                                ResearchStart:FireServer(id)
                                return
                            end
                        end
                    end
                end
            end
        end
    end
end
local function fn915()
    if mD then
        return
    end
    mD = true
    local oD = {}
    local UnitCounts = l4:FindFirstChild("UnitCounts")
    if UnitCounts then
        for i, child in UnitCounts:GetChildren() do
            if child.Value > 0 then
                oD[#oD + 1] = child.Name
            end
        end
    end
    if #oD == 0 then
        mD = false
        return
    end
    table.sort(oD, function(cg, ch)
        return ls(ch) < ls(cg)
    end)
    local oE_1 = 0
    local oF = {}
    local oG = mp()
    for k, v in oD do
        if UnitConfig.Units[UnitConfig.parseKey(v)] then
            oF[v] = true
            oE_1 += 1
            if oG <= oE_1 then
                break
            end
        end
    end
    local oD_1 = lQ()
    local oE_2 = oD_1 and oD_1:FindFirstChild("ActiveUnits")
    local oD_2 = {}
    if oE_2 then
        for i, child in oE_2:GetChildren() do
            oD_2[child.Name] = true
            if not oF[child.Name] then
                EquipUnit:FireServer(child.Name)
            end
        end
    end
    task.wait(0.25)
    for k in oF do
        if not oD_2[k] then
            EquipUnit:FireServer(k)
        end
    end
    mD = false
end
local function worker7()
    while not Library.Unloaded do
        task.wait(1)
        if mF("AutoUpgradeTree") then
            pcall(lU)
        end
        if mF("AutoResearch") then
            pcall(lV)
        end
        if mF("AutoRebirth") then
            pcall(ly)
        end
        if mF("AutoClaimIndex") then
            pcall(lj)
        end
        if mF("AutoBuyZones") then
            pcall(l8)
        end
        if mF("AutoSwitchZone") then
            pcall(lE)
        end
    end
end
k8 = nil
ResearchComplete = nil
la = nil
lb = nil
lc = nil
ld = nil
le = nil
lf = nil
Label = nil
ResearchStart = nil
li = nil
lj = nil
lk = nil
ll = nil
lm = nil
ln = nil
lo = nil
lp = nil
connection2 = nil
EquipUnit = nil
ls = nil
lt = nil
MergeAll = nil
lv = nil
lw = nil
lx = nil
ly = nil
lz = nil
Options = nil
lB = nil
lC = nil
lD = nil
lE = nil
lF = nil
Toggles = nil
lH = nil
connection = nil
lJ = nil
SaveManager = nil
lL = nil
lM = nil
lN = nil
lO = nil
lP = nil
lQ = nil
UnitConfig = nil
Library = nil
lT = nil
lU = nil
lV = nil
lW = nil
lX = nil
lY = nil
lZ = nil
l_ = nil
l0 = nil
l1 = nil
l2 = nil
l3 = nil
l4 = nil
l5 = nil
CurrentCamera2 = nil
l7 = nil
l8 = nil
l9 = nil
ma = nil
mc = nil
me = nil
mf = nil
mg = nil
mh = nil
mi = nil
mj = nil
mk = nil
ml = nil
SwordSwingEvent = nil
mn = nil
mo = nil
mp = nil
mq = nil
mr = nil
ms = nil
mt = nil
mu = nil
mv = nil
mw = nil
mx = nil
my = nil
mz = nil
mB = nil
mC = nil
mD = nil
mE = nil
mF = nil
local CoreGui, md
CoreGui = nil
md = nil
local mA
sC_12, sC_7, sC_1, mw, mq, mk, md, CoreGui, l9, l4, sC_15, l_, lW, UnitConfig, lN, lJ, lF, lz, lv, MergeAll, EquipUnit, ln, lk, ResearchStart, lf, ResearchComplete, mE, mC, mx, ms, SwordSwingEvent, me, mc = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local sC_22 = 66
repeat
    sC_9 = (sC_22 * 5 + 5) % 12 + 1
    if sC_9 <= 6 then
        if sC_9 <= 3 then
            if sC_9 <= 2 then
                if sC_9 <= 1 then
                    local tz = bit32.rrotate(bit32.bxor(bit32.lrotate(sC_22, 9), string.byte(tostring(mC))), 19)
                    if bit32.bxor(bit32.lrotate(bit32.bxor(tz, 7423249), 18), 340001221) == bit32.lrotate(tz, 18) then
                        sC_7 = game:GetService("ReplicatedStorage")
                    else
                        ms = game:GetService("ReplicatedStorage")
                    end
                    sC_22 = (sC_22 + 29) % 96
                else
                    local tg = bit32.rrotate(bit32.bxor(bit32.lrotate(sC_22, 13), string.byte(tostring(lN))), 4)
                    if bit32.bxor(bit32.lrotate(bit32.bxor(tg, 3634942392), 28), 2374667547) == bit32.lrotate(tg, 28) then
                        sC_1 = game:GetService("RunService")
                        mw = game:GetService("UserInputService")
                        mq = game:GetService("VirtualUser")
                        mk = game:GetService("HttpService")
                        md = game:GetService("GuiService")
                    else
                        mk = game:GetService("RunService")
                        sC_1 = game:GetService("UserInputService")
                        md = game:GetService("VirtualUser")
                        mq = game:GetService("HttpService")
                        mw = game:GetService("GuiService")
                    end
                    sC_22 = (sC_22 + 53) % 96
                end
            else
                sC_17 = {
                    "kfdnydoif",
                    "jetidnr",
                    "mpdpchrestz",
                    "rvyhqzwko",
                    "meuicfr",
                    "wesa",
                    "tyyiaas",
                    "xkdowxafbxi",
                    "busrjaj",
                    "yvqabtkwofr",
                    "tiltohi",
                    "ucjjmes",
                    "ctdfyi",
                    "qnku"
                }
                if sC_17[(sC_22 * 93 + 17) % 14 + 1] < sC_17[(sC_22 * 93 + 17) % 14 + 1] then
                    l4 = game:GetService("CoreGui")
                    sC_15 = game:GetService("Workspace")
                    sC_12 = CoreGui.LocalPlayer
                    l9 = "Roll an Army"
                else
                    CoreGui = game:GetService("CoreGui")
                    l9 = game:GetService("Workspace")
                    l4 = sC_12.LocalPlayer
                    sC_15 = "Roll an Army"
                end
                sC_22 = (sC_22 + 89) % 96
            end
        elseif sC_9 <= 5 then
            if sC_9 <= 4 then
                local tK = bit32.rrotate(bit32.bxor(bit32.lrotate(sC_22, 2), string.byte(tostring(UnitConfig))), 20)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(tK, 3165701635), 563644178), (bit32.bxor(bit32.band(tK, 1129265660), 75485433))), 563644178), 75485433) ~= tK then
                    lW = "https://discord.gg/K7Qxnxkk46"
                    l_ = "https://discord.gg/K7Qxnxkk46"
                else
                    l_ = "https://discord.gg/K7Qxnxkk46"
                    lW = "https://discord.gg/K7Qxnxkk46"
                end
                sC_22 = (sC_22 + 89) % 96
            else
                sC_17 = (vector.create((sC_22 * 1 + 1) % 11 + 1, (sC_22 * 10 + 3) % 13 + 1, (sC_22 * 8 + 15) % 17 + 1))
                sC_4 = (vector.create((sC_22 * 1 + 8) % 11 + 1, (sC_22 * 5 + 4) % 13 + 1, (sC_22 * 2 + 16) % 17 + 1))
                sC_11 = (vector.create((sC_22 * 2 + 9) % 11 + 1, (sC_22 * 8 + 13) % 13 + 1, (sC_22 * 7 + 2) % 17 + 1))
                sC_19 = (vector.create((sC_22 * 1 + 6) % 11 + 1, (sC_22 * 7 + 8) % 13 + 1, (sC_22 * 8 + 1) % 17 + 1))
                if vector.dot(vector.cross(sC_17, sC_4), (vector.cross(sC_11, sC_19))) == vector.dot(sC_17, sC_11) * vector.dot(sC_4, sC_19) - vector.dot(sC_17, sC_19) * vector.dot(sC_4, sC_11) then
                    UnitConfig = require(sC_7:WaitForChild("UnitConfig"))
                    lN = require(sC_7:WaitForChild("UpgradeConfig"))
                    lJ = require(sC_7:WaitForChild("ResearchConfig"))
                    lF = require(sC_7:WaitForChild("IndexConfig"))
                else
                    lF = require(UnitConfig:WaitForChild("UnitConfig"))
                    sC_7 = require(UnitConfig:WaitForChild("UpgradeConfig"))
                    lN = require(UnitConfig:WaitForChild("ResearchConfig"))
                    lJ = require(UnitConfig:WaitForChild("IndexConfig"))
                end
                sC_22 = (sC_22 + 41) % 96
            end
        else
            local s9 = bit32.rrotate(bit32.bxor(bit32.lrotate(sC_22, 23), string.byte(tostring(mc))), 10)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(s9, 1826329615), 2925781025), (bit32.bxor(bit32.band(s9, 2468637680), 1771299888))), 2925781025), 1771299888) == s9 then
                lz = require(sC_7:WaitForChild("ZoneConfig"))
                lv = sC_7:WaitForChild("RollRequest")
                MergeAll = sC_7:WaitForChild("MergeAll")
            else
                sC_7 = require(MergeAll:WaitForChild("ZoneConfig"))
                lz = MergeAll:WaitForChild("RollRequest")
                lv = MergeAll:WaitForChild("MergeAll")
            end
            sC_22 = (sC_22 + 29) % 96
        end
    elseif sC_9 <= 9 then
        if sC_9 <= 8 then
            if sC_9 <= 7 then
                sC_17 = (vector.create((sC_22 * 7 + 3) % 11 + 1, (sC_22 * 6 + 5) % 13 + 1, (sC_22 * 13 + 13) % 17 + 1))
                sC_4 = (vector.create((sC_22 * 1 + 6) % 11 + 1, (sC_22 * 4 + 3) % 13 + 1, (sC_22 * 8 + 16) % 17 + 1))
                sC_11 = (vector.create((sC_22 * 5 + 7) % 5 + 1, (sC_22 * 2 + 2) % 7 + 1, (sC_22 * 1 + 1) % 9 + 1))
                if math.abs((vector.angle(sC_17, sC_4, sC_11))) - math.abs((vector.angle(sC_4, sC_17, sC_11))) == 4 then
                    sC_7 = EquipUnit:WaitForChild("EquipUnit")
                else
                    EquipUnit = sC_7:WaitForChild("EquipUnit")
                end
                sC_22 = (sC_22 + 29) % 96
            else
                if (lf or not ms) and (sC_22 or not mk) and (not mk or mk or sC_22 and EquipUnit) or (not lf or lz or lz and sC_22) and ((not lz or not EquipUnit) and (lf and ms)) or not ((lf or not ms) and (sC_22 or not mk) and (not mk or mk or sC_22 and EquipUnit) or (not lf or lz or lz and sC_22) and ((not lz or not EquipUnit) and (lf and ms))) then
                    ln = sC_7:WaitForChild("EquipSwordEvent")
                    lk = sC_7:WaitForChild("BuyUpgrade")
                    ResearchStart = sC_7:WaitForChild("ResearchStart")
                    lf = sC_7:WaitForChild("ResearchScientist")
                else
                    sC_7 = ResearchStart:WaitForChild("EquipSwordEvent")
                    lf = ResearchStart:WaitForChild("BuyUpgrade")
                    lk = ResearchStart:WaitForChild("ResearchStart")
                    ln = ResearchStart:WaitForChild("ResearchScientist")
                end
                sC_22 = (sC_22 + 17) % 96
            end
        else
            if sC_22 * 4812591 + 6 + 5 <= sC_22 * 4812591 + 6 + 5 + 2 then
                ResearchComplete = sC_7:WaitForChild("ResearchComplete")
                mE = sC_7:WaitForChild("RebirthRequest")
                mC = sC_7:WaitForChild("IndexData")
                mx = sC_7:WaitForChild("IndexClaim")
                ms = sC_7:WaitForChild("ZoneSwitch")
            else
                mC = ResearchComplete:WaitForChild("ResearchComplete")
                mx = ResearchComplete:WaitForChild("RebirthRequest")
                sC_7 = ResearchComplete:WaitForChild("IndexData")
                ms = ResearchComplete:WaitForChild("IndexClaim")
                mE = ResearchComplete:WaitForChild("ZoneSwitch")
            end
            sC_22 = (sC_22 + 77) % 96
        end
    elseif sC_9 <= 11 then
        if sC_9 <= 10 then
            sC_9 = { "jquxk", "rfasinxbalq", "fdrdheygx", "mszvdwfncp", "pdszoqbb", "gbnbf", "iml" }
            local tA = sC_22
            sC_17 = sC_9[tA % 7 + 1]
            if sC_17:len() <= sC_17:gsub("(.)", "%1%1", tA % 3 % 2 + 1):len() then
                SwordSwingEvent = sC_7:WaitForChild("SwordSwingEvent")
            else
                sC_7 = SwordSwingEvent:WaitForChild("SwordSwingEvent")
            end
            sC_22 = (sC_22 + 17) % 96
        else
            sC_9 = { "rth", "hohwztikgp", "cfpsosed", "asguwrusbwl", "djifbq", "ojpsb", "yvlmver", "kxmzdnwge" }
            local tt = sC_22
            sC_17 = sC_9[tt % 8 + 1]
            if sC_17:len() <= sC_17:gsub("(.)", "%1%1", tt % 3 % 2 + 1):len() then
                me = {
                    { name = "Blade", rebirths = 0 },
                    { name = "Royal Flush", rebirths = 1 },
                    { name = "King Maker", rebirths = 2 },
                    { name = "Grave Fang", rebirths = 3 },
                    { name = "Violet Thorn", rebirths = 4 },
                    { name = "Reaper", rebirths = 5 },
                    { name = "Inferno Reaper", rebirths = 6 }
                }
                mc = {}
            else
                mc = {
                    { name = "Inferno Reaper", rebirths = 6 },
                    { name = "Blade", rebirths = 0 },
                    { name = "Royal Flush", rebirths = 1 },
                    { name = "King Maker", rebirths = 2 },
                    { name = "Reaper", rebirths = 5 },
                    { name = "Grave Fang", rebirths = 3 },
                    { name = "Violet Thorn", rebirths = 4 }
                }
                me = {}
            end
            sC_22 = (sC_22 + 89) % 96
        end
    else
        if (sC_22 * 2 + 8) * 10 % 3 == ((sC_22 * 2 + 8) * 10 + 0) % 3 then
            sC_12 = game:GetService("Players")
        else
            mw = game:GetService("Players")
        end
        sC_22 = (sC_22 + 65) % 96
    end
until (sC_22 * 7 + 43) % 96 == 73
for k, v in lJ.Projects do
    sC_12 = #mc + 1
    sC_22 = v.Order or 0
    mc[sC_12] = { id = k, order = sC_22 }
end
sC_7 = 2
repeat
    sC_12 = {
        "zrjbm",
        "gsguuzwnlabg",
        "drtlikaeyt",
        "gjskod",
        "mmdatdlop",
        "iklrub",
        "pfn",
        "oyxtwsifzdql",
        "czixpak",
        "dsjhxq",
        "zsnzzouwpoz",
        "qbgdyrb",
        "phuryariou",
        "ldnyacyk",
        "cmgcrbehp"
    }
    if sC_12[(sC_7 * 43 + 32) % 15 + 1] <= sC_12[(sC_7 * 43 + 32) % 15 + 1] then
        table.sort(mc, fns.fn15)
    else
        table.sort(mc, fns.fn15)
    end
    sC_7 = (sC_7 + 0) % 4
until (sC_7 * 3 + 2) % 4 == 0
Library, SaveManager, Toggles, Options, l1, lX, lT, lP, lL, lH, lC, lx, l5, mD, lo, lB, Label, lc, sC_4, lw, lm, lb, mz, mF, mh, lY, lD, lp, ld, mu, mi, l2, lQ, ls, mp, ma, lZ, lt, k8, mr, lO, li, la, my, mn, lU, mg, l7, lV, ly, lj, l8, lE, le, mB, ml, ll = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
lw = fn811
lm = fns.fn119
lb = fn522
mz = fn798
local sC_5 = "#7fd47f"
local sC_18 = "#6ec1ff"
l1 = "#e8a34d"
local sC_10 = "#8b93a3"
lX = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
lT = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
lP = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
lL = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
lH = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
lC = ""
lx = ""
local sC_2 = "#345d9d"
local sC_16 = "#f7931a"
local sC_8 = "#627eea"
local sC_23 = "#26a17b"
local sC_14 = "#14f195"
sC_19 = "#0070ba"
sC_11 = "#008cff"
mF = fns.fn178
mh = fn644
lY = fns.fn145
lD = fns.fn328
lp = fns.fn136
ld = fn357
mu = fns.fn95
mi = fn754
l2 = fn905
lQ = fns.fn47
ls = fn605
mp = fn687
ma = fn665
lZ = fn819
lt = fns.fn116
k8 = fn690
mr = fn451
l5 = {}
mC.OnClientEvent:Connect(onOnClientEvent)
task.spawn(worker)
lO = fn887
li = fn750
la = fn853
mD = false
my = fn915
mn = fns.fn130
lU = fn678
mg = fn347
l7 = fns.fn234
lV = fn908
ly = fns.fn8
lj = fn717
l8 = fn816
lE = fns.fn128
le = fn433
mB = fns.fn137
ml = fn343
lo = 0
ll = fn443
sC_22 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = l_, Copyable = true }, "|", sC_15 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local mZ = {
    Info = sC_22:AddTab("Info", "info"),
    Main = sC_22:AddTab("Main", "swords"),
    Player = sC_22:AddTab("Player", "person-standing"),
    Settings = sC_22:AddTab("Settings", "settings")
}
do
    mZ.Roll = mZ.Main:AddSubTab("Roll", "dices")
    mZ.Army = mZ.Main:AddSubTab("Army", "shield")
    mZ.Progress = mZ.Main:AddSubTab("Progress", "sprout")
    mZ.Zones = mZ.Main:AddSubTab("Zones", "map")
    lB = "Unknown"
    pcall(fns.fn198)
    sC_12 = mZ.Info:AddLeftGroupbox("Account", "circle-user")
    sC_12:AddLabel(mz("User", l4.Name, sC_5), true)
    sC_12:AddLabel(mz("Status", "Keyless", sC_5), true)
    sC_12:AddLabel(mz("Executor", lB, sC_5), true)
    sC_6 = mZ.Info:AddLeftGroupbox("Game Info", "gamepad-2")
    sC_6:AddLabel(lb(sC_15 .. " [" .. tostring(game.PlaceId) .. "]", sC_18), true)
    sC_6:AddLabel(mz("Place ID", tostring(game.PlaceId), sC_18), true)
    Label = sC_6:AddLabel(mz("Session time", "0s", l1), true)
end
lc = tostring(game.JobId)
if (lY and not sC_22 or (not lY or not lY)) and ((lY or sC_22) and (not lY and sC_18)) or not ((lY and not sC_22 or (not lY or not lY)) and ((lY or sC_22) and (not lY and sC_18))) then
    sC_4 = #lc > 18
else
    lc = #sC_4 > 18
end
if sC_4 then
    sC_12 = 1
    repeat
        local s6 = bit32.rrotate(bit32.bxor(bit32.lrotate(sC_12, 22), string.byte(tostring(sC_12))), 16)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(s6, 2640011819), 2786721394), (bit32.bxor(bit32.band(s6, 1654955476), 1725801451))), 2786721394), 1725801451) == s6 then
            sC_4 = string.sub(lc, 1, 18) .. "..."
        else
            lc = string.sub(sC_4, 1, 18) .. "..."
        end
        sC_12 = (sC_12 + 5) % 8
    until (sC_12 * 7 + 0) % 8 == 2
end
sC_12 = sC_4 or lc
mf = nil
local m2 = sC_12
sC_6:AddLabel(mz("Server", m2, sC_10), true)
sC_6:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
mf = os.clock()
task.spawn(fns.worker2)
local ScriptsGroup = mZ.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(lb("Included in this hub", sC_10), true)
ScriptsGroup:AddLabel(lb(sC_15, sC_18), true)
sC_4 = mZ.Info:AddRightGroupbox("Features", "list")
sC_4:AddLabel(lb("Auto Roll / Merge", sC_18), true)
sC_4:AddLabel(lb("Auto Equip", l1), true)
sC_4:AddLabel(lb("Auto Upgrade / Research", sC_5), true)
sC_4:AddLabel(lb("Auto Rebirth / Index / Zones", sC_18), true)
sC_4:AddLabel(lb("Kill Aura", l1), true)
sC_4:AddLabel(lb("Player Utilities", sC_10), true)
sC_17 = mZ.Info:AddRightGroupbox("Socials", "link")
sC_17:AddButton({ Text = "Discord", Func = lm })
sC_17:AddButton({ Text = "Rscripts", Func = onRscripts })
sC_9 = mZ.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
sC_9:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
sC_9:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
sC_9:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
sC_9:AddButton({ Text = "Copy Discord Invite", Func = lm })
sC_7 = mZ.Info:AddRightGroupbox("Donations", "heart")
sC_7:AddLabel(lb("All donations are optional but appreciated.", l1), true)
sC_7:AddLabel(lb("If you donate you get a special role, just PING after you donate.", sC_5), true)
sC_7:AddDivider()
sC_7:AddLabel(lb("LTC / Litecoin", sC_2), true)
sC_7:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
sC_7:AddLabel(lb("BTC / Bitcoin", sC_16), true)
sC_7:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
sC_7:AddLabel(lb("ETH / Ethereum", sC_8), true)
sC_7:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
sC_7:AddLabel(lb("USDT", sC_23), true)
sC_7:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
sC_7:AddLabel(lb("Solana", sC_14), true)
sC_7:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
sC_7:AddLabel(lb("PayPal", sC_19), true)
sC_7:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
sC_7:AddLabel(lb("Venmo", sC_11), true)
sC_7:AddButton({ Text = "Copy Venmo Link", Func = fns.onCopyVenmoLink })
sC_7:AddDivider()
sC_7:AddLabel(lb("Don't have any of the listed currencies but still wanna donate?", sC_10), true)
sC_7:AddLabel(lb("DM me and we'll work something out.", sC_18), true)
local FaqGroup = mZ.Info:AddRightGroupbox("FAQ", "circle-help")
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
for k, v in mZ do
    sC_12 = v ~= mZ.Info and v ~= mZ.Main
    if sC_12 then
        fn588(v)
    end
end
mv, mo, connection, connection2, CurrentCamera2, l3, mj, mA, l0, lM, mt = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
sC_19 = mZ.Roll:AddLeftGroupbox("Roll", "dices")
sC_19:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
sC_19:AddSlider("RollDelay", { Text = "Roll Delay", Default = 0.15, Min = 0.05, Max = 1, Rounding = 2 })
sC_4 = mZ.Roll:AddRightGroupbox("Merge", "layers")
sC_4:AddToggle("AutoMerge", { Text = "Auto Merge", Default = false })
sC_17 = mZ.Army:AddLeftGroupbox("Equip", "swords")
sC_17:AddToggle("AutoEquipTroops", { Text = "Auto Equip Best Troops", Default = false })
sC_17:AddToggle("AutoEquipSword", { Text = "Auto Equip Best Sword", Default = false })
sC_9 = mZ.Army:AddRightGroupbox("Combat", "swords")
sC_9:AddToggle("SwordKillAura", { Text = "Sword Kill Aura", Default = false })
sC_9:AddSlider("KillAuraRange", { Text = "Kill Aura Range", Default = 80, Min = 10, Max = 200, Rounding = 0 })
sC_15 = mZ.Progress:AddLeftGroupbox("Upgrades", "git-branch")
sC_15:AddToggle("AutoUpgradeTree", { Text = "Auto Upgrade Tree", Default = false })
sC_15:AddToggle("AutoResearch", { Text = "Auto Research", Default = false })
sC_7 = mZ.Progress:AddRightGroupbox("Progress", "trophy")
sC_7:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
sC_7:AddToggle("AutoClaimIndex", { Text = "Auto Claim Index", Default = false })
sC_22 = mZ.Zones:AddLeftGroupbox("Zones", "map")
sC_22:AddToggle("AutoBuyZones", { Text = "Auto Buy Zones", Default = false })
sC_22:AddToggle("AutoSwitchZone", { Text = "Auto Switch Highest Zone", Default = false })
sC_12 = mZ.Player:AddLeftGroupbox("Movement", "footprints")
sC_12:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
sC_12:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
sC_12:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
sC_12:AddToggle("NoClip", { Text = "NoClip", Default = false })
sC_12:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
sC_23 = mZ.Player:AddRightGroupbox("Fly", "feather")
sC_23:AddToggle("Fly", { Text = "Fly", Default = false })
sC_23:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
sC_14 = mZ.Settings:AddLeftGroupbox("Menu")
sC_14:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
sC_14:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
sC_14:AddButton({ Text = "Unload", Func = fns.onUnload })
mv = tick()
if ((l3 or false) and (not l3 or not l3) or (sC_15 and 4 or (sC_15 or not sC_15))) and (not l3 or not sC_15) and ((not sC_15 or not l3) and (not l3 or 4) or 4 or (l3 or l3 or (not l3 or not l3) or l3 and sC_15 and false)) and not (((l3 or false) and (not l3 or not l3) or (sC_15 and 4 or (sC_15 or not sC_15))) and (not l3 or not sC_15) and ((not sC_15 or not l3) and (not l3 or 4) or 4 or (l3 or l3 or (not l3 or not l3) or l3 and sC_15 and false))) then
    l0 = tick()
else
    mo = tick()
end
pcall(function()
    for i, v in ipairs(getconnections(l4.Idled)) do
        local qU = v
        pcall(function()
            qU:Disable()
        end)
    end
end)
l3 = fns.fn110
connection = mw.InputBegan:Connect(fns.onInputBegan)
connection2 = mw.InputChanged:Connect(fns.onInputChanged)
task.spawn(antiAfkLoop)
mj = function(fV)
    pcall(function()
        md:SetGameplayPausedNotificationEnabled(not fV)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not fV
        end
    end)
    if not fV then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(l4, "GameplayPaused", false)
        else
            l4.GameplayPaused = false
        end
    end)
end
Toggles.AntiGameplayPause:OnChanged(fn483)
task.spawn(fns.antiGameplayPauseLoop)
sC_1.Stepped:Connect(fns.onStepped)
mw.JumpRequest:Connect(onJumpRequest)
CurrentCamera2 = l9.CurrentCamera
sC_1.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fns.fn135)
Toggles.WalkSpeedEnabled:OnChanged(fn860)
task.spawn(worker3)
task.spawn(fns.worker4)
task.spawn(worker5)
task.spawn(worker6)
task.spawn(worker7)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(mZ.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/RollAnArmy")
sC_6 = SaveManager:BuildConfigSection(mZ.Settings)
mA = fn557
l0 = fns.fn307
lM = fns.fn22
if not sC_12 or sC_4 or (not sC_7 or not sC_7) or (mo or sC_15) and (not mo or not sC_12) or not (not sC_12 or sC_4 or (not sC_7 or not sC_7) or (mo or sC_15) and (not mo or not sC_12)) then
    mt = function(ho)
        local r8
        r8 = nil
        local r9 = type(ho) ~= "table"
        local sd = if r9 then 1 else 0
        local sb = 479 * sd + 3120 * (1 - sd)
        local sc = 2287 * sd + 2804 * (1 - sd)
        if not ((sb * 2313 + sc * 4087 + sb * sc) % 16777213 == 11550369) then
            r9 = type(ho.idx) ~= "string"
        end
        if not r9 then
            r9 = type(ho.type) ~= "string"
        end
        if not r9 then
            r9 = SaveManager.Ignore[ho.idx]
        end
        if r9 then
            return false
        end
        r8 = mA(ho.type, ho.idx)
        if not r8 then
            return false
        end
        local r9_1 = pcall(function()
            if ho.type == "Input" then
                if type(ho.text) ~= "string" then
                    return
                end
                r8:SetValue(ho.text)
            elseif ho.type == "ColorPicker" then
                r8:SetValueRGB(Color3.fromHex(ho.value), ho.transparency)
            elseif ho.type == "KeyPicker" then
                r8:SetValue({ ho.key, ho.mode, ho.modifiers })
                if ho.mode == "Toggle" and ho.toggled ~= nil then
                    r8.Toggled = ho.toggled
                    r8:Update()
                end
            else
                r8:SetValue(ho.value)
            end
        end)
        return r9_1
    end
end
sC_6:AddDivider()
sC_6:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
sC_6:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
sC_6:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
Library:OnUnload(fn359)
end)(...)

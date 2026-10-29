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
getgenv().TempoHoodSubtitle = "JUMP TO STEAL SLIME"
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
local vi_1, vi_3
local Upgrade_Carry_Limit
local LocalPlayer
local Guardians
local m6
local mO
local Library
local mv
local Options
local nB
local Toggles
local m_
local nH
local Label
local no
local mo
local m5
local mN
local Workspace
local mu
local nb
local mT
local nA
local nh
local mZ
local nG
local Rebirth
local nn
local Plots
local m4
local nM
local nt
local mt
local connection
local nz
local mz
local ng
local Shared
local nF
local mF
local nm
local mm
local m3
local nL
local ms
local m9
local ny
local my
local nf
local mX
local RarityTexts
local mE
local nK
local mK
local nr
local Slimes
local m8
local VirtualUser
local ne
local mW
local nD
local mD
local nk
local Database
local nJ
local mJ
local nq
local mq
local mP
local nw
local mw
local nd
local nC
local mC
local m0
local SafeZone
local function fn32(ai)
    if Library.Unloaded then
        return false
    end
    local ou = Toggles[ai]
    return ou ~= nil and ou.Value == true
end
local function fn47(W, X)
    return string.format('<font color="%s">%s</font>', X, W)
end
local function fn92(cI, cJ, cK)
    local qH
    local qE = os.clock()
    local qG = qE + (cK or 4)
    local qE_1 = mZ(cI)
    if not qE_1 then
        return nil
    end
    mO(true)
    m5(qE_1.Position)
    mz(qE_1, true)
    while true do
        if not (os.clock() < qG) then
            return nil
        end
        local qF_1 = Library.Unloaded or not nm("AutoGetLuckyBalls")
        if qF_1 then
            return nil
        end
        if mP() then
            return nil
        end
        m5(qE_1.Position)
        local qF_2 = nd(cJ)
        qH = mD(qF_2)
        if qH then
            break
        end
        local qF_3 = mZ(cI) or qE_1
        qE_1 = qF_3
        task.wait(0.35)
    end
    local qF_4 = qH:FindFirstChild("RootPart") or qH.PrimaryPart
    if qF_4 then
        m5(qF_4.Position)
        mz(qF_4.CFrame, true)
    end
    return qH
end
local function fn98()
    local pK = nf()
    local pL = pK > 0 or LocalPlayer:GetAttribute("holdingSlime") == true
    return pL
end
local function worker3()
    local uU, uV, uW, uX, uY, uZ, u_
    local u0 = 4
    while true do
        local u0_1 = 1253 - u0
        do
            if u0_1 < 1232 then
                if u0_1 < 1219 then
                    if u0_1 < 1212 then
                        if u0_1 < 1208 then
                            if u0_1 < 1207 then
                                if u0_1 < 1206 then
                                    if u0_1 == 1205 then
                                        u0 = if u_ then 37 else 30
                                    else
                                        u0 = 1224
                                        continue
                                    end
                                else
                                    task.wait(0.15)
                                    u0 = 38
                                end
                            elseif u0_1 == 1207 then
                                u0 = 0
                            else
                                u0 = 1238
                                continue
                            end
                        elseif u0_1 < 1211 then
                            if u0_1 < 1209 then
                                u0 = 27
                            elseif u0_1 < 1210 then
                                if u0_1 == 1209 then
                                    task.wait(0.05)
                                    u0 = 12
                                else
                                    u0 = 1245
                                    continue
                                end
                            elseif u0_1 == 1210 then
                                u0 = 1
                            else
                                u0 = 1227
                                continue
                            end
                        else
                            m6()
                            u0 = if mK() then 17 else 25
                        end
                    elseif u0_1 < 1217 then
                        if u0_1 < 1215 then
                            if u0_1 < 1214 then
                                if u0_1 < 1213 then
                                    if u0_1 == 1212 then
                                        u0 = if no then 34 else 6
                                    else
                                        u0 = 1227
                                        continue
                                    end
                                else
                                    uY = not Library.Unloaded
                                    u0 = 28
                                end
                            elseif u0_1 == 1214 then
                                uX = uW[(uU - 1) % #uW + 1]
                                uU += 1
                                uW = nn(uX, uV, 4.5)
                                u0 = if uW then 10 else 14
                            else
                                u0 = 1245
                                continue
                            end
                        elseif u0_1 < 1216 then
                            if u0_1 == 1215 then
                                u0 = 24
                            else
                                u0 = 8709
                                continue
                            end
                        else
                            nF(uW)
                            u0 = if mK() then 32 else 22
                        end
                    elseif u0_1 < 1218 then
                        uV = mJ("ZoneSelect")
                        uW = {}
                        for i, v in ipairs(m8) do
                            if uV[v] then
                                table.insert(uW, v)
                            end
                        end
                        u0 = if #uW == 0 then 3 else 39
                    else
                        u0 = 23
                    end
                elseif u0_1 < 1226 then
                    if u0_1 < 1224 then
                        if u0_1 < 1222 then
                            if u0_1 < 1220 then
                                task.wait(0.1)
                                u0 = 16
                            elseif u0_1 < 1221 then
                                u0 = 18
                            elseif u0_1 == 1221 then
                                u0 = 33
                            else
                                u0 = 1223
                                continue
                            end
                        elseif u0_1 < 1223 then
                            if u0_1 == 1222 then
                                mO(false)
                                task.wait(0.35)
                                u0 = 44
                            else
                                u0 = 1226
                                continue
                            end
                        elseif u0_1 == 1223 then
                            u0 = 33
                        else
                            u0 = 1230
                            continue
                        end
                    elseif u0_1 < 1225 then
                        if u0_1 == 1224 then
                            u0 = if uV then 19 else 31
                        else
                            u0 = 1230
                            continue
                        end
                    else
                        uZ = not no
                        u_ = uY
                        u0 = if u_ then 21 else 48
                    end
                elseif u0_1 < 1231 then
                    if u0_1 < 1228 then
                        if u0_1 < 1227 then
                            u0 = 24
                        elseif u0_1 == 1227 then
                            m6()
                            u0 = if mK() then 8 else 47
                        else
                            u0 = 1207
                            continue
                        end
                    elseif u0_1 < 1229 then
                        if u0_1 == 1228 then
                            u0 = 45
                        else
                            u0 = 1238
                            continue
                        end
                    elseif u0_1 < 1230 then
                        if u0_1 == 1229 then
                            u0 = 44
                        else
                            u0 = 1235
                            continue
                        end
                    else
                        uY = uW
                        u0 = if uY then 20 else 2
                    end
                else
                    uW = mD(nd(uV))
                    u0 = if not uW then 15 else 43
                end
            elseif u0_1 < 1245 then
                if u0_1 < 1238 then
                    if u0_1 < 1234 then
                        if u0_1 < 1233 then
                            if u0_1 == 1232 then
                                u_ = uZ
                                u0 = 48
                            else
                                u0 = 1227
                                continue
                            end
                        else
                            uY = not mK()
                            u0 = 2
                        end
                    elseif u0_1 < 1236 then
                        if u0_1 < 1235 then
                            u0 = if mK() then 26 else 36
                        else
                            u0 = if mK() then 42 else 45
                        end
                    elseif u0_1 < 1237 then
                        task.wait(1)
                        u0 = 25
                    elseif u0_1 == 1237 then
                        u0 = 7
                    else
                        u0 = 1221
                        continue
                    end
                elseif u0_1 < 1242 then
                    if u0_1 < 1239 then
                        uW = nn(uX, uV, 2)
                        u0 = 43
                    elseif u0_1 < 1241 then
                        if u0_1 < 1240 then
                            if u0_1 == 1239 then
                                mO(false)
                                task.wait(0.15)
                                u0 = 18
                            else
                                u0 = 1240
                                continue
                            end
                        else
                            u0 = 46
                        end
                    elseif u0_1 == 1241 then
                        u0 = 16
                    else
                        u0 = 1233
                        continue
                    end
                elseif u0_1 < 1243 then
                    if u0_1 == 1242 then
                        uV = nK("ZoneSelect")
                        u0 = 29
                    else
                        u0 = 1245
                        continue
                    end
                elseif u0_1 < 1244 then
                    u0 = 35
                else
                    u0 = if uY then 40 else 28
                end
            elseif u0_1 < 1252 then
                if u0_1 < 1249 then
                    if u0_1 < 1247 then
                        if u0_1 < 1246 then
                            task.wait(1)
                            u0 = 38
                        else
                            u0 = if not Library.Unloaded then 41 else 13
                        end
                    elseif u0_1 < 1248 then
                        uV = (nm("AutoGetLuckyBalls"))
                        u0 = if uV then 11 else 29
                    else
                        uY = nm("AutoGetLuckyBalls")
                        u0 = 9
                    end
                elseif u0_1 < 1250 then
                    if u0_1 == 1249 then
                        uU = 1
                        u0 = 16
                    else
                        u0 = 1228
                        continue
                    end
                elseif u0_1 < 1251 then
                    if u0_1 == 1250 then
                        mO(false)
                        task.wait(0.35)
                        u0 = 27
                    else
                        u0 = 1206
                        continue
                    end
                else
                    u0 = if uY then 5 else 9
                end
            elseif u0_1 < 2574 then
                if u0_1 < 1253 then
                    u0 = 35
                else
                    break
                end
            else
                break
            end
        end
    end
end
local function fn127()
    local Character = LocalPlayer.Character
    local oM = Character and Character:FindFirstChild("HumanoidRootPart")
    return oM
end
local function fn168(b_)
    local pY = Vector3.zero
    local pZ = 0
    for i, child in ipairs(Slimes:GetChildren()) do
        local p__1 = child:IsA("Model") and ng(child.Name, b_)
        if p__1 then
            local p__2 = child:FindFirstChild("RootPart") or child.PrimaryPart
            if p__2 then
                pY += p__2.Position
                pZ += 1
            end
        end
    end
    if pZ > 0 then
        local p__3 = pY / pZ
        return CFrame.new(p__3 + Vector3.new(0, 5, 0))
    end
    local pY_1 = RarityTexts:FindFirstChild(b_)
    if b_ == "Toxic" then
        local pZ_1 = RarityTexts:FindFirstChild("Toxic") or pY_1
        pY_1 = pZ_1
    end
    local pZ_2 = pY_1 and pY_1:IsA("BasePart")
    if pZ_2 then
        return pY_1.CFrame + Vector3.new(0, 6, 0)
    elseif b_ == "Common" then
        return CFrame.new(204, 6, 199)
    else
        return nil
    end
end
local function onRscripts()
    m_(nb, "Copied Rscripts profile to clipboard")
end
local function fn218()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    mq = tick()
end
local function onUnload()
    Library:Unload()
end
local function fn249(P, Q)
    if setclipboard then
        setclipboard(P)
    elseif toclipboard then
        toclipboard(P)
    end
    Library:Notify(Q)
end
local function fn255(dr)
    if not dr then
        return
    end
    for i, descendant in ipairs(dr:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.CanTouch = false
            descendant.CanCollide = false
        end
    end
end
local function fn297(c1)
    local qL_1, qL_2
    local qK = not c1
    local qK_1, qK_3
    local qS = if qK then 1 else 0
    local qQ = 1899 * qS + 2808 * (1 - qS)
    local qR = 1302 * qS + 870 * (1 - qS)
    if not ((qQ * 1507 + qR * 1296 + qQ * qR) % 16777213 == 7021683) then
        qK = not c1.Parent
    end
    if qK then
        return false
    end
    qK_1, qL_1 = nB(c1)
    if not (qK_1 and qL_1) then
        return false
    end
    local qM_1 = select(1, nf())
    m5(qL_1.Position)
    mO(false)
    mz(qL_1.CFrame, false)
    task.wait(0.2)
    if not c1.Parent or not qK_1.Parent or not qK_1.Enabled then
        return false
    end
    local qY = 1
    while true do
        if not (qY <= 4) then
            local qK_2 = select(1, nf()) > qM_1 or LocalPlayer:GetAttribute("holdingSlime") == true
            return qK_2
        end
        qK_3, qL_2 = nB(c1)
        if not (qK_3 and qL_2 and qK_3.Enabled) then
            local qK_4 = select(1, nf()) > qM_1 or LocalPlayer:GetAttribute("holdingSlime") == true
            return qK_4
        end
        mz(qL_2.CFrame, false)
        task.wait(0.08)
        nG(qK_3)
        local qN_2 = select(1, nf())
        local qO = qN_2 > qM_1 or LocalPlayer:GetAttribute("holdingSlime") == true
        if qO then
            return true
        end
        if not c1.Parent then
            break
        end
        task.wait(0.15)
        qY += 1
    end
    return true
end
local function fn314()
    local pH_1
    local pG_1
    pG_1, pH_1 = nf()
    return pG_1 >= pH_1 and pH_1 > 0
end
local function fn320()
    local Character = LocalPlayer.Character
    local oP = Character and Character:FindFirstChildWhichIsA("Humanoid")
    return oP
end
local function fn326(em)
    local sb = mo()
    if not (sb and em) then
        return nil
    end
    local Stands = sb:FindFirstChild("Stands")
    if not Stands then
        return nil
    end
    local children = Stands:GetChildren()
    table.sort(children, function(er, es)
        local r5 = tonumber(er.Name) or math.huge
        local r6 = (tonumber(es.Name))
        local sa = if r6 then 1 else 0
        local r8 = 691 * sa + 2312 * (1 - sa)
        local r9 = 614 * sa + 1144 * (1 - sa)
        if not ((r8 * 4028 + r9 * 948 + r8 * r9) % 16777213 == 3789694) then
            r6 = math.huge
        end
        return r5 < r6
    end)
    for i, v in ipairs(children) do
        local sb_2 = v:IsA("Model") and mm(v.Name, em.BaseLevel) and not em.PlotSlimes[v.Name]
        if sb_2 then
            return v
        end
    end
    return nil
end
local function fn358()
    local tq = m4()
    if not tq then
        return
    end
    local tt = Database.CarryLevelPrices[tq.CarryLevel or 1]
    local tr_1 = not tt
    if not tr_1 then
        tr_1 = (tq.Cash or 0) < tt
    end
    if tr_1 then
        return
    end
    pcall(function()
        Upgrade_Carry_Limit:FireServer()
    end)
end
local function fn365(Z, aa, ab)
    return string.format("<b>%s</b> %s %s", Z, mC("-", "#5a6070"), mC(aa, ab))
end
local function onInputChanged(ia)
    local UserInputType = ia.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        mt = tick()
    end
end
local function fn377()
    m_(nh, "Copied Discord invite to clipboard")
end
local function fn381()
    local q0 = mo()
    local q0_3
    if q0 then
        local Base = q0:FindFirstChild("Base")
        local q2 = Base and Base:IsA("BasePart")
        if q2 then
            return Base.CFrame
        end
        local q1_1 = q0:FindFirstChild("Stands") and q0.Stands:FindFirstChild("2")
        if q1_1 then
            local BasePart = q1_1:FindFirstChildWhichIsA("BasePart", true)
            if BasePart then
                return BasePart.CFrame
            elseif q0:IsA("Model") then
                return q0:GetPivot()
            else
                local q0_1 = SafeZone and SafeZone:IsA("BasePart")
                if q0_3 then
                    return SafeZone.CFrame
                end
                return nil
            end
        elseif q0:IsA("Model") then
            return q0:GetPivot()
        else
            local q0_2 = SafeZone and SafeZone:IsA("BasePart")
            if q0_3 then
                return SafeZone.CFrame
            end
            return nil
        end
    else
        q0_3 = SafeZone and SafeZone:IsA("BasePart")
        if q0_3 then
            return SafeZone.CFrame
        end
        return nil
    end
end
local function fn386(ao, ap)
    local ox = Options[ao]
    if ox == nil then
        return ap
    end
    return ox.Value
end
local function fn430()
    local px = m4()
    local max = math.max
    local py_1
    local pz = px and px.CarryLevel
    local px_1 = tonumber(pz) or 1
    local pz_1 = max(1, px_1)
    local attr = LocalPlayer:GetAttribute("holdingSlimeCount")
    if attr == nil then
        local pA_1 = LocalPlayer:GetAttribute("holdingSlime") == true and 1
        local pB = pA_1
        local pF = if pB then 1 else 0
        local pD = 299 * pF + 56 * (1 - pF)
        local pE = 739 * pF + 199 * (1 - pF)
        if not ((pD * 626 + pE * 343 + pD * pE) % 16777213 == 661612) then
            pB = 0
        end
        py_1 = pB
    else
        local pA_2 = tonumber(attr) or 0
        py_1 = pA_2
    end
    return py_1, pz_1
end
local function fn431(a6)
    if a6 == nil then
        return nil
    end
    local pa = Database.Slimes[a6] or Database.Slimes[tostring(a6)]
    return pa
end
local function fn454()
    local rx = my()
    if not rx then
        return false
    end
    m5(rx.Position)
    mO(true)
    local rB = 1
    while rB <= 3 do
        mz(rx, true)
        task.wait(0.12)
        rB += 1
    end
    task.wait(0.2)
    return true
end
local function onHeartbeat()
    local uP = Library.Unloaded or not nm("AntiEnemy")
    if uP then
        return
    end
    nD()
    mF()
    if os.clock() - ne >= 1.5 then
        mW()
    end
end
local function fn470(at)
    local oC = m0(at, {})
    if typeof(oC) ~= "table" then
        return {}
    end
    local oD = {}
    for k, v in pairs(oC) do
        if v == true then
            oD[k] = true
        else
            local oC_1 = typeof(k) == "number" and typeof(v) == "string"
            if oC_1 then
                oD[v] = true
            end
        end
    end
    return oD
end
local function worker6()
    while not Library.Unloaded do
        if nm("AutoUpgradeJump") then
            mu()
        end
        if nm("AutoUpgradeCarry") then
            mX()
        end
        if nm("AutoUpgradeFloor") then
            mw()
        end
        if nm("AutoRebirth") then
            nq()
        end
        task.wait(0.6)
    end
end
local function fn484(cw)
    local qs = nz()
    if not qs or #cw == 0 then
        return nil
    end
    local qt_1 = math.huge
    local qu
    for i, v in ipairs(cw) do
        local qv = v:FindFirstChild("RootPart") or v.PrimaryPart
        if qv then
            local Magnitude = (qv.Position - qs.Position).Magnitude
            if Magnitude < qt_1 then
                qt_1 = Magnitude
                qu = v
            end
        end
    end
    return qu
end
local function worker()
    local ut_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local us = math.floor(os.clock() - nM)
        if us < 60 then
            ut_1 = us .. "s"
        elseif us < 3600 then
            ut_1 = string.format("%dm %ds", math.floor((us) / (60)), us % 60)
        else
            ut_1 = string.format("%dh %dm", math.floor((us) / (3600)), math.floor((us % 3600) / (60)))
        end
        Label:SetText(ms("Session time", ut_1, nw))
    end
end
local function fn499(bO)
    local pN = bO or ""
    local pO = tostring(pN):gsub(" Lucky Block", "")
    if pO:find("Toxic", 1, true) then
        return "Toxic"
    end
    for i, v in ipairs(m8) do
        local pN_1 = pO == v or pO:find(v, 1, true) == 1
        if pN_1 then
            return v
        end
    end
    return pO
end
local function fn501()
    local rp = nz()
    if not rp or rp.Anchored then
        return
    end
    if rp.AssemblyLinearVelocity.Magnitude >= nC or rp.AssemblyAngularVelocity.Magnitude >= 40 then
        rp.AssemblyLinearVelocity = Vector3.zero
        rp.AssemblyAngularVelocity = Vector3.zero
    end
end
local function fn502()
    local tE = m4()
    if not tE then
        return
    end
    local tH = Database.Rebirths[(tE.Rebirth or 0) + 1]
    if not tH then
        return
    end
    if (tE.Jump or 0) < (tH.JumpRequirement or math.huge) then
        return
    end
    pcall(function()
        Rebirth:FireServer()
    end)
end
local function fn513(d5, d6)
    local rJ = tonumber(d5)
    if not rJ then
        return false
    elseif rJ <= 10 then
        return true
    else
        local rK = rJ - 10
        local rL = d6
        local rP = if rL then 1 else 0
        local rN = 3559 * rP + 3955 * (1 - rP)
        local rO = 714 * rP + 1339 * (1 - rP)
        if not ((rN * 1672 + rO * 1542 + rN * rO) % 16777213 == 9592762) then
            rL = 0
        end
        return rK <= rL
    end
end
local function fn533()
    if _G.MyPlot and _G.MyPlot.Parent then
        return _G.MyPlot
    end
    for i, child in ipairs(Plots:GetChildren()) do
        local owner = child:FindFirstChild("owner")
        if owner and owner.Value == LocalPlayer.Name then
            _G.MyPlot = child
            return child
        end
    end
    return nil
end
local function fn554(bj, bk)
    local pk = nz()
    local pl = not pk
    local pp = if pl then 1 else 0
    local pn = 771 * pp + 4053 * (1 - pp)
    local po = 1873 * pp + 3125 * (1 - pp)
    if not ((pn * 3697 + po * 3006 + pn * po) % 16777213 == 9924708) then
        pl = typeof(bj) ~= "CFrame"
    end
    if pl then
        return false
    end
    if bk then
        pk.Anchored = true
    end
    pk.AssemblyLinearVelocity = Vector3.zero
    pk.AssemblyAngularVelocity = Vector3.zero
    pk.CFrame = bj + Vector3.new(0, 3, 0)
    return true
end
local function fn557(fw)
    local s0 = mo()
    local s1 = s0 and s0:FindFirstChild("CollectPads")
    local s0_1 = s1
    if s1 then
        s1 = s0_1:FindFirstChild(tostring(fw))
    end
    local s0_2 = s1
    if s1 then
        s1 = s0_2:FindFirstChild("Top")
    end
    local s0_3 = s1
    if s1 then
        s1 = s0_3:FindFirstChild("PadGui")
    end
    local s0_4 = s1
    if s1 then
        s1 = s0_4.Enabled
    end
    if not s1 then
        return false
    end
    local Earnings = s0_4:FindFirstChild("Earnings", true)
    local s0_5 = Earnings and Earnings:IsA("TextLabel")
    if not s0_5 then
        return true
    end
    local s0_6 = Earnings.Text or ""
    local s1_2 = tostring(s0_6)
    return s1_2 ~= "" and s1_2 ~= "$0" and s1_2 ~= "0" and s1_2 ~= "$0.0"
end
local function fn559(ce)
    local p8 = ce
    if p8 then
        local p9_1 = ce:FindFirstChild("RootPart") or ce.PrimaryPart
        p8 = p9_1
    end
    local p9_2 = p8
    if not p9_2 then
        return nil, nil
    end
    local qg = if p9_2:FindFirstChild("STEALING") then 1 else 0
    if qg == 1 then
        return nil, p9_2
    end
    return p9_2:FindFirstChild("StealPrompt"), p9_2
end
local function worker4()
    while not Library.Unloaded do
        local u7 = nm("AutoGoBackBase") and mK() and not no and not nm("AutoGetLuckyBalls")
        if u7 then
            m6()
        end
        task.wait(0.35)
    end
end
local function fn568()
    if not Guardians then
        return
    end
    for i, child in ipairs(Guardians:GetChildren()) do
        m9(child)
    end
    ne = os.clock()
end
local function worker5()
    while not Library.Unloaded do
        local u9 = nm("AutoPlaceLuckyBalls") and #ny() > 0 and not nm("AutoGetLuckyBalls")
        if u9 and not no then
            nr(false)
        end
        local u9_1 = not no
        local va_1 = nm("AutoOpenLuckyBalls") and u9_1
        if va_1 then
            nL()
        end
        if nm("AutoCollectCash") then
            nt()
        end
        local u9_2 = not no
        local va_2 = nm("AutoEquipBest") and u9_2
        if va_2 then
            nJ()
        end
        task.wait(0.9)
    end
end
local function fn613()
    connection:Disconnect()
    mT:Disconnect()
    mO(false)
end
local function fn617(cl)
    local qj_1
    local qh = {}
    for i, child in ipairs(Slimes:GetChildren()) do
        if child:IsA("Model") then
            local qi = nH(child.Name)
            local qi_1
            if cl[qi] then
                qi_1, qj_1 = nB(child)
                if qi_1 and qj_1 then
                    table.insert(qh, child)
                end
            end
        end
    end
    return qh
end
local function onInputBegan()
    mt = tick()
end
local function fn654()
    if not nm("AutoGoBackBase") then
        return false
    end
    return mP()
end
local function fn657()
    local Character = LocalPlayer.Character
    if not Character then
        return
    end
    local Ragdolled = Character:FindFirstChild("Ragdolled")
    local rk = Ragdolled and Ragdolled:IsA("BoolValue") and Ragdolled.Value == true
    if rk then
        Ragdolled.Value = false
    end
    local ro = if Character:GetAttribute("Ragdolled") == true then 1 else 0
    if ro == 1 then
        Character:SetAttribute("Ragdolled", false)
    end
    local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
    if not Humanoid then
        return
    end
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
    local ri_1 = Humanoid:GetState()
    if ri_1 == Enum.HumanoidStateType.Physics or ri_1 == Enum.HumanoidStateType.Ragdoll or ri_1 == Enum.HumanoidStateType.FallingDown or ri_1 == Enum.HumanoidStateType.PlatformStanding then
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end
local function fn658(hj)
    local DiscordGroup = hj:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = mN })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = mN })
end
local function worker2()
    while not Library.Unloaded do
        task.wait(2)
        if nm("AntiAfk") then
            local uH = tick() - mt
            local uI = tick() - mq
            if uH >= 300 and uI >= 60 then
                pcall(nA)
            else
                if uH < 300 and uI >= 300 then
                    pcall(nA)
                end
            end
        end
    end
end
local function fn691(bV, bW)
    local pW = nH(bV)
    if bW == "Toxic" then
        return pW == "Toxic"
    end
    return pW == bW
end
local function onCopyJoinScript_JobID()
    local hA = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, mE)
    m_(hA, "Copied join script to clipboard")
end
local function fn732(gG, gH, gI)
    local tJ = tonumber(gH.MoneyPerSecond)
    if not tJ then
        local tK_1 = tonumber(gG.production_mps) or 0
        tJ = tK_1
    end
    local max = math.max
    local tL = tonumber(gG.level) or 1
    local tM = max(1, tL)
    local tK_3 = 1
    local tO = Database.Rebirths[gI and gI.Rebirth]
    if tO then
        local tL_2 = tonumber(tO.CashMulti) or 1
        tK_3 = tL_2
    end
    local tL_3 = Shared.getRebirthScaledEarnings(math.max(0, tJ), tM, tK_3)
    local getMutationMulti = Shared.getMutationMulti
    local tK_4 = gG.mutation or "None"
    local tM_1 = {}
    local tN_1 = gG.event_mutations
    local tS = if tN_1 then 1 else 0
    local tQ = 1593 * tS + 174 * (1 - tS)
    local tR = 1654 * tS + 146 * (1 - tS)
    if not ((tQ * 3084 + tR * 526 + tQ * tR) % 16777213 == 8417638) then
        tN_1 = tM_1
    end
    local tJ_2 = getMutationMulti(tK_4, tN_1) or 1
    return tL_3 * tJ_2
end
local function fn742(d0)
    local rF = os.clock()
    local rH = rF + (d0 or 4)
    while true do
        if not (os.clock() < rH) then
            return not mv()
        end
        if Library.Unloaded then
            break
        end
        if not mv() then
            return true
        end
        task.wait(0.15)
    end
    return false
end
local function fn778()
    local ul_1
    local uk_1
    if identifyexecutor then
        ul_1, uk_1 = identifyexecutor()
        local um = ul_1 ~= ""
        local un = type(ul_1) == "string" and um
        if un then
            local um_1 = type(uk_1) == "string" and uk_1 ~= "" and ul_1 .. " " .. uk_1
            m3 = um_1 or ul_1
        end
    end
end
local function fn795(aB)
    return next(mJ(aB)) ~= nil
end
local function fn801()
    local rQ = {}
    local Backpack = LocalPlayer:FindFirstChild("Backpack")
    local Character = LocalPlayer.Character
    for i, v in ipairs({ Character, Backpack }) do
        if v then
            for i, child in ipairs(v:GetChildren()) do
                local rR_1 = child:IsA("Tool") and child:GetAttribute("slimeUID")
                if rR_1 then
                    local rR_2 = nk(child:GetAttribute("slimeID"))
                    if rR_2 and rR_2.Type == "Lucky Block" then
                        table.insert(rQ, child)
                    end
                end
            end
        end
    end
    return rQ
end
local function fn827(bf)
    local pd = nz()
    if not pd then
        return nil
    end
    local pf = bf and true or false
    pd.Anchored = pf
    if bf then
        pd.AssemblyLinearVelocity = Vector3.zero
        pd.AssemblyAngularVelocity = Vector3.zero
    end
    return pd
end
mm = nil
Plots = nil
mo = nil
Guardians = nil
mq = nil
Slimes = nil
ms = nil
mt = nil
mu = nil
mv = nil
mw = nil
my = nil
mz = nil
mC = nil
mD = nil
mE = nil
mF = nil
Rebirth = nil
Label = nil
Upgrade_Carry_Limit = nil
mJ = nil
mK = nil
mN = nil
mO = nil
mP = nil
mT = nil
mW = nil
mX = nil
Shared = nil
mZ = nil
m_ = nil
m0 = nil
Database = nil
m3 = nil
m4 = nil
m5 = nil
m6 = nil
m8 = nil
local Data_Get, mA, Purchase_Floor, Buy_Speed_Upgrade, mM, Collect_Earnings, Open_Lucky_Block, mS, Place_Slime, mV, m2, m7
m9 = nil
connection = nil
nb = nil
Options = nil
nd = nil
ne = nil
nf = nil
ng = nil
nh = nil
Toggles = nil
nk = nil
nm = nil
nn = nil
no = nil
LocalPlayer = nil
nq = nil
nr = nil
nt = nil
Workspace = nil
Library = nil
nw = nil
VirtualUser = nil
ny = nil
nz = nil
nA = nil
nB = nil
nC = nil
nD = nil
RarityTexts = nil
nF = nil
nG = nil
nH = nil
SafeZone = nil
nJ = nil
nK = nil
nL = nil
nM = nil
local nj, nl, ns
nj = nil
nl = nil
ns = nil
VirtualUser, Workspace, LocalPlayer, nh, nb, Database, Shared, Place_Slime, Open_Lucky_Block, Collect_Earnings, Buy_Speed_Upgrade, Upgrade_Carry_Limit, Rebirth, Purchase_Floor, Data_Get, Slimes, Guardians, Plots, SafeZone, RarityTexts, nC, Library, Toggles, Options, m8, m2, nw, ns, no, nl, ne, m_, mN, mC, ms, nm, m0, mJ, nK, nz, nj, m4, mo, nk, m5, mO, mz, nG, nf, mP, mv, nH, ng, mZ, nB, nd, mD, nn, nF, my, m9, mW, mF, nD, m7, mK, mA, mm, ny, mM, nr, m6, nL, mS, nt, mu, mX, mw, nq, mV, nJ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local vi_6 = game:GetService("Players")
local nU = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
Workspace = game:GetService("Workspace")
LocalPlayer = vi_6.LocalPlayer
local nX = "Jump To Steal Slime"
nh = "https://discord.gg/K7Qxnxkk46"
nb = "https://discord.gg/K7Qxnxkk46"
local vi_5 = nU:WaitForChild("SharedModules")
local vi_8 = vi_5:WaitForChild("Network"):WaitForChild("Remotes")
Database = require(vi_5:WaitForChild("Database"))
Shared = require(vi_5:WaitForChild("Shared"))
Place_Slime = vi_8:WaitForChild("Place Slime")
Open_Lucky_Block = vi_8:WaitForChild("Open Lucky Block")
Collect_Earnings = vi_8:WaitForChild("Collect Earnings")
Buy_Speed_Upgrade = vi_8:WaitForChild("Buy Speed Upgrade")
Upgrade_Carry_Limit = vi_8:WaitForChild("Upgrade Carry Limit")
Rebirth = vi_8:WaitForChild("Rebirth")
Purchase_Floor = vi_8:WaitForChild("Purchase Floor")
Data_Get = vi_8:WaitForChild("Data: Get")
local vi_4 = Workspace:WaitForChild("Live")
Slimes = vi_4:WaitForChild("Slimes")
Guardians = vi_4:WaitForChild("Guardians")
Plots = Workspace:WaitForChild("Plots")
SafeZone = Workspace:WaitForChild("Regions"):WaitForChild("SafeZone")
RarityTexts = Workspace:WaitForChild("Map"):WaitForChild("RarityTexts")
nC = 55
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
m8 = {
    "Common",
    "Rare",
    "Epic",
    "Legendary",
    "Mythic",
    "Secret",
    "Slime God",
    "OG",
    "Moon",
    "Candy",
    "Galaxy",
    "Beach",
    "Toxic"
}
local nW = { "+1 Jump", "+5 Jump", "+10 Jump" }
m2 = { ["+1 Jump"] = 1, ["+5 Jump"] = 2, ["+10 Jump"] = 3 }
m_ = fn249
mN = fn377
mC = fn47
ms = fn365
local n3 = "#7fd47f"
local n1 = "#6ec1ff"
nw = "#e8a34d"
local n_ = "#8b93a3"
nm = fn32
m0 = fn386
mJ = fn470
nK = fn795
nz = fn127
nj = fn320
m4 = function(aM)
    local oU_4
    local oT_1, oT_2, oT_3, oT_4
    local oS_2, oS_3, oS_4, oS_5
    if not aM then
        local oR = rawget(_G, "_Lib")
        if oR and oR.Data and oR.Data.Get then
            oS_2, oT_1 = pcall(function()
                return oR.Data:Get()
            end)
            local oU_1 = oS_2 and type(oT_1) == "table"
            if oU_1 then
                return oT_1
            end
            oS_3, oT_2 = pcall(function()
                return Data_Get:InvokeServer()
            end)
            if oU_4 then
                return oT_2
            end
            return nil
        end
        oS_4, oT_3 = pcall(function()
            return Data_Get:InvokeServer()
        end)
        if oU_4 then
            return oT_3
        end
        return nil
    end
    oS_5, oT_4 = pcall(function()
        return Data_Get:InvokeServer()
    end)
    oU_4 = oS_5 and type(oT_4) == "table"
    if oU_4 then
        return oT_4
    end
    return nil
end
mo = fn533
nk = fn431
m5 = function(ba)
    if typeof(ba) ~= "Vector3" then
        return
    end
    pcall(function()
        LocalPlayer:RequestStreamAroundAsync(ba)
    end)
end
mO = fn827
mz = fn554
nG = function(bp)
    local pr
    pr = nil
    local ps = not bp
    local pw = if ps then 1 else 0
    local pu = 1417 * pw + 1 * (1 - pw)
    local pv = 2497 * pw + 2435 * (1 - pw)
    if not ((pu * 2787 + pv * 192 + pu * pv) % 16777213 == 7966852) then
        ps = not bp.Parent
    end
    if ps then
        return false
    end
    local ps_1 = tonumber(bp.HoldDuration) or 0
    pr = ps_1
    local ps_2 = pcall(function()
        if fireproximityprompt then
            fireproximityprompt(bp, pr)
        else
            bp:InputHoldBegin()
            task.wait(math.max(0.05, pr))
            bp:InputHoldEnd()
        end
    end)
    if ps_2 then
        task.wait(math.max(0.05, pr + 0.05))
    end
    return ps_2
end
nf = fn430
mP = fn314
mv = fn98
nH = fn499
ng = fn691
mZ = fn168
nB = fn559
nd = fn617
mD = fn484
nn = fn92
if (nm or Workspace or (not Workspace or nm)) and (not Workspace or not Workspace or Workspace and not nm) or not nm and not Workspace and (Workspace and Workspace) and (not nm and nm and (Workspace or nm)) or (not Workspace or Workspace) and (Workspace and not nm) and ((nm or not Workspace) and (Workspace and Workspace)) and ((not Workspace or Workspace) and (Workspace or not Workspace) or (not nm or not Workspace) and (not nm or nm)) or not ((nm or Workspace or (not Workspace or nm)) and (not Workspace or not Workspace or Workspace and not nm) or not nm and not Workspace and (Workspace and Workspace) and (not nm and nm and (Workspace or nm)) or (not Workspace or Workspace) and (Workspace and not nm) and ((nm or not Workspace) and (Workspace and Workspace)) and ((not Workspace or Workspace) and (Workspace or not Workspace) or (not nm or not Workspace) and (not nm or nm))) then
    nF = fn297
    my = fn381
    ns = false
    no = false
else
    ns = fn297
    no = fn381
    nF = false
    my = false
end
nl = 0
ne = 0
m9 = fn255
mW = fn568
mF = fn657
nD = fn501
m7 = fn454
mK = fn654
mA = fn742
mm = fn513
ny = fn801
mM = fn326
nr = function(eA)
    local st
    local sr = m4()
    if not sr then
        return false
    end
    if not eA then
        m7()
        task.wait(0.2)
    end
    mO(true)
    local sp = nj()
    local ss = false
    local sA = false
    for i = 1, 16 do
        local sq, so, attr
        local sz = 2
        while true do
            if sz < 13 then
                if sz < 6 then
                    if sz < 3 then
                        if sz < 1 then
                            m5(st.Position)
                            mz(st.CFrame, true)
                            task.wait(0.1)
                            sz = 1
                        elseif sz < 2 then
                            pcall(function()
                                Place_Slime:FireServer(tostring(sq.Name), attr)
                            end)
                            ss = true
                            st = os.clock() + 1.25
                            sz = 22
                        else
                            sz = if Library.Unloaded then 8 else 3
                        end
                    elseif sz < 4 then
                        st = (m4())
                        sz = if st then 19 else 17
                    elseif sz < 5 then
                        sr = st
                        task.wait(0.15)
                        sz = 18
                    else
                        sz = 23
                    end
                elseif sz < 9 then
                    if sz < 7 then
                        sq = mM(sr)
                        sz = if not sq then 11 else 25
                    elseif sz < 8 then
                        sA = true
                        sz = 18
                    else
                        sz = 7
                    end
                elseif sz < 11 then
                    if sz < 10 then
                        task.wait(0.1)
                        sz = 14
                    else
                        st = sq:FindFirstChildWhichIsA("BasePart", true)
                        sz = if st then 0 else 1
                    end
                elseif sz < 12 then
                    sz = 7
                else
                    st = sr
                    sz = 4
                end
            elseif sz < 20 then
                if sz < 16 then
                    if sz < 14 then
                        sz = if sp then 26 else 10
                    elseif sz < 15 then
                        sz = 22
                    else
                        sz = if os.clock() < st then 20 else 21
                    end
                elseif sz < 18 then
                    if sz < 17 then
                        sz = 7
                    else
                        st = sr
                        sz = 19
                    end
                elseif sz < 19 then
                    break
                else
                    sr = st
                    st = ny()
                    sz = if #st == 0 then 16 else 6
                end
            elseif sz < 23 then
                if sz < 21 then
                    local su = false
                    for i, v in ipairs(ny()) do
                        if v:GetAttribute("slimeUID") == attr then
                            su = true
                            break
                        end
                    end
                    sz = if not su then 5 else 9
                elseif sz < 22 then
                    sz = 23
                else
                    sz = 15
                end
            elseif sz < 25 then
                if sz < 24 then
                    st = (m4(true))
                    sz = if st then 4 else 12
                else
                    sz = 7
                end
            elseif sz < 26 then
                so = st[1]
                attr = so:GetAttribute("slimeUID")
                sz = if not attr then 24 else 13
            else
                pcall(function()
                    sp:EquipTool(so)
                end)
                task.wait(0.12)
                sz = 10
            end
        end
        if sA then
            break
        end
    end
    if not eA then
        mO(false)
    end
    return ss
end
m6 = function()
    local sN
    if no then
        return false
    end
    local sR = if os.clock() - nl < 0.75 then 1 else 0
    if sR == 1 then
        return false
    end
    no = true
    ns = true
    nl = os.clock()
    sN = false
    pcall(function()
        local sM = if not m7() then 1 else 0
        if sM == 1 then
            return
        end
        if nm("AutoPlaceLuckyBalls") then
            nr(true)
            mA(5)
        else
            task.wait(0.25)
        end
        sN = true
    end)
    mO(false)
    no = false
    ns = false
    nl = os.clock()
    return sN
end
nL = function()
    local sS = m4()
    local sT = not sS or type(sS.PlotSlimes) ~= "table"
    if sT then
        return
    end
    for k, v in pairs(sS.PlotSlimes) do
        local sY = k
        local sS_1 = nk(v.id)
        if sS_1 and sS_1.Type == "Lucky Block" or v.production_is_lucky_block == true or v.type == "Lucky Block" then
            pcall(function()
                Open_Lucky_Block:FireServer(tostring(sY))
            end)
            task.wait(0.2)
        end
    end
end
mS = fn557
nt = function()
    local s8 = m4(true)
    local s9 = not s8 or type(s8.PlotSlimes) ~= "table"
    if s9 then
        return
    end
    for k, v in pairs(s8.PlotSlimes) do
        local te = k
        local s8_1 = nk(v.id)
        if not (s8_1 and s8_1.Type == "Lucky Block" or v.production_is_lucky_block == true or v.type == "Lucky Block") then
            local s8_3 = tonumber(v.earnings) or 0
            local s8_4 = s8_3 > 0 or mS(te)
            if s8_4 then
                pcall(function()
                    Collect_Earnings:FireServer(tostring(te))
                end)
            end
        end
    end
end
mu = function()
    local th
    local ti = m0("JumpBuyAmount", "+1 Jump")
    th = m2[ti] or 1
    local ti_1 = m4()
    if not ti_1 then
        return
    end
    local tj_1 = Database.SpeedUpgrades[th]
    if not tj_1 then
        return
    end
    local tk = tj_1.UpgradeAmount or 1
    local tk_1 = Shared.getSpeedUpgradePrice(ti_1.Jump, tj_1.PriceMulti) or math.huge
    local tj_2 = tk_1 * tk
    local tk_2 = math.round(tj_2)
    if tk_2 > (ti_1.Cash or 0) then
        return
    end
    pcall(function()
        Buy_Speed_Upgrade:FireServer(th)
    end)
end
mX = fn358
mw = function()
    local tv
    local tw = m4()
    if not tw then
        return
    end
    tv = (tw.BaseLevel or 0) + 1
    local tx_1 = Database.BaseLevelPrices[tv]
    if not tx_1 or (tw.Cash or 0) < tx_1 then
        return
    end
    pcall(function()
        Purchase_Floor:InvokeServer(tv)
    end)
end
nq = fn502
mV = fn732
nJ = function()
    local tV = m4()
    local tW = not tV or type(tV.Inventory) ~= "table"
    if tW then
        return
    end
    local tT = nj()
    if not tT then
        return
    end
    local tW_1 = {}
    local Backpack = LocalPlayer:FindFirstChild("Backpack")
    local Character = LocalPlayer.Character
    for i, v in ipairs({ Character, Backpack }) do
        if v then
            for i, child in ipairs(v:GetChildren()) do
                local tX_1 = child:IsA("Tool") and child:GetAttribute("slimeUID")
                if tX_1 then
                    tW_1[tostring(child:GetAttribute("slimeUID"))] = child
                end
            end
        end
    end
    local tX_2 = -1
    local tU
    for k, v in pairs(tV.Inventory) do
        local tY_1 = type(v) == "table" and v.uid ~= nil
        if tY_1 then
            local tY_2 = tW_1[tostring(v.uid)]
            local tZ = nk(v.id)
            if tY_2 and tZ and tZ.Type ~= "Lucky Block" then
                local t__1 = mV(v, tZ, tV)
                if t__1 > tX_2 then
                    tX_2 = t__1
                    tU = tY_2
                end
            end
        end
    end
    if tU then
        pcall(function()
            tT:EquipTool(tU)
        end)
    end
end
local nT = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = nh, Copyable = true }, "|", nX },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local n0 = {
    Info = nT:AddTab("Info", "info"),
    Main = nT:AddTab("Main", "gamepad-2"),
    Settings = nT:AddTab("Settings", "settings")
}
n0.Farm = n0.Main:AddSubTab("Farm", "dices")
n0.Base = n0.Main:AddSubTab("Base", "house")
n0.Upgrades = n0.Main:AddSubTab("Upgrades", "arrow-up")
local nV = fn658
for k, v in n0 do
    if v ~= n0.Main then
        nV(v)
    end
end
m3, vi_8, Label, mE, vi_1 = nil, nil, nil, nil, nil
vi_4 = 23
repeat
    vi_5 = (vi_4 * 2 + 1) % 3 + 1
    if vi_5 <= 2 then
        if vi_5 <= 1 then
            local wm = bit32.rrotate(bit32.bxor(bit32.lrotate(vi_4, 4), string.byte(tostring(Label))), 7)
            if bit32.bxor(bit32.lrotate(bit32.bxor(wm, 144501827), 30), 3257350928) == bit32.lrotate(wm, 30) then
                mE = tostring(game.JobId)
            else
                vi_1 = tostring(game.JobId)
            end
            vi_4 = (vi_4 + 20) % 24
        else
            vi_5 = (vector.create((vi_4 * 6 + 8) % 11 + 1, (vi_4 * 2 + 2) % 13 + 1, (vi_4 * 11 + 7) % 17 + 1))
            vi_3 = (vector.create((vi_4 * 3 + 8) % 11 + 1, (vi_4 * 11 + 5) % 13 + 1, (vi_4 * 10 + 12) % 17 + 1))
            nT = (vector.create((vi_4 * 3 + 4) % 11 + 1, (vi_4 * 7 + 4) % 13 + 1, (vi_4 * 9 + 17) % 17 + 1))
            nU = (vector.create((vi_4 * 1 + 3) % 5 + 1, (vi_4 * 3 + 4) % 7 + 1, (vi_4 * 1 + 5) % 9 + 1))
            if vector.dot(vector.cross(vi_5, (vector.cross(vi_3, nT))), nU) == vector.dot(vi_3 * vector.dot(vi_5, nT) - nT * vector.dot(vi_5, vi_3), nU) then
                vi_1 = #mE > 18
            else
                mE = #vi_1 > 18
            end
            vi_4 = (vi_4 + 11) % 24
        end
    else
        vi_5 = {
            "dxal",
            "afylulu",
            "liptixrsqx",
            "ilrwijjtqur",
            "rwwy",
            "zhrh",
            "ydusxmg",
            "giq",
            "yhwicv",
            "zfvei",
            "jwkemomkdi",
            "kixvyawbae"
        }
        local wp = vi_4
        vi_3 = vi_5[wp % 12 + 1]
        if vi_3:len() >= vi_3:reverse():rep(wp % 3 + 2):len() then
            pcall(fn778)
            n1 = (nil):AddLeftGroupbox("Account", "circle-user")
            n1:AddLabel(LocalPlayer("User", nil, vi_8), true)
            n1:AddLabel(LocalPlayer("Status", "Keyless", vi_8), true)
            n1:AddLabel(LocalPlayer("Executor", "Unknown", vi_8), true)
            m3 = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
            m3:AddLabel(Label(n0 .. " [" .. tostring(game.PlaceId) .. "]", ms), true)
            m3:AddLabel(LocalPlayer("Place ID", tostring(game.PlaceId), ms), true)
            nw = m3:AddLabel(LocalPlayer("Session time", "0s", mC), true)
        else
            m3 = "Unknown"
            pcall(fn778)
            vi_6 = n0.Info:AddLeftGroupbox("Account", "circle-user")
            vi_6:AddLabel(ms("User", LocalPlayer.Name, n3), true)
            vi_6:AddLabel(ms("Status", "Keyless", n3), true)
            vi_6:AddLabel(ms("Executor", m3, n3), true)
            vi_8 = n0.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            vi_8:AddLabel(mC(nX .. " [" .. tostring(game.PlaceId) .. "]", n1), true)
            vi_8:AddLabel(ms("Place ID", tostring(game.PlaceId), n1), true)
            Label = vi_8:AddLabel(ms("Session time", "0s", nw), true)
        end
        vi_4 = (vi_4 + 8) % 24
    end
until (vi_4 * 7 + 23) % 24 == 1
if vi_1 then
    vi_6 = 7
    repeat
        vi_4 = (vector.create((vi_6 * 2 + 8) % 11 + 1, (vi_6 * 5 + 3) % 13 + 1, (vi_6 * 7 + 2) % 17 + 1))
        vi_5 = (vector.create((vi_6 * 7 + 7) % 11 + 1, (vi_6 * 7 + 10) % 13 + 1, (vi_6 * 3 + 17) % 17 + 1))
        local wX = vector.dot(vi_4, vi_5)
        if wX * wX <= vector.dot(vi_4, vi_4) * vector.dot(vi_5, vi_5) then
            vi_1 = string.sub(mE, 1, 18) .. "..."
        else
            mE = string.sub(vi_1, 1, 18) .. "..."
        end
        vi_6 = (vi_6 + 5) % 8
    until (vi_6 * 7 + 3) % 8 == 7
end
vi_6 = vi_1 or mE
nM, mt, mq, connection, mT, nA = nil, nil, nil, nil, nil, nil
vi_4 = vi_6
vi_8:AddLabel(ms("Server", vi_4, n_), true)
vi_8:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
nM = os.clock()
task.spawn(worker)
local ScriptsGroup = n0.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(mC("Included in this hub", n_), true)
ScriptsGroup:AddLabel(mC(nX, n1), true)
local FeaturesGroup = n0.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(mC("Auto Farm", n1), true)
FeaturesGroup:AddLabel(mC("Base Automation", nw), true)
FeaturesGroup:AddLabel(mC("Upgrades", n_), true)
FeaturesGroup:AddLabel(mC("Protection", n3), true)
local SocialsGroup = n0.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = mN })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = n0.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = mN })
local FaqGroup = n0.Info:AddRightGroupbox("FAQ", "circle-help")
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
nV = n0.Farm:AddLeftGroupbox("Lucky Balls")
nV:AddToggle("AutoGetLuckyBalls", { Text = "Auto Get Lucky Balls", Default = false })
nV:AddDropdown("ZoneSelect", {
    Text = "Zones",
    Values = m8,
    Default = { "Common" },
    Multi = true,
    Searchable = true,
    AllowNull = true
})
nV:AddToggle("AutoGoBackBase", { Text = "Auto Go Back Base", Default = false })
nU = n0.Farm:AddRightGroupbox("Protection")
nU:AddToggle("AntiEnemy", { Text = "Anti Enemy", Default = true })
nT = n0.Base:AddLeftGroupbox("Base")
nT:AddToggle("AutoPlaceLuckyBalls", { Text = "Auto Place Lucky Balls", Default = false })
nT:AddToggle("AutoOpenLuckyBalls", { Text = "Auto Open Lucky Balls", Default = false })
nT:AddToggle("AutoCollectCash", { Text = "Auto Collect Cash", Default = false })
nT:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false })
vi_3 = n0.Upgrades:AddLeftGroupbox("Upgrades")
vi_3:AddToggle("AutoUpgradeJump", { Text = "Auto Upgrade Jump", Default = false })
vi_3:AddDropdown("JumpBuyAmount", { Text = "Jump Amount", Values = nW, Default = "+1 Jump" })
vi_3:AddToggle("AutoUpgradeCarry", { Text = "Auto Upgrade Carry Limit", Default = false })
vi_3:AddToggle("AutoUpgradeFloor", { Text = "Auto Upgrade Floor", Default = false })
vi_5 = n0.Upgrades:AddRightGroupbox("Rebirth")
vi_5:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
vi_1 = n0.Settings:AddLeftGroupbox("Menu")
vi_1:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
vi_1:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
vi_1:AddButton("Unload", onUnload)
Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(n0.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/jump-to-steal-slime")
SaveManager:BuildConfigSection(n0.Settings)
SaveManager:LoadAutoloadConfig()
mt = tick()
if (nA and not FeaturesGroup or (not FaqGroup or FaqGroup) or not nM and FeaturesGroup and (FaqGroup and 24) or (not nM or not FaqGroup or TempoHubGroup and not TempoHubGroup) and (not nA and 24 or TempoHubGroup and not FeaturesGroup)) and ((not FaqGroup and not nA or (not FeaturesGroup or FeaturesGroup)) and (not FeaturesGroup or not TempoHubGroup or (not FaqGroup or not TempoHubGroup)) or nM and FeaturesGroup and (FaqGroup and not nA) and ((FeaturesGroup or not nA) and (nA or not nA))) and not ((nA and not FeaturesGroup or (not FaqGroup or FaqGroup) or not nM and FeaturesGroup and (FaqGroup and 24) or (not nM or not FaqGroup or TempoHubGroup and not TempoHubGroup) and (not nA and 24 or TempoHubGroup and not FeaturesGroup)) and ((not FaqGroup and not nA or (not FeaturesGroup or FeaturesGroup)) and (not FeaturesGroup or not TempoHubGroup or (not FaqGroup or not TempoHubGroup)) or nM and FeaturesGroup and (FaqGroup and not nA) and ((FeaturesGroup or not nA) and (nA or not nA)))) then
    mT = tick()
    pcall(function()
        for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
            local uB = v
            pcall(function()
                uB:Disable()
            end)
        end
    end)
    mq = connection.InputBegan:Connect(onInputBegan)
    nA = connection.InputChanged:Connect(onInputChanged)
else
    mq = tick()
    pcall(function()
        for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
            local uB = v
            pcall(function()
                uB:Disable()
            end)
        end
    end)
    nA = fn218
    connection = UserInputService.InputBegan:Connect(onInputBegan)
    mT = UserInputService.InputChanged:Connect(onInputChanged)
end
Library:OnUnload(fn613)
task.spawn(worker2)
Guardians.ChildAdded:Connect(function(iu)
    task.defer(function()
        local uO = if nm("AntiEnemy") then 1 else 0
        if uO == 1 then
            m9(iu)
        end
    end)
end)
RunService.Heartbeat:Connect(onHeartbeat)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
task.spawn(worker6)
end)(...)

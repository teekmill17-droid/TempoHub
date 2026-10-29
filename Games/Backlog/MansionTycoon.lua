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
getgenv().TempoHoodSubtitle = "MANSION TYCOON"
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
local iu
local jb
local iT
local iA
local Label
local iZ
local iG
local im
local connection
local iM
local it
local ja
local VirtualUser
local iz
local Generation
local iY
local TycoonService
local connection3
local iL
local is
local i9
local iR
local CurrentCamera
local id
local iX
local iE
local TempoMansionTycoon
local i2
local iK
local connection4
local i8
local iQ
local ix
local ic
local UserInputService
local connection2
local ij
local i1
local iJ
local iq
local i7
local iP
local iw
local Options
local iV
local iC
local Toggles
local i0
local LocalPlayer
local ip
local i6
local iO
local iv
local ia
local PlayerDataController
local iB
local ih
local i_
local iH
local SaveManager
local ReplicatedStorage
local HttpService
local function onUnload()
    iw:Unload()
end
local function fn114(Z, aa, ab)
    return string.format("<b>%s</b> %s %s", Z, iM("-", "#5a6070"), iM(aa, ab))
end
local function worker()
    local j8_1
    while true do
        task.wait(1)
        if iw.Unloaded then
            break
        end
        local j7 = math.floor(os.clock() - iH)
        if j7 < 60 then
            j8_1 = j7 .. "s"
        elseif j7 < 3600 then
            j8_1 = string.format("%dm %ds", math.floor((j7) / (60)), j7 % 60)
        else
            j8_1 = string.format("%dh %dm", math.floor((j7) / (3600)), math.floor((j7 % 3600) / (60)))
        end
        Label:SetText(ix("Session time", j8_1, iX))
    end
end
local function fn135()
    if Toggles.AutoCollect.Value then
        iK()
    end
end
local function fn140()
    local jZ_1
    local jY_1
    if identifyexecutor then
        jZ_1, jY_1 = identifyexecutor()
        local j_ = jZ_1 ~= ""
        local j0 = type(jZ_1) == "string" and j_
        if j0 then
            local j__1 = type(jY_1) == "string" and jY_1 ~= "" and jZ_1 .. " " .. jY_1
            iR = j__1 or jZ_1
        end
    end
end
local function fn151()
    PlayerDataController = require(ReplicatedStorage.ClientModules.Controllers.PlayerDataController)
end
local function onCopyJoinScript_JobID()
    local j5 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, jb)
    if setclipboard then
        setclipboard(j5)
    elseif toclipboard then
        toclipboard(j5)
    end
    iw:Notify("Copied join script to clipboard")
end
local function fn185(bJ)
    local Buttons = bJ:FindFirstChild("Buttons")
    if not Buttons then
        return {}
    end
    local kI = {}
    for i, child in Buttons:GetChildren() do
        local attr = child:GetAttribute("Price")
        local kJ = type(attr) == "number" and child:GetAttribute("Purchasable") ~= false
        if kJ then
            local Touch = child:FindFirstChild("Touch")
            local kK = Touch and Touch:IsA("BasePart") and Touch.CanTouch
            if kK then
                table.insert(kI, { Name = child.Name, Price = attr, Touch = Touch })
            end
        end
    end
    table.sort(kI, function(bS, bT)
        return bS.Price > bT.Price
    end)
    return kI
end
local function fn210()
    local nq = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local nr = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if nr then
                local nr_1 = is(k, v)
                if nr_1 then
                    nq[#nq + 1] = nr_1
                end
            end
        end
    end
    table.sort(nq, function(fk, fl)
        if fk.type ~= fl.type then
            return fk.type < fl.type
        end
        return fk.idx < fl.idx
    end)
    return { objects = nq }
end
local function fn224()
    local ly = iJ()
    if not ly then
        return false
    end
    local lz = {}
    for k, v in Options.MansionTargets:GetActiveValues() do
        lz[v] = true
    end
    local lA = iT()
    local lB = 1 + Options.MansionBuffer.Value / 100
    for i, v in ipairs(ic) do
        local lC = not ly[v.name]
        if lC ~= false then
            lC = ly[v.prev]
        end
        if lC then
            lC = lz[v.display]
        end
        if lC then
            if i0(v.prev) >= 0.999 then
                if lA >= v.cost * lB then
                    TycoonService.PurchaseTycoon:FireServer(v.name)
                    task.wait(1)
                    return true
                end
            end
        end
    end
    return false
end
local function fn247()
    pcall(function()
        iw:Unload()
    end)
end
local function onCopyEthereumAddress()
    i8(it, "Copied Ethereum address")
end
local function fn270()
    local Character = LocalPlayer.Character
    local mb = Character and Character:FindFirstChild("HumanoidRootPart")
    return mb
end
local function fn279()
    return TempoMansionTycoon.Generation == Generation
end
local function onCopyUSDTAddress()
    i8(im, "Copied USDT address")
end
local function fn292()
    return Options.MansionInterval.Value
end
local function fn294(e_, e0)
    local nd_1 = (e_ == "Toggle" and Toggles or Options)[e0]
    local nc_2 = type(nd_1) == "table" and nd_1.Type == e_
    return nc_2 and nd_1 or nil
end
local function fn328()
    local Character = LocalPlayer.Character
    local l8 = Character and Character:FindFirstChildOfClass("Humanoid")
    return l8
end
local function fn332()
    if not Toggles.Fly.Value then
        local mI = ip()
        if mI then
            mI.PlatformStand = false
        end
    end
end
local function fn342()
    return Options.BuyInterval.Value
end
local function fn354()
    local kW_1
    local kV_1
    if not PlayerDataController then
        return nil
    end
    kV_1, kW_1 = pcall(function()
        return PlayerDataController:GetIndex({ "OwnedTycoons" })
    end)
    local kX = kV_1 and type(kW_1) == "table"
    if kX then
        local kV_2 = {}
        for k, v in kW_1 do
            kV_2[v] = true
        end
        return kV_2
    end
    return nil
end
local function fn363()
    local lQ = iJ()
    if not lQ then
        return false
    elseif tick() - i1 < i9 then
        return false
    else
        local lR
        for i, v in ipairs(ic) do
            if lQ[v.name] then
                lR = v
            end
        end
        if not lR then
            return false
        end
        local lQ_1 = iZ()
        if lR.name == lQ_1 then
            return false
        end
        TycoonService.SwitchMansion:FireServer(lR.name)
        i1 = tick()
        return true
    end
end
local function antiAfkLoop()
    while not iw.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local m5 = tick() - iG
            local m6 = tick() - iC
            if m5 >= 300 and m6 >= 60 then
                pcall(id)
            else
                if m5 < 300 and m6 >= 300 then
                    pcall(id)
                end
            end
        end
    end
end
local function onRenderStepped(dZ)
    if iw.Unloaded or not Toggles or not Options then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local mB_3 = ip()
        if mB_3 then
            mB_3.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local mB_5 = i2()
        local mC_1 = ip()
        if mB_5 and mC_1 then
            mC_1.PlatformStand = true
            local mC_2 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                mC_2 = mC_2 + CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                mC_2 = mC_2 - CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                mC_2 = mC_2 - CurrentCamera.CFrame.RightVector
            end
            local mH = if UserInputService:IsKeyDown(Enum.KeyCode.D) then 1 else 0
            if mH == 1 then
                mC_2 = mC_2 + CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                mC_2 = mC_2 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                mC_2 = mC_2 - Vector3.new(0, 1, 0)
            end
            mB_5.Velocity = Vector3.zero
            if mC_2.Magnitude > 0 then
                mB_5.CFrame = mB_5.CFrame + mC_2.Unit * Options.FlySpeed.Value * dZ
            end
        end
    end
end
local function fn415()
    return Options.CollectInterval.Value
end
local function fn416()
    local kf_1, kf_5
    local ke_1, leaderstats, ke_5
    if PlayerDataController then
        ke_1, kf_1 = pcall(function()
            return PlayerDataController:GetIndex({ "Money" })
        end)
        local kg = ke_1 and type(kf_1) == "number" and kf_1 >= 0
        if kg then
            return kf_1
        end
        local leaderstats2 = LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats then
            local kf_2 = leaderstats2:FindFirstChild("Money") or leaderstats2:FindFirstChild("Cash")
            if ke_5 then
                local kf_3 = tonumber(kf_2.Value)
                if kf_5 then
                    return kf_3
                end
                return 0
            end
            return 0
        end
        return 0
    end
    leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local kf_4 = leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Cash")
        ke_5 = kf_4
        if ke_5 then
            kf_5 = tonumber(ke_5.Value)
            if kf_5 then
                return kf_5
            end
            return 0
        end
        return 0
    end
    return 0
end
local function fn420()
    if Toggles.AutoSwitch.Value then
        iv()
    end
end
local function fn424()
    if Toggles.AutoMansion.Value then
        iL()
    end
end
local function fn464()
    return Options.SwitchInterval.Value
end
local function fn473()
    iP(Toggles.AntiGameplayPause.Value)
end
local function fn475()
    local k6_1
    local k5_1
    local k4
    if PlayerDataController then
        k5_1, k6_1 = pcall(function()
            return PlayerDataController:GetIndex({ "CurrentTycoonTypeByPlot" })
        end)
        local k7 = k5_1 and type(k6_1) == "table"
        if k7 then
            k4 = k6_1.Plot1
        end
    end
    if not k4 then
        local k5_2 = iq()
        if k5_2 then
            k4 = k5_2.Name
        end
    end
    return k4
end
local function fn493(Q)
    local DiscordGroup = Q:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = iO })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = iO })
end
local function fn499()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    iC = tick()
end
local function fn504()
    local lo = iq()
    if not lo then
        return false
    end
    local lp = iE(lo)
    if #lp == 0 then
        return false
    end
    local lo_1 = 1 + Options.BuyBuffer.Value / 100
    local lq = false
    for i, v in ipairs(lp) do
        local lp_1 = not ja() or iw.Unloaded
        if lp_1 then
            break
        elseif iT() >= v.Price * lo_1 then
            ij(v.Touch)
            task.wait(0.55)
            lq = true
        end
    end
    return lq
end
local function fn533()
    if not Toggles.WalkSpeedEnabled.Value then
        local mK = ip()
        if mK then
            mK.WalkSpeed = 16
        end
    end
end
local function onCopyLitecoinAddress()
    i8(iB, "Copied Litecoin address")
end
local function onCopyPayPalLink()
    i8(ia, "Copied PayPal link")
end
local function fn567(cc)
    local Character = LocalPlayer.Character
    if not Character then
        return false
    end
    local Humanoid = Character:FindFirstChild("Humanoid")
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not HumanoidRootPart then
        return false
    end
    Humanoid.PlatformStand = true
    HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    Character:PivotTo(cc.CFrame * CFrame.new(0, iY, 0))
    task.wait(0.25)
    HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    Humanoid.PlatformStand = false
    return true
end
local function fn581()
    iP(false)
end
local function fn597(e7, e8)
    local Type = e8.Type
    if Type == "Toggle" then
        return { idx = e7, type = "Toggle", value = e8.Value == true }
    elseif Type == "Slider" then
        return { idx = e7, type = "Slider", value = tostring(e8.Value) }
    elseif Type == "Dropdown" then
        return { idx = e7, type = "Dropdown", multi = e8.Multi == true, value = e8.Value }
    elseif Type == "Input" then
        local nh = e8.Value or ""
        return { idx = e7, type = "Input", text = tostring(nh) }
    elseif Type == "ColorPicker" then
        return { idx = e7, type = "ColorPicker", value = e8.Value:ToHex(), transparency = e8.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = e7,
            type = "KeyPicker",
            mode = e8.Mode,
            key = e8.Value,
            modifiers = e8.Modifiers,
            toggled = e8.Toggled
        }
    else
        return nil
    end
end
local function fn609(W, X)
    return string.format('<font color="%s">%s</font>', X, W)
end
local function onJumpRequest()
    if iw.Unloaded or not Toggles then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local mv_2 = ip()
        if mv_2 then
            mv_2:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function onRscripts()
    if setclipboard then
        setclipboard(iu)
    elseif toclipboard then
        toclipboard(iu)
    end
    iw:Notify("Copied Rscripts profile to clipboard")
end
local function antiGameplayPauseLoop()
    while not iw.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            iP(true)
        end
    end
end
local function fn639()
    if Toggles.AutoBuy.Value then
        iV()
    end
end
local function onCopySolanaAddress()
    i8(ih, "Copied Solana address")
end
local function fn672(F, G)
    if setclipboard then
        setclipboard(F)
    elseif toclipboard then
        toclipboard(F)
    end
    iw:Notify(G)
end
local function fn680()
    iQ:Disconnect()
    connection4:Disconnect()
    connection:Disconnect()
    connection2:Disconnect()
    connection3:Disconnect()
end
local function onCopyVenmoLink()
    i8(i7, "Copied Venmo link")
end
local function onInputChanged(eE)
    local UserInputType = eE.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        iG = tick()
    end
end
local function onExportConfigToClipboard()
    local nU_1
    local nT_1
    nT_1, nU_1 = pcall(HttpService.JSONEncode, HttpService, i6())
    if not nT_1 then
        iw:Notify("Failed to encode the config")
        return
    end
    local nT_2 = setclipboard or toclipboard
    local nT_3 = type(nT_2) ~= "function" or not pcall(nT_2, nU_1)
    if nT_3 then
        iw:Notify("Your executor does not support copying to the clipboard")
        return
    end
    iw:Notify("Config copied to clipboard", 6)
end
local function onImportConfigFromClipboardTex()
    local nZ_1
    local nX = Options.SaveManager_ImportSource.Value or ""
    local nX_1
    local nY = tostring(nX):match("^%s*(.-)%s*$")
    if nY == "" then
        iw:Notify("Paste an exported config into the box first")
        return
    end
    nX_1, nZ_1 = pcall(HttpService.JSONDecode, HttpService, nY)
    local nY_1 = not nX_1
    local n2 = if nY_1 then 1 else 0
    local n0 = 3051 * n2 + 256 * (1 - n2)
    local n1 = 1277 * n2 + 219 * (1 - n2)
    if not ((n0 * 4084 + n1 * 4060 + n0 * n1) % 16777213 == 4763818) then
        nY_1 = type(nZ_1) ~= "table"
    end
    if not nY_1 then
        nY_1 = type(nZ_1.objects) ~= "table"
    end
    if nY_1 then
        iw:Notify("That is not a valid exported config")
        return
    end
    local nX_2 = 0
    for i, v in ipairs(nZ_1.objects) do
        if i_(v) then
            nX_2 += 1
        end
    end
    if nX_2 == 0 then
        iw:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local nZ_2 = nX_2 == 1 and "" or "s"
    iw:Notify(("Imported %d setting%s"):format(nX_2, nZ_2), 6)
end
local function fn748()
    local lf = iq()
    if not lf then
        return false
    end
    local Collectors = lf:FindFirstChild("Collectors")
    if not Collectors then
        return false
    end
    for i, child in Collectors:GetChildren() do
        local lf_1 = child.PrimaryPart or child:FindFirstChild("Touch")
        local lg_1 = lf_1
        if lf_1 then
            lf_1 = lg_1:IsA("BasePart")
        end
        if lf_1 then
            lf_1 = lg_1.CanTouch
        end
        if lf_1 then
            ij(lg_1)
            task.wait(0.55)
            return true
        end
    end
    return false
end
local function fn752()
    for i, child in workspace.Tycoons:GetChildren() do
        for i, child in child:GetChildren() do
            for i, child in child:GetChildren() do
                local km = child:IsA("Model") and child:GetAttribute("OwnerId") == LocalPlayer.UserId
                if km then
                    return child
                end
            end
        end
    end
    return nil
end
local function onInputBegan()
    iG = tick()
end
local function onStepped()
    if iw.Unloaded or not Toggles then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local mg_3 = descendant:IsA("BasePart") and descendant.CanCollide
                if mg_3 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function onCopyBitcoinAddress()
    i8(iA, "Copied Bitcoin address")
end
local function fn800()
    i8(iz, "Copied Discord invite to clipboard")
end
ia = nil
Options = nil
ic = nil
id = nil
Generation = nil
Label = nil
ih = nil
Toggles = nil
ij = nil
TempoMansionTycoon = nil
connection3 = nil
im = nil
SaveManager = nil
ip = nil
iq = nil
connection4 = nil
is = nil
it = nil
iu = nil
iv = nil
iw = nil
ix = nil
CurrentCamera = nil
iz = nil
iA = nil
iB = nil
iC = nil
connection2 = nil
iE = nil
TycoonService = nil
iG = nil
iH = nil
LocalPlayer = nil
iJ = nil
iK = nil
iL = nil
iM = nil
HttpService = nil
iO = nil
iP = nil
iQ = nil
iR = nil
VirtualUser = nil
iT = nil
PlayerDataController = nil
iV = nil
UserInputService = nil
iX = nil
iY = nil
iZ = nil
i_ = nil
i0 = nil
i1 = nil
i2 = nil
connection = nil
ReplicatedStorage = nil
i6 = nil
i7 = nil
i8 = nil
i9 = nil
ja = nil
jb = nil
local i3, jk
local jm_1
local ji_1
ReplicatedStorage, UserInputService, VirtualUser, HttpService, LocalPlayer, iz, iu = nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local jc_4
ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
LocalPlayer = Players.LocalPlayer
local jf = "Mansion Tycoon"
iz = "https://discord.gg/K7Qxnxkk46"
iu = "https://discord.gg/K7Qxnxkk46"
local je = getgenv()
local jc_1 = {}
local jd = je.TempoMansionTycoon
local jQ = if jd then 1 else 0
local jO = 2838 * jQ + 1745 * (1 - jQ)
local jP = 1814 * jQ + 2175 * (1 - jQ)
if not ((jO * 681 + jP * 3299 + jO * jP) % 16777213 == 13065196) then
    jd = jc_1
end
TempoMansionTycoon = nil
local jh = 6
repeat
    local jc_2 = {
        "psczdjmoej",
        "rqb",
        "xlgh",
        "itpi",
        "cflf",
        "rxda",
        "uminr",
        "zeuv",
        "jilwsvjl",
        "rfcmfmyxbrf",
        "xuccriadp"
    }
    if jc_2[(jh * 47 + 49) % 11 + 1] < jc_2[(jh * 47 + 49) % 11 + 1] then
        je.TempoMansionTycoon = TempoMansionTycoon
        je = jd.TempoMansionTycoon
    else
        je.TempoMansionTycoon = jd
        TempoMansionTycoon = je.TempoMansionTycoon
    end
    jh = (jh + 0) % 8
until (jh * 3 + 2) % 8 == 4
if type(TempoMansionTycoon.Unload) == "function" then
    pcall(TempoMansionTycoon.Unload)
end
local jc_3 = TempoMansionTycoon.Generation
jQ = if jc_3 then 1 else 0
jO = 1127 * jQ + 3327 * (1 - jQ)
jP = 1197 * jQ + 1045 * (1 - jQ)
if not ((jO * 2279 + jP * 651 + jO * jP) % 16777213 == 4696699) then
    jc_3 = 0
end
Generation, PlayerDataController, TycoonService, iw, SaveManager, Toggles, Options, ja, i8, iO, ji_1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
TempoMansionTycoon.Generation = jc_3 + 1
Generation = TempoMansionTycoon.Generation
ja = fn279
pcall(fn151)
setthreadidentity(8)
TycoonService = ReplicatedStorage.__remotes.TycoonService
local je_1 = ""
iw = getgenv().Library
if (iw and (PlayerDataController and PlayerDataController) or false) and ((PlayerDataController or false) and (not PlayerDataController and not iw) or (ji_1 or false or (not iw or not iw))) and ((PlayerDataController and iw or (PlayerDataController or je_1) or (not ji_1 or not PlayerDataController) and (false and not iw)) and (not ji_1 and ji_1 and (not iw and iw) or 54)) and not ((iw and (PlayerDataController and PlayerDataController) or false) and ((PlayerDataController or false) and (not PlayerDataController and not iw) or (ji_1 or false or (not iw or not iw))) and ((PlayerDataController and iw or (PlayerDataController or je_1) or (not ji_1 or not PlayerDataController) and (false and not iw)) and (not ji_1 and ji_1 and (not iw and iw) or 54))) then
    iw = getgenv().ThemeManager
    jk = getgenv().SaveManager
    SaveManager = nil
else
    jk = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
    Toggles = iw.Toggles
end
Options = iw.Options
i8 = fn672
iO = fn800
local Window = iw:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = iz, Copyable = true }, "|", jf },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
TempoMansionTycoon.Unload = fn247
local jj = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gavel"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
jj.Collect = jj.Main:AddSubTab("Collect", "coins")
jj.Buy = jj.Main:AddSubTab("Buy Buttons", "shopping-cart")
jj.Progression = jj.Main:AddSubTab("Progression", "crown")
for k, v in jj do
    if v ~= jj.Main then
        fn493(v)
    end
end
jm_1, iX, iR, jc_4, Label, jb, iM, ix = nil, nil, nil, nil, nil, nil, nil, nil
iM = fn609
if ((not Label or 9 or false) and (false and Label or (not Label or 9)) and 9 or ("#6ec1ff" and (Label and jm_1 and false) or jm_1 and not Label and (not jc_4 and false) and (Label or jm_1))) and not ((not Label or 9 or false) and (false and Label or (not Label or 9)) and 9 or ("#6ec1ff" and (Label and jm_1 and false) or jm_1 and not Label and (not jc_4 and false) and (Label or jm_1))) then
    iR = fn114
else
    ix = fn114
end
local jn = "#7fd47f"
local jm_2 = "#6ec1ff"
iX = "#e8a34d"
local jl = "#8b93a3"
iR = "Unknown"
pcall(fn140)
local AccountGroup = jj.Info:AddLeftGroupbox("Account", "circle-user")
AccountGroup:AddLabel(ix("User", LocalPlayer.Name, jn), true)
AccountGroup:AddLabel(ix("Status", "Keyless", jn), true)
AccountGroup:AddLabel(ix("Executor", iR, jn), true)
jh = jj.Info:AddLeftGroupbox("Game Info", "gamepad-2")
jh:AddLabel(iM(jf .. " [" .. tostring(game.PlaceId) .. "]", jm_2), true)
jh:AddLabel(ix("Place ID", tostring(game.PlaceId), jm_2), true)
Label = jh:AddLabel(ix("Session time", "0s", iX), true)
jb = tostring(game.JobId)
local je_2 = #jb > 18
if je_2 then
    local jc_6 = 2
    repeat
        local o0 = bit32.rrotate(bit32.bxor(bit32.lrotate(jc_6, 7), string.byte(tostring(jc_6))), 5)
        if bit32.bxor(bit32.lrotate(bit32.bxor(o0, 281176382), 4), 203854817) ~= bit32.lrotate(o0, 4) then
            jb = string.sub(je_2, 1, 18) .. "..."
        else
            je_2 = string.sub(jb, 1, 18) .. "..."
        end
        jc_6 = (jc_6 + 3) % 4
    until (jc_6 * 1 + 0) % 4 == 1
end
local jc_7 = je_2 or jb
iH, iB, iA, it, im, ih, ia, i7, ic, i9, i1, iY, connection, connection2, CurrentCamera, connection3, iG, iC, iQ, connection4, iT, i0, iq, iE, iJ, iZ, ij, iK, iV, iL, iv, ip, i2, iP, id, i3, is, i6, i_ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
jh:AddLabel(ix("Server", jc_7, jl), true)
jh:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
iH = os.clock()
task.spawn(worker)
local ScriptsGroup = jj.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(iM("Included in this hub", jl), true)
ScriptsGroup:AddLabel(iM(jf, jm_2), true)
local FeaturesGroup = jj.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(iM("Auto Collect Income", jm_2), true)
FeaturesGroup:AddLabel(iM("Auto Buy Buttons", iX), true)
FeaturesGroup:AddLabel(iM("Mansion Progression", jn), true)
local SocialsGroup = jj.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = iO })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = jj.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = iO })
iB = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
iA = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
it = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
im = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
ih = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
ia = ""
i7 = ""
local jE = "#345d9d"
local jB = "#f7931a"
local jz = "#627eea"
local jy = "#26a17b"
local jv = "#14f195"
local DonationsGroup = jj.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(iM("All donations are optional but appreciated.", iX), true)
DonationsGroup:AddLabel(iM("If you donate you get a special role, just PING after you donate.", jn), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(iM("LTC / Litecoin", jE), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(iM("BTC / Bitcoin", jB), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(iM("ETH / Ethereum", jz), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(iM("USDT", jy), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(iM("Solana", jv), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(iM("PayPal", "#0070ba"), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(iM("Venmo", "#008cff"), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(iM("Don't have any of the listed currencies but still wanna donate?", jl), true)
DonationsGroup:AddLabel(iM("DM me and we'll work something out.", jm_2), true)
local FaqGroup = jj.Info:AddRightGroupbox("FAQ", "circle-help")
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
ic = {
    { name = "Mansion2", display = "Mansion 2", cost = 1000000, prev = "Mansion" },
    { name = "BeachMansion", display = "Beach Mansion", cost = 2500000, prev = "Mansion2" },
    { name = "Mansion3", display = "Mansion 3", cost = 5000000, prev = "Mansion2" },
    { name = "YachtMansion", display = "Yacht Mansion", cost = 8000000, prev = "Mansion3" },
    { name = "Mansion4", display = "Mansion 4", cost = 10000000, prev = "Mansion3" },
    { name = "Penthouse", display = "Penthouse", cost = 20000000, prev = "Mansion4" }
}
i9 = 35
i1 = 0
iY = 1.4
iT = fn416
i0 = function(bs)
    local kj_1
    local ki_1
    ki_1, kj_1 = pcall(function()
        return TycoonService.GetTycoonProgress:InvokeServer(bs)
    end)
    local kk = ki_1 and type(kj_1) == "number"
    if kk then
        return kj_1
    end
    return 0
end
iq = fn752
iE = fn185
iJ = fn354
iZ = fn475
ij = fn567
iK = fn748
iV = fn504
iL = fn224
iv = fn363
local function jq(c9, da)
    task.spawn(function()
        while true do
            local lZ = ja() and not iw.Unloaded
            if lZ then
                pcall(c9)
                task.wait(da())
                continue
            end
            break
        end
    end)
end
local IncomeGroup = jj.Collect:AddRightGroupbox("Income", "banknote")
IncomeGroup:AddToggle("AutoCollect", { Text = "Auto Collect Income", Default = false })
IncomeGroup:AddSlider("CollectInterval", { Text = "Collect Interval", Default = 2, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
jq(fn135, fn415)
local PurchasesGroup = jj.Buy:AddRightGroupbox("Purchases", "shopping-cart")
PurchasesGroup:AddToggle("AutoBuy", { Text = "Auto Buy All Buttons", Default = false })
PurchasesGroup:AddSlider("BuyInterval", { Text = "Buy Interval", Default = 1.5, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
PurchasesGroup:AddSlider("BuyBuffer", { Text = "Price Buffer", Default = 10, Min = 5, Max = 15, Rounding = 0, Suffix = "%" })
jq(fn639, fn342)
local MansionProgressionGroup = jj.Progression:AddRightGroupbox("Mansion Progression", "crown")
MansionProgressionGroup:AddToggle("AutoMansion", { Text = "Auto Buy Next Mansion", Default = false })
MansionProgressionGroup:AddSlider("MansionInterval", { Text = "Buy Check Interval", Default = 3, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
MansionProgressionGroup:AddSlider("MansionBuffer", { Text = "Purchase Buffer", Default = 10, Min = 5, Max = 15, Rounding = 0, Suffix = "%" })
MansionProgressionGroup:AddToggle("AutoSwitch", { Text = "Auto Switch Mansion", Default = false })
MansionProgressionGroup:AddSlider("SwitchInterval", { Text = "Switch Check Interval", Default = 5, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
MansionProgressionGroup:AddDropdown("MansionTargets", {
    Values = { "Mansion 2", "Beach Mansion", "Mansion 3", "Yacht Mansion", "Mansion 4", "Penthouse" },
    Multi = true,
    Default = {
        ["Mansion 2"] = true,
        ["Beach Mansion"] = true,
        ["Mansion 3"] = true,
        ["Yacht Mansion"] = true,
        ["Mansion 4"] = true,
        Penthouse = true
    },
    SelectAllButtons = true,
    Searchable = true,
    Expandable = true,
    ExpandColumns = 3,
    Text = "Mansions to Buy"
})
jq(fn424, fn292)
jq(fn420, fn464)
local MovementGroup = jj.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = jj.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
ip = fn328
i2 = fn270
connection = RunService.Stepped:Connect(onStepped)
connection2 = UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
connection3 = RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fn332)
Toggles.WalkSpeedEnabled:OnChanged(fn533)
iP = function(ef)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not ef)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not ef
        end
    end)
    if not ef then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(LocalPlayer, "GameplayPaused", false)
        else
            LocalPlayer.GameplayPaused = false
        end
    end)
end
Toggles.AntiGameplayPause:OnChanged(fn473)
task.spawn(antiGameplayPauseLoop)
iw:OnUnload(fn581)
local MenuGroup = jj.Settings:AddLeftGroupbox("Menu")
if (not ScriptsGroup or FlyGroup or jc_7 and jc_7 or ScriptsGroup and FlyGroup and (not iH or iH)) and ((FlyGroup or not jc_7 or not iH and not ic) and (not FlyGroup and not iH or not ic and not ScriptsGroup)) and ((FlyGroup and not FlyGroup and (false and ic) or (jc_7 and ScriptsGroup or (FlyGroup or false))) and (not ic or FlyGroup or jc_7 and not FlyGroup or (not ScriptsGroup or not ScriptsGroup or (ScriptsGroup or false)))) or not ((not ScriptsGroup or FlyGroup or jc_7 and jc_7 or ScriptsGroup and FlyGroup and (not iH or iH)) and ((FlyGroup or not jc_7 or not iH and not ic) and (not FlyGroup and not iH or not ic and not ScriptsGroup)) and ((FlyGroup and not FlyGroup and (false and ic) or (jc_7 and ScriptsGroup or (FlyGroup or false))) and (not ic or FlyGroup or jc_7 and not FlyGroup or (not ScriptsGroup or not ScriptsGroup or (ScriptsGroup or false))))) then
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    iw.ToggleKeybind = Options.MenuKeybind
    iG = tick()
    iC = tick()
    pcall(function()
        for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
            local mX = v
            pcall(function()
                mX:Disable()
            end)
        end
    end)
    id = fn499
    iQ = UserInputService.InputBegan:Connect(onInputBegan)
    connection4 = UserInputService.InputChanged:Connect(onInputChanged)
else
    connection4:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { NoUI = true, Text = "Menu keybind", Default = "RightShift" })
    Options.ToggleKeybind = UserInputService.MenuKeybind
    iQ = tick()
    iw = tick()
    pcall(function()
        for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
            local mX = v
            pcall(function()
                mX:Disable()
            end)
        end
    end)
    iC = fn499
    iG = MenuGroup.InputBegan:Connect(onInputBegan)
    id = MenuGroup.InputChanged:Connect(onInputChanged)
end
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(antiAfkLoop)
MenuGroup:AddButton("Unload", onUnload)
iw:OnUnload(fn680)
jk:SetLibrary(iw)
jk:SetFolder("TempoHub")
jk:SaveDefault("Monochrome")
jk:ApplyToTab(jj.Settings)
jk:LoadDefault()
SaveManager:SetLibrary(iw)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/MansionTycoon")
local jH = SaveManager:BuildConfigSection(jj.Settings)
SaveManager:LoadAutoloadConfig()
i3 = fn294
is = fn597
i6 = fn210
i_ = function(fn)
    local nK
    nK = nil
    local nL = type(fn) ~= "table"
    local nP = if nL then 1 else 0
    local nN = 1961 * nP + 343 * (1 - nP)
    local nO = 217 * nP + 1715 * (1 - nP)
    if not ((nN * 417 + nO * 3620 + nN * nO) % 16777213 == 2028814) then
        nL = type(fn.idx) ~= "string"
    end
    if not nL then
        nL = type(fn.type) ~= "string"
    end
    if not nL then
        nL = SaveManager.Ignore[fn.idx]
    end
    if nL then
        return false
    end
    nK = i3(fn.type, fn.idx)
    if not nK then
        return false
    end
    local nL_1 = pcall(function()
        if fn.type == "Input" then
            if type(fn.text) ~= "string" then
                return
            end
            nK:SetValue(fn.text)
        elseif fn.type == "ColorPicker" then
            nK:SetValueRGB(Color3.fromHex(fn.value), fn.transparency)
        elseif fn.type == "KeyPicker" then
            nK:SetValue({ fn.key, fn.mode, fn.modifiers })
            if fn.mode == "Toggle" and fn.toggled ~= nil then
                nK.Toggled = fn.toggled
                nK:Update()
            end
        else
            nK:SetValue(fn.value)
        end
    end)
    return nL_1
end
if (iT and false and (false or iT) or false or (false or not is and i0) and ((is or jq) and 35)) and not (iT and false and (false or iT) or false or (false or not is and i0) and ((is or jq) and 35)) then
    jH:AddDivider()
    jH:AddInput("SaveManager_ImportSource", { AllowEmpty = true, Finished = true, Text = "Paste exported config here" })
    jH:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
    jH:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
else
    jH:AddDivider()
    jH:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    jH:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
    jH:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
end
end)(...)

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
getgenv().TempoHoodSubtitle = "ROLL A SPIRIT"
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
local Toggles
local kc
local jU
local connection2
local ki
local j_
local jH
local j5
local jN
local ju
local kb
local jT
local CurrentCamera
local TempoGen
local jZ
local jG
local j4
local jM
local RingConfig
local ka
local HttpService
local SpiritDex
local kg
local jY
local jF
local j3
local Options
local j9
local jR
local jy
local kf
local jX
local jE
local j2
local jK
local RebirthConfig
local j8
local jQ
local PendantConfig
local ke
local jW
local jD
local kk
local j1
local jJ
local jq
local j7
local connection
local jw
local kd
local jV
local Remotes
local kj
local j0
local jI
local jO
local function fn16()
    kc("EquipBest")
end
local function onInputChanged(dO)
    local UserInputType = dO.UserInputType
    local nw = UserInputType == Enum.UserInputType.MouseMovement
    local nA = if nw then 1 else 0
    local ny = 1368 * nA + 2461 * (1 - nA)
    local nz = 1102 * nA + 3207 * (1 - nA)
    if not ((ny * 2917 + nz * 2170 + ny * nz) % 16777213 == 7889332) then
        nw = UserInputType == Enum.UserInputType.Gamepad1
    end
    if nw then
        kd = tick()
    end
end
local function fn41(bo, bp, bq)
    return string.format("<b>%s</b> %s %s", bo, jT("-", "#5a6070"), jT(bp, bq))
end
local function onRscripts()
    if setclipboard then
        setclipboard(jG)
    elseif toclipboard then
        toclipboard(jG)
    end
    jI:Notify("Copied Rscripts profile to clipboard")
end
local function worker()
    local mv_1
    while true do
        task.wait(1)
        if jI.Unloaded then
            break
        end
        local mu = math.floor(os.clock() - jR)
        if mu < 60 then
            mv_1 = mu .. "s"
        elseif mu < 3600 then
            mv_1 = string.format("%dm %ds", math.floor((mu) / (60)), mu % 60)
        else
            mv_1 = string.format("%dh %dm", math.floor((mu) / (3600)), math.floor((mu % 3600) / (60)))
        end
        j3:SetText(jJ("Session time", mv_1, jw))
    end
end
local function fn77()
    local ml_1
    local mk_1
    if identifyexecutor then
        ml_1, mk_1 = identifyexecutor()
        local mm = ml_1 ~= ""
        local mn = type(ml_1) == "string" and mm
        if mn then
            local mm_1 = type(mk_1) == "string" and mk_1 ~= "" and ml_1 .. " " .. mk_1
            kk = mm_1 or ml_1
        end
    end
end
local function fn88()
    jD()
    jX("ClaimOffline")
end
local function fn117()
    pcall(function()
        connection:Disconnect()
    end)
    pcall(function()
        connection2:Disconnect()
    end)
    jM(false)
end
local function fn135(cv)
    local my = jV[cv]
    if my then
        return ("%s  ($%s)"):format(my.name, tostring(my.price))
    end
    return cv
end
local function onExportConfigToClipboard()
    local oj_1
    local oi_1
    oi_1, oj_1 = pcall(HttpService.JSONEncode, HttpService, jF())
    if not oi_1 then
        jI:Notify("Failed to encode the config")
        return
    end
    local oi_2 = setclipboard or toclipboard
    local oi_3 = type(oi_2) ~= "function"
    local op = if oi_3 then 1 else 0
    local on = 2755 * op + 3517 * (1 - op)
    local oo = 3212 * op + 2460 * (1 - op)
    if not ((on * 1854 + oo * 684 + on * oo) % 16777213 == 16153838) then
        oi_3 = not pcall(oi_2, oj_1)
    end
    if oi_3 then
        jI:Notify("Your executor does not support copying to the clipboard")
        return
    end
    jI:Notify("Config copied to clipboard", 6)
end
local function onCopyJoinScript_JobID()
    local ms = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, j0)
    if setclipboard then
        setclipboard(ms)
    elseif toclipboard then
        toclipboard(ms)
    end
    jI:Notify("Copied join script to clipboard")
end
local function fn162()
    local leaderstats = jN:FindFirstChild("leaderstats")
    local lO = leaderstats and leaderstats:FindFirstChild("Rebirths")
    if lO then
        return lO.Value or 0
    end
    return 0
end
local function onCopyLitecoinAddress()
    kj(ke, "Copied Litecoin address")
end
local function antiAfkLoop()
    while not jI.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local nE = tick() - kd
            local nF = tick() - ka
            if nE >= 300 and nF >= 60 then
                pcall(jZ)
            else
                if nE < 300 and nF >= 300 then
                    pcall(jZ)
                end
            end
        end
    end
end
local function fn231()
    if jK() < PendantConfig.ForgeCost then
        return
    end
    local oX = kc("ForgePendant")
    if oX and oX.ok and oX.rolled then
        local oY_1 = PendantConfig.Pendants[oX.rolled]
        if oY_1 and oX.rolled > (oX.equipped or 0) then
            kc("EquipPendant", oY_1.id)
        end
    end
end
local function onCopyUSDTAddress()
    kj(j7, "Copied USDT address")
end
local function fn243()
    local oM = RebirthConfig.requirementFor(jy())
    local oM_1 = oM and oM.cashCost or math.huge
    if jK() >= oM_1 then
        kc("Rebirth")
    end
end
local function fn259()
    if not jO.graveIndex then
        j2()
        return
    end
    if jO.rank >= (jY[Options.BuyRarityTier and Options.BuyRarityTier.Value or "ash"] or 1) then
        if jK() >= jO.price then
            local oR_3 = kc("ClaimSpirit", jO.graveIndex)
            if oR_3 and oR_3.ok then
                jO = { graveIndex = nil, rank = 0, price = 0 }
            end
        end
    else
        j2()
        jO = { graveIndex = nil, rank = 0, price = 0 }
    end
end
local function fn264(P, ...)
    local lz_1
    local lx = ki(P)
    local ly = lx and lx:IsA("RemoteFunction")
    local ly_1
    if not ly then
        return nil
    end
    ly_1, lz_1 = pcall(lx.InvokeServer, lx, ...)
    if ly_1 then
        return lz_1
    end
    return nil
end
local function fn273(M)
    return Remotes:FindFirstChild(M)
end
local function fn278(d4, d5)
    local nJ_1 = (d4 == "Toggle" and Toggles or Options)[d5]
    local nI_2 = type(nJ_1) == "table" and nJ_1.Type == d4
    return nI_2 and nJ_1 or nil
end
local function antiGameplayPauseLoop()
    while not jI.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            jM(true)
        end
    end
end
local function fn348()
    if not Toggles.WalkSpeedEnabled.Value then
        local m9 = ju()
        if m9 then
            m9.WalkSpeed = 16
        end
    end
end
local function fn363()
    local l3 = jN.RespawnLocation and jN.RespawnLocation.Parent
    local l4 = l3
    if l3 then
        l3 = l4:FindFirstChild("Objects")
    end
    local l4_1 = l3
    if not l4_1 then
        return false
    end
    local Character = jN.Character
    local l5 = Character and Character:FindFirstChild("HumanoidRootPart")
    if not l5 then
        return false
    end
    local l5_1 = false
    for i, descendant in ipairs(l4_1:GetDescendants()) do
        local l4_2 = descendant:IsA("BasePart") and descendant.Name == "CollectPad"
        if l4_2 then
            l5.CFrame = CFrame.new(descendant.Position + Vector3.new(0, 3, 0))
            l5_1 = true
            task.wait(0.35)
        end
    end
    return l5_1
end
local function fn365(bf)
    local DiscordGroup = bf:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = j9 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = j9 })
end
local function onImportConfigFromClipboardTex()
    local ou_1
    local oq = Options.SaveManager_ImportSource.Value or ""
    local oq_1
    local ot = tostring(oq):match("^%s*(.-)%s*$")
    if ot == "" then
        jI:Notify("Paste an exported config into the box first")
        return
    end
    oq_1, ou_1 = pcall(HttpService.JSONDecode, HttpService, ot)
    local ot_1 = not oq_1 or type(ou_1) ~= "table" or type(ou_1.objects) ~= "table"
    if ot_1 then
        jI:Notify("That is not a valid exported config")
        return
    end
    local oq_2 = 0
    for i, v in ipairs(ou_1.objects) do
        if j5(v) then
            oq_2 += 1
        end
    end
    if oq_2 == 0 then
        jI:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local ou_2 = oq_2 == 1 and "" or "s"
    jI:Notify(("Imported %d setting%s"):format(oq_2, ou_2), 6)
end
local function fn395(a8, a9)
    if setclipboard then
        setclipboard(a8)
    elseif toclipboard then
        toclipboard(a8)
    end
    jI:Notify(a9)
end
local function fn427()
    local BuyChests = Options.BuyChests
    if not BuyChests then
        return
    end
    local pc = BuyChests:GetActiveValues()
    for i, v in ipairs(pc) do
        local pb_1 = jV[v]
        local pc_1 = pb_1 and jK() >= pb_1.price
        if pc_1 then
            kc("BuyBox", v)
        end
    end
end
local function fn435(bl, bm)
    return string.format('<font color="%s">%s</font>', bm, bl)
end
local function onCopySolanaAddress()
    kj(j4, "Copied Solana address")
end
local function fn454(W, ...)
    local lE = ki(W)
    local lF = lE and lE:IsA("RemoteEvent")
    if lF then
        pcall(lE.FireServer, lE, ...)
    end
end
local function onCopyPayPalLink()
    kj(j1, "Copied PayPal link")
end
local function onInputBegan()
    kd = tick()
end
local function onRenderStepped(c2)
    if jI.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local mY_1 = ju()
        if mY_1 then
            mY_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local mY_3 = kf()
        local mZ = ju()
        if mY_3 and mZ then
            mZ.PlatformStand = true
            local mZ_1 = Vector3.zero
            local m3 = if jU:IsKeyDown(Enum.KeyCode.W) then 1 else 0
            if m3 == 1 then
                mZ_1 = mZ_1 + CurrentCamera.CFrame.LookVector
            end
            if jU:IsKeyDown(Enum.KeyCode.S) then
                mZ_1 = mZ_1 - CurrentCamera.CFrame.LookVector
            end
            if jU:IsKeyDown(Enum.KeyCode.A) then
                mZ_1 = mZ_1 - CurrentCamera.CFrame.RightVector
            end
            if jU:IsKeyDown(Enum.KeyCode.D) then
                mZ_1 = mZ_1 + CurrentCamera.CFrame.RightVector
            end
            if jU:IsKeyDown(Enum.KeyCode.Space) then
                mZ_1 = mZ_1 + Vector3.new(0, 1, 0)
            end
            if jU:IsKeyDown(Enum.KeyCode.LeftControl) then
                mZ_1 = mZ_1 - Vector3.new(0, 1, 0)
            end
            mY_3.Velocity = Vector3.zero
            if mZ_1.Magnitude > 0 then
                mY_3.CFrame = mY_3.CFrame + mZ_1.Unit * Options.FlySpeed.Value * c2
            end
        end
    end
end
local function fn504()
    local pQ_1
    local pO = kc("GetInventory")
    local pO_1
    if typeof(pO) ~= "table" then
        return
    end
    local pP = {}
    for k, v in pairs(pO) do
        pQ_1, pO_1 = string.match(k, "^(.-)#(%d+)$")
        if pQ_1 then
            local pS = tonumber(pO_1) or 1
            table.insert(pP, { key = pQ_1, level = pS })
        end
    end
    table.sort(pP, function(gB, gC)
        return gB.level > gC.level
    end)
    local pO_2 = {}
    local pQ_2 = math.min(3, #pP)
    local p1 = 1
    while p1 <= pQ_2 do
        local p2 = p1
        table.insert(pO_2, pP[p2].key)
        p1 += 1
    end
    if #pO_2 > 0 then
        kc("TowerBattle", pO_2)
    end
end
local function fn517(cy)
    local mA = jV[cy]
    if mA then
        return ("%s  ($%s)"):format(mA.name, tostring(mA.price))
    end
    return cy
end
local function onCopyBitcoinAddress()
    kj(kb, "Copied Bitcoin address")
end
local function fn539()
    if Toggles.AutoBuyRarity and Toggles.AutoBuyRarity.Value then
        return
    end
    j2()
end
local function fn593()
    local lY = kg()
    if not lY then
        return false
    end
    local RollPrompt = lY:FindFirstChild("RollPrompt", true)
    local lY_1 = RollPrompt and RollPrompt:IsA("ProximityPrompt")
    if not lY_1 then
        return false
    end
    local Parent = RollPrompt.Parent
    local Character = jN.Character
    local l0 = Character and Character:FindFirstChild("HumanoidRootPart")
    local l__1 = Parent
    if l__1 then
        l__1 = Parent:IsA("BasePart")
    end
    if l__1 and l0 then
        l0.CFrame = CFrame.new(Parent.Position + Vector3.new(0, 0, 5))
        task.wait(0.3)
    end
    if typeof(fireproximityprompt) == "function" then
        fireproximityprompt(RollPrompt)
        return true
    end
    return false
end
local function onJumpRequest()
    if jI.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local mW_1 = ju()
        if mW_1 then
            mW_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn669()
    local Character = jN.Character
    local mJ = Character and Character:FindFirstChild("HumanoidRootPart")
    return mJ
end
local function fn676()
    kj(jH, "Copied Discord invite to clipboard")
end
local function fn686(ec, ed)
    local Type = ed.Type
    if Type == "Toggle" then
        return { idx = ec, type = "Toggle", value = ed.Value == true }
    elseif Type == "Slider" then
        return { idx = ec, type = "Slider", value = tostring(ed.Value) }
    elseif Type == "Dropdown" then
        return { idx = ec, type = "Dropdown", multi = ed.Multi == true, value = ed.Value }
    elseif Type == "Input" then
        local nQ = ed.Value or ""
        return { idx = ec, type = "Input", text = tostring(nQ) }
    elseif Type == "ColorPicker" then
        return { idx = ec, type = "ColorPicker", value = ed.Value:ToHex(), transparency = ed.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = ec,
            type = "KeyPicker",
            mode = ed.Mode,
            key = ed.Value,
            modifiers = ed.Modifiers,
            toggled = ed.Toggled
        }
    else
        return nil
    end
end
local function fn687()
    jM(Toggles.AntiGameplayPause.Value)
end
local function onStepped()
    if jI.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = jN.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local mL_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if mL_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function fn740()
    local pv_1
    local pu_1
    local pt = kc("GetSpirits")
    if typeof(pt) ~= "table" then
        return
    end
    pv_1, pu_1 = nil, 0
    for k, v in pairs(pt) do
        local pt_1 = typeof(v) == "table" and v.id
        if pt_1 then
            local pt_2 = SpiritDex.byId[v.id]
            if pt_2 then
                local pt_3 = (jY[pt_2.tier] or 0) * 1000000 + (pt_2.oneIn or 0)
                if pt_3 > pu_1 then
                    pu_1 = pt_3
                    pv_1 = k
                end
            end
        end
    end
    if pv_1 ~= nil then
        kc("EquipSpirit", pv_1)
    end
end
local function fn747()
    return not jI.Unloaded and jq.TempoGen == TempoGen
end
local function fn752()
    local nW = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local nX = type(v) == "table" and type(v.Type) == "string" and not jE.Ignore[k]
            if nX then
                local nX_1 = jQ(k, v)
                if nX_1 then
                    nW[#nW + 1] = nX_1
                end
            end
        end
    end
    table.sort(nW, function(eq, er)
        if eq.type ~= er.type then
            return eq.type < er.type
        end
        return eq.idx < er.idx
    end)
    return { objects = nW }
end
local function fn760()
    local Character = jN.Character
    local mD = Character and Character:FindFirstChildOfClass("Humanoid")
    return mD
end
local function onUnload()
    jI:Unload()
end
local function fn835()
    if not Toggles.Fly.Value then
        local m4 = ju()
        if m4 then
            m4.PlatformStand = false
        end
    end
end
local function fn870()
    local UseChests = Options.UseChests
    if not UseChests then
        return
    end
    local pl = UseChests:GetActiveValues()
    for i, v in ipairs(pl) do
        kc("OpenBox", v)
    end
end
local function fn881()
    if jK() < RingConfig.ForgeCost then
        return
    end
    local o5 = kc("ForgeRing")
    if o5 and o5.ok and o5.rolled then
        local o6_1 = RingConfig.Rings[o5.rolled]
        if o6_1 and o5.rolled > (o5.equipped or 0) then
            kc("EquipRing", o6_1.id)
        end
    end
end
local function onCopyEthereumAddress()
    kj(j8, "Copied Ethereum address")
end
local function onCopyVenmoLink()
    kj(j_, "Copied Venmo link")
end
local function fn921()
    local pG = kc("GetInventory")
    if typeof(pG) ~= "table" then
        return
    end
    for k, v in pairs(pG) do
        local pG_1 = type(v) == "number" and v >= 2
        if pG_1 then
            kc("SelectItem", k)
        end
    end
end
local function fn947()
    local leaderstats = jN:FindFirstChild("leaderstats")
    local lL = leaderstats and leaderstats:FindFirstChild("Cash")
    local lK_1 = lL
    if lL then
        lL = lK_1:IsA("IntValue")
    end
    if lL then
        return lK_1.Value
    end
    return 0
end
local function fn961()
    if not workspace.CurrentCamera then
        return
    end
    jW:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    jW:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    ka = tick()
end
local function fn968()
    local Graves = workspace:FindFirstChild("Graves")
    if not Graves then
        return nil
    end
    for i, child in ipairs(Graves:GetChildren()) do
        local lQ_1 = child:IsA("Model") and child:GetAttribute("OwnerUserId") == jN.UserId
        if lQ_1 then
            return child
        end
    end
    return nil
end
jq = nil
RebirthConfig = nil
Options = nil
RingConfig = nil
ju = nil
Toggles = nil
jw = nil
PendantConfig = nil
jy = nil
SpiritDex = nil
CurrentCamera = nil
connection2 = nil
Remotes = nil
jD = nil
jE = nil
jF = nil
jG = nil
jH = nil
jI = nil
jJ = nil
jK = nil
jM = nil
jN = nil
jO = nil
connection = nil
jQ = nil
jR = nil
HttpService = nil
jT = nil
jU = nil
jV = nil
jW = nil
jX = nil
jY = nil
jZ = nil
j_ = nil
j0 = nil
j1 = nil
j2 = nil
j3 = nil
j4 = nil
j5 = nil
j7 = nil
j8 = nil
j9 = nil
ka = nil
kb = nil
kc = nil
local jL, j6
kd = nil
ke = nil
kf = nil
kg = nil
TempoGen = nil
ki = nil
kj = nil
kk = nil
local kn, ko, kp, kq, kr, ks, kt, kv, kw, kx, ky, kz, kA, kB, kD, EquipBestGroup
jq = getgenv()
local kl = jq.TempoGen or 0
TempoGen, kn = nil, nil
local km = 4
local Players, km_9
repeat
    ko = (km * 1 + 0) % 2 + 1
    if ko <= 1 then
        ko = (vector.create((km * 1 + 8) % 11 + 1, (km * 9 + 3) % 13 + 1, (km * 1 + 4) % 17 + 1))
        kp = (vector.create((km * 1 + 7) % 11 + 1, (km * 6 + 2) % 13 + 1, (km * 2 + 6) % 17 + 1))
        kq = (vector.create((km * 7 + 5) % 11 + 1, (km * 1 + 5) % 13 + 1, (km * 13 + 14) % 17 + 1))
        kr = (vector.create((km * 4 + 5) % 5 + 1, (km * 5 + 3) % 7 + 1, (km * 5 + 2) % 9 + 1))
        if vector.dot(vector.cross(ko, (vector.cross(kp, kq))), kr) == vector.dot(kp * vector.dot(ko, kq) - kq * vector.dot(ko, kp), kr) then
            jq.TempoGen = kl + 1
            TempoGen = jq.TempoGen
        else
            jq.TempoGen = jq + 1
            kl = TempoGen.TempoGen
        end
        km = (km + 5) % 16
    else
        if (km * 2 + 6) * 13 % 3 == ((km * 2 + 6) * 13 + 7) % 3 then
            jq = kn.TempoLib
        else
            kn = jq.TempoLib
        end
        km = (km + 15) % 16
    end
until (km * 1 + 8) % 16 == 0
if kn then
    kl = 4
    repeat
        local km_1 = (vector.create((kl * 5 + 7) % 11 + 1, (kl * 8 + 6) % 13 + 1, (kl * 14 + 14) % 17 + 1))
        local qv = vector.floor(km_1) + vector.ceil(km_1 * -1)
        if vector.dot(qv, qv) == 1 then
            jq = type(kn.TempoLib.Unload) == "function"
        else
            kn = type(jq.TempoLib.Unload) == "function"
        end
        kl = (kl + 4) % 8
    until (kl * 7 + 5) % 8 == 5
end
if kn then
    pcall(function()
        jq.TempoLib:Unload()
    end)
end
local km_2 = nil
kl = 0
repeat
    if (km_2 and kl or not kl and kl or (km_2 or not kl) and (km_2 or not kl)) and (kl and km_2 or (km_2 or kl) or (km_2 or kl or (kl or km_2))) or not ((km_2 and kl or not kl and kl or (km_2 or not kl) and (km_2 or not kl)) and (kl and km_2 or (km_2 or kl) or (km_2 or kl or (kl or km_2)))) then
        km_2 = typeof(gethui) == "function"
    else
        km_2 = typeof(gethui) == "function"
    end
    kl = (kl + 0) % 8
until (kl * 7 + 1) % 8 == 1
if km_2 then
    km_2 = gethui()
end
kl = km_2 or nil
local km_3 = kl
if km_3 then
    for i, child in ipairs(km_3:GetChildren()) do
        local le = child
        if le:GetAttribute("TempoHubUI") == true then
            pcall(function()
                le:Destroy()
            end)
        end
    end
end
Players, jW, jU, HttpService, jN, kq, jH, jG, Remotes, SpiritDex, ko, kp, PendantConfig, RingConfig, RebirthConfig, ks, ki, kc, jX, jK, jy, kg, j2, jD = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if (RingConfig and not ks or (kq or not ks) or (RingConfig and not RingConfig or RingConfig and jN)) and (not RingConfig and not kq and (not RingConfig or not jN) and (not kq or not ks or kq and kq)) and not ((RingConfig and not ks or (kq or not ks) or (RingConfig and not RingConfig or RingConfig and jN)) and (not RingConfig and not kq and (not RingConfig or not jN) and (not kq or not ks or kq and kq))) then
    ko = game:GetService("Players")
else
    Players = game:GetService("Players")
end
kl = game:GetService("ReplicatedStorage")
if (kc or ko or not SpiritDex and not SpiritDex) and (ko and not ko or (not kp or not RebirthConfig)) and ((not kp or ko or (not RebirthConfig or not kc)) and (not SpiritDex and kc or not RebirthConfig and kp)) or not ((kc or ko or not SpiritDex and not SpiritDex) and (ko and not ko or (not kp or not RebirthConfig)) and ((not kp or ko or (not RebirthConfig or not kc)) and (not SpiritDex and kc or not RebirthConfig and kp))) then
    jW = game:GetService("VirtualUser")
    jU = game:GetService("UserInputService")
    kr = game:GetService("RunService")
    HttpService = game:GetService("HttpService")
    jN = Players.LocalPlayer
else
    jN = game:GetService("VirtualUser")
    game:GetService("UserInputService")
    jW = game:GetService("RunService")
    jU = game:GetService("HttpService")
    kr = HttpService.LocalPlayer
end
kq = "Roll a Spirit"
jH = "https://discord.gg/K7Qxnxkk46"
jG = "https://discord.gg/K7Qxnxkk46"
Remotes = kl:WaitForChild("Remotes")
SpiritDex = require(kl.Shared.SpiritDex)
ko = require(kl.Shared.SpiritTierConfig)
kp = require(kl.Shared.BoxConfig)
PendantConfig = require(kl.Shared.PendantConfig)
RingConfig = require(kl.Shared.RingConfig)
RebirthConfig = require(kl.Shared.RebirthConfig)
ki = fn273
kc = fn264
jX = fn454
jK = fn947
if (jy or kp) and (not jy and not jy) or (not jy or jy) and (kp or jy) or not ((jy or kp) and (not jy and not jy) or (not jy or jy) and (kp or jy)) then
    jy = fn162
    kg = fn968
    j2 = fn593
    jD = fn363
    ks = {}
else
    ks = fn162
    jy = fn968
    jD = fn593
    j2 = fn363
    kg = {}
end
for i, v in ipairs(ko.tiers) do
    table.insert(ks, v.id)
end
kl = {}
local km_5 = ko.rankOf or kl
jY, ko, jV = nil, nil, nil
kn = 3
repeat
    kl = {
        "zkdkipyfgbzs",
        "fnkoopnqcy",
        "cyqcctugt",
        "ehqheqrtp",
        "tli",
        "tepihsbwpq",
        "wwctfavfnmf",
        "ehbbrkziyfe",
        "kdywxzvo"
    }
    if kl[(kn * 72 + 81) % 9 + 1] < kl[(kn * 72 + 81) % 9 + 1] then
        km_5 = jY
        jV = {}
        ko = {}
    else
        jY = km_5
        ko = {}
        jV = {}
    end
    kn = (kn + 1) % 4
until (kn * 3 + 3) % 4 == 3
for i, v in ipairs(kp) do
    table.insert(ko, v.id)
    jV[v.id] = v
end
jO, kl, jI, kt, jE, kp, kn = nil, nil, nil, nil, nil, nil, nil
local km_6 = 8
repeat
    kv = (km_6 * 1 + 1) % 5 + 1
    if kv <= 3 then
        if kv <= 2 then
            if kv <= 1 then
                if (km_6 * 2 + 8) * 7 % 3 == ((km_6 * 2 + 8) * 7 + 6) % 3 then
                    kl = ""
                else
                    jO = ""
                end
                km_6 = (km_6 + 16) % 20
            else
                kw = {
                    "wgtb",
                    "ull",
                    "akjqsqgtwx",
                    "fcinrsrmx",
                    "pehcm",
                    "lyiqoyd",
                    "hsbixhlw",
                    "fdrhsaejxfk",
                    "jjidnbja",
                    "nemynxlqme"
                }
                local qU = km_6
                kx = kw[qU % 10 + 1]
                if kx:len() >= kx:gsub("(.)", "%1%1", qU % 3 % 2 + 1):len() then
                    kl = getgenv().Library
                else
                    jI = getgenv().Library
                end
                km_6 = (km_6 + 16) % 20
            end
        else
            kw = (vector.create((km_6 * 2 + 1) % 11 + 1, (km_6 * 6 + 10) % 13 + 1, (km_6 * 9 + 14) % 17 + 1))
            local qG = vector.floor(kw) + vector.ceil(kw * -1)
            if vector.dot(qG, qG) == 5 then
                kq = getgenv().ThemeManager
                kt = getgenv().SaveManager
                setthreadidentity(8)
                jE = jH:CreateWindow({
                    ShowCustomCursor = false,
                    NotifySide = "Right",
                    CornerRadius = 0,
                    Footer = { kl, { Text = jI, Copyable = true }, "|" },
                    Title = "Tempo Hub",
                    Icon = "ghost"
                })
            else
                kt = getgenv().ThemeManager
                jE = getgenv().SaveManager
                setthreadidentity(8)
                kp = jI:CreateWindow({
                    Title = "Tempo Hub",
                    Footer = { { Text = jH, Copyable = true }, "|", kq },
                    Icon = "ghost",
                    NotifySide = "Right",
                    ShowCustomCursor = false,
                    CornerRadius = 0
                })
            end
            km_6 = (km_6 + 1) % 20
        end
    elseif kv <= 4 then
        kv = (vector.create((km_6 * 3 + 8) % 11 + 1, (km_6 * 11 + 13) % 13 + 1, (km_6 * 10 + 4) % 17 + 1))
        kw = (vector.create((km_6 * 4 + 6) % 11 + 1, (km_6 * 3 + 11) % 13 + 1, (km_6 * 3 + 7) % 17 + 1))
        local qF = vector.dot(kv, kw)
        if qF * qF >= vector.dot(kv, kv) * vector.dot(kw, kw) + 1 then
            jI = kn.MainFrame
        else
            kn = jI.MainFrame
        end
        km_6 = (km_6 + 1) % 20
    else
        if (km_6 * 2 + 9) * 7 % 3 == ((km_6 * 2 + 9) * 7 + 5) % 3 then
            kl = { graveIndex = nil, rank = 0, price = 0 }
        else
            jO = { graveIndex = nil, rank = 0, price = 0 }
        end
        km_6 = (km_6 + 6) % 20
    end
until (km_6 * 3 + 1) % 20 == 5
if kn then
    kl = 1
    repeat
        local km_7 = {
            "wxt",
            "qidsrfy",
            "inriaitmfrz",
            "lwpmzwpooat",
            "pqcsssxbnsa",
            "ghukjjipot",
            "zlbod",
            "fsljzfdqtr",
            "uskbhwvjn"
        }
        local q2 = kl
        kv = km_7[q2 % 9 + 1]
        if kv:len() <= kv:reverse():rep(q2 % 3 + 2):len() then
            kn = jI.MainFrame:FindFirstAncestorWhichIsA("ScreenGui")
        else
            jI = kn.MainFrame:FindFirstAncestorWhichIsA("ScreenGui")
        end
        kl = (kl + 6) % 8
    until (kl * 1 + 4) % 8 == 3
end
local km_8 = kn
if km_8 then
    km_8:SetAttribute("TempoHubUI", true)
end
Toggles, Options, kj, j9 = nil, nil, nil, nil
jq.TempoLib = jI
kv = {
    Info = kp:AddTab("Info", "info"),
    Main = kp:AddTab("Main", "gamepad-2"),
    Combat = kp:AddTab("Combat", "swords"),
    Farming = kp:AddTab("Farming", "wheat"),
    Inventory = kp:AddTab("Inventory", "package"),
    Player = kp:AddTab("Player", "person-standing"),
    Settings = kp:AddTab("Settings", "settings")
}
Toggles = jI.Toggles
Options = jI.Options
kj = fn395
j9 = fn676
kn = fn365
for k, v in kv do
    if v ~= kv.Info then
        kn(v)
    end
end
ky, kx, jw, kw, kk, km_9, kz, j3, j0, kp, jT, jJ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
kl = 38
repeat
    kn = (kl * 1 + 5) % 9 + 1
    if kn <= 5 then
        if kn <= 3 then
            if kn <= 2 then
                if kn <= 1 then
                    if (not km_9 or km_9) and (not ky and not ky) and ((not km_9 or km_9) and (not km_9 and not ky)) or not ((not km_9 or km_9) and (not ky and not ky) and ((not km_9 or km_9) and (not km_9 and not ky))) then
                        ky = "#7fd47f"
                    else
                        j0 = "#7fd47f"
                    end
                    kl = (kl + 1) % 72
                else
                    if kl * 98732275 + 6 + 1 >= kl * 98732275 + 6 + 1 + 1 then
                        jw = "#6ec1ff"
                    else
                        kx = "#6ec1ff"
                    end
                    kl = (kl + 1) % 72
                end
            else
                kA = (vector.create((kl * 1 + 3) % 11 + 1, (kl * 9 + 1) % 13 + 1, (kl * 11 + 15) % 17 + 1))
                kB = (vector.create((kl * 5 + 9) % 11 + 1, (kl * 8 + 11) % 13 + 1, (kl * 5 + 17) % 17 + 1))
                local qD = vector.cross(kA, kB)
                local qE = vector.dot(kA, kB)
                if vector.dot(qD, qD) + qE * qE == vector.dot(kA, kA) * vector.dot(kB, kB) + 4 then
                    jT = "#e8a34d"
                else
                    jw = "#e8a34d"
                end
                kl = (kl + 10) % 72
            end
        elseif kn <= 4 then
            kA = {
                "oqsclwzu",
                "qspocgg",
                "lhoorkls",
                "trjiml",
                "ywemedfr",
                "nzgucpb",
                "yknd",
                "xnmsqn",
                "jouv",
                "vweeize",
                "rtlwtepwlbn",
                "yveclfmpvc",
                "xyidrf",
                "fhldrylr",
                "piro",
                "zvevgqq"
            }
            if kA[(kl * 55 + 103) % 16 + 1] < kA[(kl * 55 + 103) % 16 + 1] then
                jw = "#8b93a3"
            else
                kw = "#8b93a3"
            end
            kl = (kl + 28) % 72
        else
            if (kl * 3 + 7) * 17 % 4 == ((kl * 3 + 7) * 17 + 2) % 4 then
                ky = "Unknown"
                pcall(fn77)
                kx = jT.Info:AddLeftGroupbox("Account", "circle-user")
                kx:AddLabel(kv("User", kk.Name, km_9), true)
                kx:AddLabel(kv("Status", "Keyless", km_9), true)
                kx:AddLabel(kv("Executor", "Unknown", km_9), true)
                jw = jT.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                jw:AddLabel(kq(jN .. " [" .. tostring(game.PlaceId) .. "]", jJ), true)
                jw:AddLabel(kv("Place ID", tostring(game.PlaceId), jJ), true)
                kz = jw:AddLabel(kv("Session time", "0s", j3), true)
            else
                kk = "Unknown"
                pcall(fn77)
                km_9 = kv.Info:AddLeftGroupbox("Account", "circle-user")
                km_9:AddLabel(jJ("User", jN.Name, ky), true)
                km_9:AddLabel(jJ("Status", "Keyless", ky), true)
                km_9:AddLabel(jJ("Executor", kk, ky), true)
                kz = kv.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                kz:AddLabel(jT(kq .. " [" .. tostring(game.PlaceId) .. "]", kx), true)
                kz:AddLabel(jJ("Place ID", tostring(game.PlaceId), kx), true)
                j3 = kz:AddLabel(jJ("Session time", "0s", jw), true)
            end
            kl = (kl + 37) % 72
        end
    elseif kn <= 7 then
        if kn <= 6 then
            if kk and not kk and (jJ or jJ) or (not kk and not jJ or kk and kk) or not (kk and not kk and (jJ or jJ) or (not kk and not jJ or kk and kk)) then
                j0 = tostring(game.JobId)
            else
                j3 = tostring(game.JobId)
            end
            kl = (kl + 46) % 72
        else
            kA = {
                "zwjjhrx",
                "uew",
                "zrxiilncuu",
                "zfh",
                "ibuz",
                "yatn",
                "aeqvjcp",
                "gdpwcgbnbyl",
                "zvpw",
                "otigrqsihi"
            }
            if kA[(kl * 53 + 93) % 10 + 1] <= kA[(kl * 53 + 93) % 10 + 1] then
                kp = #j0 > 18
            else
                j0 = #kp > 18
            end
            kl = (kl + 46) % 72
        end
    elseif kn <= 8 then
        local q3 = bit32.rrotate(bit32.bxor(bit32.lrotate(kl, 20), string.byte(tostring(kw))), 31)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(q3, 1903191041), 1507190304), (bit32.bxor(bit32.band(q3, 2391776254), 3399915641))), 1507190304), 3399915641) ~= q3 then
            km_9 = fn435
        else
            jT = fn435
        end
        kl = (kl + 28) % 72
    else
        kn = {
            "wnu",
            "fkwdffw",
            "xowqc",
            "xrzkffobdry",
            "mwmjihq",
            "mabuupsjmbb",
            "lgl",
            "uhwwtkx",
            "stlyto",
            "pgonulivxt"
        }
        local q1 = kl
        kA = kn[q1 % 10 + 1]
        if kA:len() >= kA:reverse():rep(q1 % 3 + 2):len() then
            jw = fn41
        else
            jJ = fn41
        end
        kl = (kl + 28) % 72
    end
until (kl * 47 + 48) % 72 == 25
if kp then
    kl = 0
    repeat
        if kl * 28102447 + 12 + 2 >= kl * 28102447 + 12 + 2 + 1 then
            j0 = string.sub(kp, 1, 18) .. "..."
        else
            kp = string.sub(j0, 1, 18) .. "..."
        end
        kl = (kl + 1) % 8
    until (kl * 7 + 4) % 8 == 3
end
kl = kp
local lh = if kl then 1 else 0
local lf = 3630 * lh + 3521 * (1 - lh)
local lg = 1842 * lh + 486 * (1 - lh)
if not ((lf * 3905 + lg * 2538 + lf * lg) % 16777213 == 8759393) then
    kl = j0
end
jR, ke, kb, j8, j7, j4, j1, j_, EquipBestGroup, CurrentCamera, kd, ka, connection, connection2, ju, kf, jM, jZ, j6, jQ, jF, j5, jL, kD = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local kQ = kl
kz:AddLabel(jJ("Server", kQ, kw), true)
kz:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
jR = os.clock()
task.spawn(worker)
kA = kv.Info:AddRightGroupbox("Scripts", "package")
kA:AddLabel(jT("Included in this hub", kw), true)
kA:AddLabel(jT(kq, kx), true)
kn = kv.Info:AddRightGroupbox("Features", "list")
kn:AddLabel(jT("Auto Roll", kx), true)
kn:AddLabel(jT("Auto Forge", jw), true)
kn:AddLabel(jT("Auto Chests", ky), true)
kn:AddLabel(jT("Auto Battle", kx), true)
kn:AddLabel(jT("Auto Rebirth", jw), true)
local SocialsGroup = kv.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = j9 })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = kv.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = j9 })
ke = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
kb = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
j8 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
j7 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
j4 = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
j1 = ""
j_ = ""
local kR = "#345d9d"
local kO = "#f7931a"
local kN = "#627eea"
local kM = "#26a17b"
local kK = "#14f195"
local kJ = "#0070ba"
local kI = "#008cff"
local DonationsGroup = kv.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(jT("All donations are optional but appreciated.", jw), true)
DonationsGroup:AddLabel(jT("If you donate you get a special role, just PING after you donate.", ky), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(jT("LTC / Litecoin", kR), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(jT("BTC / Bitcoin", kO), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(jT("ETH / Ethereum", kN), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(jT("USDT", kM), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(jT("Solana", kK), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(jT("PayPal", kJ), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(jT("Venmo", kI), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(jT("Don't have any of the listed currencies but still wanna donate?", kw), true)
DonationsGroup:AddLabel(jT("DM me and we'll work something out.", kx), true)
local FaqGroup = kv.Info:AddRightGroupbox("FAQ", "circle-help")
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
local Rebirth_PrestigeGroup = kv.Main:AddRightGroupbox("Rebirth / Prestige", "refresh-cw")
Rebirth_PrestigeGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
Rebirth_PrestigeGroup:AddSlider("RebirthInterval", { Text = "Rebirth Interval", Default = 1, Min = 0.1, Max = 10, Rounding = 2, Suffix = "s" })
local SpiritsGroup = kv.Farming:AddRightGroupbox("Spirits", "ghost")
SpiritsGroup:AddToggle("AutoRollSpirits", { Text = "Auto Roll Spirits", Default = false })
SpiritsGroup:AddSlider("RollInterval", { Text = "Roll Interval", Default = 1, Min = 0.1, Max = 10, Rounding = 2, Suffix = "s" })
SpiritsGroup:AddToggle("AutoBuyRarity", { Text = "Auto Buy Spirit Rarity", Default = false })
SpiritsGroup:AddDropdown("BuyRarityTier", { Values = ks, Default = "ash", Text = "Minimum Rarity" })
SpiritsGroup:AddSlider("BuyRarityInterval", { Text = "Buy Interval", Default = 1, Min = 0.1, Max = 10, Rounding = 2, Suffix = "s" })
local ForgeEquipmentGroup = kv.Farming:AddRightGroupbox("Forge Equipment", "hammer")
ForgeEquipmentGroup:AddToggle("AutoForgePendant", { Text = "Auto Forge Pendant", Default = false })
ForgeEquipmentGroup:AddToggle("AutoForgeRing", { Text = "Auto Forge Ring", Default = false })
ForgeEquipmentGroup:AddSlider("ForgeInterval", { Text = "Forge Interval", Default = 1, Min = 0.1, Max = 10, Rounding = 2, Suffix = "s" })
local ChestsGroup = kv.Farming:AddLeftGroupbox("Chests", "box")
ChestsGroup:AddToggle("AutoBuyChests", { Text = "Auto Buy Chests", Default = false })
ChestsGroup:AddDropdown("BuyChests", {
    Values = ko,
    Default = nil,
    Multi = true,
    Text = "Chests to Buy",
    Searchable = true,
    Expandable = true,
    FormatDisplayValue = fn135
})
ChestsGroup:AddSlider("BuyChestInterval", { Text = "Buy Chest Interval", Default = 1, Min = 0.1, Max = 10, Rounding = 2, Suffix = "s" })
ChestsGroup:AddToggle("AutoUseChests", { Text = "Auto Use Chests", Default = false })
ChestsGroup:AddDropdown("UseChests", {
    Values = ko,
    Default = nil,
    Multi = true,
    Text = "Chests to Open",
    Searchable = true,
    Expandable = true,
    FormatDisplayValue = fn517
})
ChestsGroup:AddSlider("UseChestInterval", { Text = "Use Chest Interval", Default = 1, Min = 0.1, Max = 10, Rounding = 2, Suffix = "s" })
local IncomeGroup = kv.Farming:AddLeftGroupbox("Income", "coins")
if (IncomeGroup and 66 or IncomeGroup and IncomeGroup or "0xaE95A405D007a6F858E5d35714111B075fEFb40a" or (IncomeGroup or false or false)) and ((IncomeGroup and 66 or not IncomeGroup or (not IncomeGroup or IncomeGroup or false)) and (false or (not IncomeGroup and false or (false or not IncomeGroup)))) or not ((IncomeGroup and 66 or IncomeGroup and IncomeGroup or "0xaE95A405D007a6F858E5d35714111B075fEFb40a" or (IncomeGroup or false or false)) and ((IncomeGroup and 66 or not IncomeGroup or (not IncomeGroup or IncomeGroup or false)) and (false or (not IncomeGroup and false or (false or not IncomeGroup))))) then
    IncomeGroup:AddToggle("AutoCollectIncome", { Text = "Auto Collect Income", Default = false })
    IncomeGroup:AddSlider("CollectInterval", { Text = "Collect Interval", Default = 3, Min = 0.1, Max = 10, Rounding = 2, Suffix = "s" })
    EquipBestGroup = kv.Inventory:AddRightGroupbox("Equip Best", "wand")
else
    EquipBestGroup:AddToggle("AutoCollectIncome", { Text = "Auto Collect Income", Default = false })
    EquipBestGroup:AddSlider("CollectInterval", { Text = "Collect Interval", Min = 0.1, Rounding = 2, Max = 10, Suffix = "s", Default = 3 })
    kv = IncomeGroup.Inventory:AddRightGroupbox("Equip Best", "wand")
end
EquipBestGroup:AddToggle("AutoEquipSpirits", { Text = "Auto Equip Best Spirits", Default = false })
EquipBestGroup:AddToggle("AutoEquipCards", { Text = "Auto Equip Best Cards", Default = false })
EquipBestGroup:AddSlider("EquipInterval", { Text = "Equip Interval", Default = 2, Min = 0.1, Max = 10, Rounding = 2, Suffix = "s" })
local CardsGroup = kv.Inventory:AddLeftGroupbox("Cards", "layers")
CardsGroup:AddToggle("AutoLevelCards", { Text = "Auto Level Up Cards", Default = false })
CardsGroup:AddSlider("LevelCardsInterval", { Text = "Level Up Interval", Default = 2, Min = 0.1, Max = 10, Rounding = 2, Suffix = "s" })
local TowerGroup = kv.Combat:AddLeftGroupbox("Tower", "tower-control")
TowerGroup:AddToggle("AutoBattleTower", { Text = "Auto Battle Tower", Default = false })
TowerGroup:AddSlider("TowerInterval", { Text = "Battle Interval", Default = 5, Min = 0.1, Max = 10, Rounding = 2, Suffix = "s" })
kB = kv.Player:AddLeftGroupbox("Movement", "footprints")
kB:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
kB:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
kB:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
kB:AddToggle("NoClip", { Text = "NoClip", Default = false })
kB:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
kp = kv.Player:AddRightGroupbox("Fly", "feather")
kp:AddToggle("Fly", { Text = "Fly", Default = false })
kp:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
ju = fn760
kf = fn669
kr.Stepped:Connect(onStepped)
jU.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
kr.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fn835)
Toggles.WalkSpeedEnabled:OnChanged(fn348)
jM = function(dp)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not dp)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not dp
        end
    end)
    if not dp then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(jN, "GameplayPaused", false)
        else
            jN.GameplayPaused = false
        end
    end)
end
Toggles.AntiGameplayPause:OnChanged(fn687)
task.spawn(antiGameplayPauseLoop)
local MenuGroup = kv.Settings:AddLeftGroupbox("Menu", "wrench")
kd = tick()
ka = tick()
pcall(function()
    for i, v in ipairs(getconnections(jN.Idled)) do
        local ns = v
        pcall(function()
            ns:Disable()
        end)
    end
end)
jZ = fn961
connection = jU.InputBegan:Connect(onInputBegan)
connection2 = jU.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(antiAfkLoop)
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", onUnload)
jI.ToggleKeybind = Options.MenuKeybind
kt:SetLibrary(jI)
kt:SetFolder("TempoHub")
kt:SaveDefault("Monochrome")
kt:ApplyToTab(kv.Settings)
kt:LoadDefault()
jE:SetLibrary(jI)
jE:IgnoreThemeSettings()
jE:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
jE:SetFolder("TempoHub/RollASpirit")
local kW = jE:BuildConfigSection(kv.Settings)
j6 = fn278
jQ = fn686
jF = fn752
j5 = function(et)
    local of
    of = nil
    local og = type(et) ~= "table" or type(et.idx) ~= "string" or type(et.type) ~= "string" or jE.Ignore[et.idx]
    if og then
        return false
    end
    of = j6(et.type, et.idx)
    if not of then
        return false
    end
    local og_1 = pcall(function()
        if et.type == "Input" then
            if type(et.text) ~= "string" then
                return
            end
            of:SetValue(et.text)
        elseif et.type == "ColorPicker" then
            of:SetValueRGB(Color3.fromHex(et.value), et.transparency)
        elseif et.type == "KeyPicker" then
            of:SetValue({ et.key, et.mode, et.modifiers })
            if et.mode == "Toggle" and et.toggled ~= nil then
                of.Toggled = et.toggled
                of:Update()
            end
        else
            of:SetValue(et.value)
        end
    end)
    return og_1
end
kW:AddDivider()
kW:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
kW:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
kW:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
jE:LoadAutoloadConfig()
jI:OnUnload(fn117)
jI:Notify({
    Title = "Tempo Hub loaded",
    Description = "Press RightShift to open or close the window.",
    Time = 5
})
jL = fn747
if (not kn and not kn or kR and EquipBestGroup or (EquipBestGroup or not EquipBestGroup or "#345d9d")) and ((false or (kR or kn)) and (kn or false or false)) and ((kB and false or (kB or kR) or false and (kR or not EquipBestGroup)) and ((j7 or kB or kn and kR) and ((kB or EquipBestGroup) and (j7 or not EquipBestGroup)))) and not ((not kn and not kn or kR and EquipBestGroup or (EquipBestGroup or not EquipBestGroup or "#345d9d")) and ((false or (kR or kn)) and (kn or false or false)) and ((kB and false or (kB or kR) or false and (kR or not EquipBestGroup)) and ((j7 or kB or kn and kR) and ((kB or EquipBestGroup) and (j7 or not EquipBestGroup))))) then
else
    kD = function(e5, e6, e7)
        task.spawn(function()
            while jL() do
                local oH = Toggles[e5]
                if oH and oH.Value then
                    pcall(e7)
                end
                local oH_1 = Options[e6]
                local oH_2 = oH_1 and oH_1.Value or 1
                local wait = task.wait
                local oK = tonumber(oH_2) or 1
                wait(math.max(oK, 0.1))
            end
        end)
    end
end
kD("AutoRebirth", "RebirthInterval", fn243)
kD("AutoRollSpirits", "RollInterval", fn539)
kD("AutoBuyRarity", "BuyRarityInterval", fn259)
kD("AutoForgePendant", "ForgeInterval", fn231)
kD("AutoForgeRing", "ForgeInterval", fn881)
kD("AutoBuyChests", "BuyChestInterval", fn427)
kD("AutoUseChests", "UseChestInterval", fn870)
kD("AutoCollectIncome", "CollectInterval", fn88)
kD("AutoEquipSpirits", "EquipInterval", fn740)
kD("AutoEquipCards", "EquipInterval", fn16)
kD("AutoLevelCards", "LevelCardsInterval", fn921)
kD("AutoBattleTower", "TowerInterval", fn504)
local k_ = ki("SpiritRolled")
local kZ = k_ and k_:IsA("RemoteEvent")
if kZ then
    k_.OnClientEvent:Connect(function(gH, gI)
        local p4 = SpiritDex.byId[gI]
        if not p4 then
            return
        end
        local p5 = jY[p4.tier] or 1
        jO = { graveIndex = gH, spiritId = gI, rank = p5, price = SpiritDex.claimPrice(p4) }
    end)
end
end)(...)

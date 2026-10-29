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
getgenv().TempoHoodSubtitle = "+1 TNT MINING"
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
local tM
local ut
local tP
local tw
local tS
local ud
local tz
local tV
local ug
local LocalPlayer
local tY
local tF
local t0
local um
local Workspace
local t3
local up
local us
local t9
local uv
local uc
local ty
local tB
local ui
local tE
local t_
local ul
local tH
local t5
local tN
local t8
local uu
local tQ
local ux
local ub
local tT
local tx
local ue
local CoreGui
local tA
local uh
local tD
local uk
local tG
local un
local t1
local tJ
local function fn42(bh)
    local Map = Workspace:FindFirstChild("Map")
    local v2 = Map and Map:FindFirstChild("Areas")
    local v1_1 = v2
    if v2 then
        v2 = v1_1:FindFirstChild(bh)
    end
    return v2 or nil
end
local function fn78()
    return Workspace:FindFirstChild("ActiveBombs")
end
local function fn81(ch, ci)
    local wD_1
    if not tS.MineState.IsLoaded() then
        return nil
    end
    local wA = tS.MineState.GetExposedBlocks()
    if #wA == 0 then
        return nil
    end
    local wB = t_()
    local wB_2
    local wB_1 = wB and wB.Position or Vector3.zero
    wD_1, wB_2 = nil, -1
    local wE = math.max(1, math.floor(#wA / 120))
    local wF = #wA
    local wK = 1
    while wE > 0 and wK <= wF or wE <= 0 and wK >= wF do
        local wE_1 = wA[wK]
        local wF_1 = wE_1.Position + Vector3.new(0, tS.BlockSize / 2, 0)
        local wE_2 = tS.MineState.GetBlocksInRadius(wF_1, ci)
        local wG = 0
        for i, v in ipairs(wE_2) do
            if v.Alive then
                wG += 1
            end
        end
        wG -= (wF_1 - wB_1).Magnitude * 0.01
        if wG > wB_2 then
            wD_1, wB_2 = wF_1, wG
        end
        wK += wE
    end
    return wD_1
end
local function fn118()
    local SellFilter = tx.SellFilter
    local zt = type(SellFilter) ~= "table" or next(SellFilter) == nil
    if zt then
        return nil
    end
    return SellFilter
end
local function fn143()
    if coroutine.status(tw) ~= "dead" then
        pcall(task.cancel, tw)
    end
end
local function fn193(hy)
    local Map = Workspace:FindFirstChild("Map")
    local Ae = Map and Map:FindFirstChild("Lobby")
    local Ad_1 = Ae
    if Ae then
        Ae = Ad_1:FindFirstChild("TrainingArea")
    end
    local Ad_2 = Ae
    if Ae then
        Ae = Ad_2:FindFirstChild("Plots")
    end
    local Ad_3 = Ae
    if Ae then
        Ae = Ad_3:FindFirstChild(hy)
    end
    local Ad_4 = Ae
    if not Ad_4 then
        return nil
    elseif Ad_4:IsA("Model") then
        local Ae_1 = Ad_4.PrimaryPart or Ad_4:FindFirstChildWhichIsA("BasePart")
        return Ae_1
    else
        local Ae_2 = Ad_4:IsA("BasePart") and Ad_4
        return Ae_2 or nil
    end
end
local function fn206()
    return CoreGui
end
local function fn242(ai)
    return us[ai] or "Idle"
end
local function fn257()
    local ClientCollectibleBlocks = Workspace:FindFirstChild("ClientCollectibleBlocks")
    if not ClientCollectibleBlocks then
        return {}
    end
    local xP = {}
    for i, child in ipairs(ClientCollectibleBlocks:GetChildren()) do
        if child:IsA("BasePart") then
            xP[#xP + 1] = child
        end
    end
    return xP
end
local function fn261()
    local AL = t0()
    if not AL then
        return false
    end
    local AM = tV(AL) or "Dirt"
    local AM_1 = um(AM)
    if not AM_1 then
        return false
    end
    return ty(AM_1.Position + Vector3.new(0, AM_1.Size.Y / 2 + 3, 0))
end
local function fn272()
    local vI = uk()
    local vJ = vI and vI:FindFirstChild("HumanoidRootPart")
    local vI_1 = vJ
    if vJ then
        vJ = vI_1.Parent
    end
    if vJ then
        return vI_1
    end
    return nil
end
local function fn293()
    local zN_2, zN_3
    local zJ = 0
    while tH() do
        task.wait(0.5)
        if not tH() then
            break
        elseif not tx.AutoSell then
            un("sell", "Idle")
        else
            local zK = t0()
            if not zK then
                continue
            end
            local zL = tB()
            local zL_3, zL_5
            local zM = ue(zK, zL)
            if zM <= 0 then
                un("sell", "Nothing to sell")
                continue
            elseif zM < tx.SellMinBlocks then
                un("sell", string.format("Holding %d / %d blocks", zM, tx.SellMinBlocks))
                continue
            elseif os.clock() < zJ then
                continue
            else
                zJ = os.clock() + math.max(tx.SellInterval, 0.5)
                local zM_1 = 0
                if zL then
                    for k in pairs(zL) do
                        if not tH() then
                            break
                        end
                        local zN_1 = zK.BlockInventory or {}
                        local zL_2 = tonumber(zN_1[k]) or 0
                        if zL_2 > 0 then
                            zL_3, zN_2 = pcall(zK.SellBlocks, zK, k)
                            if zL_3 and zN_2 and zN_2.Success then
                                local zL_4 = tonumber(zN_2.Payout) or 0
                                zM_1 += zL_4
                            end
                        end
                    end
                else
                    zL_5, zN_3 = pcall(zK.SellAllBlocks, zK)
                    if zL_5 and zN_3 and zN_3.Success then
                        local zK_2 = tonumber(zN_3.Payout) or 0
                        zM_1 = zK_2
                    end
                end
                local zK_3 = zM_1 > 0 and "Sold for $" .. t3(zM_1)
                local zL_6 = zK_3 or "Nothing to sell"
                un("sell", zL_6)
                continue
            end
        end
    end
end
local function fn296()
    local z__1
    local z2_1
    local z1_2, z1_3
    local zU
    local zV = 0
    local zW = os.clock()
    while tH() do
        task.wait(0.5)
        if not tH() then
            break
        end
        local zX = os.clock() - zW
        zW = os.clock()
        if not tx.AutoClick then
            zV = 0
            zU = nil
            un("click", "Idle")
            continue
        end
        local zY = t0()
        if not zY then
            continue
        end
        local zZ = zY.TrainingPlot or LocalPlayer:GetAttribute("IsTraining")
        local zZ_1, zZ_4
        if zZ then
            zV = 0
            un("click", "Paused while training")
        elseif not zY.EquippedBomb then
            un("click", "No TNT equipped")
        else
            zV += math.clamp(zX, 0, 2) * tx.ClickRate
            local zX_1 = math.floor(zV)
            if zX_1 <= 0 then
                continue
            end
            zV -= zX_1
            zZ_1, z__1 = pcall(zY.GetDamagePerClick, zY)
            local z0 = zU
            if not z0 then
                local z1_1 = zZ_1 and tonumber(z__1)
                z0 = z1_1 or nil
            end
            local zZ_3 = z0
            if not zZ_3 then
                continue
            end
            local z__2 = 0
            local z0_1 = {}
            local z7 = 1
            while z7 <= zX_1 do
                z1_2, z2_1 = pcall(zY._ApplyPredictedDamage, zY, zZ_3)
                if z1_2 then
                    z0_1[#z0_1 + 1] = z2_1
                    z__2 += zZ_3
                end
                z7 += 1
            end
            zZ_4, z1_3 = pcall(tS.Network.ClientAction.Invoke, { "ApplyClicks", { zX_1 } })
            local z1_4 = zZ_4 and z1_3 or nil
            local zZ_6 = math.max(z__2 * 1e-05, 0.0001)
            local z2_3 = z1_4 and tonumber(z1_4.DamagePerClick)
            if z2_3 then
                zU = tonumber(z1_4.DamagePerClick)
            end
            local z2_4 = z1_4 and z1_4.Success and z1_4.AcceptedClicks == zX_1
            if z2_4 then
                local abs = math.abs
                local z3 = z1_4.DamageGained
                local Ac = if z3 then 1 else 0
                local Aa = 2433 * Ac + 2274 * (1 - Ac)
                local Ab = 2568 * Ac + 829 * (1 - Ac)
                if not ((Aa * 2046 + Ab * 1356 + Aa * Ab) % 16777213 == 14708070) then
                    z3 = 0
                end
                z2_4 = abs(z3 - z__2) <= zZ_6
            end
            if z2_4 then
                pcall(zY._ConfirmPredictedDamage, zY, z0_1)
                un("click", string.format("Clicking %d/s (+%s dmg)", tx.ClickRate, t3(z__2)))
            else
                pcall(zY._ReconcilePredictedDamage, zY, z0_1, z1_4)
                local zY_1 = z1_4 and "Server throttled clicks" or "Click request failed"
                un("click", zY_1)
            end
        end
    end
end
local function fn308(bb)
    local vW_1
    local vV = tx.TargetArea ~= "Auto" and bb.OwnedAreas and bb.OwnedAreas[tx.TargetArea]
    local vV_1
    if vV then
        return tx.TargetArea
    end
    vV_1, vW_1 = pcall(bb.GetHighestOwnedAreaName, bb)
    return vV_1 and vW_1 or nil
end
local function fn339(bx, by, bz)
    local v7 = bx.CFrame:PointToObjectSpace(by)
    local v8 = math.max(bx.Size.X / 2 - bz, 0)
    local v9 = math.max(bx.Size.Z / 2 - bz, 0)
    local wa = math.abs(v7.X) <= v8 and math.abs(v7.Z) <= v9
    return wa
end
local function fn398(dZ, d_)
    un("mine", "Resetting mine")
    pcall(tS.Teleport.TeleportToArea, "Lobby")
    local x2 = os.clock() + 6
    while true do
        local x3 = tH() and os.clock() < x2
        if x3 then
            local x3_1 = dZ.HeldBombs or 0
            local x4 = x3_1 > 0 and not dZ:IsInMineArea()
            if x4 then
                break
            end
            task.wait(0.2)
            continue
        end
        break
    end
    if not tH() then
        return
    end
    ux(dZ, d_)
end
local function fn403(hK)
    local TrainingFilter = tx.TrainingFilter
    local Ak = type(TrainingFilter) ~= "table" or next(TrainingFilter) == nil
    if Ak then
        return true
    end
    return TrainingFilter[hK] == true
end
local function fn423()
    local AI = t0()
    if not AI then
        return false
    end
    local AJ = tG(AI)
    if not AJ then
        return false
    end
    return ux(AI, AJ)
end
local function fn424()
    return not tT.Unloaded
end
local function fn443(gH, gI)
    local zv = 0
    local zw = {}
    local zw_3
    local zx = gH.BlockInventory
    local zx_2
    local zC = if zx then 1 else 0
    local zA = 3693 * zC + 900 * (1 - zC)
    local zB = 855 * zC + 3752 * (1 - zC)
    if not ((zA * 1130 + zB * 3999 + zA * zB) % 16777213 == 10749750) then
        zx = zw
    end
    for k, v in pairs(zx) do
        local zx_1 = not gI or gI[k]
        if zx_1 then
            local zw_2 = tonumber(v) or 0
            zx_1 = zw_2 > 0
        end
        if zx_1 then
            zw_3, zx_2 = pcall(gH.IsBlockFavorited, gH, k)
            if not (zw_3 and zx_2) then
                local zw_4 = tonumber(v) or 0
                zv += zw_4
            end
        end
    end
    return zv
end
local function fn448(dp)
    local xF_1
    local xE_1
    local xD = uv()
    if not xD then
        return 0
    end
    xE_1, xF_1 = tY(dp)
    local xG = 0
    for i, child in ipairs(xD:GetChildren()) do
        if not tH() then
            break
        end
        local xD_1 = child:IsA("Model") and child.PrimaryPart and not child:GetAttribute("IsIgnited")
        if xD_1 then
            if ut(dp, child, xE_1, xF_1) then
                xG += 1
            end
        end
    end
    return xG
end
local function fn464()
    local Bb = {}
    local Bd = tS.EggAreas or {}
    for i, v in ipairs(Bd) do
        Bb[#Bb + 1] = v
    end
    if #Bb == 0 then
        Bb[1] = "Desert"
    end
    return Bb
end
local function fn469()
    local yX_3, yX_5, yX_6, yX_7
    local yW_3, yW_5, yW_7, yW_9
    local yV_6, yV_8, yV_9, yV_17
    while tH() do
        task.wait(1)
        if not tH() then
            break
        end
        local yU = t0()
        if not yU then
            continue
        end
        if tx.AutoUnlockArea then
            local yV_1 = yU:GetHighestOwnedAreaName()
            local yW_1 = yV_1 and tS.AreasConfig.GetNextName(yV_1)
            local yV_2 = yW_1 or nil
            if not yV_2 then
                un("areas", "All areas owned")
            else
                local yV_3 = tS.AreasConfig[yV_2]
                local yX_1 = yV_3 and tonumber(yV_3.Price)
                local yV_4 = yX_1 or 0
                local yV_5 = tonumber(yU.Money) or 0
                if yV_5 >= yV_4 then
                    yV_6, yX_3 = pcall(yU.PurchaseArea, yU, yV_2)
                    local yV_7 = yV_6 and yX_3 and yX_3.Success and "Unlocked " .. yV_2 or "Failed " .. yV_2
                    un("areas", yV_7)
                else
                    un("areas", "Saving for " .. yV_2)
                end
            end
        else
            un("areas", "Idle")
        end
        if tx.AutoBuyBomb then
            yW_3, yV_8 = ul(yU)
            if not yW_3 then
                un("bombs", "All TNT owned")
            else
                local yX_4 = tonumber(yU.Money) or 0
                if yX_4 >= yV_8 then
                    yV_9, yX_5 = pcall(yU.BuyBomb, yU, yW_3)
                    local yV_10 = yV_9 and yX_5 and yX_5.Success and "Bought " .. yW_3 or "Failed " .. yW_3
                    un("bombs", yV_10)
                else
                    un("bombs", "Saving for " .. yW_3)
                end
            end
        end
        if tx.AutoEquipBomb then
            local yV_11 = t1(yU)
            if yV_11 and yU.EquippedBomb ~= yV_11 then
                pcall(yU.EquipBomb, yU, yV_11)
                un("bombs", "Equipped " .. yV_11)
            elseif not tx.AutoBuyBomb then
                un("bombs", "Equipped " .. tostring(yU.EquippedBomb))
            end
        elseif not tx.AutoBuyBomb then
            un("bombs", "Idle")
        end
        if tx.AutoUpgrades then
            local yV_12 = nil
            for i, v in ipairs(uu) do
                if tD(v) then
                    yW_5, yX_6 = pcall(yU.BuyUpgrade, yU, v)
                    if yW_5 and yX_6 and yX_6.Success then
                        yV_12 = up[v]
                        break
                    end
                end
            end
            local yV_13 = yV_12 and "Upgraded " .. yV_12 or "Waiting for cash"
            un("upgrades", yV_13)
        else
            un("upgrades", "Idle")
        end
        if tx.AutoMineLuck then
            local yV_14 = tG(yU)
            if yV_14 then
                yW_7, yX_7 = pcall(yU.BuyUpgrade, yU, "MineLuck", yV_14)
                if yW_7 and yX_7 and yX_7.Success then
                    un("upgrades", "Mine Luck " .. yV_14 .. " lvl " .. tostring(yX_7.Level))
                end
            end
        end
        if tx.AutoRebirth then
            local GetRebirthLevelRequirement = tS.RebirthConfig.GetRebirthLevelRequirement
            local yW_8 = tonumber(yU.Rebirths) or 0
            local yX_8 = GetRebirthLevelRequirement(yW_8)
            local yV_16 = tonumber(yU.Level) or 0
            if yV_16 >= yX_8 then
                yV_17, yW_9 = pcall(yU.PerformRebirth, yU)
                local yW_10 = yV_17 and yW_9 and yW_9.Success and "Rebirthed" or "Rebirth pending"
                un("rebirth", yW_10)
            else
                local format = string.format
                local yW_11 = tonumber(yU.Level) or 0
                un("rebirth", format("Level %d / %d", yW_11, yX_8))
            end
        else
            un("rebirth", "Idle")
        end
    end
end
local function fn491(fd)
    local UpgradeFilter = tx.UpgradeFilter
    local yS = type(UpgradeFilter) ~= "table" or next(UpgradeFilter) == nil
    if yS then
        return true
    end
    return UpgradeFilter[up[fd]] == true or UpgradeFilter[fd] == true
end
local function fn549(dK, dL)
    local x_ = tE(dL)
    if not x_ then
        un("mine", "Area " .. tostring(dL) .. " not rendered")
        return false
    end
    if dK:GetMineAreaName() ~= dL then
        pcall(tS.Teleport.TeleportToArea, dL)
        local x__1 = os.clock() + 6
        while true do
            local x0 = tH() and os.clock() < x__1
            if x0 then
                local x0_1 = tS.MineRender.IsActiveMineReady() and tS.MineState.GetAreaName() == dL
                if x0_1 then
                    break
                end
                task.wait(0.15)
                continue
            end
            break
        end
    end
    local x__2 = tz(dL)
    if not x__2 then
        return false
    end
    ty(x__2)
    tF()
    return true
end
local function fn591()
    local AZ = {}
    local A_ = {}
    local A0 = tS.BlockNames
    local A4 = if A0 then 1 else 0
    local A2 = 2139 * A4 + 3621 * (1 - A4)
    local A3 = 3549 * A4 + 4039 * (1 - A4)
    if not ((A2 * 3468 + A3 * 1951 + A2 * A3) % 16777213 == 5156249) then
        A0 = A_
    end
    for i, v in ipairs(A0) do
        AZ[#AZ + 1] = v
    end
    return AZ
end
local function fn606(hO)
    local Aq_1
    local Ap_1
    local As_1
    local Ar_1
    Aq_1, Ap_1 = nil, -1
    for k, v in pairs(tS.TrainingConfig.Plots) do
        Ar_1, As_1 = pcall(hO.CanTrainAtPlot, hO, k)
        local At = Ar_1 and As_1 and ui(k)
        if At then
            local Ar_2 = tonumber(v.DamageMultiplier) or 0
            if Ar_2 > Ap_1 then
                Aq_1, Ap_1 = k, Ar_2
            end
        end
    end
    return Aq_1
end
local function fn607()
    while tH() do
        task.wait(1)
        local AB = not tH() or not tx.AutoTraining
        if AB then
            local AB_1 = tH() and not tx.AutoTraining
            if AB_1 then
                un("training", "Idle")
            end
            continue
        end
        local AB_2 = t0()
        if not AB_2 then
            continue
        end
        local AC = tV(AB_2)
        if not AC then
            un("training", "No unlocked plot")
            continue
        end
        local AB_3 = um(AC)
        if not AB_3 then
            un("training", AC .. " plot missing")
            continue
        end
        local AD = t_()
        local AE = AB_3.Position + Vector3.new(0, AB_3.Size.Y / 2 + 3, 0)
        if not AD or (AD.Position - AE).Magnitude > 4 then
            ty(AE)
        end
        un("training", "Training at " .. AC)
    end
end
local function fn615(b7)
    local wy_1
    local wx_1
    local GetBombExplosionRadius = b7.GetBombExplosionRadius
    local EquippedBomb = b7.EquippedBomb
    local ww = b7.EnchantedBombs or 0
    wx_1, wy_1 = pcall(GetBombExplosionRadius, b7, EquippedBomb, ww > 0)
    local wu_1 = wx_1 and tonumber(wy_1)
    local wv_1 = wu_1
    if not wv_1 then
        wv_1 = tS.MineConfig.ExplosionRadius and tS.MineConfig.ExplosionRadius.Minimum
    end
    local wu_3 = wv_1 or 2.6
    return wu_3, wu_3 * tS.BlockSize
end
local function fn616()
    local vx_1
    local vw_1
    if not tN then
        return nil
    end
    vw_1, vx_1 = pcall(tS.SessionClass.GetClient)
    local vy = vw_1 and type(vx_1) == "table"
    if vy then
        return vx_1
    end
    return nil
end
local function fn673(b3)
    local wm = 0
    local wo = b3.ActiveBombs or {}
    for k in pairs(wo) do
        wm += 1
    end
    return wm
end
local function fn676()
    local y9_10
    local y7_1, y7_2, y7_4, y7_6, y7_7, y7_8
    local y8_1, y8_2, y8_3, y8_5, y8_6, y8_7, y8_12
    while tH() do
        task.wait(2)
        if not tH() then
            break
        end
        local y5 = t0()
        if not y5 then
            continue
        end
        local y6
        if tx.AutoDaily then
            y7_1, y8_1 = pcall(y5.GetDailyRewardState, y5)
            if y7_1 and y8_1 and y8_1.CanClaim then
                y7_2, y8_2 = pcall(y5.ClaimDailyReward, y5)
                if y7_2 and y8_2 and y8_2.Success then
                    y6 = "Claimed daily reward"
                end
            end
        end
        if tx.AutoGroup and not y5.GroupRewardClaimed then
            y7_4, y8_3 = pcall(y5.ClaimGroupReward, y5)
            if y7_4 and y8_3 and y8_3.Success then
                y6 = "Claimed group reward"
            end
        end
        if tx.AutoIndex then
            for i, v in ipairs(tP()) do
                if not tH() then
                    break
                end
                local y7_5 = y5.OwnedAreas[v]
                if y7_5 then
                    y7_5 = not (y5.ClaimedIndexRewards or {})[v]
                end
                if y7_5 then
                    y7_6, y8_5 = pcall(y5.IsAreaIndexComplete, y5, v)
                    if y7_6 and y8_5 then
                        y7_7, y8_6 = pcall(y5.ClaimIndexReward, y5, v)
                        if y7_7 and y8_6 and y8_6.Success then
                            y6 = "Claimed index " .. v
                        end
                    end
                end
            end
        end
        if tx.AutoEquipPets then
            y7_8, y8_7 = pcall(y5.EquipBestPets, y5)
            if y7_8 and y8_7 and y8_7.Success then
                un("pets", "Equipped best pets")
            end
        end
        if tx.AutoHatchEgg then
            local EggArea = tx.EggArea
            local y8_8 = tS.AreasConfig[EggArea]
            local y9_8 = y8_8 and tonumber(y8_8.PetEggPrice)
            local y8_9 = y9_8 or nil
            if not y8_9 then
                un("pets", EggArea .. " has no eggs")
            elseif not y5.OwnedAreas[EggArea] then
                un("pets", EggArea .. " not owned")
            else
                local y8_10 = tonumber(y5.EggShards) or 0
                if y8_10 < y8_9 then
                    local format = string.format
                    local za = tonumber(y5.EggShards) or 0
                    un("pets", format("Shards %d / %d", za, y8_9))
                else
                    y8_12, y9_10 = pcall(y5.HatchPetEgg, y5, EggArea)
                    if y8_12 and y9_10 and y9_10.Success then
                        un("pets", "Hatching " .. EggArea .. " egg")
                    else
                        if y8_12 and y9_10 and y9_10.Message then
                            un("pets", y9_10.Message)
                        end
                    end
                end
            end
        elseif not tx.AutoEquipPets then
            un("pets", "Idle")
        end
        local y5_3 = y6
        if not y5_3 then
            y5_3 = (tx.AutoDaily or tx.AutoGroup or tx.AutoIndex) and "Watching"
        end
        local y6_2 = y5_3 or "Idle"
        un("rewards", y6_2)
    end
end
local function fn721()
    if not tN then
        return false
    end
    local AG = pcall(tS.Teleport.TeleportToArea, "Lobby")
    return AG
end
local function fn775(Z)
    return type(Z) == "function"
end
local function fn835()
    local AR = { "Auto" }
    for i, v in ipairs(tP()) do
        AR[#AR + 1] = v
    end
    return AR
end
local function fn840(eW)
    local yy_1
    local yx_1
    yy_1, yx_1 = nil, -1
    local yA = eW.OwnedBombs or {}
    for k in pairs(yA) do
        local yz_1 = tS.BombsConfig[k]
        local yA_1 = yz_1 and tonumber(yz_1.DamagePerClick)
        local yz_2 = yA_1 or 0
        if yz_2 > yx_1 then
            yy_1, yx_1 = k, yz_2
        end
    end
    return yy_1
end
local function fn904(bF, bG, bH)
    local bI = bF.CFrame:PointToObjectSpace(bG)
    local bJ = math.max(bF.Size.X / 2 - bH, 0)
    local bK = math.max(bF.Size.Z / 2 - bH, 0)
    local bL = -bF.Size.Y / 2 + bH
    local bM = Vector3.new(math.clamp(bI.X, -bJ, bJ), math.max(bI.Y, bL), math.clamp(bI.Z, -bK, bK))
    return bF.CFrame:PointToWorldSpace(bM)
end
local function fn923()
    return tS.AreaNames or {}
end
local function fn929(bO)
    local wc = tE(bO)
    if not wc then
        return nil
    end
    local wd = tN
    local we
    if wd then
        wd = tS.MineState.IsLoaded()
    end
    if wd then
        wd = tS.MineState.GetAreaName() == bO
    end
    if wd then
        for i, v in ipairs(tS.MineState.GetExposedBlocks()) do
            if not we or v.Position.Y > we then
                we = v.Position.Y
            end
        end
    end
    local we_1 = we and we + tS.BlockSize or wc.Position.Y + wc.Size.Y / 2 - 2
    return Vector3.new(wc.Position.X, we_1 + 4, wc.Position.Z)
end
local function fn942()
    local Character = LocalPlayer.Character
    if not Character or not Character.Parent then
        return nil
    end
    return Character
end
local function fn958(bo)
    local v4 = t8(bo)
    local v5 = v4 and v4:FindFirstChild("Mine")
    local v4_1 = v5
    if v5 then
        v5 = v4_1:FindFirstChild("MineArea")
    end
    local v4_2 = v5
    if v5 then
        v5 = v4_2:IsA("BasePart")
    end
    if v5 then
        return v4_2
    end
    return nil
end
local function fn964()
    gethui = t9
end
local function fn1039(af, ag)
    us[af] = ag
end
local function fn1128()
    local vD = {}
    if not tQ(getgenv) then
        table.insert(vD, "getgenv")
    end
    if not tN then
        table.insert(vD, "game modules")
    end
    return vD
end
local function fn1175()
    local yc_2
    local yb_5, yb_7
    while tH() do
        task.wait(0.2)
        if not tH() then
            break
        end
        local x6 = t0()
        if not x6 then
            un("mine", "Waiting for session")
        else
            if not (tx.AutoMine or tx.AutoDetonate or tx.AutoCollect) then
                un("mine", "Idle")
            else
                local x7_1 = tG(x6)
                if not x7_1 then
                    un("mine", "No owned area")
                else
                    local x8 = tx.AutoMine
                    if x8 then
                        local x9_1 = not x6:IsInMineArea() or x6:GetMineAreaName() ~= x7_1
                        x8 = x9_1
                    end
                    if x8 then
                        ux(x6, x7_1)
                    end
                    local x8_1 = x6:IsInMineArea()
                    if tx.AutoMine and x8_1 then
                        local x9_3 = tonumber(x6.HeldBombs) or 0
                        local x9_4 = ug(x6)
                        if x9_3 <= 0 and x9_4 <= 0 then
                            if tx.AutoReturn then
                                ud(x6, x7_1)
                            else
                                un("mine", "Out of TNT")
                            end
                        else
                            local yb_2 = x9_3 > 0
                            if yb_2 then
                                local yc_1 = tonumber(x6.MaxActiveBombs) or 1
                                yb_2 = x9_4 < yc_1
                            end
                            if yb_2 then
                                if tS.MineRender.IsActiveMineReady() then
                                    local yb_3 = tA(x6)
                                    if yb_3 then
                                        tF()
                                        un("mine", string.format("Mining %s (%d TNT left)", x7_1, x9_3 - 1))
                                    else
                                        un("mine", "No mineable blocks")
                                    end
                                else
                                    un("mine", "Mine loading")
                                end
                            else
                                un("mine", string.format("Mining %s (%d placed)", x7_1, x9_4))
                            end
                        end
                    end
                    local x9_5 = tx.AutoDetonate and x8_1 and tS.MineRender.IsActiveMineReady()
                    if x9_5 then
                        if uh(x6) > 0 then
                            tF()
                        end
                    end
                    if tx.AutoCollect and x8_1 then
                        local x9_7 = t_()
                        local ya_2 = ub()
                        if x9_7 and #ya_2 > 0 then
                            yb_5, yc_2 = pcall(x6.GetUpgradeValue, x6, "CollectionRange")
                            local yd = yb_5 and tonumber(yc_2)
                            local yd_1
                            local yc_3 = (yd or 12) * 0.8
                            yd_1, yb_7 = nil, math.huge
                            for i, v in ipairs(ya_2) do
                                local Magnitude = (v.Position - x9_7.Position).Magnitude
                                if Magnitude > yc_3 and Magnitude < yb_7 then
                                    yd_1, yb_7 = v, Magnitude
                                end
                            end
                            if yd_1 then
                                local x9_8 = tE(x7_1)
                                local ya_4 = yd_1.Position + Vector3.new(0, 3, 0)
                                if x9_8 then
                                    ya_4 = uc(x9_8, ya_4, 3)
                                end
                                ty(ya_4)
                                tF()
                            end
                        end
                    end
                    if tx.AutoUnstuck and tx.AutoMine and x8_1 then
                        local x8_2 = 0
                        if tS.MineState.IsLoaded() then
                            for k, v in pairs(tS.MineState.GetBlocks()) do
                                if v.Alive then
                                    x8_2 += 1
                                end
                            end
                        end
                        if x8_2 ~= tJ then
                            tJ = x8_2
                            tF()
                        elseif os.clock() - tM >= tx.StuckSeconds then
                            un("mine", "Unsticking")
                            ud(x6, x7_1)
                            tF()
                        end
                    end
                end
            end
        end
    end
end
local function fn1198()
    tM = os.clock()
end
local function fn1202(e4)
    local yH_1
    local yG_1
    yG_1, yH_1 = nil, math.huge
    for k, v in pairs(tS.BombsConfig) do
        local yI = tonumber(v.Price) or 0
        local yI_1 = not e4:OwnsBomb(k) and yI > 0 and yI < yH_1
        if yI_1 then
            yG_1, yH_1 = k, yI
        end
    end
    return yG_1, yH_1
end
local function fn1204(gz)
    local zl = (tonumber(gz))
    local zr = if zl then 1 else 0
    local zp = 864 * zr + 138 * (1 - zr)
    local zq = 403 * zr + 321 * (1 - zr)
    if not ((zp * 2306 + zq * 3162 + zp * zq) % 16777213 == 3614862) then
        zl = 0
    end
    local zm = 1
    local zn = zl
    while true do
        if zn >= 1000 and zm < #t5 then
            zn /= 1000
            zm += 1
            continue
        end
        break
    end
    if zm == 1 then
        return string.format("%d", zn)
    end
    return string.format("%.2f%s", zn, t5[zm])
end
tw = nil
tx = nil
ty = nil
tz = nil
tA = nil
tB = nil
LocalPlayer = nil
tD = nil
tE = nil
tF = nil
tG = nil
tH = nil
Workspace = nil
tJ = nil
tM = nil
tN = nil
tP = nil
tQ = nil
tS = nil
tT = nil
tV = nil
CoreGui = nil
tY = nil
t_ = nil
t0 = nil
t1 = nil
t3 = nil
t5 = nil
t8 = nil
t9 = nil
ub = nil
uc = nil
ud = nil
ue = nil
local Players, tu, tv, tK, Lighting, tO, TeleportService, tU, tX, GuiService, t2, HttpService, VirtualUser, t7, UserInputService, uf
ug = nil
uh = nil
ui = nil
uk = nil
ul = nil
um = nil
un = nil
up = nil
us = nil
ut = nil
uu = nil
uv = nil
ux = nil
local uj, uo, uq, ur, uw
local uA_1
if not game:IsLoaded() then
    game.Loaded:Wait()
end
Players, uq, uj, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, TeleportService, Lighting, Workspace, LocalPlayer, uu, up, uf, t9 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
if (not CoreGui or not CoreGui) and (not LocalPlayer or CoreGui) or (not LocalPlayer and CoreGui or not CoreGui and CoreGui) or not ((not CoreGui or not CoreGui) and (not LocalPlayer or CoreGui) or (not LocalPlayer and CoreGui or not CoreGui and CoreGui)) then
    uq = game:GetService("ReplicatedStorage")
    uj = game:GetService("RunService")
else
    uj = game:GetService("ReplicatedStorage")
    uq = game:GetService("RunService")
end
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
TeleportService = game:GetService("TeleportService")
Lighting = game:GetService("Lighting")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local uz = "TempoTntMining"
uu = { "MaxHeldBombs", "MaxActiveBombs", "CollectionRange", "WalkSpeed" }
up = {
    MaxHeldBombs = "Carried TNT",
    MaxActiveBombs = "Placed TNT",
    CollectionRange = "Range",
    WalkSpeed = "Speed"
}
uf = { "Dirt", "Stone", "Cactus", "Silver", "Gold", "Ruby" }
t9 = fn206
if getgenv then
    getgenv().gethui = t9
end
tT, tx, us, tS, tN, tM, tJ, t5, tw, uA_1, uw, tQ, tH, un, tK, t0, uk, t_, ty, tP, tG, t8, tE, tU, uc, tz, uv, ug, tY, t7, tA, ut, uh, ub, tF, ux, ud, tu, uo, t1, ul, tD, t2, ur, t3, tB, ue, tv, tO, um, ui, tV, tX = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if false and uh and (t5 and 40) or (not t5 and not t7 or uh and false) or (t5 and not uh or false and not t_ or (t7 and not t7)) or not (false and uh and (t5 and 40) or (not t5 and not t7 or uh and false) or (t5 and not uh or false and not t_ or (t7 and not t7))) then
    pcall(fn964)
    uA_1 = function(w)
        local uY
        local uZ
        local uX
        uX = nil
        uY = nil
        uZ = nil
        local u_ = w ~= ""
        local u0 = type(w) == "string" and u_
        assert(u0, "A namespace is required")
        assert(type(getgenv) == "function", "getgenv is unavailable")
        uX = getgenv()
        assert(type(uX) == "table", "getgenv did not return a table")
        local u__2 = uX[w]
        if u__2 ~= nil then
            local u0_2 = type(u__2) == "table" and type(u__2.Unload) == "function"
            assert(u0_2, "Namespace is occupied")
            u__2.Unload()
            assert(uX[w] == nil, "Previous instance did not release its namespace")
        end
        uY = {}
        uZ = { State = {}, Unloaded = false }
        uZ.Track = function(D)
            assert(type(D) == "function", "Cleanup must be callable")
            if uZ.Unloaded then
                D()
            else
                table.insert(uY, D)
            end
            return D
        end
        uZ.Unload = function()
            local uQ_2
            local uP_2
            if uZ.Unloaded then
                return
            end
            uZ.Unloaded = true
            local uN = {}
            local uU = #uY
            local uT = -1
            while false and uU <= 1 or true and uU >= 1 do
                local uV = uU
                local uO_2 = table.remove(uY, uV)
                uP_2, uQ_2 = pcall(uO_2)
                if not uP_2 then
                    table.insert(uN, tostring(uQ_2))
                end
                uU += uT
            end
            table.clear(uZ.State)
            if #uN > 0 then
                error("Cleanup incomplete: " .. table.concat(uN, "; "), 0)
            end
            if uX[w] == uZ then
                uX[w] = nil
            end
        end
        uX[w] = uZ
        return uZ
    end
else
    pcall(fn964)
    t2 = function(w)
        local uY
        local uZ
        local uX
        uX = nil
        uY = nil
        uZ = nil
        local u_ = w ~= ""
        local u0 = type(w) == "string" and u_
        assert(u0, "A namespace is required")
        assert(type(getgenv) == "function", "getgenv is unavailable")
        uX = getgenv()
        assert(type(uX) == "table", "getgenv did not return a table")
        local u__1 = uX[w]
        if u__1 ~= nil then
            local u0_1 = type(u__1) == "table" and type(u__1.Unload) == "function"
            assert(u0_1, "Namespace is occupied")
            u__1.Unload()
            assert(uX[w] == nil, "Previous instance did not release its namespace")
        end
        uY = {}
        uZ = { State = {}, Unloaded = false }
        uZ.Track = function(D)
            assert(type(D) == "function", "Cleanup must be callable")
            if uZ.Unloaded then
                D()
            else
                table.insert(uY, D)
            end
            return D
        end
        uZ.Unload = function()
            local uQ_1
            local uP_1
            if uZ.Unloaded then
                return
            end
            uZ.Unloaded = true
            local uN = {}
            local uU = #uY
            local uT = -1
            while false and uU <= 1 or true and uU >= 1 do
                local uV = uU
                local uO_1 = table.remove(uY, uV)
                uP_1, uQ_1 = pcall(uO_1)
                if not uP_1 then
                    table.insert(uN, tostring(uQ_1))
                end
                uU += uT
            end
            table.clear(uZ.State)
            if #uN > 0 then
                error("Cleanup incomplete: " .. table.concat(uN, "; "), 0)
            end
            if uX[w] == uZ then
                uX[w] = nil
            end
        end
        uX[w] = uZ
        return uZ
    end
end
uw = function(Q, R)
    local u6 = type(Q) == "table" and type(Q.Track) == "function"
    assert(u6, "FeatureAPI required")
    local u6_1 = type(R) == "table" and type(R.OnUnload) == "function"
    assert(u6_1, "UI library required")
    assert(type(R.Unload) == "function", "UI unload required")
    Q.Track(function()
        if not R.Unloaded then
            R:Unload()
        end
    end)
    R:OnUnload(function()
        Q.Unload()
    end)
end
tT = uA_1(uz)
tQ = fn775
tH = fn424
tx = {
    AutoMine = false,
    AutoDetonate = false,
    AutoCollect = false,
    AutoReturn = false,
    ClampToPit = true,
    AutoUnstuck = false,
    StuckSeconds = 8,
    TargetArea = "Auto",
    AutoUnlockArea = false,
    AutoBuyBomb = false,
    AutoEquipBomb = false,
    AutoEquipPets = false,
    AutoHatchEgg = false,
    EggArea = "Desert",
    AutoUpgrades = false,
    UpgradeFilter = {},
    AutoMineLuck = false,
    AutoDaily = false,
    AutoGroup = false,
    AutoIndex = false,
    AutoSell = false,
    SellInterval = 5,
    SellMinBlocks = 0,
    SellFilter = {},
    AutoClick = false,
    ClickRate = 15,
    AutoTraining = false,
    TrainingFilter = {},
    AutoRebirth = false
}
us = {
    mine = "Idle",
    sell = "Idle",
    click = "Idle",
    areas = "Idle",
    bombs = "Idle",
    pets = "Idle",
    upgrades = "Idle",
    rewards = "Idle",
    training = "Idle",
    rebirth = "Idle"
}
un = fn1039
tT.StatusLine = fn242
tS = {}
tN = false
tK = function()
    local Logic, ClientLogic
    Logic = uq:WaitForChild("Logic", 30)
    ClientLogic = uq:WaitForChild("ClientLogic", 30)
    if not Logic or not ClientLogic then
        return false
    end
    local vt_1 = pcall(function()
        tS.SessionClass = require(Logic.Classes.PlayerSession)
        tS.MineState = require(ClientLogic.Services.MineStateService)
        tS.MineRender = require(ClientLogic.Engines.MineRenderEngine)
        tS.Teleport = require(ClientLogic.Engines.TeleportEngine)
        tS.Hotbar = require(ClientLogic.Engines.HotbarEngine)
        tS.Render = require(Logic.Services.RenderService)
        tS.MineConfig = require(Logic.Configs.MineConfig)
        tS.BombsConfig = require(Logic.Configs.BombsConfig)
        tS.AreasConfig = require(Logic.Configs.AreasConfig)
        tS.UpgradesConfig = require(Logic.Configs.UpgradesConfig)
        tS.TrainingConfig = require(Logic.Configs.TrainingConfig)
        tS.RebirthConfig = require(Logic.Configs.RebirthConfig)
        tS.BlocksConfig = require(Logic.Configs.BlocksConfig)
        tS.Network = require(Logic.Network)
        tS.BlockSize = uq.Assets.Models.BlockTemplate.Root.Size.X
        tS.AreaNames = tS.AreasConfig.GetOrderedNames()
        tS.BlockNames = {}
        for k in pairs(tS.BlocksConfig) do
            table.insert(tS.BlockNames, k)
        end
        table.sort(tS.BlockNames, function(aw, ax)
            local va = tonumber(tS.BlocksConfig[aw].SellValue) or 0
            local va_1 = tonumber(tS.BlocksConfig[ax].SellValue) or 0
            if va == va_1 then
                return aw < ax
            end
            return va < va_1
        end)
        tS.EggAreas = {}
        for i, v in ipairs(tS.AreaNames) do
            local ve = tS.AreasConfig[v]
            local vf = ve and tonumber(ve.PetEggPrice)
            if vf then
                table.insert(tS.EggAreas, v)
            end
        end
    end)
    if not vt_1 then
        return false
    end
    tN = true
    return true
end
t0 = fn616
tT.Support = fn1128
uk = fn942
t_ = fn272
ty = function(a0)
    local vO
    vO = nil
    vO = uk()
    if not vO then
        return false
    end
    local vP = pcall(function()
        vO:PivotTo(CFrame.new(a0))
    end)
    if vP then
        local vQ = t_()
        if vQ then
            vQ.AssemblyLinearVelocity = Vector3.zero
            vQ.AssemblyAngularVelocity = Vector3.zero
        end
    end
    return vP
end
tP = fn923
tG = fn308
t8 = fn42
tE = fn958
tU = fn339
uc = fn904
tz = fn929
uv = fn78
ug = fn673
tY = fn615
t7 = fn81
tA = function(cB)
    local w3
    w3 = nil
    local EquippedBomb, w1, w2, w4, w5
    local w7_1
    local w6 = uv()
    local w6_1
    if not w6 then
        return false
    end
    w7_1, w6_1 = tY(cB)
    w4 = t7(cB, w6_1)
    if not w4 then
        return false
    end
    EquippedBomb = cB.EquippedBomb
    local w8 = cB.EnchantedBombs or 0
    local w8_2
    w2 = w8 > 0
    w5, w1 = pcall(cB.GetBombConfig, cB)
    w3 = nil
    local w8_1 = pcall(function()
        local Place = tS.Render.Bomb.Place
        local wU = CFrame.new(w4)
        local wW = w5 and w1 or nil
        w3 = Place({ Name = EquippedBomb, Cframe = wU, Config = wW, IsEnchanted = w2 })
    end)
    local w9 = not w3
    local w9_1
    if not w8_1 or w9 then
        return false
    end
    w8_2, w9_1 = pcall(cB.PlaceBomb, cB, CFrame.new(w4), nil, EquippedBomb)
    if not w8_2 or not w9_1 or not w9_1.Success then
        pcall(function()
            w3:Destroy()
        end)
        return false
    end
    w3.Name = w9_1.Id
    w3:SetAttribute("Name", EquippedBomb)
    return true, w7_1, w6_1
end
ut = function(c1, c2, c3, c4)
    local xp, xq, xr, xs
    local xu_1, xu_2
    local xt = c1.ActiveBombs and c1.ActiveBombs[c2.Name]
    local xt_2, xt_3
    xs = xt
    if not xs or xs.IsFused then
        return false
    end
    xt_2, xu_1 = pcall(c1.IgniteBomb, c1, c2.Name)
    local xv = not xt_2 or not xu_1
    local xz = if xv then 1 else 0
    local xx = 2526 * xz + 933 * (1 - xz)
    local xy = 1019 * xz + 2223 * (1 - xz)
    if not ((xx * 2286 + xy * 2405 + xx * xy) % 16777213 == 10799125) then
        xv = not xu_1.Success
    end
    if xv then
        return false
    end
    xr = 1
    if xs.IsEnchanted then
        xt_3, xu_2 = pcall(c1.GetEnchantedBombDamageMultiplier, c1)
        local xv_1 = xt_3 and tonumber(xu_2)
        local xt_4 = xv_1
        local xz_1 = if xt_4 then 1 else 0
        local xx_1 = 1484 * xz_1 + 3417 * (1 - xz_1)
        local xy_1 = 3689 * xz_1 + 690 * (1 - xz_1)
        if not ((xx_1 * 3654 + xy_1 * 3654 + xx_1 * xy_1) % 16777213 == 7599405) then
            xt_4 = 1
        end
        xr = xt_4
    end
    xq, xp = pcall(c1.GetBombDamagePerClick, c1, xs.Name)
    pcall(function()
        local PlayEvent = tS.Render.PlayEvent
        local Name2 = c2.Name
        local Name = xs.Name
        local FuseTime = tS.MineConfig.FuseTime
        local IsEnchanted = xs.IsEnchanted
        local xh = tonumber(c1.Damage) or 0
        local xi = xh * xr
        local xk = xq and xp
        local xo = if xk then 1 else 0
        local xm = 4090 * xo + 3493 * (1 - xo)
        local xn = 2315 * xo + 3641 * (1 - xo)
        if not ((xm * 2033 + xn * 445 + xm * xn) % 16777213 == 2036282) then
            xk = nil
        end
        PlayEvent("Bomb.Ignite", {
            Id = Name2,
            Name = Name,
            FuseTime = FuseTime,
            ExplosionRadius = c3,
            MineRadius = c4,
            IsEnchanted = IsEnchanted,
            Damage = xi,
            DamagePerClick = xk,
            Session = c1,
            ActiveBomb = xs
        })
    end)
    return true
end
uh = fn448
ub = fn257
if (not tB or false or tu and tS) and ((false or tB) and (tJ and not tJ)) or (tB or tJ or (not tS or tu) or tS and not tS and (not tJ or tJ)) or not ((not tB or false or tu and tS) and ((false or tB) and (tJ and not tJ)) or (tB or tJ or (not tS or tu) or tS and not tS and (not tJ or tJ))) then
    tM = os.clock()
    tJ = -1
    tF = fn1198
    ux = fn549
    ud = fn398
else
    ux = os.clock()
    ud = -1
    tM = fn1198
    tJ = fn549
    tF = fn398
end
tu = fn1175
uo = function()
    local connection
    connection = uj.Heartbeat:Connect(function()
        local ys = not tH() or not tx.ClampToPit
        if ys or not tN then
            return
        end
        local ys_1 = t0()
        local yt_1 = t_()
        if not ys_1 or not yt_1 then
            return
        end
        local yu_2 = ys_1:GetMineAreaName()
        if not yu_2 then
            return
        end
        local ys_2 = tE(yu_2)
        if not ys_2 then
            return
        end
        local Position = yt_1.Position
        local yv_1 = tU(ys_2, Position, 2) and Position.Y > ys_2.Position.Y - ys_2.Size.Y / 2 + 3
        if yv_1 then
            return
        end
        local yv_2 = uc(ys_2, Position, 3)
        yt_1.CFrame = CFrame.new(yv_2)
        yt_1.AssemblyLinearVelocity = Vector3.zero
    end)
    tT.Track(function()
        connection:Disconnect()
    end)
end
t1 = fn840
ul = fn1202
tD = fn491
t2 = fn469
ur = fn676
t5 = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }
t3 = fn1204
tB = fn118
ue = fn443
tv = fn293
tO = fn296
um = fn193
ui = fn403
tV = fn606
tX = fn607
tT.TeleportLobby = fn721
tT.TeleportMine = fn423
tT.TeleportTraining = fn261
local function uC(ix)
    return function(iy)
        tx[ix] = iy
    end
end
tT.SetAutoMine = uC("AutoMine")
tT.SetAutoDetonate = uC("AutoDetonate")
tT.SetAutoCollect = uC("AutoCollect")
tT.SetAutoReturn = uC("AutoReturn")
tT.SetClampToPit = uC("ClampToPit")
tT.SetAutoUnstuck = uC("AutoUnstuck")
tT.SetStuckSeconds = uC("StuckSeconds")
tT.SetTargetArea = uC("TargetArea")
tT.SetAutoUnlockArea = uC("AutoUnlockArea")
tT.SetAutoBuyBomb = uC("AutoBuyBomb")
tT.SetAutoEquipBomb = uC("AutoEquipBomb")
tT.SetAutoEquipPets = uC("AutoEquipPets")
tT.SetAutoHatchEgg = uC("AutoHatchEgg")
tT.SetEggArea = uC("EggArea")
tT.SetAutoUpgrades = uC("AutoUpgrades")
tT.SetUpgradeFilter = uC("UpgradeFilter")
tT.SetAutoMineLuck = uC("AutoMineLuck")
tT.SetAutoDaily = uC("AutoDaily")
tT.SetAutoGroup = uC("AutoGroup")
tT.SetAutoIndex = uC("AutoIndex")
tT.SetAutoSell = uC("AutoSell")
tT.SetSellInterval = uC("SellInterval")
tT.SetSellMinBlocks = uC("SellMinBlocks")
tT.SetSellFilter = uC("SellFilter")
tT.SetAutoClick = uC("AutoClick")
tT.SetClickRate = uC("ClickRate")
tT.SetAutoTraining = uC("AutoTraining")
tT.SetTrainingFilter = uC("TrainingFilter")
tT.SetAutoRebirth = uC("AutoRebirth")
tT.AreaOptions = fn835
tT.BlockOptions = fn591
tT.EggAreaOptions = fn464
tw = task.spawn(function()
    local Bq = os.clock() + 30
    while true do
        local Br_1 = tH() and os.clock() < Bq
        if Br_1 then
            local Br_2 = tK() and t0()
            if Br_2 then
                break
            end
            task.wait(0.5)
            continue
        end
        break
    end
    local Bq_1 = not tN
    local Br_3 = not tH() or Bq_1
    if Br_3 then
        return
    end
    uo()
    for i, v in ipairs({ tu, t2, ur, tv, tO, tX }) do
        local Bp
        Bp = task.spawn(v)
        tT.Track(function()
            local Bo = if coroutine.status(Bp) ~= "dead" then 1 else 0
            if Bo == 1 then
                pcall(task.cancel, Bp)
            end
        end)
    end
end)
tT.Track(fn143)
local function uB()
    local jH
    local kq
    local jc = "https://discord.gg/K7Qxnxkk46"
    local i9 = "+1 TNT Mining"
    local jd = "https://tempohub.shop"
    local ja = "v0.2"
    local jb = "https://discord.gg/K7Qxnxkk46"
    local Library = getgenv().Library
    local ThemeManager = getgenv().ThemeManager
    local SaveManager = getgenv().SaveManager
    local Toggles = Library.Toggles
    local Options = Library.Options
    uw(tT, Library)
    local function jm(jn, jo)
        local BD = tQ(setclipboard) and setclipboard
        local BE = BD
        if not BE then
            local BD_1 = tQ(toclipboard) and toclipboard
            BE = BD_1 or nil
        end
        local BD_2 = BE
        if not BD_2 then
            Library:Notify("Clipboard is unavailable")
            return
        end
        local BE_1 = pcall(BD_2, jn)
        if BE_1 then
            Library:Notify(jo)
        else
            Library:Notify("Failed to copy")
        end
    end
    local function onDiscord()
        jm(jb, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = jb, Copyable = true }, "|", i9, "|", ja },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(false)
    local jB = {
        [1] = Window:AddTab("Info", "info"),
        [2] = Window:AddTab("Main", "gamepad-2"),
        [3] = Window:AddTab("Player", "person-standing"),
        [4] = Window:AddTab("Settings", "settings")
    }
    local jC = {
        [1] = jB[2]:AddSubTab("Mining", "pickaxe"),
        [2] = jB[2]:AddSubTab("Progression", "trending-up"),
        [3] = jB[2]:AddSubTab("Rewards", "gift")
    }
    local function jD(jE)
        local DiscordGroup = jE:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    jD(jC[1])
    jD(jC[2])
    jD(jC[3])
    jD(jB[3])
    jD(jB[4])
    jH = "#ffb6c1"
    local function jI(jJ)
        local jK = tostring(jJ):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
        return string.format('<font color="%s">%s</font>', jH, jK)
    end
    local jM = {}
    local function jN()
        local Mining_TntGroup = jC[1]:AddRightGroupbox("Mining & TNT", "bomb")
        jM.mine = Mining_TntGroup:AddLabel(jI("Idle"), true)
        Mining_TntGroup:AddToggle("AutoMine", { Text = "Auto Mine (TNT Farm)", Default = false, Callback = tT.SetAutoMine })
        Mining_TntGroup:AddDropdown("TargetArea", { Text = "Mine Area", Values = tT.AreaOptions(), Default = 1, Callback = tT.SetTargetArea })
        Mining_TntGroup:AddToggle("AutoDetonate", { Text = "Auto TNT Detonation", Default = false, Callback = tT.SetAutoDetonate })
        Mining_TntGroup:AddToggle("AutoCollect", { Text = "Auto Collect Dropped Blocks", Default = false, Callback = tT.SetAutoCollect })
        Mining_TntGroup:AddToggle("AutoReturn", { Text = "Auto Return & Reset Mine", Default = false, Callback = tT.SetAutoReturn })
        Mining_TntGroup:AddToggle("ClampToPit", { Text = "Safe Mine Pit Bounds Clamping (Anti-Void)", Default = true, Callback = tT.SetClampToPit })
        Mining_TntGroup:AddToggle("AutoUnstuck", { Text = "Auto Unstuck", Default = false, Callback = tT.SetAutoUnstuck })
        Mining_TntGroup:AddSlider("StuckSeconds", {
            Text = "Stuck Timeout",
            Default = 8,
            Min = 3,
            Max = 60,
            Rounding = 0,
            Suffix = "s",
            Callback = tT.SetStuckSeconds
        })
        local AreasGroup = jC[1]:AddLeftGroupbox("Areas", "map")
        jM.areas = AreasGroup:AddLabel(jI("Idle"), true)
        AreasGroup:AddToggle("AutoUnlockArea", { Text = "Auto Unlock Next Area", Default = false, Callback = tT.SetAutoUnlockArea })
        AreasGroup:AddToggle("AutoTargetArea", {
            Text = "Auto Target Highest Owned Area",
            Default = true,
            Callback = function(jU)
                if jU then
                    tT.SetTargetArea("Auto")
                    if Options.TargetArea then
                        Options.TargetArea:SetValue("Auto")
                    end
                end
            end
        })
        local BombsGroup = jC[1]:AddLeftGroupbox("Bombs", "flame")
        jM.bombs = BombsGroup:AddLabel(jI("Idle"), true)
        BombsGroup:AddToggle("AutoBuyBomb", { Text = "Auto Buy Next Bomb", Default = false, Callback = tT.SetAutoBuyBomb })
        BombsGroup:AddToggle("AutoEquipBomb", { Text = "Auto Equip Highest Owned Bomb", Default = false, Callback = tT.SetAutoEquipBomb })
    end
    local function jZ()
        local UpgradesGroup = jC[2]:AddRightGroupbox("Upgrades", "arrow-big-up")
        jM.upgrades = UpgradesGroup:AddLabel(jI("Idle"), true)
        UpgradesGroup:AddToggle("AutoUpgrades", { Text = "Auto Buy Stat Upgrades", Default = false, Callback = tT.SetAutoUpgrades })
        UpgradesGroup:AddDropdown("UpgradeFilter", {
            Text = "Stat Upgrades",
            Values = { "Carried TNT", "Placed TNT", "Range", "Speed" },
            Default = {},
            Multi = true,
            AllowNull = true,
            Callback = tT.SetUpgradeFilter
        })
        UpgradesGroup:AddToggle("AutoMineLuck", { Text = "Auto Buy Area Mine Luck", Default = false, Callback = tT.SetAutoMineLuck })
        local ClickingGroup = jC[2]:AddRightGroupbox("Clicking", "mouse-pointer-click")
        jM.click = ClickingGroup:AddLabel(jI("Idle"), true)
        ClickingGroup:AddToggle("AutoClick", { Text = "Auto Click", Default = false, Callback = tT.SetAutoClick })
        ClickingGroup:AddSlider("ClickRate", {
            Text = "Clicks Per Second",
            Default = 15,
            Min = 1,
            Max = 25,
            Rounding = 0,
            Callback = tT.SetClickRate
        })
        local TrainingGroup = jC[2]:AddLeftGroupbox("Training", "dumbbell")
        jM.training = TrainingGroup:AddLabel(jI("Idle"), true)
        TrainingGroup:AddToggle("AutoTraining", { Text = "Auto Best Training Zone", Default = false, Callback = tT.SetAutoTraining })
        TrainingGroup:AddDropdown("TrainingFilter", {
            Text = "Allowed Zones",
            Values = uf,
            Default = {},
            Multi = true,
            AllowNull = true,
            Callback = tT.SetTrainingFilter
        })
        local ProgressionGroup = jC[2]:AddLeftGroupbox("Progression", "repeat")
        jM.rebirth = ProgressionGroup:AddLabel(jI("Idle"), true)
        ProgressionGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false, Callback = tT.SetAutoRebirth })
    end
    local function j9()
        local RewardsGroup = jC[3]:AddRightGroupbox("Rewards", "gift")
        jM.rewards = RewardsGroup:AddLabel(jI("Idle"), true)
        RewardsGroup:AddToggle("AutoDaily", { Text = "Auto Claim Daily Reward", Default = false, Callback = tT.SetAutoDaily })
        RewardsGroup:AddToggle("AutoGroup", { Text = "Auto Claim Group Reward", Default = false, Callback = tT.SetAutoGroup })
        RewardsGroup:AddToggle("AutoIndex", { Text = "Auto Claim Index Rewards", Default = false, Callback = tT.SetAutoIndex })
        RewardsGroup:AddToggle("AutoSell", { Text = "Auto Sell Mined Blocks", Default = false, Callback = tT.SetAutoSell })
        jM.sell = RewardsGroup:AddLabel(jI("Idle"), true)
        RewardsGroup:AddDropdown("SellFilter", {
            Text = "Blocks To Sell",
            Values = tT.BlockOptions(),
            Default = {},
            Multi = true,
            AllowNull = true,
            Callback = tT.SetSellFilter
        })
        RewardsGroup:AddSlider("SellInterval", {
            Text = "Sell Interval",
            Default = 5,
            Min = 1,
            Max = 120,
            Rounding = 0,
            Suffix = "s",
            Callback = tT.SetSellInterval
        })
        RewardsGroup:AddSlider("SellMinBlocks", {
            Text = "Sell When Blocks Reach",
            Default = 0,
            Min = 0,
            Max = 500,
            Rounding = 0,
            Callback = tT.SetSellMinBlocks
        })
        local Pets_EggsGroup = jC[3]:AddLeftGroupbox("Pets & Eggs", "paw-print")
        jM.pets = Pets_EggsGroup:AddLabel(jI("Idle"), true)
        Pets_EggsGroup:AddToggle("AutoEquipPets", { Text = "Auto Equip Best Pets", Default = false, Callback = tT.SetAutoEquipPets })
        Pets_EggsGroup:AddToggle("AutoHatchEgg", { Text = "Auto Hatch Selected Egg", Default = false, Callback = tT.SetAutoHatchEgg })
        Pets_EggsGroup:AddDropdown("EggArea", { Text = "Egg Area", Values = tT.EggAreaOptions(), Default = 1, Callback = tT.SetEggArea })
    end
    jN()
    jZ()
    j9()
    kq = task.spawn(function()
        while not Library.Unloaded do
            task.wait(0.35)
            if Library.Unloaded then
                break
            end
            for k, v in pairs(jM) do
                local BL
                local BS = v
                BL = tT.StatusLine(k)
                pcall(function()
                    BS:SetText(jI(BL))
                end)
            end
        end
    end)
    tT.Track(function()
        local BW = if coroutine.status(kq) ~= "dead" then 1 else 0
        if BW == 1 then
            pcall(task.cancel, kq)
        end
    end)
    local function ks()
        local Co
        local Ck
        local Cg
        local Cn
        Cg = nil
        Ck = nil
        Cn = nil
        Co = nil
        local Label2, Label3, Ch, Ci, Label, Cl, Cm, Cp, Cq
        Co = function(kv)
            return (tostring(kv):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
        end
        Cn = function(kx, ky)
            return string.format('<font color="%s">%s</font>', ky, Co(kx))
        end
        Cq = function(kB, kC, kD)
            return string.format("<b>%s</b> %s %s", kB, Cn("-", "#5a6070"), Cn(kC, kD))
        end
        local Cr = "#8b93a3"
        Cp = "#7fd47f"
        Ci = "#e8a34d"
        local Cs = "#6ec1ff"
        local Ct = tT.Support()
        local Cu = #Ct == 0 and "ready"
        local Cv = Cu or "limited: " .. table.concat(Ct, ", ")
        Cm = "Unknown"
        pcall(function()
            local BY_1
            local BX_1
            if tQ(identifyexecutor) then
                BY_1, BX_1 = identifyexecutor()
                local BZ = BY_1 ~= ""
                local B_ = type(BY_1) == "string" and BZ
                if B_ then
                    local BZ_1 = type(BX_1) == "string" and BX_1 ~= "" and BY_1 .. " " .. BX_1
                    local BX_2 = BZ_1
                    local B3 = if BX_2 then 1 else 0
                    local B1 = 1025 * B3 + 262 * (1 - B3)
                    local B2 = 901 * B3 + 3689 * (1 - B3)
                    if not ((B1 * 506 + B2 * 1685 + B1 * B2) % 16777213 == 2960360) then
                        BX_2 = BY_1
                    end
                    Cm = BX_2
                end
            end
        end)
        Cg = os.clock()
        Cl = function()
            local B7 = math.floor(os.clock() - Cg)
            if B7 < 60 then
                return B7 .. "s"
            elseif B7 < 3600 then
                return string.format("%dm %ds", math.floor((B7) / (60)), B7 % 60)
            else
                return string.format("%dh %dm", math.floor((B7) / (3600)), math.floor((B7 % 3600) / (60)))
            end
        end
        local UserGroup = jB[1]:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(Cq("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, Cp), true)
        UserGroup:AddLabel(Cq("UserId", tostring(LocalPlayer.UserId), Cs), true)
        UserGroup:AddLabel(Cq("Executor", Cm .. "  " .. Cv, Cp), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(Cq("Session", Cl(), Ci), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                jm(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                jm("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = jB[1]:AddRightGroupbox("Session", "signal")
        SessionGroup:AddLabel(Cq("Game", i9, Cs), true)
        Label2 = SessionGroup:AddLabel(Cq("Players", "0/0", Cp), true)
        Ch = tostring(game.JobId)
        local Cs_1 = #Ch > 18 and string.sub(Ch, 1, 18) .. "..."
        local Cu_2 = Cs_1
        local Cz = if Cu_2 then 1 else 0
        local Cx = 2264 * Cz + 3495 * (1 - Cz)
        local Cy = 1788 * Cz + 1884 * (1 - Cz)
        if not ((Cx * 462 + Cy * 678 + Cx * Cy) % 16777213 == 6306264) then
            Cu_2 = Ch
        end
        local Cs_2 = Cu_2
        SessionGroup:AddLabel(Cq("Job", Cs_2, Cr), true)
        Label = SessionGroup:AddLabel(Cq("Ping", "0 ms", Ci), true)
        SessionGroup:AddDivider()
        SessionGroup:AddButton({
            Text = "Rejoin Place",
            Func = function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        })
        SessionGroup:AddButton({
            Text = "Copy Job ID",
            Func = function()
                jm(Ch, "Copied Job ID")
            end
        })
        Ck = task.spawn(function()
            local Ca_1
            local B9_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(Cq("Session", Cl(), Ci))
                Label2:SetText(Cq("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), Cp))
                B9_1, Ca_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local B9_2 = B9_1 and Ca_1 .. " ms" or "n/a"
                Label:SetText(Cq("Ping", B9_2, Ci))
            end
        end)
        tT.Track(function()
            if coroutine.status(Ck) ~= "dead" then
                pcall(task.cancel, Ck)
            end
        end)
        local SocialsGroup = jB[1]:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                jm(jc, "Copied Rscripts profile")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                jm(jd, "Copied website link")
            end
        })
    end
    ks()
    local function lJ()
        local l1
        local l_
        local lZ
        local l0
        local MovementGroup = jB[3]:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = jB[3]:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        local TeleportsGroup = jB[3]:AddRightGroupbox("Teleports", "map-pin")
        TeleportsGroup:AddButton({
            Text = "Teleport to Lobby",
            Func = function()
                if not tT.TeleportLobby() then
                    Library:Notify("Lobby teleport is unavailable")
                end
            end
        })
        TeleportsGroup:AddButton({
            Text = "Teleport to Mine",
            Func = function()
                task.spawn(function()
                    if not tT.TeleportMine() then
                        Library:Notify("Mine teleport is unavailable")
                    end
                end)
            end
        })
        TeleportsGroup:AddButton({
            Text = "Teleport to Training Area",
            Func = function()
                if not tT.TeleportTraining() then
                    Library:Notify("Training teleport is unavailable")
                end
            end
        })
        l1 = {}
        lZ = {}
        l_ = {}
        l0 = {}
        local lY = {}
        local function l2()
            for k, v in lZ do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(lZ)
        end
        local function l6()
            for k, v in l_ do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(l_)
        end
        local function ma()
            for k, v in l0 do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(l0)
        end
        local function me(mf)
            if not mf:IsA("ProximityPrompt") then
                return
            end
            if l1[mf] == nil then
                l1[mf] = {
                    HoldDuration = mf.HoldDuration,
                    MaxActivationDistance = mf.MaxActivationDistance,
                    RequiresLineOfSight = mf.RequiresLineOfSight
                }
            end
            mf.HoldDuration = 0
            mf.MaxActivationDistance = 50
            mf.RequiresLineOfSight = false
        end
        local function mh()
            for k, v in l1 do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(l1)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                ma()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                l6()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                l2()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for i, descendant in ipairs(Workspace:GetDescendants()) do
                    pcall(me, descendant)
                end
            else
                mh()
            end
        end)
        table.insert(lY, Workspace.DescendantAdded:Connect(function(mA)
            if Toggles.InstantProximityPrompt.Value then
                pcall(me, mA)
            end
        end))
        table.insert(lY, uj.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        if lZ[descendant] == nil then
                            lZ[descendant] = descendant.CanCollide
                        end
                        descendant.CanCollide = false
                    end
                end
            end
        end))
        table.insert(lY, UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local DC = Character and Character:FindFirstChildOfClass("Humanoid")
            if Toggles.InfJump.Value and DC then
                DC:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(lY, uj.RenderStepped:Connect(function(mV)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local DF = Character and Character:FindFirstChildOfClass("Humanoid")
            local DG = Character
            if DG then
                DG = Character:FindFirstChild("HumanoidRootPart")
            end
            local DE_1 = DG
            local CurrentCamera = Workspace.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and DF then
                if l_[DF] == nil then
                    l_[DF] = DF.WalkSpeed
                end
                DF.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and DE_1 and DF and CurrentCamera then
                if l0[DF] == nil then
                    l0[DF] = DF.PlatformStand
                end
                DF.PlatformStand = true
                local DG_4 = Vector3.zero
                if not UserInputService:GetFocusedTextBox() then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        DG_4 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        DG_4 -= CurrentCamera.CFrame.LookVector
                    end
                    local DM = if UserInputService:IsKeyDown(Enum.KeyCode.A) then 1 else 0
                    if DM == 1 then
                        DG_4 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        DG_4 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        DG_4 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        DG_4 -= Vector3.new(0, 1, 0)
                    end
                end
                DE_1.AssemblyLinearVelocity = Vector3.zero
                if DG_4.Magnitude > 0 then
                    DE_1.CFrame = DE_1.CFrame + DG_4.Unit * Options.FlySpeed.Value * mV
                end
            end
        end))
        tT.Track(function()
            for k, v in lY do
                v:Disconnect()
            end
            l2()
            l6()
            ma()
            mh()
        end)
    end
    lJ()
    local function na()
        local ET, EU, EV, EW, EX, EY, EZ, E_, E0, E1, E2, Label, E4, E5
        E5 = {}
        EZ = {}
        EW = nil
        EX = 0
        E0 = false
        ET = 0
        E1 = os.clock()
        local MenuGroup = jB[4]:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        Label = MenuGroup:AddLabel("AFK triggers: 0")
        EU = function()
            local CurrentCamera
            CurrentCamera = Workspace.CurrentCamera
            local DV = not CurrentCamera or not tQ(VirtualUser.CaptureController) or not tQ(VirtualUser.ClickButton2)
            if DV then
                return false
            end
            local DV_1 = pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            end)
            if not DV_1 then
                return false
            end
            EX += 1
            E1 = os.clock()
            pcall(function()
                Label:SetText("AFK triggers: " .. EX)
            end)
            return true
        end
        E2 = function(nE)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not nE)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not nE
                end
            end)
            if not nE then
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
        E_ = function(nU)
            local ClassName = nU.ClassName
            if ClassName == "ParticleEmitter" or ClassName == "Trail" or ClassName == "Smoke" or ClassName == "Fire" or ClassName == "Sparkles" or ClassName == "Beam" then
                if E5[nU] == nil then
                    E5[nU] = nU.Enabled
                end
                pcall(function()
                    nU.Enabled = false
                end)
            end
        end
        EY = function()
            for k, v in E5 do
                local Ef = k
                local Eh = v
                if Ef.Parent then
                    pcall(function()
                        Ef.Enabled = Eh
                    end)
                end
            end
            table.clear(E5)
            if EW then
                pcall(function()
                    settings().Rendering.QualityLevel = EW.Quality
                end)
                Lighting.GlobalShadows = EW.Shadows
                Lighting.FogEnd = EW.Fog
                EW = nil
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(n8)
                pcall(function()
                    uj:Set3dRenderingEnabled(not n8)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(od)
                if od then
                    if not EW then
                        EW = {
                            Quality = settings().Rendering.QualityLevel,
                            Shadows = Lighting.GlobalShadows,
                            Fog = Lighting.FogEnd
                        }
                    end
                    pcall(function()
                        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                    end)
                    Lighting.GlobalShadows = false
                    Lighting.FogEnd = 9000000000
                    for i, descendant in ipairs(Workspace:GetDescendants()) do
                        pcall(E_, descendant)
                    end
                else
                    EY()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        local ScriptGroup = jB[4]:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        Toggles.AntiGameplayPause:OnChanged(function()
            E2(Toggles.AntiGameplayPause.Value)
        end)
        if Toggles.AntiGameplayPause.Value then
            E2(true)
        end
        table.insert(EZ, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value and not Library.Unloaded then
                EU()
            end
        end))
        table.insert(EZ, Workspace.DescendantAdded:Connect(function(oz)
            if Toggles.FpsBoost.Value then
                pcall(E_, oz)
            end
        end))
        EV = function(oD)
            if E0 or Library.Unloaded or not Toggles.AutoReconnect.Value then
                return
            end
            E0 = true
            local Ex = ET
            local Ey_1 = pcall(function()
                if oD then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not Ey_1 then
                E0 = false
                if not oD and Ex == ET then
                    task.delay(1.5, function()
                        if Ex == ET then
                            EV(true)
                        end
                    end)
                end
            end
        end
        table.insert(EZ, TeleportService.TeleportInitFailed:Connect(function(oV)
            local EC
            if oV == LocalPlayer and E0 then
                E0 = false
                EC = ET
                task.delay(3, function()
                    if EC == ET then
                        EV(true)
                    end
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local EH = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            if Library.Unloaded or not EH then
                return
            end
            table.insert(EZ, EH.ChildAdded:Connect(function(o9)
                if o9.Name == "ErrorPrompt" then
                    EV(false)
                end
            end))
        end)
        E4 = task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    E2(true)
                end
                local EK = Toggles.AntiAfk.Value and os.clock() - E1 >= 60
                if EK then
                    EU()
                end
                task.wait(1)
            end
        end)
        tT.Track(function()
            ET += 1
            for k, v in EZ do
                v:Disconnect()
            end
            pcall(task.cancel, E4)
            E2(false)
            EY()
            pcall(function()
                uj:Set3dRenderingEnabled(true)
            end)
        end)
    end
    na()
    local function pt()
        local FY, FZ, F_, F0
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("MyScriptHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(jB[4])
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/TntMining")
        local F1 = SaveManager:BuildConfigSection(jB[4])
        F_ = function(pA, pB)
            local E9_1 = (pA == "Toggle" and Toggles or Options)[pB]
            local E8_2 = type(E9_1) == "table" and E9_1.Type == pA
            return E8_2 and E9_1 or nil
        end
        FY = function(pK, pL)
            local Type = pL.Type
            if Type == "Toggle" then
                return { idx = pK, type = "Toggle", value = pL.Value == true }
            elseif Type == "Slider" then
                return { idx = pK, type = "Slider", value = tostring(pL.Value) }
            elseif Type == "Dropdown" then
                return { idx = pK, type = "Dropdown", multi = pL.Multi == true, value = pL.Value }
            elseif Type == "Input" then
                local Fg = pL.Value or ""
                return { idx = pK, type = "Input", text = tostring(Fg) }
            elseif Type == "ColorPicker" then
                return { idx = pK, type = "ColorPicker", value = pL.Value:ToHex(), transparency = pL.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = pK,
                    type = "KeyPicker",
                    mode = pL.Mode,
                    key = pL.Value,
                    modifiers = pL.Modifiers,
                    toggled = pL.Toggled
                }
            else
                return nil
            end
        end
        F0 = function()
            local Fm = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local Fn = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if Fn then
                        local Fn_1 = FY(k, v)
                        if Fn_1 then
                            Fm[#Fm + 1] = Fn_1
                        end
                    end
                end
            end
            table.sort(Fm, function(pV, pW)
                if pV.type ~= pW.type then
                    return pV.type < pW.type
                end
                return pV.idx < pW.idx
            end)
            return { objects = Fm }
        end
        FZ = function(pY)
            local FG
            FG = nil
            local FH = type(pY) ~= "table" or type(pY.idx) ~= "string" or type(pY.type) ~= "string" or SaveManager.Ignore[pY.idx]
            if FH then
                return false
            end
            FG = F_(pY.type, pY.idx)
            if not FG then
                return false
            end
            local FH_1 = pcall(function()
                if pY.type == "Input" then
                    if type(pY.text) ~= "string" then
                        return
                    end
                    FG:SetValue(pY.text)
                elseif pY.type == "ColorPicker" then
                    FG:SetValueRGB(Color3.fromHex(pY.value), pY.transparency)
                elseif pY.type == "KeyPicker" then
                    FG:SetValue({ pY.key, pY.mode, pY.modifiers })
                    if pY.mode == "Toggle" and pY.toggled ~= nil then
                        FG.Toggled = pY.toggled
                        FG:Update()
                    end
                else
                    FG:SetValue(pY.value)
                end
            end)
            return FH_1
        end
        F1:AddDivider()
        F1:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", AllowEmpty = true })
        F1:AddButton("Export Config to Clipboard", function()
            local FK_1
            local FJ_1
            FJ_1, FK_1 = pcall(HttpService.JSONEncode, HttpService, F0())
            if FJ_1 then
                local FJ_2 = tQ(setclipboard) and setclipboard
                local FL = FJ_2
                if not FL then
                    local FJ_3 = tQ(toclipboard) and toclipboard
                    FL = FJ_3 or nil
                end
                local FJ_4 = FL
                local FL_1 = type(FJ_4) == "function" and pcall(FJ_4, FK_1)
                if FL_1 then
                    Library:Notify("Config copied to clipboard", 6)
                    return
                end
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Failed to encode the config")
        end)
        F1:AddButton("Import Config from Clipboard Text", function()
            local FQ_1
            local FO = Options.SaveManager_ImportSource.Value or ""
            local FO_1
            local FP = tostring(FO):match("^%s*(.-)%s*$")
            if FP == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            if #FP > 262144 then
                Library:Notify("That config is too large")
                return
            end
            FO_1, FQ_1 = pcall(HttpService.JSONDecode, HttpService, FP)
            local FP_1 = not FO_1 or type(FQ_1) ~= "table" or type(FQ_1.objects) ~= "table"
            if FP_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            if #FQ_1.objects > 2048 then
                Library:Notify("That config has too many records")
                return
            end
            local FO_2 = 0
            for i, v in ipairs(FQ_1.objects) do
                if FZ(v) then
                    FO_2 += 1
                end
            end
            if FO_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local FQ_2 = FO_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(FO_2, FQ_2), 6)
        end)
        ThemeManager:LoadDefault()
        SaveManager:LoadAutoloadConfig()
        if Options.TargetArea then
            tT.SetTargetArea(Options.TargetArea.Value)
        end
        if Options.StuckSeconds then
            tT.SetStuckSeconds(Options.StuckSeconds.Value)
        end
        if Options.UpgradeFilter then
            tT.SetUpgradeFilter(Options.UpgradeFilter.Value)
        end
        if Options.TrainingFilter then
            tT.SetTrainingFilter(Options.TrainingFilter.Value)
        end
        if Options.EggArea then
            tT.SetEggArea(Options.EggArea.Value)
        end
        if Options.SellFilter then
            tT.SetSellFilter(Options.SellFilter.Value)
        end
        if Options.SellInterval then
            tT.SetSellInterval(Options.SellInterval.Value)
        end
        if Options.SellMinBlocks then
            tT.SetSellMinBlocks(Options.SellMinBlocks.Value)
        end
        if Options.ClickRate then
            tT.SetClickRate(Options.ClickRate.Value)
        end
        if Toggles.ClampToPit then
            tT.SetClampToPit(Toggles.ClampToPit.Value)
        end
        if Toggles.AutoUnstuck then
            tT.SetAutoUnstuck(Toggles.AutoUnstuck.Value)
        end
        if Toggles.AutoReturn then
            tT.SetAutoReturn(Toggles.AutoReturn.Value)
        end
        if Toggles.AutoCollect then
            tT.SetAutoCollect(Toggles.AutoCollect.Value)
        end
        if Toggles.AutoUnlockArea then
            tT.SetAutoUnlockArea(Toggles.AutoUnlockArea.Value)
        end
        if Toggles.AutoBuyBomb then
            tT.SetAutoBuyBomb(Toggles.AutoBuyBomb.Value)
        end
        if Toggles.AutoEquipBomb then
            tT.SetAutoEquipBomb(Toggles.AutoEquipBomb.Value)
        end
        if Toggles.AutoUpgrades then
            tT.SetAutoUpgrades(Toggles.AutoUpgrades.Value)
        end
        if Toggles.AutoMineLuck then
            tT.SetAutoMineLuck(Toggles.AutoMineLuck.Value)
        end
        if Toggles.AutoDaily then
            tT.SetAutoDaily(Toggles.AutoDaily.Value)
        end
        if Toggles.AutoGroup then
            tT.SetAutoGroup(Toggles.AutoGroup.Value)
        end
        if Toggles.AutoIndex then
            tT.SetAutoIndex(Toggles.AutoIndex.Value)
        end
        if Toggles.AutoSell then
            tT.SetAutoSell(Toggles.AutoSell.Value)
        end
        if Toggles.AutoClick then
            tT.SetAutoClick(Toggles.AutoClick.Value)
        end
        if Toggles.AutoEquipPets then
            tT.SetAutoEquipPets(Toggles.AutoEquipPets.Value)
        end
        if Toggles.AutoHatchEgg then
            tT.SetAutoHatchEgg(Toggles.AutoHatchEgg.Value)
        end
        if Toggles.AutoTraining then
            tT.SetAutoTraining(Toggles.AutoTraining.Value)
        end
        if Toggles.AutoRebirth then
            tT.SetAutoRebirth(Toggles.AutoRebirth.Value)
        end
        if Toggles.AutoDetonate then
            tT.SetAutoDetonate(Toggles.AutoDetonate.Value)
        end
        if Toggles.AutoMine then
            tT.SetAutoMine(Toggles.AutoMine.Value)
        end
        if Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    pt()
end
uB()
end)(...)

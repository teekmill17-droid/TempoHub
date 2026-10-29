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
getgenv().TempoHoodSubtitle = "+1 CLONE EVOLUTION"
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
local r2
local ro
local rK
local rr
local rN
local q8
local rQ
local rx
local rb
local re
local rW
local rA
local rh
local rD
local rk
local r1
local rn
local rJ
local CoreGui
local rM
local q7
local rP
local rw
local rS
local ra
local rz
local rV
local rg
local rY
local rC
local rj
local r0
local rF
local rI
local q6
local rs
local rO
local LocalPlayer
local rv
local rR
local rc
local ry
local rU
local rX
local r_
local rl
local rH
local function fn86(eB)
    for i, descendant in ipairs(eB:GetDescendants()) do
        local vY = descendant:IsA("BasePart") and descendant.Name == "Tube"
        if vY then
            return descendant
        end
    end
    return nil
end
local function fn88()
    if not rl(firetouchinterest) then
        rQ.CloneStatus = "Your executor cannot fire touch pads"
        return
    end
    if not rb() then
        rQ.CloneStatus = "Waiting for your character"
        return
    end
    local Map = rW:FindFirstChild("Map")
    local v6 = Map and Map:FindFirstChild("CloneSpots")
    if not v6 then
        rQ.CloneStatus = "Clone spots are not loaded"
        return
    end
    local v6_1 = {}
    local gmatch = string.gmatch
    local v8 = rK("OwnedCloneTypes") or ""
    for k in gmatch(tostring(v8), "[^,]+") do
        v6_1[k] = true
    end
    local v7_1 = rh()
    local v8_1 = {}
    for i, child in ipairs(v6:GetChildren()) do
        local attr = child:GetAttribute("CloneType")
        local v9 = tonumber(child:GetAttribute("WinCost"))
        local wa = type(attr) == "string" and v9 and not v6_1[attr] and v9 <= v7_1
        if wa then
            local wa_1 = rO(child)
            if wa_1 then
                table.insert(v8_1, { name = attr, cost = v9, tube = wa_1 })
            end
        end
    end
    if #v8_1 == 0 then
        rQ.CloneStatus = "No affordable clone left to buy"
        return
    end
    table.sort(v8_1, function(e_, e0)
        return e_.cost < e0.cost
    end)
    local name = nil
    for i, v in ipairs(v8_1) do
        local v6_2 = not rc() or rR.stopped
        if v6_2 then
            return
        end
        if rM(v.tube) then
            task.wait(0.3)
            name = v.name
        end
    end
    if name then
        rQ.CloneStatus = "Bought " .. name
        return
    end
    rQ.CloneStatus = "Clone purchase was rejected"
end
local function fn118(bQ)
    if not rl(firetouchinterest) then
        return false
    end
    local t6 = rb()
    if not t6 or not bQ or not bQ.Parent then
        return false
    end
    local t7_1 = pcall(firetouchinterest, t6, bQ, 0)
    if not t7_1 then
        return false
    end
    task.wait(0.06)
    pcall(firetouchinterest, t6, bQ, 1)
    return true
end
local function fn129(gv)
    if gv then
        rQ.PetStatus = "Starting"
        rz(rD, q6)
    else
        rw(rD)
        rQ.PetStatus = "Idle"
    end
end
local function fn140(gn)
    if gn then
        rQ.HatchStatus = "Starting"
        rz(rH, r2)
    else
        rw(rH)
        rQ.HatchStatus = "Idle"
    end
end
local function fn184(aG)
    local Packages = r_:FindFirstChild("Packages")
    local s2 = Packages and Packages:FindFirstChild("Knit")
    local s1_1 = s2
    if s2 then
        s2 = s1_1:FindFirstChild("Services")
    end
    local s1_2 = s2
    if s2 then
        s2 = s1_2:FindFirstChild(aG)
    end
    local s1_3 = s2
    if s2 then
        s2 = s1_3:FindFirstChild("RF")
    end
    local s1_4 = s2
    if s1_4 then
        return rs(s1_4)
    end
    return nil
end
local function fn191(gh)
    if gh then
        rQ.CloneStatus = "Starting"
        rz(rR, ro)
    else
        rw(rR)
        rQ.CloneStatus = "Idle"
    end
end
local function fn284()
    rw(rj)
    rw(re)
    rw(ra)
    rw(r1)
    rw(rY)
    rw(rR)
    rw(rH)
    rw(rD)
end
local function fn291()
    return not rA.Unloaded
end
local function fn302(dR)
    local multiplier
    local index
    index, multiplier = nil, nil
    for i, v in ipairs(rP()) do
        if dR[v.index] == true and (not multiplier or v.multiplier > multiplier) then
            index, multiplier = v.index, v.multiplier
        end
    end
    return index, multiplier
end
local function fn420(dM)
    for i, v in ipairs(rP()) do
        if v.index == dM then
            return v.multiplier
        end
    end
    return nil
end
local function fn423(gc)
    local w_ = gc == rC
    local w0 = type(gc) ~= "string" or w_
    if w0 then
        rY.pad = nil
        return
    end
    local w__1 = tonumber(string.match(gc, "%d+"))
    local w0_1 = w__1 and math.floor(w__1)
    local w__2 = w0_1 or nil
    rY.pad = w__2
end
local function worker()
    local tx_1
    local tw_1
    tw_1, tx_1 = pcall(rV)
    if not tw_1 then
        q8.ready = true
        warn("[Tempo] game load failed: " .. tostring(tx_1))
    end
end
local function fn477()
    if not rl(firetouchinterest) then
        rQ.PlateStatus = "Your executor cannot fire touch pads"
        return
    end
    if not rb() then
        rQ.PlateStatus = "Waiting for your character"
        return
    end
    local clamp = math.clamp
    local uD_1
    local floor = math.floor
    local uF = tonumber(re.stage) or 1
    local uF_1
    local uE_1 = clamp(floor(uF), 1, rF)
    uD_1, uF_1 = rv(q8.cloneRF, "GetUnlockedZoneIndex")
    local uG = uD_1 and type(uF_1) == "number" and uE_1 >= uF_1
    if uG then
        rQ.PlateStatus = "Beat stage " .. tostring(uE_1) .. " first"
        return
    end
    local uD_2 = q7(uE_1)
    if not uD_2 then
        rQ.PlateStatus = "Stage " .. tostring(uE_1) .. " has no win plates loaded"
        return
    end
    local uF_2 = re.lastWins or rh()
    for i, v in ipairs(uD_2) do
        local uD_3 = not rc() or re.stopped
        if uD_3 then
            return
        end
        rM(v)
    end
    task.wait(0.75)
    local uD_4 = rh()
    re.lastWins = uD_4
    local uF_3 = uD_4 - uF_2
    if uF_3 > 0 then
        rQ.PlateStatus = string.format("Stage %d paid %s wins", uE_1, rr(uF_3))
        return
    end
    rQ.PlateStatus = "Stage " .. tostring(uE_1) .. " plates are already claimed"
end
local function fn501()
    return CoreGui
end
local function fn536()
    local tf_1
    local tg_1
    tf_1, tg_1 = rv(q8.petRF, "GetEggs")
    local th = not tf_1 or type(tg_1) ~= "table"
    if th then
        return nil
    end
    local tf_2 = {}
    for k, v in pairs(tg_1) do
        local tg_2 = type(v) == "table" and v.Robux ~= true and v.Currency == "Wins"
        if tg_2 then
            local tg_3 = tonumber(v.Cost) or 0
            local th_1 = type(v.DisplayName) == "string" and v.DisplayName
            local ti = th_1 or k
            tf_2[k] = { Cost = tg_3, DisplayName = ti }
        end
    end
    if next(tf_2) == nil then
        return nil
    end
    return tf_2
end
local function fn541(fV)
    if fV then
        rQ.ClickStatus = "Starting"
        rz(ra, rU)
    else
        rw(ra)
        rQ.ClickStatus = "Idle"
    end
end
local function fn542()
    local u5 = q8.padConfig and q8.padConfig.Pads
    local u6 = {}
    if type(u5) ~= "table" then
        return u6
    end
    for k, v in pairs(u5) do
        local u5_1 = tonumber(k)
        local u7_1 = u5_1 and type(v) == "table"
        if u7_1 then
            local insert = table.insert
            local u8 = tonumber(v.Multiplier) or 1
            insert(u6, { index = u5_1, multiplier = u8, rebirths = tonumber(v.Rebirths), robux = v.GamePass == true })
        end
    end
    table.sort(u6, function(dJ, dK)
        return dJ.index < dK.index
    end)
    return u6
end
local function fn543()
    local Character = LocalPlayer.Character
    local sO = Character and Character:FindFirstChild("HumanoidRootPart")
    local sN_1 = sO
    local sS = if sN_1 then 1 else 0
    local sQ = 1906 * sS + 2947 * (1 - sS)
    local sR = 2672 * sS + 1396 * (1 - sS)
    if not ((sQ * 579 + sR * 834 + sQ * sR) % 16777213 == 8424854) then
        sN_1 = nil
    end
    return sN_1
end
local function fn548(ai)
    local sJ = tonumber(ai) or 0
    ai = sJ
    local sJ_1 = 1
    local sK = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }
    while ai >= 1000 and sJ_1 < 12 do
        ai = ai / 1000
        sJ_1 += 1
    end
    if sJ_1 == 1 then
        return string.format("%d", ai)
    end
    return string.format("%.2f%s", ai, sK[sJ_1])
end
local function fn559()
    local tG = {}
    local tH = {}
    for i, v in ipairs(rx) do
        if q8.eggs == nil or q8.eggs[v] then
            table.insert(tH, v)
            tG[v] = true
        end
    end
    if q8.eggs then
        local tI_2 = {}
        for k in pairs(q8.eggs) do
            if not tG[k] then
                table.insert(tI_2, k)
            end
        end
        table.sort(tI_2, function(bE, bF)
            return (q8.eggs[bE].Cost or 0) < (q8.eggs[bF].Cost or 0)
        end)
        for i, v in ipairs(tI_2) do
            table.insert(tH, v)
        end
    end
    return tH
end
local function fn570(f6)
    if f6 then
        rQ.TrainStatus = "Starting"
        rz(rY, rN)
    else
        rw(rY)
        rQ.TrainStatus = "Idle"
    end
end
local function fn572(aB)
    local sZ_1
    local sY_1
    if not aB then
        return nil
    end
    sY_1, sZ_1 = pcall(require, aB)
    local s_ = sY_1 and type(sZ_1) == "table"
    if s_ then
        return sZ_1
    end
    return nil
end
local function fn626(bK)
    local t0 = q8.eggs and q8.eggs[bK]
    local t1 = t0
    if t0 then
        t0 = tonumber(t1.Cost)
    end
    return t0 or nil
end
local function fn658(V)
    local sH = typeof(cloneref) == "function" and typeof(V) == "Instance"
    if sH then
        return cloneref(V)
    end
    return V
end
local function fn671(fL)
    if fL then
        re.lastWins = nil
        rQ.PlateStatus = "Starting"
        rz(re, rS)
    else
        rw(re)
        rQ.PlateStatus = "Idle"
    end
end
local function fn699(cA)
    local Stages = rW:FindFirstChild("Stages")
    local uu = Stages and Stages:FindFirstChild("Stage" .. tostring(cA))
    local ut_1 = uu
    if uu then
        uu = ut_1:FindFirstChild("Buttons")
    end
    local ut_2 = uu
    if not ut_2 then
        return nil
    end
    local uu_1 = {}
    for i, child in ipairs(ut_2:GetChildren()) do
        local TouchPart = child:FindFirstChild("TouchPart")
        local uv = TouchPart and TouchPart:IsA("BasePart") and TouchPart:GetAttribute("WinAmount") ~= nil and not string.match(child.Name, "^%d+x")
        if uv then
            table.insert(uu_1, TouchPart)
        end
    end
    if #uu_1 == 0 then
        return nil
    end
    table.sort(uu_1, function(cM, cN)
        local uq = tonumber(cM:GetAttribute("WinAmount")) or 0
        local ur = tonumber(cN:GetAttribute("WinAmount")) or 0
        return uq < ur
    end)
    return uu_1
end
local function fn748(fF)
    if fF then
        rj.target = nil
        rQ.StageStatus = "Starting"
        rz(rj, rn)
    else
        rw(rj)
        rQ.StageStatus = "Idle"
    end
end
local function fn767()
    local uk_1, uk_2
    local uj_1, uj_2
    local cloneRF = q8.cloneRF
    if not cloneRF then
        rQ.StageStatus = "Stage service unavailable"
        return
    end
    local ui = rj.target
    if type(ui) ~= "number" then
        uj_1, uk_1 = rv(cloneRF, "GetUnlockedZoneIndex")
        local ul_1 = not uj_1
        local up_1 = if ul_1 then 1 else 0
        local un_1 = 283 * up_1 + 1245 * (1 - up_1)
        local uo_1 = 3068 * up_1 + 2274 * (1 - up_1)
        if not ((un_1 * 3087 + uo_1 * 3167 + un_1 * uo_1) % 16777213 == 11458221) then
            ul_1 = type(uk_1) ~= "number"
        end
        if ul_1 then
            rQ.StageStatus = "Could not read stage progress"
            return
        end
        ui = math.floor(uk_1)
    end
    if ui > rF then
        rj.target = nil
        rQ.StageStatus = "Every stage is cleared"
        task.wait(3)
        return
    end
    local ui_1 = math.max(1, ui)
    uj_2, uk_2 = rv(cloneRF, "CompleteStage", ui_1)
    local uh_1 = not uj_2 or type(uk_2) ~= "table"
    if uh_1 then
        rj.target = nil
        rQ.StageStatus = "Stage " .. tostring(ui_1) .. " did not answer"
        return
    end
    local uh_2 = tonumber(uk_2.UnlockedZoneIndex)
    if uk_2.Success then
        if uk_2.AlreadyCompleted then
            local max = math.max
            local ul_2 = uh_2 or ui_1
            rj.target = max(ul_2, ui_1) + 1
            rQ.StageStatus = "Stage " .. tostring(ui_1) .. " was already cleared"
            return
        end
        local uj_4 = uh_2 or ui_1 + 1
        rj.target = uj_4
        local format = string.format
        local ul_3 = uk_2.Reward
        local up_2 = if ul_3 then 1 else 0
        local un_2 = 2628 * up_2 + 1598 * (1 - up_2)
        local uo_2 = 3713 * up_2 + 3138 * (1 - up_2)
        if not ((un_2 * 2175 + uo_2 * 3233 + un_2 * uo_2) % 16777213 == 10700580) then
            ul_3 = 0
        end
        rQ.StageStatus = format("Cleared stage %d for %s wins", ui_1, rr(ul_3))
        return
    end
    rj.target = uh_2
    rQ.StageStatus = "Stage " .. tostring(ui_1) .. " is still locked"
end
local function fn794(Y)
    return type(Y) == "function"
end
local function fn802()
    local wE_1
    local wD_1
    local petRF = q8.petRF
    if not petRF then
        rQ.PetStatus = "Pet service unavailable"
        return
    end
    wD_1, wE_1 = rv(petRF, "EquipBestPets")
    local wC_1 = not wD_1 or type(wE_1) ~= "table" or not wE_1.Success
    if wC_1 then
        rQ.PetStatus = "Equip was rejected"
        return
    end
    local wC_2 = type(wE_1.EquippedPetIds) == "table" and #wE_1.EquippedPetIds
    local wD_2 = wC_2
    local wJ = if wD_2 then 1 else 0
    local wH = 1604 * wJ + 1484 * (1 - wJ)
    local wI = 3455 * wJ + 3707 * (1 - wJ)
    if not ((wH * 1230 + wI * 2431 + wH * wI) % 16777213 == 15913845) then
        wD_2 = 0
    end
    local wC_3 = wD_2
    local format = string.format
    local wF = wC_3 == 1 and "" or "s"
    rQ.PetStatus = format("Equipped %d pet%s", wC_3, wF)
end
local function fn831(f0)
    if f0 then
        rQ.RebirthStatus = "Starting"
        rz(r1, rg)
    else
        rw(r1)
        rQ.RebirthStatus = "Idle"
    end
end
local function fn839()
    q8.cloneRF = ry("CloneClickService")
    q8.rebirthRF = ry("RebirthService")
    q8.petRF = ry("PetService")
    q8.eggs = rI()
    local Shared = r_:FindFirstChild("Shared")
    local tr = Shared and Shared:FindFirstChild("TargetPracticeConfig")
    q8.padConfig = r0(tr)
    local tq_1 = {}
    if not q8.cloneRF then
        table.insert(tq_1, "stages")
    end
    if not q8.rebirthRF then
        table.insert(tq_1, "rebirth")
    end
    if not q8.petRF then
        table.insert(tq_1, "pets")
    end
    if not q8.padConfig then
        table.insert(tq_1, "punching bags")
    end
    if not rl(firetouchinterest) then
        table.insert(tq_1, "touch pads")
    end
    q8.missing = tq_1
    q8.ready = true
end
local function fn878(ch)
    ch.stopped = true
    local uf = ch.generation or 0
    ch.generation = uf + 1
end
local function fn885(gt)
    local w7 = gt ~= ""
    local w8 = type(gt) == "string" and w7
    if w8 then
        rH.egg = gt
    end
end
local function fn955()
    gethui = rX
end
local function fn993()
    local uX_1, uX_3
    local uW_1, uW_5
    local rebirthRF = q8.rebirthRF
    if not rebirthRF then
        rQ.RebirthStatus = "Rebirth service unavailable"
        return
    end
    uW_1, uX_1 = rv(rebirthRF, "GetRebirthInfo")
    local uY = not uW_1
    local u1 = if uY then 1 else 0
    local u_ = 386 * u1 + 111 * (1 - u1)
    local u0 = 519 * u1 + 3563 * (1 - u1)
    if not ((u_ * 3117 + u0 * 1269 + u_ * u0) % 16777213 == 2062107) then
        uY = type(uX_1) ~= "table"
    end
    if uY then
        rQ.RebirthStatus = "Could not read rebirth progress"
        return
    end
    if uX_1.AtCap then
        rQ.RebirthStatus = "Rebirths are capped"
        return
    end
    if not uX_1.CanRebirth then
        local uW_2 = tonumber(uX_1.CurrentLevel) or 0
        local uW_3 = tonumber(uX_1.LevelRequired) or 0
        rQ.RebirthStatus = string.format("Level %d of %d", uW_2, uW_3)
        return
    end
    local uW_4 = rv(rebirthRF, "Rebirth")
    if not uW_4 then
        rQ.RebirthStatus = "Rebirth was rejected"
        return
    end
    rj.target = nil
    uW_5, uX_3 = rv(rebirthRF, "GetRebirthInfo")
    local uV_1 = uW_5 and type(uX_3) == "table" and tonumber(uX_3.RebirthCount)
    local uW_6 = uV_1 or nil
    local uV_2 = uW_6
    if uW_6 then
        uW_6 = "Rebirth " .. tostring(uV_2)
    end
    local uV_3 = uW_6 or "Rebirthed"
    rQ.RebirthStatus = uV_3
end
local function fn1025()
    local sW = tonumber(rK("PadWins")) or 0
    return sW
end
local function fn1129()
    local petRF = q8.petRF
    if not petRF then
        rQ.HatchStatus = "Pet service unavailable"
        return
    end
    local egg = rH.egg
    local wv = egg == ""
    local wv_2
    local ww = type(egg) ~= "string" or wv
    local ww_2
    if ww then
        rQ.HatchStatus = "Pick an egg first"
        return
    end
    local wv_1 = rk(egg)
    local ww_1 = rh()
    if wv_1 and ww_1 < wv_1 then
        rQ.HatchStatus = string.format("%s needs %s wins", egg, rr(wv_1))
        return
    end
    wv_2, ww_2 = rv(petRF, "OpenEgg", egg, 1)
    local wt_1 = not wv_2 or type(ww_2) ~= "table"
    if wt_1 then
        rQ.HatchStatus = "Hatch was rejected"
        return
    end
    if ww_2.Success then
        local wt_2 = type(ww_2.Pets) == "table" and ww_2.Pets
        local wv_4 = (wt_2 or {})[1]
        local wt_4 = type(wv_4) == "table"
        if wt_4 then
            local wx_2 = wv_4.DisplayName
            local wB_1 = if wx_2 then 1 else 0
            local wz_1 = 1382 * wB_1 + 3617 * (1 - wB_1)
            local wA_1 = 9 * wB_1 + 792 * (1 - wB_1)
            if not ((wz_1 * 2138 + wA_1 * 3612 + wz_1 * wA_1) % 16777213 == 2999662) then
                wx_2 = wv_4.ModelName
            end
            if not wx_2 then
                wx_2 = wv_4.Key
            end
            wt_4 = wx_2
        end
        local wv_5 = wt_4
        local wB_2 = if wv_5 then 1 else 0
        local wz_2 = 462 * wB_2 + 2668 * (1 - wB_2)
        local wA_2 = 1007 * wB_2 + 1286 * (1 - wB_2)
        if not ((wz_2 * 501 + wA_2 * 3461 + wz_2 * wA_2) % 16777213 == 4181923) then
            wv_5 = nil
        end
        local wt_5 = wv_5
        if wv_5 then
            wv_5 = "Hatched " .. tostring(wt_5)
        end
        local wt_6 = wv_5 or "Hatched a " .. egg .. " egg"
        rQ.HatchStatus = wt_6
        return
    end
    if ww_2.Reason == "StorageFull" then
        rQ.HatchStatus = "Pet storage is full"
        return
    end
    local wt_7 = ww_2.Reason or "unknown"
    rQ.HatchStatus = "Hatch failed: " .. tostring(wt_7)
end
local function fn1203(fR)
    local wM = tonumber(tostring(fR):match("%d+"))
    local wP = wM or 1
    re.stage = math.clamp(math.floor(wP), 1, rF)
    re.lastWins = nil
end
local function fn1227()
    local uT_1
    local uS_1
    local cloneRF = q8.cloneRF
    if not cloneRF then
        rQ.ClickStatus = "Click service unavailable"
        return
    end
    uS_1, uT_1 = rv(cloneRF, "Click")
    if not uS_1 then
        rQ.ClickStatus = "Click was rejected"
        return
    end
    local uR_1 = type(uT_1) == "table" and tonumber(uT_1.power)
    if uR_1 then
        rQ.ClickStatus = "Power " .. rr(uT_1.power)
        return
    end
    rQ.ClickStatus = "Clicking"
end
q6 = nil
q7 = nil
q8 = nil
LocalPlayer = nil
ra = nil
rb = nil
rc = nil
re = nil
rg = nil
rh = nil
rj = nil
rk = nil
rl = nil
rn = nil
ro = nil
CoreGui = nil
rr = nil
rs = nil
rv = nil
rw = nil
rx = nil
ry = nil
rz = nil
rA = nil
rC = nil
rD = nil
rF = nil
rH = nil
rI = nil
rJ = nil
rK = nil
rM = nil
rN = nil
rO = nil
rP = nil
rQ = nil
rR = nil
rS = nil
local Players, Workspace, rf, Lighting, TeleportService, rp, rt, GuiService, HttpService, VirtualUser, rG, UserInputService
rU = nil
rV = nil
rW = nil
rX = nil
rY = nil
r_ = nil
r0 = nil
r1 = nil
r2 = nil
local RunService, rZ
local r4_1
local sd = if not game:IsLoaded() then 1 else 0
if sd == 1 then
    game.Loaded:Wait()
end
Players, RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, TeleportService, Lighting, Workspace, LocalPlayer, rX = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local r5 = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
game:GetService("CollectionService")
TeleportService = game:GetService("TeleportService")
Lighting = game:GetService("Lighting")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local r6 = "TempoCloneEvolution"
rX = fn501
if getgenv then
    getgenv().gethui = rX
end
rA, r_, rW, rQ, rF, rC, rx, q8, r4_1, rf, rs, rl, rc, rr, rb, rK, rh, r0, ry, rv, rI, rV = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local r3 = 23
repeat
    local r7 = (r3 * 1 + 1) % 8 + 1
    if r7 <= 4 then
        if r7 <= 2 then
            if r7 <= 1 then
                if (rl and rQ or rQ and not rl or (rF or not rl) and (rl or false)) and ((rl or rF) and (rQ and not rl) and (false and rl or rQ and rF)) and not ((rl and rQ or rQ and not rl or (rF or not rl) and (rl or false)) and ((rl or rF) and (rQ and not rl) and (false and rl or rQ and rF))) then
                    pcall(fn955)
                    rW = function(u)
                        local st
                        local su
                        local ss
                        ss = nil
                        st = nil
                        su = nil
                        local sv = u ~= ""
                        local sw = type(u) == "string" and sv
                        assert(sw, "A namespace is required")
                        assert(type(getgenv) == "function", "getgenv is unavailable")
                        st = getgenv()
                        assert(type(st) == "table", "getgenv did not return a table")
                        local sv_2 = st[u]
                        if sv_2 ~= nil then
                            local sw_2 = type(sv_2) == "table" and type(sv_2.Unload) == "function"
                            assert(sw_2, "Namespace is occupied")
                            sv_2.Unload()
                            assert(st[u] == nil, "Previous instance did not release its namespace")
                        end
                        su = {}
                        ss = { State = {}, Unloaded = false }
                        ss.Track = function(A)
                            assert(type(A) == "function", "Cleanup must be callable")
                            if ss.Unloaded then
                                A()
                            else
                                table.insert(su, A)
                            end
                            return A
                        end
                        ss.Unload = function()
                            local si_2
                            local sh_2
                            if ss.Unloaded then
                                return
                            end
                            ss.Unloaded = true
                            local sf = {}
                            local sp = #su
                            local so = -1
                            while false and sp <= 1 or true and sp >= 1 do
                                local sq = sp
                                local sg_2 = table.remove(su, sq)
                                sh_2, si_2 = pcall(sg_2)
                                if not sh_2 then
                                    table.insert(sf, tostring(si_2))
                                end
                                sp += so
                            end
                            table.clear(ss.State)
                            if #sf > 0 then
                                error("Cleanup incomplete: " .. table.concat(sf, "; "), 0)
                            end
                            if st[u] == ss then
                                st[u] = nil
                            end
                        end
                        st[u] = ss
                        return ss
                    end
                else
                    pcall(fn955)
                    r4_1 = function(u)
                        local st
                        local su
                        local ss
                        ss = nil
                        st = nil
                        su = nil
                        local sv = u ~= ""
                        local sw = type(u) == "string" and sv
                        assert(sw, "A namespace is required")
                        assert(type(getgenv) == "function", "getgenv is unavailable")
                        st = getgenv()
                        assert(type(st) == "table", "getgenv did not return a table")
                        local sv_1 = st[u]
                        if sv_1 ~= nil then
                            local sw_1 = type(sv_1) == "table" and type(sv_1.Unload) == "function"
                            assert(sw_1, "Namespace is occupied")
                            sv_1.Unload()
                            assert(st[u] == nil, "Previous instance did not release its namespace")
                        end
                        su = {}
                        ss = { State = {}, Unloaded = false }
                        ss.Track = function(A)
                            assert(type(A) == "function", "Cleanup must be callable")
                            if ss.Unloaded then
                                A()
                            else
                                table.insert(su, A)
                            end
                            return A
                        end
                        ss.Unload = function()
                            local si_1
                            local sh_1
                            if ss.Unloaded then
                                return
                            end
                            ss.Unloaded = true
                            local sf = {}
                            local sp = #su
                            local so = -1
                            while false and sp <= 1 or true and sp >= 1 do
                                local sq = sp
                                local sg_1 = table.remove(su, sq)
                                sh_1, si_1 = pcall(sg_1)
                                if not sh_1 then
                                    table.insert(sf, tostring(si_1))
                                end
                                sp += so
                            end
                            table.clear(ss.State)
                            if #sf > 0 then
                                error("Cleanup incomplete: " .. table.concat(sf, "; "), 0)
                            end
                            if st[u] == ss then
                                st[u] = nil
                            end
                        end
                        st[u] = ss
                        return ss
                    end
                end
                r3 = (r3 + 9) % 32
            else
                local Dv = bit32.rrotate(bit32.bxor(bit32.lrotate(r3, 12), string.byte(tostring(rr))), 3)
                if bit32.bxor(bit32.lrotate(bit32.bxor(Dv, 3352683748), 20), 1313635678) ~= bit32.lrotate(Dv, 20) then
                    rx = function(N, O)
                        local sF = type(N) == "table" and type(N.Track) == "function"
                        assert(sF, "FeatureAPI required")
                        local sF_2 = type(O) == "table" and type(O.OnUnload) == "function"
                        assert(sF_2, "UI library required")
                        assert(type(O.Unload) == "function", "UI unload required")
                        N.Track(function()
                            if not O.Unloaded then
                                O:Unload()
                            end
                        end)
                        O:OnUnload(function()
                            N.Unload()
                        end)
                    end
                else
                    rf = function(N, O)
                        local sF = type(N) == "table" and type(N.Track) == "function"
                        assert(sF, "FeatureAPI required")
                        local sF_1 = type(O) == "table" and type(O.OnUnload) == "function"
                        assert(sF_1, "UI library required")
                        assert(type(O.Unload) == "function", "UI unload required")
                        N.Track(function()
                            if not O.Unloaded then
                                O:Unload()
                            end
                        end)
                        O:OnUnload(function()
                            N.Unload()
                        end)
                    end
                end
                r3 = (r3 + 9) % 32
            end
        elseif r7 <= 3 then
            if r3 * 41810633 + 9 + 6 <= r3 * 41810633 + 9 + 6 + 5 then
                rA = r4_1(r6)
            else
                r6 = rA(r4_1)
            end
            r3 = (r3 + 25) % 32
        else
            local r8_1 = {
                "gdwpjpmbp",
                "gwvq",
                "sply",
                "fcmb",
                "numnwbvz",
                "turikpi",
                "qkpxi",
                "downqa",
                "ykvgsdlid",
                "ydkdvl"
            }
            local Dr = r3
            local r9_1 = r8_1[Dr % 10 + 1]
            if r9_1:len() >= r9_1:reverse():rep(Dr % 3 + 2):len() then
                rW = fn658
                r_ = fn794
                rl = fn291
                r5 = rW(Workspace)
                rs = rW(rc)
            else
                rs = fn658
                rl = fn794
                rc = fn291
                r_ = rs(r5)
                rW = rs(Workspace)
            end
            r3 = (r3 + 1) % 32
        end
    elseif r7 <= 6 then
        if r7 <= 5 then
            local r8_2 = (vector.create((r3 * 5 + 5) % 11 + 1, (r3 * 8 + 12) % 13 + 1, (r3 * 10 + 12) % 17 + 1))
            local r9_2 = (vector.create((r3 * 1 + 6) % 11 + 1, (r3 * 9 + 7) % 13 + 1, (r3 * 3 + 2) % 17 + 1))
            local Dn = vector.dot(r8_2, r9_2)
            if Dn * Dn <= vector.dot(r8_2, r8_2) * vector.dot(r9_2, r9_2) then
                rQ = rA.State
                rQ.StageStatus = "Idle"
                rQ.PlateStatus = "Idle"
                rQ.ClickStatus = "Idle"
                rQ.RebirthStatus = "Idle"
                rQ.TrainStatus = "Idle"
                rQ.CloneStatus = "Idle"
                rQ.HatchStatus = "Idle"
                rQ.PetStatus = "Idle"
                rF = 25
            else
                rA = rF.State
                rA.StageStatus = "Idle"
                rA.PlateStatus = "Idle"
                rA.ClickStatus = "Idle"
                rA.RebirthStatus = "Idle"
                rA.TrainStatus = "Idle"
                rA.CloneStatus = "Idle"
                rA.HatchStatus = "Idle"
                rA.PetStatus = "Idle"
                rQ = 25
            end
            r3 = (r3 + 17) % 32
        else
            if (r3 * 2 + 5) * 16 % 3 == ((r3 * 2 + 5) * 16 + 4) % 3 then
                rr = "Best Unlocked"
                rC = { "Uncommon", "Legendary", "Epic", "Secret", "Mythic", "Common", "Rare" }
                rx = fn548
            else
                rC = "Best Unlocked"
                rx = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret" }
                rr = fn548
            end
            r3 = (r3 + 1) % 32
        end
    elseif r7 <= 7 then
        local D7 = bit32.rrotate(bit32.bxor(bit32.lrotate(r3, 3), string.byte(tostring(q8))), 9)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(D7, 1130808591), 1532804195), (bit32.bxor(bit32.band(D7, 3164158704), 247987351))), 1532804195), 247987351) == D7 then
            rb = fn543
            rK = function(ar)
                local sU_2
                local sT_2
                sT_2, sU_2 = pcall(function()
                    return LocalPlayer:GetAttribute(ar)
                end)
                if sT_2 then
                    return sU_2
                end
                return nil
            end
            rh = fn1025
            q8 = {
                ready = false,
                cloneRF = nil,
                rebirthRF = nil,
                petRF = nil,
                eggs = nil,
                padConfig = nil,
                missing = {}
            }
        else
            q8 = fn543
            rh = function(ar)
                local sU_1
                local sT_1
                sT_1, sU_1 = pcall(function()
                    return LocalPlayer:GetAttribute(ar)
                end)
                if sT_1 then
                    return sU_1
                end
                return nil
            end
            rb = fn1025
            rK = {
                petRF = nil,
                rebirthRF = nil,
                ready = false,
                missing = {},
                padConfig = nil,
                cloneRF = nil,
                eggs = nil
            }
        end
        r3 = (r3 + 17) % 32
    else
        local r7_1 = { "fzbeudissco", "novxgrh", "hwhjhojbyr", "tsggzujx", "usgmcvuwz", "fvap", "kahgsycf" }
        local Dq = r3
        local r8_3 = r7_1[Dq % 7 + 1]
        local sd_1 = if r8_3:len() <= r8_3:reverse():rep(Dq % 3 + 2):len() then 1 else 0
        if sd_1 == 1 then
            r0 = fn572
            ry = fn184
            rv = function(aT, aU, ...)
                local s8
                local s7
                s7 = nil
                s8 = nil
                local ta_2
                if not aT then
                    return false, nil
                end
                s8 = aT:FindFirstChild(aU)
                local s9 = not s8
                local s9_2
                local te = if s9 then 1 else 0
                local tc = 1232 * te + 3356 * (1 - te)
                local td = 1756 * te + 1891 * (1 - te)
                if not ((tc * 2320 + td * 211 + tc * td) % 16777213 == 5392148) then
                    s9 = not s8:IsA("RemoteFunction")
                end
                if s9 then
                    return false, nil
                end
                s7 = table.pack(...)
                s9_2, ta_2 = pcall(function()
                    return s8:InvokeServer(table.unpack(s7, 1, s7.n))
                end)
                if not s9_2 then
                    return false, nil
                end
                return true, ta_2
            end
            rI = fn536
            rV = fn839
        else
            ry = fn572
            rv = fn184
            rV = function(aT, aU, ...)
                local s8
                local s7
                s7 = nil
                s8 = nil
                local ta_1
                if not aT then
                    return false, nil
                end
                s8 = aT:FindFirstChild(aU)
                local s9 = not s8
                local s9_1
                local te = if s9 then 1 else 0
                local tc = 1232 * te + 3356 * (1 - te)
                local td = 1756 * te + 1891 * (1 - te)
                if not ((tc * 2320 + td * 211 + tc * td) % 16777213 == 5392148) then
                    s9 = not s8:IsA("RemoteFunction")
                end
                if s9 then
                    return false, nil
                end
                s7 = table.pack(...)
                s9_1, ta_1 = pcall(function()
                    return s8:InvokeServer(table.unpack(s7, 1, s7.n))
                end)
                if not s9_1 then
                    return false, nil
                end
                return true, ta_1
            end
            r0 = fn536
            rI = fn839
        end
        r3 = (r3 + 17) % 32
    end
until (r3 * 13 + 9) % 32 == 20
rJ = nil
rJ = task.spawn(worker)
local r8_4 = os.clock() + 15
while true do
    local r3_1 = not q8.ready and rc() and os.clock() < r8_4
    if r3_1 then
        task.wait(0.1)
        continue
    end
    break
end
rA.Track(function()
    if coroutine.status(rJ) ~= "dead" then
        pcall(task.cancel, rJ)
    end
end)
rj, re, ra, r1, rY, rR, rH, rD, rp, rk, rM, rz, rw, rn, q7, rS, rU, rg, rP, rZ, rt, rG, rN, rO, ro, r2, q6 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
rp = fn559
rk = fn626
rM = fn118
rj = { interval = 0.4 }
re = { interval = 1.5, stage = 1 }
ra = { interval = 0.1 }
r1 = { interval = 5 }
rY = { interval = 0.3, pad = nil }
rR = { interval = 3 }
rH = { interval = 1, egg = rx[1] }
rD = { interval = 10 }
rz = function(b4, b5)
    local generation
    local ud = b4.generation or 0
    b4.generation = ud + 1
    b4.stopped = false
    generation = b4.generation
    task.spawn(function()
        local ua_1
        while true do
            local t9 = rc() and not b4.stopped and b4.generation == generation
            local t9_1
            if t9 then
                t9_1, ua_1 = pcall(b5)
                if not t9_1 then
                    warn("[Tempo] loop error: " .. tostring(ua_1))
                end
                local t9_2 = not rc() or b4.stopped or b4.generation ~= generation
                if t9_2 then
                    break
                end
                task.wait(b4.interval)
                continue
            end
            break
        end
    end)
end
rw = fn878
if (not r1 and not ra or (r1 or false) or false and (rz and not r1)) and ((not rR or not ra) and (not ra or false) or not r1 and ra and (not r1 and r1)) or not ((not r1 and not ra or (r1 or false) or false and (rz and not r1)) and ((not rR or not ra) and (not ra or false) or not r1 and ra and (not r1 and r1))) then
    rn = fn767
    q7 = fn699
else
    q7 = fn767
    rn = fn699
end
rS = fn477
rU = fn1227
rg = fn993
rP = fn542
rZ = fn420
rt = fn302
rG = function(d0)
    local vB
    vB = nil
    local AttackZone = rW:FindFirstChild("AttackZone")
    local vC_2
    local vD = AttackZone and AttackZone:FindFirstChild("TargetPractice" .. tostring(d0))
    local vD_2
    vB = vD
    if not vB then
        return nil
    end
    local Touch = vB:FindFirstChild("Touch")
    local vD_1 = Touch and Touch:IsA("BasePart")
    if vD_1 then
        return Touch.Position + Vector3.new(0, 4, 0)
    end
    vC_2, vD_2 = pcall(function()
        return vB:GetPivot().Position
    end)
    local vE = vC_2 and typeof(vD_2) == "Vector3"
    if vE then
        return vD_2 + Vector3.new(0, 4, 0)
    end
    return nil
end
rN = function()
    local vP_1
    local vM_1
    local vN_1, vN_3
    local cloneRF = q8.cloneRF
    if not cloneRF then
        rQ.TrainStatus = "Training service unavailable"
        return
    end
    vM_1, vN_1 = rv(cloneRF, "GetTargetPadAccess")
    local vO = not vM_1 or type(vN_1) ~= "table"
    local vO_1
    if vO then
        rQ.TrainStatus = "Could not read bag access"
        return
    end
    local vM_2 = rY.pad
    if vM_2 == nil then
        vM_2, vO_1 = rt(vN_1)
        if not vM_2 then
            rQ.TrainStatus = "No punching bag is unlocked yet"
            return
        end
    else
        vO_1 = rZ(vM_2)
        if vN_1[vM_2] ~= true then
            rQ.TrainStatus = string.format("Bag %d is locked", vM_2)
            return
        end
    end
    local vJ = rG(vM_2)
    if not vJ then
        rQ.TrainStatus = string.format("Bag %d is not loaded", vM_2)
        return
    end
    local vK = rb()
    if not vK then
        rQ.TrainStatus = "Waiting for your character"
        return
    end
    if (vK.Position - vJ).Magnitude > 8 then
        pcall(function()
            vK.CFrame = CFrame.new(vJ)
        end)
        rQ.TrainStatus = string.format("Moving onto bag %d", vM_2)
        task.wait(0.4)
        local vN_2 = not rc() or rY.stopped
        if vN_2 then
            return
        end
        vK = rb()
        if not vK then
            return
        end
    end
    vN_3, vP_1 = rv(cloneRF, "TargetFarmClick", vM_2)
    local vL_1 = not vN_3 or type(vP_1) ~= "table"
    if vL_1 then
        rQ.TrainStatus = "Training hit was rejected"
        return
    end
    if vP_1.Success then
        local format = string.format
        local vN_4 = vO_1 or 1
        local vO_2 = tostring(vN_4)
        local vQ = vP_1.clickAmount or 0
        rQ.TrainStatus = format("Bag %d x%s for %s power", vM_2, vO_2, rr(vQ))
        return
    end
    if vP_1.Reason == "NotAtPad" then
        rQ.TrainStatus = string.format("Lining up on bag %d", vM_2)
        return
    end
    if vP_1.Reason == "NeedsRebirths" then
        rQ.TrainStatus = string.format("Bag %d needs more rebirths", vM_2)
        return
    end
    local format = string.format
    local vN_5 = vP_1.Reason or "unknown"
    rQ.TrainStatus = format("Bag %d refused: %s", vM_2, tostring(vN_5))
end
rO = fn86
ro = fn88
r2 = fn1129
q6 = fn802
rj.SetEnabled = fn748
re.SetEnabled = fn671
re.SetStage = fn1203
ra.SetEnabled = fn541
r1.SetEnabled = fn831
rY.SetEnabled = fn570
rY.SetBag = fn423
rR.SetEnabled = fn191
rH.SetEnabled = fn140
rH.SetEgg = fn885
rD.SetEnabled = fn129
rA.Track(fn284)
local function r4_2()
    local B6
    local B5
    local onDiscord
    B5 = nil
    B6 = nil
    onDiscord = nil
    local BZ, Library, Toggles, B1, ThemeManager, B3, Options, SaveManager, B8
    B5 = "https://discord.gg/K7Qxnxkk46"
    B8 = "+1 Clone Evolution"
    B1 = "https://tempohub.shop"
    BZ = "https://discord.gg/K7Qxnxkk46"
    Library = getgenv().Library
    ThemeManager = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
    Toggles = Library.Toggles
    Options = Library.Options
    rf(rA, Library)
    B6 = function(gX, gY)
        local xe = rl(setclipboard) and setclipboard
        local xf = xe
        if not xf then
            local xe_1 = rl(toclipboard) and toclipboard
            xf = xe_1 or nil
        end
        local xe_2 = xf
        if not xe_2 then
            Library:Notify("Clipboard is unavailable")
            return
        end
        local xf_1 = pcall(xe_2, gX)
        if xf_1 then
            Library:Notify(gY)
        else
            Library:Notify("Failed to copy")
        end
    end
    onDiscord = function()
        B6(B5, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = B5, Copyable = true }, "|", B8, "|", "v0.4" },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(false)
    B3 = {
        Info = Window:AddTab("Info", "info"),
        Main = Window:AddTab("Main", "gamepad-2"),
        Player = Window:AddTab("Player", "person-standing"),
        Settings = Window:AddTab("Settings", "settings")
    }
    local function Ca_1(ha)
        local DiscordGroup = ha:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    for k, v in B3 do
        if k ~= "Info" then
            Ca_1(v)
        end
    end
    local function Cb()
        local xv
        xv = nil
        local Label2, Label7, Label3, Label8, Label5, Label, Label6, Label4
        local xw = {}
        local xG = 1
        local xE = rF
        while xG <= xE do
            local xH = xG
            table.insert(xw, "Stage " .. tostring(xH))
            xG += 1
        end
        local xx = { rC }
        for i, v in ipairs(rP()) do
            local xy_1 = ""
            if v.robux then
                xy_1 = " Robux"
            elseif v.rebirths then
                local format = string.format
                local rebirths = v.rebirths
                local xC = v.rebirths == 1 and "" or "s"
                xy_1 = format(" %d rebirth%s", rebirths, xC)
            end
            table.insert(xx, string.format("Bag %d  x%s%s", v.index, tostring(v.multiplier), xy_1))
        end
        local xy_2 = rp()
        local AutomationGroup = B3.Main:AddLeftGroupbox("Automation", "swords")
        Label8 = AutomationGroup:AddLabel(rQ.StageStatus, true)
        AutomationGroup:AddDivider()
        AutomationGroup:AddToggle("AutoStage", {
            Text = "Auto Farm Stage",
            Default = false,
            Tooltip = "Clears the next unlocked stage over and over, from stage 1 up to stage 25.",
            Callback = function(hA)
                rj.SetEnabled(hA)
            end
        })
        Label7 = AutomationGroup:AddLabel(rQ.PlateStatus, true)
        AutomationGroup:AddToggle("AutoWinPlate", {
            Text = "Auto Win Plate",
            Default = false,
            Tooltip = "Claims the free win plate of the stage below once that stage is cleared. Robux multiplier plates are left alone.",
            Callback = function(hF)
                re.SetEnabled(hF)
            end
        })
        AutomationGroup:AddDropdown("WinPlateStage", {
            Text = "Win Plate Stage",
            Values = xw,
            Default = xw[1],
            Multi = false,
            AllowNull = false,
            Tooltip = "Which stage the win plates are collected from.",
            Callback = function(hJ)
                re.SetStage(hJ)
            end
        })
        Label6 = AutomationGroup:AddLabel(rQ.ClickStatus, true)
        AutomationGroup:AddToggle("AutoClick", {
            Text = "Auto Click",
            Default = false,
            Tooltip = "Sends clicks to the server to build power and new clones.",
            Callback = function(hM)
                ra.SetEnabled(hM)
            end
        })
        Label5 = AutomationGroup:AddLabel(rQ.RebirthStatus, true)
        AutomationGroup:AddToggle("AutoRebirth", {
            Text = "Auto Rebirth",
            Default = false,
            Tooltip = "Rebirths as soon as your level meets the requirement.",
            Callback = function(hR)
                r1.SetEnabled(hR)
            end
        })
        local TrainingAndPetsGroup = B3.Main:AddRightGroupbox("Training and Pets", "sparkles")
        Label4 = TrainingAndPetsGroup:AddLabel(rQ.TrainStatus, true)
        TrainingAndPetsGroup:AddDivider()
        TrainingAndPetsGroup:AddToggle("AutoTrain", {
            Text = "Auto Train",
            Default = false,
            Tooltip = "Stands on a punching bag and hits it for multiplied power.",
            Callback = function(hX)
                rY.SetEnabled(hX)
            end
        })
        TrainingAndPetsGroup:AddDropdown("TrainBag", {
            Text = "Punching Bag",
            Values = xx,
            Default = xx[1],
            Multi = false,
            AllowNull = false,
            Tooltip = "Best Unlocked picks the highest multiplier your rebirths and passes allow.",
            Callback = function(h0)
                rY.SetBag(h0)
            end
        })
        Label3 = TrainingAndPetsGroup:AddLabel(rQ.CloneStatus, true)
        TrainingAndPetsGroup:AddToggle("AutoBuyClones", {
            Text = "Auto Buy Affordable Clones",
            Default = false,
            Tooltip = "Unlocks every clone tube you can already afford, cheapest first. Buying one also equips it.",
            Callback = function(h3)
                rR.SetEnabled(h3)
            end
        })
        Label2 = TrainingAndPetsGroup:AddLabel(rQ.HatchStatus, true)
        TrainingAndPetsGroup:AddToggle("AutoHatch", {
            Text = "Auto Hatch",
            Default = false,
            Tooltip = "Hatches the selected egg whenever you have the wins for it.",
            Callback = function(h8)
                rH.SetEnabled(h8)
            end
        })
        TrainingAndPetsGroup:AddDropdown("HatchEgg", {
            Text = "Egg to Hatch",
            Values = xy_2,
            Default = xy_2[1],
            Multi = false,
            AllowNull = false,
            Tooltip = "Only eggs that cost wins are listed. Robux eggs are left out.",
            Callback = function(ic)
                rH.SetEgg(ic)
            end
        })
        Label = TrainingAndPetsGroup:AddLabel(rQ.PetStatus, true)
        TrainingAndPetsGroup:AddToggle("AutoEquipBestPet", {
            Text = "Auto Equip Best Pet",
            Default = false,
            Tooltip = "Keeps your strongest owned pets equipped.",
            Callback = function(ig)
                rD.SetEnabled(ig)
            end
        })
        xv = task.spawn(function()
            while not Library.Unloaded do
                task.wait(0.4)
                pcall(function()
                    Label8:SetText(rQ.StageStatus)
                    Label7:SetText(rQ.PlateStatus)
                    Label6:SetText(rQ.ClickStatus)
                    Label5:SetText(rQ.RebirthStatus)
                    Label4:SetText(rQ.TrainStatus)
                    Label3:SetText(rQ.CloneStatus)
                    Label2:SetText(rQ.HatchStatus)
                    Label:SetText(rQ.PetStatus)
                end)
            end
        end)
        rA.Track(function()
            if coroutine.status(xv) ~= "dead" then
                task.cancel(xv)
            end
        end)
    end
    Cb()
    local function Ca_2()
        local x0
        local x5
        local x1
        local yc
        x0 = nil
        x1 = nil
        x5 = nil
        yc = nil
        local x2, x3, Label, x6, x7, x8, Label2, ya, Label3
        x1 = function(iK)
            return (tostring(iK):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
        end
        x0 = function(iM, iN)
            return string.format('<font color="%s">%s</font>', iN, x1(iM))
        end
        x7 = function(iQ, iR, iS)
            return string.format("<b>%s</b> %s %s", iQ, x0("-", "#5a6070"), x0(iR, iS))
        end
        local yd = "#6ec1ff"
        ya = "#e8a34d"
        x2 = "#7fd47f"
        local ye = "#8b93a3"
        local missing = q8.missing
        local yg = #missing == 0 and "ready"
        local yh = yg or "limited: " .. table.concat(missing, ", ")
        x6 = "Unknown"
        pcall(function()
            local xQ_1
            local xP_1
            if rl(identifyexecutor) then
                xQ_1, xP_1 = identifyexecutor()
                local xR = xQ_1 ~= ""
                local xS = type(xQ_1) == "string" and xR
                if xS then
                    local xR_1 = type(xP_1) == "string" and xP_1 ~= "" and xQ_1 .. " " .. xP_1
                    x6 = xR_1 or xQ_1
                end
            end
        end)
        yc = os.clock()
        x8 = function()
            local xU = math.floor(os.clock() - yc)
            if xU < 60 then
                return xU .. "s"
            elseif xU < 3600 then
                return string.format("%dm %ds", math.floor((xU) / (60)), xU % 60)
            else
                return string.format("%dh %dm", math.floor((xU) / (3600)), math.floor((xU % 3600) / (60)))
            end
        end
        local UserGroup = B3.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(x7("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, x2), true)
        UserGroup:AddLabel(x7("UserId", tostring(LocalPlayer.UserId), yd), true)
        UserGroup:AddLabel(x7("Executor", x6 .. "  " .. yh, x2), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(x7("Session", x8(), ya), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                B6(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                B6("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = B3.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddLabel(x7("Game", B8, yd), true)
        Label2 = SessionGroup:AddLabel(x7("Players", "0/0", x2), true)
        x3 = tostring(game.JobId)
        local yd_1 = #x3 > 18 and string.sub(x3, 1, 18) .. "..."
        local yg_2 = yd_1 or x3
        SessionGroup:AddLabel(x7("Job", yg_2, ye), true)
        Label = SessionGroup:AddLabel(x7("Ping", "0 ms", ya), true)
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
                B6(x3, "Copied Job ID")
            end
        })
        x5 = task.spawn(function()
            local xX_1
            local xW_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(x7("Session", x8(), ya))
                Label2:SetText(x7("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), x2))
                xW_1, xX_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local xW_2 = xW_1 and xX_1 .. " ms" or "n/a"
                Label:SetText(x7("Ping", xW_2, ya))
            end
        end)
        rA.Track(function()
            if coroutine.status(x5) ~= "dead" then
                task.cancel(x5)
            end
        end)
        local SocialsGroup = B3.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                B6(BZ, "Copied Rscripts profile")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                B6(B1, "Copied website link")
            end
        })
    end
    Ca_2()
    local function Ca_3()
        local j6
        local j4
        local j7
        local j5
        local MovementGroup = B3.Player:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = B3.Player:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        j6 = {}
        local j3 = {}
        j5 = {}
        j7 = {}
        j4 = {}
        local function j8()
            for k, v in j4 do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(j4)
        end
        local function kc()
            for k, v in j5 do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(j5)
        end
        local function kg()
            for k, v in j6 do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(j6)
        end
        local function kk(kl)
            if not kl:IsA("ProximityPrompt") then
                return
            end
            if j7[kl] == nil then
                j7[kl] = {
                    HoldDuration = kl.HoldDuration,
                    MaxActivationDistance = kl.MaxActivationDistance,
                    RequiresLineOfSight = kl.RequiresLineOfSight
                }
            end
            kl.HoldDuration = 0
            kl.MaxActivationDistance = 50
            kl.RequiresLineOfSight = false
        end
        local function kn()
            for k, v in j7 do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(j7)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                kg()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                kc()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                j8()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for k, v in Workspace:QueryDescendants("ProximityPrompt") do
                    pcall(kk, v)
                end
            else
                kn()
            end
        end)
        table.insert(j3, Workspace.DescendantAdded:Connect(function(kH)
            if Toggles.InstantProximityPrompt.Value then
                kk(kH)
            end
        end))
        table.insert(j3, RunService.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for k, v in Character:QueryDescendants("BasePart") do
                    if j4[v] == nil then
                        j4[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end))
        table.insert(j3, UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local zc = Character and Character:FindFirstChildOfClass("Humanoid")
            if Toggles.InfJump.Value and zc then
                zc:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(j3, RunService.RenderStepped:Connect(function(k2)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local zi = Character and Character:FindFirstChildOfClass("Humanoid")
            local zj = Character
            if zj then
                zj = Character:FindFirstChild("HumanoidRootPart")
            end
            local zh_1 = zj
            local CurrentCamera = Workspace.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and zi then
                if j5[zi] == nil then
                    j5[zi] = zi.WalkSpeed
                end
                zi.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and zh_1 and zi and CurrentCamera then
                if j6[zi] == nil then
                    j6[zi] = zi.PlatformStand
                end
                zi.PlatformStand = true
                local zj_4 = Vector3.zero
                if not UserInputService:GetFocusedTextBox() then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        zj_4 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        zj_4 -= CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        zj_4 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        zj_4 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        zj_4 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        zj_4 -= Vector3.new(0, 1, 0)
                    end
                end
                zh_1.AssemblyLinearVelocity = Vector3.zero
                if zj_4.Magnitude > 0 then
                    zh_1.CFrame = zh_1.CFrame + zj_4.Unit * Options.FlySpeed.Value * k2
                end
            end
        end))
        rA.Track(function()
            for k, v in j3 do
                v:Disconnect()
            end
            j8()
            kc()
            kg()
            kn()
        end)
    end
    Ca_3()
    local function Ca_4()
        local AC, AD, AE, AF, AG, AH, AI, AJ, AK, AL, Label, AN, AO, AP
        AN = {}
        AH = {}
        AE = nil
        AP = 0
        AF = 0
        AJ = false
        AK = os.clock()
        local MenuGroup = B3.Settings:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        Label = MenuGroup:AddLabel("AFK triggers: 0")
        AC = function()
            local CurrentCamera
            CurrentCamera = Workspace.CurrentCamera
            local zy = not CurrentCamera or not rl(VirtualUser.CaptureController) or not rl(VirtualUser.ClickButton2)
            if zy then
                return false
            end
            local zy_1 = pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            end)
            if not zy_1 then
                return false
            end
            AF += 1
            AK = os.clock()
            pcall(function()
                Label:SetText("AFK triggers: " .. AF)
            end)
            return true
        end
        AL = function(lM)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not lM)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not lM
                end
            end)
            if not lM then
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
        AI = function(l1)
            local zE = l1.ClassName == "ParticleEmitter" or l1.ClassName == "Trail"
            local zI = if zE then 1 else 0
            local zG = 1959 * zI + 1097 * (1 - zI)
            local zH = 4091 * zI + 1225 * (1 - zI)
            if not ((zG * 1887 + zH * 1347 + zG * zH) % 16777213 == 444266) then
                zE = l1.ClassName == "Smoke"
            end
            if not zE then
                zE = l1.ClassName == "Fire"
            end
            if not zE then
                zE = l1.ClassName == "Sparkles"
            end
            if not zE then
                zE = l1.ClassName == "Explosion"
            end
            if not zE then
                zE = l1.ClassName == "Beam"
            end
            if zE then
                if AN[l1] == nil then
                    AN[l1] = l1.Enabled
                end
                pcall(function()
                    l1.Enabled = false
                end)
            end
        end
        AG = function()
            for k, v in AN do
                local zN = k
                local zP = v
                if zN.Parent then
                    pcall(function()
                        zN.Enabled = zP
                    end)
                end
            end
            table.clear(AN)
            if AE then
                pcall(function()
                    settings().Rendering.QualityLevel = AE.Quality
                end)
                Lighting.GlobalShadows = AE.Shadows
                Lighting.FogEnd = AE.Fog
                AE = nil
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(mg)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not mg)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(ml)
                if ml then
                    if not AE then
                        AE = {
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
                    for k, v in Workspace:QueryDescendants("ParticleEmitter,Trail,Smoke,Fire,Sparkles,Beam") do
                        pcall(AI, v)
                    end
                else
                    AG()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        AL(true)
        local ScriptGroup = B3.Settings:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        Toggles.AntiGameplayPause:OnChanged(function()
            AL(Toggles.AntiGameplayPause.Value)
        end)
        if Toggles.AntiGameplayPause.Value then
            AL(true)
        end
        table.insert(AH, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value and not Library.Unloaded then
                AC()
            end
        end))
        table.insert(AH, Workspace.DescendantAdded:Connect(function(mE)
            if Toggles.FpsBoost.Value then
                AI(mE)
            end
        end))
        AD = function(mI)
            if AJ or Library.Unloaded or not Toggles.AutoReconnect.Value then
                return
            end
            AJ = true
            local z7 = AP
            local z8_1 = pcall(function()
                if mI then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not z8_1 then
                AJ = false
                if not mI and z7 == AP then
                    task.delay(1.5, function()
                        if z7 == AP then
                            AD(true)
                        end
                    end)
                end
            end
        end
        table.insert(AH, TeleportService.TeleportInitFailed:Connect(function(m_)
            local Ai
            if m_ == LocalPlayer and AJ then
                AJ = false
                Ai = AP
                task.delay(3, function()
                    if Ai == AP then
                        AD(true)
                    end
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local Aq = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            if Library.Unloaded or not Aq then
                return
            end
            table.insert(AH, Aq.ChildAdded:Connect(function(ne)
                if ne.Name == "ErrorPrompt" then
                    AD(false)
                end
            end))
        end)
        AO = task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    AL(true)
                end
                local At = Toggles.AntiAfk.Value and os.clock() - AK >= 60
                if At then
                    AC()
                end
                task.wait(1)
            end
        end)
        rA.Track(function()
            AP += 1
            for k, v in AH do
                v:Disconnect()
            end
            pcall(task.cancel, AO)
            AL(false)
            AG()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
        end)
    end
    Ca_4()
    local function Ca_5()
        local BN, BO, BP, BQ
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("TempoHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(B3.Settings)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/CloneEvolution")
        local BR = SaveManager:BuildConfigSection(B3.Settings)
        BN = function(nF, nG)
            local AT_1 = (nF == "Toggle" and Toggles or Options)[nG]
            local AS_2 = type(AT_1) == "table" and AT_1.Type == nF
            return AS_2 and AT_1 or nil
        end
        BP = function(nP, nQ)
            local Type = nQ.Type
            if Type == "Toggle" then
                return { idx = nP, type = "Toggle", value = nQ.Value == true }
            elseif Type == "Slider" then
                return { idx = nP, type = "Slider", value = tostring(nQ.Value) }
            elseif Type == "Dropdown" then
                return { idx = nP, type = "Dropdown", multi = nQ.Multi == true, value = nQ.Value }
            elseif Type == "Input" then
                local A_ = nQ.Value or ""
                return { idx = nP, type = "Input", text = tostring(A_) }
            elseif Type == "ColorPicker" then
                return { idx = nP, type = "ColorPicker", value = nQ.Value:ToHex(), transparency = nQ.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = nP,
                    type = "KeyPicker",
                    mode = nQ.Mode,
                    key = nQ.Value,
                    modifiers = nQ.Modifiers,
                    toggled = nQ.Toggled
                }
            else
                return nil
            end
        end
        BO = function()
            local A5 = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local A6 = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if A6 then
                        local A6_1 = BP(k, v)
                        if A6_1 then
                            A5[#A5 + 1] = A6_1
                        end
                    end
                end
            end
            table.sort(A5, function(n_, n0)
                if n_.type ~= n0.type then
                    return n_.type < n0.type
                end
                return n_.idx < n0.idx
            end)
            return { objects = A5 }
        end
        BQ = function(n2)
            local Bp
            Bp = nil
            local Bq = type(n2) ~= "table" or type(n2.idx) ~= "string" or type(n2.type) ~= "string" or SaveManager.Ignore[n2.idx]
            if Bq then
                return false
            end
            Bp = BN(n2.type, n2.idx)
            if not Bp then
                return false
            end
            local Bq_1 = pcall(function()
                if n2.type == "Input" then
                    if type(n2.text) ~= "string" then
                        return
                    end
                    Bp:SetValue(n2.text)
                elseif n2.type == "ColorPicker" then
                    Bp:SetValueRGB(Color3.fromHex(n2.value), n2.transparency)
                elseif n2.type == "KeyPicker" then
                    Bp:SetValue({ n2.key, n2.mode, n2.modifiers })
                    if n2.mode == "Toggle" and n2.toggled ~= nil then
                        Bp.Toggled = n2.toggled
                        Bp:Update()
                    end
                else
                    Bp:SetValue(n2.value)
                end
            end)
            return Bq_1
        end
        BR:AddDivider()
        BR:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        BR:AddButton("Export Config to Clipboard", function()
            local Bt_1
            local Bs_1
            Bs_1, Bt_1 = pcall(HttpService.JSONEncode, HttpService, BO())
            if Bs_1 then
                local Bs_2 = rl(setclipboard) and setclipboard
                local Bu = Bs_2
                local Bz = if Bu then 1 else 0
                local Bx = 4083 * Bz + 1277 * (1 - Bz)
                local By = 1757 * Bz + 3574 * (1 - Bz)
                if not ((Bx * 2815 + By * 704 + Bx * By) % 16777213 == 3127191) then
                    local Bs_3 = rl(toclipboard) and toclipboard
                    Bu = Bs_3 or nil
                end
                local Bs_4 = Bu
                local Bu_1 = type(Bs_4) == "function" and pcall(Bs_4, Bt_1)
                if Bu_1 then
                    Library:Notify("Config copied to clipboard", 6)
                    return
                end
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Failed to encode the config")
        end)
        BR:AddButton("Import Config from Clipboard Text", function()
            local BC_1
            local BA = Options.SaveManager_ImportSource.Value or ""
            local BA_1
            local BB = tostring(BA):match("^%s*(.-)%s*$")
            if BB == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            if #BB > 262144 then
                Library:Notify("That config is too large")
                return
            end
            BA_1, BC_1 = pcall(HttpService.JSONDecode, HttpService, BB)
            local BB_1 = not BA_1 or type(BC_1) ~= "table" or type(BC_1.objects) ~= "table"
            if BB_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            if #BC_1.objects > 2048 then
                Library:Notify("That config has too many records")
                return
            end
            local BA_2 = 0
            for i, v in ipairs(BC_1.objects) do
                if BQ(v) then
                    BA_2 += 1
                end
            end
            if BA_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local BC_2 = BA_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(BA_2, BC_2), 6)
        end)
        ThemeManager:LoadDefault()
        SaveManager:LoadAutoloadConfig()
        if Options.WinPlateStage then
            re.SetStage(Options.WinPlateStage.Value)
        end
        if Options.TrainBag then
            rY.SetBag(Options.TrainBag.Value)
        end
        if Options.HatchEgg then
            rH.SetEgg(Options.HatchEgg.Value)
        end
        if Toggles.AutoStage then
            rj.SetEnabled(Toggles.AutoStage.Value)
        end
        if Toggles.AutoWinPlate then
            re.SetEnabled(Toggles.AutoWinPlate.Value)
        end
        if Toggles.AutoClick then
            ra.SetEnabled(Toggles.AutoClick.Value)
        end
        if Toggles.AutoRebirth then
            r1.SetEnabled(Toggles.AutoRebirth.Value)
        end
        if Toggles.AutoTrain then
            rY.SetEnabled(Toggles.AutoTrain.Value)
        end
        if Toggles.AutoBuyClones then
            rR.SetEnabled(Toggles.AutoBuyClones.Value)
        end
        if Toggles.AutoHatch then
            rH.SetEnabled(Toggles.AutoHatch.Value)
        end
        if Toggles.AutoEquipBestPet then
            rD.SetEnabled(Toggles.AutoEquipBestPet.Value)
        end
        if Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    Ca_5()
end
r4_2()
end)(...)

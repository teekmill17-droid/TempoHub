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
getgenv().TempoHoodSubtitle = "+1 POOR TO RICH"
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
local kh
local k_
local kH
local lo
local Options
local k5
local kN
local kt
local DataAccessAPIClient
local kT
local kA
local lh
local kg
local kZ
local ln
local km
local VirtualUser
local Toggles
local la
local kS
local kz
local lg
local kf
local kY
local kF
local lm
local kl
local kL
local CurrentCamera2
local k9
local kR
local ky
local lf
local ke
local Label
local kE
local ll
local kk
local k2
local kK
local kq
local UserInputService
local Library
local kx
local le
local kd
local kW
local kD
local lk
local kj
local k1
local kJ
local kp
local k7
local kP
local kw
local connection
local kc
local kV
local connection2
local lj
local ki
local k0
local kI
local ko
local k6
local kO
local kv
local lc
local kb
local kU
local SaveManager
local li
local function fn16()
    local pi = Options.AutoWinMode and Options.AutoWinMode.Value or "Best"
    local pi_1 = kW(pi)
    if not pi_1 then
        return
    end
    local ph_2 = kF(pi_1.Stage, pi_1.Position)
    if ph_2 then
        k2(ph_2)
        return
    end
    lo(pi_1.Position, 8)
    k2(pi_1.Position)
    task.wait(0.35)
    local ph_3 = kF(pi_1.Stage, pi_1.Position)
    if ph_3 then
        k2(ph_3)
    end
end
local function fn31(bb)
    local mR = ky()
    local mS = mR and mR:FindFirstChild(tostring(bb))
    local mR_1 = mS
    if mS then
        mS = mR_1:FindFirstChild("StageButton")
    end
    local mR_2 = mS
    if mS then
        mS = mR_2:FindFirstChild("WinModel")
    end
    local mR_3 = mS
    if mS then
        mS = mR_3:FindFirstChild("WinPart")
    end
    local mR_4 = mS
    if mS then
        mS = mR_4:IsA("BasePart")
    end
    if mS then
        return mR_4
    end
    return nil
end
local function onCopySolanaAddress()
    ki(kv, "Copied Solana address")
end
local function onInputBegan()
    lf = tick()
end
local function fn67(b5)
    local MapPoorRich = kA:FindFirstChild("MapPoorRich")
    local nA = MapPoorRich and MapPoorRich:FindFirstChild("Spawn")
    local nz_1 = nA
    if nA then
        nA = nz_1:FindFirstChild("Training")
    end
    local nz_2 = nA
    if nA then
        nA = nz_2:FindFirstChild(b5)
    end
    local nz_3 = nA
    if nA then
        nA = nz_3:FindFirstChild(b5)
    end
    local nz_4 = nA
    if not nz_4 then
        return nil
    end
    return nz_4:FindFirstChildWhichIsA("BasePart", true)
end
local function fn77()
    local mi = kg()
    local mj = mi and mi:FindFirstChild("HumanoidRootPart")
    return mj
end
local function fn110()
    local pn = kw()
    if not pn then
        return
    end
    local po = kO(kH(pn))
    if not po then
        return
    end
    local pn_1 = kK(po.Name)
    if pn_1 then
        k2(pn_1)
    end
end
local function worker2()
    while not Library.Unloaded do
        task.wait(1)
        if kL("AutoWin") then
            pcall(lg)
        end
    end
end
local function onCopyPayPalLink()
    ki(ko, "Copied PayPal link")
end
local function fn114(fd)
    local DiscordGroup = fd:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = le })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = le })
end
local function fn127()
    local nO = {}
    local nP = ll:FindFirstChild("Inventory") and ll.Inventory:FindFirstChild("Trails")
    local nP_2
    local nQ_1
    if not nP then
        return nO
    end
    for i, child in ipairs(nP:GetChildren()) do
        local nP_1 = child:IsA("ModuleScript") and child.Name ~= "None"
        if nP_1 then
            nP_2, nQ_1 = pcall(require, child)
            local nR = nP_2 and type(nQ_1) == "table"
            if nR then
                local nP_3 = nQ_1.Costs and tonumber(nQ_1.Costs.Wins)
                local nR_1 = nP_3 or nil
                local nR_2 = #nO + 1
                local Name = child.Name
                local nT = tonumber(nQ_1.SpeedMultiplier) or 0
                nO[nR_2] = { Name = Name, Mult = nT, Wins = nR_1 }
            end
        end
    end
    table.sort(nO, function(cA, cB)
        return cA.Mult < cB.Mult
    end)
    return nO
end
local function worker4()
    while not Library.Unloaded do
        task.wait(2)
        if kL("AutoRebirth") then
            pcall(k_)
        end
        if kL("AutoBestTrails") then
            pcall(kt)
        end
        if kL("AutoBestTools") then
            pcall(k6)
        end
    end
end
local function worker3()
    while not Library.Unloaded do
        task.wait(1.5)
        if kL("AutoTrain") then
            pcall(kd)
        end
    end
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            kT(true)
        end
    end
end
local function fn181()
    local pd = kw()
    if not pd then
        return
    end
    local pe = kH(pd)
    local pf = km(pd)
    local pd_1 = lk.GetLevelRequirement(pe + 1)
    if pf >= pd_1 then
        kS:FireServer()
    end
end
local function fn185(gX, gY)
    local Type = gY.Type
    if Type == "Toggle" then
        return { idx = gX, type = "Toggle", value = gY.Value == true }
    elseif Type == "Slider" then
        return { idx = gX, type = "Slider", value = tostring(gY.Value) }
    elseif Type == "Dropdown" then
        return { idx = gX, type = "Dropdown", multi = gY.Multi == true, value = gY.Value }
    elseif Type == "Input" then
        local qD = gY.Value or ""
        return { idx = gX, type = "Input", text = tostring(qD) }
    elseif Type == "ColorPicker" then
        return { idx = gX, type = "ColorPicker", value = gY.Value:ToHex(), transparency = gY.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = gX,
            type = "KeyPicker",
            mode = gY.Mode,
            key = gY.Value,
            modifiers = gY.Modifiers,
            toggled = gY.Toggled
        }
    else
        return nil
    end
end
local function fn189()
    local mf = kg()
    local mg = mf and mf:FindFirstChildOfClass("Humanoid")
    return mg
end
local function fn219()
    pcall(function()
        connection:Disconnect()
    end)
    pcall(function()
        connection2:Disconnect()
    end)
    kT(false)
    local rj = lm()
    if rj then
        rj.PlatformStand = false
        rj.WalkSpeed = 16
    end
end
local function fn262(N, O)
    if setclipboard then
        setclipboard(N)
    elseif toclipboard then
        toclipboard(N)
    end
    Library:Notify(O)
end
local function fn293()
    local oD = kw()
    if not oD then
        return
    end
    local oE = k5(oD)
    local oF = oD.Trails and oD.Trails.Owned
    local oF_1 = oD.Trails and oD.Trails.Equipped
    local oD_1 = kN(oF_1)
    local oH
    for i, v in ipairs(ln()) do
        local oF_2 = lh(oF, v.Name)
        if oF_2 or v.Wins ~= nil and v.Wins > 0 and oE >= v.Wins then
            oH = v
        end
    end
    if not oH then
        return
    end
    if not lh(oF, oH.Name) then
        k0:FireServer(oH.Name)
        return
    end
    if oD_1 ~= oH.Name then
        k7:FireServer("Trails", oH.Name)
    end
end
local function fn332()
    local na = {}
    for k, v in pairs(kE) do
        local nb = ky()
        local nc = nb and nb:FindFirstChild(tostring(k))
        local nb_1 = nc
        if nc then
            nc = nb_1:FindFirstChild("StageButton")
        end
        local nb_2 = nc
        if nc then
            nc = nb_2:GetAttribute("Wins")
        end
        local nb_3 = tonumber(nc) or v.Wins
        na[#na + 1] = { Stage = k, Wins = nb_3, Position = v.Position }
    end
    table.sort(na, function(bP, bQ)
        return bP.Wins < bQ.Wins
    end)
    return na
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local qi_1 = lm()
        if qi_1 then
            qi_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = kq.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local p7_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if p7_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function onCopyVenmoLink()
    ki(kj, "Copied Venmo link")
end
local function onExportConfigToClipboard()
    local q0_1
    local q__1
    q__1, q0_1 = pcall(kV.JSONEncode, kV, lc())
    if not q__1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local q__2 = setclipboard or toclipboard
    local q__3 = type(q__2) ~= "function"
    local q5 = if q__3 then 1 else 0
    local q3 = 2845 * q5 + 1259 * (1 - q5)
    local q4 = 657 * q5 + 2545 * (1 - q5)
    if not ((q3 * 1565 + q4 * 3955 + q3 * q4) % 16777213 == 8920025) then
        q__3 = not pcall(q__2, q0_1)
    end
    if q__3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function onCopyBitcoinAddress()
    ki(kR, "Copied Bitcoin address")
end
local function fn412(ch)
    local nF
    for i, v in ipairs(kJ) do
        if ch >= v.Rebirths then
            if not nF or v.Mult > nF.Mult then
                nF = v
            end
        end
    end
    return nF
end
local function fn418()
    local n0 = {}
    local n1 = ll:FindFirstChild("Inventory") and ll.Inventory:FindFirstChild("Food")
    local n1_2
    local n2_1
    if not n1 then
        return n0
    end
    for i, child in ipairs(n1:GetChildren()) do
        local n1_1 = child:IsA("ModuleScript") and child.Name ~= "Config"
        if n1_1 then
            n1_2, n2_1 = pcall(require, child)
            local n3 = n1_2 and type(n2_1) == "table" and n2_1.SpeedMultiplier ~= nil
            if n3 then
                local n1_3 = tonumber(n2_1.WinsRequired) or 0
                local n1_4 = kx[child.Name] == true or n2_1.DevProductId ~= nil or n2_1.DevProductName ~= nil
                if not n1_4 then
                    n1_4 = n1_3 <= 0 and child.Name ~= "Carrot"
                end
                local n4_2 = n1_4
                local n1_5 = #n0 + 1
                local Name = child.Name
                local n6 = tonumber(n2_1.SpeedMultiplier) or 0
                local n2_2 = not n4_2
                if n2_2 ~= false then
                    n2_2 = n1_3 > 0
                end
                n0[n1_5] = { Name = Name, Mult = n6, Wins = n1_3, IsRobux = n4_2, CanBuy = n2_2 }
            end
        end
    end
    table.sort(n0, function(cU, cV)
        return cU.Mult < cV.Mult
    end)
    return n0
end
local function fn485(U, V)
    return string.format('<font color="%s">%s</font>', V, U)
end
local function fn491(gP, gQ)
    local qz_1 = (gP == "Toggle" and Toggles or Options)[gQ]
    local qy_2 = type(qz_1) == "table" and qz_1.Type == gP
    return qy_2 and qz_1 or nil
end
local function onCopyJoinScript_JobID()
    local eH = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, kP)
    ki(eH, "Copied join script to clipboard")
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local pT = tick() - lf
            local pU = tick() - li
            if pT >= 300 and pU >= 60 then
                pcall(kp)
            else
                if pT < 300 and pU >= 300 then
                    pcall(kp)
                end
            end
        end
    end
end
local function fn509()
    local mm_1
    local ml_1, ml_2
    ml_1, mm_1 = pcall(DataAccessAPIClient.GetAPI, DataAccessAPIClient)
    local mn = not ml_1
    local mn_1
    local mr = if mn then 1 else 0
    local mp = 1393 * mr + 3900 * (1 - mr)
    local mq = 4082 * mr + 3270 * (1 - mr)
    if not ((mp * 3615 + mq * 2503 + mp * mq) % 16777213 == 4161954) then
        mn = type(mm_1) ~= "table"
    end
    if mn then
        return nil
    end
    ml_2, mn_1 = pcall(mm_1.GetLocalProfile)
    local mm_2 = not ml_2 or type(mn_1) ~= "table"
    local mu = if mm_2 then 1 else 0
    local ms = 1028 * mu + 2113 * (1 - mu)
    local mt = 3811 * mu + 4003 * (1 - mu)
    if not ((ms * 2965 + mt * 1458 + ms * mt) % 16777213 == 12522166) then
        mm_2 = type(mn_1.Data) ~= "table"
    end
    if mm_2 then
        return nil
    end
    return mn_1.Data
end
local function onRenderStepped(gi)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local qk_1 = lm()
        if qk_1 then
            qk_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local qk_3 = k1()
        local ql = lm()
        if qk_3 and ql then
            ql.PlatformStand = true
            local ql_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                ql_1 = ql_1 + CurrentCamera2.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                ql_1 = ql_1 - CurrentCamera2.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                ql_1 = ql_1 - CurrentCamera2.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                ql_1 = ql_1 + CurrentCamera2.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                ql_1 = ql_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                ql_1 = ql_1 - Vector3.new(0, 1, 0)
            end
            qk_3.Velocity = Vector3.zero
            if ql_1.Magnitude > 0 then
                qk_3.CFrame = qk_3.CFrame + ql_1.Unit * Options.FlySpeed.Value * gi
            end
        end
    end
end
local function fn558(dd, de)
    if type(dd) ~= "table" then
        return false
    end
    local ow = dd[de]
    return ow ~= nil and ow ~= false and ow ~= 0
end
local function fn573()
    local MapPoorRich = kA:FindFirstChild("MapPoorRich")
    local mP = MapPoorRich and MapPoorRich:FindFirstChild("Stage's")
    return mP
end
local function fn584(aX)
    local mB = aX and aX.Levels
    local mC = mB
    if mB then
        mB = mC.Speed
    end
    local mC_1 = mB
    if mB then
        mB = mC_1.Level
    end
    local mC_2 = tonumber(mB) or 0
    return mC_2
end
local function onInputChanged(fB)
    local UserInputType = fB.UserInputType
    local pO = UserInputType == Enum.UserInputType.MouseMovement
    local pS = if pO then 1 else 0
    local pQ = 4065 * pS + 1499 * (1 - pS)
    local pR = 2200 * pS + 3696 * (1 - pS)
    if not ((pQ * 1369 + pR * 3485 + pQ * pR) % 16777213 == 5397772) then
        pO = UserInputType == Enum.UserInputType.Gamepad1
    end
    if pO then
        lf = tick()
    end
end
local function fn611()
    ki(kh, "Copied Discord invite to clipboard")
end
local function fn614(cX)
    local MapPoorRich = kA:FindFirstChild("MapPoorRich")
    local oi = MapPoorRich and MapPoorRich:FindFirstChild("Spawn")
    local oh_1 = oi
    if oi then
        oi = oh_1:FindFirstChild("Folder")
    end
    local oh_2 = oi
    if oi then
        oi = oh_2:FindFirstChild("FoodStand")
    end
    local oh_3 = oi
    if oi then
        oi = oh_3:FindFirstChild("FoodsStand")
    end
    local oh_4 = oi
    if not oh_4 then
        return nil
    end
    for i, descendant in ipairs(oh_4:GetDescendants()) do
        local oh_5 = descendant:IsA("BasePart") and descendant:GetAttribute("Name") == cX
        if oh_5 then
            local FoodPrompt = descendant:FindFirstChild("FoodPrompt")
            local oi_1 = FoodPrompt and FoodPrompt:IsA("ProximityPrompt")
            if oi_1 then
                return FoodPrompt
            end
        end
    end
    return nil
end
local function worker()
    local pz_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local py = math.floor(os.clock() - kf)
        if py < 60 then
            pz_1 = py .. "s"
        elseif py < 3600 then
            pz_1 = string.format("%dm %ds", math.floor((py) / (60)), py % 60)
        else
            pz_1 = string.format("%dh %dm", math.floor((py) / (3600)), math.floor((py % 3600) / (60)))
        end
        Label:SetText(kz("Session time", pz_1, k9))
    end
end
local function fn619()
    local pr_1
    local pq_1
    if identifyexecutor then
        pr_1, pq_1 = identifyexecutor()
        local ps = pr_1 ~= ""
        local pt = type(pr_1) == "string" and ps
        if pt then
            local ps_1 = type(pq_1) == "string" and pq_1 ~= "" and pr_1 .. " " .. pq_1
            local pq_2 = ps_1
            local px = if pq_2 then 1 else 0
            local pv = 1415 * px + 1090 * (1 - px)
            local pw = 207 * px + 1622 * (1 - px)
            if not ((pv * 3510 + pw * 1880 + pv * pw) % 16777213 == 5648715) then
                pq_2 = pr_1
            end
            kk = pq_2
        end
    end
end
local function fn627()
    local CurrentCamera = kA.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    li = tick()
end
local function fn639()
    local oU = kw()
    if not oU then
        return
    end
    local oV = k5(oU)
    local oW = oU.Food and oU.Food.Owned
    local oW_1 = oU.Food and oU.Food.Equipped
    local oU_1 = kN(oW_1)
    local oY
    local oW_2 = nil
    for i, v in ipairs(la()) do
        if lh(oW, v.Name) then
            oY = v
        else
            if v.CanBuy and oV >= v.Wins then
                oW_2 = v
            end
        end
    end
    local oZ_2 = oW_2
    local oV_1 = oY
    if oZ_2 then
        oZ_2 = not oY or oW_2.Mult > oY.Mult
    end
    if oZ_2 then
        oV_1 = oW_2
    end
    if not oV_1 then
        return
    end
    if not lh(oW, oV_1.Name) then
        if not oV_1.CanBuy or oV_1.IsRobux then
            return
        end
        local oW_4 = kl(oV_1.Name)
        if oW_4 and fireproximityprompt then
            fireproximityprompt(oW_4)
        end
        return
    end
    if oU_1 ~= oV_1.Name then
        k7:FireServer("Food", oV_1.Name)
    end
end
local function onCopyUSDTAddress()
    ki(kD, "Copied USDT address")
end
local function fn659(bS)
    local nk = lj()
    if #nk == 0 then
        return nil
    elseif bS == "Worst" then
        return nk[1]
    elseif bS == "Best" then
        return nk[#nk]
    elseif bS == "Random" then
        return nk[math.random(1, #nk)]
    else
        local nl = k1()
        if not nl then
            return nk[1]
        end
        local nm
        local nn = math.huge
        for i, v in ipairs(nk) do
            local nk_1 = v.Position
            local no = kb(v.Stage)
            if no then
                nk_1 = no.Position
            end
            local Magnitude = (nk_1 - nl.Position).Magnitude
            if Magnitude < nn then
                nn = Magnitude
                nm = v
            end
        end
        return nm
    end
end
local function onImportConfigFromClipboardTex()
    local q8_1
    local q6 = Options.SaveManager_ImportSource.Value
    local q6_1
    local rc = if q6 then 1 else 0
    local ra = 2083 * rc + 202 * (1 - rc)
    local rb = 1615 * rc + 1120 * (1 - rc)
    if not ((ra * 3365 + rb * 1654 + ra * rb) % 16777213 == 13044550) then
        q6 = ""
    end
    local q7 = tostring(q6):match("^%s*(.-)%s*$")
    if q7 == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    q6_1, q8_1 = pcall(kV.JSONDecode, kV, q7)
    local q7_1 = not q6_1
    local rc_1 = if q7_1 then 1 else 0
    local ra_1 = 198 * rc_1 + 2957 * (1 - rc_1)
    local rb_1 = 1771 * rc_1 + 3091 * (1 - rc_1)
    if not ((ra_1 * 480 + rb_1 * 3997 + ra_1 * rb_1) % 16777213 == 7524385) then
        q7_1 = type(q8_1) ~= "table"
    end
    if not q7_1 then
        q7_1 = type(q8_1.objects) ~= "table"
    end
    if q7_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local q6_2 = 0
    for i, v in ipairs(q8_1.objects) do
        if kY(v) then
            q6_2 += 1
        end
    end
    if q6_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local q8_2 = q6_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(q6_2, q8_2), 6)
end
local function fn675()
    return kq.Character
end
local function onCopyEthereumAddress()
    ki(kI, "Copied Ethereum address")
end
local function fn703()
    kT(Toggles.AntiGameplayPause.Value)
end
local function fn709()
    local qG = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local qH = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if qH then
                local qH_1 = ke(k, v)
                if qH_1 then
                    qG[#qG + 1] = qH_1
                end
            end
        end
    end
    table.sort(qG, function(g7, g8)
        if g7.type ~= g8.type then
            return g7.type < g8.type
        end
        return g7.idx < g8.idx
    end)
    return { objects = qG }
end
local function fn722()
    if not Toggles.Fly.Value then
        local qr = lm()
        if qr then
            qr.PlatformStand = false
        end
    end
end
local function fn740(aR)
    local mv = aR and aR.Wins
    local mw = tonumber(mv) or 0
    return mw
end
local function fn745(a3)
    local mH = k1()
    local mI = not a3
    local mJ = not mH
    local mN = if mJ then 1 else 0
    local mL = 1780 * mN + 376 * (1 - mN)
    local mM = 1472 * mN + 1996 * (1 - mN)
    if not ((mL * 2632 + mM * 3081 + mL * mM) % 16777213 == 11840352) then
        mJ = mI
    end
    if mJ then
        return false
    elseif typeof(a3) == "Instance" then
        if a3:IsA("Model") then
            a3 = a3:GetPivot().Position
            mH.CFrame = CFrame.new(a3 + Vector3.new(0, 3, 0))
            return true
        elseif a3:IsA("BasePart") then
            a3 = a3.Position
            mH.CFrame = CFrame.new(a3 + Vector3.new(0, 3, 0))
            return true
        else
            return false
        end
    else
        mH.CFrame = CFrame.new(a3 + Vector3.new(0, 3, 0))
        return true
    end
end
local function onRscripts()
    ki(kc, "Copied Rscripts profile to clipboard")
end
local function onUnload()
    Library:Unload()
end
local function fn797(X, Y, Z)
    return string.format("<b>%s</b> %s %s", X, kU("-", "#5a6070"), kU(Y, Z))
end
local function fn798(bv, bw)
    local m4 = kb(bv)
    if m4 then
        return m4
    elseif not bw then
        return nil
    else
        lo(bw, 8)
        local m5 = os.clock() + 2.5
        while true do
            if not (os.clock() < m5) then
                return kb(bv)
            end
            m4 = kb(bv)
            if m4 then
                break
            end
            task.wait(0.1)
        end
        return m4
    end
end
local function onCopyLitecoinAddress()
    ki(kZ, "Copied Litecoin address")
end
local function fn807(aU)
    local my = aU and aU.Rebirths
    local mz = tonumber(my) or 0
    return mz
end
local function fn821(dh)
    if type(dh) ~= "table" then
        return nil
    end
    return dh["1"] or dh[1]
end
local function fn864(au)
    local mc = Toggles[au]
    return mc ~= nil and mc.Value == true
end
local function fn920()
    if not Toggles.WalkSpeedEnabled.Value then
        local qt = lm()
        if qt then
            qt.WalkSpeed = 16
        end
    end
end
kb = nil
kc = nil
kd = nil
ke = nil
kf = nil
kg = nil
kh = nil
ki = nil
kj = nil
kk = nil
kl = nil
km = nil
Options = nil
ko = nil
kp = nil
kq = nil
CurrentCamera2 = nil
Toggles = nil
kt = nil
kv = nil
kw = nil
kx = nil
ky = nil
kz = nil
kA = nil
SaveManager = nil
connection2 = nil
kD = nil
kE = nil
kF = nil
kH = nil
kI = nil
kJ = nil
kK = nil
kL = nil
kN = nil
kO = nil
kP = nil
Library = nil
kR = nil
kS = nil
kT = nil
kU = nil
kV = nil
kW = nil
Label = nil
kY = nil
kZ = nil
local CoreGui, kM
k_ = nil
k0 = nil
k1 = nil
k2 = nil
VirtualUser = nil
k5 = nil
k6 = nil
k7 = nil
UserInputService = nil
k9 = nil
la = nil
DataAccessAPIClient = nil
lc = nil
connection = nil
le = nil
lf = nil
lg = nil
lh = nil
li = nil
lj = nil
lk = nil
ll = nil
lm = nil
ln = nil
lo = nil
local k3, lp, lr, ls, RunService, lu, lv, lw, lx, ly, lz
lp, ll, RunService, UserInputService, VirtualUser, kV, kM, CoreGui, kA, kq, ls, kh, kc, lr, lk, DataAccessAPIClient, k7, k0, kS, kJ, kE, kx = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local lq = 75
repeat
    lu = (lq * 2 + 5) % 11 + 1
    if lu <= 6 then
        if lu <= 3 then
            if lu <= 2 then
                if lu <= 1 then
                    lv = (vector.create((lq * 3 + 6) % 11 + 1, (lq * 2 + 7) % 13 + 1, (lq * 4 + 8) % 17 + 1))
                    lw = (vector.create((lq * 2 + 6) % 11 + 1, (lq * 11 + 13) % 13 + 1, (lq * 13 + 6) % 17 + 1))
                    lx = (vector.create((lq * 3 + 1) % 11 + 1, (lq * 10 + 4) % 13 + 1, (lq * 12 + 14) % 17 + 1))
                    ly = (vector.create((lq * 1 + 5) % 5 + 1, (lq * 4 + 3) % 7 + 1, (lq * 4 + 5) % 9 + 1))
                    if vector.dot(vector.cross(lv, (vector.cross(lw, lx))), ly) == vector.dot(lw * vector.dot(lv, lx) - lx * vector.dot(lv, lw), ly) + 4 then
                        kJ = kx:RemoteEvent("Rebirth")
                        lr = {
                            { Name = "Trash", Mult = 3, Rebirths = 2 },
                            { Mult = 1, Rebirths = 0, Name = "Poor" },
                            { Mult = 5, Rebirths = 5, Name = "Coin" }
                        }
                        kS = {
                            [11] = { Wins = 1000, Position = Vector3.new(-526.94506835938, 101.22668457031, -264.19506835938) },
                            [6] = { Wins = 35, Position = Vector3.new(-526.94506835938, 76.226684570312, 590.80493164062) },
                            [2] = { Wins = 2, Position = Vector3.new(-526.94506835938, 76.226684570312, 1360.0549316406) },
                            [8] = { Wins = 100, Position = Vector3.new(-526.94506835938, 76.226684570312, 270.80493164062) },
                            [4] = { Wins = 10, Position = Vector3.new(-526.94506835938, 76.226684570312, 1040.0549316406) },
                            [5] = { Wins = 20, Position = Vector3.new(-526.94506835938, 76.226684570312, 865.80493164062) },
                            [12] = { Wins = 2000, Position = Vector3.new(-526.94506835938, 101.22668457031, -424.19506835938) },
                            [7] = { Wins = 50, Position = Vector3.new(-526.94506835938, 76.226684570312, 430.80493164062) },
                            [13] = { Wins = 10000, Position = Vector3.new(-527.05493164062, 74.526672363281, -895.19506835938) },
                            [10] = { Wins = 500, Position = Vector3.new(-526.94506835938, 101.22668457031, -104.19506835938) },
                            [9] = { Wins = 200, Position = Vector3.new(-526.94506835938, 101.22668457031, 55.804931640625) },
                            [3] = { Wins = 4, Position = Vector3.new(-526.94506835938, 76.226684570312, 1200.0549316406) }
                        }
                        kE = { ["Golden Apple"] = true, ["Treasure Chest"] = true, ["Golden Protein Bar"] = true }
                    else
                        kS = lr:RemoteEvent("Rebirth")
                        kJ = {
                            { Name = "Poor", Mult = 1, Rebirths = 0 },
                            { Name = "Trash", Mult = 3, Rebirths = 2 },
                            { Name = "Coin", Mult = 5, Rebirths = 5 }
                        }
                        kE = {
                            [2] = { Wins = 2, Position = Vector3.new(-526.94506835938, 76.226684570312, 1360.0549316406) },
                            [3] = { Wins = 4, Position = Vector3.new(-526.94506835938, 76.226684570312, 1200.0549316406) },
                            [4] = { Wins = 10, Position = Vector3.new(-526.94506835938, 76.226684570312, 1040.0549316406) },
                            [5] = { Wins = 20, Position = Vector3.new(-526.94506835938, 76.226684570312, 865.80493164062) },
                            [6] = { Wins = 35, Position = Vector3.new(-526.94506835938, 76.226684570312, 590.80493164062) },
                            [7] = { Wins = 50, Position = Vector3.new(-526.94506835938, 76.226684570312, 430.80493164062) },
                            [8] = { Wins = 100, Position = Vector3.new(-526.94506835938, 76.226684570312, 270.80493164062) },
                            [9] = { Wins = 200, Position = Vector3.new(-526.94506835938, 101.22668457031, 55.804931640625) },
                            [10] = { Wins = 500, Position = Vector3.new(-526.94506835938, 101.22668457031, -104.19506835938) },
                            [11] = { Wins = 1000, Position = Vector3.new(-526.94506835938, 101.22668457031, -264.19506835938) },
                            [12] = { Wins = 2000, Position = Vector3.new(-526.94506835938, 101.22668457031, -424.19506835938) },
                            [13] = { Wins = 10000, Position = Vector3.new(-527.05493164062, 74.526672363281, -895.19506835938) }
                        }
                        kx = { ["Golden Apple"] = true, ["Golden Protein Bar"] = true, ["Treasure Chest"] = true }
                    end
                    lq = (lq + 83) % 88
                else
                    lv = (vector.create((lq * 6 + 3) % 11 + 1, (lq * 6 + 5) % 13 + 1, (lq * 2 + 4) % 17 + 1))
                    local r3 = vector.floor(lv) + vector.ceil(lv * -1)
                    if vector.dot(r3, r3) == 0 then
                        lp = game:GetService("Players")
                    else
                        lk = game:GetService("Players")
                    end
                    lq = (lq + 61) % 88
                end
            else
                if (lq * 3 + 8) * 5 % 4 == ((lq * 3 + 8) * 5 + 15) % 4 then
                    kM = game:GetService("ReplicatedStorage")
                else
                    ll = game:GetService("ReplicatedStorage")
                end
                lq = (lq + 39) % 88
            end
        elseif lu <= 5 then
            if lu <= 4 then
                if (lq * 2 + 2) * 10 % 3 == ((lq * 2 + 2) * 10 + 0) % 3 then
                    RunService = game:GetService("RunService")
                else
                    lp = game:GetService("RunService")
                end
                lq = (lq + 17) % 88
            else
                lv = {
                    "zolfjlpahly",
                    "lfwuqebus",
                    "yqfptdqgp",
                    "kxkkulcaxpq",
                    "hmtk",
                    "wnrgypprdj",
                    "uqrdgxhmk",
                    "vhdilx"
                }
                local r5 = lq
                lw = lv[r5 % 8 + 1]
                if lw:len() >= lw:gsub("(.)", "%1%1", r5 % 3 % 2 + 1):len() then
                    lr = game:GetService("UserInputService")
                else
                    UserInputService = game:GetService("UserInputService")
                end
                lq = (lq + 61) % 88
            end
        else
            local sh = bit32.rrotate(bit32.bxor(bit32.lrotate(lq, 26), string.byte(tostring(k0))), 11)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(sh, 3284215601), 99190730), (bit32.bxor(bit32.band(sh, 1010751694), 67535871))), 99190730), 67535871) ~= sh then
                kc = game:GetService("VirtualUser")
            else
                VirtualUser = game:GetService("VirtualUser")
            end
            lq = (lq + 39) % 88
        end
    elseif lu <= 9 then
        if lu <= 8 then
            if lu <= 7 then
                lv = (vector.create((lq * 7 + 8) % 11 + 1, (lq * 11 + 6) % 13 + 1, (lq * 15 + 9) % 17 + 1))
                local sk = vector.floor(lv) + vector.ceil(lv * -1)
                if vector.dot(sk, sk) == 3 then
                    kA = game:GetService("HttpService")
                    kV = game:GetService("GuiService")
                    kq = game:GetService("CoreGui")
                    kM = game:GetService("Workspace")
                    lp = CoreGui.LocalPlayer
                else
                    kV = game:GetService("HttpService")
                    kM = game:GetService("GuiService")
                    CoreGui = game:GetService("CoreGui")
                    kA = game:GetService("Workspace")
                    kq = lp.LocalPlayer
                end
                lq = (lq + 83) % 88
            else
                if (lq * 3 + 8) * 5 % 4 == ((lq * 3 + 8) * 5 + 9) % 4 then
                    kh = "Poor to Rich"
                    ls = "https://discord.gg/K7Qxnxkk46"
                else
                    ls = "Poor to Rich"
                    kh = "https://discord.gg/K7Qxnxkk46"
                end
                lq = (lq + 50) % 88
            end
        else
            lv = (vector.create((lq * 4 + 6) % 11 + 1, (lq * 7 + 7) % 13 + 1, (lq * 2 + 6) % 17 + 1))
            lw = (vector.create((lq * 5 + 7) % 11 + 1, (lq * 11 + 7) % 13 + 1, (lq * 11 + 4) % 17 + 1))
            lx = (vector.create((lq * 5 + 8) % 11 + 1, (lq * 7 + 2) % 13 + 1, (lq * 1 + 13) % 17 + 1))
            ly = (vector.create((lq * 7 + 2) % 11 + 1, (lq * 9 + 3) % 13 + 1, (lq * 3 + 2) % 17 + 1))
            if vector.dot(vector.cross(lv, lw), (vector.cross(lx, ly))) == vector.dot(lv, lx) * vector.dot(lw, ly) - vector.dot(lv, ly) * vector.dot(lw, lx) + 1 then
                lr = "https://discord.gg/K7Qxnxkk46"
            else
                kc = "https://discord.gg/K7Qxnxkk46"
            end
            lq = (lq + 17) % 88
        end
    elseif lu <= 10 then
        if (lq * 2 + 7) * 4 % 3 == ((lq * 2 + 7) * 4 + 0) % 3 then
            lr = require(ll:WaitForChild("Packages"):WaitForChild("Net"))
        else
            ll = require(lr:WaitForChild("Packages"):WaitForChild("Net"))
        end
        lq = (lq + 83) % 88
    else
        lu = {
            "npq",
            "gmgxd",
            "brlgxc",
            "vozywmsbphl",
            "sznelyrplpys",
            "daoift",
            "uhbplgslbtq",
            "fdahbxxcix",
            "oqnaecsv",
            "zkofsfva",
            "nypiryfqd"
        }
        if lu[(lq * 18 + 112) % 11 + 1] < lu[(lq * 18 + 112) % 11 + 1] then
            k7 = require(lr:WaitForChild("GetRebirthInfo"))
            ll = require(lr:WaitForChild("Controllers"):WaitForChild("Data"):WaitForChild("DataAccessAPIClient"))
            k0 = DataAccessAPIClient:RemoteEvent("Equip")
            lk = DataAccessAPIClient:RemoteEvent("TrailsBuy")
        else
            lk = require(ll:WaitForChild("GetRebirthInfo"))
            DataAccessAPIClient = require(ll:WaitForChild("Controllers"):WaitForChild("Data"):WaitForChild("DataAccessAPIClient"))
            k7 = lr:RemoteEvent("Equip")
            k0 = lr:RemoteEvent("TrailsBuy")
        end
        lq = (lq + 6) % 88
    end
until (lq * 57 + 68) % 88 == 42
lu, lx = pcall(require, ll:WaitForChild("Inventory"):WaitForChild("Food"):WaitForChild("Config"))
lw = lu
if lw then
    lp = 4
    repeat
        lq = (vector.create((lp * 5 + 5) % 11 + 1, (lp * 8 + 3) % 13 + 1, (lp * 3 + 16) % 17 + 1))
        lr = (vector.create((lp * 5 + 4) % 11 + 1, (lp * 7 + 1) % 13 + 1, (lp * 5 + 5) % 17 + 1))
        local rZ = vector.cross(lq, lr)
        local r_ = vector.dot(lq, lr)
        if vector.dot(rZ, rZ) + r_ * r_ == vector.dot(lq, lq) * vector.dot(lr, lr) then
            lw = type(lx) == "table"
        else
            lx = type(lw) == "table"
        end
        lp = (lp + 7) % 8
    until (lp * 5 + 2) % 8 == 1
end
if lw then
    lp = 6
    repeat
        lq = {
            "zyuic",
            "gcsdhcn",
            "gdmiqgobtwky",
            "qkvbt",
            "vgwc",
            "lskocyydg",
            "qzcax",
            "bapgsmwepmu",
            "whmoq",
            "oflw",
            "oyxqlugs",
            "gkrigqknbtai",
            "blts"
        }
        if lq[(lp * 16 + 38) % 13 + 1] <= lq[(lp * 16 + 38) % 13 + 1] then
            lw = type(lx.FoodBalance) == "table"
        else
            lx = type(lw.FoodBalance) == "table"
        end
        lp = (lp + 5) % 8
    until (lp * 3 + 2) % 8 == 3
end
if lw then
    for k, v in pairs(lx.FoodBalance) do
        lp = type(v) == "table"
        if lp then
            lq = v.DevProductId or v.DevProductName
            lp = lq
        end
        if lp then
            kx[k] = true
        end
    end
end
Library, SaveManager, Toggles, Options, k9, kZ, kR, kI, kD, kv, ko, kj, kk, lu, Label, kP, ki, le, kU, kz, kL, kg, lm, k1, kw, k5, kH, km, k2, ky, kb, lo, kF, lj, kW, kK, kO, ln, la, kl, lh, kN, kt, k6, k_, lg, kd = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
ki = fn262
le = fn611
kU = fn485
kz = fn797
local lF = "#7fd47f"
local lD = "#6ec1ff"
k9 = "#e8a34d"
local lA = "#8b93a3"
kZ = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
kR = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
kI = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
kD = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
kv = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
ko = ""
kj = ""
lw = "#345d9d"
local lG = "#f7931a"
local lE = "#627eea"
local lC = "#26a17b"
local lB = "#14f195"
ly = "#0070ba"
lx = "#008cff"
kL = fn864
kg = fn675
lm = fn189
k1 = fn77
kw = fn509
k5 = fn740
kH = fn807
km = fn584
k2 = fn745
ky = fn573
kb = fn31
lo = function(bo, bp)
    pcall(function()
        local m_ = bp
        local m3 = if m_ then 1 else 0
        local m1 = 1739 * m3 + 2149 * (1 - m3)
        local m2 = 3270 * m3 + 3438 * (1 - m3)
        if not ((m1 * 3317 + m2 * 1918 + m1 * m2) % 16777213 == 949440) then
            m_ = 5
        end
        kq:RequestStreamAroundAsync(bo, m_)
    end)
end
kF = fn798
lj = fn332
kW = fn659
kK = fn67
kO = fn412
ln = fn127
la = fn418
kl = fn614
lh = fn558
kN = fn821
kt = fn293
k6 = fn639
k_ = fn181
lg = fn16
kd = fn110
lp = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = kh, Copyable = true }, "|", ls },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local lH = {
    Info = lp:AddTab("Info", "info"),
    Main = lp:AddTab("Main", "coins"),
    Player = lp:AddTab("Player", "person-standing"),
    Settings = lp:AddTab("Settings", "settings")
}
if (not ki and ki and (not ki and not ki) or (ki or ki) and (ki or false)) and ("#e8a34d" and (ki and false or k9 and ki)) or not ((not ki and ki and (not ki and not ki) or (ki or ki) and (ki or false)) and ("#e8a34d" and (ki and false or k9 and ki))) then
    kk = "Unknown"
    pcall(fn619)
    lu = lH.Info:AddLeftGroupbox("Account", "circle-user")
    lu:AddLabel(kz("User", kq.Name, lF), true)
    lu:AddLabel(kz("Status", "Keyless", lF), true)
    lu:AddLabel(kz("Executor", kk, lF), true)
    lz = lH.Info:AddLeftGroupbox("Game Info", "gamepad-2")
    lz:AddLabel(kU(ls .. " [" .. tostring(game.PlaceId) .. "]", lD), true)
    lz:AddLabel(kz("Place ID", tostring(game.PlaceId), lD), true)
    Label = lz:AddLabel(kz("Session time", "0s", k9), true)
else
    lz = "Unknown"
    pcall(fn619)
    ls = kU.Info:AddLeftGroupbox("Account", "circle-user")
    ls:AddLabel(kk("User", Label.Name, lH), true)
    ls:AddLabel(kk("Status", "Keyless", lH), true)
    ls:AddLabel(kk("Executor", "Unknown", lH), true)
    lF = kU.Info:AddLeftGroupbox("Game Info", "gamepad-2")
    lF:AddLabel(lu(k9 .. " [" .. tostring(game.PlaceId) .. "]", kq), true)
    lF:AddLabel(kk("Place ID", tostring(game.PlaceId), kq), true)
    kz = lF:AddLabel(kk("Session time", "0s", lD), true)
end
kP = tostring(game.JobId)
lv = #kP > 18
if lv then
    lp = 7
    repeat
        lq = {
            "nkiirouw",
            "jbdeggybw",
            "usthopq",
            "cwus",
            "ynppvkpporm",
            "jnrwstwjtf",
            "xhbyemkec",
            "oeuhampphjr",
            "sam",
            "mvbv",
            "dbtqxq",
            "baymht"
        }
        if lq[(lp * 82 + 79) % 12 + 1] < lq[(lp * 82 + 79) % 12 + 1] then
            kP = string.sub(lv, 1, 18) .. "..."
        else
            lv = string.sub(kP, 1, 18) .. "..."
        end
        lp = (lp + 2) % 8
    until (lp * 7 + 4) % 8 == 3
end
lp = lv
local l1 = if lp then 1 else 0
local l_ = 583 * l1 + 297 * (1 - l1)
local l0 = 1339 * l1 + 391 * (1 - l1)
if not ((l_ * 2419 + l0 * 3555 + l_ * l0) % 16777213 == 6951059) then
    lp = kP
end
kf = nil
local lJ = lp
lz:AddLabel(kz("Server", lJ, lA), true)
lz:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
kf = os.clock()
task.spawn(worker)
local ScriptsGroup = lH.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(kU("Included in this hub", lA), true)
ScriptsGroup:AddLabel(kU(ls, lD), true)
lv = lH.Info:AddRightGroupbox("Features", "list")
lv:AddLabel(kU("Auto Win", lD), true)
lv:AddLabel(kU("Auto Rebirth", k9), true)
lv:AddLabel(kU("Auto Trails", lF), true)
lv:AddLabel(kU("Auto Tools", lD), true)
lv:AddLabel(kU("Auto Train", k9), true)
lv:AddLabel(kU("Player Utilities", lA), true)
lu = lH.Info:AddRightGroupbox("Socials", "link")
lu:AddButton({ Text = "Discord", Func = le })
lu:AddButton({ Text = "Rscripts", Func = onRscripts })
lq = lH.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
lq:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
lq:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
lq:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
lq:AddButton({ Text = "Copy Discord Invite", Func = le })
local DonationsGroup = lH.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(kU("All donations are optional but appreciated.", k9), true)
DonationsGroup:AddLabel(kU("If you donate you get a special role, just PING after you donate.", lF), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(kU("LTC / Litecoin", lw), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(kU("BTC / Bitcoin", lG), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(kU("ETH / Ethereum", lE), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(kU("USDT", lC), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(kU("Solana", lB), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(kU("PayPal", ly), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(kU("Venmo", lx), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(kU("Don't have any of the listed currencies but still wanna donate?", lA), true)
DonationsGroup:AddLabel(kU("DM me and we'll work something out.", lD), true)
local FaqGroup = lH.Info:AddRightGroupbox("FAQ", "circle-help")
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
for k, v in pairs(lH) do
    if v ~= lH.Info then
        fn114(v)
    end
end
lf, li, connection, connection2, CurrentCamera2, kp, kT, k3, ke, lc, kY = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
ls = lH.Main:AddLeftGroupbox("Automation", "bot")
ls:AddToggle("AutoWin", { Text = "Auto Win", Default = false })
ls:AddDropdown("AutoWinMode", { Text = "Win Mode", Values = { "Best", "Worst", "Nearest", "Random" }, Default = "Best" })
ls:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
ls:AddToggle("AutoTrain", { Text = "Auto Train", Default = false })
lr = lH.Main:AddRightGroupbox("Shop", "shopping-bag")
lr:AddToggle("AutoBestTrails", { Text = "Auto Buy/Equip Best Trails", Default = false })
lr:AddToggle("AutoBestTools", { Text = "Auto Buy/Equip Best Tools", Default = false })
lq = lH.Player:AddLeftGroupbox("Movement", "footprints")
lq:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
lq:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
lq:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
lq:AddToggle("NoClip", { Text = "NoClip", Default = false })
lq:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
lw = lH.Player:AddRightGroupbox("Fly", "feather")
lw:AddToggle("Fly", { Text = "Fly", Default = false })
lw:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
lv = lH.Settings:AddLeftGroupbox("Menu")
lv:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
lv:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
lv:AddButton({ Text = "Unload", Func = onUnload })
lf = tick()
li = tick()
pcall(function()
    for i, v in ipairs(getconnections(kq.Idled)) do
        local pK = v
        pcall(function()
            pK:Disable()
        end)
    end
end)
kp = fn627
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
task.spawn(antiAfkLoop)
kT = function(fQ)
    pcall(function()
        kM:SetGameplayPausedNotificationEnabled(not fQ)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not fQ
        end
    end)
    if not fQ then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(kq, "GameplayPaused", false)
        else
            kq.GameplayPaused = false
        end
    end)
end
Toggles.AntiGameplayPause:OnChanged(fn703)
task.spawn(antiGameplayPauseLoop)
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera2 = kA.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fn722)
Toggles.WalkSpeedEnabled:OnChanged(fn920)
task.spawn(worker2)
task.spawn(worker3)
task.spawn(worker4)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(lH.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/PoorToRich")
lu = SaveManager:BuildConfigSection(lH.Settings)
k3 = fn491
ke = fn185
lc = fn709
kY = function(ha)
    local qX
    qX = nil
    local qY = type(ha) ~= "table" or type(ha.idx) ~= "string" or type(ha.type) ~= "string" or SaveManager.Ignore[ha.idx]
    if qY then
        return false
    end
    qX = k3(ha.type, ha.idx)
    if not qX then
        return false
    end
    local qY_1 = pcall(function()
        if ha.type == "Input" then
            if type(ha.text) ~= "string" then
                return
            end
            qX:SetValue(ha.text)
        elseif ha.type == "ColorPicker" then
            qX:SetValueRGB(Color3.fromHex(ha.value), ha.transparency)
        elseif ha.type == "KeyPicker" then
            qX:SetValue({ ha.key, ha.mode, ha.modifiers })
            if ha.mode == "Toggle" and ha.toggled ~= nil then
                qX.Toggled = ha.toggled
                qX:Update()
            end
        else
            qX:SetValue(ha.value)
        end
    end)
    return qY_1
end
lu:AddDivider()
lu:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
lu:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
lu:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
Library:OnUnload(fn219)
end)(...)

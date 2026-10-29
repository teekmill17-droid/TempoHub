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
getgenv().TempoHoodSubtitle = "STEAL FROM THE RICH!"
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
local FO_16
local uJ
local tJ
local t7
local tP
local uw
local ud
local Options
local uC
local re_TREADMILL_UPGRADE
local Toggles
local State
local tI
local up
local connection
local uO
local uc
local uU
local tU
local uB
local tB
local ui
local u_
local t_
local uH
local tH
local u5
local uN
local uT
local tT
local uA
local uh
local uZ
local tZ
local uG
local tG
local un
local t4
local uM
local ua
local uS
local Network
local uY
local tY
local uF
local um
local re_PLOT_UPGRADE
local uL
local tL
local uR
local ClientBalanceService
local uy
local Library
local rf_ITEM_LOADOUT
local u2
local t2
local uK
local ur
local uQ
local ux
local InfiniteMath
local uD
local tD
local u1
local t1
function fns.fn1()
    gethui = u_
end
function fns.fn27()
    uQ(tL.Player)
    local MovementGroup = tL.Player:AddLeftGroupbox("Movement", "person-standing")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "Noclip", Default = false })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = tL.Player:AddRightGroupbox("Fly", "plane")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    Toggles.WalkSpeedEnabled:OnChanged(function(mF)
        uM.SetWalkSpeedEnabled(mF)
    end)
    Options.WalkSpeed:OnChanged(function(mJ)
        uM.SetWalkSpeedValue(mJ)
    end)
    Toggles.InfJump:OnChanged(function(mL)
        uM.SetInfJump(mL)
    end)
    Toggles.NoClip:OnChanged(function(mN)
        uM.SetNoClip(mN)
    end)
    Toggles.InstantProximityPrompt:OnChanged(function(mP)
        uM.SetInstantProximityPrompt(mP)
    end)
    Toggles.Fly:OnChanged(function(mR)
        uM.SetFly(mR)
    end)
    Options.FlySpeed:OnChanged(function(mT)
        uM.SetFlySpeed(mT)
    end)
end
local function fn58()
    uQ(tL.Main)
    local StealGroup = tL.Main:AddLeftGroupbox("Steal", "//")
    StealGroup:AddToggle("AutoSteal", { Text = "Auto Steal", Default = false })
    StealGroup:AddDropdown("StealZoneFilter", { Text = "Zone Filter", Values = uU, Default = table.clone(uU), Multi = true, AllowNull = true })
    StealGroup:AddDropdown("StealRarityFilter", { Text = "Rarity Filter", Values = uc, Default = table.clone(uc), Multi = true, AllowNull = true })
    local TeleportGroup = tL.Main:AddLeftGroupbox("Teleport", "map-pin")
    TeleportGroup:AddButton({
        Text = "Teleport to Base",
        Func = function()
            if not uM.TeleportToBase() then
                Library:Notify("Base not found", 3)
            end
        end
    })
    TeleportGroup:AddDropdown("TeleportZone", { Text = "Zone", Values = uU, Default = 1 })
    TeleportGroup:AddButton({
        Text = "Teleport to Zone",
        Func = function()
            local D8 = Options.TeleportZone and Options.TeleportZone.Value
            local Eg = if not uM.TeleportToZone(D8) then 1 else 0
            if Eg == 1 then
                Library:Notify("Zone not found", 3)
            end
        end
    })
    local PlotGroup = tL.Main:AddLeftGroupbox("Plot", "house")
    PlotGroup:AddToggle("AutoPlace", { Text = "Auto Place", Default = false })
    PlotGroup:AddToggle("AutoOpen", { Text = "Auto Open", Default = false })
    PlotGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false })
    PlotGroup:AddToggle("AutoBuyEquipSlot", { Text = "Auto Buy +1 Equip", Default = false })
    PlotGroup:AddToggle("AutoUpgradePlot", { Text = "Auto Upgrade Plot", Default = false })
    local TreadmillGroup = tL.Main:AddRightGroupbox("Treadmill", "gauge")
    TreadmillGroup:AddToggle("AutoTreadmill", { Text = "Auto Go On Treadmill", Default = false })
    TreadmillGroup:AddToggle("AutoUpgradeTreadmill", { Text = "Auto Upgrade Treadmill", Default = false })
    local MetaGroup = tL.Main:AddRightGroupbox("Meta", "sparkles")
    MetaGroup:AddToggle("AutoClaimIndex", { Text = "Auto Claim Index", Default = false })
    MetaGroup:AddToggle("AutoBuyTrails", { Text = "Auto Buy Trails", Default = false })
    local SellGroup = tL.Main:AddRightGroupbox("Sell", "banknote")
    SellGroup:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
    SellGroup:AddToggle("TeleportToSellerWhileSelling", { Text = "Teleport to Seller while Selling", Default = false })
    SellGroup:AddDropdown("SellMode", { Text = "Sell Mode", Values = tT, Default = 2 })
    Toggles.AutoSteal:OnChanged(function(nh)
        uM.SetSteal(nh)
    end)
    Options.StealZoneFilter:OnChanged(function(nj)
        uM.SetZoneFilter(nj)
    end)
    Options.StealRarityFilter:OnChanged(function(nl)
        uM.SetRarityFilter(nl)
    end)
    Toggles.AutoPlace:OnChanged(function(nn)
        uM.SetPlace(nn)
    end)
    Toggles.AutoOpen:OnChanged(function(np)
        uM.SetOpen(np)
    end)
    Toggles.AutoEquipBest:OnChanged(function(nr)
        uM.SetEquipBest(nr)
    end)
    Toggles.AutoBuyEquipSlot:OnChanged(function(nt)
        uM.SetBuyEquipSlot(nt)
    end)
    Toggles.AutoUpgradePlot:OnChanged(function(nv)
        uM.SetUpgradePlot(nv)
    end)
    Toggles.AutoTreadmill:OnChanged(function(nx)
        uM.SetTreadmill(nx)
    end)
    Toggles.AutoUpgradeTreadmill:OnChanged(function(nz)
        uM.SetUpgradeTreadmill(nz)
    end)
    Toggles.AutoClaimIndex:OnChanged(function(nB)
        uM.SetClaimIndex(nB)
    end)
    Toggles.AutoBuyTrails:OnChanged(function(nD)
        uM.SetBuyTrails(nD)
    end)
    Toggles.AutoSell:OnChanged(function(nF)
        uM.SetSell(nF)
    end)
    Toggles.TeleportToSellerWhileSelling:OnChanged(function(nH)
        uM.SetTeleportToSellerWhileSelling(nH)
    end)
    Options.SellMode:OnChanged(function(nJ)
        uM.SetSellMode(nJ)
    end)
    uM.SetZoneFilter(Options.StealZoneFilter.Value)
    uM.SetRarityFilter(Options.StealRarityFilter.Value)
    uM.SetSellMode(Options.SellMode.Value)
    uM.SetTeleportToSellerWhileSelling(Toggles.TeleportToSellerWhileSelling.Value)
end
local function fn68()
    local Character = u2.Character
    if not Character then
        return nil
    end
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local wA_1 = HumanoidRootPart and HumanoidRootPart:IsA("BasePart")
    if wA_1 then
        return HumanoidRootPart
    end
    return nil
end
local function fn70()
    local Ar = not up() or not State.Enabled.EquipBest
    if Ar then
        return
    end
    if os.clock() - State.LastEquipBestAt < 2 then
        return
    end
    local Ar_1 = pcall(function()
        rf_ITEM_LOADOUT:InvokeServer("placebest")
    end)
    if Ar_1 then
        State.LastEquipBestAt = os.clock()
    end
end
local function fn73(hY)
    t4("Open", hY, 0.3, t1)
end
local function fn88()
    if not State.Enabled.UpgradeTreadmill then
        return
    end
    uH(re_TREADMILL_UPGRADE, "TreadmillSignBoard", "LastUpgradeTreadmillAt", 1.5)
end
local function fn98()
    local Ae_1
    local Ad_1
    local Ac_1
    local Aa = not up() or not State.Enabled.Open
    if Aa then
        return
    end
    local Ak = if os.clock() - State.LastOpenAt < 0.35 then 1 else 0
    if Ak == 1 then
        return
    end
    local Aa_1 = select(1, tI())
    if not Aa_1 then
        return
    end
    local Ab = uA()
    if not Ab then
        return
    end
    Ae_1, Ad_1, Ac_1 = nil, nil, nil
    for i, descendant in ipairs(Aa_1:GetDescendants()) do
        local Aa_2 = descendant:IsA("ProximityPrompt") and descendant.Enabled and descendant.ActionText == "Open Crate"
        if Aa_2 then
            local Parent = descendant.Parent
            local Af
            local Ag = Parent and Parent:IsA("BasePart")
            if Ag then
                Af = Parent.Position
            else
                local Model = descendant:FindFirstAncestorWhichIsA("Model")
                if Model then
                    Af = Model:GetPivot().Position
                end
            end
            if Af then
                local Magnitude = (Af - Ab.Position).Magnitude
                if not Ac_1 or Magnitude < Ac_1 then
                    Ac_1 = Magnitude
                    Ae_1 = descendant
                    Ad_1 = Af
                end
            end
        end
    end
    if not (Ae_1 and Ad_1) then
        return
    end
    tU(Ad_1)
    ud(CFrame.new(Ad_1 + Vector3.new(0, 3, 0)))
    task.wait(0.1)
    local Aa_7 = not up() or not State.Enabled.Open
    if Aa_7 then
        return
    end
    if uG(Ae_1) then
        State.LastOpenAt = os.clock()
    end
end
local function fn101(jz)
    local DiscordGroup = jz:AddLeftGroupbox("Discord", "message-circle")
    DiscordGroup:AddDiscordBox(nil, {
        Banner = 95892854151512,
        Avatar = 132608042600488,
        Title = "Tempo Hub",
        Subtitle = "Dupes, keyless scripts and updates",
        Status = "online",
        Accent = Color3.fromRGB(88, 101, 242),
        Link = uw,
        Buttons = { { Text = "Copy Discord Invite", Icon = "copy", Copy = true } }
    })
    return DiscordGroup
end
local function fn114(bm)
    local w6 = bm == ""
    local w7 = type(bm) ~= "string"
    local xb = if w7 then 1 else 0
    local w9 = 839 * xb + 728 * (1 - xb)
    local xa = 3126 * xb + 2102 * (1 - xb)
    if not ((w9 * 3918 + xa * 894 + w9 * xa) % 16777213 == 8704560) then
        w7 = w6
    end
    if w7 then
        return false
    elseif not ur(State.RarityFilter) then
        return true
    else
        return State.RarityFilter[bm] == true
    end
end
local function fn158(jD)
    return (tostring(jD):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
end
local function fn160(ig)
    t4("ClaimIndex", ig, 2, uL)
end
local function fn174(dP)
    local zp = dP and dP:GetAttribute("CrateAreaId") == "Angelic"
    if zp then
        local zp_1 = uA()
        if zp_1 then
            local LookVector = zp_1.CFrame.LookVector
            return math.atan2(-LookVector.X, -LookVector.Z)
        end
        return 0
    end
    return 0
end
local function fn193(im)
    t4("Sell", im, 1, uN)
end
local function fn196(iq)
    State.ZoneFilter = uh(iq)
    if not ur(State.ZoneFilter) then
        for i, v in ipairs(uU) do
            State.ZoneFilter[v] = true
        end
    end
end
local function fn212()
    return not uM.Unloaded
end
local function fn222(h0)
    t4("EquipBest", h0, 1.5, ua)
end
local function fn340()
    local Crates = ui:FindFirstChild("Crates")
    if not Crates then
        return {}
    end
    local zt = {}
    for i, child in ipairs(Crates:GetChildren()) do
        local zs_1 = child:IsA("Model") and child:GetAttribute("IsCrate") == true
        if zs_1 then
            local attr2 = child:GetAttribute("AreaId")
            local attr = child:GetAttribute("CrateTier")
            local zv = u1(attr2) and tP(attr)
            if zv then
                local zw
                for i, descendant in ipairs(child:GetDescendants()) do
                    local zv_1 = descendant:IsA("ProximityPrompt") and descendant.Enabled and descendant.ActionText == "Steal"
                    if zv_1 then
                        zw = descendant
                        break
                    end
                end
                if zw then
                    local Position = child:GetPivot().Position
                    table.insert(zt, { model = child, areaId = attr2, tier = attr, prompt = zw, position = Position })
                end
            end
        end
    end
    return zt
end
local function fn342(ij)
    t4("BuyTrails", ij, 1, un)
end
local function fn352(aT)
    local wF = uA()
    if not wF then
        return false
    end
    wF.AssemblyLinearVelocity = Vector3.zero
    wF.AssemblyAngularVelocity = Vector3.zero
    wF.CFrame = aT
    return true
end
local function fn353()
    local Map = ui:FindFirstChild("Map")
    local Ba = Map and Map:FindFirstChild("Vendors")
    local A9_1 = Ba
    if Ba then
        Ba = A9_1:FindFirstChild("SellPlaces")
    end
    local A9_2 = Ba
    if Ba then
        Ba = A9_2:FindFirstChild("Sell1")
    end
    local A9_3 = Ba
    if Ba then
        Ba = A9_3:FindFirstChild("sellnpc NEW")
    end
    local Bb = Ba
    if Ba then
        Ba = Bb:IsA("Model")
    end
    if Ba then
        local pivot = Bb:GetPivot()
        return pivot * CFrame.new(0, 2, 5)
    elseif A9_3 then
        local ProximityPrompt = A9_3:FindFirstChildWhichIsA("ProximityPrompt", true)
        local A9_4 = ProximityPrompt and ProximityPrompt.Parent
        local Ba_3 = A9_4
        if A9_4 then
            A9_4 = Ba_3:IsA("BasePart")
        end
        if A9_4 then
            return CFrame.new(Ba_3.Position + Vector3.new(0, 3, 4))
        end
        return CFrame.new(tD)
    else
        return CFrame.new(tD)
    end
end
local function fn387()
    local Balance = ClientBalanceService.Balance
    if Balance == nil then
        return InfiniteMath.new(0)
    end
    return Balance
end
local function fn398()
    for i, child in ipairs(ui:GetChildren()) do
        if child.Name:match("^Plot Building %d+$") then
            local floor = child:FindFirstChild("floor")
            local xx = floor and floor:GetAttribute("OwnerUserId") == u2.UserId
            if xx then
                return child, floor
            end
        end
    end
    return nil, nil
end
local function fn429(h6)
    t4("Treadmill", h6, 0.5, tZ)
end
local function fn444(cr, cs)
    local yd = cr and cr:IsA("BasePart")
    if not yd then
        return nil
    end
    local yd_1 = cs and tonumber(cs:GetAttribute("MountYaw"))
    local yd_2 = yd_1 or 0
    return cr.CFrame * CFrame.new(0, cr.Size.Y / 2 + 3, 0) * CFrame.Angles(0, math.rad(yd_2), 0)
end
local function fn470(h3)
    t4("BuyEquipSlot", h3, 1.2, u5)
end
local function fn506()
    if uK() then
        return nil
    end
    local Character = u2.Character
    if not Character then
        return nil
    end
    local Tool = Character:FindFirstChildOfClass("Tool")
    if uD(Tool) then
        return Tool
    end
    return nil
end
local function fn543(iE)
    if iE == "Held" or iE == "All" then
        State.SellMode = iE
    end
end
local function fn565()
    if not State.Enabled.UpgradePlot then
        return
    end
    uH(re_PLOT_UPGRADE, "UpgradeSignBoard", "LastUpgradePlotAt", 1.5)
end
local function fn582(iG)
    local BX = iG and true
    local B0 = if BX then 1 else 0
    local BZ = 2402 * B0 + 1504 * (1 - B0)
    local B_ = 2075 * B0 + 493 * (1 - B0)
    if not ((BZ * 1748 + B_ * 783 + BZ * B_) % 16777213 == 10807571) then
        BX = false
    end
    State.TeleportToSellerWhileSelling = BX
end
local function fn583()
    local Treadmills = ui:FindFirstChild("Treadmills")
    if not Treadmills then
        return nil, nil
    end
    local yh = Treadmills:FindFirstChild("PersonalTreadmill_" .. tostring(u2.UserId))
    if yh then
        local Belt2 = yh:FindFirstChild("Belt", true)
        local yj = Belt2 and Belt2:IsA("BasePart")
        if yj then
            return Belt2, yh
        end
        for i, child in ipairs(Treadmills:GetChildren()) do
            local yg_1 = child:GetAttribute("RiderUserId") == u2.UserId or child:GetAttribute("OwnerUserId") == u2.UserId
            if yg_1 then
                local Belt = child:FindFirstChild("Belt", true)
                local yh_1 = Belt and Belt:IsA("BasePart")
                if yh_1 then
                    return Belt, child
                end
            end
        end
        return nil, nil
    end
    for i, child in ipairs(Treadmills:GetChildren()) do
        local yg_3 = child:GetAttribute("RiderUserId") == u2.UserId or child:GetAttribute("OwnerUserId") == u2.UserId
        if yg_3 then
            local Belt = child:FindFirstChild("Belt", true)
            local yh_2 = Belt and Belt:IsA("BasePart")
            if yh_2 then
                return Belt, child
            end
        end
    end
    return nil, nil
end
local function fn586(dv, dw)
    if not dv then
        return false
    end
    local y3 = dv.CFrame:PointToObjectSpace(dw)
    local y4 = math.abs(y3.X) > dv.Size.X / 2 - 2 or math.abs(y3.Z) > dv.Size.Z / 2 - 2
    if y4 then
        return false
    end
    local y3_1 = dv.Position.Y + dv.Size.Y / 2
    if math.abs(dw.Y - y3_1) > 2.5 then
        return false
    elseif tY(dv, dw) then
        return false
    else
        return true
    end
end
local function fn596(hV)
    t4("Place", hV, 0.35, t7)
end
local function fn605(iN)
    if not up() then
        return false
    end
    local B3 = iN
    if type(iN) == "table" then
        B3 = nil
        for k, v in pairs(iN) do
            local B4_1 = v == true and type(k) == "string"
            if B4_1 then
                B3 = k
                break
            elseif type(v) == "string" then
                B3 = v
                break
            end
        end
    end
    local B4_2 = B3 == ""
    local B5 = type(B3) ~= "string" or B4_2
    if B5 then
        return false
    end
    local B3_1 = uR[B3] or B3
    local B4_4 = tJ(B3_1)
    if not B4_4 then
        return false
    end
    tU(B4_4)
    return ud(CFrame.new(B4_4))
end
local function fn633()
    local AF_1
    local AE = not up() or not State.Enabled.Treadmill
    local AE_1
    if AE then
        return
    end
    if u2:GetAttribute("OnTreadmill") == true then
        return
    end
    if os.clock() - State.LastTreadmillAt < 0.8 then
        return
    end
    AF_1, AE_1 = t2()
    if not AF_1 then
        return
    end
    local AG = um(AF_1, AE_1)
    if not AG then
        return
    end
    tU(AG.Position)
    ud(AG)
    State.LastTreadmillAt = os.clock()
end
local function fn654(dl, dm)
    for i, child in ipairs(dl:GetChildren()) do
        if child.Name == "AppraisingCrate" or child.Name == "ItemStand" then
            local Position = child:GetPivot().Position
            local yV = Position.X - dm.X
            local yW = Position.Z - dm.Z
            if yV * yV + yW * yW < 9 then
                return true
            end
        end
    end
    return false
end
local function fn674()
    if not up() then
        return false
    end
    local B1 = uF()
    if not B1 then
        return false
    end
    tU(B1.Position)
    return ud(B1)
end
local function fn675(ic)
    t4("UpgradePlot", ic, 1.2, uZ)
end
local function fn709(jJ, jK, jL)
    return string.format("<b>%s</b> %s %s", jJ, uy("-", "#5a6070"), uy(jK, jL))
end
local function fn752()
    if not uK() then
        return true
    end
    tU(tG)
    if not ud(CFrame.new(tG + Vector3.new(0, 3, 0))) then
        return false
    end
    local yO = os.clock() + 4
    while true do
        local yP = up() and uK() and os.clock() < yO
        if yP then
            ud(CFrame.new(tG + Vector3.new(0, 3, 0)))
            task.wait(0.08)
            if not up() then
                return false
            end
            continue
        end
        break
    end
    return not uK()
end
local function fn794()
    local AV = not up() or not State.Enabled.ClaimIndex
    if AV then
        return
    end
    if os.clock() - State.LastClaimIndexAt < 2 then
        return
    end
    local AV_1 = pcall(function()
        Network.FireServer("INDEX_CLAIM_ALL")
    end)
    if AV_1 then
        State.LastClaimIndexAt = os.clock()
    end
end
local function fn802(dE)
    local y9, za, zb, zc, zf, zg, zh, zi, zk, zl, zm, zn
    local ze = 13
    while true do
        local ze_1 = 518 - ze
        do
            if ze_1 < 510 then
                if ze_1 < 508 then
                    if ze_1 < 507 then
                        if ze_1 < 505 then
                            if ze_1 < 503 then
                                if ze_1 < 502 then
                                    if ze_1 == 501 then
                                        return za
                                    end
                                    break
                                elseif ze_1 == 502 then
                                    za = Vector3.new(dE.Position.X, y9, dE.Position.Z)
                                    ze = if uS(dE, za) then 17 else 15
                                else
                                    ze = 515
                                    continue
                                end
                            elseif ze_1 < 504 then
                                if ze_1 == 503 then
                                    return nil
                                end
                                ze = 514
                                continue
                            else
                                ze = if zl > 0 and zm <= zk or zl <= 0 and zm >= zk then 5 else 12
                            end
                        elseif ze_1 < 506 then
                            ze = if not dE then 0 else 4
                        elseif ze_1 == 506 then
                            ze = 1
                        else
                            ze = 509
                            continue
                        end
                    else
                        return za
                    end
                elseif ze_1 < 509 then
                    if ze_1 == 508 then
                        local Position = (dE.CFrame * CFrame.new(zi, dE.Size.Y / 2, zn)).Position
                        za = Vector3.new(Position.X, y9, Position.Z)
                        ze = if uS(dE, za) then 11 else 8
                    else
                        ze = 11714
                        continue
                    end
                elseif ze_1 == 509 then
                    zm += zl
                    ze = 14
                else
                    ze = 515
                    continue
                end
            elseif ze_1 < 513 then
                if ze_1 < 511 then
                    if ze_1 == 510 then
                        ze = 9
                    else
                        ze = 6608
                        continue
                    end
                elseif ze_1 < 512 then
                    break
                elseif ze_1 == 512 then
                    za = -zb
                    zm = za
                    zk = zb
                    zl = zc
                    ze = 14
                else
                    ze = 14028
                    continue
                end
            elseif ze_1 < 514 then
                zn = zm
                ze = 10
            elseif ze_1 < 517 then
                if ze_1 < 516 then
                    if ze_1 < 515 then
                        y9 = dE.Position.Y + dE.Size.Y / 2
                        za = math.max(1, dE.Size.X / 2 - 2.5)
                        zb = math.max(1, dE.Size.Z / 2 - 2.5)
                        zc = 3.2
                        zh = -za
                        zf = za
                        zg = zc
                        ze = 3
                    elseif ze_1 == 515 then
                        ze = if zg > 0 and zh <= zf or zg <= 0 and zh >= zf then 2 else 16
                    else
                        ze = 15394
                        continue
                    end
                else
                    zi = zh
                    ze = 6
                end
            elseif ze_1 < 518 then
                if ze_1 == 517 then
                    zh += zg
                    ze = 3
                else
                    ze = 2676
                    continue
                end
            elseif ze_1 < 6608 then
                if ze_1 < 4132 then
                    if ze_1 < 2676 then
                        if ze_1 == 518 then
                            return nil
                        end
                        ze = 6608
                        continue
                    end
                    break
                end
                break
            else
                break
            end
        end
    end
end
local function fn869(M)
    local ws = typeof(cloneref) == "function" and typeof(M) == "Instance"
    if ws then
        return cloneref(M)
    end
    return M
end
local function fn881(h9)
    t4("UpgradeTreadmill", h9, 1.2, tH)
end
local function fn883(P)
    return type(P) == "function"
end
local function fn884(bc)
    if type(bc) ~= "table" then
        return false
    end
    for k, v in pairs(bc) do
        if v then
            return true
        end
    end
    return false
end
local function fn895()
    local yw = {}
    local yB = if uK() then 1 else 0
    if yB == 1 then
        return yw
    end
    local Character = u2.Character
    if Character then
        for i, child in ipairs(Character:GetChildren()) do
            if uD(child) then
                table.insert(yw, child)
            end
        end
    end
    for i, child in ipairs(u2.Backpack:GetChildren()) do
        if uD(child) then
            table.insert(yw, child)
        end
    end
    return yw
end
local function fn936()
    local Character = u2.Character
    if not Character then
        return nil
    end
    return Character:FindFirstChildOfClass("Humanoid")
end
local function fn949(ix)
    State.RarityFilter = uh(ix)
    local BP = if not ur(State.RarityFilter) then 1 else 0
    if BP == 1 then
        for i, v in ipairs(uc) do
            State.RarityFilter[v] = true
        end
    end
end
local function fn954(jF, jG)
    return string.format('<font color="%s">%s</font>', jG, uC(jF))
end
local function fn999(jt, ju)
    local Cn = false
    if ux(setclipboard) then
        Cn = pcall(setclipboard, jt)
    else
        local Cs = if ux(toclipboard) then 1 else 0
        if Cs == 1 then
            Cn = pcall(toclipboard, jt)
        end
    end
    if Cn and ju then
        Library:Notify(ju, 3)
    elseif not Cn then
        Library:Notify("Clipboard unavailable", 3)
    end
    return Cn
end
local function fn1038()
    return tB.CoreGui
end
local function fn1042(cL)
    local yr = cL and cL:IsA("Tool")
    if not yr then
        return false
    end
    local yr_1 = cL:GetAttribute("IsBatTool") or cL:GetAttribute("IsBearTrapTool") or cL:GetAttribute("IsTreadmill")
    if yr_1 then
        return false
    end
    return cL:GetAttribute("CrateUid") ~= nil
end
local function fn1076(a7)
    local wM = not a7 or not a7:IsA("ProximityPrompt") or not a7.Enabled
    if wM then
        return false
    elseif not ux(fireproximityprompt) then
        return false
    else
        local wM_1 = pcall(fireproximityprompt, a7)
        return wM_1
    end
end
local function fn1104(hS)
    t4("Steal", hS, 0.12, t_)
end
local function fn1137()
    if not State.TeleportToSellerWhileSelling then
        return true
    end
    local Bg = uT()
    local Bh = uA()
    if Bh and (Bh.Position - Bg.Position).Magnitude <= 12 then
        return true
    end
    tU(Bg.Position)
    return ud(Bg)
end
local function fn1143()
    return u2:GetAttribute("CarryingStolen") == true
end
local function fn1179(ao, ap)
    local wu = ao.Order
    local wz = if wu then 1 else 0
    local wx = 2871 * wz + 3238 * (1 - wz)
    local wy = 3588 * wz + 1144 * (1 - wz)
    if not ((wx * 299 + wy * 2537 + wx * wy) % 16777213 == 3485120) then
        wu = 0
    end
    return wu < (ap.Order or 0)
end
local function fn1187(ca)
    local xY = uB(ca)
    if xY then
        local xZ = xY.Position.Y + xY.Size.Y / 2 + 3
        return Vector3.new(xY.Position.X, xZ, xY.Position.Z)
    end
    local Crates = ui:FindFirstChild("Crates")
    if Crates then
        for i, child in ipairs(Crates:GetChildren()) do
            if child:GetAttribute("AreaId") == ca then
                local Position = child:GetPivot().Position
                return Vector3.new(Position.X, Position.Y + 3, Position.Z)
            end
        end
    end
    return nil
end
local function fn1204(bq)
    local xc = bq == ""
    local xd = type(bq) ~= "string" or xc
    if xd then
        return false
    elseif not ur(State.ZoneFilter) then
        return true
    else
        local xc_1 = uO[bq]
        if xc_1 and State.ZoneFilter[xc_1] == true then
            return true
        end
        return State.ZoneFilter[bq] == true
    end
end
local function fn1232(hM, hN, hO, hP)
    local Enabled = State.Enabled
    local Bx = hN and true or false
    Enabled[hM] = Bx
    if State.Enabled[hM] then
        uY(hM, hO, hP)
    else
        State.Gens[hM] += 1
    end
end
local function fn1264()
    local x7_1
    local x6_1
    x6_1, x7_1 = tI()
    if x7_1 then
        local PlayerSpawn = x7_1:FindFirstChild("PlayerSpawn")
        local x8 = PlayerSpawn and PlayerSpawn:IsA("BasePart")
        if x8 then
            return PlayerSpawn.CFrame * CFrame.new(0, 3, 0)
        end
        return CFrame.new(x7_1.Position + Vector3.new(0, x7_1.Size.Y / 2 + 3, 0))
    end
    return nil
end
local function fn1282()
    local bU, bV = tI()
    return bV
end
local function fn1286(bg)
    local wY = {}
    if type(bg) == "table" then
        for k, v in pairs(bg) do
            local wZ = v == true and type(k) == "string"
            if wZ then
                wY[k] = true
            elseif type(v) == "string" then
                wY[v] = true
            end
        end
    end
    return wY
end
local function fn1319(bX)
    local xF = uJ[bX]
    local xG = xF == ""
    local xH = type(xF) ~= "string" or xG
    if xH then
        return nil
    end
    local Map = ui:FindFirstChild("Map")
    local xH_1 = { Map, ui }
    for i, v in ipairs(xH_1) do
        if v then
            local xG_2 = v:FindFirstChild(xF, true)
            local xH_2 = xG_2 and xG_2:IsA("BasePart")
            if xH_2 then
                return xG_2
            end
            for i, descendant in ipairs(v:GetDescendants()) do
                local xG_3 = descendant.Name == xF and descendant:IsA("BasePart")
                if xG_3 then
                    return descendant
                end
            end
        end
    end
    return nil
end
tB = nil
tD = nil
tG = nil
tH = nil
tI = nil
tJ = nil
tL = nil
tP = nil
ClientBalanceService = nil
tT = nil
tU = nil
Options = nil
InfiniteMath = nil
tY = nil
tZ = nil
t_ = nil
Toggles = nil
t1 = nil
t2 = nil
t4 = nil
connection = nil
t7 = nil
ua = nil
uc = nil
ud = nil
Library = nil
Network = nil
uh = nil
ui = nil
um = nil
un = nil
local rf_SELL_QUOTE, tE, re_SELL_DO, re_PLACE_AT, tM, tN, tO, tQ, tS, tX, t3, t5, SaveManager, t9, ThemeManager, ue, uj, uk, ul
up = nil
ur = nil
uw = nil
ux = nil
uy = nil
uA = nil
uB = nil
uC = nil
uD = nil
uF = nil
uG = nil
uH = nil
State = nil
uJ = nil
uK = nil
uL = nil
uM = nil
uN = nil
uO = nil
uQ = nil
uR = nil
uS = nil
uT = nil
uU = nil
rf_ITEM_LOADOUT = nil
uY = nil
uZ = nil
u_ = nil
re_TREADMILL_UPGRADE = nil
u1 = nil
u2 = nil
re_PLOT_UPGRADE = nil
u5 = nil
local uo, uq, us, ut, uu, uv, uz, uE, uP, uV, uW, u4
uo = nil
uq = nil
us = nil
ut = nil
uu = nil
uv = nil
uz = nil
uE = nil
uP = nil
uV = nil
uW = nil
u4 = nil
if not game:IsLoaded() then
    game.Loaded:Wait()
end
tB, u2, u_ = nil, nil, nil
local FO_18 = 3
repeat
    if u2 and not FO_18 and (u2 and FO_18) and ((not tB or not FO_18) and (not FO_18 or tB)) and ((tB or not tB) and (FO_18 and u2) or (not tB or tB) and (FO_18 or not tB)) or ((not u2 or tB or (u2 or not tB)) and (not tB and u2 and (not u2 or u2)) or ((u2 or not u2) and (tB and u2) or (u2 or FO_18) and (tB and tB))) or not (u2 and not FO_18 and (u2 and FO_18) and ((not tB or not FO_18) and (not FO_18 or tB)) and ((tB or not tB) and (FO_18 and u2) or (not tB or tB) and (FO_18 or not tB)) or ((not u2 or tB or (u2 or not tB)) and (not tB and u2 and (not u2 or u2)) or ((u2 or not u2) and (tB and u2) or (u2 or FO_18) and (tB and tB)))) then
        tB = {}
        tB.Players = game:GetService("Players")
        tB.ReplicatedStorage = game:GetService("ReplicatedStorage")
        tB.RunService = game:GetService("RunService")
        tB.UserInputService = game:GetService("UserInputService")
        tB.VirtualUser = game:GetService("VirtualUser")
        tB.HttpService = game:GetService("HttpService")
        tB.TeleportService = game:GetService("TeleportService")
        tB.Workspace = game:GetService("Workspace")
        tB.Lighting = game:GetService("Lighting")
        tB.Stats = game:GetService("Stats")
        tB.CoreGui = game:GetService("CoreGui")
        tB.ProximityPromptService = game:GetService("ProximityPromptService")
        u2 = tB.Players.LocalPlayer
        u_ = fn1038
    else
        u_ = {}
        u_.Players = game:GetService("Players")
        u_.ReplicatedStorage = game:GetService("ReplicatedStorage")
        u_.RunService = game:GetService("RunService")
        u_.UserInputService = game:GetService("UserInputService")
        u_.VirtualUser = game:GetService("VirtualUser")
        u_.HttpService = game:GetService("HttpService")
        u_.TeleportService = game:GetService("TeleportService")
        u_.Workspace = game:GetService("Workspace")
        u_.Lighting = game:GetService("Lighting")
        u_.Stats = game:GetService("Stats")
        u_.CoreGui = game:GetService("CoreGui")
        u_.ProximityPromptService = game:GetService("ProximityPromptService")
        tB = u_.Players.LocalPlayer
        u2 = fn1038
    end
    FO_18 = (FO_18 + 7) % 8
until (FO_18 * 5 + 2) % 8 == 4
if getgenv then
    getgenv().gethui = u_
end
uM, State, ui, Network, InfiniteMath, ClientBalanceService, re_PLACE_AT, re_SELL_DO, rf_SELL_QUOTE, re_PLOT_UPGRADE, re_TREADMILL_UPGRADE, rf_ITEM_LOADOUT, ux, up = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pcall(fns.fn1)
local function FO_19(i)
    local wf
    local wd
    local we
    wd = nil
    we = nil
    wf = nil
    local wg = i ~= ""
    local wh = type(i) == "string" and wg
    assert(wh, "Namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    wd = getgenv()
    assert(type(wd) == "table", "getgenv did not return a table")
    local wg_1 = wd[i]
    if wg_1 ~= nil then
        local wh_1 = type(wg_1) == "table" and type(wg_1.Unload) == "function"
        assert(wh_1, "Namespace is occupied")
        wg_1.Unload()
        assert(wd[i] == nil, "Previous instance did not release its namespace")
    end
    we = {}
    wf = { State = {}, Unloaded = false }
    wf.Track = function(o)
        assert(type(o) == "function", "Cleanup must be callable")
        if wf.Unloaded then
            o()
        else
            table.insert(we, o)
        end
        return o
    end
    wf.Unload = function()
        local v3_1
        local v2_1
        if wf.Unloaded then
            return
        end
        wf.Unloaded = true
        local v0 = {}
        local v7 = #we
        local v6 = -1
        while false and v7 <= 1 or true and v7 >= 1 do
            local v8 = v7
            local v1_1 = table.remove(we, v8)
            v2_1, v3_1 = pcall(v1_1)
            if not v2_1 then
                table.insert(v0, tostring(v3_1))
            end
            v7 += v6
        end
        table.clear(wf.State)
        if #v0 > 0 then
            error("Cleanup incomplete: " .. table.concat(v0, "; "), 0)
        end
        if wd[i] == wf then
            wd[i] = nil
        end
    end
    wd[i] = wf
    return wf
end
local function FO_7(D, E)
    local wn = type(D) == "table" and type(D.Track) == "function"
    assert(wn, "FeatureAPI required")
    local wn_1 = type(E) == "table" and type(E.OnUnload) == "function"
    assert(wn_1, "UI library required")
    assert(type(E.Unload) == "function", "UI unload required")
    D.Track(function()
        if not E.Unloaded then
            E:Unload()
        end
    end)
    E:OnUnload(function()
        D.Unload()
    end)
end
uM = FO_19("TempoStealFromTheRich")
State = uM.State
local FO_11 = fn869
ux = fn883
up = fn212
local FO_2 = FO_11(tB.ReplicatedStorage)
ui = FO_11(tB.Workspace)
Network = require(FO_2:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Network"))
local FO_5 = require(FO_2.Shared.Data.AreaData)
local FO_21 = require(FO_2.Shared.Data.TrailData)
local FO_12 = require(FO_2.Shared.Data.ItemData)
InfiniteMath = require(FO_2.Shared.Utility.InfiniteMath)
ClientBalanceService = require(FO_2.LBTHClient.Services.ClientBalanceService)
re_PLACE_AT = FO_2:WaitForChild("re_PLACE_AT", 30)
re_SELL_DO = FO_2:WaitForChild("re_SELL_DO", 30)
rf_SELL_QUOTE = FO_2:WaitForChild("rf_SELL_QUOTE", 30)
re_PLOT_UPGRADE = FO_2:WaitForChild("re_PLOT_UPGRADE", 30)
re_TREADMILL_UPGRADE = FO_2:WaitForChild("re_TREADMILL_UPGRADE", 30)
rf_ITEM_LOADOUT = FO_2:WaitForChild("rf_ITEM_LOADOUT", 30)
FO_18 = re_PLACE_AT and re_SELL_DO
FO_2 = FO_18 and rf_SELL_QUOTE
FO_18 = FO_2 and re_PLOT_UPGRADE
FO_2 = FO_18 and re_TREADMILL_UPGRADE
FO_18 = FO_2 and rf_ITEM_LOADOUT
uU, uR, uO, uJ = nil, nil, nil, nil
FO_2 = 0
repeat
    FO_11 = (FO_2 * 1 + 1) % 2 + 1
    if FO_11 <= 1 then
        if not uO and not uO and (uO or uO) and (uO and not uO and (uO and uO)) or (not uR and uO and (not uO and not uO) or (not uO or not uO) and (not uR and not uO)) or (not uO and uR and (not uR or not uO) or (not uR and uR or uR and not uO)) and ((not uO or not uO or uO and uR) and (not uR and not uO or not uO and uO)) or not (not uO and not uO and (uO or uO) and (uO and not uO and (uO and uO)) or (not uR and uO and (not uO and not uO) or (not uO or not uO) and (not uR and not uO)) or (not uO and uR and (not uR or not uO) or (not uR and uR or uR and not uO)) and ((not uO or not uO or uO and uR) and (not uR and not uO or not uO and uO))) then
            uR = {}
            uO = {}
            uJ = {}
        else
            uJ = {}
            uR = {}
            uO = {}
        end
        FO_2 = (FO_2 + 13) % 16
    else
        if (FO_2 * 2 + 1) * 16 % 3 == ((FO_2 * 2 + 1) * 16 + 8) % 3 then
            assert(uU, "Core remotes missing")
            FO_18 = {}
        else
            assert(FO_18, "Core remotes missing")
            uU = {}
        end
        FO_2 = (FO_2 + 5) % 16
    end
until (FO_2 * 9 + 1) % 16 == 3
FO_11 = {}
for i, v in ipairs(FO_5.Areas) do
    FO_18 = type(v) == "table" and type(v.Id) == "string"
    if FO_18 then
        table.insert(FO_11, v)
    end
end
FO_18 = 2
repeat
    FO_2 = (vector.create((FO_18 * 2 + 4) % 11 + 1, (FO_18 * 9 + 7) % 13 + 1, (FO_18 * 7 + 9) % 17 + 1))
    local Ib = vector.floor(FO_2) + vector.ceil(FO_2 * -1)
    if vector.dot(Ib, Ib) == 4 then
        table.sort(FO_11, fn1179)
    else
        table.sort(FO_11, fn1179)
    end
    FO_18 = (FO_18 + 7) % 8
until (FO_18 * 7 + 0) % 8 == 7
for i, v in ipairs(FO_11) do
    FO_18 = v.Id
    FO_2 = v.DisplayName or v.Id
    FO_11 = FO_18 .. " - " .. tostring(FO_2)
    table.insert(uU, FO_11)
    uR[FO_11] = v.Id
    uO[v.Id] = FO_11
    if type(v.AreaPart) == "string" then
        uJ[v.Id] = v.AreaPart
    end
end
uc = {}
local vF = 1
while true do
    if vF <= 20 then
        local vG = vF
        FO_18 = FO_12:GetTierByIndex(vG)
        FO_2 = type(FO_18) == "table" and type(FO_18.Name) == "string"
        if FO_2 then
            table.insert(uc, FO_18.Name)
            vF += 1
            continue
        end
        break
    end
    break
end
if #uc == 0 then
    FO_18 = 6
    repeat
        FO_2 = {
            "kkgnipmex",
            "cxcsqoow",
            "yeyljewpsy",
            "fmxzbqnl",
            "kscxfc",
            "jygric",
            "dxjco",
            "dpvsfozxmmr",
            "qaigffoifr",
            "fwi",
            "kyhdmylffta"
        }
        if FO_2[(FO_18 * 69 + 98) % 11 + 1] <= FO_2[(FO_18 * 69 + 98) % 11 + 1] then
            uc = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Divine" }
        else
            uc = { "Epic", "Uncommon", "Legendary", "Mythic", "Common", "Rare", "Divine", "Secret" }
        end
        FO_18 = (FO_18 + 0) % 8
    until (FO_18 * 3 + 6) % 8 == 0
end
tT, tN, tG, tD, u4 = nil, nil, nil, nil, nil
tT = { "Held", "All" }
tN = { Held = "held", All = "all" }
tG = Vector3.new(2437, 4, -928)
tD = Vector3.new(2437.8, 5, -860)
u4 = {}
FO_18 = FO_21.Trails
if type(FO_18) == "table" then
    for i, v in ipairs(FO_18) do
        FO_18 = type(v) == "table" and type(v.Id) == "string"
        if FO_18 then
            table.insert(u4, v)
        end
    end
end
FO_18 = 3
repeat
    local HT = bit32.rrotate(bit32.bxor(bit32.lrotate(FO_18, 1), string.byte(tostring(FO_18))), 27)
    if bit32.bxor(bit32.lrotate(bit32.bxor(HT, 529362489), 26), 3833476536) == bit32.lrotate(HT, 26) then
        State.Enabled = {
            Steal = false,
            Place = false,
            Open = false,
            EquipBest = false,
            BuyEquipSlot = false,
            Treadmill = false,
            UpgradeTreadmill = false,
            UpgradePlot = false,
            ClaimIndex = false,
            BuyTrails = false,
            Sell = false
        }
        State.RarityFilter = {}
        State.ZoneFilter = {}
    else
        State.Enabled = {
            UpgradeTreadmill = false,
            Open = false,
            EquipBest = false,
            BuyEquipSlot = false,
            Treadmill = false,
            UpgradePlot = false,
            ClaimIndex = false,
            Steal = false,
            Sell = false,
            BuyTrails = false,
            Place = false
        }
        State.RarityFilter = {}
        State.ZoneFilter = {}
    end
    FO_18 = (FO_18 + 0) % 8
until (FO_18 * 7 + 1) % 8 == 6
for i, v in ipairs(uc) do
    State.RarityFilter[v] = true
end
for i, v in ipairs(uU) do
    State.ZoneFilter[v] = true
end
uA, ul, ud, tU, uG, ur, uh, tP, u1, uE, us, tI, uP, uB, tJ, uF, um, t2, uK, uD, uq, t9, uV, uu, tY, uS, uv, tO, uW, t_, t7, t1, ua, u5, tZ, uH, tH, uZ, uL, un, uT, tQ, uN, uY, t4 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
State.SellMode = "All"
State.TeleportToSellerWhileSelling = false
State.Gens = {
    Steal = 0,
    Place = 0,
    Open = 0,
    EquipBest = 0,
    BuyEquipSlot = 0,
    Treadmill = 0,
    UpgradeTreadmill = 0,
    UpgradePlot = 0,
    ClaimIndex = 0,
    BuyTrails = 0,
    Sell = 0
}
State.TrailOwned = {}
State.LastStealAt = 0
State.LastPlaceAt = 0
State.LastOpenAt = 0
State.LastEquipBestAt = 0
State.LastBuySlotAt = 0
State.LastTreadmillAt = 0
State.LastUpgradeTreadmillAt = 0
State.LastUpgradePlotAt = 0
State.LastClaimIndexAt = 0
State.LastBuyTrailsAt = 0
State.LastSellAt = 0
uA = fn68
ul = fn936
ud = fn352
tU = function(aX)
    if typeof(aX) ~= "Vector3" then
        return
    end
    pcall(function()
        local wK = if ux(u2.RequestStreamAroundAsync) then 1 else 0
        if wK == 1 then
            task.defer(function()
                pcall(function()
                    u2:RequestStreamAroundAsync(aX)
                end)
            end)
        end
    end)
end
uG = fn1076
ur = fn884
uh = fn1286
tP = fn114
u1 = fn1204
uE = fn387
us = function(bB)
    local xn
    local xp_1
    xn = tonumber(bB)
    local xo = not xn or xn <= 0
    local xo_1
    if xo then
        return true
    end
    xo_1, xp_1 = pcall(function()
        return uE() >= InfiniteMath.new(xn)
    end)
    return xo_1 and xp_1 == true
end
tI = fn398
uP = fn1282
uB = fn1319
tJ = fn1187
uF = fn1264
um = fn444
t2 = fn583
uK = fn1143
uD = fn1042
uq = fn506
if (not uq or false or false) and ((us or not uq) and (not uq or not uq)) or (us and uq or not uD and uq or (uD and us or not uq and not uq)) or not ((not uq or false or false) and ((us or not uq) and (not uq or not uq)) or (us and uq or not uD and uq or (uD and us or not uq and not uq))) then
    t9 = fn895
    uV = fn752
else
    uV = fn895
    t9 = fn752
end
uu = function(dc)
    if not (dc and dc.Parent) then
        return false
    end
    local yR = ul()
    if not yR then
        return false
    elseif dc.Parent == u2.Character then
        return true
    else
        local yS_1 = pcall(function()
            yR:EquipTool(dc)
        end)
        return yS_1
    end
end
tY = fn654
uS = fn586
uv = fn802
tO = fn174
uW = fn340
t_ = function()
    local zN
    zN = nil
    local zO = not up()
    local zV = if zO then 1 else 0
    local zT = 1971 * zV + 1288 * (1 - zV)
    local zU = 480 * zV + 3033 * (1 - zV)
    if not ((zT * 2701 + zU * 1795 + zT * zU) % 16777213 == 7131351) then
        zO = not State.Enabled.Steal
    end
    if zO then
        return
    end
    if uK() then
        uV()
        return
    end
    if os.clock() - State.LastStealAt < 0.3 then
        return
    end
    local zO_1 = uW()
    if #zO_1 == 0 then
        return
    end
    zN = uA()
    if not zN then
        return
    end
    table.sort(zO_1, function(ek, el)
        return (ek.position - zN.Position).Magnitude < (el.position - zN.Position).Magnitude
    end)
    local zP = zO_1[1]
    tU(zP.position)
    ud(CFrame.new(zP.position + Vector3.new(0, 3, 0)))
    task.wait(0.04)
    local zO_2 = not up() or not State.Enabled.Steal
    local zV_1 = if zO_2 then 1 else 0
    local zT_1 = 303 * zV_1 + 1790 * (1 - zV_1)
    local zU_1 = 1053 * zV_1 + 400 * (1 - zV_1)
    if not ((zT_1 * 2440 + zU_1 * 1556 + zT_1 * zU_1) % 16777213 == 2696847) then
        zO_2 = uK()
    end
    if zO_2 then
        return
    end
    if not uG(zP.prompt) then
        return
    end
    State.LastStealAt = os.clock()
    local zO_3 = os.clock() + 1.5
    local zQ = false
    while true do
        local zR = up() and State.Enabled.Steal and not uK() and os.clock() < zO_3
        if zR then
            local zR_1 = not zQ
            if zR_1 ~= false then
                zR_1 = os.clock() - State.LastStealAt >= 0.2
            end
            if zR_1 then
                local zR_2 = zP.prompt and zP.prompt.Parent and zP.prompt.Enabled and not uK()
                if zR_2 then
                    uG(zP.prompt)
                end
                zQ = true
            end
            task.wait(0.05)
            continue
        end
        break
    end
    local zO_4 = not up() or not State.Enabled.Steal
    if zO_4 then
        return
    end
    if uK() then
        uV()
    end
end
t7 = function()
    local zZ, z_
    local z0 = not up()
    local z6 = if z0 then 1 else 0
    local z4 = 2861 * z6 + 1125 * (1 - z6)
    local z5 = 201 * z6 + 1924 * (1 - z6)
    if not ((z4 * 2747 + z5 * 2630 + z4 * z5) % 16777213 == 8962858) then
        z0 = not State.Enabled.Place
    end
    if z0 then
        return
    end
    if uK() then
        uV()
        return
    end
    if os.clock() - State.LastPlaceAt < 0.55 then
        return
    end
    local z0_1 = uP()
    if not z0_1 then
        return
    end
    local z1 = uq()
    if not z1 then
        local z2_1 = t9()
        if #z2_1 == 0 then
            return
        end
        uu(z2_1[1])
        task.wait(0.15)
        local z9 = if uK() then 1 else 0
        if z9 == 1 then
            return
        end
        z1 = uq()
        if not z1 then
            return
        end
    end
    zZ = uv(z0_1)
    if not zZ then
        return
    end
    tU(zZ)
    ud(CFrame.new(zZ + Vector3.new(0, 4, 0)))
    task.wait(0.1)
    local z2_2 = not up() or not State.Enabled.Place
    if z2_2 then
        return
    end
    if not uS(z0_1, zZ) then
        return
    end
    z_ = tO(z1)
    local z0_2 = pcall(function()
        re_PLACE_AT:FireServer(zZ, z_)
    end)
    if z0_2 then
        State.LastPlaceAt = os.clock()
    end
end
t1 = fn98
ua = fn70
u5 = function()
    local Aw
    local Ay_1
    local Ax = not up() or not State.Enabled.BuyEquipSlot
    local Ax_1, Ax_2
    if Ax then
        return
    end
    if os.clock() - State.LastBuySlotAt < 1.5 then
        return
    end
    Ax_1, Aw = tI()
    if not Aw then
        return
    end
    Ax_2, Ay_1 = pcall(function()
        return rf_ITEM_LOADOUT:InvokeServer("list")
    end)
    local Az = Ax_2 and type(Ay_1) == "table"
    if Az then
        local Ax_3 = tonumber(Ay_1.NextPrice)
        local Az_1 = Ax_3 and Ax_3 > 0 and not us(Ax_3)
        if Az_1 then
            return
        end
        local Ax_4 = type(Ay_1.Slots) == "number" and type(Ay_1.NextSlots) == "number" and Ay_1.NextSlots <= Ay_1.Slots
        if Ax_4 then
            return
        end
    end
    local Ax_5 = pcall(function()
        re_PLOT_UPGRADE:FireServer(Aw, true)
    end)
    if Ax_5 then
        State.LastBuySlotAt = os.clock()
    end
end
tZ = fn633
uH = function(fZ, f_, f0, f1)
    local AL
    AL = nil
    if not up() then
        return
    end
    local AM = os.clock()
    if AM - (State[f0] or 0) < (f1 or 1.5) then
        return
    end
    AL = select(1, tI())
    if not AL then
        return
    end
    local AM_2 = AL:FindFirstChild(f_, true)
    if AM_2 then
        if AM_2:GetAttribute("CanAfford") == false then
            return
        end
        local AN_1 = tonumber(AM_2:GetAttribute("UpgradePrice"))
        local AM_3 = AN_1 and AN_1 > 0 and not us(AN_1)
        if AM_3 then
            return
        end
    end
    local AM_4 = pcall(function()
        fZ:FireServer(AL)
    end)
    if AM_4 then
        State[f0] = os.clock()
    end
end
tH = fn88
uZ = fn565
uL = fn794
un = function()
    local A_ = not up() or not State.Enabled.BuyTrails
    if A_ then
        return
    end
    if os.clock() - State.LastBuyTrailsAt < 1.2 then
        return
    end
    local A__1 = false
    for i, v in ipairs(u4) do
        local A8 = v
        local A0 = not up() or not State.Enabled.BuyTrails
        if A0 then
            break
        elseif State.TrailOwned[A8.Id] ~= true then
            local A0_1 = tonumber(A8.Price) or 0
            if us(A0_1) then
                local A0_2 = pcall(function()
                    Network.FireServer("TRAIL_BUY", A8.Id)
                end)
                if A0_2 then
                    A__1 = true
                    task.wait(0.2)
                end
            end
        end
    end
    if A__1 then
        State.LastBuyTrailsAt = os.clock()
        pcall(function()
            Network.FireServer("TRAIL_STATE")
        end)
    end
end
uT = fn353
tQ = fn1137
uN = function()
    local Bk
    local Bm_1, Bm_2
    local Bl = not up() or not State.Enabled.Sell
    local Bl_2, Bl_3
    if Bl then
        return
    end
    if os.clock() - State.LastSellAt < 1.2 then
        return
    end
    Bk = tN[State.SellMode] or "all"
    if Bk == "held" then
        Bl_2, Bm_1 = pcall(function()
            return rf_SELL_QUOTE:InvokeServer()
        end)
        local Bn_1 = Bl_2 and type(Bm_1) == "table" and Bm_1.HeldLabel and Bm_1.HeldPrice
        if not Bn_1 then
            return
        end
    elseif Bk == "all" then
        Bl_3, Bm_2 = pcall(function()
            return rf_SELL_QUOTE:InvokeServer()
        end)
        local Bn_2 = Bl_3 and type(Bm_2) == "table"
        if Bn_2 then
            local Bl_4 = tonumber(Bm_2.AllCount) or 0
            if Bl_4 <= 0 then
                return
            end
        end
    end
    if not tQ() then
        return
    end
    if State.TeleportToSellerWhileSelling then
        task.wait(0.08)
        local Bl_5 = not up() or not State.Enabled.Sell
        if Bl_5 then
            return
        end
    end
    local Bl_6 = pcall(function()
        re_SELL_DO:FireServer(Bk)
    end)
    if Bl_6 then
        State.LastSellAt = os.clock()
    end
end
uY = function(hv, hw, hx)
    State.Gens[hv] += 1
    local hz = State.Gens[hv]
    task.spawn(function()
        local Bt_1
        while true do
            local Bs = up() and State.Enabled[hv] and State.Gens[hv] == hz
            local Bs_1
            if Bs then
                Bs_1, Bt_1 = pcall(hx)
                if not Bs_1 then
                    warn("[Tempo][StealFromTheRich]", hv, Bt_1)
                end
                task.wait(hw)
                local Bs_2 = not up() or not State.Enabled[hv] or State.Gens[hv] ~= hz
                if Bs_2 then
                    break
                end
                continue
            end
            break
        end
    end)
end
t4 = fn1232
uM.SetSteal = fn1104
uM.SetPlace = fn596
uM.SetOpen = fn73
uM.SetEquipBest = fn222
uM.SetBuyEquipSlot = fn470
uM.SetTreadmill = fn429
uM.SetUpgradeTreadmill = fn881
uM.SetUpgradePlot = fn675
uM.SetClaimIndex = fn160
uM.SetBuyTrails = fn342
uM.SetSell = fn193
uM.SetZoneFilter = fn196
uM.SetRarityFilter = fn949
uM.SetSellMode = fn543
uM.SetTeleportToSellerWhileSelling = fn582
uM.TeleportToBase = fn674
uM.TeleportToZone = fn605
connection = nil
FO_18 = pcall(function()
    connection = Network.OnClientEvent("TRAIL_STATE"):Connect(function(i1)
        local Cg = type(i1) == "table" and type(i1.Owned) == "table"
        if Cg then
            State.TrailOwned = i1.Owned
        end
    end)
    Network.FireServer("TRAIL_STATE")
end)
FO_2 = FO_18 and connection
if FO_2 then
    uM.Track(function()
        pcall(function()
            connection:Disconnect()
        end)
    end)
end
uM.Track(function()
    for k in pairs(State.Gens) do
        State.Gens[k] += 1
        State.Enabled[k] = false
    end
end)
FO_18 = ux(fireproximityprompt)
FO_2 = ux(setclipboard) or ux(toclipboard)
FO_19, FO_5 = nil, nil
FO_11 = 15
repeat
    FO_12 = (FO_11 * 1 + 0) % 2 + 1
    if FO_12 <= 1 then
        FO_12 = (vector.create((FO_11 * 4 + 8) % 11 + 1, (FO_11 * 11 + 13) % 13 + 1, (FO_11 * 13 + 7) % 17 + 1))
        FO_21 = (vector.create((FO_11 * 6 + 6) % 11 + 1, (FO_11 * 2 + 10) % 13 + 1, (FO_11 * 11 + 8) % 17 + 1))
        FO_16 = (vector.create((FO_11 * 7 + 4) % 11 + 1, (FO_11 * 6 + 7) % 13 + 1, (FO_11 * 12 + 13) % 17 + 1))
        if vector.dot(vector.cross(FO_12, FO_21), FO_16) == vector.dot(vector.cross(FO_21, FO_16), FO_12) + 4 then
            FO_19 = {}
        else
            FO_5 = {}
        end
        FO_11 = (FO_11 + 15) % 16
    else
        FO_12 = (vector.create((FO_11 * 2 + 1) % 11 + 1, (FO_11 * 8 + 9) % 13 + 1, (FO_11 * 7 + 11) % 17 + 1))
        FO_21 = (vector.create((FO_11 * 4 + 6) % 11 + 1, (FO_11 * 9 + 12) % 13 + 1, (FO_11 * 9 + 15) % 17 + 1))
        FO_16 = (vector.create((FO_11 * 2 + 6) % 11 + 1, (FO_11 * 11 + 12) % 13 + 1, (FO_11 * 7 + 17) % 17 + 1))
        if vector.dot(vector.cross(FO_12, FO_21), FO_16) == vector.dot(vector.cross(FO_21, FO_16), FO_12) + 1 then
            ux = { identifyexecutor = FO_2(identifyexecutor), fireproximityprompt = FO_18, setclipboard = FO_19 }
        else
            FO_19 = { fireproximityprompt = FO_18, setclipboard = FO_2, identifyexecutor = ux(identifyexecutor) }
        end
        FO_11 = (FO_11 + 7) % 16
    end
until (FO_11 * 5 + 10) % 16 == 3
if not FO_19.fireproximityprompt then
    FO_18 = 3
    repeat
        FO_2 = (vector.create((FO_18 * 1 + 3) % 11 + 1, (FO_18 * 11 + 6) % 13 + 1, (FO_18 * 13 + 17) % 17 + 1))
        FO_11 = (vector.create((FO_18 * 6 + 1) % 11 + 1, (FO_18 * 6 + 5) % 13 + 1, (FO_18 * 8 + 4) % 17 + 1))
        local Gk = vector.dot(FO_2, FO_11)
        if Gk * Gk <= vector.dot(FO_2, FO_2) * vector.dot(FO_11, FO_11) then
            table.insert(FO_5, "fireproximityprompt")
        else
            table.insert(FO_5, "fireproximityprompt")
        end
        FO_18 = (FO_18 + 1) % 4
    until (FO_18 * 1 + 1) % 4 == 1
end
FO_18 = #FO_5 == 0 and "(ready)"
FO_2 = FO_18
if not FO_2 then
    FO_18 = 4
    repeat
        local Ia = bit32.rrotate(bit32.bxor(bit32.lrotate(FO_18, 6), string.byte(tostring(FO_18))), 25)
        if bit32.bxor(bit32.lrotate(bit32.bxor(Ia, 1265310751), 20), 3254040241) ~= bit32.lrotate(Ia, 20) then
            FO_5 = "(missing " .. table.concat(FO_2, ", ") .. ")"
        else
            FO_2 = "(missing " .. table.concat(FO_5, ", ") .. ")"
        end
        FO_18 = (FO_18 + 4) % 8
    until (FO_18 * 5 + 1) % 8 == 1
end
uz, uw, ut, uo, uj, Library, ThemeManager, SaveManager, Toggles, Options, tL, t3, tX, tS, tM, t5, ue, tE, uQ, uC, uy, uk, FO_12 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
uz = FO_2
uw = "https://discord.gg/K7Qxnxkk46"
ut = "https://discord.gg/K7Qxnxkk46"
uo = "https://tempohub.shop"
local vj = "v0.5"
uj = "Steal From The Rich"
Library = getgenv().Library
ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles, Options = Library.Toggles, Library.Options
FO_7(uM, Library)
FO_19 = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = uw, Copyable = true }, "|", uj, "|", vj },
    Icon = 132608042600488,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    SidebarCompacted = true,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
tL = {}
tL.Info = FO_19:AddTab("Info", "info")
tL.Main = FO_19:AddTab("Main", "gamepad-2")
tL.Player = FO_19:AddTab("Player", "person-standing")
tL.Settings = FO_19:AddTab("Settings", "settings")
tE = fn999
uQ = fn101
uC = fn158
uy = fn954
uk = fn709
t3 = "#7fd47f"
tX = "#6ec1ff"
tS = "#e8a34d"
tM = "#8b93a3"
FO_11 = function()
    local CE
    local CJ
    local CH
    CE = nil
    CH = nil
    CJ = nil
    local Label4, CG, Label, CK, Label5, Label3, Label2
    CH = "Unknown"
    pcall(function()
        local Cu_1
        local Ct_1
        if type(identifyexecutor) == "function" then
            Cu_1, Ct_1 = identifyexecutor()
            local Cv = Cu_1 ~= ""
            local Cw = type(Cu_1) == "string" and Cv
            if Cw then
                local Cv_1 = type(Ct_1) == "string" and Ct_1 ~= "" and Cu_1 .. " " .. Ct_1
                CH = Cv_1 or Cu_1
            end
        end
    end)
    CE = os.clock()
    CK = function()
        local Cy = math.floor(os.clock() - CE)
        if Cy < 60 then
            return Cy .. "s"
        elseif Cy < 3600 then
            return string.format("%dm %ds", math.floor((Cy) / (60)), Cy % 60)
        else
            return string.format("%dh %dm", math.floor((Cy) / (3600)), math.floor((Cy % 3600) / (60)))
        end
    end
    local UserGroup = tL.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = u2, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(uk("User", u2.DisplayName .. " @" .. u2.Name, t3), true)
    UserGroup:AddLabel(uk("UserId", tostring(u2.UserId), tX), true)
    UserGroup:AddLabel(uk("Executor", CH .. "  " .. uz, t3), true)
    UserGroup:AddDivider()
    Label5 = UserGroup:AddLabel(uk("Session", CK(), tS), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            tE(u2.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            tE("https://www.roblox.com/users/" .. tostring(u2.UserId) .. "/profile", "Copied profile link")
        end
    })
    local DiscordGroup = tL.Info:AddRightGroupbox("Discord", "message-circle")
    DiscordGroup:AddDiscordBox(nil, {
        Banner = 95892854151512,
        Avatar = 132608042600488,
        Title = "Tempo Hub",
        Subtitle = "Dupes, keyless scripts and updates",
        Status = "online",
        Accent = Color3.fromRGB(88, 101, 242),
        Link = uw,
        Buttons = { { Text = "Copy Discord Invite", Icon = "copy", Copy = true } }
    })
    local SessionGroup = tL.Info:AddRightGroupbox("Session", "signal")
    Label4 = SessionGroup:AddLabel(uk("Game", uj, t3), true)
    Label3 = SessionGroup:AddLabel(uk("Players", #tB.Players:GetPlayers() .. "/" .. tostring(tB.Players.MaxPlayers), t3), true)
    CG = tostring(game.JobId)
    if #CG > 18 then
        CG = string.sub(CG, 1, 18) .. "..."
    end
    Label2 = SessionGroup:AddLabel(uk("Job", CG, tM), true)
    Label = SessionGroup:AddLabel(uk("Ping", "n/a", tS), true)
    SessionGroup:AddButton({
        Text = "Rejoin Place",
        Func = function()
            pcall(function()
                tB.TeleportService:Teleport(game.PlaceId, u2)
            end)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            tE(tostring(game.JobId), "Copied Job ID")
        end
    })
    CJ = task.spawn(function()
        local CB_1
        local CA_1
        while up() do
            task.wait(1)
            if not up() then
                break
            end
            Label5:SetText(uk("Session", CK(), tS))
            Label3:SetText(uk("Players", #tB.Players:GetPlayers() .. "/" .. tostring(tB.Players.MaxPlayers), t3))
            Label4:SetText(uk("Game", uj, t3))
            CA_1, CB_1 = pcall(function()
                return math.floor(tB.Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local CA_2 = CA_1 and CB_1 .. " ms" or "n/a"
            Label:SetText(uk("Ping", CA_2, tS))
            Label2:SetText(uk("Job", CG, tM))
        end
    end)
    uM.Track(function()
        pcall(task.cancel, CJ)
    end)
    local SocialsGroup = tL.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({
        Text = "Discord",
        Func = function()
            tE(uw, "Copied Discord invite")
        end
    })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            tE(ut, "Copied Rscripts profile")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            tE(uo, "Copied website")
        end
    })
end
t5 = {
    WalkSpeedEnabled = false,
    WalkSpeed = 32,
    InfJump = false,
    NoClip = false,
    Fly = false,
    FlySpeed = 60,
    InstantPP = false,
    WalkSnapshots = {},
    NoClipSnapshots = {},
    FlyPlatformStand = nil,
    InfJumpConn = nil,
    NoClipConn = nil,
    FlyConn = nil,
    InstantConn = nil,
    InstantSnapshots = {}
}
FO_21 = function()
    local connection
    connection = nil
    local D4
    D4 = function(k2)
        if not k2 then
            return
        end
        if t5.WalkSnapshots[k2] == nil then
            t5.WalkSnapshots[k2] = k2.WalkSpeed
        end
        if t5.WalkSpeedEnabled then
            k2.WalkSpeed = t5.WalkSpeed
        end
    end
    uM.SetWalkSpeedEnabled = function(k5)
        local CS = k5 and true or false
        t5.WalkSpeedEnabled = CS
        local CR_1 = ul()
        if not CR_1 then
            return
        end
        if t5.WalkSpeedEnabled then
            D4(CR_1)
        elseif t5.WalkSnapshots[CR_1] ~= nil then
            CR_1.WalkSpeed = t5.WalkSnapshots[CR_1]
        end
    end
    uM.SetWalkSpeedValue = function(lc)
        t5.WalkSpeed = lc
        if t5.WalkSpeedEnabled then
            local CX = ul()
            if CX then
                CX.WalkSpeed = lc
            end
        end
    end
    uM.SetInfJump = function(lg)
        local C1 = lg and true or false
        t5.InfJump = C1
        if t5.InfJumpConn then
            t5.InfJumpConn:Disconnect()
            t5.InfJumpConn = nil
        end
        if not t5.InfJump then
            return
        end
        t5.InfJumpConn = tB.UserInputService.JumpRequest:Connect(function()
            local CZ = not up() or not t5.InfJump
            if CZ then
                return
            end
            local CZ_1 = ul()
            if CZ_1 then
                CZ_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
    uM.SetNoClip = function(ls)
        local C8 = ls and true
        local Dc = if C8 then 1 else 0
        local Da = 2124 * Dc + 822 * (1 - Dc)
        local Db = 1673 * Dc + 2767 * (1 - Dc)
        if not ((Da * 2348 + Db * 2645 + Da * Db) % 16777213 == 12965689) then
            C8 = false
        end
        t5.NoClip = C8
        if t5.NoClipConn then
            t5.NoClipConn:Disconnect()
            t5.NoClipConn = nil
        end
        local Character = u2.Character
        if not t5.NoClip then
            for k, v in pairs(t5.NoClipSnapshots) do
                if k and k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(t5.NoClipSnapshots)
            return
        end
        local function C6(lB)
            local C3 = lB:IsA("BasePart") and t5.NoClipSnapshots[lB] == nil
            if C3 then
                t5.NoClipSnapshots[lB] = lB.CanCollide
                lB.CanCollide = false
            end
        end
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                C6(descendant)
            end
            t5.NoClipConn = Character.DescendantAdded:Connect(function(lG)
                if t5.NoClip then
                    C6(lG)
                end
            end)
        end
    end
    uM.SetFly = function(lJ)
        local Dx = lJ and true or false
        t5.Fly = Dx
        if t5.FlyConn then
            t5.FlyConn:Disconnect()
            t5.FlyConn = nil
        end
        local Dw_1 = ul()
        if not t5.Fly then
            if Dw_1 and t5.FlyPlatformStand ~= nil then
                Dw_1.PlatformStand = t5.FlyPlatformStand
            end
            t5.FlyPlatformStand = nil
            return
        end
        if Dw_1 then
            t5.FlyPlatformStand = Dw_1.PlatformStand
            Dw_1.PlatformStand = true
        end
        t5.FlyConn = tB.RunService.RenderStepped:Connect(function()
            local Dp = not up() or not t5.Fly
            if Dp then
                return
            end
            if tB.UserInputService:GetFocusedTextBox() then
                return
            end
            local Dp_1 = uA()
            local CurrentCamera = ui.CurrentCamera
            if not (Dp_1 and CurrentCamera) then
                return
            end
            local Dr_1 = Vector3.zero
            local Dv = if tB.UserInputService:IsKeyDown(Enum.KeyCode.W) then 1 else 0
            if Dv == 1 then
                Dr_1 += CurrentCamera.CFrame.LookVector
            end
            local Dv_1 = if tB.UserInputService:IsKeyDown(Enum.KeyCode.S) then 1 else 0
            if Dv_1 == 1 then
                Dr_1 -= CurrentCamera.CFrame.LookVector
            end
            if tB.UserInputService:IsKeyDown(Enum.KeyCode.A) then
                Dr_1 -= CurrentCamera.CFrame.RightVector
            end
            if tB.UserInputService:IsKeyDown(Enum.KeyCode.D) then
                Dr_1 += CurrentCamera.CFrame.RightVector
            end
            local Dv_2 = if tB.UserInputService:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
            if Dv_2 == 1 then
                Dr_1 += Vector3.yAxis
            end
            if tB.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                Dr_1 -= Vector3.yAxis
            end
            if Dr_1.Magnitude > 0 then
                Dp_1.AssemblyLinearVelocity = Dr_1.Unit * t5.FlySpeed
            else
                Dp_1.AssemblyLinearVelocity = Vector3.zero
            end
        end)
    end
    uM.SetFlySpeed = function(l2)
        t5.FlySpeed = l2
    end
    uM.SetInstantProximityPrompt = function(l4)
        local DP
        local DR = l4 and true or false
        t5.InstantPP = DR
        if t5.InstantConn then
            t5.InstantConn:Disconnect()
            t5.InstantConn = nil
        end
        local function DQ_1()
            for k, v in pairs(t5.InstantSnapshots) do
                if k and k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(t5.InstantSnapshots)
        end
        if not t5.InstantPP then
            DQ_1()
            return
        end
        DP = function(mc)
            if not mc:IsA("ProximityPrompt") then
                return
            end
            if t5.InstantSnapshots[mc] == nil then
                t5.InstantSnapshots[mc] = {
                    HoldDuration = mc.HoldDuration,
                    MaxActivationDistance = mc.MaxActivationDistance,
                    RequiresLineOfSight = mc.RequiresLineOfSight
                }
            end
            mc.HoldDuration = 0
            mc.MaxActivationDistance = 50
            mc.RequiresLineOfSight = false
        end
        for i, descendant in ipairs(ui:GetDescendants()) do
            DP(descendant)
        end
        t5.InstantConn = ui.DescendantAdded:Connect(function(mh)
            if t5.InstantPP then
                DP(mh)
            end
        end)
    end
    local function onCharacterAdded(ml)
        task.defer(function()
            if not up() then
                return
            end
            local Humanoid = ml:WaitForChild("Humanoid", 10)
            if not Humanoid then
                return
            end
            if t5.WalkSpeedEnabled then
                D4(Humanoid)
            end
            if t5.NoClip then
                uM.SetNoClip(true)
            end
            if t5.Fly then
                uM.SetFly(true)
            end
        end)
    end
    if u2.Character then
        onCharacterAdded(u2.Character)
    end
    connection = u2.CharacterAdded:Connect(onCharacterAdded)
    uM.Track(function()
        connection:Disconnect()
    end)
    uM.Track(function()
        uM.SetWalkSpeedEnabled(false)
        uM.SetInfJump(false)
        uM.SetNoClip(false)
        uM.SetFly(false)
        uM.SetInstantProximityPrompt(false)
    end)
end
if (not tL and t3 or (FO_12 or t3)) and ((not FO_12 or tL) and (not FO_12 or false)) or not ((not tL and t3 or (FO_12 or t3)) and ((not FO_12 or tL) and (not FO_12 or false))) then
    ue = {
        AntiAfk = true,
        NoGameplayPaused = true,
        AutoReconnect = false,
        Disable3D = false,
        FpsBoost = false,
        AfkConn = nil,
        AfkTask = nil,
        AfkCount = 0,
        ReconnectConns = {},
        FpsSnapshots = {},
        FpsConn = nil
    }
else
    uC = {
        AntiAfk = true,
        FpsSnapshots = {},
        Disable3D = false,
        ReconnectConns = {},
        AfkCount = 0,
        NoGameplayPaused = true,
        AfkTask = nil,
        AutoReconnect = false,
        AfkConn = nil,
        FpsBoost = false,
        FpsConn = nil
    }
end
FO_16 = function()
    local function nN()
        if not ui.CurrentCamera then
            return false
        end
        local Eh_1 = not ux(tB.VirtualUser.CaptureController) or not ux(tB.VirtualUser.ClickButton2)
        if Eh_1 then
            return false
        end
        local Eh_2 = pcall(function()
            tB.VirtualUser:CaptureController()
            tB.VirtualUser:ClickButton2(Vector2.new())
        end)
        if Eh_2 then
            ue.AfkCount = ue.AfkCount + 1
        end
        return Eh_2
    end
    uM.SetAntiAfk = function(n_)
        local Ev = n_ and true or false
        ue.AntiAfk = Ev
        if ue.AfkConn then
            ue.AfkConn:Disconnect()
            ue.AfkConn = nil
        end
        if ue.AfkTask then
            pcall(task.cancel, ue.AfkTask)
            ue.AfkTask = nil
        end
        if not ue.AntiAfk then
            return
        end
        ue.AfkConn = u2.Idled:Connect(function()
            local Em = up() and ue.AntiAfk
            if Em then
                nN()
            end
        end)
        ue.AfkTask = task.spawn(function()
            local Eo = os.clock()
            while true do
                local Ep = up() and ue.AntiAfk
                if Ep then
                    task.wait(1)
                    local Ep_1 = not up()
                    local Et = if Ep_1 then 1 else 0
                    local Er = 3503 * Et + 515 * (1 - Et)
                    local Es = 1013 * Et + 2544 * (1 - Et)
                    if not ((Er * 2967 + Es * 3864 + Er * Es) % 16777213 == 1078959) then
                        Ep_1 = not ue.AntiAfk
                    end
                    if Ep_1 then
                        break
                    end
                    if os.clock() - Eo >= 60 then
                        Eo = os.clock()
                        nN()
                    end
                    continue
                end
                break
            end
        end)
    end
    uM.SetNoGameplayPaused = function(oh)
        local EB = oh and true or false
        ue.NoGameplayPaused = EB
    end
    uM.SetAutoReconnect = function(oj)
        local EG = oj and true
        local EK = if EG then 1 else 0
        local EI = 2556 * EK + 531 * (1 - EK)
        local EJ = 1866 * EK + 2940 * (1 - EK)
        if not ((EI * 2056 + EJ * 318 + EI * EJ) % 16777213 == 10618020) then
            EG = false
        end
        ue.AutoReconnect = EG
        for i, v in ipairs(ue.ReconnectConns) do
            v:Disconnect()
        end
        table.clear(ue.ReconnectConns)
        if not ue.AutoReconnect then
            return
        end
        table.insert(ue.ReconnectConns, tB.TeleportService.TeleportInitFailed:Connect(function()
            local ED = not up() or not ue.AutoReconnect
            if ED then
                return
            end
            task.wait(1)
            local ED_1 = up() and ue.AutoReconnect
            if ED_1 then
                pcall(function()
                    tB.TeleportService:Teleport(game.PlaceId, u2)
                end)
            end
        end))
    end
    uM.SetDisable3D = function(oB)
        local ES = oB and true or false
        ue.Disable3D = ES
        pcall(function()
            tB.RunService:Set3dRenderingEnabled(not ue.Disable3D)
        end)
    end
    uM.SetFpsBoost = function(oG)
        local Fg
        local Fi = oG and true
        local Fm = if Fi then 1 else 0
        local Fk = 3249 * Fm + 3021 * (1 - Fm)
        local Fl = 2212 * Fm + 1015 * (1 - Fm)
        if not ((Fk * 343 + Fl * 3814 + Fk * Fl) % 16777213 == 16737763) then
            Fi = false
        end
        ue.FpsBoost = Fi
        if ue.FpsConn then
            ue.FpsConn:Disconnect()
            ue.FpsConn = nil
        end
        local function Fh_1()
            for k, v in pairs(ue.FpsSnapshots) do
                local EZ = k
                if EZ and EZ.Parent then
                    for k, v in pairs(v) do
                        local E4 = k
                        local E6 = v
                        pcall(function()
                            EZ[E4] = E6
                        end)
                    end
                end
            end
            table.clear(ue.FpsSnapshots)
        end
        if not ue.FpsBoost then
            Fh_1()
            return
        end
        Fg = function(oT)
            if ue.FpsSnapshots[oT] then
                return
            end
            local E7 = oT:IsA("ParticleEmitter") or oT:IsA("Trail")
            local Fb = if E7 then 1 else 0
            local E9 = 2593 * Fb + 2628 * (1 - Fb)
            local Fa = 1532 * Fb + 2746 * (1 - Fb)
            if not ((E9 * 776 + Fa * 3559 + E9 * Fa) % 16777213 == 11437032) then
                E7 = oT:IsA("Beam")
            end
            if not E7 then
                E7 = oT:IsA("Fire")
            end
            if not E7 then
                E7 = oT:IsA("Smoke")
            end
            if not E7 then
                E7 = oT:IsA("Sparkles")
            end
            if E7 then
                ue.FpsSnapshots[oT] = { Enabled = oT.Enabled }
                oT.Enabled = false
            end
        end
        for i, descendant in ipairs(ui:GetDescendants()) do
            Fg(descendant)
        end
        if ue.FpsSnapshots[tB.Lighting] == nil then
            ue.FpsSnapshots[tB.Lighting] = { GlobalShadows = tB.Lighting.GlobalShadows, FogEnd = tB.Lighting.FogEnd }
            tB.Lighting.GlobalShadows = false
        end
        ue.FpsConn = ui.DescendantAdded:Connect(function(o_)
            if ue.FpsBoost then
                Fg(o_)
            end
        end)
    end
    uM.Track(function()
        uM.SetAntiAfk(false)
        uM.SetAutoReconnect(false)
        uM.SetDisable3D(false)
        uM.SetFpsBoost(false)
    end)
end
FO_12 = function()
    uQ(tL.Settings)
    local MenuGroup = tL.Settings:AddLeftGroupbox("Menu", "settings")
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    MenuGroup:AddToggle("NoGameplayPaused", { Text = "No Gameplay Paused", Default = true })
    MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
    MenuGroup:AddToggle("Disable3DRendering", { Text = "Disable 3D Rendering", Default = false })
    MenuGroup:AddToggle("FPSBoost", { Text = "FPS Boost", Default = false })
    MenuGroup:AddToggle("HideUIOnStart", { Text = "Hide UI On Start", Default = false })
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    local ScriptGroup = tL.Settings:AddLeftGroupbox("Script", "scroll-text")
    ScriptGroup:AddButton({
        Text = "Unload Script",
        Func = function()
            Library:Unload()
        end
    })
    Toggles.AntiAfk:OnChanged(function(pc)
        uM.SetAntiAfk(pc)
    end)
    Toggles.NoGameplayPaused:OnChanged(function(pf)
        uM.SetNoGameplayPaused(pf)
    end)
    Toggles.AutoReconnect:OnChanged(function(ph)
        uM.SetAutoReconnect(ph)
    end)
    Toggles.Disable3DRendering:OnChanged(function(pj)
        uM.SetDisable3D(pj)
    end)
    Toggles.FPSBoost:OnChanged(function(pl)
        uM.SetFpsBoost(pl)
    end)
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("MyScriptHub")
    ThemeManager:SaveDefault("Evil Hello Kitty")
    ThemeManager:ApplyToTab(tL.Settings)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    SaveManager:SetFolder("TempoHub/StealFromTheRich")
    local FG_2 = SaveManager:BuildConfigSection(tL.Settings)
    if FG_2 then
        FG_2:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Default = "", Finished = true, AllowEmpty = true })
        FG_2:AddButton({
            Text = "Export Config to Clipboard",
            Func = function()
                local Fv_1
                local Fu_1
                Fu_1, Fv_1 = pcall(function()
                    if ux(SaveManager.ExportConfig) then
                        return SaveManager:ExportConfig()
                    end
                    error("ExportConfig unavailable")
                end)
                local Fw = Fu_1 and type(Fv_1) == "string"
                if Fw then
                    tE(Fv_1, "Copied config")
                else
                    Library:Notify("Export unavailable", 3)
                end
            end
        })
        FG_2:AddButton({
            Text = "Import Config from Clipboard Text",
            Func = function()
                local FC
                FC = Options.SaveManager_ImportSource and Options.SaveManager_ImportSource.Value or ""
                if FC == "" then
                    Library:Notify("Paste a config first", 3)
                    return
                end
                local FD_1 = pcall(function()
                    local FB = if ux(SaveManager.ImportConfig) then 1 else 0
                    if FB == 1 then
                        SaveManager:ImportConfig(FC)
                    elseif ux(SaveManager.LoadConfigFromJSON) then
                        SaveManager:LoadConfigFromJSON(FC)
                    else
                        error("Import unavailable")
                    end
                end)
                if FD_1 then
                    Options.SaveManager_ImportSource:SetValue("")
                    Library:Notify("Imported config", 3)
                else
                    Library:Notify("Import failed", 3)
                end
            end
        })
    end
    pcall(function()
        ThemeManager:LoadDefault()
    end)
    pcall(function()
        SaveManager:LoadAutoloadConfig()
    end)
end
FO_21()
FO_16()
FO_11()
fn58()
fns.fn27()
FO_12()
uM.SetAntiAfk(Toggles.AntiAfk.Value)
uM.SetNoGameplayPaused(Toggles.NoGameplayPaused.Value)
if Toggles.HideUIOnStart.Value then
    pcall(function()
        Library:Toggle(false)
    end)
end
FO_18 = 1
repeat
    FO_2 = {
        "icebmoqwb",
        "srocmjbvv",
        "gdiejg",
        "lya",
        "qdnose",
        "pcow",
        "neieb",
        "llgotnieop",
        "hat",
        "ugdnex",
        "vqei",
        "iacducwzmoh",
        "tvkuk"
    }
    if FO_2[(FO_18 * 81 + 51) % 13 + 1] < FO_2[(FO_18 * 81 + 51) % 13 + 1] then
        vj:Notify("Steal From The Rich " .. Library .. " loaded", 4)
    else
        Library:Notify("Steal From The Rich v0.5 loaded", 4)
    end
    FO_18 = (FO_18 + 4) % 8
until (FO_18 * 3 + 6) % 8 == 5
end)(...)

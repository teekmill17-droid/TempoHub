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
getgenv().TempoHoodSubtitle = "FISH AN ANIME RNG"
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
local Constants
local A5
local BC
local BQ
local BT
local B3
local A3
local BW
local BA
local Options
local BO
local BL
local Library
local Toggles
local Be
local Bn
local LocalPlayer
local BZ
local Bq
local B7
local Bk
local Bi
local BP
local BG
local Ba
local Bl
local Bf
local function fn78()
    local EO = BT()
    if not EO then
        return
    end
    local EQ = Options.AutoFeedMode and Options.AutoFeedMode.Value
    local E2 = if EQ then 1 else 0
    local E0 = 113 * E2 + 2003 * (1 - E2)
    local E1 = 3906 * E2 + 1775 * (1 - E2)
    if not ((E0 * 3136 + E1 * 109 + E0 * E1) % 16777213 == 1221500) then
        EQ = "Level Up"
    end
    local EP_2 = Be[EQ] or "LevelUpPrompt"
    local EQ_2 = EP_2 == "LevelUp10Prompt" and LocalPlayer:GetAttribute("Rsh_B9") ~= true
    if EQ_2 then
        EP_2 = "LevelUpPrompt"
    end
    local EQ_3 = B3("AutoFeedRarities")
    local ER = next(EQ_3) ~= nil
    local ES = Bk()
    local ET = Bq()
    if not ET then
        return
    end
    local CFrame = ET.CFrame
    BO = true
    for i, descendant in EO:GetDescendants() do
        if descendant:GetAttribute("IsPlacedCharacter") == true then
            local EV = descendant:GetAttribute("Rarity") or ""
            local EW = tostring(EV)
            if not ER or EQ_3[EW] then
                local EV_2 = Bf(EO, descendant:GetAttribute("StandId"))
                local EW_1 = EV_2 and EV_2:FindFirstChild("PromptNode_Pickup")
                local EX = EW_1
                if EW_1 then
                    EW_1 = EX:FindFirstChild(EP_2)
                end
                local EY = EW_1
                if EW_1 then
                    EW_1 = EY:IsA("ProximityPrompt")
                end
                if EW_1 then
                    EW_1 = EY:GetAttribute("ServerEnabled") ~= false
                end
                if EW_1 then
                    local EW_2 = BG(EY.ActionText)
                    if EW_2 <= 0 or ES >= EW_2 then
                        local EZ_1 = EV_2:FindFirstChild("PromptPart")
                        local EV_3 = EZ_1 and EZ_1:IsA("BasePart")
                        if not EV_3 then
                            EZ_1 = EX:FindFirstChildWhichIsA("BasePart")
                        end
                        local EV_4 = EZ_1 and EZ_1:IsA("BasePart")
                        local EX_1 = not EV_4
                        if EX_1 ~= false then
                            EX_1 = EY.Parent
                        end
                        if EX_1 then
                            EX_1 = EY.Parent:IsA("BasePart")
                        end
                        if EX_1 then
                            EZ_1 = EY.Parent
                        end
                        if EZ_1 then
                            ET.CFrame = EZ_1.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.05)
                        end
                        BZ(EY, true)
                        if EW_2 > 0 then
                            ES -= EW_2
                        end
                        task.wait(0.15)
                    end
                end
            end
        end
    end
    if ET.Parent then
        ET.CFrame = CFrame
    end
    BO = false
end
local function fn98(g0)
    local DiscordGroup = g0:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = BW })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = BW })
end
local function fn122(bO)
    local Touch = bO:FindFirstChild("Touch", true)
    local D_ = Touch and Touch:IsA("BasePart")
    if D_ then
        return Touch
    end
    local Part = bO:FindFirstChild("Part", true)
    local D__1 = Part and Part:IsA("BasePart")
    if D__1 then
        return Part
    end
    return nil
end
local function fn153(bU, bV)
    local D1 = bV
    local D7 = if D1 then 1 else 0
    local D5 = 1145 * D7 + 3459 * (1 - D7)
    local D6 = 716 * D7 + 3948 * (1 - D7)
    if not ((D5 * 1746 + D6 * 2564 + D5 * D6) % 16777213 == 4654814) then
        D1 = ""
    end
    local D2 = tostring(D1)
    if D2 == "" then
        return true
    elseif bU:FindFirstChild(D2, true) then
        return true
    else
        local Purchases = bU:FindFirstChild("Purchases")
        local D3 = Purchases and Purchases:FindFirstChild(D2)
        if D3 then
            return true
        end
        return false
    end
end
local function fn185()
    local Es = tonumber(LocalPlayer:GetAttribute("FoodNumber")) or 0
    return Es
end
local function fn284(ab)
    local CX = {}
    local CY = {}
    local C0 = (Constants[ab] or {}).Offers or {}
    local C0_2
    local C1 = (Constants.Potions or {}).Definitions or {}
    for k, v in C0 do
        if v.Kind == "Potion" and v.PotionKey then
            local CZ_4 = C1[v.PotionKey]
            C0_2 = CZ_4 and CZ_4.ToolName or v.PotionKey
        elseif v.Kind == "Character" then
            C0_2 = "Random Character"
        elseif v.Kind == "Ability" then
            C0_2 = v.AbilityName or v.RodName or k
        elseif v.Kind == "BackpackStorage" then
            C0_2 = "Backpack Storage"
        elseif v.Kind == "Crate" then
            C0_2 = v.CrateKey or "Crate"
        else
            C0_2 = v.Kind or k
        end
        if CX[C0_2] then
            C0_2 = C0_2 .. " (" .. tostring(k) .. ")"
        end
        CY[#CY + 1] = C0_2
        CX[C0_2] = k
    end
    table.sort(CY)
    return CY, CX
end
local function fn350(a0)
    local Dd = Toggles[a0]
    return Dd and Dd.Value == true
end
local function fn353()
    local Character = LocalPlayer.Character
    local Dt = Character and Character:FindFirstChild("HumanoidRootPart")
    return Dt
end
local function fn416(aM, aN)
    return string.format('<font color="%s">%s</font>', aN, aM)
end
local function fn446(eX, eY)
    local GG = not eY or not eY:IsA("BasePart")
    local GM = if GG then 1 else 0
    local GK = 2570 * GM + 2677 * (1 - GM)
    local GL = 1708 * GM + 2267 * (1 - GM)
    if not ((GK * 2186 + GL * 2695 + GK * GL) % 16777213 == 14610640) then
        GG = typeof(eX) ~= "Vector3"
    end
    if GG then
        return math.huge
    end
    local GG_1 = eY.CFrame:PointToObjectSpace(eX)
    local GH = eY.Size * 0.5
    local GI = Vector3.new(math.clamp(GG_1.X, -GH.X, GH.X), math.clamp(GG_1.Y, -GH.Y, GH.Y), math.clamp(GG_1.Z, -GH.Z, GH.Z))
    return (GG_1 - GI).Magnitude
end
local function fn456(b0)
    local D8 = A5(b0)
    local D9 = Bq()
    if not D8 or not D9 or not b0.Parent then
        return false
    end
    local TimeToUnlock = b0:FindFirstChild("TimeToUnlock")
    local Eb = TimeToUnlock and TimeToUnlock.Value
    local Ea_2 = Bi(Eb) + 5
    BO = true
    local Eb_1 = os.clock()
    while true do
        local Ec = b0.Parent and not Library.Unloaded and A3("AutoBuyUnlockButtons") and os.clock() - Eb_1 < Ea_2
        if Ec then
            local D9_1 = Bq()
            if not D9_1 then
                break
            end
            local Ec_1 = BA()
            if Ec_1 then
                Ec_1.Sit = false
                Ec_1.PlatformStand = false
            end
            D9_1.CFrame = CFrame.new(D8.Position + Vector3.new(0, 3, 0))
            D9_1.AssemblyLinearVelocity = Vector3.zero
            if firetouchinterest then
                pcall(firetouchinterest, D9_1, D8, 0)
                pcall(firetouchinterest, D9_1, D8, 1)
            end
            task.wait(0.15)
            continue
        end
        break
    end
    local D8_1 = b0.Parent == nil
    BO = false
    return D8_1
end
local function fn476(bE)
    local DN = Bq()
    local DO = not DN
    local DS = if DO then 1 else 0
    local DQ = 1497 * DS + 3231 * (1 - DS)
    local DR = 868 * DS + 3898 * (1 - DS)
    if not ((DQ * 3583 + DR * 3198 + DQ * DR) % 16777213 == 9439011) then
        DO = not bE
    end
    if not DO then
        DO = not bE:IsA("BasePart")
    end
    if DO then
        return
    end
    if firetouchinterest then
        pcall(firetouchinterest, DN, bE, 0)
        pcall(firetouchinterest, DN, bE, 1)
        return
    end
    local CFrame = DN.CFrame
    DN.CFrame = bE.CFrame + Vector3.new(0, 3, 0)
    task.wait(0.05)
    DN.CFrame = CFrame
end
local function fn578()
    local PlayerPlots = BP:FindFirstChild("PlayerPlots")
    if not PlayerPlots then
        return nil
    end
    for i, child in PlayerPlots:GetChildren() do
        if child:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            return child
        end
    end
    return nil
end
local function fn643(fg)
    local GY = fg
    while true do
        if not (GY and GY ~= BP) then
            return false
        end
        local GZ_1 = string.lower(GY.Name)
        local G__1 = string.find(GZ_1, "lava", 1, true) or string.find(GZ_1, "kill", 1, true)
        if G__1 then
            break
        end
        GY = GY.Parent
    end
    return true
end
local function fn644()
    pcall(function()
        Bn.FishingAutoFishEnabledSync:FireServer(false)
    end)
    pcall(function()
        if type(_G.__AF_SetForcedAutoFish) == "function" then
            _G.__AF_SetForcedAutoFish(false)
        end
    end)
end
local function fn675(cq)
    local Eo_1
    local Em = cq or ""
    local Em_1
    local En = tostring(Em)
    Eo_1, Em_1 = En:match("(%d+%.?%d*)([KMBkmb]?)%s*Food")
    if not Eo_1 then
        return 0
    end
    local En_1 = 1
    local Eq = Em_1 or ""
    local Em_2 = string.upper(Eq)
    if Em_2 == "K" then
        En_1 = 1000
    elseif Em_2 == "M" then
        En_1 = 1000000
    elseif Em_2 == "B" then
        En_1 = 1000000000
    end
    local Em_3 = tonumber(Eo_1) or 0
    return Em_3 * En_1
end
local function fn756()
    local F0_1
    local F__1
    local FY = Bq()
    local FY_1 = FY and FY.Position or Vector3.zero
    F0_1, F__1 = nil, nil
    local Scripted = BP:FindFirstChild("Scripted")
    local F1 = Scripted and Scripted:FindFirstChild("PondAreas")
    if F1 then
        for i, descendant in F1:GetDescendants() do
            local FY_4 = descendant:IsA("BasePart") and Bl[descendant.Name]
            if FY_4 then
                local Magnitude = (descendant.Position - FY_1).Magnitude
                if not F__1 or Magnitude < F__1 then
                    F0_1 = descendant
                    F__1 = Magnitude
                end
            end
        end
    end
    if F0_1 then
        return F0_1
    end
    for i, descendant in BP:GetDescendants() do
        local FY_6 = descendant:IsA("BasePart") and Bl[descendant.Name]
        if FY_6 then
            local Magnitude = (descendant.Position - FY_1).Magnitude
            if not F__1 or Magnitude < F__1 then
                F0_1 = descendant
                F__1 = Magnitude
            end
        end
    end
    return F0_1
end
local function fn837()
    return Bn.GemStoreGetState:InvokeServer()
end
local function fn841(dk)
    if not dk then
        return 0
    end
    local E9 = tonumber(dk:GetAttribute("RodStrength"))
    if E9 then
        return E9
    end
    local E9_3 = ((Constants.Fishing or {}).Rods or {})[dk.Name]
    local Fa_1 = E9_3 and E9_3.Strength
    local E9_4 = tonumber(Fa_1) or 0
    return E9_4
end
local function fn869(bt)
    if type(bt) == "number" then
        return bt
    end
    local DB = bt or ""
    local DC = tostring(DB):gsub(",", ""):gsub("%s", ""):upper()
    if DC == "" then
        return 0
    end
    local DB_1 = 1
    local DD = DC:sub(-1)
    if DD == "K" then
        DB_1 = 1000
        DC = DC:sub(1, -2)
    elseif DD == "M" then
        DB_1 = 1000000
        DC = DC:sub(1, -2)
    elseif DD == "B" then
        DB_1 = 1000000000
        DC = DC:sub(1, -2)
    elseif DD == "T" then
        DB_1 = 1000000000000
        DC = DC:sub(1, -2)
    end
    local DD_1 = tonumber(DC) or 0
    return DD_1 * DB_1
end
local function fn925(cz, cA)
    local Eu = cA or ""
    local Ev = tostring(Eu)
    if Ev == "" or not cz then
        return nil
    end
    local Eu_2 = cz:FindFirstChild(Ev)
    local Ew_1 = Eu_2 and Eu_2:FindFirstChild("PromptNode_Pickup")
    if Ew_1 then
        return Eu_2
    end
    local Purchases = cz:FindFirstChild("Purchases")
    if Purchases then
        local Ew_2 = Purchases:FindFirstChild(Ev)
        local Ex_1 = Ew_2 and Ew_2:FindFirstChild("PromptNode_Pickup")
        if Ex_1 then
            return Ew_2
        end
        for i, child in Purchases:GetChildren() do
            if child:FindFirstChild("PromptNode_Pickup") then
                local Eu_4 = child:GetAttribute("StandId") or child.Name
                local Ew_3 = tostring(Eu_4)
                if Ew_3 == Ev or child.Name == Ev then
                    return child
                end
            end
        end
        for i, descendant in cz:GetDescendants() do
            if descendant.Name == "PromptNode_Pickup" then
                local Parent = descendant.Parent
                local Ew_4 = Parent
                if Ew_4 then
                    local Ex_2 = Parent:GetAttribute("StandId") or Parent.Name
                    Ew_4 = tostring(Ex_2) == Ev
                end
                if Ew_4 then
                    return Parent
                end
            end
        end
        return nil
    end
    for i, descendant in cz:GetDescendants() do
        if descendant.Name == "PromptNode_Pickup" then
            local Parent = descendant.Parent
            local Ew_5 = Parent
            if Ew_5 then
                local Ex_3 = Parent:GetAttribute("StandId") or Parent.Name
                Ew_5 = tostring(Ex_3) == Ev
            end
            if Ew_5 then
                return Parent
            end
        end
    end
    return nil
end
local function fn933(aP, aQ, aR)
    return string.format("<b>%s</b> %s %s", aP, BQ("-", "#5a6070"), BQ(aQ, aR))
end
local function fn969(gJ, gK)
    if not gJ then
        return nil
    end
    local H0 = gK + 1
    if gJ.MaxLevels and H0 > gJ.MaxLevels then
        return nil
    elseif gJ.Costs then
        local H1_1 = gJ.Costs[tostring(H0)] or gJ.Costs[H0]
        return H1_1
    else
        local H1_2 = type(gJ.CostAnchors) == "table" and #gJ.CostAnchors >= 2
        if H1_2 then
            local CostAnchors = gJ.CostAnchors
            local H2_1 = 1
            while true do
                if H2_1 < #CostAnchors - 1 and CostAnchors[H2_1 + 1][1] < H0 then
                    H2_1 += 1
                    continue
                end
                break
            end
            local H3_2 = CostAnchors[H2_1][1]
            local H4 = CostAnchors[H2_1][2]
            local H5 = CostAnchors[H2_1 + 1][1]
            local H6 = CostAnchors[H2_1 + 1][2]
            if H3_2 < H5 and H4 > 0 then
                return math.floor(H4 * ((H6 / H4) ^ (1 / (H5 - H3_2))) ^ (H0 - H3_2))
            elseif gJ.CostBase then
                local H1_5 = gJ.CostScale or 2
                return math.floor(gJ.CostBase * H1_5 ^ (H0 - 1))
            else
                return nil
            end
        elseif gJ.CostBase then
            local H1_6 = gJ.CostScale or 2
            return math.floor(gJ.CostBase * H1_6 ^ (H0 - 1))
        else
            return nil
        end
    end
end
local function fn1043()
    local Dz = tonumber(LocalPlayer:GetAttribute("Rebirths")) or 0
    return Dz
end
local function fn1053()
    local Character = LocalPlayer.Character
    local Dq = Character and Character:FindFirstChildOfClass("Humanoid")
    return Dq
end
local function fn1109()
    local Character = LocalPlayer.Character
    if not Character then
        return nil
    end
    for i, child in Character:GetChildren() do
        local Fe_1 = child:IsA("Tool") and child:GetAttribute("IsFishingRod") == true
        if Fe_1 then
            return child
        end
    end
    local Ff = Constants.Fishing or {}
    local Fe_3 = {}
    local Fg = Ff.Rods
    local Fq = if Fg then 1 else 0
    local Fo = 952 * Fq + 384 * (1 - Fq)
    local Fp = 3462 * Fq + 3449 * (1 - Fq)
    if not ((Fo * 2397 + Fp * 2637 + Fo * Fp) % 16777213 == 14707062) then
        Fg = Fe_3
    end
    local Fe_4 = Fg
    for i, child in Character:GetChildren() do
        local Fd_1 = child:IsA("Tool") and Fe_4[child.Name] ~= nil
        if Fd_1 then
            return child
        end
    end
    return nil
end
local function fn1129()
    local Dv = tonumber(LocalPlayer:GetAttribute("CashNumber")) or 0
    return Dv
end
local function fn1191(bK)
    local DT = bK or ""
    local DU = tostring(DT):gsub("%s", ""):lower()
    if DU == "" then
        return 5
    end
    local DT_1 = tonumber((DU:match("^(%d+%.?%d*)")))
    if not DT_1 then
        return 5
    end
    local DY = if DU:find("h", 1, true) then 1 else 0
    if DY == 1 then
        return math.max(1, DT_1 * 3600)
    elseif DU:find("m", 1, true) then
        return math.max(1, DT_1 * 60)
    else
        return math.max(1, DT_1)
    end
end
local function fn1220(a5)
    local Dg = Options[a5]
    local Dh = Dg and Dg.Value
    if type(Dh) ~= "table" then
        return {}
    end
    local Dh_1 = {}
    for k, v in Dh do
        if v == true then
            Dh_1[k] = true
        else
            local Dg_2 = type(k) == "number" and type(v) == "string"
            if Dg_2 then
                Dh_1[v] = true
            end
        end
    end
    return Dh_1
end
local function fn1222()
    B7(BC, "Copied Discord invite to clipboard")
end
local function fn1269(aF, aG)
    if setclipboard then
        setclipboard(aF)
    elseif toclipboard then
        toclipboard(aF)
    end
    Library:Notify(aG)
end
local function fn1270(gD)
    local HY = Bq()
    local HY_1 = HY and HY.Position or nil
    return Ba(gD, HY_1)
end
local function fn1303(e7, e8)
    if not e7 then
        return nil
    end
    local GN = e8
    local GU = if GN then 1 else 0
    local GS = 2145 * GU + 3320 * (1 - GU)
    local GT = 1931 * GU + 3857 * (1 - GU)
    if not ((GS * 430 + GT * 588 + GS * GT) % 16777213 == 6199773) then
        GN = e7.Position
    end
    local GO = GN
    local GN_1 = e7.CFrame:PointToObjectSpace(GO)
    local GO_1 = e7.Size * 0.5
    local GP = math.clamp(GN_1.X, -GO_1.X * 0.85, GO_1.X * 0.85)
    local GQ = math.clamp(GN_1.Z, -GO_1.Z * 0.85, GO_1.Z * 0.85)
    if math.abs(GN_1.X) > GO_1.X then
        GP = math.clamp(GN_1.X, -GO_1.X, GO_1.X) * 0.7
    end
    if math.abs(GN_1.Z) > GO_1.Z then
        GQ = math.clamp(GN_1.Z, -GO_1.Z, GO_1.Z) * 0.7
    end
    return e7.CFrame:PointToWorldSpace(Vector3.new(GP, GO_1.Y + 0.5, GQ))
end
local function fn1428(dY)
    local FU_2 = ((Constants.Fishing or {}).Ponds or {})[dY.Name]
    local FV_1 = FU_2 and FU_2.RequiredStrength
    local FU_3 = tonumber(FV_1) or 0
    return FU_3
end
local function fn1479()
    local Dx = tonumber(LocalPlayer:GetAttribute("GemsNumber")) or 0
    return Dx
end
Options = nil
Toggles = nil
A3 = nil
A5 = nil
Library = nil
Ba = nil
Be = nil
Bf = nil
Bi = nil
Bk = nil
Bl = nil
Bn = nil
Bq = nil
Constants = nil
BA = nil
BC = nil
BG = nil
local Players, AV, AX, AY, A_, A0, A1, SaveManager, A4, ThemeManager, A7, A8, Bb, Bc, Bd, Bg, Bh, Bj, Bm, Bo, Bp, Bs, Bt, Bu, Bv, Bw, Bx, By, Bz, BB, BD, BE, BF
LocalPlayer = nil
BL = nil
BO = nil
BP = nil
BQ = nil
BT = nil
BW = nil
BZ = nil
B3 = nil
B7 = nil
local BH, BI, BK, BM, Lighting, BR, BS, GuiService, HttpService, BX, VirtualUser, B_, UserInputService, B1, B2, B4, RunService, B6, Cg, Ch, Ci
local Cf_1
Players, RunService, UserInputService, VirtualUser, HttpService, GuiService, BR, BP, Lighting, LocalPlayer, BE, BC, Bz, Bx, Constants, Bn = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if (BR and BR and (Players or not LocalPlayer) or "https://discord.gg/K7Qxnxkk46" and (not Players and not BR)) and not (BR and BR and (Players or not LocalPlayer) or "https://discord.gg/K7Qxnxkk46" and (not Players and not BR)) then
    game:GetService("Players")
else
    Players = game:GetService("Players")
end
local ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
if Players and not VirtualUser or "https://discord.gg/K7Qxnxkk46" or not Players and VirtualUser and (false and not VirtualUser) or (not Players and LocalPlayer and (false or LocalPlayer) or (BC or LocalPlayer) and (not LocalPlayer and not VirtualUser)) or "https://discord.gg/K7Qxnxkk46" and (not VirtualUser or VirtualUser) and (LocalPlayer or not Players or BC and VirtualUser) and (VirtualUser and false and (not Players and Players) and (not Players and BC or Players and LocalPlayer)) or not (Players and not VirtualUser or "https://discord.gg/K7Qxnxkk46" or not Players and VirtualUser and (false and not VirtualUser) or (not Players and LocalPlayer and (false or LocalPlayer) or (BC or LocalPlayer) and (not LocalPlayer and not VirtualUser)) or "https://discord.gg/K7Qxnxkk46" and (not VirtualUser or VirtualUser) and (LocalPlayer or not Players or BC and VirtualUser) and (VirtualUser and false and (not Players and Players) and (not Players and BC or Players and LocalPlayer))) then
    BR = game:GetService("TeleportService")
    BP = game:GetService("Workspace")
else
    BP = game:GetService("TeleportService")
    BR = game:GetService("Workspace")
end
Lighting = game:GetService("Lighting")
LocalPlayer = Players.LocalPlayer
BE = "Fish an Anime RNG"
BC = "https://discord.gg/K7Qxnxkk46"
Bz = "https://discord.gg/K7Qxnxkk46"
Bx = "https://tempohub.shop"
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
Constants = require(ReplicatedStorage:WaitForChild("Constants"))
Bn = {
    FishingRequestStart = Remotes:WaitForChild("FishingRequestStart"),
    FishingClick = Remotes:WaitForChild("FishingClick"),
    FishingAutoFishEnabledSync = Remotes:WaitForChild("FishingAutoFishEnabledSync"),
    FishingAutoFishPurchase = Remotes:WaitForChild("FishingAutoFishPurchase"),
    FishingStoreGetState = Remotes:WaitForChild("FishingStoreGetState"),
    FishingStorePurchase = Remotes:WaitForChild("FishingStorePurchase"),
    SetAutoCollectState = Remotes:WaitForChild("SetAutoCollectState"),
    UpgradesStoreGetState = Remotes:WaitForChild("UpgradesStoreGetState"),
    UpgradesStorePurchase = Remotes:WaitForChild("UpgradesStorePurchase"),
    GemStoreGetState = Remotes:WaitForChild("GemStoreGetState"),
    GemStorePurchase = Remotes:WaitForChild("GemStorePurchase"),
    BoostsStoreGetState = Remotes:WaitForChild("BoostsStoreGetState"),
    BoostsStorePurchase = Remotes:WaitForChild("BoostsStorePurchase"),
    PotionGetState = Remotes:WaitForChild("PotionGetState"),
    PotionUse = Remotes:WaitForChild("PotionUse"),
    SecretStoreGetState = Remotes:WaitForChild("SecretStoreGetState"),
    SecretStorePurchase = Remotes:WaitForChild("SecretStorePurchase"),
    SecretStore2GetState = Remotes:WaitForChild("SecretStore2GetState"),
    SecretStore2Purchase = Remotes:WaitForChild("SecretStore2Purchase"),
    SecretStore3GetState = Remotes:WaitForChild("SecretStore3GetState"),
    SecretStore3Purchase = Remotes:WaitForChild("SecretStore3Purchase"),
    ResearchGetData = Remotes:WaitForChild("ResearchGetData"),
    ResearchStart = Remotes:WaitForChild("ResearchStart"),
    RarityAutoSellGetState = Remotes:WaitForChild("RarityAutoSellGetState"),
    RarityAutoSellSet = Remotes:WaitForChild("RarityAutoSellSet"),
    BackpackSellAllRequest = Remotes:WaitForChild("BackpackSellAllRequest"),
    BackpackSellRarityRequest = Remotes:WaitForChild("BackpackSellRarityRequest"),
    BackpackSellSelectedRequest = Remotes:WaitForChild("BackpackSellSelectedRequest"),
    BackpackCharSummaryGet = Remotes:WaitForChild("BackpackCharSummaryGet"),
    BackpackEquipBest = Remotes:WaitForChild("BackpackEquipBest"),
    BackpackHoldCharacter = Remotes:WaitForChild("BackpackHoldCharacter"),
    RebirthGetState = Remotes:WaitForChild("RebirthGetState"),
    RebirthPurchase = Remotes:WaitForChild("RebirthPurchase"),
    IndexGetData = Remotes:WaitForChild("IndexGetData"),
    IndexClaimAllRewards = Remotes:WaitForChild("IndexClaimAllRewards"),
    DepolarizrConfirm = Remotes:WaitForChild("DepolarizrConfirm"),
    DepolarizrUI = Remotes:WaitForChild("DepolarizrUI"),
    SacrificeRequest = Remotes:WaitForChild("SacrificeRequest"),
    Spin = Remotes:WaitForChild("Spin"),
    ShowCatchReward = Remotes:WaitForChild("ShowCatchReward"),
    FishingState = Remotes:WaitForChild("FishingState"),
    TeleportRequest = Remotes:WaitForChild("TeleportRequest"),
    GetSettingsData = Remotes:WaitForChild("GetSettingsData"),
    SetPerformanceModeSetting = Remotes:WaitForChild("SetPerformanceModeSetting"),
    SetCharacterVfxSetting = Remotes:WaitForChild("SetCharacterVfxSetting"),
    SetStarsSetting = Remotes:WaitForChild("SetStarsSetting"),
    SetViewportsSetting = Remotes:WaitForChild("SetViewportsSetting"),
    SetCharacterRenderSetting = Remotes:WaitForChild("SetCharacterRenderSetting")
}
local B9 = Constants.RarityOrder or {
    "Common",
    "Uncommon",
    "Rare",
    "Epic",
    "Legendary",
    "Mythical",
    "Cosmic",
    "Secret",
    "Rainbow",
    "Ascended",
    "Divine",
    "Supreme",
    "Celestial",
    "Ancient",
    "God",
    "Omniscient",
    "Exclusive"
}
local B9_3
Be, A8, A1 = nil, nil, nil
local Cd = { "Level Up", "Level Up 10", "Max Level Up" }
Be = {
    ["Level Up"] = "LevelUpPrompt",
    ["Level Up 10"] = "LevelUp10Prompt",
    ["Max Level Up"] = "MaxLevelUpPrompt"
}
A8 = {
    Common = 9807270,
    Uncommon = 5763719,
    Rare = 3447003,
    Epic = 10181046,
    Legendary = 15844367,
    Mythical = 15105570,
    Cosmic = 1752220,
    Secret = 10038562,
    Rainbow = 15277667,
    God = 16766720
}
local Cc = {}
A1 = {}
local Cb = (Constants.UpgradesStore or {}).Offers or {}
for k, v in Cb do
    local B8_5 = v.Label or k
    Cc[#Cc + 1] = B8_5
    A1[B8_5] = k
end
table.sort(Cc)
local B8_6 = {}
Ch, B9_3, Cg, Cf_1 = nil, nil, nil, nil
local Cb_1 = 9
repeat
    Ci = (Cb_1 * 1 + 1) % 3 + 1
    if Ci <= 2 then
        if Ci <= 1 then
            Ci = (vector.create((Cb_1 * 5 + 7) % 11 + 1, (Cb_1 * 7 + 3) % 13 + 1, (Cb_1 * 2 + 9) % 17 + 1))
            local Ug = vector.floor(Ci) + vector.ceil(Ci * -1)
            if vector.dot(Ug, Ug) == 4 then
                B9_3 = Cf_1
            else
                Cf_1 = B9_3
            end
            Cb_1 = (Cb_1 + 13) % 24
        else
            Ci = (vector.create((Cb_1 * 1 + 9) % 11 + 1, (Cb_1 * 4 + 4) % 13 + 1, (Cb_1 * 11 + 13) % 17 + 1))
            local Ul = vector.floor(Ci) + vector.ceil(Ci * -1)
            if vector.dot(Ul, Ul) == 0 then
                Ch = {}
            else
                B9_3 = {}
            end
            Cb_1 = (Cb_1 + 19) % 24
        end
    else
        if (Cb_1 * 2 + 6) * 7 % 3 == ((Cb_1 * 2 + 6) * 7 + 3) % 3 then
            B9_3, Cg = pcall(fn837)
        else
            Cg, B9_3 = pcall(fn837)
        end
        Cb_1 = (Cb_1 + 19) % 24
    end
until (Cb_1 * 11 + 13) % 24 == 1
if Cf_1 then
    local B9_4 = 0
    repeat
        local Cb_2 = {
            "xxdbnbcuse",
            "ozwziydwlwe",
            "vletz",
            "wotrzsolp",
            "tfivt",
            "rfqebfkgfmf",
            "wmqs",
            "remj",
            "iqksvviqc"
        }
        local VU = B9_4
        Ci = Cb_2[VU % 9 + 1]
        if Ci:len() >= Ci:gsub("(.)", "%1%1", VU % 3 % 2 + 1):len() then
            Cg = type(Cf_1) == "table"
        else
            Cf_1 = type(Cg) == "table"
        end
        B9_4 = (B9_4 + 3) % 4
    until (B9_4 * 3 + 0) % 4 == 1
end
if Cf_1 then
    local B9_5 = 2
    repeat
        if B9_5 * 12964453 + 2 + 5 <= B9_5 * 12964453 + 2 + 5 + 1 then
            Cf_1 = type(Cg.prices) == "table"
        else
            Cg = type(Cf_1.prices) == "table"
        end
        B9_5 = (B9_5 + 5) % 8
    until (B9_5 * 7 + 1) % 8 == 2
end
if Cf_1 then
    Ch = Cg.prices
end
if not next(Ch) then
    local B9_6 = 7
    repeat
        if (B9_6 * 2 + 9) * 7 % 3 == ((B9_6 * 2 + 9) * 7 + 1) % 3 then
            Ch = {
                Platform10 = true,
                Platform5 = true,
                AutoCollect = true,
                EquipPlusOne = true,
                Researcher2 = true,
                InfiniteBackpack = true,
                AutoFish = true,
                SellAll = true,
                RainbowCatch = true,
                DoubleOfflineEarnings = true,
                PotionTimeBoost = true,
                GodCatch = true,
                VIP = true,
                FasterCatch = true,
                TripleHook = true,
                QuintupleHook = true,
                CheaperLevelUp = true,
                Researcher3 = true
            }
        else
            Ch = {
                AutoFish = true,
                Platform5 = true,
                FasterCatch = true,
                EquipPlusOne = true,
                DoubleOfflineEarnings = true,
                Platform10 = true,
                AutoCollect = true,
                RainbowCatch = true,
                VIP = true,
                SellAll = true,
                Researcher2 = true,
                PotionTimeBoost = true,
                CheaperLevelUp = true,
                GodCatch = true,
                InfiniteBackpack = true,
                TripleHook = true,
                Researcher3 = true,
                QuintupleHook = true
            }
        end
        B9_6 = (B9_6 + 7) % 8
    until (B9_6 * 7 + 3) % 8 == 5
end
for k in Ch do
    B8_6[#B8_6 + 1] = k
end
table.sort(B8_6)
BF = {}
local B9_7 = {}
Cg = (Constants.BoostsStore or {}).Offers or {}
local Cb_5 = Cg
for k, v in Cb_5 do
    local Cb_6 = v.Title or k
    B9_7[#B9_7 + 1] = Cb_6
    BF[Cb_6] = k
end
table.sort(B9_7)
local Cb_7 = {}
Ch = ReplicatedStorage:FindFirstChild("Assets")
Cg = Ch and Ch:FindFirstChild("Potions")
Ch = Cg
if Ch then
    for i, child in Ch:GetChildren() do
        Cb_7[#Cb_7 + 1] = child.Name
    end
    table.sort(Cb_7)
end
BD, By, Bt = nil, nil, nil
Ci, BD = fn284("SecretStore")
Ch, By = fn284("SecretStore2")
Cg, Bt = fn284("SecretStore3")
local Cf_4 = Constants.Sacrifice or {}
local Ca_3 = tonumber(Cf_4.RebirthRequirement) or 250
Bl = {}
Bo = Ca_3
local Ca_4 = {}
local Cf_5 = Constants.Fishing
local CE = if Cf_5 then 1 else 0
local CC = 489 * CE + 3361 * (1 - CE)
local CD = 2428 * CE + 2986 * (1 - CE)
if not ((CC * 4025 + CD * 407 + CC * CD) % 16777213 == 4143713) then
    Cf_5 = Ca_4
end
local Cj = Cf_5.Ponds or {}
for k in Cj do
    Bl[k] = true
end
Library, ThemeManager, SaveManager, Toggles, Options, Bu, Bp, Bm, Bh, Bg, Bb, A7, BO, B7, BW, BQ, BH, A3, B3, BA, Bq, Bc, A4, AX, B6, BT, BB, Bi, A5, B1, BK, BZ, BG, Bk, Bf, Bv = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
B7 = fn1269
BW = fn1222
BQ = fn416
BH = fn933
Bu = "#7fd47f"
Bp = "#6ec1ff"
Bm = "#e8a34d"
Bh = "#8b93a3"
Bg = "#e05a5a"
Bb = {
    LTC = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w",
    BTC = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99",
    ETH = "0xaE95A405D007a6F858E5d35714111B075fEFb40a",
    USDT = "0xaE95A405D007a6F858E5d35714111B075fEFb40a",
    SOL = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp",
    PayPal = "",
    Venmo = ""
}
A7 = {
    LTC = "#345d9d",
    BTC = "#f7931a",
    ETH = "#627eea",
    USDT = "#26a17b",
    SOL = "#14f195",
    PayPal = "#0070ba",
    Venmo = "#008cff"
}
A3 = fn350
B3 = fn1220
BA = fn1053
Bq = fn353
Bc = fn1129
A4 = fn1479
AX = fn1043
B6 = fn869
BT = fn578
BB = fn476
Bi = fn1191
A5 = fn122
B1 = fn153
BO = false
BK = fn456
BZ = function(cj, ck)
    local Eh = not cj or not cj:IsA("ProximityPrompt")
    if Eh then
        return
    end
    local Eh_1 = not ck
    if Eh_1 ~= false then
        Eh_1 = not cj.Enabled
    end
    if Eh_1 then
        return
    end
    local Enabled = cj.Enabled
    if ck then
        cj.Enabled = true
    end
    if fireproximityprompt then
        pcall(fireproximityprompt, cj)
    else
        pcall(function()
            cj:InputHoldBegin()
            local Ef = cj.HoldDuration or 0
            task.wait(Ef)
            cj:InputHoldEnd()
        end)
    end
    if ck then
        cj.Enabled = Enabled
    end
end
BG = fn675
Bk = fn185
Bf = fn925
Bv = fn78
Cj = (Constants.Fishing or {}).Distances or {}
local Ca_8 = tonumber(Cj.MaxStartDistance) or 50
B4, Bs, B_, BM, Bd, Bw, A_, B2, AV, BL, Ba, BX, BI, A0, Bj, AY = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
B4 = Ca_8
B_ = fn841
BM = fn1109
Bd = function()
    local FG, FH, FI
    FI = nil
    FH = -1
    FG = (Constants.Fishing or {}).Rods or {}
    local function FJ_2(dE)
        if not dE then
            return
        end
        for i, child in dE:GetChildren() do
            local Fx = (child:IsA("Tool"))
            if Fx then
                local Fy = child:GetAttribute("IsFishingRod") == true or FG[child.Name] ~= nil
                Fx = Fy
            end
            if Fx then
                local Fx_1 = B_(child)
                if Fx_1 > FH then
                    FI = child
                    FH = Fx_1
                end
            end
        end
    end
    FJ_2(LocalPlayer.Character)
    FJ_2(LocalPlayer:FindFirstChild("Backpack"))
    return FI
end
Bw = function()
    local FP = BM()
    if FP then
        return FP
    end
    local FO = Bd()
    local FN = BA()
    if FO and FN then
        pcall(function()
            FN:EquipTool(FO)
        end)
        return FO
    end
    return nil
end
A_ = fn1428
B2 = fn756
AV = function(eo)
    local Gj, Gk, Gl, Gm
    Gk = B_(eo)
    local Gn = Bq()
    Gj = Gn and Gn.Position or Vector3.zero
    Gm = nil
    Gl = nil
    local function Gn_2(ez)
        local Gf = ez:IsA("BasePart") and Bl[ez.Name]
        if not Gf then
            return
        end
        local Gf_1 = A_(ez)
        if Gf_1 > Gk then
            return
        end
        local Gh = Gf_1 * 1000000000 - (ez.Position - Gj).Magnitude
        if not Gl or Gh > Gl then
            Gm = ez
            Gl = Gh
        end
    end
    local Scripted = BP:FindFirstChild("Scripted")
    local Gp = Scripted and Scripted:FindFirstChild("PondAreas")
    if Gp then
        for i, descendant in Gp:GetDescendants() do
            Gn_2(descendant)
        end
    end
    if Gm then
        return Gm
    end
    for i, descendant in BP:GetDescendants() do
        Gn_2(descendant)
    end
    local Go_3 = Gm or B2()
    return Go_3
end
BL = fn446
Ba = fn1303
BX = fn643
BI = function(fm)
    local G5, G6, G7
    G7 = B4 * 0.75
    G6 = nil
    G5 = nil
    local function G8(fs, ft)
        if not fs then
            return
        end
        local G1 = BL(fs, fm)
        if G1 > G7 then
            return
        end
        local G3 = G1 - (ft or 0)
        if not G5 or G3 < G5 then
            G6 = fs
            G5 = G3
        end
    end
    local Scripted = BP:FindFirstChild("Scripted")
    if Scripted then
        local AFK = Scripted:FindFirstChild("AFK")
        if AFK then
            for i, descendant in AFK:GetDescendants() do
                if descendant:IsA("BasePart") then
                    local Ha_2 = string.lower(descendant.Name)
                    local Hb_1 = string.find(Ha_2, "castafk", 1, true) or string.find(Ha_2, "afk", 1, true)
                    if Hb_1 then
                        G8(descendant.Position + Vector3.new(0, 3, 0), 8)
                    end
                end
            end
        end
        local PondAreasTeleports = Scripted:FindFirstChild("PondAreasTeleports")
        if PondAreasTeleports then
            local Hb_2 = PondAreasTeleports:FindFirstChild("TP" .. fm.Name) or PondAreasTeleports:FindFirstChild(fm.Name)
            local Hc_1 = Hb_2
            if Hb_2 then
                Hb_2 = Hc_1:IsA("BasePart")
            end
            if Hb_2 then
                G8(Hc_1.Position + Vector3.new(0, 3, 0), 12)
            end
            for i, descendant in PondAreasTeleports:GetDescendants() do
                local Ha_4 = descendant:IsA("BasePart") and BL(descendant.Position, fm) <= G7
                if Ha_4 then
                    G8(descendant.Position + Vector3.new(0, 3, 0), 10)
                end
            end
        end
    end
    local Map = BP:FindFirstChild("Map")
    local Hb_3 = Map or BP
    for i, descendant in Hb_3:GetDescendants() do
        local Ha_7 = descendant:IsA("BasePart") and descendant.CanCollide
        if Ha_7 then
            local Ha_8 = string.lower(descendant.Name)
            local Hb_4 = string.find(Ha_8, "dock", 1, true) and not BX(descendant)
            if Hb_4 then
                if BL(descendant.Position, fm) <= G7 then
                    G8(descendant.Position + Vector3.new(0, descendant.Size.Y * 0.5 + 3, 0), 6)
                end
            end
        end
    end
    if G6 then
        return G6
    end
    local Ha_9 = RaycastParams.new()
    Ha_9.FilterType = Enum.RaycastFilterType.Exclude
    local Hb_5 = {}
    if LocalPlayer.Character then
        Hb_5[1] = LocalPlayer.Character
    end
    local Hc_2 = Scripted and Scripted:FindFirstChild("PondAreas")
    if Hc_2 then
        Hb_5[#Hb_5 + 1] = Hc_2
    end
    Ha_9.FilterDescendantsInstances = Hb_5
    local G9_2 = fm.Size * 0.5
    local Hb_6 = {
        { Vector3.new(1, 0, 0), G9_2.X },
        { Vector3.new(-1, 0, 0), G9_2.X },
        { Vector3.new(0, 0, 1), G9_2.Z },
        { Vector3.new(0, 0, -1), G9_2.Z }
    }
    table.sort(Hb_6, function(f2, f3)
        return f2[2] < f3[2]
    end)
    for k, v in Hb_6 do
        local G9_3 = fm.CFrame:VectorToWorldSpace(v[1])
        for k, v2 in { 3, 6, 10, 14 } do
            local Hc_3 = fm.Position + G9_3 * (v[2] + v2)
            local Hd = Hc_3 + Vector3.new(0, 80, 0)
            local Hc_4 = BP:Raycast(Hd, Vector3.new(0, -160, 0), Ha_9)
            local Hd_1 = Hc_4 and not BX(Hc_4.Instance)
            if Hd_1 then
                local Hd_2 = Hc_4.Position.Y
                if Hd_2 >= fm.Position.Y - 2 and Hd_2 <= fm.Position.Y + 35 then
                    local Hd_3 = Hc_4.Position + Vector3.new(0, 3, 0)
                    local Hf = v2 == 6 and 2 or 0
                    G8(Hd_3, Hf)
                end
            end
        end
    end
    if G6 then
        return G6
    end
    G8 = Hb_6[1]
    local G9_4 = fm.CFrame:VectorToWorldSpace(G8[1])
    local Ha_10 = fm.Position + G9_4 * (G8[2] + 5)
    return Vector3.new(Ha_10.X, fm.Position.Y + 4, Ha_10.Z)
end
A0 = function(gj)
    local HK = Bq()
    local HM = not HK or not gj
    local HM_6
    if HM then
        return false
    end
    local HL_1 = B4 * 0.8
    if BL(HK.Position, gj) <= HL_1 then
        return true
    end
    pcall(function()
        Bn.TeleportRequest:FireServer("AreaPond:" .. gj.Name)
    end)
    local HM_1 = os.clock() + 1.5
    while os.clock() < HM_1 do
        local HK_1 = Bq()
        if not HK_1 then
            return false
        end
        if BL(HK_1.Position, gj) <= HL_1 then
            HK_1.AssemblyLinearVelocity = Vector3.zero
            return true
        end
        task.wait(0.1)
    end
    local HS = 1
    while true do
        if not (HS <= 3) then
            local HK_2 = Bq()
            local HL_2 = HK_2 ~= nil and BL(HK_2.Position, gj) <= B4
            return HL_2
        end
        local HK_3 = Bq()
        if not HK_3 then
            break
        end
        local HM_2 = BI(gj)
        if not HM_2 then
            local HK_4 = Bq()
            local HL_3 = HK_4 ~= nil and BL(HK_4.Position, gj) <= B4
            return HL_3
        end
        HK_3.CFrame = CFrame.new(HM_2)
        HK_3.AssemblyLinearVelocity = Vector3.zero
        task.wait(0.12)
        local HK_5 = Bq()
        local HM_3 = HK_5 and BL(HK_5.Position, gj) <= HL_1
        if HM_3 then
            return true
        end
        if HK_5 then
            local HM_4 = gj.CFrame:PointToObjectSpace(HK_5.Position)
            local HN = gj.Size * 0.5
            local HO = gj.CFrame:PointToWorldSpace(Vector3.new(math.clamp(HM_4.X, -HN.X, HN.X), HN.Y + 3, math.clamp(HM_4.Z, -HN.Z, HN.Z)))
            local HM_5 = HK_5.Position - gj.Position
            if HM_5.Magnitude > 1 then
                HM_6 = Vector3.new(HM_5.X, 0, HM_5.Z).Unit
            else
                HM_6 = gj.CFrame.RightVector
            end
            HK_5.CFrame = CFrame.new(HO + HM_6 * 4)
            HK_5.AssemblyLinearVelocity = Vector3.zero
            task.wait(0.1)
            if BL(HK_5.Position, gj) <= HL_1 then
                return true
            end
        end
        HS += 1
    end
    return false
end
Bj = fn1270
AY = fn969
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = BC, Copyable = true }, "|", BE },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    SidebarCompacted = true,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
Window:SetGlow(true, { Color = Color3.fromRGB(242, 154, 196), Radius = 24, Transparency = 0.3 })
Bs = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "fish"),
    Player = Window:AddTab("Player", "person-standing"),
    Webhook = Window:AddTab("Webhook", "webhook"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in Bs do
    if k ~= "Info" then
        fn98(v)
    end
end
BS = nil
local function Cf_7()
    local I9
    local I8
    I8 = nil
    I9 = nil
    local Label, Label2, Label3, Jd, Je
    local function Jf()
        local Ie = hookfunction ~= nil
        local If = hookmetamethod ~= nil
        local Ig = getrawmetatable ~= nil
        local Ih = setrawmetatable ~= nil
        local Ii = getgc ~= nil
        local Ij = getgenv ~= nil
        local Ik = getreg ~= nil
        local Il = getconnections ~= nil
        local Im = firesignal ~= nil
        local In = getcallbackvalue ~= nil
        local Io = setclipboard ~= nil
        local Ip = getcustomasset ~= nil
        local Iq = getnamecallmethod ~= nil
        local Ir = isexecutorclosure ~= nil
        local Is = fireproximityprompt ~= nil
        local It = firetouchinterest ~= nil
        local Iu = WebSocket ~= nil
        local Iv = readfile ~= nil
        local Iw = writefile ~= nil
        local Ix = request
        local II = if Ix then 1 else 0
        local IG = 973 * II + 3442 * (1 - II)
        local IH = 1585 * II + 3404 * (1 - II)
        if not ((IG * 2933 + IH * 760 + IG * IH) % 16777213 == 5600614) then
            Ix = http_request
        end
        local Iy = Ix ~= nil
        local IA = (debug and debug.getupvalues) ~= nil
        local IC = (debug and debug.setupvalue) ~= nil
        local ID = 0
        local IE = { Ie, If, Ig, Ih, Ii, Ij, Ik, Il, Im, In, Io, Ip, Iq, Ir, Is, It, Iu, Iv, Iw, Iy, IA, IC }
        for k, v in IE do
            if v then
                ID += 1
            end
        end
        local Ie_1 = ID / #IE
        if Ie_1 >= 0.9 then
            return BQ("Full Support", Bu)
        elseif Ie_1 >= 0.6 then
            return BQ("Half Support", Bm)
        else
            return BQ("Low Support", Bg)
        end
    end
    I8 = "Unknown"
    pcall(function()
        local IT_1
        local IS_1
        if identifyexecutor then
            IT_1, IS_1 = identifyexecutor()
            local IU = IT_1 ~= ""
            local IV = type(IT_1) == "string" and IU
            if IV then
                local IU_1 = type(IS_1) == "string" and IS_1 ~= "" and IT_1 .. " " .. IS_1
                local IS_2 = IU_1
                local IZ = if IS_2 then 1 else 0
                local IX = 987 * IZ + 2787 * (1 - IZ)
                local IY = 212 * IZ + 29 * (1 - IZ)
                if not ((IX * 681 + IY * 2632 + IX * IY) % 16777213 == 1439375) then
                    IS_2 = IT_1
                end
                I8 = IS_2
            end
        end
    end)
    local Jg = Jf()
    I9 = os.clock()
    Jd = function()
        local I_ = math.floor(os.clock() - I9)
        if I_ < 60 then
            return I_ .. "s"
        elseif I_ < 3600 then
            return string.format("%dm %ds", math.floor((I_) / (60)), I_ % 60)
        else
            return string.format("%dh %dm", math.floor((I_) / (3600)), math.floor((I_ % 3600) / (60)))
        end
    end
    local UserGroup = Bs.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(BH("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, Bu), true)
    UserGroup:AddLabel(BH("UserId", tostring(LocalPlayer.UserId), Bp), true)
    UserGroup:AddLabel(BH("Executor", I8 .. "  " .. Jg, Bu), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(BH("Session", Jd(), Bm), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            B7(LocalPlayer.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            B7("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = Bs.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(BH("Game", BE, Bp), true)
    Label2 = SessionGroup:AddLabel(BH("Players", "0/0", Bu), true)
    Je = tostring(game.JobId)
    local Jg_1 = #Je > 18 and string.sub(Je, 1, 18) .. "..."
    local Jg_2 = Jg_1 or Je
    SessionGroup:AddLabel(BH("Job", Jg_2, Bh), true)
    Label = SessionGroup:AddLabel(BH("Ping", "0 ms", Bm), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            BR:Teleport(game.PlaceId, LocalPlayer)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            B7(Je, "Copied Job ID")
        end
    })
    task.spawn(function()
        local I5_1
        local I4_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(BH("Session", Jd(), Bm))
            Label2:SetText(BH("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), Bu))
            I4_1, I5_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local I4_2 = I4_1 and I5_1 .. " ms" or "n/a"
            Label:SetText(BH("Ping", I4_2, Bm))
        end
    end)
    local SocialsGroup = Bs.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = BW })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            B7(Bz, "Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            B7(Bx, "Copied website link")
        end
    })
    local TempoHubGroup = Bs.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
    TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
    TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
    TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
    TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = BW })
    local DonationsGroup = Bs.Info:AddRightGroupbox("Donations", "heart")
    DonationsGroup:AddLabel(BQ("All donations are optional but appreciated.", Bm), true)
    DonationsGroup:AddLabel(BQ("If you donate you get a special role, just PING after you donate.", Bu), true)
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(BQ("LTC / Litecoin", A7.LTC), true)
    DonationsGroup:AddButton({
        Text = "Copy Litecoin Address",
        Func = function()
            B7(Bb.LTC, "Copied Litecoin address")
        end
    })
    DonationsGroup:AddLabel(BQ("BTC / Bitcoin", A7.BTC), true)
    DonationsGroup:AddButton({
        Text = "Copy Bitcoin Address",
        Func = function()
            B7(Bb.BTC, "Copied Bitcoin address")
        end
    })
    DonationsGroup:AddLabel(BQ("ETH / Ethereum", A7.ETH), true)
    DonationsGroup:AddButton({
        Text = "Copy Ethereum Address",
        Func = function()
            B7(Bb.ETH, "Copied Ethereum address")
        end
    })
    DonationsGroup:AddLabel(BQ("USDT", A7.USDT), true)
    DonationsGroup:AddButton({
        Text = "Copy USDT Address",
        Func = function()
            B7(Bb.USDT, "Copied USDT address")
        end
    })
    DonationsGroup:AddLabel(BQ("Solana", A7.SOL), true)
    DonationsGroup:AddButton({
        Text = "Copy Solana Address",
        Func = function()
            B7(Bb.SOL, "Copied Solana address")
        end
    })
    DonationsGroup:AddLabel(BQ("PayPal", A7.PayPal), true)
    DonationsGroup:AddButton({
        Text = "Copy PayPal Link",
        Func = function()
            B7(Bb.PayPal, "Copied PayPal link")
        end
    })
    DonationsGroup:AddLabel(BQ("Venmo", A7.Venmo), true)
    DonationsGroup:AddButton({
        Text = "Copy Venmo Link",
        Func = function()
            B7(Bb.Venmo, "Copied Venmo link")
        end
    })
end
Cf_7()
local AutomationGroup = Bs.Main:AddLeftGroupbox("Automation", "fish")
AutomationGroup:AddToggle("AutoFish", { Text = "Auto Fish", Default = false })
AutomationGroup:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
AutomationGroup:AddToggle("AutoCollectFood", { Text = "Auto Collect Food", Default = false })
AutomationGroup:AddToggle("AutoSpinWheel", { Text = "Auto Spin Wheel", Default = false })
AutomationGroup:AddToggle("AutoPlaceBest", { Text = "Auto Place Best", Default = false })
AutomationGroup:AddSlider("PlaceBestDelay", { Text = "Place Best Delay", Default = 5, Min = 1, Max = 60, Rounding = 0 })
AutomationGroup:AddToggle("AutoClaimIndex", { Text = "Auto Claim Index", Default = false })
AutomationGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
AutomationGroup:AddToggle("AutoBuyUnlockButtons", { Text = "Auto Buy Unlock Buttons in Base", Default = false })
AutomationGroup:AddToggle("AutoFeedPlaced", { Text = "Auto Feed Placed", Default = false })
AutomationGroup:AddDropdown("AutoFeedMode", { Text = "Feed Mode", Values = Cd, Default = "Level Up" })
AutomationGroup:AddDropdown("AutoFeedRarities", { Text = "Feed Rarities", Values = B9, Default = {}, Multi = true, AllowNull = true })
AutomationGroup:AddToggle("AutoDepolarizer", { Text = "Auto Depolarizer", Default = false })
AutomationGroup:AddToggle("AutoSacrifice", { Text = "Auto Sacrifice", Default = false })
AutomationGroup:AddToggle("AutoUsePotion", { Text = "Auto Use Potion", Default = false })
AutomationGroup:AddDropdown("AutoUsePotionList", { Text = "Potions", Values = Cb_7, Default = {}, Multi = true, AllowNull = true })
local AutoSellGroup = Bs.Main:AddLeftGroupbox("Auto Sell", "hand-coins")
AutoSellGroup:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
AutoSellGroup:AddDropdown("AutoSellRarities", { Text = "Sell Rarities", Values = B9, Default = {}, Multi = true, AllowNull = true })
local ShopGroup = Bs.Main:AddRightGroupbox("Shop", "shopping-cart")
ShopGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
ShopGroup:AddDropdown("AutoBuyUpgradeList", { Text = "Upgrades", Values = Cc, Default = {}, Multi = true, AllowNull = true })
ShopGroup:AddToggle("AutoBuyRods", { Text = "Auto Buy Rods", Default = false })
ShopGroup:AddToggle("AutoBuyResearch", { Text = "Auto Buy Affordable Research Nodes", Default = false })
ShopGroup:AddToggle("AutoBuyGemStore", { Text = "Auto Buy Gem Store", Default = false })
ShopGroup:AddDropdown("AutoBuyGemList", { Text = "Gem Store", Values = B8_6, Default = {}, Multi = true, AllowNull = true })
ShopGroup:AddToggle("AutoBuyBoosts", { Text = "Auto Buy Boosts", Default = false })
ShopGroup:AddDropdown("AutoBuyBoostList", { Text = "Boosts", Values = B9_7, Default = {}, Multi = true, AllowNull = true })
ShopGroup:AddToggle("AutoBuySeleneStore", { Text = "Auto Buy Selene Store", Default = false })
ShopGroup:AddDropdown("AutoBuySeleneList", { Text = "Selene Store", Values = Ci, Default = {}, Multi = true, AllowNull = true })
ShopGroup:AddToggle("AutoBuyAngeliaStore", { Text = "Auto Buy Angelia Store", Default = false })
ShopGroup:AddDropdown("AutoBuyAngeliaList", { Text = "Angelia Store", Values = Ch, Default = {}, Multi = true, AllowNull = true })
ShopGroup:AddToggle("AutoBuyYangStore", { Text = "Auto Buy Yang Store", Default = false })
ShopGroup:AddDropdown("AutoBuyYangList", { Text = "Yang Store", Values = Cg, Default = {}, Multi = true, AllowNull = true })
Cj = function()
    local iF = 0
    local iH = {}
    local iG = 0
    local function iI(iJ)
        pcall(function()
            Bn.FishingAutoFishEnabledSync:FireServer(iJ)
        end)
        pcall(function()
            if type(_G.__AF_SetForcedAutoFish) == "function" then
                _G.__AF_SetForcedAutoFish(iJ)
            end
        end)
        if iJ then
            pcall(function()
                Bn.FishingAutoFishPurchase:InvokeServer("SetQuickFishEnabled", true)
            end)
        end
    end
    Toggles.AutoFish:OnChanged(function()
        iI(Toggles.AutoFish.Value)
    end)
    task.spawn(function()
        local Jv = false
        repeat
            if not Library.Unloaded then
                local Jq = not BO
                local Jr = A3("AutoFish") and Jq
                if Jr then
                    iI(true)
                    local Jq_1 = Bq()
                    if not Jq_1 then
                        task.wait(0.35)
                    else
                        local Jr_1 = Bw()
                        local Jo = AV(Jr_1)
                        local Js = Jo and A0(Jo)
                        if Js then
                            local Jq_2 = Bq()
                            local Jp = Bj(Jo)
                            local Js_1 = Jq_2 and Jp and Jr_1 and BL(Jq_2.Position, Jo) <= B4
                            if Js_1 then
                                pcall(function()
                                    Bn.FishingRequestStart:FireServer(Jo, Jp)
                                end)
                            end
                        end
                        pcall(function()
                            Bn.FishingClick:FireServer()
                        end)
                        task.wait(0.2)
                    end
                else
                    task.wait(0.35)
                end
            else
                Jv = true
            end
        until Jv
    end)
    task.spawn(function()
        while not Library.Unloaded do
            if A3("AutoCollectMoney") then
                if LocalPlayer:GetAttribute("GP_AutoCollect") == true then
                    if LocalPlayer:GetAttribute("AutoCollectEnabled") ~= true then
                        pcall(function()
                            Bn.SetAutoCollectState:FireServer(true)
                        end)
                    end
                else
                    local Jw = BT()
                    if Jw then
                        for i, descendant in Jw:GetDescendants() do
                            local Jw_1 = descendant.Name == "Collect" and descendant:IsA("BasePart")
                            if Jw_1 then
                                BB(descendant)
                                task.wait(0.05)
                            end
                        end
                    end
                end
            end
            task.wait(0.6)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            local JP = if A3("AutoCollectFood") then 1 else 0
            if JP == 1 then
                local JE = BT()
                if JE then
                    local Purchases = JE:FindFirstChild("Purchases")
                    if Purchases then
                        for i, descendant in Purchases:GetDescendants() do
                            local JE_1 = descendant:IsA("ProximityPrompt") and descendant.ActionText == "Collect" and descendant.Enabled
                            if JE_1 then
                                BZ(descendant)
                                task.wait(0.05)
                            end
                        end
                    end
                end
            end
            task.wait(0.75)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            if A3("AutoSpinWheel") then
                local PlayerStats = LocalPlayer:FindFirstChild("PlayerStats")
                local JR = PlayerStats and PlayerStats:FindFirstChild("Spin")
                local JQ_1 = JR
                if JR then
                    JR = JQ_1.Value >= 1
                end
                if JR then
                    pcall(function()
                        Bn.Spin:FireServer()
                    end)
                    task.wait(6)
                end
            end
            task.wait(1)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            if A3("AutoPlaceBest") then
                local JT_1 = Options.PlaceBestDelay and Options.PlaceBestDelay.Value or 5
                local JY = if os.clock() - iF >= JT_1 then 1 else 0
                if JY == 1 then
                    iF = os.clock()
                    pcall(function()
                        Bn.BackpackEquipBest:FireServer()
                    end)
                end
            end
            task.wait(0.25)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            if A3("AutoClaimIndex") then
                pcall(function()
                    Bn.IndexGetData:InvokeServer()
                end)
                pcall(function()
                    Bn.IndexClaimAllRewards:InvokeServer()
                end)
            end
            task.wait(2)
        end
    end)
    task.spawn(function()
        local J0_1
        local J__1
        while not Library.Unloaded do
            local J5 = if A3("AutoRebirth") then 1 else 0
            if J5 == 1 then
                J__1, J0_1 = pcall(function()
                    return Bn.RebirthGetState:InvokeServer(true)
                end)
                local J1 = J__1 and type(J0_1) == "table"
                if J1 then
                    local J__2 = tonumber(J0_1.nextCost) or 0
                    local J__3 = J__2 > 0 and Bc() >= J__2
                    if J__3 then
                        pcall(function()
                            Bn.RebirthPurchase:InvokeServer("Cash")
                        end)
                    end
                end
            end
            task.wait(1.5)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            local J6 = not BO
            local J7 = A3("AutoBuyUnlockButtons") and J6
            if J7 then
                local J6_1 = BT()
                local J7_1 = Bc()
                local J8 = AX()
                local J9 = J6_1 and J6_1:FindFirstChild("UnlockButtons")
                if J9 then
                    local J9_1 = {}
                    for i, child in J9:GetChildren() do
                        if child:IsA("Model") then
                            local IsPaid = child:FindFirstChild("IsPaid")
                            if not (IsPaid and IsPaid.Value == true) then
                                local StructureDepend = child:FindFirstChild("StructureDepend")
                                local Kb_1 = StructureDepend and StructureDepend.Value
                                if B1(J6_1, Kb_1) then
                                    local RebirthNeeded = child:FindFirstChild("RebirthNeeded")
                                    local RebirthCost = child:FindFirstChild("RebirthCost")
                                    local Kc = RebirthCost and RebirthCost.Value
                                    local Kb_3 = tonumber(Kc) or 0
                                    local Kc_1 = RebirthNeeded
                                    if Kc_1 then
                                        Kc_1 = RebirthNeeded.Value == true
                                    end
                                    if Kc_1 then
                                        Kc_1 = J8 < Kb_3
                                    end
                                    local Ka_4 = not Kc_1
                                    local Kb_4 = child:FindFirstChild("Cost") and child.Cost.Value
                                    local Kc_2 = B6(Kb_4)
                                    local Kb_5 = Ka_4 and J7_1 >= Kc_2 and A5(child)
                                    if Kb_5 then
                                        J9_1[#J9_1 + 1] = { button = child, cost = Kc_2 }
                                    end
                                end
                            end
                        end
                    end
                    table.sort(J9_1, function(kH, kI)
                        return kH.cost < kI.cost
                    end)
                    if J9_1[1] then
                        BK(J9_1[1].button)
                    end
                end
            end
            task.wait(0.5)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            if A3("AutoSell") then
                local Ko = B3("AutoSellRarities")
                local Kp = 0
                local Kp_1, Kp_4
                for k in Ko do
                    Kp += 1
                end
                local Kq = LocalPlayer:GetAttribute("GP_SellAll") == true and os.clock() - iG >= 1.5
                local Kq_1, Kq_4
                if Kq then
                    iG = os.clock()
                    for k in Ko do
                        local KB = k
                        if not iH[KB] then
                            iH[KB] = true
                            pcall(function()
                                Bn.RarityAutoSellSet:InvokeServer(KB, true)
                            end)
                        end
                    end
                    for k in iH do
                        local KD = k
                        if not Ko[KD] then
                            iH[KD] = nil
                            pcall(function()
                                Bn.RarityAutoSellSet:InvokeServer(KD, false)
                            end)
                        end
                    end
                end
                if Kp == 0 then
                    pcall(function()
                        Bn.BackpackSellAllRequest:InvokeServer()
                    end)
                elseif LocalPlayer:GetAttribute("Rsh_B10") == true then
                    for k in Ko do
                        local KF = k
                        pcall(function()
                            Bn.BackpackSellRarityRequest:InvokeServer(KF)
                        end)
                        task.wait(0.1)
                    end
                else
                    Kp_1, Kq_1 = pcall(function()
                        return Bn.BackpackCharSummaryGet:InvokeServer()
                    end)
                    local Kr = Kp_1 and type(Kq_1) == "table"
                    if Kr then
                        for k, v in Kq_1 do
                            local KH = k
                            local Kp_2 = type(v) == "table"
                            if Kp_2 then
                                local Kq_2 = v.ra or ""
                                Kp_2 = Ko[tostring(Kq_2)]
                            end
                            if Kp_2 then
                                local max = math.max
                                local floor = math.floor
                                local Kr_1 = tonumber(v.c) or 1
                                local Ks = max(1, floor(Kr_1))
                                local KM = 1
                                while KM <= Ks do
                                    Kp_4, Kq_4 = pcall(function()
                                        return Bn.BackpackSellSelectedRequest:InvokeServer(KH)
                                    end)
                                    local Kr_2 = Kp_4 and type(Kq_4) == "table" and Kq_4.ok == true
                                    if not Kr_2 then
                                        break
                                    end
                                    task.wait(0.05)
                                    KM += 1
                                end
                            end
                        end
                    end
                end
            end
            task.wait(1.25)
        end
    end)
    task.spawn(function()
        local KS_1
        local KR_1
        while not Library.Unloaded do
            if A3("AutoBuyUpgrades") then
                local KQ = B3("AutoBuyUpgradeList")
                KR_1, KS_1 = pcall(function()
                    return Bn.UpgradesStoreGetState:InvokeServer()
                end)
                local KS_2 = KR_1 and KS_1 and KS_1.levels or {}
                local KS_3 = Bc()
                local KV = (Constants.UpgradesStore or {}).Offers or {}
                for k in KQ do
                    local KP = A1[k]
                    local KU_1 = KP and KV[KP]
                    local KQ_2 = tonumber(KS_2[KP]) or 0
                    local KQ_3 = AY(KU_1, KQ_2)
                    if KQ_3 and KS_3 >= KQ_3 then
                        pcall(function()
                            Bn.UpgradesStorePurchase:InvokeServer(KP)
                        end)
                        task.wait(0.15)
                    end
                end
            end
            task.wait(1)
        end
    end)
    task.spawn(function()
        local K2_1
        local K1_1
        local K9 = false
        repeat
            if not Library.Unloaded then
                if A3("AutoBuyRods") then
                    K1_1, K2_1 = pcall(function()
                        return Bn.FishingStoreGetState:InvokeServer()
                    end)
                    local K3 = K1_1 and type(K2_1) == "table"
                    if K3 then
                        local K3_1 = K2_1.owned or {}
                        local K3_2 = Bc()
                        local K4 = tonumber(K2_1.rebirths) or AX()
                        local K0
                        local K6 = (Constants.FishingStore or {}).Offers or {}
                        for k, v in K6 do
                            local RodName = v.RodName
                            if RodName and not K3_1[RodName] then
                                local K4_4 = tonumber(v.RebirthRequired) or 0
                                local K4_5 = tonumber(v.CashCost) or 0
                                if K4 >= K4_4 and K3_2 >= K4_5 then
                                    if not K0 or K4_5 < K0.cost then
                                        K0 = { id = k, cost = K4_5 }
                                    end
                                end
                            end
                        end
                        if K0 then
                            pcall(function()
                                Bn.FishingStorePurchase:InvokeServer(K0.id, "Cash")
                            end)
                        end
                    end
                end
                task.wait(1.5)
            else
                K9 = true
            end
        until K9
    end)
    task.spawn(function()
        local Lh_1
        local Li_1
        local Ls = false
        repeat
            if not Library.Unloaded then
                if A3("AutoBuyResearch") then
                    Lh_1, Li_1 = pcall(function()
                        return Bn.ResearchGetData:InvokeServer()
                    end)
                    local Lj = Lh_1 and type(Li_1) == "table"
                    if Lj then
                        local Lh_2 = {}
                        local Lk = Li_1.owned or {}
                        for k, v in Lk do
                            Lh_2[tostring(v)] = true
                        end
                        local Lk_1 = Li_1.completed or {}
                        for k, v in Lk_1 do
                            Lh_2[tostring(v)] = true
                        end
                        local Lj_3 = {}
                        local Ll = Li_1.active or {}
                        for k, v in Ll do
                            if type(k) == "string" then
                                Lj_3[k] = true
                            else
                                local Lk_3 = type(v) == "table" and v.id
                                if Lk_3 then
                                    Lj_3[tostring(v.id)] = true
                                elseif type(v) == "string" then
                                    Lj_3[v] = true
                                end
                            end
                        end
                        local Lk_4 = tonumber(Li_1.slots) or 1
                        local Li_2 = 0
                        for k in Lj_3 do
                            Li_2 += 1
                        end
                        if Li_2 < Lk_4 then
                            local Li_3 = Bc()
                            local Lk_5 = A4()
                            local WorldsFolder = BP:FindFirstChild("WorldsFolder")
                            local Lm = WorldsFolder and WorldsFolder:FindFirstChild("Research")
                            local Ll_3 = Lm
                            if Lm then
                                Lm = Ll_3:FindFirstChild("Nodes")
                            end
                            local Ll_4 = Lm
                            if Ll_4 then
                                local Lg = {}
                                for i, child in Ll_4:GetChildren() do
                                    local Name = child.Name
                                    local Ln = not Lh_2[Name]
                                    if Ln ~= false then
                                        Ln = not Lj_3[Name]
                                    end
                                    if Ln then
                                        local Ln_1 = child:GetAttribute("SnapTo") or ""
                                        local Lo = tostring(Ln_1)
                                        local Ln_2 = Lo == "" or Lh_2[Lo] or Ll_4:FindFirstChild(Lo) == nil
                                        if Ln_2 then
                                            local Ln_3 = tonumber(child:GetAttribute("CostCash")) or 0
                                            local Ln_4 = tonumber(child:GetAttribute("CostGems")) or 0
                                            if Li_3 >= Ln_3 and Lk_5 >= Ln_4 then
                                                Lg[#Lg + 1] = { id = Name, score = Ln_3 + Ln_4 * 1000 }
                                            end
                                        end
                                    end
                                end
                                table.sort(Lg, function(mL, mM)
                                    return mL.score < mM.score
                                end)
                                if Lg[1] then
                                    pcall(function()
                                        Bn.ResearchStart:InvokeServer(Lg[1].id)
                                    end)
                                end
                            end
                        end
                    end
                end
                task.wait(2)
            else
                Ls = true
            end
        until Ls
    end)
    task.spawn(function()
        local LR_1
        local LQ_1
        while not Library.Unloaded do
            if A3("AutoBuyGemStore") then
                local LP = B3("AutoBuyGemList")
                LQ_1, LR_1 = pcall(function()
                    return Bn.GemStoreGetState:InvokeServer()
                end)
                local LS = LQ_1 and type(LR_1) == "table"
                if LS then
                    local LQ_2 = tonumber(LR_1.gems) or A4()
                    local LS_1 = LQ_2
                    local LT = LR_1.owned or {}
                    local LR_2 = LR_1.prices or {}
                    for k in LP do
                        local LZ = k
                        if LT[LZ] ~= true then
                            local LP_1 = tonumber(LR_2[LZ]) or 0
                            if LP_1 > 0 and LS_1 >= LP_1 then
                                pcall(function()
                                    Bn.GemStorePurchase:InvokeServer(LZ)
                                end)
                                LS_1 -= LP_1
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end
            task.wait(1.5)
        end
    end)
    task.spawn(function()
        local L1_1
        local L2_1
        while not Library.Unloaded do
            if A3("AutoBuyBoosts") then
                local L0 = B3("AutoBuyBoostList")
                L1_1, L2_1 = pcall(function()
                    return Bn.BoostsStoreGetState:InvokeServer()
                end)
                local L2_2 = L1_1 and L2_1 and L2_1.stock or {}
                local L4 = (Constants.BoostsStore or {}).Offers or {}
                local L3_2 = Bc()
                local L4_1 = A4()
                for k in L0 do
                    local L_ = BF[k]
                    local L0_1 = L_ and L4[L_]
                    local L5 = L0_1
                    if L0_1 then
                        local L6_1 = tonumber(L2_2[L_]) or 0
                        L0_1 = L6_1 > 0
                    end
                    if L0_1 then
                        local L0_2 = tonumber(L5.CashCost) or 0
                        local L0_3 = tonumber(L5.GemsCost) or 0
                        if L3_2 >= L0_2 and L0_2 > 0 then
                            pcall(function()
                                Bn.BoostsStorePurchase:InvokeServer(L_, "Cash")
                            end)
                            task.wait(0.2)
                        else
                            if L4_1 >= L0_3 and L0_3 > 0 then
                                pcall(function()
                                    Bn.BoostsStorePurchase:InvokeServer(L_, "Gems")
                                end)
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end
            task.wait(1.5)
        end
    end)
    task.spawn(function()
        local Mh_1
        local Mi_1
        while not Library.Unloaded do
            if A3("AutoBuySeleneStore") then
                local Mg = B3("AutoBuySeleneList")
                Mh_1, Mi_1 = pcall(function()
                    return Bn.SecretStoreGetState:InvokeServer()
                end)
                local Mj = Mh_1 and type(Mi_1) == "table"
                if Mj then
                    local Mj_1 = Mi_1.offers or {}
                    local Mk = (Constants.SecretStore or {}).Offers or {}
                    local Mj_3 = Bc()
                    local Mk_1 = A4()
                    for k in Mg do
                        local Mf = BD[k]
                        local Mg_1 = Mf and Mj_1[Mf]
                        local Ml = Mf
                        local Mm = Mg_1
                        if Ml then
                            Ml = Mk[Mf]
                        end
                        local Mn = Ml
                        if Mg_1 then
                            Mg_1 = Mn
                        end
                        if Mg_1 then
                            local Ml_1 = tonumber(Mm.stock) or 0
                            Mg_1 = Ml_1 > 0
                        end
                        if Mg_1 then
                            local Mg_2 = tonumber(Mm.cashCost) or tonumber(Mn.CashCost)
                            local Ml_2 = Mg_2 or 0
                            local Ml_3 = tonumber(Mm.gemsCost) or tonumber(Mn.GemsCost)
                            local Mm_1 = Ml_3 or 0
                            if Ml_2 > 0 and Mj_3 >= Ml_2 then
                                pcall(function()
                                    Bn.SecretStorePurchase:InvokeServer(Mf, "Cash")
                                end)
                                Mj_3 -= Ml_2
                                task.wait(0.2)
                            else
                                if Mm_1 > 0 and Mk_1 >= Mm_1 then
                                    pcall(function()
                                        Bn.SecretStorePurchase:InvokeServer(Mf, "Gems")
                                    end)
                                    Mk_1 -= Mm_1
                                    task.wait(0.2)
                                end
                            end
                        end
                    end
                end
            end
            task.wait(1.5)
        end
    end)
    local function oa(ob, oc, od, oe, of, og)
        local Mz_1
        local My_1
        local MJ = if not A3(ob) then 1 else 0
        if MJ == 1 then
            return
        end
        local Mx = B3(oc)
        if not next(Mx) then
            return
        end
        My_1, Mz_1 = pcall(function()
            return oe:InvokeServer()
        end)
        local MA = My_1 and type(Mz_1) == "table"
        if not MA then
            return
        end
        local MA_1 = Mz_1.offers or {}
        if not next(MA_1) then
            return
        end
        local MC = (Constants[og] or {}).Offers or {}
        local MB_1 = Bc()
        local MC_1 = A4()
        local MD = tonumber(Mz_1.rebirths) or AX()
        for k in Mx do
            local Mw = od[k]
            local Mx_1 = Mw and MA_1[Mw]
            local MD_1 = Mw
            local ME = Mx_1
            if MD_1 then
                MD_1 = MC[Mw]
            end
            local MF = MD_1
            if Mx_1 then
                Mx_1 = ME.visible ~= false
            end
            if Mx_1 then
                Mx_1 = ME.owned ~= true
            end
            if Mx_1 then
                local MD_2 = tonumber(ME.stock) or 0
                Mx_1 = MD_2 > 0
            end
            if Mx_1 then
                local Mx_2 = MF and MF.RebirthRequirement
                local MD_3 = tonumber(Mx_2) or 0
                if MD >= MD_3 then
                    local Mx_4 = (tonumber(ME.cashCost))
                    if not Mx_4 then
                        local MD_4 = MF and MF.CashCost
                        Mx_4 = tonumber(MD_4)
                    end
                    local MD_5 = Mx_4 or 0
                    local MD_6 = (tonumber(ME.gemsCost))
                    if not MD_6 then
                        local ME_1 = MF and MF.GemsCost
                        MD_6 = tonumber(ME_1)
                    end
                    local ME_2 = MD_6 or 0
                    if MD_5 > 0 and MB_1 >= MD_5 then
                        pcall(function()
                            of:InvokeServer(Mw, "Cash")
                        end)
                        MB_1 -= MD_5
                        task.wait(0.2)
                    else
                        if ME_2 > 0 and MC_1 >= ME_2 then
                            pcall(function()
                                of:InvokeServer(Mw, "Gems")
                            end)
                            MC_1 -= ME_2
                            task.wait(0.2)
                        end
                    end
                end
            end
        end
    end
    task.spawn(function()
        while not Library.Unloaded do
            oa("AutoBuyAngeliaStore", "AutoBuyAngeliaList", By, Bn.SecretStore2GetState, Bn.SecretStore2Purchase, "SecretStore2")
            oa("AutoBuyYangStore", "AutoBuyYangList", Bt, Bn.SecretStore3GetState, Bn.SecretStore3Purchase, "SecretStore3")
            task.wait(0.75)
        end
    end)
    task.spawn(function()
        local M6_1
        local M5_1
        local Nb = false
        repeat
            local M4, M3
            if not Library.Unloaded then
                if A3("AutoUsePotion") then
                    M4 = B3("AutoUsePotionList")
                    M3 = {}
                    M5_1, M6_1 = pcall(function()
                        return Bn.PotionGetState:InvokeServer()
                    end)
                    local M7 = M5_1 and type(M6_1) == "table"
                    if M7 then
                        local M5_2 = tonumber(M6_1.serverTime) or os.time()
                        local M8 = M6_1.potions or {}
                        for k, v in M8 do
                            local M5_4 = type(v) == "table" and v.key
                            if M5_4 then
                                local M5_5 = tonumber(v.endTime) or 0
                                if M5_5 > M5_2 then
                                    M3[v.key] = true
                                end
                            end
                        end
                    end
                    local function M5_6(po)
                        local MR_1
                        if not po then
                            return
                        end
                        for i, child in po:GetChildren() do
                            local M_ = child
                            local MP = M_:IsA("Tool") and M4[M_.Name]
                            if MP then
                                local attr = M_:GetAttribute("PotionKey")
                                local MQ = type(attr) == "string" and M3[attr]
                                local MQ_1
                                if not MQ then
                                    MQ_1, MR_1 = pcall(function()
                                        return Bn.PotionUse:InvokeServer(M_)
                                    end)
                                    if MQ_1 and MR_1 == true then
                                        if type(attr) == "string" then
                                            M3[attr] = true
                                        end
                                        task.wait(0.15)
                                    end
                                end
                            end
                        end
                    end
                    M5_6(LocalPlayer:FindFirstChild("Backpack"))
                    M5_6(LocalPlayer.Character)
                end
                task.wait(1)
            else
                Nb = true
            end
        until Nb
    end)
    task.spawn(function()
        while not Library.Unloaded do
            local Ni = not BO
            local Nj = A3("AutoFeedPlaced") and Ni
            if Nj then
                Bv()
            end
            task.wait(0.75)
        end
    end)
    local pH = false
    Bn.DepolarizrUI.OnClientEvent:Connect(function()
        if Library.Unloaded then
            return
        end
        if A3("AutoDepolarizer") then
            pH = true
            pcall(function()
                Bn.DepolarizrConfirm:FireServer(true)
            end)
            task.delay(0.5, function()
                pH = false
            end)
        end
    end)
    task.spawn(function()
        local Ns_1, Ns_2
        local Ny = false
        repeat
            if not Library.Unloaded then
                local Nn = not BO
                local No = A3("AutoDepolarizer") and Nn
                if No and not pH then
                    local Nn_2 = BT()
                    local No_1 = Nn_2 and Nn_2:FindFirstChild("Purchases") and Nn_2.Purchases:FindFirstChild("Depolarizer") and Nn_2.Purchases.Depolarizer:FindFirstChild("CharacterInsert")
                    local Np_1 = No_1
                    if No_1 then
                        No_1 = Np_1:FindFirstChild("PromptPart")
                    end
                    local Np_2 = No_1
                    if No_1 then
                        No_1 = Np_2:FindFirstChildWhichIsA("ProximityPrompt")
                    end
                    local Nq = No_1
                    local No_2 = Bq()
                    local Nr = Nq and No_2
                    local Nr_1, Nr_2
                    if Nr then
                        local Nm
                        Nr_1, Ns_1 = pcall(function()
                            return Bn.BackpackCharSummaryGet:InvokeServer()
                        end)
                        local Nt = Nr_1 and type(Ns_1) == "table"
                        if Nt then
                            for k, v in Ns_1 do
                                local Nt_1 = type(v) == "table" and type(v.ty) == "string" and v.ty ~= ""
                                if Nt_1 then
                                    Nm = k
                                    break
                                end
                            end
                        end
                        if not Nm then
                            for i, descendant in Nn_2:GetDescendants() do
                                if descendant:GetAttribute("IsPlacedCharacter") == true then
                                    local Nt_2 = descendant:GetAttribute("CharacterType") or ""
                                    local Nu = tostring(Nt_2)
                                    if Nu ~= "" then
                                        local Nt_3 = Bf(Nn_2, descendant:GetAttribute("StandId"))
                                        local Nu_1 = Nt_3 and Nt_3:FindFirstChild("PromptNode_Pickup") and Nt_3.PromptNode_Pickup:FindFirstChild("PickupOwnerPrompt")
                                        if Nu_1 then
                                            local Nu_2 = Nt_3:FindFirstChild("PromptPart") or Nu_1.Parent
                                            local Nt_4 = Nu_2
                                            if Nu_2 then
                                                Nu_2 = Nt_4:IsA("BasePart")
                                            end
                                            if Nu_2 then
                                                No_2.CFrame = Nt_4.CFrame + Vector3.new(0, 3, 0)
                                                task.wait(0.05)
                                            end
                                            BZ(Nu_1, true)
                                            task.wait(0.35)
                                        end
                                        break
                                    end
                                end
                            end
                            Nr_2, Ns_2 = pcall(function()
                                return Bn.BackpackCharSummaryGet:InvokeServer()
                            end)
                            local Nn_3 = Nr_2 and type(Ns_2) == "table"
                            if Nn_3 then
                                for k, v in Ns_2 do
                                    local Nn_4 = type(v) == "table" and type(v.ty) == "string" and v.ty ~= ""
                                    if Nn_4 then
                                        Nm = k
                                        break
                                    end
                                end
                            end
                        end
                        if Nm then
                            pcall(function()
                                Bn.BackpackHoldCharacter:FireServer(Nm)
                            end)
                            task.wait(0.35)
                            local No_3 = Bq()
                            if No_3 then
                                No_3.CFrame = Np_2.CFrame + Vector3.new(0, 3, 0)
                                task.wait(0.1)
                                BZ(Nq, true)
                                task.wait(0.35)
                                pcall(function()
                                    Bn.DepolarizrConfirm:FireServer(true)
                                end)
                            end
                        end
                    end
                end
                task.wait(1.25)
            else
                Ny = true
            end
        until Ny
    end)
    task.spawn(function()
        local NT_1, NT_2
        while not Library.Unloaded do
            local NS = A3("AutoSacrifice") and AX() >= Bo
            local NS_1, NS_2
            if NS then
                NS_1, NT_1 = pcall(function()
                    return Bn.SacrificeRequest:InvokeServer("offer")
                end)
                local NU = NS_1 and type(NT_1) == "table" and NT_1.ok == true
                if NU then
                    NS_2, NT_2 = pcall(function()
                        return Bn.SacrificeRequest:InvokeServer("confirm")
                    end)
                    local NU_1 = NS_2 and type(NT_2) == "table" and NT_2.ok == true
                    if NU_1 then
                        pcall(function()
                            Bn.SacrificeRequest:InvokeServer("cutsceneDone")
                        end)
                    end
                end
            end
            task.wait(3)
        end
    end)
end
Cj()
BS = fn644
local function Cp()
    local MovementGroup = Bs.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = Bs.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local function qR(qS)
        local N_ = if not qS:IsA("ProximityPrompt") then 1 else 0
        if N_ == 1 then
            return
        end
        qS.HoldDuration = 0
        qS.MaxActivationDistance = 50
        qS.RequiresLineOfSight = false
    end
    local connection
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in BP:GetDescendants() do
                pcall(qR, descendant)
            end
            connection = BP.DescendantAdded:Connect(function(q1)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(qR, q1)
                end
            end)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    RunService.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = LocalPlayer.Character
            if Character then
                for i, descendant in Character:GetDescendants() do
                    local Ob_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if Ob_2 then
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
        if Toggles.InfJump and Toggles.InfJump.Value then
            local Om_1 = BA()
            if Om_1 then
                Om_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    RunService.RenderStepped:Connect(function(rm)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local Oo_1 = BA()
            if Oo_1 then
                Oo_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local Oo_3 = Bq()
            local Op = BA()
            if Oo_3 and Op then
                Op.PlatformStand = true
                local Op_1 = Vector3.zero
                local CurrentCamera = BP.CurrentCamera
                if CurrentCamera then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        Op_1 += CurrentCamera.CFrame.LookVector
                    end
                    local Ou = if UserInputService:IsKeyDown(Enum.KeyCode.S) then 1 else 0
                    if Ou == 1 then
                        Op_1 -= CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        Op_1 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        Op_1 += CurrentCamera.CFrame.RightVector
                    end
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    Op_1 += Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    Op_1 -= Vector3.new(0, 1, 0)
                end
                Oo_3.AssemblyLinearVelocity = Vector3.zero
                if Op_1.Magnitude > 0 then
                    Oo_3.CFrame = Oo_3.CFrame + Op_1.Unit * Options.FlySpeed.Value * rm
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local Oy = BA()
            if Oy then
                Oy.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local OA = BA()
            if OA then
                OA.WalkSpeed = 16
            end
        end
    end)
    Library:OnUnload(function()
        if connection then
            connection:Disconnect()
        end
        BS()
        local OC = BA()
        if OC then
            OC.PlatformStand = false
            OC.WalkSpeed = 16
        end
    end)
end
Cp()
local function Ca_9()
    local Pl, Pm, Pn, Po, Pp
    local Pr = syn and syn.request
    if not Pr then
        Pr = http and http.request
    end
    if not Pr then
        Pr = http_request
    end
    if not Pr then
        Pr = request
    end
    Pn = Pr
    Pl = function(rU)
        local OH
        local OJ_4
        local OI = Options.WebhookUrl
        local OI_2
        if OI then
            local OJ_1 = Options.WebhookUrl.Value or ""
            OI = tostring(OJ_1)
        end
        local OJ_2 = OI
        local OO = if OJ_2 then 1 else 0
        local OM = 671 * OO + 2392 * (1 - OO)
        local ON = 680 * OO + 1944 * (1 - OO)
        if not ((OM * 2572 + ON * 2085 + OM * ON) % 16777213 == 3599892) then
            OJ_2 = ""
        end
        OH = OJ_2
        if not Pn or OH == "" then
            return false
        end
        OI_2, OJ_4 = pcall(function()
            return Pn({
                Url = OH,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(rU)
            })
        end)
        if not OI_2 then
            return false
        end
        local OI_3 = OJ_4
        if OI_3 then
            OI_3 = OJ_4.StatusCode or OJ_4.Status
        end
        local OJ_5 = OI_3
        local OI_4 = OJ_5 == nil
        if not OI_4 then
            OI_4 = OJ_5 >= 200 and OJ_5 < 300
        end
        return OI_4
    end
    Pm = function()
        if A3("WebhookPingEveryone") then
            return "@everyone"
        end
        local OP = Options.WebhookPingId
        if OP then
            local OQ_1 = Options.WebhookPingId.Value or ""
            OP = tostring(OQ_1):gsub("%D", "")
        end
        local OQ_2 = OP or ""
        if OQ_2 ~= "" then
            return "<@" .. OQ_2 .. ">"
        end
        return nil
    end
    Po = function(sl, sm)
        if not A3("WebhookEnabled") then
            return false
        end
        local OS = sm and Pm()
        local OT = OS or nil
        return Pl({ username = "Tempo Hub", content = OT, embeds = { sl } })
    end
    Pp = function(sp)
        local OY = Library.Unloaded or not A3("WebhookEnabled") or not A3("WebhookFishObtained")
        if OY then
            return
        end
        if type(sp) ~= "table" then
            return
        end
        for k, v in sp do
            if type(v) == "table" then
                local OY_1 = v.name or "Unknown"
                local OZ = tostring(OY_1)
                local OY_2 = v.rarity or "Unknown"
                local O_ = tostring(OY_2)
                local OY_3 = tonumber(v.level) or 0
                local OY_4 = v.typeName or ""
                local O1 = tostring(OY_4)
                local OY_5 = {
                    { name = "Character", value = OZ, inline = true },
                    { name = "Rarity", value = O_, inline = true },
                    { name = "Player", value = LocalPlayer.Name, inline = true }
                }
                if OY_3 > 0 then
                    OY_5[#OY_5 + 1] = { name = "Level", value = tostring(OY_3), inline = true }
                end
                if O1 ~= "" then
                    OY_5[#OY_5 + 1] = { name = "Type", value = O1, inline = true }
                end
                local O0_1 = {
                    title = "Character Obtained",
                    color = A8[O_] or 5793266,
                    fields = OY_5,
                    footer = { text = "Fish an Anime RNG | Tempo Hub" }
                }
                local O3 = O_ == "God" or O_ == "Secret" or O_ == "Omniscient"
                Po(O0_1, O3)
            end
        end
    end
    local WebhookGroup = Bs.Webhook:AddLeftGroupbox("Webhook", "webhook")
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
            local Pb = Options.WebhookUrl
            if Pb then
                local Pc_1 = Options.WebhookUrl.Value or ""
                Pb = tostring(Pc_1)
            end
            if (Pb or "") == "" then
                Library:Notify("Set a webhook URL first")
                return
            end
            if Pl({
                username = "Tempo Hub",
                content = Pm(),
                embeds = {
                    {
                        title = "Webhook Connected",
                        description = "Fish an Anime RNG webhook is working.",
                        color = 5793266,
                        fields = {
                            { name = "Player", value = LocalPlayer.Name, inline = true },
                            { name = "Place", value = tostring(game.PlaceId), inline = true }
                        },
                        footer = { text = "Fish an Anime RNG | Tempo Hub" }
                    }
                }
            }) then
                Library:Notify("Webhook test sent")
            else
                Library:Notify("Webhook test failed")
            end
        end
    })
    local ConfigurationGroup = Bs.Webhook:AddRightGroupbox("Configuration", "list-filter")
    ConfigurationGroup:AddToggle("WebhookFishObtained", { Text = "Character Obtained", Default = true })
    Bn.ShowCatchReward.OnClientEvent:Connect(function(sC)
        if Library.Unloaded then
            return
        end
        Pp(sC)
    end)
    Bn.FishingState.OnClientEvent:Connect(function(sF)
        local Pi = Library.Unloaded or type(sF) ~= "table"
        if Pi then
            return
        end
        local Pi_1 = sF.kind or ""
        local Pj = tostring(Pi_1)
        if Pj == "Completed" then
            if sF.suppressReveal == true then
                return
            end
            Pp(sF.rewards)
        elseif Pj == "GodRevealRewards" then
            Pp(sF.rewards)
        end
    end)
end
Ca_9()
local function Cq()
    local RV, connection2, RX, RY, RZ, Label, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, Sa, Sb, Sc, Sd, Se, connection, Sg
    local MenuGroup = Bs.Settings:AddLeftGroupbox("Menu", "logs")
    R6 = 0
    Se = tick()
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    Label = MenuGroup:AddLabel("AFK triggers: 0")
    Sb = function()
        local CurrentCamera = BP.CurrentCamera
        if not CurrentCamera then
            return
        end
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        R6 += 1
        Se = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. R6)
        end)
    end
    connection2 = LocalPlayer.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(Sb)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local Pw = Toggles.AntiAfk.Value and tick() - Se >= 60
            if Pw then
                pcall(Sb)
            end
        end
    end)
    MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
    MenuGroup:AddToggle("Disable3D", { Text = "Disable 3D Rendering", Default = false })
    MenuGroup:AddToggle("FpsBoost", { Text = "FPS Boost", Default = false })
    MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    local ScriptGroup = Bs.Settings:AddLeftGroupbox("Script", "terminal")
    ScriptGroup:AddButton({
        Text = "Unload Script",
        Func = function()
            Library:Unload()
        end
    })
    Sc = function(tf)
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not tf)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not tf
            end
        end)
        if not tf then
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
    Toggles.AntiGameplayPause:OnChanged(function()
        Sc(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                Sc(true)
            end
        end
    end)
    RZ = false
    R8 = function()
        local PlaceId, JobId
        if RZ then
            return
        end
        RZ = true
        PlaceId, JobId = game.PlaceId, game.JobId
        local PI = pcall(function()
            BR:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer)
        end)
        if not PI then
            pcall(function()
                BR:Teleport(PlaceId, LocalPlayer)
            end)
        end
    end
    task.spawn(function()
        local RobloxPromptGui = game:GetService("CoreGui"):WaitForChild("RobloxPromptGui", 30)
        local PQ = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
        if not PQ then
            return
        end
        PQ.ChildAdded:Connect(function(tL)
            if Library.Unloaded then
                return
            end
            if Toggles.AutoReconnect.Value and tL.Name == "ErrorPrompt" then
                R8()
            end
        end)
    end)
    BR.TeleportInitFailed:Connect(function()
        if Toggles.AutoReconnect.Value then
            RZ = false
            R8()
        end
    end)
    Toggles.Disable3D:OnChanged(function()
        pcall(function()
            RunService:Set3dRenderingEnabled(not Toggles.Disable3D.Value)
        end)
    end)
    R7 = {
        ParticleEmitter = true,
        Trail = true,
        Smoke = true,
        Fire = true,
        Sparkles = true,
        Explosion = true,
        Beam = true,
        PointLight = true,
        SpotLight = true,
        SurfaceLight = true,
        PostEffect = true
    }
    connection = nil
    Sa = nil
    R1 = {}
    RV = setmetatable({}, { __mode = "k" })
    R3 = function(t6, t7, t8)
        local PY_1
        local PX_1
        local PW = RV[t6]
        if not PW then
            PW = {}
            RV[t6] = PW
        end
        if PW[t7] == nil then
            PX_1, PY_1 = pcall(function()
                return t6[t7]
            end)
            if not PX_1 then
                return
            end
            PW[t7] = PY_1
        end
        pcall(function()
            t6[t7] = t8
        end)
    end
    RY = function(uj)
        if R7[uj.ClassName] then
            pcall(function()
                uj.Enabled = false
            end)
        else
            local P3 = if uj:IsA("BasePart") then 1 else 0
            if P3 == 1 then
                R3(uj, "CastShadow", false)
                R3(uj, "Reflectance", 0)
                R3(uj, "Material", Enum.Material.SmoothPlastic)
                local P3_1 = if uj:IsA("MeshPart") then 1 else 0
                if P3_1 == 1 then
                    R3(uj, "TextureID", "")
                end
            else
                local P_ = uj:IsA("Decal") or uj:IsA("Texture")
                if P_ then
                    R3(uj, "Transparency", 1)
                elseif uj:IsA("SpecialMesh") then
                    R3(uj, "TextureId", "")
                elseif uj:IsA("Atmosphere") then
                    R3(uj, "Density", 0)
                end
            end
        end
    end
    R2 = function(up)
        local P4
        local P6_1
        local P5_1
        if up then
            if not Sa then
                P5_1, P6_1 = pcall(function()
                    return Bn.GetSettingsData:InvokeServer()
                end)
                local P7 = P5_1 and type(P6_1) == "table"
                if P7 then
                    Sa = {
                        performanceMode = P6_1.performanceMode == true,
                        disableCharVfx = P6_1.disableCharVfx == true,
                        starsEnabled = P6_1.starsEnabled ~= false,
                        charViewports = P6_1.charViewports ~= false,
                        characterRenderAll = P6_1.characterRenderAll == true
                    }
                else
                    Sa = {
                        performanceMode = false,
                        disableCharVfx = false,
                        starsEnabled = true,
                        charViewports = true,
                        characterRenderAll = false
                    }
                end
            end
            pcall(function()
                Bn.SetPerformanceModeSetting:FireServer(true)
            end)
            pcall(function()
                Bn.SetCharacterVfxSetting:FireServer(true)
            end)
            pcall(function()
                Bn.SetStarsSetting:FireServer(false)
            end)
            pcall(function()
                Bn.SetViewportsSetting:FireServer(false)
            end)
            pcall(function()
                Bn.SetCharacterRenderSetting:FireServer(false)
            end)
            return
        end
        P4 = Sa
        Sa = nil
        if not P4 then
            return
        end
        pcall(function()
            Bn.SetPerformanceModeSetting:FireServer(P4.performanceMode)
        end)
        pcall(function()
            Bn.SetCharacterVfxSetting:FireServer(P4.disableCharVfx)
        end)
        pcall(function()
            Bn.SetStarsSetting:FireServer(P4.starsEnabled)
        end)
        pcall(function()
            Bn.SetViewportsSetting:FireServer(P4.charViewports)
        end)
        pcall(function()
            Bn.SetCharacterRenderSetting:FireServer(P4.characterRenderAll)
        end)
    end
    R4 = function(uO)
        if not uO then
            for k, v in R1 do
                local Qi = k
                local Qk = v
                if Qi and Qk and Qi.Parent == nil and Qk.Parent then
                    pcall(function()
                        Qi.Parent = Qk
                    end)
                end
            end
            table.clear(R1)
            return
        end
        for i, player in Players:GetPlayers() do
            if player ~= LocalPlayer then
                local Character = player.Character
                if Character and Character.Parent and not R1[Character] then
                    R1[Character] = Character.Parent
                    pcall(function()
                        Character.Parent = nil
                    end)
                end
            end
        end
    end
    R0 = function()
        if connection then
            connection:Disconnect()
            connection = nil
        end
        R2(false)
        R4(false)
        for k, v in RV do
            local Qy = k
            for k, v in v do
                local QE = k
                local QG = v
                pcall(function()
                    Qy[QE] = QG
                end)
            end
        end
        table.clear(RV)
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end)
        pcall(function()
            Lighting.GlobalShadows = true
        end)
    end
    Sd = function(vi)
        R0()
        if not vi then
            return
        end
        R2(true)
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
        pcall(function()
            UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
        end)
        R3(Lighting, "GlobalShadows", false)
        R3(Lighting, "EnvironmentDiffuseScale", 0)
        R3(Lighting, "EnvironmentSpecularScale", 0)
        R3(Lighting, "FogEnd", 9000000000)
        R3(Lighting, "Brightness", 1)
        local Terrain = BP.Terrain
        R3(Terrain, "Decoration", false)
        R3(Terrain, "WaterWaveSize", 0)
        R3(Terrain, "WaterWaveSpeed", 0)
        R3(Terrain, "WaterReflectance", 0)
        R3(Terrain, "WaterTransparency", 1)
        R4(true)
        task.spawn(function()
            local descendants = BP:GetDescendants()
            for k, v in descendants do
                if Library.Unloaded or not Toggles.FpsBoost.Value then
                    return
                end
                pcall(RY, v)
                if k % 400 == 0 then
                    task.wait()
                end
            end
            for i, descendant in Lighting:GetDescendants() do
                pcall(RY, descendant)
            end
        end)
        connection = game.DescendantAdded:Connect(function(vF)
            if not Toggles.FpsBoost.Value then
                return
            end
            pcall(RY, vF)
            if vF:IsA("Model") then
                local QV = Players:GetPlayerFromCharacter(vF)
                if QV and QV ~= LocalPlayer then
                    R4(true)
                end
            end
        end)
    end
    Toggles.FpsBoost:OnChanged(function()
        Sd(Toggles.FpsBoost.Value)
    end)
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("TempoHub")
    ThemeManager:SaveDefault("Evil Hello Kitty")
    ThemeManager:ApplyToTab(Bs.Settings)
    ThemeManager:LoadDefault()
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    SaveManager:SetFolder("TempoHub/FishAnAnimeRNG")
    local Sh_2 = SaveManager:BuildConfigSection(Bs.Settings)
    SaveManager:LoadAutoloadConfig()
    R9 = function(vU, vV)
        local Q4_1 = (vU == "Toggle" and Toggles or Options)[vV]
        local Q3_2 = type(Q4_1) == "table" and Q4_1.Type == vU
        return Q3_2 and Q4_1 or nil
    end
    R5 = function(v1, v2)
        local Type = v2.Type
        if Type == "Toggle" then
            return { idx = v1, type = "Toggle", value = v2.Value == true }
        elseif Type == "Slider" then
            return { idx = v1, type = "Slider", value = tostring(v2.Value) }
        elseif Type == "Dropdown" then
            return { idx = v1, type = "Dropdown", multi = v2.Multi == true, value = v2.Value }
        elseif Type == "Input" then
            local Q8 = v2.Value or ""
            return { idx = v1, type = "Input", text = tostring(Q8) }
        elseif Type == "ColorPicker" then
            return { idx = v1, type = "ColorPicker", value = v2.Value:ToHex(), transparency = v2.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = v1,
                type = "KeyPicker",
                mode = v2.Mode,
                key = v2.Value,
                modifiers = v2.Modifiers,
                toggled = v2.Toggled
            }
        else
            return nil
        end
    end
    Sg = function()
        local Re = {}
        for k, v in { Toggles, Options } do
            for k, v in v do
                local Rf = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if Rf then
                    local Rf_1 = R5(k, v)
                    if Rf_1 then
                        Re[#Re + 1] = Rf_1
                    end
                end
            end
        end
        table.sort(Re, function(we, wf)
            if we.type ~= wf.type then
                return we.type < wf.type
            end
            return we.idx < wf.idx
        end)
        return { objects = Re }
    end
    RX = function(wh)
        local Ry
        Ry = nil
        local Rz = type(wh) ~= "table" or type(wh.idx) ~= "string"
        local RD = if Rz then 1 else 0
        local RB = 957 * RD + 2953 * (1 - RD)
        local RC = 577 * RD + 2214 * (1 - RD)
        if not ((RB * 3999 + RC * 1565 + RB * RC) % 16777213 == 5282237) then
            Rz = type(wh.type) ~= "string"
        end
        local RD_1 = if Rz then 1 else 0
        local RB_1 = 3690 * RD_1 + 757 * (1 - RD_1)
        local RC_1 = 3011 * RD_1 + 1417 * (1 - RD_1)
        if not ((RB_1 * 388 + RC_1 * 1616 + RB_1 * RC_1) % 16777213 == 630873) then
            Rz = SaveManager.Ignore[wh.idx]
        end
        if Rz then
            return false
        end
        Ry = R9(wh.type, wh.idx)
        if not Ry then
            return false
        end
        local Rz_1 = pcall(function()
            if wh.type == "Input" then
                if type(wh.text) ~= "string" then
                    return
                end
                Ry:SetValue(wh.text)
            elseif wh.type == "ColorPicker" then
                Ry:SetValueRGB(Color3.fromHex(wh.value), wh.transparency)
            elseif wh.type == "KeyPicker" then
                Ry:SetValue({ wh.key, wh.mode, wh.modifiers })
                if wh.mode == "Toggle" and wh.toggled ~= nil then
                    Ry.Toggled = wh.toggled
                    Ry:Update()
                end
            else
                Ry:SetValue(wh.value)
            end
        end)
        return Rz_1
    end
    Sh_2:AddDivider()
    Sh_2:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    Sh_2:AddButton("Export Config to Clipboard", function()
        local RF_1
        local RE_1
        RE_1, RF_1 = pcall(HttpService.JSONEncode, HttpService, Sg())
        if not RE_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local RE_2 = setclipboard or toclipboard
        local RE_3 = type(RE_2) ~= "function" or not pcall(RE_2, RF_1)
        if RE_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    Sh_2:AddButton("Import Config from Clipboard Text", function()
        local RK_1
        local RI = Options.SaveManager_ImportSource.Value or ""
        local RI_1
        local RJ = tostring(RI):match("^%s*(.-)%s*$")
        if RJ == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        RI_1, RK_1 = pcall(HttpService.JSONDecode, HttpService, RJ)
        local RJ_1 = not RI_1 or type(RK_1) ~= "table" or type(RK_1.objects) ~= "table"
        if RJ_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local RI_2 = 0
        for k, v in RK_1.objects do
            if RX(v) then
                RI_2 += 1
            end
        end
        if RI_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local RK_2 = RI_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(RI_2, RK_2), 6)
    end)
    if Toggles.HideUiOnStart.Value then
        Library:Toggle(false)
    end
    if Toggles.FpsBoost.Value then
        Sd(true)
    end
    Sc(Toggles.AntiGameplayPause.Value)
    Library:OnUnload(function()
        connection2:Disconnect()
        Sc(false)
        R0()
        pcall(function()
            RunService:Set3dRenderingEnabled(true)
        end)
    end)
end
Cq()
end)(...)

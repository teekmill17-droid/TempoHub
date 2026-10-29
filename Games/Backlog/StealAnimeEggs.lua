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
getgenv().TempoHoodSubtitle = "STEAL ANIME EGGS"
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
local qh
local pW
local ph
local qk
local pZ
local pG
local pJ
local Options
local pq
local pM
local pP
local Toggles
local pa
local pw
local EquipBestPets
local qg
local pz
local pV
local qj
local GetPlotCapacity
local pF
local GetPlotPets
local pC
local Library
local p3
local pm
local pO
local p9
local o9
local pR
local qc
local pc
local py
local pU
local pf
local pX
local p_
local pE
local pl
local State
local p5
local EggConfigurations
local pr
local ClaimIndexReward
local pN
local pu
local pQ
local qb
local px
local function fn3(bU)
    local Eggs = pZ:FindFirstChild("Eggs")
    local sp = Eggs and Eggs:FindFirstChild(bU)
    if sp then
        local BasePart = sp:FindFirstChildWhichIsA("BasePart", true)
        if BasePart then
            return BasePart.Position
        end
        return pP[bU]
    end
    return pP[bU]
end
local function fn12(gG)
    return (tostring(gG):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
end
local function fn18(gw, gx)
    local vS = false
    if pm(setclipboard) then
        vS = pcall(setclipboard, gw)
    elseif pm(toclipboard) then
        vS = pcall(toclipboard, gw)
    end
    if vS and gx then
        Library:Notify(gx, 3)
    elseif not vS then
        Library:Notify("Clipboard unavailable", 3)
    end
    return vS
end
local function fn32()
    return not pM.Unloaded
end
local function fn66(fY)
    local Enabled = State.Enabled
    local vA = fY and true or false
    Enabled.EquipBest = vA
    if State.Enabled.EquipBest then
        pJ("EquipBest", 2.5, pq)
    else
        local Gens = State.Gens
        Gens.EquipBest = Gens.EquipBest + 1
    end
end
local function fn99()
    if not pw() then
        return true
    end
    py(pR)
    if not pQ(CFrame.new(pR + Vector3.new(0, 3, 0))) then
        return false
    end
    local s3 = os.clock() + 3
    while true do
        local s4 = qk() and pw() and os.clock() < s3
        if s4 then
            pQ(CFrame.new(pR + Vector3.new(0, 3, 0)))
            task.wait(0.15)
            continue
        end
        break
    end
    return not pw()
end
local function fn114()
    local sg = pZ:FindFirstChild("Plot_" .. qc.Name)
    if sg then
        return sg
    end
    for i, child in ipairs(pZ:GetChildren()) do
        if child.Name == "Plot_" .. qc.Name then
            return child
        end
    end
    return nil
end
local function fn140()
    local leaderstats = qc:FindFirstChild("leaderstats")
    local tJ = leaderstats and leaderstats:FindFirstChild("Money")
    local tI_1 = tJ
    if tJ then
        tJ = tI_1:IsA("ValueBase")
    end
    if tJ then
        local tJ_1 = (tonumber(tI_1.Value))
        local tQ = if tJ_1 then 1 else 0
        local tO = 960 * tQ + 817 * (1 - tQ)
        local tP = 678 * tQ + 2366 * (1 - tQ)
        if not ((tO * 1100 + tP * 3584 + tO * tP) % 16777213 == 4136832) then
            tJ_1 = 0
        end
        return tJ_1
    end
    return 0
end
local function fn177(al, am)
    return al.order < am.order
end
local function fn225(cJ)
    local s6 = cJ and cJ:IsA("Tool")
    if not s6 then
        return false
    end
    local s6_1 = cJ:GetAttribute("IsBat") or cJ:GetAttribute("IsTreadmill") or cJ:GetAttribute("IsTrapTool")
    if s6_1 then
        return false
    end
    local attr = cJ:GetAttribute("OriginalName")
    local s7 = attr == ""
    local s8 = type(attr) ~= "string"
    local tc = if s8 then 1 else 0
    local ta = 558 * tc + 736 * (1 - tc)
    local tb = 1724 * tc + 699 * (1 - tc)
    if not ((ta * 457 + tb * 1550 + ta * tb) % 16777213 == 3889198) then
        s8 = s7
    end
    if s8 then
        return false
    elseif string.sub(attr, -3) == "Egg" then
        return true
    else
        local s6_3 = cJ:GetAttribute("HatchConnected") == true and cJ:GetAttribute("Rarity") == "None"
        return s6_3
    end
end
local function fn233()
    pG(pa.Main)
    local StealGroup = pa.Main:AddLeftGroupbox("Steal", "//")
    StealGroup:AddToggle("AutoSteal", { Text = "Auto Steal", Default = false })
    StealGroup:AddDropdown("StealZoneFilter", { Text = "Zone Filter", Values = p3, Default = table.clone(p3), Multi = true, AllowNull = true })
    StealGroup:AddDropdown("StealRarityFilter", { Text = "Rarity Filter", Values = pN, Default = table.clone(pN), Multi = true, AllowNull = true })
    local EggsGroup = pa.Main:AddLeftGroupbox("Eggs", "egg")
    EggsGroup:AddToggle("AutoPlaceEggs", { Text = "Auto Place Eggs", Default = false })
    EggsGroup:AddToggle("AutoHatchEggs", { Text = "Auto Hatch Eggs", Default = false })
    local PetsGroup = pa.Main:AddRightGroupbox("Pets", "paw-print")
    PetsGroup:AddToggle("AutoClaimIndex", { Text = "Auto Claim Index", Default = false })
    PetsGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false })
    local ShopGroup = pa.Main:AddRightGroupbox("Shop", "shopping-bag")
    ShopGroup:AddToggle("AutoBuyTrails", { Text = "Auto Buy Trails", Default = false })
    local SellGroup = pa.Main:AddRightGroupbox("Sell", "banknote")
    SellGroup:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
    SellGroup:AddDropdown("SellMode", { Text = "Sell Mode", Values = pf, Default = 2 })
    Toggles.AutoSteal:OnChanged(function(j_)
        pM.SetSteal(j_)
    end)
    Options.StealZoneFilter:OnChanged(function(j3)
        pM.SetZoneFilter(j3)
    end)
    Options.StealRarityFilter:OnChanged(function(j5)
        pM.SetRarityFilter(j5)
    end)
    Toggles.AutoPlaceEggs:OnChanged(function(j7)
        pM.SetPlace(j7)
    end)
    Toggles.AutoHatchEggs:OnChanged(function(j9)
        pM.SetHatch(j9)
    end)
    Toggles.AutoClaimIndex:OnChanged(function(kb)
        pM.SetClaimIndex(kb)
    end)
    Toggles.AutoEquipBest:OnChanged(function(kd)
        pM.SetEquipBest(kd)
    end)
    Toggles.AutoBuyTrails:OnChanged(function(kf)
        pM.SetBuyTrails(kf)
    end)
    Toggles.AutoSell:OnChanged(function(kh)
        pM.SetSell(kh)
    end)
    Options.SellMode:OnChanged(function(kj)
        pM.SetSellMode(kj)
    end)
    pM.SetZoneFilter(Options.StealZoneFilter.Value)
    pM.SetRarityFilter(Options.StealRarityFilter.Value)
    pM.SetSellMode(Options.SellMode.Value)
end
local function fn269()
    local tR = {}
    local Trails = qc:FindFirstChild("Trails")
    if not Trails then
        return tR
    end
    for i, child in ipairs(Trails:GetChildren()) do
        if child.Name ~= "Equipped" then
            tR[child.Name] = true
        end
    end
    return tR
end
local function fn279(bl)
    if not pc(State.RarityFilter) then
        return true
    end
    return State.RarityFilter[bl] == true
end
local function fn296(gI, gJ)
    return string.format('<font color="%s">%s</font>', gJ, pl(gI))
end
local function fn313(fI)
    local Enabled = State.Enabled
    local u8 = fI and true or false
    Enabled.Steal = u8
    if State.Enabled.Steal then
        pJ("Steal", 0.25, ph)
    else
        local Gens = State.Gens
        Gens.Steal = Gens.Steal + 1
    end
end
local function fn325(fQ)
    local Enabled = State.Enabled
    local vm = fQ and true or false
    Enabled.Hatch = vm
    if State.Enabled.Hatch then
        pJ("Hatch", 0.5, pr)
    else
        local Gens = State.Gens
        Gens.Hatch = Gens.Hatch + 1
    end
end
local function fn334(bb)
    if type(bb) ~= "table" then
        return false
    end
    for k, v in pairs(bb) do
        if v then
            return true
        end
    end
    return false
end
local function fn337(f1)
    local Enabled = State.Enabled
    local vE = f1 and true or false
    Enabled.BuyTrails = vE
    if State.Enabled.BuyTrails then
        pJ("BuyTrails", 2, pO)
    else
        local Gens = State.Gens
        Gens.BuyTrails = Gens.BuyTrails + 1
    end
end
local function fn342()
    return o9.CoreGui
end
local function fn396(N)
    return type(N) == "function"
end
local function fn429()
    gethui = p5
end
local function fn450(K)
    local ru = typeof(cloneref) == "function" and typeof(K) == "Instance"
    if ru then
        return cloneref(K)
    end
    return K
end
local function fn466(a6)
    local rI = not a6 or not a6:IsA("ProximityPrompt") or not a6.Enabled
    if rI then
        return false
    end
    local rM = if not pm(fireproximityprompt) then 1 else 0
    if rM == 1 then
        return false
    end
    local rI_1 = pcall(fireproximityprompt, a6)
    return rI_1
end
local function fn470()
    local tv_1
    local ts_1
    local tu_1
    local tt_1
    ts_1, tt_1 = pcall(function()
        return GetPlotPets:InvokeServer()
    end)
    tu_1, tv_1 = pcall(function()
        return GetPlotCapacity:InvokeServer()
    end)
    local tw = ts_1
    local ts_2 = 0
    if tw then
        tw = type(tt_1) == "table"
    end
    if tw then
        for k in pairs(tt_1) do
            ts_2 += 1
        end
    end
    local tt_2 = tu_1 and type(tv_1) == "number"
    local tt_3 = tt_2 and tv_1
    local tH = if tt_3 then 1 else 0
    local tF = 3166 * tH + 467 * (1 - tH)
    local tG = 3147 * tH + 2790 * (1 - tH)
    if not ((tF * 441 + tG * 2705 + tF * tG) % 16777213 == 3095030) then
        tt_3 = nil
    end
    return ts_2, tt_3
end
local function fn489(bw)
    local r6 = bw == ""
    local r7 = type(bw) ~= "string" or r6
    if r7 then
        return nil
    end
    local EggSettings = EggConfigurations.EggSettings
    local r7_1 = type(EggSettings) == "table" and EggSettings[bw]
    local r7_2 = type(r7_1) == "table" and type(r7_1.Rarity) == "string"
    if r7_2 then
        return r7_1.Rarity
    end
    return nil
end
local function fn543(aS)
    local rB = pu()
    if not rB then
        return false
    end
    rB.AssemblyLinearVelocity = Vector3.zero
    rB.AssemblyAngularVelocity = Vector3.zero
    rB.CFrame = aS
    return true
end
local function fn569(gM, gN, gO)
    return string.format("<b>%s</b> %s %s", gM, qj("-", "#5a6070"), qj(gN, gO))
end
local function fn597(f6)
    State.ZoneFilter = pX(f6)
end
local function fn601(fU)
    local Enabled = State.Enabled
    local vt = fU and true or false
    Enabled.ClaimIndex = vt
    if State.Enabled.ClaimIndex then
        pJ("ClaimIndex", 3, pU)
    else
        local Gens = State.Gens
        Gens.ClaimIndex = Gens.ClaimIndex + 1
    end
end
local function fn612(f9)
    if f9 == "Equipped" or f9 == "Inventory" then
        State.SellMode = f9
    end
end
local function fn613()
    for k in pairs(State.Gens) do
        State.Gens[k] += 1
        State.Enabled[k] = false
    end
end
local function fn614()
    local t_ = not qk() or not State.Enabled.Steal
    if t_ then
        return
    end
    if not pm(fireproximityprompt) then
        return
    end
    local t__1 = os.clock()
    if t__1 - State.LastStealAt < 0.35 then
        return
    end
    if pw() then
        qg()
        State.LastStealAt = os.clock()
        return
    end
    local t__2 = {}
    for i, v in ipairs(p3) do
        if qb(p_[v]) then
            table.insert(t__2, v)
        end
    end
    if #t__2 == 0 then
        return
    end
    State.StealZoneCursor = State.StealZoneCursor % #t__2 + 1
    local StealZoneCursor = State.StealZoneCursor
    local t1 = #t__2 - 1
    local uf = 0
    while uf <= t1 do
        local ug = uf
        local t1_1 = not qk() or not State.Enabled.Steal
        if t1_1 then
            return
        end
        if pw() then
            qg()
            return
        end
        local t2 = p_[t__2[(StealZoneCursor + ug - 1) % #t__2 + 1]]
        local t1_3 = pF(t2)
        if t1_3 then
            py(t1_3)
            pQ(CFrame.new(t1_3 + Vector3.new(0, 5, 0)))
            task.wait(0.15)
        end
        local t1_4 = not qk() or not State.Enabled.Steal
        if t1_4 then
            return
        end
        local t1_5 = p9(t2)
        for i, v in ipairs(t1_5) do
            local t1_6 = not qk() or not State.Enabled.Steal
            if t1_6 then
                return
            end
            if pw() then
                qg()
                return
            end
            if v.position then
                pQ(CFrame.new(v.position + Vector3.new(0, 3, 0)))
                task.wait(0.08)
            end
            if pE(v.prompt) then
                State.LastStealAt = os.clock()
                task.wait(0.35)
                if pw() then
                    qg()
                end
                return
            end
        end
        uf += 1
    end
end
local function fn615(bf)
    local rU = {}
    if type(bf) == "table" then
        for k, v in pairs(bf) do
            local rV = v == true and type(k) == "string"
            if rV then
                rU[k] = true
            elseif type(v) == "string" then
                rU[v] = true
            end
        end
    end
    return rU
end
local function fn726()
    local Character = qc.Character
    local s1 = Character ~= nil and Character:GetAttribute("CarryingEgg") == true
    return s1
end
local function fn727(bD)
    local EggSettings = EggConfigurations.EggSettings
    local sa = type(EggSettings) == "table" and EggSettings[bD]
    local sa_1 = type(sa) == "table" and type(sa.HatchTime) == "number"
    if sa_1 then
        return sa.HatchTime
    end
    local HatchTimeByRarity = EggConfigurations.HatchTimeByRarity
    local sa_2 = pC(bD)
    local sb = type(HatchTimeByRarity) == "table" and sa_2 and type(HatchTimeByRarity[sa_2]) == "number"
    if sb then
        return HatchTimeByRarity[sa_2]
    end
    return nil
end
local function fn729()
    local Character = qc.Character
    if not Character then
        return nil
    end
    return Character:FindFirstChildOfClass("Humanoid")
end
local function fn732()
    local uJ = not qk() or not State.Enabled.ClaimIndex
    if uJ then
        return
    end
    pcall(function()
        ClaimIndexReward:InvokeServer("ALL")
    end)
end
local function fn733()
    pG(pa.Player)
    local MovementGroup = pa.Player:AddLeftGroupbox("Movement", "person-standing")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "Noclip", Default = false })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = pa.Player:AddRightGroupbox("Fly", "plane")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    Toggles.WalkSpeedEnabled:OnChanged(function(jy)
        pM.SetWalkSpeedEnabled(jy)
    end)
    Options.WalkSpeed:OnChanged(function(jC)
        pM.SetWalkSpeedValue(jC)
    end)
    Toggles.InfJump:OnChanged(function(jE)
        pM.SetInfJump(jE)
    end)
    Toggles.NoClip:OnChanged(function(jG)
        pM.SetNoClip(jG)
    end)
    Toggles.InstantProximityPrompt:OnChanged(function(jI)
        pM.SetInstantProximityPrompt(jI)
    end)
    Toggles.Fly:OnChanged(function(jK)
        pM.SetFly(jK)
    end)
    Options.FlySpeed:OnChanged(function(jM)
        pM.SetFlySpeed(jM)
    end)
end
local function fn766(f2)
    local Enabled = State.Enabled
    local vI = f2 and true or false
    Enabled.Sell = vI
    if State.Enabled.Sell then
        pJ("Sell", 1.5, px)
    else
        local Gens = State.Gens
        Gens.Sell = Gens.Sell + 1
    end
end
local function fn795(gC)
    local DiscordGroup = gC:AddLeftGroupbox("Discord", "message-circle")
    DiscordGroup:AddDiscordBox(nil, {
        Banner = 95892854151512,
        Avatar = 132608042600488,
        Title = "Tempo Hub",
        Subtitle = "Dupes, keyless scripts and updates",
        Status = "online",
        Accent = Color3.fromRGB(88, 101, 242),
        Link = qh,
        Buttons = { { Text = "Copy Discord Invite", Icon = "copy", Copy = true } }
    })
    return DiscordGroup
end
local function fn824()
    local td = {}
    local Character = qc.Character
    if Character then
        for i, child in ipairs(Character:GetChildren()) do
            if pz(child) then
                table.insert(td, child)
            end
        end
    end
    for i, child in ipairs(qc.Backpack:GetChildren()) do
        if pz(child) then
            table.insert(td, child)
        end
    end
    return td
end
local function fn867()
    local Character = qc.Character
    if not Character then
        return nil
    end
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local rw_1 = HumanoidRootPart and HumanoidRootPart:IsA("BasePart")
    if rw_1 then
        return HumanoidRootPart
    end
    return nil
end
local function fn906(f3)
    State.RarityFilter = pX(f3)
end
local function fn931(fM)
    local Enabled = State.Enabled
    local vf = fM and true
    local vj = if vf then 1 else 0
    local vh = 1751 * vj + 1231 * (1 - vj)
    local vi = 2217 * vj + 4085 * (1 - vj)
    if not ((vh * 1560 + vi * 2038 + vh * vi) % 16777213 == 11131773) then
        vf = false
    end
    Enabled.Place = vf
    if State.Enabled.Place then
        pJ("Place", 0.5, pV)
    else
        local Gens = State.Gens
        Gens.Place = Gens.Place + 1
    end
end
local function fn932()
    local uL = not qk() or not State.Enabled.EquipBest
    if uL then
        return
    end
    local uL_1 = os.clock()
    if uL_1 - State.LastEquipBestAt < 2 then
        return
    end
    local uL_2 = pcall(function()
        EquipBestPets:FireServer()
    end)
    if uL_2 then
        State.LastEquipBestAt = os.clock()
    end
end
local function fn1000(bp)
    if not pc(State.ZoneFilter) then
        return true
    end
    local r3 = pW[bp]
    if r3 and State.ZoneFilter[r3] == true then
        return true
    end
    return State.ZoneFilter[bp] == true
end
o9 = nil
pa = nil
pc = nil
EquipBestPets = nil
pf = nil
ph = nil
pl = nil
pm = nil
Options = nil
pq = nil
pr = nil
Toggles = nil
pu = nil
pw = nil
px = nil
py = nil
pz = nil
pC = nil
pE = nil
pF = nil
pG = nil
State = nil
Library = nil
pJ = nil
EggConfigurations = nil
pM = nil
pN = nil
pO = nil
pP = nil
pQ = nil
pR = nil
pU = nil
pV = nil
pW = nil
local pb, pe, pg, pi, RequestSell, pk, po, RequestHatch, ps, pv, SaveManager, pB, ThemeManager, pL, pS, pT
pX = nil
GetPlotCapacity = nil
pZ = nil
p_ = nil
GetPlotPets = nil
p3 = nil
p5 = nil
ClaimIndexReward = nil
p9 = nil
qb = nil
qc = nil
qg = nil
qh = nil
qj = nil
qk = nil
local p1, p2, p4, p6, p7, qa, qd, qe, TrailAction, qi, qp
if not game:IsLoaded() then
    game.Loaded:Wait()
end
o9, qc, p5 = nil, nil, nil
local ql = 1
repeat
    local Au = bit32.rrotate(bit32.bxor(bit32.lrotate(ql, 25), string.byte(tostring(o9))), 4)
    if bit32.bxor(bit32.lrotate(bit32.bxor(Au, 3098381163), 16), 2339092653) == bit32.lrotate(Au, 16) then
        o9 = {}
        o9.Players = game:GetService("Players")
        o9.ReplicatedStorage = game:GetService("ReplicatedStorage")
        o9.RunService = game:GetService("RunService")
        o9.UserInputService = game:GetService("UserInputService")
        o9.VirtualUser = game:GetService("VirtualUser")
        o9.HttpService = game:GetService("HttpService")
        o9.TeleportService = game:GetService("TeleportService")
        o9.Workspace = game:GetService("Workspace")
        o9.Lighting = game:GetService("Lighting")
        o9.Stats = game:GetService("Stats")
        o9.CoreGui = game:GetService("CoreGui")
        o9.ProximityPromptService = game:GetService("ProximityPromptService")
        qc = o9.Players.LocalPlayer
        p5 = fn342
    else
        p5 = {}
        p5.Players = game:GetService("Players")
        p5.ReplicatedStorage = game:GetService("ReplicatedStorage")
        p5.RunService = game:GetService("RunService")
        p5.UserInputService = game:GetService("UserInputService")
        p5.VirtualUser = game:GetService("VirtualUser")
        p5.HttpService = game:GetService("HttpService")
        p5.TeleportService = game:GetService("TeleportService")
        p5.Workspace = game:GetService("Workspace")
        p5.Lighting = game:GetService("Lighting")
        p5.Stats = game:GetService("Stats")
        p5.CoreGui = game:GetService("CoreGui")
        p5.ProximityPromptService = game:GetService("ProximityPromptService")
        o9 = p5.Players.LocalPlayer
        qc = fn342
    end
    ql = (ql + 0) % 4
until (ql * 3 + 3) % 4 == 2
if getgenv then
    getgenv().gethui = p5
end
pM, State, pZ, EggConfigurations, RequestHatch, RequestSell, EquipBestPets, TrailAction, ClaimIndexReward, GetPlotPets, GetPlotCapacity, pR, pN, pm, qk = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pcall(fn429)
local function qn(i)
    local rn
    local rl
    local rm
    rl = nil
    rm = nil
    rn = nil
    local ro = i ~= ""
    local rp = type(i) == "string" and ro
    assert(rp, "Namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    rl = getgenv()
    assert(type(rl) == "table", "getgenv did not return a table")
    local ro_1 = rl[i]
    if ro_1 ~= nil then
        local rp_1 = type(ro_1) == "table" and type(ro_1.Unload) == "function"
        assert(rp_1, "Namespace is occupied")
        ro_1.Unload()
        assert(rl[i] == nil, "Previous instance did not release its namespace")
    end
    rm = {}
    rn = { State = {}, Unloaded = false }
    rn.Track = function(o)
        assert(type(o) == "function", "Cleanup must be callable")
        if rn.Unloaded then
            o()
        else
            table.insert(rm, o)
        end
        return o
    end
    rn.Unload = function()
        local rb_1
        local ra_1
        if rn.Unloaded then
            return
        end
        rn.Unloaded = true
        local q8 = {}
        local rf = #rm
        local re = -1
        while false and rf <= 1 or true and rf >= 1 do
            local rg = rf
            local q9_1 = table.remove(rm, rg)
            ra_1, rb_1 = pcall(q9_1)
            if not ra_1 then
                table.insert(q8, tostring(rb_1))
            end
            rf += re
        end
        table.clear(rn.State)
        if #q8 > 0 then
            error("Cleanup incomplete: " .. table.concat(q8, "; "), 0)
        end
        if rl[i] == rn then
            rl[i] = nil
        end
    end
    rl[i] = rn
    return rn
end
local function qu(B, C)
    local rs = type(B) == "table" and type(B.Track) == "function"
    assert(rs, "FeatureAPI required")
    local rs_1 = type(C) == "table" and type(C.OnUnload) == "function"
    assert(rs_1, "UI library required")
    assert(type(C.Unload) == "function", "UI unload required")
    B.Track(function()
        if not C.Unloaded then
            C:Unload()
        end
    end)
    C:OnUnload(function()
        B.Unload()
    end)
end
pM = qn("TempoStealAnimeEggs")
State = pM.State
pm = fn396
qk = fn32
local qq = fn450(o9.ReplicatedStorage)
pZ = fn450(o9.Workspace)
local qo = qq:WaitForChild("Events", 30)
assert(qo, "Events missing")
local Modules = qq:WaitForChild("Modules", 30)
assert(Modules, "Modules missing")
EggConfigurations = require(Modules:WaitForChild("EggConfigurations"))
local qr = require(Modules:WaitForChild("RarityConfigurations"))
local ZoneConfigurations = require(Modules:WaitForChild("ZoneConfigurations"))
local qt = require(Modules:WaitForChild("TrailConfigurations"))
RequestHatch = qo:WaitForChild("RequestHatch")
RequestSell = qo:WaitForChild("RequestSell")
EquipBestPets = qo:WaitForChild("EquipBestPets")
TrailAction = qo:WaitForChild("TrailAction")
ClaimIndexReward = qo:WaitForChild("ClaimIndexReward")
GetPlotPets = qo:WaitForChild("GetPlotPets")
GetPlotCapacity = qo:WaitForChild("GetPlotCapacity")
pR = Vector3.new(8, 3, 123)
if not GetPlotCapacity or not pR or (not qt or State) or State and qt and (not pR or pR) or (qt and qt or (not GetPlotCapacity or not GetPlotPets)) and ((not GetPlotPets or not GetPlotPets) and (pR and State)) or not (not GetPlotCapacity or not pR or (not qt or State) or State and qt and (not pR or pR) or (qt and qt or (not GetPlotCapacity or not GetPlotPets)) and ((not GetPlotPets or not GetPlotPets) and (pR and State))) then
    pN = {}
end
local qv = {}
for k, v in pairs(qr) do
    local ql_2 = type(v) == "table" and type(v.Order) == "number"
    if ql_2 then
        table.insert(qv, { name = k, order = v.Order })
    end
end
table.sort(qv, fn177)
for i, v in ipairs(qv) do
    table.insert(pN, v.name)
end
p3, p_, pW, pP = nil, nil, nil, nil
local ql_3 = 15
repeat
    if (ql_3 * 1 + 1) % 2 + 1 <= 1 then
        local qm_2 = (vector.create((ql_3 * 1 + 1) % 11 + 1, (ql_3 * 7 + 6) % 13 + 1, (ql_3 * 2 + 7) % 17 + 1))
        local qn_1 = (vector.create((ql_3 * 1 + 7) % 11 + 1, (ql_3 * 1 + 5) % 13 + 1, (ql_3 * 8 + 11) % 17 + 1))
        local As = vector.cross(qm_2, qn_1)
        local At = vector.dot(qm_2, qn_1)
        if vector.dot(As, As) + At * At == vector.dot(qm_2, qm_2) * vector.dot(qn_1, qn_1) + 2 then
            pP = {}
        else
            p3 = {}
        end
        ql_3 = (ql_3 + 9) % 16
    else
        local qm_3 = {
            "bsukldqz",
            "xprl",
            "etzca",
            "wnuisfqvhw",
            "yzyrmqj",
            "ipm",
            "jze",
            "rlrgdwyxqx",
            "blfzpu",
            "utrrtsff",
            "jjlklh",
            "wvo"
        }
        local Ar = ql_3
        local qn_2 = qm_3[Ar % 12 + 1]
        if qn_2:len() <= qn_2:reverse():rep(Ar % 3 + 2):len() then
            p_ = {}
            pW = {}
            pP = {
                Zone1 = Vector3.new(-7.1, 0.5, 200.5),
                Zone2 = Vector3.new(39.6, 0.4, 373.3),
                Zone3 = Vector3.new(0.8, 0.4, 535),
                Zone4 = Vector3.new(-6.2, 0.4, 801.8),
                Zone5 = Vector3.new(0.1, 0.4, 1130),
                Zone6 = Vector3.new(24.5, 0.5, 1459.3),
                Zone7 = Vector3.new(25, 11.6, 1795.8),
                Zone8 = Vector3.new(33.7, 0.4, 2546.8),
                Zone9 = Vector3.new(4, 0.4, 3279.2),
                Zone10 = Vector3.new(25, 11.6, 3841),
                Zone11 = Vector3.new(25, 11.6, 4888.7)
            }
        else
            pP = {}
            p_ = {}
            pW = {
                Zone4 = Vector3.new(-6.2, 0.4, 801.8),
                Zone6 = Vector3.new(24.5, 0.5, 1459.3),
                Zone8 = Vector3.new(33.7, 0.4, 2546.8),
                Zone1 = Vector3.new(-7.1, 0.5, 200.5),
                Zone3 = Vector3.new(0.8, 0.4, 535),
                Zone5 = Vector3.new(0.1, 0.4, 1130),
                Zone10 = Vector3.new(25, 11.6, 3841),
                Zone11 = Vector3.new(25, 11.6, 4888.7),
                Zone7 = Vector3.new(25, 11.6, 1795.8),
                Zone9 = Vector3.new(4, 0.4, 3279.2),
                Zone2 = Vector3.new(39.6, 0.4, 373.3)
            }
        end
        ql_3 = (ql_3 + 15) % 16
    end
until (ql_3 * 3 + 7) % 16 == 12
local qT = 1
while qT <= 11 do
    local qU = qT
    local ql_4 = "Zone" .. tostring(qU)
    local qm_4 = ZoneConfigurations[ql_4]
    local qn_3 = type(qm_4) == "table" and qm_4.DisplayName
    local qm_5 = qn_3 or ql_4
    local qm_6 = ql_4 .. " - " .. tostring(qm_5)
    table.insert(p3, qm_6)
    p_[qm_6] = ql_4
    pW[ql_4] = qm_6
    qT += 1
end
pf, qi = nil, nil
local qn_5 = 2
repeat
    local AD = bit32.rrotate(bit32.bxor(bit32.lrotate(qn_5, 23), string.byte(tostring(pf))), 20)
    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(AD, 2566273489), 466303660), (bit32.bxor(bit32.band(AD, 1728693806), 4212810241))), 466303660), 4212810241) ~= AD then
        qi = { "Equipped", "Inventory" }
        pf = {}
    else
        pf = { "Equipped", "Inventory" }
        qi = {}
    end
    qn_5 = (qn_5 + 6) % 8
until (qn_5 * 1 + 5) % 8 == 5
local Trails = qt.Trails
if type(Trails) == "table" then
    for i, v in ipairs(Trails) do
        local ql_6 = type(v) == "table" and type(v.ID) == "string"
        if ql_6 then
            table.insert(qi, v)
        end
    end
end
local ql_7 = 2
repeat
    local zn = bit32.rrotate(bit32.bxor(bit32.lrotate(ql_7, 1), string.byte(tostring(ql_7))), 9)
    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(zn, 4217906487), 2969505107), (bit32.bxor(bit32.band(zn, 77060808), 2887771213))), 2969505107), 2887771213) == zn then
        State.Enabled = {
            Steal = false,
            Place = false,
            Hatch = false,
            ClaimIndex = false,
            EquipBest = false,
            BuyTrails = false,
            Sell = false
        }
        State.RarityFilter = {}
        State.ZoneFilter = {}
    else
        State.Enabled = {
            EquipBest = false,
            ClaimIndex = false,
            Steal = false,
            BuyTrails = false,
            Hatch = false,
            Sell = false,
            Place = false
        }
        State.RarityFilter = {}
        State.ZoneFilter = {}
    end
    ql_7 = (ql_7 + 5) % 8
until (ql_7 * 3 + 4) % 8 == 1
for i, v in ipairs(pN) do
    State.RarityFilter[v] = true
end
for i, v in ipairs(p3) do
    State.ZoneFilter[v] = true
end
pu, p6, pQ, py, pE, pc, pX, ps, qb, pC, p1, qd, pF, p9, pw, qg, pz, p4, pk, pb, pL, ph, pV, pr, pU, pq, pO, px, pJ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
State.SellMode = "Inventory"
State.Gens = { Steal = 0, Place = 0, Hatch = 0, ClaimIndex = 0, EquipBest = 0, BuyTrails = 0, Sell = 0 }
State.LastStealAt = 0
State.LastPlaceAt = 0
State.LastHatchAt = 0
State.LastEquipBestAt = 0
State.LastSellAt = 0
State.StealZoneCursor = 0
pu = fn867
p6 = fn729
pQ = fn543
py = function(aW)
    if typeof(aW) ~= "Vector3" then
        return
    end
    pcall(function()
        local rG = if pm(qc.RequestStreamAroundAsync) then 1 else 0
        if rG == 1 then
            task.defer(function()
                pcall(function()
                    qc:RequestStreamAroundAsync(aW)
                end)
            end)
        end
    end)
end
pE = fn466
pc = fn334
pX = fn615
if not qd and not pF or not qd and not ph or pF and qd and (pF or qd) or not (not qd and not pF or not qd and not ph or pF and qd and (pF or qd)) then
    ps = fn279
    qb = fn1000
    pC = fn489
else
    pC = fn279
    ps = fn1000
    qb = fn489
end
p1 = fn727
qd = fn114
pF = fn3
p9 = function(b0)
    local sK
    local Eggs = pZ:FindFirstChild("Eggs")
    local sM = Eggs and Eggs:FindFirstChild(b0)
    if not sM then
        return {}
    end
    sK = {}
    local function sM_1(b7)
        local sr = not b7 or not b7:IsA("Model")
        if sr then
            return
        end
        local sr_1 = b7:GetAttribute("IsEgg") ~= true and b7.Name ~= "SpawnedEgg"
        if sr_1 then
            return
        end
        local sr_2 = b7:GetAttribute("OriginalName")
        local ss = sr_2 == ""
        local st = type(sr_2) ~= "string" or ss
        if st then
            local st_1 = b7.Name ~= "SpawnedEgg" and b7.Name
            local sD = if st_1 then 1 else 0
            local sB = 3528 * sD + 3101 * (1 - sD)
            local sC = 2844 * sD + 3360 * (1 - sD)
            if not ((sB * 2240 + sC * 3433 + sB * sC) % 16777213 == 10922591) then
                st_1 = nil
            end
            sr_2 = st_1
        end
        local ss_2 = pC(sr_2)
        local st_2 = not ss_2 or not ps(ss_2)
        if st_2 then
            return
        end
        local st_3 = nil
        for i, descendant in ipairs(b7:GetDescendants()) do
            local su_1 = descendant:IsA("ProximityPrompt") and descendant.Enabled
            if su_1 then
                if descendant.ActionText == "Egg" then
                    st_3 = descendant
                    break
                elseif st_3 == nil then
                    st_3 = descendant
                end
            end
        end
        if not st_3 then
            return
        end
        local su_2 = b7:FindFirstChild("Root")
        local sv = su_2 and su_2:IsA("BasePart")
        if not sv then
            local sv_1 = b7.PrimaryPart or b7:FindFirstChildWhichIsA("BasePart")
            su_2 = sv_1
        end
        local insert = table.insert
        local su_3 = su_2 and su_2.Position or nil
        insert(sK, { model = b7, original = sr_2, rarity = ss_2, prompt = st_3, position = su_3 })
    end
    local EggSpawn = sM:FindFirstChild("EggSpawn")
    if EggSpawn then
        for i, child in ipairs(EggSpawn:GetChildren()) do
            sM_1(child)
        end
    end
    for i, child in ipairs(sM:GetChildren()) do
        if child.Name ~= "EggSpawn" then
            sM_1(child)
        end
    end
    return sK
end
pw = fn726
qg = fn99
pz = fn225
if (not p1 and not p1 or not pq and not pq) and (ph or not pq or (p1 or pr)) and not ((not p1 and not p1 or not pq and not pq) and (ph or not pq or (p1 or pr))) then
    pL = fn824
    pb = fn470
    ph = fn140
    p4 = fn269
    pk = fn614
else
    p4 = fn824
    pk = fn470
    pb = fn140
    pL = fn269
    ph = fn614
end
pV = function()
    local up
    up = nil
    local ur_1
    local uq = not qk() or not State.Enabled.Place
    local uq_2
    if uq then
        return
    end
    local uq_1 = os.clock()
    if uq_1 - State.LastPlaceAt < 0.45 then
        return
    end
    if pw() then
        qg()
        return
    end
    uq_2, ur_1 = pk()
    if ur_1 and uq_2 >= ur_1 then
        return
    end
    local uq_3 = p4()
    if #uq_3 == 0 then
        return
    end
    local uo = p6()
    up = uq_3[1]
    if not (uo and up) then
        return
    end
    if up.Parent == qc.Backpack then
        local uq_5 = pcall(function()
            uo:EquipTool(up)
        end)
        if not uq_5 then
            return
        end
        task.wait(0.12)
    end
    if up.Parent ~= qc.Character then
        return
    end
    local uq_6 = qd()
    local ur_2 = uq_6 and uq_6:FindFirstChild("EggHatch")
    local us_1 = ur_2
    if ur_2 then
        ur_2 = us_1:IsA("BasePart")
    end
    if ur_2 then
        pQ(CFrame.new(us_1.Position + Vector3.new(0, 4, 0)))
        task.wait(0.12)
    else
        if not uq_6 then
            return
        end
        local Spawn = uq_6:FindFirstChild("Spawn")
        local uq_7 = Spawn and Spawn:IsA("BasePart")
        if not uq_7 then
            return
        end
        pQ(CFrame.new(Spawn.Position + Vector3.new(0, 4, 0)))
        task.wait(0.12)
    end
    local uq_8 = not qk() or not State.Enabled.Place
    if uq_8 then
        return
    end
    if up.Parent ~= qc.Character then
        return
    end
    local uq_9 = pcall(function()
        up:Activate()
    end)
    if uq_9 then
        State.LastPlaceAt = os.clock()
        task.wait(0.35)
    end
end
pr = function()
    local ux = not qk() or not State.Enabled.Hatch
    if ux then
        return
    end
    local ux_1 = os.clock()
    if ux_1 - State.LastHatchAt < 0.4 then
        return
    end
    local ux_2 = qd()
    local uy = ux_2 and ux_2:FindFirstChild("EggHatch")
    if not uy then
        return
    end
    local uy_1 = workspace:GetServerTimeNow()
    for i, child in ipairs(uy:GetChildren()) do
        local uI = child
        local ux_4 = not qk() or not State.Enabled.Hatch
        if ux_4 then
            return
        end
        if uI:GetAttribute("IsEgg") == true then
            local ux_5 = uI:GetAttribute("OriginalName") or uI.Name
            local uz_1
            local attr = uI:GetAttribute("HatchStartTime")
            local uA = p1(ux_5)
            local uB = type(attr) == "number" and type(uA) == "number"
            if uB then
                uz_1 = uy_1 >= attr + uA
            else
                local ProximityPrompt = uI:FindFirstChildWhichIsA("ProximityPrompt", true)
                uz_1 = ProximityPrompt ~= nil and ProximityPrompt.Enabled and ProximityPrompt.ActionText == "Hatch"
            end
            if uz_1 then
                local ux_8 = uI:FindFirstChild("Root") or uI.PrimaryPart or uI:FindFirstChildWhichIsA("BasePart", true)
                if ux_8 then
                    pQ(CFrame.new(ux_8.Position + Vector3.new(0, 3, 0)))
                    task.wait(0.05)
                end
                local ux_9 = pcall(function()
                    RequestHatch:FireServer(uI)
                end)
                if not ux_9 then
                    local ProximityPrompt = uI:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if ProximityPrompt and ProximityPrompt.ActionText == "Hatch" then
                        pE(ProximityPrompt)
                        ux_9 = true
                    end
                end
                if ux_9 then
                    State.LastHatchAt = os.clock()
                    return
                end
            end
        end
    end
end
pU = fn732
pq = fn932
pO = function()
    local uN = not qk() or not State.Enabled.BuyTrails
    if uN then
        return
    end
    local uN_1 = pL()
    local uO = pb()
    for i, v in ipairs(qi) do
        local uX = v
        local uP = not qk() or not State.Enabled.BuyTrails
        if uP then
            return
        end
        if not uN_1[uX.ID] then
            local uP_1 = tonumber(uX.Price) or 0
            if uO >= uP_1 then
                pcall(function()
                    TrailAction:FireServer("BuyMoney", uX.ID)
                end)
                task.wait(0.35)
                uN_1 = pL()
                uO = pb()
            end
        end
    end
end
px = function()
    local uY
    local uZ = not qk()
    local u3 = if uZ then 1 else 0
    local u1 = 772 * u3 + 2653 * (1 - u3)
    local u2 = 2835 * u3 + 3617 * (1 - u3)
    if not ((u1 * 1033 + u2 * 508 + u1 * u2) % 16777213 == 4426276) then
        uZ = not State.Enabled.Sell
    end
    if uZ then
        return
    end
    local uZ_1 = os.clock()
    if uZ_1 - State.LastSellAt < 1.25 then
        return
    end
    uY = State.SellMode
    if uY ~= "Equipped" and uY ~= "Inventory" then
        uY = "Inventory"
    end
    local uZ_3 = pcall(function()
        RequestSell:FireServer(uY)
    end)
    if uZ_3 then
        State.LastSellAt = os.clock()
    end
end
pJ = function(fv, fw, fx)
    State.Gens[fv] += 1
    local fz = State.Gens[fv]
    task.spawn(function()
        while true do
            local u4 = qk() and State.Enabled[fv] and State.Gens[fv] == fz
            if u4 then
                pcall(fx)
                task.wait(fw)
                continue
            end
            break
        end
    end)
end
pM.SetSteal = fn313
pM.SetPlace = fn931
pM.SetHatch = fn325
pM.SetClaimIndex = fn601
pM.SetEquipBest = fn66
pM.SetBuyTrails = fn337
pM.SetSell = fn766
pM.SetRarityFilter = fn906
pM.SetZoneFilter = fn597
pM.SetSellMode = fn612
pM.Track(fn613)
local ql_8 = pm(fireproximityprompt)
local qm_7 = pm(setclipboard) or pm(toclipboard)
qo, qp = nil, nil
local qn_6 = 8
repeat
    if (qn_6 * 1 + 0) % 2 + 1 <= 1 then
        local qq_2 = {
            "aqxsnkwwx",
            "wyquuc",
            "cijedoovpo",
            "kguhzbkfj",
            "okkghatryef",
            "erwkn",
            "dfxou",
            "pwxet",
            "iylhpg",
            "wfbcoocqng",
            "ojr",
            "vvsk"
        }
        if qq_2[(qn_6 * 81 + 29) % 12 + 1] < qq_2[(qn_6 * 81 + 29) % 12 + 1] then
            pm = { setclipboard = qo, fireproximityprompt = ql_8, identifyexecutor = qm_7(identifyexecutor) }
        else
            qo = { fireproximityprompt = ql_8, setclipboard = qm_7, identifyexecutor = pm(identifyexecutor) }
        end
        qn_6 = (qn_6 + 1) % 16
    else
        ql_8 = 1
        if qn_6 * 87829123 + 6 + 6 >= qn_6 * 87829123 + 6 + 6 + 1 then
            qo = {}
        else
            qp = {}
        end
        qn_6 = (qn_6 + 1) % 16
    end
until (qn_6 * 13 + 15) % 16 == 1
if not qo.fireproximityprompt then
    local ql_9 = 4
    repeat
        local qm_8 = (vector.create((ql_9 * 7 + 2) % 11 + 1, (ql_9 * 11 + 8) % 13 + 1, (ql_9 * 10 + 10) % 17 + 1))
        local qn_7 = (vector.create((ql_9 * 2 + 7) % 11 + 1, (ql_9 * 6 + 11) % 13 + 1, (ql_9 * 14 + 16) % 17 + 1))
        qo = (vector.create((ql_9 * 1 + 9) % 11 + 1, (ql_9 * 11 + 11) % 13 + 1, (ql_9 * 3 + 16) % 17 + 1))
        local qq_3 = (vector.create((ql_9 * 7 + 4) % 11 + 1, (ql_9 * 3 + 4) % 13 + 1, (ql_9 * 14 + 8) % 17 + 1))
        if vector.dot(vector.cross(qm_8, qn_7), (vector.cross(qo, qq_3))) == vector.dot(qm_8, qo) * vector.dot(qn_7, qq_3) - vector.dot(qm_8, qq_3) * vector.dot(qn_7, qo) then
            table.insert(qp, "fireproximityprompt")
        else
            table.insert(qp, "fireproximityprompt")
        end
        ql_9 = (ql_9 + 6) % 8
    until (ql_9 * 7 + 7) % 8 == 5
end
local qm_9 = #qp == 0 and "(ready)"
if not qm_9 then
    local ql_11 = 1
    repeat
        if (ql_11 * 2 + 1) * 4 % 3 == ((ql_11 * 2 + 1) * 4 + 5) % 3 then
            qp = "(missing " .. table.concat(qm_9, ", ") .. ")"
        else
            qm_9 = "(missing " .. table.concat(qp, ", ") .. ")"
        end
        ql_11 = (ql_11 + 3) % 8
    until (ql_11 * 5 + 1) % 8 == 5
end
pe, qh, qa, p2, pS, Library, ThemeManager, SaveManager, Toggles, Options, pa, pv, po, pi, pg, pB, p7, qe, pG, pl, qj, pT, qv = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if not pB and pB and (not Library or not pB) or (pB or pB) and (pB and pB) or not (not pB and pB and (not Library or not pB) or (pB or pB) and (pB and pB)) then
    pe = qm_9
end
qh = "https://discord.gg/K7Qxnxkk46"
qa = "https://discord.gg/K7Qxnxkk46"
p2 = "https://tempohub.shop"
local qy = "v0.2"
pS = "Steal Anime Eggs"
Library = getgenv().Library
ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles, Options = Library.Toggles, Library.Options
qu(pM, Library)
qo = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = qh, Copyable = true }, "|", pS, "|", qy },
    Icon = 132608042600488,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    SidebarCompacted = true,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
pa = {}
pa.Info = qo:AddTab("Info", "info")
pa.Main = qo:AddTab("Main", "gamepad-2")
pa.Player = qo:AddTab("Player", "person-standing")
pa.Settings = qo:AddTab("Settings", "settings")
qe = fn18
if qo and qo or qh and qo or (pe and qh or (qo or pe)) or not (qo and qo or qh and qo or (pe and qh or (qo or pe))) then
    pG = fn795
    pl = fn12
    qj = fn296
    pT = fn569
    pv = "#7fd47f"
else
    pv = fn795
    pG = fn12
    pT = fn296
    pl = fn569
    qj = "#7fd47f"
end
po = "#6ec1ff"
pi = "#e8a34d"
pg = "#8b93a3"
local function qx()
    local v7
    local v5
    v5 = nil
    v7 = nil
    local Label, Label2, Label3, wa, wb, wc
    wc = "Unknown"
    pcall(function()
        local vW_1
        local vV_1
        if pm(identifyexecutor) then
            vW_1, vV_1 = identifyexecutor()
            local vX = vW_1 ~= ""
            local vY = type(vW_1) == "string" and vX
            if vY then
                local vX_1 = type(vV_1) == "string" and vV_1 ~= "" and vW_1 .. " " .. vV_1
                wc = vX_1 or vW_1
            end
        end
    end)
    v7 = os.clock()
    wb = function()
        local v_ = math.floor(os.clock() - v7)
        if v_ < 60 then
            return v_ .. "s"
        elseif v_ < 3600 then
            return string.format("%dm %ds", math.floor((v_) / (60)), v_ % 60)
        else
            return string.format("%dh %dm", math.floor((v_) / (3600)), math.floor((v_ % 3600) / (60)))
        end
    end
    local UserGroup = pa.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = qc, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(pT("User", qc.DisplayName .. " @" .. qc.Name, pv), true)
    UserGroup:AddLabel(pT("UserId", tostring(qc.UserId), po), true)
    UserGroup:AddLabel(pT("Executor", wc .. "  " .. pe, pv), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(pT("Session", wb(), pi), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            qe(qc.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            qe("https://www.roblox.com/users/" .. tostring(qc.UserId) .. "/profile", "Copied profile link")
        end
    })
    local DiscordGroup = pa.Info:AddRightGroupbox("Discord", "message-circle")
    DiscordGroup:AddDiscordBox(nil, {
        Banner = 95892854151512,
        Avatar = 132608042600488,
        Title = "Tempo Hub",
        Subtitle = "Dupes, keyless scripts and updates",
        Status = "online",
        Accent = Color3.fromRGB(88, 101, 242),
        Link = qh,
        Buttons = { { Text = "Copy Discord Invite", Icon = "copy", Copy = true } }
    })
    local SessionGroup = pa.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddLabel(pT("Game", pS, po), true)
    Label2 = SessionGroup:AddLabel(pT("Players", "0/0", pv), true)
    wa = tostring(game.JobId)
    local we = #wa > 18 and string.sub(wa, 1, 18) .. "..."
    local we_1 = we or wa
    SessionGroup:AddLabel(pT("Job", we_1, pg), true)
    Label = SessionGroup:AddLabel(pT("Ping", "0 ms", pi), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Place",
        Func = function()
            o9.TeleportService:Teleport(game.PlaceId, qc)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            qe(wa, "Copied Job ID")
        end
    })
    v5 = task.spawn(function()
        local v2_1
        while true do
            local v1 = qk() and not Library.Unloaded
            local v1_2
            if v1 then
                task.wait(1)
                local v1_1 = Library.Unloaded or not qk()
                if v1_1 then
                    break
                end
                Label3:SetText(pT("Session", wb(), pi))
                Label2:SetText(pT("Players", #o9.Players:GetPlayers() .. "/" .. tostring(o9.Players.MaxPlayers), pv))
                v1_2, v2_1 = pcall(function()
                    return math.floor(o9.Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local v1_3 = v1_2 and v2_1 .. " ms" or "n/a"
                Label:SetText(pT("Ping", v1_3, pi))
                continue
            end
            break
        end
    end)
    pM.Track(function()
        pcall(task.cancel, v5)
    end)
    local SocialsGroup = pa.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({
        Text = "Discord",
        Func = function()
            qe(qh, "Copied Discord invite")
        end
    })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            qe(qa, "Copied Rscripts profile")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            qe(p2, "Copied website")
        end
    })
end
pB = {
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
local function qq_4()
    local function h3(h4)
        if not h4 then
            return
        end
        if pB.WalkSnapshots[h4] == nil then
            pB.WalkSnapshots[h4] = h4.WalkSpeed
        end
        if pB.WalkSpeedEnabled then
            h4.WalkSpeed = pB.WalkSpeed
        end
    end
    pM.SetWalkSpeedEnabled = function(h7)
        local wj = h7 and true or false
        pB.WalkSpeedEnabled = wj
        local wi_1 = p6()
        if not wi_1 then
            return
        end
        if pB.WalkSpeedEnabled then
            h3(wi_1)
        elseif pB.WalkSnapshots[wi_1] ~= nil then
            wi_1.WalkSpeed = pB.WalkSnapshots[wi_1]
        end
    end
    pM.SetWalkSpeedValue = function(ie)
        pB.WalkSpeed = ie
        if pB.WalkSpeedEnabled then
            local wl = p6()
            if wl then
                wl.WalkSpeed = ie
            end
        end
    end
    pM.SetInfJump = function(ij)
        local wt = ij and true or false
        pB.InfJump = wt
        if pB.InfJumpConn then
            pB.InfJumpConn:Disconnect()
            pB.InfJumpConn = nil
        end
        if not pB.InfJump then
            return
        end
        pB.InfJumpConn = o9.UserInputService.JumpRequest:Connect(function()
            local wn = not qk() or not pB.InfJump
            if wn then
                return
            end
            local wn_1 = p6()
            if wn_1 then
                wn_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
    pM.SetNoClip = function(iw)
        local wD = iw and true or false
        pB.NoClip = wD
        if pB.NoClipConn then
            pB.NoClipConn:Disconnect()
            pB.NoClipConn = nil
        end
        local Character = qc.Character
        if not pB.NoClip then
            for k, v in pairs(pB.NoClipSnapshots) do
                if k and k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(pB.NoClipSnapshots)
            return
        end
        local function wB(iF)
            local wy = iF:IsA("BasePart") and pB.NoClipSnapshots[iF] == nil
            if wy then
                pB.NoClipSnapshots[iF] = iF.CanCollide
                iF.CanCollide = false
            end
        end
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                wB(descendant)
            end
            pB.NoClipConn = Character.DescendantAdded:Connect(function(iK)
                if pB.NoClip then
                    wB(iK)
                end
            end)
        end
    end
    pM.SetFly = function(iN)
        local wZ = iN and true or false
        pB.Fly = wZ
        if pB.FlyConn then
            pB.FlyConn:Disconnect()
            pB.FlyConn = nil
        end
        local wY_1 = p6()
        if not pB.Fly then
            if wY_1 and pB.FlyPlatformStand ~= nil then
                wY_1.PlatformStand = pB.FlyPlatformStand
            end
            pB.FlyPlatformStand = nil
            return
        end
        if wY_1 then
            pB.FlyPlatformStand = wY_1.PlatformStand
            wY_1.PlatformStand = true
        end
        pB.FlyConn = o9.RunService.RenderStepped:Connect(function()
            local wR = not qk() or not pB.Fly
            if wR then
                return
            end
            if o9.UserInputService:GetFocusedTextBox() then
                return
            end
            local wR_1 = pu()
            local CurrentCamera = pZ.CurrentCamera
            if not (wR_1 and CurrentCamera) then
                return
            end
            local wT_1 = Vector3.zero
            local wX = if o9.UserInputService:IsKeyDown(Enum.KeyCode.W) then 1 else 0
            if wX == 1 then
                wT_1 += CurrentCamera.CFrame.LookVector
            end
            if o9.UserInputService:IsKeyDown(Enum.KeyCode.S) then
                wT_1 -= CurrentCamera.CFrame.LookVector
            end
            if o9.UserInputService:IsKeyDown(Enum.KeyCode.A) then
                wT_1 -= CurrentCamera.CFrame.RightVector
            end
            if o9.UserInputService:IsKeyDown(Enum.KeyCode.D) then
                wT_1 += CurrentCamera.CFrame.RightVector
            end
            if o9.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                wT_1 += Vector3.yAxis
            end
            if o9.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                wT_1 -= Vector3.yAxis
            end
            if wT_1.Magnitude > 0 then
                wR_1.AssemblyLinearVelocity = wT_1.Unit * pB.FlySpeed
            else
                wR_1.AssemblyLinearVelocity = Vector3.zero
            end
        end)
    end
    pM.SetFlySpeed = function(i6)
        pB.FlySpeed = i6
    end
    pM.SetInstantProximityPrompt = function(i8)
        local xa
        local xc = i8 and true or false
        pB.InstantPP = xc
        if pB.InstantConn then
            pB.InstantConn:Disconnect()
            pB.InstantConn = nil
        end
        local function xb_1()
            for k, v in pairs(pB.InstantSnapshots) do
                if k and k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(pB.InstantSnapshots)
        end
        if not pB.InstantPP then
            xb_1()
            return
        end
        xa = function(jg)
            if not jg:IsA("ProximityPrompt") then
                return
            end
            if pB.InstantSnapshots[jg] == nil then
                pB.InstantSnapshots[jg] = {
                    HoldDuration = jg.HoldDuration,
                    MaxActivationDistance = jg.MaxActivationDistance,
                    RequiresLineOfSight = jg.RequiresLineOfSight
                }
            end
            jg.HoldDuration = 0
            jg.MaxActivationDistance = 50
            jg.RequiresLineOfSight = false
        end
        for i, descendant in ipairs(pZ:GetDescendants()) do
            xa(descendant)
        end
        pB.InstantConn = pZ.DescendantAdded:Connect(function(jl)
            if pB.InstantPP then
                xa(jl)
            end
        end)
    end
    pM.Track(function()
        pM.SetWalkSpeedEnabled(false)
        pM.SetInfJump(false)
        pM.SetNoClip(false)
        pM.SetFly(false)
        pM.SetInstantProximityPrompt(false)
    end)
    qc.CharacterAdded:Connect(function()
        task.wait(0.2)
        if not qk() then
            return
        end
        if pB.WalkSpeedEnabled then
            pM.SetWalkSpeedEnabled(true)
        end
        if pB.NoClip then
            pM.SetNoClip(true)
        end
        if pB.Fly then
            pM.SetFly(true)
        end
    end)
end
qr = fn733
qt = fn233
p7 = {
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
local function qw()
    local function kn()
        if not pZ.CurrentCamera then
            return false
        end
        local xl_1 = not pm(o9.VirtualUser.CaptureController) or not pm(o9.VirtualUser.ClickButton2)
        if xl_1 then
            return false
        end
        local xl_2 = pcall(function()
            o9.VirtualUser:CaptureController()
            o9.VirtualUser:ClickButton2(Vector2.new())
        end)
        if xl_2 then
            p7.AfkCount = p7.AfkCount + 1
        end
        return xl_2
    end
    pM.SetAntiAfk = function(kB)
        local xw = kB and true or false
        p7.AntiAfk = xw
        if p7.AfkConn then
            p7.AfkConn:Disconnect()
            p7.AfkConn = nil
        end
        if p7.AfkTask then
            pcall(task.cancel, p7.AfkTask)
            p7.AfkTask = nil
        end
        if not p7.AntiAfk then
            return
        end
        p7.AfkConn = qc.Idled:Connect(function()
            local xq = qk() and p7.AntiAfk
            if xq then
                kn()
            end
        end)
        p7.AfkTask = task.spawn(function()
            local xs = os.clock()
            while true do
                local xt = qk() and p7.AntiAfk
                if xt then
                    task.wait(1)
                    local xt_1 = not qk() or not p7.AntiAfk
                    if xt_1 then
                        break
                    end
                    if os.clock() - xs >= 60 then
                        xs = os.clock()
                        kn()
                    end
                    continue
                end
                break
            end
        end)
    end
    pM.SetNoGameplayPaused = function(kT)
        local xz = kT and true or false
        p7.NoGameplayPaused = xz
    end
    pM.SetAutoReconnect = function(kV)
        local xK = kV and true or false
        p7.AutoReconnect = xK
        for i, v in ipairs(p7.ReconnectConns) do
            v:Disconnect()
        end
        table.clear(p7.ReconnectConns)
        if not p7.AutoReconnect then
            return
        end
        table.insert(p7.ReconnectConns, o9.TeleportService.TeleportInitFailed:Connect(function()
            local xE = not qk() or not p7.AutoReconnect
            if xE then
                return
            end
            task.wait(1)
            local xE_1 = qk() and p7.AutoReconnect
            if xE_1 then
                pcall(function()
                    o9.TeleportService:Teleport(game.PlaceId, qc)
                end)
            end
        end))
    end
    pM.SetDisable3D = function(k9)
        local xT = k9 and true or false
        p7.Disable3D = xT
        pcall(function()
            o9.RunService:Set3dRenderingEnabled(not p7.Disable3D)
        end)
    end
    pM.SetFpsBoost = function(le)
        local ye
        local yg = le and true or false
        p7.FpsBoost = yg
        if p7.FpsConn then
            p7.FpsConn:Disconnect()
            p7.FpsConn = nil
        end
        local function yf_1()
            for k, v in pairs(p7.FpsSnapshots) do
                local x_ = k
                if x_ and x_.Parent then
                    for k, v in pairs(v) do
                        local x5 = k
                        local x7 = v
                        pcall(function()
                            x_[x5] = x7
                        end)
                    end
                end
            end
            table.clear(p7.FpsSnapshots)
        end
        if not p7.FpsBoost then
            yf_1()
            return
        end
        ye = function(lr)
            if p7.FpsSnapshots[lr] then
                return
            end
            local x8 = lr:IsA("ParticleEmitter") or lr:IsA("Trail")
            local yc = if x8 then 1 else 0
            local ya = 3353 * yc + 3124 * (1 - yc)
            local yb = 2881 * yc + 492 * (1 - yc)
            if not ((ya * 746 + yb * 2052 + ya * yb) % 16777213 == 1295930) then
                x8 = lr:IsA("Beam")
            end
            if not x8 then
                x8 = lr:IsA("Fire")
            end
            if not x8 then
                x8 = lr:IsA("Smoke")
            end
            if not x8 then
                x8 = lr:IsA("Sparkles")
            end
            if x8 then
                p7.FpsSnapshots[lr] = { Enabled = lr.Enabled }
                lr.Enabled = false
            end
        end
        for i, descendant in ipairs(pZ:GetDescendants()) do
            ye(descendant)
        end
        if p7.FpsSnapshots[o9.Lighting] == nil then
            p7.FpsSnapshots[o9.Lighting] = { GlobalShadows = o9.Lighting.GlobalShadows, FogEnd = o9.Lighting.FogEnd }
            o9.Lighting.GlobalShadows = false
        end
        p7.FpsConn = pZ.DescendantAdded:Connect(function(ly)
            if p7.FpsBoost then
                ye(ly)
            end
        end)
    end
    pM.Track(function()
        pM.SetAntiAfk(false)
        pM.SetAutoReconnect(false)
        pM.SetDisable3D(false)
        pM.SetFpsBoost(false)
    end)
end
if (SaveManager or pG) and (SaveManager and not pG) and (pG or SaveManager or (SaveManager or pG)) or not ((SaveManager or pG) and (SaveManager and not pG) and (pG or SaveManager or (SaveManager or pG))) then
    qv = function()
        pG(pa.Settings)
        local MenuGroup = pa.Settings:AddLeftGroupbox("Menu", "settings")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        MenuGroup:AddToggle("NoGameplayPaused", { Text = "No Gameplay Paused", Default = true })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3DRendering", { Text = "Disable 3D Rendering", Default = false })
        MenuGroup:AddToggle("FPSBoost", { Text = "FPS Boost", Default = false })
        MenuGroup:AddToggle("HideUIOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        local ScriptGroup = pa.Settings:AddLeftGroupbox("Script", "scroll-text")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        Toggles.AntiAfk:OnChanged(function(lL)
            pM.SetAntiAfk(lL)
        end)
        Toggles.NoGameplayPaused:OnChanged(function(lO)
            pM.SetNoGameplayPaused(lO)
        end)
        Toggles.AutoReconnect:OnChanged(function(lQ)
            pM.SetAutoReconnect(lQ)
        end)
        Toggles.Disable3DRendering:OnChanged(function(lS)
            pM.SetDisable3D(lS)
        end)
        Toggles.FPSBoost:OnChanged(function(lU)
            pM.SetFpsBoost(lU)
        end)
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("MyScriptHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(pa.Settings)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/StealAnimeEggs")
        local yB_4 = SaveManager:BuildConfigSection(pa.Settings)
        if yB_4 then
            yB_4:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Default = "", Finished = true, AllowEmpty = true })
            yB_4:AddButton({
                Text = "Export Config to Clipboard",
                Func = function()
                    local yq_2
                    local yp_2
                    yp_2, yq_2 = pcall(function()
                        if pm(SaveManager.ExportConfig) then
                            return SaveManager:ExportConfig()
                        end
                        error("ExportConfig unavailable")
                    end)
                    local yr = yp_2 and type(yq_2) == "string"
                    if yr then
                        qe(yq_2, "Copied config")
                    else
                        Library:Notify("Export unavailable", 3)
                    end
                end
            })
            yB_4:AddButton({
                Text = "Import Config from Clipboard Text",
                Func = function()
                    local yx
                    yx = Options.SaveManager_ImportSource and Options.SaveManager_ImportSource.Value or ""
                    if yx == "" then
                        Library:Notify("Paste a config first", 3)
                        return
                    end
                    local yy_2 = pcall(function()
                        if pm(SaveManager.ImportConfig) then
                            SaveManager:ImportConfig(yx)
                        elseif pm(SaveManager.LoadConfigFromJSON) then
                            SaveManager:LoadConfigFromJSON(yx)
                        else
                            error("Import unavailable")
                        end
                    end)
                    if yy_2 then
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
else
    p7 = function()
        pG(pa.Settings)
        local MenuGroup = pa.Settings:AddLeftGroupbox("Menu", "settings")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        MenuGroup:AddToggle("NoGameplayPaused", { Text = "No Gameplay Paused", Default = true })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3DRendering", { Text = "Disable 3D Rendering", Default = false })
        MenuGroup:AddToggle("FPSBoost", { Text = "FPS Boost", Default = false })
        MenuGroup:AddToggle("HideUIOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        local ScriptGroup = pa.Settings:AddLeftGroupbox("Script", "scroll-text")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        Toggles.AntiAfk:OnChanged(function(lL)
            pM.SetAntiAfk(lL)
        end)
        Toggles.NoGameplayPaused:OnChanged(function(lO)
            pM.SetNoGameplayPaused(lO)
        end)
        Toggles.AutoReconnect:OnChanged(function(lQ)
            pM.SetAutoReconnect(lQ)
        end)
        Toggles.Disable3DRendering:OnChanged(function(lS)
            pM.SetDisable3D(lS)
        end)
        Toggles.FPSBoost:OnChanged(function(lU)
            pM.SetFpsBoost(lU)
        end)
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("MyScriptHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(pa.Settings)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/StealAnimeEggs")
        local yB_2 = SaveManager:BuildConfigSection(pa.Settings)
        if yB_2 then
            yB_2:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Default = "", Finished = true, AllowEmpty = true })
            yB_2:AddButton({
                Text = "Export Config to Clipboard",
                Func = function()
                    local yq_1
                    local yp_1
                    yp_1, yq_1 = pcall(function()
                        if pm(SaveManager.ExportConfig) then
                            return SaveManager:ExportConfig()
                        end
                        error("ExportConfig unavailable")
                    end)
                    local yr = yp_1 and type(yq_1) == "string"
                    if yr then
                        qe(yq_1, "Copied config")
                    else
                        Library:Notify("Export unavailable", 3)
                    end
                end
            })
            yB_2:AddButton({
                Text = "Import Config from Clipboard Text",
                Func = function()
                    local yx
                    yx = Options.SaveManager_ImportSource and Options.SaveManager_ImportSource.Value or ""
                    if yx == "" then
                        Library:Notify("Paste a config first", 3)
                        return
                    end
                    local yy_1 = pcall(function()
                        if pm(SaveManager.ImportConfig) then
                            SaveManager:ImportConfig(yx)
                        elseif pm(SaveManager.LoadConfigFromJSON) then
                            SaveManager:LoadConfigFromJSON(yx)
                        else
                            error("Import unavailable")
                        end
                    end)
                    if yy_1 then
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
end
qq_4()
qw()
qx()
qt()
qr()
qv()
pM.SetAntiAfk(Toggles.AntiAfk.Value)
pM.SetNoGameplayPaused(Toggles.NoGameplayPaused.Value)
if Toggles.HideUIOnStart.Value then
    pcall(function()
        Library:Toggle(false)
    end)
end
local ql_12 = 3
repeat
    local qm_10 = {
        "wncnaeti",
        "ctjxglwwws",
        "fxl",
        "epqgyvkijf",
        "fhjj",
        "taow",
        "nsjiyvre",
        "wlyizb",
        "cfha",
        "edmjlerep"
    }
    if qm_10[(ql_12 * 40 + 110) % 10 + 1] <= qm_10[(ql_12 * 40 + 110) % 10 + 1] then
        Library:Notify("Steal Anime Eggs v0.2 loaded", 4)
    else
        qy:Notify("Steal Anime Eggs " .. Library .. " loaded", 4)
    end
    ql_12 = (ql_12 + 3) % 4
until (ql_12 * 3 + 1) % 4 == 3
end)(...)

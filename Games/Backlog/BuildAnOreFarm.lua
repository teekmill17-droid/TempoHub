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
getgenv().TempoHoodSubtitle = "BUILD AN ORE FARM"
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
local uQ_1, uQ_2, uQ_4, uQ_5, UserInputService, uQ_7, uQ_11, uQ_12, uQ_14, uQ_15, uQ_16, uQ_19, uQ_21, uQ_23, MinerDataChanged, uQ_26, uQ_27
local n2
local ov
local nr
local n8
local m8
local nQ
local nx
local oe
local Toggles
local nD
local ol
local nk
local nJ
local connection
local n7
local nP
local nw
local od
local nd
local nV
local nC
local oj
local n0
local ot
local m6
local nO
local oz
local oc
local nU
local oF
local nB
local MyPlot
local Workspace
local Library
local m5
local nN
local oy
local nu
local ob
local nb
local Options
local oh
local nZ
local nG
local op
local nn
local n4
local m4
local ox
local oa
local na
local nS
local GetOreState
local og
local ng
local connection2
local ow
local ns
local n9
local m9
local nR
local ny
local of
local nf
local nX
function fns.fn18()
    local pY_1
    local pX_1
    pX_1, pY_1 = pcall(function()
        return GetOreState:InvokeServer()
    end)
    local pZ = pX_1 and type(pY_1) == "table"
    if pZ then
        local pX_2 = pY_1.carrying or 0
        nJ.carrying = pX_2
        local pX_3 = pY_1.stock or 0
        nJ.stock = pX_3
        local pX_4 = pY_1.banked or 0
        nJ.banked = pX_4
        local pX_5 = pY_1.rate or 0
        nJ.rate = pX_5
        local pX_6 = pY_1.upgradeCost or 0
        nJ.upgradeCost = pX_6
        local pX_7 = pY_1.level or 0
        nJ.level = pX_7
    end
    return nJ
end
function fns.fn23(aw, ax)
    return string.format('<font color="%s">%s</font>', ax, aw)
end
function fns.onUnload()
    Library:Unload()
end
function fns.fn66(a4)
    return next(nf(a4)) ~= nil
end
function fns.fn74()
    local qA = oz()
    if not qA then
        return nil
    end
    local Lever = qA:FindFirstChild("Lever", true)
    if not Lever then
        return nil
    end
    return Lever:FindFirstChildWhichIsA("ProximityPrompt", true)
end
function fns.fn88()
    local Character = ol.Character
    local qf = Character and Character:FindFirstChild("HumanoidRootPart")
    return qf
end
function fns.onOnClientEvent4(cl)
    if cl == "start" then
        n9 = true
        n4 = 0
    elseif cl == "land" then
        n9 = false
        n4 = os.clock()
    end
end
function fns.onOnClientEvent3(bJ)
    if type(bJ) == "table" then
        nG = bJ
    end
end
function fns.fn105()
    local Character = ol.Character
    local qi = Character and Character:FindFirstChildOfClass("Humanoid")
    return qi
end
function fns.fn144()
    local rs = {}
    local rt = ot()
    if not rt then
        return rs
    end
    for i, descendant in ipairs(rt:GetDescendants()) do
        local rt_1 = descendant:IsA("Model") and descendant:GetAttribute("PickaxeSetup")
        if rt_1 then
            table.insert(rs, descendant)
        end
    end
    return rs
end
function fns.fn146(eK)
    local sw = {}
    local SpinDisplays = Workspace:FindFirstChild("SpinDisplays")
    local sy = nn()
    if not (SpinDisplays and sy) then
        return sw
    end
    local sz_1 = eK or 70
    for i, child in ipairs(SpinDisplays:GetChildren()) do
        local BuyPrompt = child:FindFirstChild("BuyPrompt", true)
        local sz_2 = BuyPrompt and BuyPrompt:IsA("ProximityPrompt") and BuyPrompt.Enabled
        if sz_2 then
            local sz_3 = nd(BuyPrompt)
            if sz_3 and (sz_3 - sy).Magnitude <= sz_1 then
                local insert = table.insert
                local Name = child.Name
                local ObjectText = BuyPrompt.ObjectText
                local sE = nB(BuyPrompt.ActionText) or m5[child.Name]
                local sF = sE or 0
                insert(sw, {
                    stand = child,
                    prompt = BuyPrompt,
                    name = Name,
                    object = ObjectText,
                    price = sF,
                    distance = (sz_3 - sy).Magnitude
                })
            end
        end
    end
    table.sort(sw, function(e0, e1)
        return e0.distance < e1.distance
    end)
    return sw
end
function fns.fn159(b0)
    local qk = oz()
    if not qk then
        return 0
    end
    local ql = tonumber(qk:GetAttribute(b0)) or 0
    return ql
end
function fns.fn175(dm)
    local rl = n0()
    if not rl or not dm then
        return false
    end
    local Character = ol.Character
    local rn_1 = Character and Character:FindFirstChildOfClass("Tool")
    local rm_2 = rn_1
    if rn_1 then
        rn_1 = rm_2.Name == dm
    end
    if rn_1 then
        return true
    end
    local Backpack = ol:FindFirstChildOfClass("Backpack")
    local rn_2 = Backpack and Backpack:FindFirstChild(dm)
    if not rn_2 then
        return false
    end
    rl:EquipTool(rn_2)
    return true
end
function fns.worker()
    nC()
    na()
    oj()
end
function fns.onOnClientEvent(bz)
    if type(bz) == "table" then
        nQ = bz
    end
end
function fns.fn269(cG)
    local qS = os.clock()
    local qT = cG or 6
    while true do
        local qT_1 = not Library.Unloaded and os.clock() - qS < qT
        if qT_1 then
            local qT_2 = not n9 and n4 > 0 and os.clock() - n4 < 4
            if qT_2 then
                return true
            end
            task.wait(0.05)
            continue
        end
        break
    end
    n9 = false
    return true
end
function fns.fn277(aO, aP)
    local pE = Options[aO]
    if pE == nil then
        return aP
    end
    return pE.Value
end
function fns.fn290()
    local qN = oz()
    if not qN then
        return nil
    end
    return qN:GetPivot().Position
end
local function fn300(aX)
    local pI = nP(aX, {})
    if typeof(pI) ~= "table" then
        return {}
    end
    local pJ = {}
    for k, v in pairs(pI) do
        if v == true then
            pJ[k] = true
        else
            local pI_1 = typeof(k) == "number" and typeof(v) == "string"
            if pI_1 then
                pJ[v] = true
            end
        end
    end
    return pJ
end
local function fn313(cU)
    local q0 = cU and cU:IsA("Tool") and nU.getEntry(cU.Name) ~= nil
    return q0
end
local function onPlatformDown()
    pcall(function()
        nR:InvokeServer(-1)
    end)
end
local function fn321(aI)
    if Library.Unloaded then
        return false
    end
    local pB = Toggles[aI]
    return pB ~= nil and pB.Value == true
end
local function fn335(fx)
    local DiscordGroup = fx:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = nw })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = nw })
end
local function fn340(c0)
    local Backpack = ol:FindFirstChildOfClass("Backpack")
    if Backpack then
        for i, child in ipairs(Backpack:GetChildren()) do
            if child:IsA("Tool") then
                c0(child)
            end
        end
    end
    local Character = ol.Character
    if Character then
        local Tool = Character:FindFirstChildOfClass("Tool")
        if Tool then
            c0(Tool)
        end
    end
end
local function fn359(cD)
    return nf("UpgradeTargets")[cD] == true
end
local function fn364(cz)
    local qQ = cz and cz.Parent
    while true do
        if not qQ then
            return nil
        end
        if qQ:IsA("BasePart") then
            return qQ.Position
        end
        if qQ:IsA("Model") then
            break
        end
        qQ = qQ.Parent
    end
    return qQ:GetPivot().Position
end
local function onInputBegan()
    ny = tick()
end
local function fn423()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    ow:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    ow:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    ns = tick()
end
local function fn435()
    local p1_1
    local p0_1
    p0_1, p1_1 = pcall(function()
        return of:InvokeServer()
    end)
    local p2 = p0_1 and type(p1_1) == "table"
    if p2 then
        nG = p1_1
    end
    return nG
end
local function fn471()
    local tb_1
    local ta_1
    if identifyexecutor then
        tb_1, ta_1 = identifyexecutor()
        local tc = tb_1 ~= ""
        local td = type(tb_1) == "string" and tc
        if td then
            local tc_1 = type(ta_1) == "string" and ta_1 ~= "" and tb_1 .. " " .. ta_1
            nx = tc_1 or tb_1
        end
    end
end
local function worker3()
    while not Library.Unloaded do
        local tN = nr("RollDelay", 0.55)
        if oa("AutoSpin") then
            if not n9 then
                local tO = true
                local tP = ov() and not oa("AutoSkipUnaffordable")
                if tP then
                    tO = oc()
                end
                if tO then
                    local tO_1 = nS()
                    if tO_1 then
                        n4 = 0
                        oy(tO_1.Parent)
                        task.wait(0.1)
                        nu(tO_1)
                        op(6)
                        task.wait(0.25)
                        if ov() then
                            oc()
                        end
                    end
                end
            end
        elseif ov() then
            oc()
        end
        task.wait(tN)
    end
end
local function fn490(cY)
    local q5 = cY and cY:IsA("Tool") and cY:GetAttribute("IsMiner") == true
    return q5
end
local function fn509(az, aA, aB)
    return string.format("<b>%s</b> %s %s", az, nk("-", "#5a6070"), nk(aA, aB))
end
local function fn533(ap, aq)
    if setclipboard then
        setclipboard(ap)
    elseif toclipboard then
        toclipboard(ap)
    end
    Library:Notify(aq)
end
local function fn555(dQ)
    if not dQ or not m8[dQ] then
        return false
    end
    local rR_1 = nP("PlaceMinPickaxe", "Basic")
    local rS = m8[rR_1]
    local rW = if rS then 1 else 0
    local rU = 2020 * rW + 3411 * (1 - rW)
    local rV = 2621 * rW + 2565 * (1 - rW)
    if not ((rU * 2754 + rV * 3111 + rU * rV) % 16777213 == 2234218) then
        rS = 1
    end
    if (m8[dQ] or 0) < rS then
        return false
    end
    local rR_3 = nf("PlacePickaxeTargets")
    local rS_2 = next(rR_3) and not rR_3[dQ]
    if rS_2 then
        return false
    end
    return true
end
local function fn574()
    connection:Disconnect()
    connection2:Disconnect()
    pcall(function()
        n8:FireServer(false, {})
    end)
end
local function fn591()
    if oa("AutoBuyAny") then
        return og(true)
    elseif oa("AutoBuyDisplays") then
        return og(false)
    else
        return true
    end
end
local function fn609()
    local s7 = oa("AutoBuyAny") or oa("AutoBuyDisplays")
    return s7
end
local function fn626(ct)
    local qH = ct or ""
    local qI = string.match(qH, "([%d,]+)")
    if not qI then
        return nil
    end
    return tonumber((string.gsub(qI, ",", "")))
end
local function fn633()
    m4()
end
local function onInputChanged(gC)
    local UserInputType = gC.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        ny = tick()
    end
end
local function fn652()
    nN(ob, "Copied Discord invite to clipboard")
end
local function onPlatformUp()
    pcall(function()
        nR:InvokeServer(1)
    end)
end
local function fn682()
    return MyPlot.lobby(1)
end
local function fn707()
    return MyPlot.mining(1)
end
local function onRollTargets()
    if oa("AutoSpecificRoll") then
        m4()
    end
end
local function fn775()
    local pU_1
    local pT_1
    pT_1, pU_1 = pcall(function()
        return ox:InvokeServer()
    end)
    local pV = pT_1 and type(pU_1) == "table"
    if pV then
        nQ = pU_1
    end
    return nQ
end
local function onCopyJoinScript_JobID()
    local fO = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, oF)
    nN(fO, "Copied join script to clipboard")
end
local function fn801(aT, aU)
    local pG = tonumber(nP(aT, aU)) or aU
    return pG
end
local function fn814(ce)
    local qs = oe()
    local qt = not ce
    local qu = not qs
    local qy = if qu then 1 else 0
    local qw = 2455 * qy + 3126 * (1 - qy)
    local qx = 2420 * qy + 2595 * (1 - qy)
    if not ((qw * 3448 + qx * 3793 + qw * qx) % 16777213 == 6807787) then
        qu = qt
    end
    if qu then
        return false
    elseif ce:IsA("Model") then
        local pivot = ce:GetPivot()
        qs.CFrame = pivot + Vector3.new(0, 4, 0)
        return true
    elseif ce:IsA("BasePart") then
        local CFrame = ce.CFrame
        qs.CFrame = CFrame + Vector3.new(0, 4, 0)
        return true
    else
        return false
    end
end
local function fn816(dG)
    for i, descendant in ipairs(dG:GetDescendants()) do
        local rB = descendant:IsA("ProximityPrompt") and descendant.Name == "PlacePrompt"
        if rB then
            return descendant
        end
    end
    return nil
end
local function fn826(e3)
    local sQ = nf("RollTargets")
    local sR = not e3
    if sR ~= false then
        sR = not next(sQ)
    end
    if sR then
        return true
    end
    local sR_1 = nQ or nC()
    local sS = sR_1
    if sR_1 then
        sR_1 = sS.cash
    end
    local sT = sR_1
    local s0 = if sT then 1 else 0
    local sZ = 1458 * s0 + 1565 * (1 - s0)
    local s_ = 2856 * s0 + 3419 * (1 - s0)
    if not ((sZ * 4020 + s_ * 424 + sZ * s_) % 16777213 == 11236152) then
        sT = 0
    end
    local sR_2 = sT
    local sT_1 = oa("AutoSkipUnaffordable")
    local sU = false
    for i, v in ipairs(nZ(70)) do
        if Library.Unloaded then
            break
        else
            local sV = v.object
            local sW = sV == ""
            local sX = typeof(sV) ~= "string" or sW
            if sX then
                sV = v.name
            end
            local sW_1 = not e3
            if sW_1 ~= false then
                sW_1 = not sQ[sV]
            end
            if not sW_1 then
                if v.price > sR_2 then
                    if not sT_1 then
                        sU = true
                    end
                else
                    oy(v.prompt.Parent)
                    task.wait(0.12)
                    if nu(v.prompt) then
                        local sR_3 = sR_2 - v.price
                        task.wait(0.2)
                        local sS_1 = nC()
                        sR_2 = sS_1 and sS_1.cash or sR_3
                    end
                end
            end
        end
    end
    return not sU
end
local function onOnClientEvent2(bB)
    if type(bB) ~= "table" then
        return
    end
    local p8 = bB.carrying or nJ.carrying
    nJ.carrying = p8
    local p8_1 = bB.stock
    local qc = if p8_1 then 1 else 0
    local qa = 3801 * qc + 2051 * (1 - qc)
    local qb = 2473 * qc + 2412 * (1 - qc)
    if not ((qa * 810 + qb * 1920 + qa * qb) % 16777213 == 449630) then
        p8_1 = nJ.stock
    end
    nJ.stock = p8_1
    local p8_2 = bB.banked or nJ.banked
    nJ.banked = p8_2
    local p8_3 = bB.rate
    local qc_1 = if p8_3 then 1 else 0
    local qa_1 = 493 * qc_1 + 1417 * (1 - qc_1)
    local qb_1 = 2692 * qc_1 + 949 * (1 - qc_1)
    if not ((qa_1 * 3934 + qb_1 * 3139 + qa_1 * qb_1) % 16777213 == 11716806) then
        p8_3 = nJ.rate
    end
    nJ.rate = p8_3
    local p8_4 = bB.upgradeCost or nJ.upgradeCost
    nJ.upgradeCost = p8_4
    local p8_5 = bB.level or nJ.level
    nJ.level = p8_5
end
local function fn855(cP, cQ)
    if not cP then
        return -1
    elseif cQ == "Money" then
        return m5[cP] or 0
    else
        return m8[cP] or 0
    end
end
local function onRscripts()
    nN(n7, "Copied Rscripts profile to clipboard")
end
local function fn866()
    local r4_1
    local r3_1
    local r8_2
    local r1 = nP("PlaceCompareBy", "Rarity")
    local r2 = nP("PlacePickaxeMode", "Replace Worse")
    r4_1, r3_1 = nX(r1)
    if not r4_1 then
        return
    end
    local r5 = math.huge
    local r6
    local r7
    for i, v in ipairs(n2()) do
        local attr = v:GetAttribute("Pickaxe")
        local r9 = attr == ""
        local sa = typeof(attr) ~= "string" or r9
        if sa then
            r6 = r6 or v
        else
            local r9_2 = nO(attr, r1)
            if r9_2 < r5 then
                r5 = r9_2
                r7 = v
            end
        end
    end
    if r2 == "Empty Only" then
        r8_2 = r6
    else
        r8_2 = r6
        local r1_1 = not r8_2
        if r1_1 ~= false then
            r1_1 = r7
        end
        if r1_1 then
            r1_1 = r3_1 > r5
        end
        if r1_1 then
            r8_2 = r7
        end
    end
    if not r8_2 then
        return
    end
    if not ng(r4_1) then
        return
    end
    task.wait(0.15)
    local r1_2 = nD(r8_2)
    if not r1_2 then
        return
    end
    oy(r8_2)
    task.wait(0.1)
    nu(r1_2)
end
local function onTeleportPlot()
    pcall(function()
        nV:InvokeServer()
    end)
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local uK = tick() - ny
            local uL = tick() - ns
            if uK >= 300 and uL >= 60 then
                pcall(nb)
            else
                if uK < 300 and uL >= 300 then
                    pcall(nb)
                end
            end
        end
    end
end
local function worker2()
    local tj_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local ti = math.floor(os.clock() - od)
        if ti < 60 then
            tj_1 = ti .. "s"
        elseif ti < 3600 then
            tj_1 = string.format("%dm %ds", math.floor((ti) / (60)), ti % 60)
        else
            tj_1 = string.format("%dh %dm", math.floor((ti) / (3600)), math.floor((ti % 3600) / (60)))
        end
        m6:SetText(m9("Session time", tj_1, oh))
    end
end
local function onTeleportToLever()
    local tm = nS()
    if tm then
        oy(tm.Parent)
    end
end
m4 = nil
m5 = nil
m6 = nil
m8 = nil
m9 = nil
na = nil
nb = nil
nd = nil
nf = nil
ng = nil
nk = nil
nn = nil
nr = nil
ns = nil
nu = nil
nw = nil
nx = nil
ny = nil
nB = nil
nC = nil
nD = nil
nG = nil
nJ = nil
nN = nil
nO = nil
nP = nil
nQ = nil
local m3, m7, nc, ne, nh, GetPickaxeInfo, nj, nl, ClaimOfflineEarnings, no, GetGroupReward, nq, nt, nv, nz, nA, BuyLuck, nF, nH, nI, nK, nL, ClaimDaily
nR = nil
nS = nil
Options = nil
nU = nil
nV = nil
Toggles = nil
nX = nil
nZ = nil
MyPlot = nil
n0 = nil
n2 = nil
connection2 = nil
n4 = nil
Library = nil
n7 = nil
n8 = nil
n9 = nil
oa = nil
ob = nil
oc = nil
od = nil
oe = nil
of = nil
og = nil
oh = nil
oj = nil
ol = nil
op = nil
Workspace = nil
ot = nil
connection = nil
ov = nil
ow = nil
ox = nil
oy = nil
oz = nil
GetOreState = nil
oF = nil
local nY, n1, n6, oi, om, oo, oA, oB, oC, oE
nY = nil
n1 = nil
n6 = nil
oi = nil
om = nil
oo = nil
oA = nil
oB = nil
oC = nil
oE = nil
uQ_19, uQ_21, UserInputService, ow, Workspace, ol, uQ_15, ob, n7, uQ_1, MyPlot, uQ_11, nU, uQ_23, nK, nH, BuyLuck, nz, nt, no, nl, GetPickaxeInfo, nh, nc, m7, m3, GetOreState, uQ_14, ox, MinerDataChanged, om, of, uQ_4, n8, uQ_12, n1, nY, nV, nR, ClaimDaily, nI, nF, nA, nv, GetGroupReward, ClaimOfflineEarnings, nj, uQ_26, uQ_5, m8, m5, uQ_2 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local uQ_9 = 53
repeat
    uQ_27 = (uQ_9 * 7 + 3) % 20 + 1
    if uQ_27 <= 10 then
        if uQ_27 <= 5 then
            if uQ_27 <= 3 then
                if uQ_27 <= 2 then
                    if uQ_27 <= 1 then
                        if (uQ_9 * 1 + 4) * 9 % 4 == ((uQ_9 * 1 + 4) * 9 + 4) % 4 then
                            MyPlot = require(uQ_21:WaitForChild("MyPlot"))
                        else
                            uQ_21 = require(MyPlot:WaitForChild("MyPlot"))
                        end
                        uQ_9 = (uQ_9 + 3) % 160
                    else
                        if uQ_9 * 48955353 + 4 + 6 <= uQ_9 * 48955353 + 4 + 6 + 1 then
                            uQ_11 = require(uQ_21:WaitForChild("PickaxeConfig"))
                        else
                            uQ_21 = require(uQ_11:WaitForChild("PickaxeConfig"))
                        end
                        uQ_9 = (uQ_9 + 63) % 160
                    end
                else
                    local v8 = bit32.rrotate(bit32.bxor(bit32.lrotate(uQ_9, 8), string.byte(tostring(GetPickaxeInfo))), 1)
                    if bit32.bxor(bit32.lrotate(bit32.bxor(v8, 875961783), 12), 1641771843) ~= bit32.lrotate(v8, 12) then
                        uQ_21 = require(nU:WaitForChild("PickaxeLib"))
                    else
                        nU = require(uQ_21:WaitForChild("PickaxeLib"))
                    end
                    uQ_9 = (uQ_9 + 63) % 160
                end
            elseif uQ_27 <= 4 then
                if uQ_9 * 10695755 + 12 + 5 <= uQ_9 * 10695755 + 12 + 5 + 6 then
                    uQ_23 = require(uQ_21:WaitForChild("MinerShopConfig"))
                else
                    uQ_21 = require(uQ_23:WaitForChild("MinerShopConfig"))
                end
                uQ_9 = (uQ_9 + 3) % 160
            else
                if (not m5 or m5) and (not ol or not ol) and (nc or nc or not m5 and nI) or not ((not m5 or m5) and (not ol or not ol) and (nc or nc or not m5 and nI)) then
                    nK = uQ_1:WaitForChild("BuyRoll")
                    nH = uQ_1:WaitForChild("BuyMiner")
                    BuyLuck = uQ_1:WaitForChild("BuyLuck")
                    nz = uQ_1:WaitForChild("BuyMutation")
                    nt = uQ_1:WaitForChild("BuyAxeSpeed")
                else
                    nt = BuyLuck:WaitForChild("BuyRoll")
                    uQ_1 = BuyLuck:WaitForChild("BuyMiner")
                    nz = BuyLuck:WaitForChild("BuyLuck")
                    nH = BuyLuck:WaitForChild("BuyMutation")
                    nK = BuyLuck:WaitForChild("BuyAxeSpeed")
                end
                uQ_9 = (uQ_9 + 83) % 160
            end
        elseif uQ_27 <= 8 then
            if uQ_27 <= 7 then
                if uQ_27 <= 6 then
                    if (uQ_9 * 3 + 6) * 17 % 4 == ((uQ_9 * 3 + 6) * 17 + 8) % 4 then
                        no = uQ_1:WaitForChild("BuyShopMiner")
                        nl = uQ_1:WaitForChild("UpgradePickaxe")
                        GetPickaxeInfo = uQ_1:WaitForChild("GetPickaxeInfo")
                        nh = uQ_1:WaitForChild("UpgradeProcessor")
                        nc = uQ_1:WaitForChild("CollectOre")
                    else
                        nh = GetPickaxeInfo:WaitForChild("BuyShopMiner")
                        no = GetPickaxeInfo:WaitForChild("UpgradePickaxe")
                        nc = GetPickaxeInfo:WaitForChild("GetPickaxeInfo")
                        uQ_1 = GetPickaxeInfo:WaitForChild("UpgradeProcessor")
                        nl = GetPickaxeInfo:WaitForChild("CollectOre")
                    end
                    uQ_9 = (uQ_9 + 83) % 160
                else
                    uQ_16 = (vector.create((uQ_9 * 7 + 9) % 11 + 1, (uQ_9 * 11 + 10) % 13 + 1, (uQ_9 * 5 + 9) % 17 + 1))
                    uQ_7 = (vector.create((uQ_9 * 6 + 3) % 11 + 1, (uQ_9 * 7 + 10) % 13 + 1, (uQ_9 * 7 + 12) % 17 + 1))
                    local vi = vector.cross(uQ_16, uQ_7)
                    local vj = vector.dot(uQ_16, uQ_7)
                    if vector.dot(vi, vi) + vj * vj == vector.dot(uQ_16, uQ_16) * vector.dot(uQ_7, uQ_7) + 3 then
                        uQ_1 = GetOreState:WaitForChild("MeltOre")
                        m7 = GetOreState:WaitForChild("CollectCash")
                        uQ_14 = GetOreState:WaitForChild("GetOreState")
                        ox = GetOreState:WaitForChild("OreStateChanged")
                        m3 = GetOreState:WaitForChild("GetMinerData")
                    else
                        m7 = uQ_1:WaitForChild("MeltOre")
                        m3 = uQ_1:WaitForChild("CollectCash")
                        GetOreState = uQ_1:WaitForChild("GetOreState")
                        uQ_14 = uQ_1:WaitForChild("OreStateChanged")
                        ox = uQ_1:WaitForChild("GetMinerData")
                    end
                    uQ_9 = (uQ_9 + 83) % 160
                end
            else
                if (uQ_9 * 3 + 9) * 13 % 4 == ((uQ_9 * 3 + 9) * 13 + 9) % 4 then
                    uQ_1 = MinerDataChanged:WaitForChild("MinerDataChanged")
                else
                    MinerDataChanged = uQ_1:WaitForChild("MinerDataChanged")
                end
                uQ_9 = (uQ_9 + 63) % 160
            end
        elseif uQ_27 <= 9 then
            uQ_16 = { "bfgtev", "xgozkuqpr", "hxh", "kis", "kxjtdycwc", "dwqxrk", "hfnw" }
            local wd = uQ_9
            uQ_7 = uQ_16[wd % 7 + 1]
            if uQ_7:len() >= uQ_7:reverse():rep(wd % 3 + 2):len() then
                uQ_1 = uQ_12:WaitForChild("DoRebirth")
                n8 = uQ_12:WaitForChild("GetRebirthData")
                of = uQ_12:WaitForChild("RebirthChanged")
                om = uQ_12:WaitForChild("AutoSpinSet")
                uQ_4 = uQ_12:WaitForChild("SpinPhase")
            else
                om = uQ_1:WaitForChild("DoRebirth")
                of = uQ_1:WaitForChild("GetRebirthData")
                uQ_4 = uQ_1:WaitForChild("RebirthChanged")
                n8 = uQ_1:WaitForChild("AutoSpinSet")
                uQ_12 = uQ_1:WaitForChild("SpinPhase")
            end
            uQ_9 = (uQ_9 + 143) % 160
        else
            if (uQ_9 * 2 + 9) * 16 % 3 == ((uQ_9 * 2 + 9) * 16 + 2) % 3 then
                nY = ClaimDaily:WaitForChild("PlaceMiner")
                nV = ClaimDaily:WaitForChild("TrashPickaxe")
                uQ_1 = ClaimDaily:WaitForChild("TeleportPlot")
                n1 = ClaimDaily:WaitForChild("TeleportPlatform")
                nR = ClaimDaily:WaitForChild("ClaimDaily")
            else
                n1 = uQ_1:WaitForChild("PlaceMiner")
                nY = uQ_1:WaitForChild("TrashPickaxe")
                nV = uQ_1:WaitForChild("TeleportPlot")
                nR = uQ_1:WaitForChild("TeleportPlatform")
                ClaimDaily = uQ_1:WaitForChild("ClaimDaily")
            end
            uQ_9 = (uQ_9 + 103) % 160
        end
    elseif uQ_27 <= 15 then
        if uQ_27 <= 13 then
            if uQ_27 <= 12 then
                if uQ_27 <= 11 then
                    local vo = bit32.rrotate(bit32.bxor(bit32.lrotate(uQ_9, 10), string.byte(tostring(m8))), 4)
                    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(vo, 1090411197), 1799253251), (bit32.bxor(bit32.band(vo, 3204556098), 52351829))), 1799253251), 52351829) == vo then
                        nI = uQ_1:WaitForChild("GetDailyData")
                        nF = uQ_1:WaitForChild("ClaimPlayTime")
                        nA = uQ_1:WaitForChild("GetPlayTimeData")
                        nv = uQ_1:WaitForChild("ClaimGroupReward")
                        GetGroupReward = uQ_1:WaitForChild("GetGroupReward")
                    else
                        uQ_1 = GetGroupReward:WaitForChild("GetDailyData")
                        nI = GetGroupReward:WaitForChild("ClaimPlayTime")
                        nF = GetGroupReward:WaitForChild("GetPlayTimeData")
                        nA = GetGroupReward:WaitForChild("ClaimGroupReward")
                        nv = GetGroupReward:WaitForChild("GetGroupReward")
                    end
                    uQ_9 = (uQ_9 + 103) % 160
                else
                    local wl = bit32.rrotate(bit32.bxor(bit32.lrotate(uQ_9, 6), string.byte(tostring(nI))), 8)
                    if bit32.bxor(bit32.lrotate(bit32.bxor(wl, 888959991), 22), 4258086684) ~= bit32.lrotate(wl, 22) then
                        uQ_1 = ClaimOfflineEarnings:WaitForChild("ClaimOfflineEarnings")
                    else
                        ClaimOfflineEarnings = uQ_1:WaitForChild("ClaimOfflineEarnings")
                    end
                    uQ_9 = (uQ_9 + 23) % 160
                end
            else
                uQ_16 = {
                    "rcqlsdjjj",
                    "dohj",
                    "jgonmlsk",
                    "bbx",
                    "wpvtwsdp",
                    "dqflzyrjhfd",
                    "dajvgaq",
                    "duuryqnzuozz",
                    "euwtjkg",
                    "grvo",
                    "lvbmrco",
                    "ijunvjadljji",
                    "jkhyobimn",
                    "dmidyfsxc",
                    "kpyvwu",
                    "revll"
                }
                if uQ_16[(uQ_9 * 43 + 105) % 16 + 1] <= uQ_16[(uQ_9 * 43 + 105) % 16 + 1] then
                    nj = uQ_1:WaitForChild("GetMinerShop")
                    uQ_26 = { "Ore", "Pickaxes", "Luck", "Mutation", "Axe Speed", "Rolls", "Miners" }
                    uQ_5 = {}
                    m8 = {}
                else
                    m8 = uQ_26:WaitForChild("GetMinerShop")
                    uQ_1 = { "Pickaxes", "Ore", "Mutation", "Axe Speed", "Luck", "Rolls", "Miners" }
                    nj = {}
                    uQ_5 = {}
                end
                uQ_9 = (uQ_9 + 143) % 160
            end
        elseif uQ_27 <= 14 then
            local wb = bit32.rrotate(bit32.bxor(bit32.lrotate(uQ_9, 26), string.byte(tostring(MinerDataChanged))), 9)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(wb, 3046858165), 1301700425), (bit32.bxor(bit32.band(wb, 1248109130), 1321836155))), 1301700425), 1321836155) ~= wb then
                uQ_2 = {}
                m5 = {}
            else
                m5 = {}
                uQ_2 = {}
            end
            uQ_9 = (uQ_9 + 83) % 160
        else
            uQ_16 = {
                "wmbq",
                "sciktzttwfq",
                "eznrfwih",
                "wlpr",
                "svzlriep",
                "engjnnzamwh",
                "swzhytqj",
                "yyqmehg",
                "nyziobcvwi",
                "ljyretqorbv"
            }
            local wk = uQ_9
            uQ_7 = uQ_16[wk % 10 + 1]
            if uQ_7:len() <= uQ_7:gsub("(.)", "%1%1", wk % 3 % 2 + 1):len() then
                uQ_19 = game:GetService("Players")
            else
                ol = game:GetService("Players")
            end
            uQ_9 = (uQ_9 + 3) % 160
        end
    elseif uQ_27 <= 18 then
        if uQ_27 <= 17 then
            if uQ_27 <= 16 then
                uQ_16 = {
                    "sjsfomrkhrj",
                    "esumrjpwfchv",
                    "dufso",
                    "uicwwil",
                    "hjieqsauup",
                    "axrrviq",
                    "jhvhdvsdcwc",
                    "slxgrebe",
                    "omqnxamzxttg",
                    "vhff",
                    "abtxi",
                    "icxtmgnafb",
                    "tayzgk",
                    "qmrngnn",
                    "ddxonsqoragn"
                }
                if uQ_16[(uQ_9 * 84 + 105) % 15 + 1] < uQ_16[(uQ_9 * 84 + 105) % 15 + 1] then
                    nU = game:GetService("ReplicatedStorage")
                else
                    uQ_21 = game:GetService("ReplicatedStorage")
                end
                uQ_9 = (uQ_9 + 123) % 160
            else
                if (uQ_9 * 2 + 6) * 16 % 3 == ((uQ_9 * 2 + 6) * 16 + 0) % 3 then
                    UserInputService = game:GetService("UserInputService")
                else
                    ol = game:GetService("UserInputService")
                end
                uQ_9 = (uQ_9 + 3) % 160
            end
        else
            uQ_16 = (vector.create((uQ_9 * 5 + 1) % 11 + 1, (uQ_9 * 2 + 2) % 13 + 1, (uQ_9 * 8 + 17) % 17 + 1))
            uQ_7 = (vector.create((uQ_9 * 1 + 8) % 11 + 1, (uQ_9 * 8 + 2) % 13 + 1, (uQ_9 * 15 + 10) % 17 + 1))
            local wh = vector.cross(uQ_16, uQ_7)
            local wi = vector.dot(uQ_16, uQ_7)
            if vector.dot(wh, wh) + wi * wi == vector.dot(uQ_16, uQ_16) * vector.dot(uQ_7, uQ_7) then
                ow = game:GetService("VirtualUser")
                Workspace = game:GetService("Workspace")
                ol = uQ_19.LocalPlayer
                uQ_15 = "Build An Ore Farm"
                ob = "https://discord.gg/K7Qxnxkk46"
            else
                uQ_19 = game:GetService("VirtualUser")
                ow = game:GetService("Workspace")
                ob = Workspace.LocalPlayer
                ol = "Build An Ore Farm"
                uQ_15 = "https://discord.gg/K7Qxnxkk46"
            end
            uQ_9 = (uQ_9 + 123) % 160
        end
    elseif uQ_27 <= 19 then
        if uQ_9 * 40644869 + 1 + 3 <= uQ_9 * 40644869 + 1 + 3 + 4 then
            n7 = "https://discord.gg/K7Qxnxkk46"
        else
            uQ_21 = "https://discord.gg/K7Qxnxkk46"
        end
        uQ_9 = (uQ_9 + 3) % 160
    else
        uQ_27 = (vector.create((uQ_9 * 3 + 2) % 11 + 1, (uQ_9 * 3 + 2) % 13 + 1, (uQ_9 * 2 + 3) % 17 + 1))
        local vq = vector.floor(uQ_27) + vector.ceil(uQ_27 * -1)
        if vector.dot(vq, vq) == 4 then
            uQ_21 = uQ_1:WaitForChild("Remotes")
        else
            uQ_1 = uQ_21:WaitForChild("Remotes")
        end
        uQ_9 = (uQ_9 + 43) % 160
    end
until (uQ_9 * 27 + 156) % 160 == 7
for i, v in ipairs(uQ_11) do
    table.insert(uQ_5, v.name)
    m8[v.name] = i
    uQ_19 = v.name
    uQ_9 = v.value or 0
    m5[uQ_19] = uQ_9
    uQ_19 = v.name
    uQ_9 = v.oneIn or 0
    uQ_2[uQ_19] = uQ_9
end
oo = {}
uQ_19 = {}
for i, v in ipairs(uQ_23.Tiers) do
    table.insert(uQ_19, v.Name)
    oo[v.Name] = i
end
Library, Toggles, Options, oh, nQ, nJ, nG, n9, n4, nN, nw, nk, m9, oa, nP, nr, nf, oi, nC, na, oj, oz, ot, oe, n0, nL, nu, oy, nS, nB, nn, nd, oB, op, nO, nq, ne, oE, n6, ng, n2, nD, oC, nX, oA, m4, nZ, og, ov, oc = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
uQ_7 = getgenv().ThemeManager
uQ_27 = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
nN = fn533
nw = fn652
nk = fns.fn23
m9 = fn509
local uQ_8 = "#7fd47f"
local uQ_17 = "#6ec1ff"
oh = "#e8a34d"
local uQ_28 = "#8b93a3"
oa = fn321
nP = fns.fn277
nr = fn801
nf = fn300
oi = fns.fn66
nQ = nil
nJ = { carrying = 0, stock = 0, banked = 0, rate = 0, upgradeCost = 0, level = 0 }
nG = nil
nC = fn775
na = fns.fn18
oj = fn435
MinerDataChanged.OnClientEvent:Connect(fns.onOnClientEvent)
uQ_14.OnClientEvent:Connect(onOnClientEvent2)
uQ_4.OnClientEvent:Connect(fns.onOnClientEvent3)
task.spawn(fns.worker)
oz = fn682
ot = fn707
oe = fns.fn88
n0 = fns.fn105
nL = fns.fn159
nu = function(b4)
    local Enabled
    local HoldDuration
    Enabled = nil
    HoldDuration = nil
    if not b4 or not b4.Parent then
        return false
    end
    HoldDuration = b4.HoldDuration
    Enabled = b4.Enabled
    local qq_1 = pcall(function()
        b4.Enabled = true
        b4.HoldDuration = 0
        if fireproximityprompt then
            fireproximityprompt(b4)
        else
            b4:InputHoldBegin()
            b4:InputHoldEnd()
        end
    end)
    pcall(function()
        b4.HoldDuration = HoldDuration
        b4.Enabled = Enabled
    end)
    return qq_1
end
oy = fn814
n9 = false
n4 = 0
uQ_12.OnClientEvent:Connect(fns.onOnClientEvent4)
nS = fns.fn74
nB = fn626
if (not nP or not Toggles) and (not nn and nu) and (not op and uQ_7 and (not nn or op)) or (not nn or not Toggles or op and not nn) and (not Toggles and not op and (Toggles or not op)) or not ((not nP or not Toggles) and (not nn and nu) and (not op and uQ_7 and (not nn or op)) or (not nn or not Toggles or op and not nn) and (not Toggles and not op and (Toggles or not op))) then
    nn = fns.fn290
    nd = fn364
    oB = fn359
    op = fns.fn269
    nO = fn855
else
    op = fns.fn290
    nn = fn364
    nd = fn359
    nO = fns.fn269
    oB = fn855
end
nq = fn313
ne = fn490
oE = fn340
n6 = function(c8)
    local da = -1
    local Name
    oE(function(dc)
        local rk = if not nq(dc) then 1 else 0
        if rk == 1 then
            return
        end
        local rg = nO(dc.Name, c8)
        if rg > da then
            da = rg
            Name = dc.Name
        end
    end)
    return Name, da
end
ng = fns.fn175
n2 = fns.fn144
nD = fn816
oC = fn555
nX = function(d_)
    local d1 = -1
    local Name
    oE(function(d3)
        local r0 = if not nq(d3) then 1 else 0
        if r0 == 1 then
            return
        end
        if not oC(d3.Name) then
            return
        end
        local rX = nO(d3.Name, d_)
        if rX > d1 then
            d1 = rX
            Name = d3.Name
        end
    end)
    return Name, d1
end
oA = fn866
m4 = function()
    local so, sp
    so = oa("AutoSpecificRoll")
    local sq = nf("RollTargets")
    sp = {}
    for k in pairs(sq) do
        sp[k] = true
    end
    pcall(function()
        n8:FireServer(so, sp)
    end)
end
nZ = fns.fn146
og = fn826
ov = fn609
oc = fn591
uQ_21 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = ob, Copyable = true }, "|", uQ_15 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
uQ_16 = {
    Info = uQ_21:AddTab("Info", "info"),
    Main = uQ_21:AddTab("Main", "pickaxe"),
    Misc = uQ_21:AddTab("Misc", "sparkles"),
    Settings = uQ_21:AddTab("Settings", "settings")
}
uQ_16.Farm = uQ_16.Main:AddSubTab("Farm", "factory")
uQ_16.Roll = uQ_16.Main:AddSubTab("Roll", "dices")
uQ_16.Upgrades = uQ_16.Main:AddSubTab("Upgrades", "arrow-up")
uQ_16.Inventory = uQ_16.Main:AddSubTab("Inventory", "backpack")
uQ_23 = fn335
for k, v in uQ_16 do
    if v ~= uQ_16.Main then
        uQ_23(v)
    end
end
nx, uQ_9, uQ_11, m6, oF, uQ_21 = nil, nil, nil, nil, nil, nil
uQ_1 = 7
repeat
    uQ_2 = (uQ_1 * 2 + 2) % 3 + 1
    if uQ_2 <= 2 then
        if uQ_2 <= 1 then
            local wj = bit32.rrotate(bit32.bxor(bit32.lrotate(uQ_1, 3), string.byte(tostring(uQ_9))), 14)
            if bit32.bxor(bit32.lrotate(bit32.bxor(wj, 1821908185), 20), 3449211265) ~= bit32.lrotate(wj, 20) then
                oF = #uQ_21 > 18
            else
                uQ_21 = #oF > 18
            end
            uQ_1 = (uQ_1 + 8) % 24
        else
            uQ_2 = (vector.create((uQ_1 * 1 + 8) % 11 + 1, (uQ_1 * 9 + 1) % 13 + 1, (uQ_1 * 7 + 15) % 17 + 1))
            uQ_23 = (vector.create((uQ_1 * 7 + 4) % 11 + 1, (uQ_1 * 9 + 5) % 13 + 1, (uQ_1 * 11 + 8) % 17 + 1))
            uQ_12 = (vector.create((uQ_1 * 3 + 3) % 11 + 1, (uQ_1 * 9 + 10) % 13 + 1, (uQ_1 * 4 + 10) % 17 + 1))
            if vector.dot(vector.cross(uQ_2, uQ_23), uQ_12) == vector.dot(vector.cross(uQ_23, uQ_12), uQ_2) then
                nx = "Unknown"
                pcall(fn471)
                uQ_9 = uQ_16.Info:AddLeftGroupbox("Account", "circle-user")
                uQ_9:AddLabel(m9("User", ol.Name, uQ_8), true)
                uQ_9:AddLabel(m9("Status", "Keyless", uQ_8), true)
                uQ_9:AddLabel(m9("Executor", nx, uQ_8), true)
                uQ_11 = uQ_16.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                uQ_11:AddLabel(nk(uQ_15 .. " [" .. tostring(game.PlaceId) .. "]", uQ_17), true)
                uQ_11:AddLabel(m9("Place ID", tostring(game.PlaceId), uQ_17), true)
                m6 = uQ_11:AddLabel(m9("Session time", "0s", oh), true)
            else
                uQ_16 = "Unknown"
                pcall(fn471)
                ol = uQ_11.Info:AddLeftGroupbox("Account", "circle-user")
                ol:AddLabel(uQ_15("User", m9.Name, uQ_17), true)
                ol:AddLabel(uQ_15("Status", "Keyless", uQ_17), true)
                ol:AddLabel(uQ_15("Executor", "Unknown", uQ_17), true)
                m6 = uQ_11.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                m6:AddLabel(uQ_9(oh .. " [" .. tostring(game.PlaceId) .. "]", uQ_8), true)
                m6:AddLabel(uQ_15("Place ID", tostring(game.PlaceId), uQ_8), true)
                nx = m6:AddLabel(uQ_15("Session time", "0s", nk), true)
            end
            uQ_1 = (uQ_1 + 11) % 24
        end
    else
        if uQ_1 * 112352705 + 4 + 6 >= uQ_1 * 112352705 + 4 + 6 + 1 then
            m6 = tostring(game.JobId)
        else
            oF = tostring(game.JobId)
        end
        uQ_1 = (uQ_1 + 5) % 24
    end
until (uQ_1 * 19 + 0) % 24 == 13
if uQ_21 then
    uQ_9 = 4
    repeat
        uQ_1 = (vector.create((uQ_9 * 4 + 3) % 11 + 1, (uQ_9 * 3 + 2) % 13 + 1, (uQ_9 * 11 + 1) % 17 + 1))
        uQ_2 = (vector.create((uQ_9 * 3 + 8) % 11 + 1, (uQ_9 * 10 + 3) % 13 + 1, (uQ_9 * 6 + 8) % 17 + 1))
        uQ_23 = (vector.create((uQ_9 * 5 + 3) % 11 + 1, (uQ_9 * 2 + 4) % 13 + 1, (uQ_9 * 9 + 1) % 17 + 1))
        uQ_12 = (vector.create((uQ_9 * 1 + 5) % 11 + 1, (uQ_9 * 8 + 5) % 13 + 1, (uQ_9 * 13 + 6) % 17 + 1))
        if vector.dot(vector.cross(uQ_1, uQ_2), (vector.cross(uQ_23, uQ_12))) == vector.dot(uQ_1, uQ_23) * vector.dot(uQ_2, uQ_12) - vector.dot(uQ_1, uQ_12) * vector.dot(uQ_2, uQ_23) + 3 then
            oF = string.sub(uQ_21, 1, 18) .. "..."
        else
            uQ_21 = string.sub(oF, 1, 18) .. "..."
        end
        uQ_9 = (uQ_9 + 0) % 8
    until (uQ_9 * 5 + 6) % 8 == 2
end
uQ_9 = uQ_21 or oF
od, uQ_4, uQ_12, ny, ns, connection, connection2, nb = nil, nil, nil, nil, nil, nil, nil, nil
local o6 = uQ_9
uQ_11:AddLabel(m9("Server", o6, uQ_28), true)
uQ_11:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
od = os.clock()
task.spawn(worker2)
local ScriptsGroup = uQ_16.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(nk("Included in this hub", uQ_28), true)
ScriptsGroup:AddLabel(nk(uQ_15, uQ_17), true)
local FeaturesGroup = uQ_16.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(nk("Auto Farm", uQ_17), true)
FeaturesGroup:AddLabel(nk("Auto Roll", oh), true)
FeaturesGroup:AddLabel(nk("Auto Upgrades", uQ_8), true)
FeaturesGroup:AddLabel(nk("Inventory Tools", uQ_28), true)
uQ_14 = uQ_16.Info:AddRightGroupbox("Socials", "link")
if ((not uQ_12 or not nb or (not uQ_12 or nb)) and (nb or nb or (not uQ_12 or not nb)) or not nb and not nb and (nb or not uQ_12) and (uQ_12 and not uQ_12 or not uQ_12 and nb)) and ((uQ_12 and uQ_12 and (not uQ_12 and nb) or (nb and not nb or (uQ_12 or nb))) and ((uQ_12 or nb or (nb or not uQ_12)) and (not nb or nb or not uQ_12 and nb))) and not (((not uQ_12 or not nb or (not uQ_12 or nb)) and (nb or nb or (not uQ_12 or not nb)) or not nb and not nb and (nb or not uQ_12) and (uQ_12 and not uQ_12 or not uQ_12 and nb)) and ((uQ_12 and uQ_12 and (not uQ_12 and nb) or (nb and not nb or (uQ_12 or nb))) and ((uQ_12 or nb or (nb or not uQ_12)) and (not nb or nb or not uQ_12 and nb)))) then
    uQ_4:AddButton({ Text = "Discord", Func = uQ_14 })
    uQ_4:AddButton({ Text = "Rscripts", Func = onRscripts })
    uQ_16 = nw.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
else
    uQ_14:AddButton({ Text = "Discord", Func = nw })
    uQ_14:AddButton({ Text = "Rscripts", Func = onRscripts })
    uQ_4 = uQ_16.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
end
uQ_4:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
uQ_4:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
uQ_4:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
uQ_4:AddButton({ Text = "Copy Discord Invite", Func = nw })
uQ_12 = uQ_16.Info:AddRightGroupbox("FAQ", "circle-help")
uQ_12:AddLabel("Where do I get a good config?", true)
uQ_12:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
uQ_12:AddLabel("How do I import / export configs?", true)
uQ_12:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
uQ_12:AddLabel("How do I report bugs?", true)
uQ_12:AddLabel("Join the Discord and post it in the bugs channel.", true)
uQ_12:AddLabel("How do I make suggestions?", true)
uQ_12:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
uQ_12:AddLabel("How do I get help or updates?", true)
uQ_12:AddLabel("Join the Discord, updates and support are posted there first.", true)
uQ_23 = uQ_16.Farm:AddLeftGroupbox("Farm")
uQ_23:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
uQ_23:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
uQ_23:AddSlider("FarmDelay", { Text = "Farm Delay", Default = 0.35, Min = 0.1, Max = 2, Rounding = 2, Suffix = "s" })
uQ_2 = uQ_16.Farm:AddRightGroupbox("Shop Miners")
uQ_2:AddToggle("AutoBuyShopMiners", { Text = "Auto Buy Shop Miners", Default = false })
uQ_2:AddDropdown("ShopMinerTargets", {
    Text = "Shop Miners",
    Values = uQ_19,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true
})
uQ_2:AddToggle("AutoPlaceMiners", { Text = "Auto Place / Replace Miners", Default = false })
uQ_21 = uQ_16.Roll:AddLeftGroupbox("Roll")
uQ_21:AddToggle("AutoSpin", { Text = "Auto Spin", Default = false })
uQ_21:AddToggle("AutoSpecificRoll", { Text = "Auto Specific Roll", Default = false })
uQ_21:AddToggle("AutoBuyAny", { Text = "Auto Buy Any", Default = false })
uQ_21:AddToggle("AutoBuyDisplays", { Text = "Auto Buy Selected Pickaxes", Default = false })
uQ_21:AddToggle("AutoSkipUnaffordable", { Text = "Auto Skip If Can't Afford", Default = true })
uQ_21:AddSlider("RollDelay", { Text = "Roll Delay", Default = 0.55, Min = 0.2, Max = 3, Rounding = 2, Suffix = "s" })
uQ_1 = uQ_16.Roll:AddRightGroupbox("Targets")
uQ_1:AddDropdown("RollTargets", {
    Text = "Pickaxes",
    Values = uQ_5,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Callback = onRollTargets
})
local UpgradesGroup = uQ_16.Upgrades:AddLeftGroupbox("Upgrades")
UpgradesGroup:AddToggle("AutoUpgrade", { Text = "Auto Upgrade", Default = false })
UpgradesGroup:AddDropdown("UpgradeTargets", {
    Text = "Upgradeables",
    Values = uQ_26,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true
})
UpgradesGroup:AddSlider("UpgradeDelay", { Text = "Upgrade Delay", Default = 0.4, Min = 0.1, Max = 2, Rounding = 2, Suffix = "s" })
local InventoryGroup = uQ_16.Inventory:AddLeftGroupbox("Inventory")
InventoryGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false })
InventoryGroup:AddToggle("AutoPlacePickaxes", { Text = "Auto Place Pickaxes", Default = false })
InventoryGroup:AddDropdown("PlacePickaxeMode", { Text = "Place Mode", Values = { "Empty Only", "Replace Worse" }, Default = "Replace Worse" })
InventoryGroup:AddDropdown("PlaceCompareBy", { Text = "Compare By", Values = { "Rarity", "Money" }, Default = "Rarity" })
InventoryGroup:AddDropdown("PlacePickaxeTargets", {
    Text = "Place Pickaxes",
    Values = uQ_5,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true
})
InventoryGroup:AddDropdown("PlaceMinPickaxe", { Text = "Minimum", Values = uQ_5, Default = "Basic" })
InventoryGroup:AddToggle("AutoTrashWeak", { Text = "Auto Trash Weak", Default = false })
InventoryGroup:AddDropdown("TrashBelow", { Text = "Trash Below", Values = uQ_5, Default = "Basic" })
InventoryGroup:AddSlider("InventoryDelay", { Text = "Inventory Delay", Default = 0.5, Min = 0.2, Max = 3, Rounding = 2, Suffix = "s" })
local ClaimsGroup = uQ_16.Misc:AddLeftGroupbox("Claims")
ClaimsGroup:AddToggle("AutoClaimDaily", { Text = "Auto Claim Daily", Default = false })
ClaimsGroup:AddToggle("AutoClaimPlayTime", { Text = "Auto Claim Playtime", Default = false })
ClaimsGroup:AddToggle("AutoClaimGroup", { Text = "Auto Claim Group", Default = false })
ClaimsGroup:AddToggle("AutoClaimOffline", { Text = "Auto Claim Offline", Default = false })
local TeleportGroup = uQ_16.Misc:AddRightGroupbox("Teleport")
TeleportGroup:AddButton({ Text = "Teleport Plot", Func = onTeleportPlot })
TeleportGroup:AddButton({ Text = "Platform Up", Func = onPlatformUp })
TeleportGroup:AddButton({ Text = "Platform Down", Func = onPlatformDown })
TeleportGroup:AddButton({ Text = "Teleport to Lever", Func = onTeleportToLever })
local MenuGroup = uQ_16.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", fns.onUnload)
Library.ToggleKeybind = Options.MenuKeybind
uQ_7:SetLibrary(Library)
uQ_7:SetFolder("TempoHub")
uQ_7:SaveDefault("Monochrome")
uQ_7:ApplyToTab(uQ_16.Settings)
uQ_7:LoadDefault()
uQ_27:SetLibrary(Library)
uQ_27:IgnoreThemeSettings()
uQ_27:SetIgnoreIndexes({ "MenuKeybind" })
uQ_27:SetFolder("TempoHub/build-an-ore-farm")
uQ_27:BuildConfigSection(uQ_16.Settings)
uQ_27:LoadAutoloadConfig()
ny = tick()
ns = tick()
pcall(function()
    for i, v in ipairs(getconnections(ol.Idled)) do
        local tu = v
        pcall(function()
            tu:Disable()
        end)
    end
end)
nb = fn423
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
Toggles.AutoSpecificRoll:OnChanged(fn633)
task.spawn(function()
    local tE_1
    local tD_2
    while not Library.Unloaded do
        local tA = nr("FarmDelay", 0.35)
        if oa("AutoSell") then
            na()
            local tB_1 = nL("DispOre")
            local tC_1 = math.max(nL("DispBanked"), nJ.banked)
            if tB_1 >= 1 and nJ.carrying <= 0 then
                pcall(function()
                    nc:FireServer()
                end)
                task.wait(0.15)
            end
            if nJ.carrying > 0 then
                pcall(function()
                    m7:FireServer()
                end)
                task.wait(0.15)
            end
            if tC_1 > 0 then
                pcall(function()
                    m3:FireServer()
                end)
            end
        end
        if oa("AutoBuyShopMiners") then
            local tB_2 = nQ or nC()
            local tC_2 = tB_2
            if tB_2 then
                tB_2 = tC_2.cash
            end
            local tC_3 = tB_2 or 0
            local tC_4 = nf("ShopMinerTargets")
            if next(tC_4) then
                tD_2, tE_1 = pcall(function()
                    return nj:InvokeServer()
                end)
                local tF = tD_2 and type(tE_1) == "table" and type(tE_1.rows) == "table"
                if tF then
                    for k, v in pairs(tE_1.rows) do
                        local tM = v
                        local tD_3 = type(tM) == "table" and tC_4[tM.name]
                        if tD_3 then
                            tD_3 = (tM.stock or 0) > 0
                        end
                        if tD_3 then
                            tD_3 = tC_3 >= (tM.price or math.huge)
                        end
                        if tD_3 then
                            pcall(function()
                                no:InvokeServer(tM.index)
                            end)
                            break
                        end
                    end
                end
            end
        end
        if oa("AutoRebirth") then
            local tB_4 = nG or oj()
            local tC_5 = tB_4
            if tB_4 then
                tB_4 = tC_5.canRebirth
            end
            if tB_4 then
                pcall(function()
                    om:FireServer()
                end)
                oj()
            end
        end
        task.wait(tA)
    end
end)
task.spawn(worker3)
task.spawn(function()
    while not Library.Unloaded do
        local tR = nr("UpgradeDelay", 0.4)
        local tS = oa("AutoUpgrade") and oi("UpgradeTargets")
        local tS_4
        if tS then
            local tS_1 = nC()
            local tU = tS_1 and tS_1.cash or 0
            local tU_19
            local tT_1 = tU
            if oB("Ore") then
                na()
                local tV_1 = tT_1 >= (nJ.upgradeCost or math.huge)
                if tV_1 then
                    tV_1 = (nJ.upgradeCost or 0) > 0
                end
                if tV_1 then
                    pcall(function()
                        nh:FireServer()
                    end)
                    tS_1 = nC()
                    tT_1 = tS_1 and tS_1.cash or tT_1
                end
            end
            local tU_4 = oB("Rolls") and tS_1 and tS_1.rolls and tS_1.maxRolls and tS_1.rollCost
            if tU_4 then
                if tS_1.rolls < tS_1.maxRolls and tT_1 >= tS_1.rollCost then
                    pcall(function()
                        nK:InvokeServer()
                    end)
                    tS_1 = nC()
                    tT_1 = tS_1 and tS_1.cash or tT_1
                end
            end
            local tU_7 = oB("Miners") and tS_1 and tS_1.miners and tS_1.maxMiners and tS_1.cost
            if tU_7 then
                if tS_1.miners < tS_1.maxMiners and tT_1 >= tS_1.cost then
                    pcall(function()
                        nH:InvokeServer()
                    end)
                    tS_1 = nC()
                    tT_1 = tS_1 and tS_1.cash or tT_1
                end
            end
            local tU_10 = oB("Luck") and tS_1 and tS_1.luck and tS_1.luckMax and tS_1.luckCost
            if tU_10 then
                if tS_1.luck < tS_1.luckMax and tT_1 >= tS_1.luckCost then
                    pcall(function()
                        BuyLuck:InvokeServer()
                    end)
                    tS_1 = nC()
                    tT_1 = tS_1 and tS_1.cash or tT_1
                end
            end
            local tU_13 = oB("Mutation") and tS_1 and tS_1.mut and tS_1.mutMax and tS_1.mutCost
            if tU_13 then
                if tS_1.mut < tS_1.mutMax and tT_1 >= tS_1.mutCost then
                    pcall(function()
                        nz:InvokeServer()
                    end)
                    tS_1 = nC()
                    tT_1 = tS_1 and tS_1.cash or tT_1
                end
            end
            local tU_16 = oB("Axe Speed") and tS_1 and tS_1.axeMult and tS_1.axeSpeedCost
            if tU_16 then
                if tS_1.axeMult < 10 and tT_1 >= tS_1.axeSpeedCost then
                    pcall(function()
                        nt:InvokeServer()
                    end)
                    local tS_2 = nC()
                    tT_1 = tS_2 and tS_2.cash or tT_1
                end
            end
            if oB("Pickaxes") then
                for i, v in ipairs(n2()) do
                    local t7 = v
                    if Library.Unloaded then
                        break
                    end
                    tS_4, tU_19 = pcall(function()
                        return GetPickaxeInfo:InvokeServer(t7)
                    end)
                    local tV_7 = tS_4 and type(tU_19) == "table" and tU_19.cost and tT_1 >= tU_19.cost
                    if tV_7 then
                        pcall(function()
                            nl:InvokeServer(t7)
                        end)
                        tT_1 = tT_1 - tU_19.cost
                        task.wait(0.1)
                    end
                end
            end
        end
        task.wait(tR)
    end
end)
task.spawn(function()
    local ut = false
    repeat
        local uj, uk
        if not Library.Unloaded then
            local um = nr("InventoryDelay", 0.5)
            local un = nP("PlaceCompareBy", "Rarity")
            if oa("AutoEquipBest") then
                local uo_1 = n6(un)
                if uo_1 then
                    ng(uo_1)
                end
            end
            if oa("AutoPlacePickaxes") then
                oA()
            end
            if oa("AutoPlaceMiners") then
                uj = nil
                oE(function(iK)
                    if ne(iK) then
                        local t8 = uj
                        local uc = if t8 then 1 else 0
                        local ua = 1884 * uc + 3022 * (1 - uc)
                        local ub = 2013 * uc + 57 * (1 - uc)
                        if not ((ua * 1879 + ub * 1150 + ua * ub) % 16777213 == 9647478) then
                            t8 = iK
                        end
                        uj = t8
                    end
                end)
                local un_1 = uj and ng(uj.Name)
                if un_1 then
                    local un_2 = oo[uj.Name] or 0
                    local uo_2 = math.huge
                    local ul
                    for i, v in ipairs(n2()) do
                        local un_3 = tonumber(v:GetAttribute("MinerTier")) or 0
                        if un_3 <= 0 then
                            ul = v
                            break
                        end
                        if un_3 < un_2 and un_3 < uo_2 then
                            uo_2 = un_3
                            ul = v
                        end
                    end
                    if ul then
                        oy(ul)
                        task.wait(0.1)
                        pcall(function()
                            n1:FireServer(ul)
                        end)
                    end
                end
            end
            if oa("AutoTrashWeak") then
                local un_5 = nP("TrashBelow", "Basic")
                uk = m8[un_5] or 1
                oE(function(i3)
                    if not nq(i3) then
                        return
                    end
                    local ud = m8[i3.Name] or 0
                    if ud > 0 and ud < uk then
                        local ui = if ng(i3.Name) then 1 else 0
                        if ui == 1 then
                            task.wait(0.1)
                            pcall(function()
                                nY:FireServer()
                            end)
                        end
                    end
                end)
            end
            task.wait(um)
        else
            ut = true
        end
    until ut
end)
task.spawn(function()
    local uB_1, uB_2, uB_3
    local uA_1, uA_2, uA_4
    while not Library.Unloaded do
        if oa("AutoClaimDaily") then
            uA_1, uB_1 = pcall(function()
                return nI:InvokeServer()
            end)
            local uC_1 = uA_1 and type(uB_1) == "table" and uB_1.state and uB_1.state.available
            if uC_1 then
                pcall(function()
                    ClaimDaily:InvokeServer()
                end)
            end
        end
        if oa("AutoClaimPlayTime") then
            uA_2, uB_2 = pcall(function()
                return nA:InvokeServer()
            end)
            local uC_2 = uA_2 and type(uB_2) == "table" and type(uB_2.rewards) == "table"
            if uC_2 then
                for i, v in ipairs(uB_2.rewards) do
                    local uJ = v
                    if uJ.ready and not uJ.claimed then
                        pcall(function()
                            nF:InvokeServer(uJ.index)
                        end)
                        task.wait(0.1)
                    end
                end
            end
        end
        if oa("AutoClaimGroup") then
            uA_4, uB_3 = pcall(function()
                return GetGroupReward:InvokeServer()
            end)
            local uC_3 = uA_4 and type(uB_3) == "table" and uB_3.inGroup and not uB_3.claimed
            if uC_3 then
                pcall(function()
                    nv:InvokeServer()
                end)
            end
        end
        if oa("AutoClaimOffline") then
            pcall(function()
                ClaimOfflineEarnings:FireServer()
            end)
        end
        task.wait(2)
    end
end)
task.spawn(antiAfkLoop)
Library:OnUnload(fn574)
end)(...)

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
getgenv().TempoHoodSubtitle = "+1 SMASH WALLS FOR ANIME CHA"
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
local l3
local mL
local UpgradeShopConfig
local l6
local mO
local ms
local Options
local mv
local lR
local my
local Library
local CollectionService
local mf
local mB
local lX
local WeaponShopConfig
local lE
local ml
local TeleportConfig
local lH
local mo
local l2
local mr
local l5
local lN
local l8
local mu
local LocalPlayer
local Toggles
local me
local CombatConfig
local lD
local mG
local lG
local mn
local mJ
local l4
local RebirthConfig
local lJ
local PlotUpgradeState
local lM
local lP
local mw
local PlotConfig
local mz
local mg
local lC
local RebirthState
local mj
local mF
local l0
local BigNum
local lI
local function fn26()
    if l8() then
        mo()
    end
end
local function fn71()
    local Character = LocalPlayer.Character
    local nJ = Character and Character:FindFirstChildOfClass("Humanoid")
    return nJ
end
local function fn79(ef)
    local p1 = Options.UpgradeSelection and Options.UpgradeSelection.Value
    local p2 = ml(p1)
    if next(p2) == nil then
        return
    end
    local p1_1 = ef and ef.Plot
    if type(p1_1) ~= "table" then
        return
    end
    local p1_2 = ef and ef.Stats and ef.Stats.Coins
    for k, v in l2 do
        if p2[v] then
            local p1_3 = lX[v]
            local p5 = PlotUpgradeState.GetUpgradeState(p1_1, p1_3)
            local p6 = type(p5) == "table" and p5.isMaxed ~= true and lC(p1_2, p5.cost)
            if p6 then
                mn(UpgradeShopConfig.Mutations.BuyUpgrade, { upgradeId = p1_3 })
                return
            end
        end
    end
end
local function fn80(dF)
    local pq_1
    local pp_1
    pp_1, pq_1 = pcall(RebirthState.BuildPanelState, dF)
    local pr = not pp_1 or type(pq_1) ~= "table" or pq_1.canRebirth ~= true
    if pr then
        return
    end
    mn(RebirthConfig.Mutations.PerformRebirth, { skipRequirements = false, ignoreRequirements = false })
end
local function fn149()
    local qP = hookfunction ~= nil
    local qQ = hookmetamethod ~= nil
    local qR = getrawmetatable ~= nil
    local qS = setrawmetatable ~= nil
    local qT = getgc ~= nil
    local qU = getgenv ~= nil
    local qV = getreg ~= nil
    local qW = getconnections ~= nil
    local qX = firesignal ~= nil
    local qY = getcallbackvalue ~= nil
    local qZ = setclipboard ~= nil
    local q_ = getcustomasset ~= nil
    local q0 = getnamecallmethod ~= nil
    local q1 = isexecutorclosure ~= nil
    local q2 = fireproximityprompt ~= nil
    local q3 = firetouchinterest ~= nil
    local q4 = WebSocket ~= nil
    local q5 = readfile ~= nil
    local q6 = writefile ~= nil
    local q8 = (request or http_request) ~= nil
    local ra = (debug and debug.getupvalues) ~= nil
    local rc = (debug and debug.setupvalue) ~= nil
    local rd = 0
    local re = { qP, qQ, qR, qS, qT, qU, qV, qW, qX, qY, qZ, q_, q0, q1, q2, q3, q4, q5, q6, q8, ra, rc }
    for i, v in ipairs(re) do
        if v then
            rd += 1
        end
    end
    local qP_1 = rd / #re
    if qP_1 >= 0.9 then
        return lI("Full Support", me)
    elseif qP_1 >= 0.6 then
        return lI("Half Support", l0)
    else
        return lI("Low Support", lP)
    end
end
local function fn156(P, Q)
    local nl_1
    local nk_1
    nk_1, nl_1 = pcall(BigNum.compare, P.price, Q.price)
    if nk_1 then
        return nl_1 < 0
    end
    local nk_2 = tonumber(P.price) or 0
    local nl_2 = tonumber(Q.price) or 0
    return nk_2 < nl_2
end
local function fn188(af, ag)
    if setclipboard then
        setclipboard(af)
    elseif toclipboard then
        toclipboard(af)
    end
    Library:Notify(ag)
end
local function fn196(cI)
    local oU_1
    local WallCollision = cI:FindFirstChild("WallCollision", true)
    local oV = WallCollision and WallCollision:IsA("BasePart")
    if oV then
        oU_1 = WallCollision.Position
    else
        oU_1 = cI:GetPivot().Position
    end
    local oT_1 = Vector3.new(oU_1.X - 10, oU_1.Y + 3, oU_1.Z)
    return CFrame.lookAt(oT_1, Vector3.new(oU_1.X, oT_1.Y, oU_1.Z))
end
local function worker2()
    while not Library.Unloaded do
        local qN = lE("AutoCollectCharacters") or lE("AutoSell")
        if qN then
            pcall(mG)
        else
            if mv.autoCollectArmed or mv.autoSellArmed then
                l3()
            end
        end
        if lE("AutoEquipBest") then
            pcall(lN)
        end
        local qN_2 = lE("AutoCollectMoney") or lE("AutoRebirth") or lE("AutoBuyWeapons") or lE("AutoBestWeapon") or lE("AutoBuyUpgrades")
        if qN_2 then
            local qN_3 = lG()
            if qN_3 then
                if lE("AutoCollectMoney") then
                    pcall(mL, qN_3)
                end
                if lE("AutoRebirth") then
                    pcall(mu, qN_3)
                end
                if lE("AutoBuyWeapons") then
                    pcall(lH, qN_3)
                end
                if lE("AutoBestWeapon") then
                    pcall(mB, qN_3)
                end
                if lE("AutoBuyUpgrades") then
                    pcall(mz, qN_3)
                end
            end
        end
        if lE("AutoBestBiome") then
            pcall(lM)
        end
        task.wait(0.4)
    end
end
local function fn326()
    local qA = lE("AutoCollectCharacters") or lE("AutoSell")
    return qA
end
local function fn330(az)
    if Library.Unloaded then
        return false
    end
    local np = Toggles[az]
    return np ~= nil and np.Value == true
end
local function fn401()
    ms(mO, "Copied Discord invite to clipboard")
end
local function fn405()
    local nS_1
    local nR_1
    nR_1, nS_1 = pcall(function()
        return mr.RequestBootstrap:InvokeServer()
    end)
    local nT = not nR_1 or type(nS_1) ~= "table"
    if nT then
        return nil
    elseif type(nS_1.snapshot) == "table" then
        return nS_1.snapshot
    else
        return nS_1
    end
end
local function fn407(bL, bM)
    local n9 = Options[bL]
    local oa = n9 and n9.Value
    local n9_1 = ml(oa)
    local oa_1 = next(n9_1) == nil and bM
    if oa_1 then
        for k, v in mj do
            n9_1[v] = true
        end
    end
    return n9_1
end
local function fn420(ab)
    if ab then
        lD[#lD + 1] = ab
    end
    return ab
end
local function fn447(bW)
    local oi = lE("AutoCollectCharacters")
    local oj = lE("AutoSell")
    local ol = oj and lJ("SellRarities", false)[bW]
    if ol then
        return true
    end
    local oj_1 = oi and not lJ("CollectRarities", true)[bW]
    if oj_1 then
        return true
    end
    return false
end
local function fn452()
    pcall(function()
        mr.RequestAction:InvokeServer(TeleportConfig.Actions.EquipBest)
    end)
end
local function fn518()
    local oZ_1
    local oY_1
    local oX = mg()
    if not oX then
        oY_1, oZ_1 = pcall(function()
            return mr.RequestState:InvokeServer()
        end)
        local o_ = oY_1 and type(oZ_1) == "table"
        if o_ then
            local oY_2 = oZ_1.state
            local o3_1 = if oY_2 then 1 else 0
            local o1_1 = 1357 * o3_1 + 1800 * (1 - o3_1)
            local o2_1 = 1005 * o3_1 + 2228 * (1 - o3_1)
            if not ((o1_1 * 3898 + o2_1 * 2327 + o1_1 * o2_1) % 16777213 == 8992006) then
                oY_2 = oZ_1
            end
            o_ = oY_2
        end
        local oY_3 = o_
        local o3_2 = if oY_3 then 1 else 0
        local o1_2 = 2166 * o3_2 + 1790 * (1 - o3_2)
        local o2_2 = 3461 * o3_2 + 2450 * (1 - o3_2)
        if not ((o1_2 * 3524 + o2_2 * 1642 + o1_2 * o2_2) % 16777213 == 4035259) then
            oY_3 = nil
        end
        local oZ_2 = oY_3
        local oY_4 = type(oZ_2) == "table" and oZ_2.Completed == true
        if oY_4 then
            pcall(function()
                mr.RequestAction:InvokeServer(TeleportConfig.Actions.ResetBiome)
            end)
            pcall(function()
                mr.RequestAction:InvokeServer(TeleportConfig.Actions.TeleportToWalls)
            end)
        else
            pcall(function()
                mr.RequestAction:InvokeServer(TeleportConfig.Actions.TeleportToWalls)
            end)
        end
        return
    end
    local oY_5 = my()
    local oZ_3 = l6(oX)
    if not oY_5 or (oY_5.Position - oZ_3.Position).Magnitude > 16 then
        mf(oZ_3)
    end
    mw(true)
    pcall(function()
        mr.RequestPrimaryAttack:FireServer()
    end)
end
local function fn535(ap, aq, ar)
    return string.format("<b>%s</b> %s %s", ap, lI("-", "#5a6070"), lI(aq, ar))
end
local function fn549(am, an)
    return string.format('<font color="%s">%s</font>', an, am)
end
local function fn550()
    if not mJ() then
        mw(false)
    end
end
local function fn553(dp)
    local pg = dp and dp.Plot and dp.Plot.UnitSlots
    if type(pg) ~= "table" then
        return
    end
    for k, v in pg do
        local pg_1 = type(v) == "table" and type(v.UnitId) == "string" and v.UnitId ~= "" and l5(v.StoredCash)
        if pg_1 then
            mn(PlotConfig.Mutations.CollectUnitIncome, { slotId = v.SlotId })
        end
    end
end
local function fn583(aF)
    local nv = {}
    if type(aF) == "table" then
        for k, v in aF do
            local nw_1 = v == true and type(k) == "string"
            if nw_1 then
                nv[k] = true
            elseif type(v) == "string" then
                nv[v] = true
            end
        end
    else
        local nw_2 = aF ~= ""
        local nx = type(aF) == "string" and nw_2
        if nx then
            nv[aF] = true
        end
    end
    return nv
end
local function fn586(aT)
    local Character = LocalPlayer.Character
    if not Character then
        return
    end
    if Character.PrimaryPart then
        Character:PivotTo(aT)
    else
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = aT
        end
    end
end
local function fn595()
    local UserId = LocalPlayer.UserId
    local oH = math.huge
    local oI
    for i, v in ipairs(CollectionService:GetTagged(CombatConfig.TargetTagName)) do
        local oJ = v.Parent and v:GetAttribute(CombatConfig.Attributes.TargetId) == "BiomeWall"
        if oJ then
            local attr2 = v:GetAttribute(CombatConfig.Attributes.OwnerUserId)
            local attr = v:GetAttribute(CombatConfig.Attributes.CurrentHealth)
            local oL = attr2 == UserId and type(attr) == "number" and attr > 0
            if oL then
                local oJ_2 = tonumber(v:GetAttribute("BiomeWallSequenceIndex")) or math.huge
                if oJ_2 < oH then
                    oH = oJ_2
                    oI = v
                end
            end
        end
    end
    return oI
end
local function worker()
    while not Library.Unloaded do
        if lE("AutoAttackWalls") then
            pcall(mF)
        elseif lE("AutoAttack") then
            mw(true)
            pcall(function()
                mr.RequestPrimaryAttack:FireServer()
            end)
        elseif mv.autoAttackArmed then
            mw(false)
        end
        task.wait(0.08)
    end
end
local function fn636(dN)
    local pt = dN
    local pu = {}
    if pt then
        pt = dN.Weapons
    end
    if pt then
        pt = dN.Weapons.OwnedWeaponIds
    end
    local pv = pt
    if type(pv) == "table" then
        for k, v in pv do
            pu[v] = true
        end
    end
    local pt_1 = dN and dN.Stats and dN.Stats.Coins
    for k, v in lR do
        local pt_2 = not pu[v.id]
        if pt_2 ~= false then
            pt_2 = lC(pt_1, v.price)
        end
        if pt_2 then
            mn(WeaponShopConfig.Actions.AcquireWeapon, { weaponId = v.id, mode = WeaponShopConfig.Modes.Normal })
            return
        end
    end
end
local function fn675()
    local qt = lE("AutoAttack") or lE("AutoAttackWalls")
    return qt
end
local function fn677(d2)
    local pM = d2 and d2.Weapons
    if type(pM) ~= "table" then
        return
    end
    local pM_1 = {}
    if type(pM.OwnedWeaponIds) == "table" then
        for k, v in pM.OwnedWeaponIds do
            pM_1[v] = true
        end
    end
    local EquippedWeaponId = pM.EquippedWeaponId
    local pN_1 = #lR
    local pZ = pN_1
    local pY = -1
    while true do
        if false and pZ <= 1 or true and pZ >= 1 then
            pN_1 = lR[pZ]
            if pM_1[pN_1.id] then
                break
            end
            pZ += pY
            continue
        end
        return
    end
    if pN_1.id ~= EquippedWeaponId then
        mn(WeaponShopConfig.Actions.SetEquippedWeapon, { weaponId = pN_1.id })
    end
    return
end
local function fn679()
    local Character = LocalPlayer.Character
    local nM = Character and Character:FindFirstChild("HumanoidRootPart")
    return nM
end
local function fn689()
    local qF = if not l8() then 1 else 0
    if qF == 1 then
        l3()
    end
end
local function fn729(eU)
    local DiscordGroup = eU:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = l4 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = l4 })
end
local function fn743()
    if l8() then
        mo()
    end
end
local function fn752()
    local qz = if not mJ() then 1 else 0
    if qz == 1 then
        mw(false)
    end
end
local function fn811()
    local qJ = if not l8() then 1 else 0
    if qJ == 1 then
        l3()
    end
end
WeaponShopConfig = nil
lC = nil
lD = nil
lE = nil
lG = nil
lH = nil
lI = nil
lJ = nil
UpgradeShopConfig = nil
lM = nil
lN = nil
Options = nil
lP = nil
LocalPlayer = nil
lR = nil
PlotConfig = nil
Toggles = nil
CollectionService = nil
lX = nil
RebirthState = nil
l0 = nil
l2 = nil
l3 = nil
l4 = nil
l5 = nil
l6 = nil
PlotUpgradeState = nil
l8 = nil
Library = nil
me = nil
mf = nil
mg = nil
mj = nil
ml = nil
BigNum = nil
local Players, lF, lK, lV, lW, SaveManager, l_, Workspace, l9, CoreGui, BiomeCatalog, TeleportService, GuiService, mi, mk
mn = nil
mo = nil
mr = nil
ms = nil
mu = nil
mv = nil
mw = nil
my = nil
mz = nil
CombatConfig = nil
mB = nil
mF = nil
mG = nil
TeleportConfig = nil
mJ = nil
mL = nil
RebirthConfig = nil
mO = nil
local mp, HttpService, VirtualUser, UserInputService, mC, mD, RunService, mI, mK, mN
Players, RunService, UserInputService, VirtualUser, HttpService, GuiService, TeleportService, CoreGui, Workspace, CollectionService, LocalPlayer, lF, mO, mK, mC, BigNum, BiomeCatalog, PlotUpgradeState, RebirthState, PlotConfig, UpgradeShopConfig, WeaponShopConfig, RebirthConfig, TeleportConfig, CombatConfig, mr, mj = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
TeleportService = game:GetService("TeleportService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
CollectionService = game:GetService("CollectionService")
LocalPlayer = Players.LocalPlayer
lF = "+1 SMASH Walls For Anime Characters!"
mO = "https://discord.gg/K7Qxnxkk46"
mK = "https://discord.gg/K7Qxnxkk46"
mC = "https://tempohub.shop"
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Window
local Network = ReplicatedStorage:WaitForChild("Network")
BigNum = require(Shared.core.util.BigNum)
local WeaponCatalog = require(Shared.features.Combat.Config.WeaponCatalog)
BiomeCatalog = require(Shared.features.Biomes.Config.BiomeCatalog)
PlotUpgradeState = require(Shared.features.Plot.State.PlotUpgradeState)
RebirthState = require(Shared.features.Rebirth.Util.RebirthState)
PlotConfig = require(Shared.features.Plot.Config.PlotConfig)
UpgradeShopConfig = require(Shared.features.Plot.Config.UpgradeShopConfig)
WeaponShopConfig = require(Shared.features.Combat.Config.WeaponShopConfig)
RebirthConfig = require(Shared.features.Rebirth.Config.RebirthConfig)
TeleportConfig = require(Shared.features.Teleport.Config.TeleportConfig)
CombatConfig = require(Shared.features.Combat.Config.CombatConfig)
local RarityConfig = require(Shared.features.Plot.Config.RarityConfig)
mr = {
    RequestPrimaryAttack = Network.Combat.RequestPrimaryAttack,
    SetAutoAttackEnabled = Network.Combat.SetAutoAttackEnabled,
    DispatchMutation = Network.Data.DispatchMutation,
    RequestBootstrap = Network.Data.RequestBootstrap,
    RequestCollectUnit = Network.Biomes.RequestCollectUnit,
    RequestState = Network.Biomes.RequestState,
    RequestBiomeMenu = Network.Biomes.RequestBiomeMenu,
    EquipBiome = Network.Biomes.EquipBiome,
    RequestAction = Network.Teleport.RequestAction,
    SetFeature = Network.AutoFarm.SetFeature,
    SetAutoSellRarity = Network.AutoFarm.SetAutoSellRarity
}
mj = {}
for k, v in RarityConfig.Order do
    mj[#mj + 1] = v
end
l2, lX, lR = nil, nil, nil
local mP_1 = 7
repeat
    local ue = bit32.rrotate(bit32.bxor(bit32.lrotate(mP_1, 28), string.byte(tostring(l2))), 22)
    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(ue, 488757417), 1221386550), (bit32.bxor(bit32.band(ue, 3806209878), 1451822573))), 1221386550), 1451822573) == ue then
        l2 = { "Damage", "Attack Speed", "Offline Earnings" }
        lX = { Damage = "Damage", ["Attack Speed"] = "AttackSpeed", ["Offline Earnings"] = "OfflineEarnings" }
        lR = {}
    else
        lR = { "Offline Earnings", "Damage", "Attack Speed" }
        l2 = { Damage = "Damage", ["Offline Earnings"] = "OfflineEarnings", ["Attack Speed"] = "AttackSpeed" }
        lX = {}
    end
    mP_1 = (mP_1 + 7) % 8
until (mP_1 * 1 + 4) % 8 == 2
for k, v in WeaponCatalog.List() do
    if WeaponCatalog.SupportsShopMode(v.id, "Normal") then
        lR[#lR + 1] = { id = v.id, name = v.displayName, price = WeaponCatalog.GetShopPrice(v.id, "Normal") }
    end
end
Library, SaveManager, Toggles, Options, lD, mv, me, l9, l0, lV, lP, Window, mp, mN, ms, l4, lI, mD, lE, ml, lK, my, mf, lG, mn, lC, l5, mw, l_, mk, lJ, lW, mo, l3, mg, l6, mF, mG, mL, lN, mu, lH, mB, mz, lM = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
table.sort(lR, fn156)
local mP_2 = ""
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
lD = {}
mN = fn420
mv = {
    autoAttackArmed = false,
    autoCollectArmed = false,
    autoSellArmed = false,
    syncedSellRarities = {}
}
ms = fn188
l4 = fn401
lI = fn549
mD = fn535
me = "#7fd47f"
l9 = "#6ec1ff"
l0 = "#e8a34d"
lV = "#8b93a3"
lP = "#e05a5a"
lE = fn330
ml = fn583
lK = fn71
my = fn679
mf = fn586
lG = fn405
mn = function(a3, a4)
    return pcall(function()
        return mr.DispatchMutation:InvokeServer({ name = a3, payload = a4 })
    end)
end
lC = function(ba, bb)
    local nZ_1
    local nY_1
    nY_1, nZ_1 = pcall(function()
        return BigNum.compare(ba, bb) >= 0
    end)
    if nY_1 then
        return nZ_1
    end
    local nY_2 = tonumber(ba) or 0
    local nZ_2 = tonumber(bb) or 0
    return nY_2 >= nZ_2
end
if (lN and not SaveManager or false and not lN or (lN and SaveManager or lN and mg)) and not (lN and not SaveManager or false and not lN or (lN and SaveManager or lN and mg)) then
    mw = function(bj)
        local n1_2
        local n0_3
        n0_3, n1_2 = pcall(function()
            return BigNum.compare(bj, 0) > 0
        end)
        if n0_3 then
            return n1_2
        end
        local n0_4 = tonumber(bj) or 0
        return n0_4 > 0
    end
    l5 = function(bq)
        if mv.autoAttackArmed == bq then
            return
        end
        mv.autoAttackArmed = bq
        pcall(function()
            mr.SetAutoAttackEnabled:FireServer(bq)
        end)
    end
else
    l5 = function(bj)
        local n1_1
        local n0_1
        n0_1, n1_1 = pcall(function()
            return BigNum.compare(bj, 0) > 0
        end)
        if n0_1 then
            return n1_1
        end
        local n0_2 = tonumber(bj) or 0
        return n0_2 > 0
    end
    mw = function(bq)
        if mv.autoAttackArmed == bq then
            return
        end
        mv.autoAttackArmed = bq
        pcall(function()
            mr.SetAutoAttackEnabled:FireServer(bq)
        end)
    end
end
l_ = function(bw)
    if mv.autoCollectArmed == bw then
        return
    end
    mv.autoCollectArmed = bw
    pcall(function()
        LocalPlayer:SetAttribute("AutoFarmAutoCollectEnabled", bw)
    end)
    pcall(function()
        mr.SetFeature:InvokeServer("AutoCollect", bw)
    end)
end
mk = function(bF)
    if mv.autoSellArmed == bF then
        return
    end
    mv.autoSellArmed = bF
    pcall(function()
        mr.SetFeature:InvokeServer("AutoSell", bF)
    end)
end
lJ = fn407
lW = fn447
mo = function()
    local oo = lE("AutoCollectCharacters")
    local op = false
    for k, v in mj do
        local oy = v
        local on = lW(oy)
        if on then
            op = true
        end
        if mv.syncedSellRarities[oy] ~= on then
            mv.syncedSellRarities[oy] = on
            pcall(function()
                mr.SetAutoSellRarity:InvokeServer(oy, on)
            end)
        end
    end
    l_(oo)
    mk(op)
end
if mg and false or false and mg or (not l4 or false) and (mg and not mg) or not (mg and false or false and mg or (not l4 or false) and (mg and not mg)) then
    l3 = function()
        l_(false)
        mk(false)
        for k, v in mj do
            local oF = v
            if mv.syncedSellRarities[oF] ~= false then
                mv.syncedSellRarities[oF] = false
                pcall(function()
                    mr.SetAutoSellRarity:InvokeServer(oF, false)
                end)
            end
        end
    end
    mg = fn595
    l6 = fn196
    mF = fn518
    mG = function()
        local o5_3
        local o4_3
        mo()
        o4_3, o5_3 = pcall(function()
            return mr.RequestState:InvokeServer()
        end)
        local o6 = o4_3
        local o4_4 = 6
        if o6 then
            o6 = type(o5_3) == "table"
        end
        if o6 then
            local o6_3 = o5_3.state
            local pb = if o6_3 then 1 else 0
            local o9 = 372 * pb + 987 * (1 - pb)
            local pa = 1627 * pb + 3699 * (1 - pb)
            if not ((o9 * 1966 + pa * 1863 + o9 * pa) % 16777213 == 4367697) then
                o6_3 = o5_3
            end
            local o5_4 = o6_3
            if type(o5_4) == "table" then
                local max = math.max
                local o7 = tonumber(o5_4.PartsPerRun) or o4_4
                o4_4 = max(1, o7)
            end
        end
        for i = 1, o4_4 do
            local pf = i
            pcall(function()
                mr.RequestCollectUnit:InvokeServer(pf, true)
            end)
        end
    end
else
    mg = function()
        l_(false)
        mk(false)
        for k, v in mj do
            local oF = v
            if mv.syncedSellRarities[oF] ~= false then
                mv.syncedSellRarities[oF] = false
                pcall(function()
                    mr.SetAutoSellRarity:InvokeServer(oF, false)
                end)
            end
        end
    end
    mF = fn595
    mG = fn196
    l3 = fn518
    l6 = function()
        local o5_1
        local o4_1
        mo()
        o4_1, o5_1 = pcall(function()
            return mr.RequestState:InvokeServer()
        end)
        local o6 = o4_1
        local o4_2 = 6
        if o6 then
            o6 = type(o5_1) == "table"
        end
        if o6 then
            local o6_1 = o5_1.state
            local pb = if o6_1 then 1 else 0
            local o9 = 372 * pb + 987 * (1 - pb)
            local pa = 1627 * pb + 3699 * (1 - pb)
            if not ((o9 * 1966 + pa * 1863 + o9 * pa) % 16777213 == 4367697) then
                o6_1 = o5_1
            end
            local o5_2 = o6_1
            if type(o5_2) == "table" then
                local max = math.max
                local o7 = tonumber(o5_2.PartsPerRun) or o4_2
                o4_2 = max(1, o7)
            end
        end
        for i = 1, o4_2 do
            local pf = i
            pcall(function()
                mr.RequestCollectUnit:InvokeServer(pf, true)
            end)
        end
    end
end
mL = fn553
lN = fn452
mu = fn80
lH = fn636
mB = fn677
mz = fn79
lM = function()
    local qg_1
    local qf_1
    qf_1, qg_1 = pcall(function()
        return mr.RequestBiomeMenu:InvokeServer()
    end)
    local qh = not qf_1 or type(qg_1) ~= "table" or type(qg_1.locations) ~= "table"
    if qh then
        return
    end
    local qf_2 = -1
    local qe
    for k, v in qg_1.locations do
        local qh_1 = type(v) == "table" and v.owned == true
        if qh_1 then
            local qh_2 = BiomeCatalog.Get(v.id)
            local qi = qh_2 and tonumber(qh_2.order)
            local qh_3 = qi or 0
            if qh_3 > qf_2 then
                qf_2 = qh_3
                qe = v
            end
        end
    end
    if qe and qe.equipped ~= true and qe.id ~= qg_1.equippedLocationId then
        pcall(function()
            mr.EquipBiome:InvokeServer(qe.id)
        end)
    end
end
if (mP_2 or not lD) and (lD and false) or (not lD and false or (not lD or false)) or not ((mP_2 or not lD) and (lD and false) or (not lD and false or (not lD or false))) then
    Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = mO, Copyable = true }, "|", lF },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
else
    lF = mO:CreateWindow({
        NotifySide = "Right",
        Font = Enum.Font.BuilderSans,
        Icon = 78539693571783,
        ShowCustomCursor = false,
        TabSwipeFrom = "bottom",
        CornerRadius = 0,
        Title = "Tempo",
        Animations = { TabSwitch = true },
        Footer = { Window, { Text = Library, Copyable = true }, "|" }
    })
end
mp = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "swords"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in mp do
    if k ~= "Info" then
        fn729(v)
    end
end
mI, mJ, l8, mi = nil, nil, nil, nil
local FarmGroup = mp.Main:AddLeftGroupbox("Farm", "swords")
FarmGroup:AddToggle("AutoAttack", { Text = "Auto Attack", Default = false })
FarmGroup:AddToggle("AutoAttackWalls", { Text = "Auto Attack Walls", Default = false })
FarmGroup:AddToggle("AutoCollectCharacters", { Text = "Auto Collect Characters", Default = false })
FarmGroup:AddDropdown("CollectRarities", {
    Text = "Collect Rarities",
    Values = mj,
    Default = mj,
    Multi = true,
    SelectAllButtons = true,
    Expandable = true
})
FarmGroup:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
FarmGroup:AddDropdown("SellRarities", {
    Text = "Sell Rarities",
    Values = mj,
    Default = {},
    Multi = true,
    AllowNull = true,
    SelectAllButtons = true,
    Expandable = true
})
FarmGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false })
FarmGroup:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
local ProgressGroup = mp.Main:AddRightGroupbox("Progress", "trending-up")
ProgressGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
ProgressGroup:AddToggle("AutoBuyWeapons", { Text = "Auto Buy Weapons", Default = false })
ProgressGroup:AddToggle("AutoBestWeapon", { Text = "Auto Best Weapon", Default = false })
ProgressGroup:AddDivider("Upgrades")
ProgressGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
ProgressGroup:AddDropdown("UpgradeSelection", { Text = "Upgrades", Values = l2, Default = l2, Multi = true })
ProgressGroup:AddToggle("AutoBestBiome", { Text = "Auto Best Biome", Default = false })
mJ = fn675
Toggles.AutoAttack:OnChanged(fn550)
Toggles.AutoAttackWalls:OnChanged(fn752)
l8 = fn326
Toggles.AutoCollectCharacters:OnChanged(fn689)
Toggles.AutoSell:OnChanged(fn811)
Options.CollectRarities:OnChanged(fn26)
Options.SellRarities:OnChanged(fn743)
task.spawn(worker)
task.spawn(worker2)
mi = fn149
local function mU_1()
    local rJ
    local rG
    rG = nil
    rJ = nil
    local rE, rF, Label, Label2, Label3
    rG = "Unknown"
    pcall(function()
        local rn_1
        local rm_1
        if identifyexecutor then
            rn_1, rm_1 = identifyexecutor()
            local ro = rn_1 ~= ""
            local rp = type(rn_1) == "string" and ro
            if rp then
                local ro_1 = type(rm_1) == "string" and rm_1 ~= "" and rn_1 .. " " .. rm_1
                rG = ro_1 or rn_1
            end
        end
    end)
    local rL = mi()
    rJ = os.clock()
    rF = function()
        local rx = math.floor(os.clock() - rJ)
        if rx < 60 then
            return rx .. "s"
        elseif rx < 3600 then
            return string.format("%dm %ds", math.floor((rx) / (60)), rx % 60)
        else
            return string.format("%dh %dm", math.floor((rx) / (3600)), math.floor((rx % 3600) / (60)))
        end
    end
    local UserGroup = mp.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(mD("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, me), true)
    UserGroup:AddLabel(mD("UserId", tostring(LocalPlayer.UserId), l9), true)
    UserGroup:AddLabel(mD("Executor", rG .. "  " .. rL, me), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(mD("Session", rF(), l0), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            ms(LocalPlayer.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            ms("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = mp.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(mD("Game", lF, l9), true)
    Label2 = SessionGroup:AddLabel(mD("Players", "0/0", me), true)
    rE = tostring(game.JobId)
    local rM_1 = #rE > 18 and string.sub(rE, 1, 18) .. "..."
    local rM_2 = rM_1 or rE
    SessionGroup:AddLabel(mD("Job", rM_2, lV), true)
    Label = SessionGroup:AddLabel(mD("Ping", "0 ms", l0), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            ms(rE, "Copied Job ID")
        end
    })
    task.spawn(function()
        local rA_1
        local rz_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(mD("Session", rF(), l0))
            Label2:SetText(mD("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), me))
            rz_1, rA_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local rz_2 = rz_1 and rA_1 .. " ms" or "n/a"
            Label:SetText(mD("Ping", rz_2, l0))
        end
    end)
    local SocialsGroup = mp.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = l4 })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            if setclipboard then
                setclipboard(mK)
            elseif toclipboard then
                toclipboard(mK)
            end
            Library:Notify("Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            ms(mC, "Copied website link")
        end
    })
end
mU_1()
local function mV()
    local MovementGroup = mp.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = mp.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    mN(RunService.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = LocalPlayer.Character
            if Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    local rP_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if rP_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end))
    mN(UserInputService.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local rX_1 = lK()
            if rX_1 then
                rX_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end))
    local CurrentCamera = Workspace.CurrentCamera
    mN(RunService.RenderStepped:Connect(function(he)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local rZ_1 = lK()
            if rZ_1 then
                rZ_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local rZ_3 = my()
            local r_ = lK()
            if rZ_3 and r_ then
                r_.PlatformStand = true
                local r__1 = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    r__1 = r__1 + CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    r__1 = r__1 - CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    r__1 = r__1 - CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    r__1 = r__1 + CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    r__1 = r__1 + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    r__1 = r__1 - Vector3.new(0, 1, 0)
                end
                rZ_3.Velocity = Vector3.zero
                if r__1.Magnitude > 0 then
                    rZ_3.CFrame = rZ_3.CFrame + r__1.Unit * Options.FlySpeed.Value * he
                end
            end
        end
    end))
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local r5 = lK()
            if r5 then
                r5.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local r7 = lK()
            if r7 then
                r7.WalkSpeed = 16
            end
        end
    end)
    local function hA(hB)
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not hB)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not hB
            end
        end)
        if not hB then
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
        hA(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                hA(true)
            end
        end
    end)
    local function hS(hT)
        if not hT:IsA("ProximityPrompt") then
            return
        end
        hT.HoldDuration = 0
        hT.MaxActivationDistance = 50
        hT.RequiresLineOfSight = false
    end
    local connection
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in ipairs(Workspace:GetDescendants()) do
                pcall(hS, descendant)
            end
            connection = Workspace.DescendantAdded:Connect(function(h0)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(hS, h0)
                end
            end)
            mN(connection)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    Library:OnUnload(function()
        hA(false)
        if connection then
            connection:Disconnect()
        end
    end)
end
mV()
local function mQ_2()
    local MenuGroup = mp.Settings:AddLeftGroupbox("Menu")
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    local ib = 0
    local ic = tick()
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local Label = MenuGroup:AddLabel("AFK triggers: 0")
    local function ig()
        local CurrentCamera = Workspace.CurrentCamera
        if not CurrentCamera then
            return
        end
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        ib = ib + 1
        ic = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. ib)
        end)
    end
    local connection = LocalPlayer.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(ig)
        end
    end)
    mN(connection)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local sx = Toggles.AntiAfk.Value and tick() - ic >= 60
            if sx then
                pcall(ig)
            end
        end
    end)
    MenuGroup:AddButton({
        Text = "Unload UI",
        Func = function()
            Library:Unload()
        end
    })
end
mQ_2()
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("MyScriptHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(mp.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/Plus1SmashWallsForAnimeCharacters")
mI = SaveManager:BuildConfigSection(mp.Settings)
SaveManager:LoadAutoloadConfig()
local function mW()
    local function iG(iH, iI)
        local sA = iH == "Toggle" and Toggles
        local sF = if sA then 1 else 0
        local sD = 2896 * sF + 2015 * (1 - sF)
        local sE = 770 * sF + 475 * (1 - sF)
        if not ((sD * 2204 + sE * 611 + sD * sE) % 16777213 == 9083174) then
            sA = Options
        end
        local sA_1 = sA[iI]
        local sz_2 = type(sA_1) == "table" and sA_1.Type == iH
        return sz_2 and sA_1 or nil
    end
    local function iQ(iR, iS)
        local Type = iS.Type
        if Type == "Toggle" then
            return { idx = iR, type = "Toggle", value = iS.Value == true }
        elseif Type == "Slider" then
            return { idx = iR, type = "Slider", value = tostring(iS.Value) }
        elseif Type == "Dropdown" then
            return { idx = iR, type = "Dropdown", multi = iS.Multi == true, value = iS.Value }
        elseif Type == "Input" then
            local sH = iS.Value
            local sL = if sH then 1 else 0
            local sJ = 250 * sL + 890 * (1 - sL)
            local sK = 3493 * sL + 841 * (1 - sL)
            if not ((sJ * 1125 + sK * 3718 + sJ * sK) % 16777213 == 14141474) then
                sH = ""
            end
            return { idx = iR, type = "Input", text = tostring(sH) }
        elseif Type == "ColorPicker" then
            return { idx = iR, type = "ColorPicker", value = iS.Value:ToHex(), transparency = iS.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = iR,
                type = "KeyPicker",
                mode = iS.Mode,
                key = iS.Value,
                modifiers = iS.Modifiers,
                toggled = iS.Toggled
            }
        else
            return nil
        end
    end
    local function iU()
        local sN = {}
        for i, v in ipairs({ Toggles, Options }) do
            for k, v in pairs(v) do
                local sO = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if sO then
                    local sO_1 = iQ(k, v)
                    if sO_1 then
                        sN[#sN + 1] = sO_1
                    end
                end
            end
        end
        table.sort(sN, function(i3, i4)
            if i3.type ~= i4.type then
                return i3.type < i4.type
            end
            return i3.idx < i4.idx
        end)
        return { objects = sN }
    end
    local function i5(i6)
        local s6
        s6 = nil
        local s7 = type(i6) ~= "table" or type(i6.idx) ~= "string" or type(i6.type) ~= "string" or SaveManager.Ignore[i6.idx]
        if s7 then
            return false
        end
        s6 = iG(i6.type, i6.idx)
        if not s6 then
            return false
        end
        local s7_1 = pcall(function()
            if i6.type == "Input" then
                if type(i6.text) ~= "string" then
                    return
                end
                s6:SetValue(i6.text)
            elseif i6.type == "ColorPicker" then
                s6:SetValueRGB(Color3.fromHex(i6.value), i6.transparency)
            elseif i6.type == "KeyPicker" then
                s6:SetValue({ i6.key, i6.mode, i6.modifiers })
                if i6.mode == "Toggle" and i6.toggled ~= nil then
                    s6.Toggled = i6.toggled
                    s6:Update()
                end
            else
                s6:SetValue(i6.value)
            end
        end)
        return s7_1
    end
    mI:AddDivider()
    mI:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    mI:AddButton("Export Config to Clipboard", function()
        local td_1
        local tc_1
        tc_1, td_1 = pcall(HttpService.JSONEncode, HttpService, iU())
        if not tc_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local tc_2 = setclipboard or toclipboard
        local tc_3 = type(tc_2) ~= "function" or not pcall(tc_2, td_1)
        if tc_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    mI:AddButton("Import Config from Clipboard Text", function()
        local ti_1
        local tg = Options.SaveManager_ImportSource.Value or ""
        local tg_1
        local th = tostring(tg):match("^%s*(.-)%s*$")
        if th == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        tg_1, ti_1 = pcall(HttpService.JSONDecode, HttpService, th)
        local th_1 = not tg_1 or type(ti_1) ~= "table" or type(ti_1.objects) ~= "table"
        if th_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local tg_2 = 0
        for i, v in ipairs(ti_1.objects) do
            if i5(v) then
                tg_2 += 1
            end
        end
        if tg_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local ti_2 = tg_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(tg_2, ti_2), 6)
    end)
end
mW()
Library:OnUnload(function()
    mw(false)
    l3()
    for k, v in lD do
        local tz = v
        pcall(function()
            tz:Disconnect()
        end)
    end
    table.clear(lD)
end)
end)(...)

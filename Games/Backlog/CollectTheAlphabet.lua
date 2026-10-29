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
getgenv().TempoHoodSubtitle = "COLLECT THE ALPHABET"
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
local l2
local k2
local Toggles
local lH
local lN
local l8
local lQ
local lu
local lb
local le
local lW
local lh
local lZ
local kZ
local SPECIAL_PRICES
local l1
local k1
local lk
local PackData
local k4
local lq
local Library
local lJ
local SellConfig
local lt
local LocalPlayer
local lz
local lV
local Options
local kY
local lF
local l0
local lm
local lj
local lI
local k3
local l6
local l3
local k6
local lO
local k9
local lc
local lU
local lf
local lX
local kX
local lE
local l_
local k_
local Workspace
local function fn6()
    lz(k3, "Copied Discord invite to clipboard")
end
local function fn50(fJ)
    if fJ == "buy" then
        if not Toggles.AutoBuyPacks.Value then
            return nil
        end
        local qx_1 = k_()
        if qx_1 == "prompt" then
            return 0.7
        end
        return nil
    elseif fJ == "place" then
        local qx_2 = Toggles.AutoPlacePacks.Value and LocalPlayer:GetAttribute("HoldingPack") and lH()
        if qx_2 then
            local qx_3 = k2()
            if qx_3 then
                k4(qx_3.CFrame)
            end
            return 0.55
        end
        return nil
    elseif fJ == "open" then
        local qx_4 = Toggles.AutoOpenPacks.Value and lJ()
        if qx_4 then
            return 0.8
        end
        return nil
    elseif fJ == "collect" then
        local qx_5 = Toggles.AutoCollectMoney.Value and lf()
        if qx_5 then
            return 0.7
        end
        return nil
    elseif fJ == "dropLetters" then
        local qx_6 = Toggles.AutoDropOff.Value and lI("Letters")
        if qx_6 then
            return 1
        end
        return nil
    elseif fJ == "dropSymbols" then
        local qx_7 = Toggles.AutoDropOff.Value and lI("Symbols")
        if qx_7 then
            return 1
        end
        return nil
    elseif fJ == "dropWords" then
        local qx_8 = Toggles.AutoDropOff.Value and lI("Words")
        if qx_8 then
            return 1
        end
        return nil
    else
        return nil
    end
end
local function fn120(as)
    local DiscordGroup = as:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = lc })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = lc })
end
local function fn148(dV)
    local WordBoard = dV:FindFirstChild("WordBoard")
    local pP = WordBoard and WordBoard:FindFirstChild("Pad")
    return pP
end
local function fn151(bs)
    local nE = k2()
    local nF = nE and bs and bs:IsA("BasePart")
    if not nF then
        return false
    end
    nE.CFrame = bs.CFrame * CFrame.new(0, 3, 0)
    nE.AssemblyLinearVelocity = Vector3.zero
    l1.stayPart = bs
    l1.stayCFrame = nil
    if firetouchinterest then
        pcall(firetouchinterest, nE, bs, 0)
        pcall(firetouchinterest, bs, nE, 0)
        kZ.held = true
        kZ.part = bs
    end
    return true
end
local function fn154(a9)
    local nw = SellConfig.SYMBOL_KEYS[a9]
    if nw then
        local nx = tonumber(LocalPlayer:GetAttribute("Symbol_" .. nw)) or 0
        return nx
    end
    local nw_1 = tonumber(LocalPlayer:GetAttribute("Letter_" .. a9)) or 0
    return nw_1
end
local function fn179()
    local qE
    local qC = #le
    local qI = 1
    while true do
        if qI <= qC then
            local qD = l1.index % qC + 1
            l1.index = qD
            lm()
            qE = l6(le[qD].id)
            if qE then
                break
            end
            qI += 1
            continue
        end
        lm()
        return
    end
    k9(qE)
    return
end
local function fn221()
    local og = lF("PackList")
    for k, v in lb do
        if og[v] then
            local oh = kX[v]
            local oi = oh and lE(oh)
            if oi then
                local oi_1 = lZ(oh)
                if oi_1 then
                    lN(oi_1)
                    return "prompt"
                end
            end
        end
    end
    return nil
end
local function fn233(d_)
    local pR = lF("DropOffList")
    if not pR[d_] then
        return false
    end
    local pR_1 = k6()
    local pS = lQ[d_]
    local pT = pR_1 and pS and pS(pR_1)
    if not pT then
        return false
    end
    return l_(pT)
end
local function fn303(bG)
    if not (bG and fireproximityprompt) then
        return false
    end
    local nT_1 = k2()
    local Parent = bG.Parent
    local nV
    if Parent then
        if Parent:IsA("BasePart") then
            nV = Parent.Position
        else
            nV = Parent:GetPivot().Position
        end
    end
    if nT_1 and nV then
        local nU_2 = CFrame.new(nV + Vector3.new(0, 3, 0))
        nT_1.CFrame = nU_2
        nT_1.AssemblyLinearVelocity = Vector3.zero
        k4(nU_2)
    end
    return pcall(fireproximityprompt, bG)
end
local function fn322(fG)
    l1.busyUntil = os.clock() + fG
end
local function fn358()
    local attr = LocalPlayer:GetAttribute("AssignedBase")
    local Bases = Workspace:FindFirstChild("Bases")
    local nb = attr and Bases and Bases:FindFirstChild(attr)
    return nb
end
local function fn387()
    local pz = tonumber(LocalPlayer:GetAttribute("IncomeAccrued")) or 0
    if pz < 1 then
        return false
    end
    local pz_1 = k6()
    local pA_1 = pz_1 and pz_1:FindFirstChild("CollectPad")
    local pz_2 = pA_1
    if pA_1 then
        pA_1 = pz_2:FindFirstChild("CollectPad")
    end
    local pz_3 = pA_1
    if pz_3 then
        l_(pz_3)
        return true
    end
    return false
end
local function fn395()
    local nN = k2()
    if l1.stayPart and l1.stayPart.Parent then
        l_(l1.stayPart)
    else
        if nN and l1.stayCFrame then
            nN.CFrame = l1.stayCFrame
            nN.AssemblyLinearVelocity = Vector3.zero
        end
    end
end
local function fn436()
    local nz = k2()
    local part = kZ.part
    if kZ.held and firetouchinterest and nz and part then
        pcall(firetouchinterest, nz, part, 1)
        pcall(firetouchinterest, part, nz, 1)
    end
    kZ.held = false
    kZ.part = nil
end
local function fn467(cJ, cK)
    for k, v in cK do
        local oM = cJ - v
        if oM.X * oM.X + oM.Z * oM.Z < 36 then
            return false
        end
    end
    return true
end
local function fn474(aU)
    local nj = Options[aU]
    local nk = nj and nj.Value
    local nj_1 = {}
    if type(nk) ~= "table" then
        return nj_1
    end
    for k, v in nk do
        if v then
            nj_1[k] = true
        end
    end
    return nj_1
end
local function fn507()
    local Money = LocalPlayer:FindFirstChild("Money")
    local m1 = Money and tonumber(Money.Value)
    return m1 or 0
end
local function fn532()
    local oU, oV, oW, oX, oY, oZ, o_, o4, o5, o6, o9, pa, pe, pf
    local o0 = 21
    while true do
        local o0_1 = 12504 - o0
        do
            if o0_1 < 12486 then
                if o0_1 < 12475 then
                    if o0_1 < 12471 then
                        if o0_1 < 12467 then
                            if o0_1 < 12466 then
                                if o0_1 < 6581 then
                                    break
                                elseif o0_1 < 12463 then
                                    break
                                elseif o0_1 < 12464 then
                                    if o0_1 == 12463 then
                                        o5 = 2329 * o6 + 1354 * (1 - o6)
                                        o0 = 17
                                    else
                                        o0 = 12502
                                        continue
                                    end
                                elseif o0_1 < 12465 then
                                    if o0_1 == 12464 then
                                        oV = oU:GetPivot()
                                        oW = l3()
                                        oX = RaycastParams.new()
                                        oX.FilterType = Enum.RaycastFilterType.Exclude
                                        oY = { LocalPlayer.Character }
                                        oZ = Workspace:FindFirstChild("ConveyorPacks")
                                        o6 = if oZ then 1 else 0
                                        o4 = 482 * o6 + 1659 * (1 - o6)
                                        o0 = 41
                                    else
                                        o0 = 1646
                                        continue
                                    end
                                elseif o0_1 == 12465 then
                                    oU = -24
                                    pe = oU
                                    o0 = 30
                                else
                                    o0 = 12466
                                    continue
                                end
                            elseif o0_1 == 12466 then
                                oU = o_
                                o0 = if oU then 26 else 14
                            else
                                o0 = 12477
                                continue
                            end
                        elseif o0_1 < 12470 then
                            if o0_1 < 12468 then
                                if o0_1 == 12467 then
                                    o0 = if o9 <= 24 then 33 else 25
                                else
                                    o0 = 6700
                                    continue
                                end
                            elseif o0_1 < 12469 then
                                oZ = Workspace:FindFirstChild("PlacedPacks")
                                o0 = if oZ then 15 else 16
                            else
                                o0 = if oU then 34 else 9
                            end
                        else
                            oU = oZ.Normal.Y > 0.7
                            o0 = 9
                        end
                    elseif o0_1 < 12474 then
                        if o0_1 < 12473 then
                            if o0_1 < 12472 then
                                pa = o9
                                o0 = 39
                            else
                                o0 = if oU then 11 else 6
                            end
                        else
                            local oU_1 = oV * Vector3.new(pa, 20, pf)
                            oZ = Workspace:Raycast(oU_1, Vector3.new(0, -40, 0), oX)
                            oU = oZ
                            o0 = if oU then 19 else 35
                        end
                    else
                        o0 = if pe <= 24 then 3 else 22
                    end
                elseif o0_1 < 12479 then
                    if o0_1 < 12477 then
                        if o0_1 < 12476 then
                            oU = oZ.Position.Y < 4
                            o0 = 32
                        else
                            oU = oY
                            o_ = true
                            o0 = if oU then 7 else 10
                        end
                    elseif o0_1 < 12478 then
                        if o0_1 == 12477 then
                            o0 = 0
                        else
                            o0 = 6581
                            continue
                        end
                    else
                        oU = lh(oZ.Position, oW)
                        o0 = 14
                    end
                elseif o0_1 < 12485 then
                    if o0_1 < 12482 then
                        if o0_1 < 12480 then
                            if o0_1 == 12479 then
                                return nil
                            end
                            o0 = 12474
                            continue
                        elseif o0_1 < 12481 then
                            return nil
                        elseif o0_1 == 12481 then
                            o0 = if not oW then 24 else 40
                        else
                            o0 = 12468
                            continue
                        end
                    elseif o0_1 < 12483 then
                        o0 = 1
                    elseif o0_1 < 12484 then
                        if o0_1 == 12483 then
                            oU = k6()
                            oV = k2()
                            oW = oU
                            local o3 = if oW then 1 else 0
                            local o1 = 427 * o3 + 878 * (1 - o3)
                            local o2 = 2305 * o3 + 3158 * (1 - o3)
                            o0 = if (o1 * 179 + o2 * 98 + o1 * o2) % 16777213 == 1286558 then 5 else 23
                        else
                            o0 = 12498
                            continue
                        end
                    else
                        return oZ.Position
                    end
                elseif o0_1 == 12485 then
                    oU = oZ.Instance.Anchored
                    o0 = 35
                else
                    o0 = 12476
                    continue
                end
            elseif o0_1 < 12497 then
                if o0_1 < 12494 then
                    if o0_1 < 12491 then
                        if o0_1 < 12489 then
                            if o0_1 < 12487 then
                                if o0_1 == 12486 then
                                    o0 = if o_ then 28 else 0
                                else
                                    o0 = 12496
                                    continue
                                end
                            elseif o0_1 < 12488 then
                                if o0_1 == 12487 then
                                    o0 = if (o4 * 379 + o5 * 3032 + o4 * o5) % 16777213 == 8366784 then 13 else 36
                                else
                                    o0 = 4309
                                    continue
                                end
                            elseif o0_1 == 12488 then
                                oX.FilterDescendantsInstances = oY
                                oY = oU:FindFirstChild("Conveyer")
                                oU = -24
                                o9 = oU
                                o0 = 37
                            else
                                o0 = 12491
                                continue
                            end
                        elseif o0_1 < 12490 then
                            oY[#oY + 1] = oZ
                            o0 = 16
                        elseif o0_1 == 12490 then
                            o0 = if oU then 20 else 27
                        else
                            o0 = 1646
                            continue
                        end
                    elseif o0_1 < 12492 then
                        if o0_1 == 12491 then
                            oY[#oY + 1] = oZ
                            o0 = 36
                        else
                            o0 = 5183
                            continue
                        end
                    elseif o0_1 < 12493 then
                        break
                    else
                        oU = oV:PointToObjectSpace(oZ.Position)
                        o_ = math.abs(oU.X) <= 34
                        o0 = if o_ then 8 else 18
                    end
                elseif o0_1 < 12496 then
                    if o0_1 < 12495 then
                        o0 = if oU then 2 else 38
                    else
                        o0 = if oU then 29 else 32
                    end
                elseif o0_1 == 12496 then
                    o_ = math.abs(oU.Z) <= 52
                    o0 = 18
                else
                    o0 = 12474
                    continue
                end
            elseif o0_1 < 12502 then
                if o0_1 < 12499 then
                    if o0_1 < 12498 then
                        oU = oY:IsA("BasePart")
                        o0 = 10
                    elseif o0_1 == 12498 then
                        o0 = 4
                    else
                        o0 = 10577
                        continue
                    end
                elseif o0_1 < 12501 then
                    if o0_1 < 12500 then
                        if o0_1 == 12499 then
                            oW = oV
                            o0 = 23
                        else
                            o0 = 12502
                            continue
                        end
                    elseif o0_1 == 12500 then
                        pe += 8
                        o0 = 30
                    else
                        o0 = 12473
                        continue
                    end
                elseif o0_1 == 12501 then
                    pf = pe
                    o0 = 31
                else
                    o0 = 12467
                    continue
                end
            elseif o0_1 < 12504 then
                if o0_1 < 12503 then
                    oU = oZ.Position - oY.Position
                    o_ = oU.X * oU.X + oU.Z * oU.Z > 64
                    o0 = 38
                else
                    o9 += 8
                    o0 = 37
                end
            elseif o0_1 == 12504 then
                o0 = 6
            else
                o0 = 12467
                continue
            end
        end
    end
end
local function fn549(bU)
    local n__1
    local nZ_1
    n__1, nZ_1 = k1(bU)
    if type(n__1) ~= "number" then
        return false
    elseif nZ_1 == "Diamonds" then
        local nZ_2 = lu() - n__1
        local n1_1 = Options.KeepDiamonds and Options.KeepDiamonds.Value
        local n5 = if n1_1 then 1 else 0
        local n3 = 4069 * n5 + 2424 * (1 - n5)
        local n4 = 376 * n5 + 1824 * (1 - n5)
        if not ((n3 * 3383 + n4 * 161 + n3 * n4) % 16777213 == 15355907) then
            n1_1 = 0
        end
        return nZ_2 >= n1_1
    else
        local nZ_3 = lO() - n__1
        return nZ_3 >= (Options.KeepMoney and Options.KeepMoney.Value or 0)
    end
end
local function fn580(bP)
    local nX = SPECIAL_PRICES[bP]
    if nX then
        return nX, "Diamonds"
    end
    return PackData.PRICES[bP], "Money"
end
local function fn586(dS)
    local SymbolDropOff = dS:FindFirstChild("SymbolDropOff")
    local pM = SymbolDropOff and SymbolDropOff:FindFirstChild("DropOff")
    return pM
end
local function fn600()
    local Character = LocalPlayer.Character
    local mQ = Character and Character:FindFirstChildOfClass("Humanoid")
    return mQ
end
local function fn610(ah, ai, aj)
    return string.format("<b>%s</b> %s %s", ah, kY("-", "#5a6070"), kY(ai, aj))
end
local function fn655(X, Y)
    if setclipboard then
        setclipboard(X)
    elseif toclipboard then
        toclipboard(X)
    end
    Library:Notify(Y)
end
local function fn665(bp)
    l1.stayPart = nil
    l1.stayCFrame = bp
end
local function fn668()
    lW()
    l1.stayPart = nil
    l1.stayCFrame = nil
end
local function fn669(b3)
    local ConveyorPacks = Workspace:FindFirstChild("ConveyorPacks")
    local attr = LocalPlayer:GetAttribute("AssignedBase")
    if not (ConveyorPacks and attr) then
        return nil
    end
    for i, child in ConveyorPacks:GetChildren() do
        local n6_1 = child.Name == b3 and child:GetAttribute("BaseName") == attr
        if n6_1 then
            local BuyPrompt = child:FindFirstChild("BuyPrompt", true)
            local n8_1 = BuyPrompt and BuyPrompt:IsA("ProximityPrompt") and BuyPrompt.Enabled
            if n8_1 then
                return BuyPrompt
            end
        end
    end
    return nil
end
local function fn671()
    local Diamonds = LocalPlayer:FindFirstChild("Diamonds")
    local m4 = Diamonds and tonumber(Diamonds.Value)
    return m4 or 0
end
local function autoSellLoop()
    while not Library.Unloaded do
        if os.clock() < l1.busyUntil then
            lk()
        else
            pcall(lt)
        end
        if Toggles.AutoSell.Value then
            pcall(lj)
        end
        if Toggles.AutoBuyUpgrades.Value then
            pcall(lU)
        end
        if Toggles.AutoBuyShop.Value then
            pcall(l8)
        end
        task.wait(0.15)
    end
end
local function fn703(dP)
    local DropOff = dP:FindFirstChild("DropOff")
    local pG = DropOff and DropOff:FindFirstChild("DropOff")
    return pG
end
local function fn734(ae, af)
    return string.format('<font color="%s">%s</font>', af, ae)
end
local function fn795()
    lm()
    lX(false)
    if l2 then
        l2:Disconnect()
    end
    if lV then
        lV:Disconnect()
    end
    local sr = lq()
    if sr then
        sr.PlatformStand = false
        sr.WalkSpeed = 16
    end
end
local function fn802(a2, a3)
    local nt = l0[a3]
    local nu = nt ~= nil and lF(a2)[nt] == true
    return nu
end
local function fn814()
    local oC = {}
    local UserId = LocalPlayer.UserId
    local PlacedPacks = Workspace:FindFirstChild("PlacedPacks")
    if not PlacedPacks then
        return oC
    end
    for i, child in PlacedPacks:GetChildren() do
        if child:GetAttribute("OwnerUserId") == UserId then
            oC[#oC + 1] = child:GetPivot().Position
        end
    end
    return oC
end
local function fn862()
    local Character = LocalPlayer.Character
    local mW = Character and Character:FindFirstChild("HumanoidRootPart")
    return mW
end
kX = nil
kY = nil
kZ = nil
k_ = nil
k1 = nil
k2 = nil
k3 = nil
k4 = nil
k6 = nil
k9 = nil
lb = nil
lc = nil
LocalPlayer = nil
le = nil
lf = nil
lh = nil
lj = nil
lk = nil
Workspace = nil
lm = nil
lq = nil
lt = nil
lu = nil
lz = nil
Options = nil
lE = nil
lF = nil
SPECIAL_PRICES = nil
lH = nil
lI = nil
lJ = nil
local k0, k5, k7, k8, la, lg, SellLetters, ln, BuySpecialPack, lp, CoreGui, ls, BuyUpgrade, GuiService, lx, ClaimLetter, HttpService, PlacePack, VirtualUser
Toggles = nil
lN = nil
lO = nil
SellConfig = nil
lQ = nil
lU = nil
lV = nil
lW = nil
lX = nil
lZ = nil
l_ = nil
l0 = nil
l1 = nil
l2 = nil
l3 = nil
PackData = nil
l6 = nil
Library = nil
l8 = nil
local UserInputService, lM, SaveManager, lS, RunService, UpgradeData, l5, l9
local mc_1
RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, LocalPlayer, k8, k3, k0, PackData, UpgradeData, SellConfig, mc_1, PlacePack, ClaimLetter, BuyUpgrade, BuySpecialPack, SellLetters, lb, k7, kX, l0 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
if (ReplicatedStorage and not mc_1 or mc_1 and not Workspace) and (VirtualUser or not PackData or (VirtualUser or not PackData)) and not ((ReplicatedStorage and not mc_1 or mc_1 and not Workspace) and (VirtualUser or not PackData or (VirtualUser or not PackData))) then
    k3 = "Collect The Alphabet"
    k8 = "https://discord.gg/K7Qxnxkk46"
else
    k8 = "Collect The Alphabet"
    k3 = "https://discord.gg/K7Qxnxkk46"
end
k0 = "https://discord.gg/K7Qxnxkk46"
PackData = require(ReplicatedStorage:WaitForChild("PackData"))
UpgradeData = require(ReplicatedStorage:WaitForChild("UpgradeData"))
SellConfig = require(ReplicatedStorage:WaitForChild("SellConfig"))
local PackRemotes = ReplicatedStorage:WaitForChild("PackRemotes")
PlacePack = PackRemotes:WaitForChild("PlacePack")
ClaimLetter = PackRemotes:WaitForChild("ClaimLetter")
BuyUpgrade = ReplicatedStorage:WaitForChild("UpgradeRemotes"):WaitForChild("BuyUpgrade")
BuySpecialPack = ReplicatedStorage:WaitForChild("SpecialShopRemotes"):WaitForChild("BuySpecialPack")
SellLetters = ReplicatedStorage:WaitForChild("SellRemotes"):WaitForChild("SellLetters")
lb = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic" }
k7 = { "Common Special", "Rare Special", "Legendary Special" }
local me = {
    "Common",
    "Uncommon",
    "Rare",
    "Epic",
    "Legendary",
    "Mythic",
    "Common Special",
    "Rare Special",
    "Legendary Special"
}
kX = {
    Common = "CommonPack",
    Uncommon = "UncommonPack",
    Rare = "RarePack",
    Epic = "EpicPack",
    Legendary = "LegendaryPack",
    Mythic = "MythicPack",
    ["Common Special"] = "CommonSpecialPack",
    ["Rare Special"] = "RareSpecialPack",
    ["Legendary Special"] = "LegendarySpecialPack"
}
l0 = {}
for k, v in kX do
    l0[v] = k
end
SPECIAL_PRICES, lx, ls = nil, nil, nil
SPECIAL_PRICES = PackData.SPECIAL_PRICES
local mb = { "Letters", "Symbols", "Words" }
lx = { "Rarity", "Time", "Money" }
ls = {}
local mB = 65
while mB <= 90 do
    local mC = mB
    ls[#ls + 1] = string.char(mC)
    mB += 1
end
local mc_3 = nil
local ma_1 = 3
repeat
    local tI = bit32.rrotate(bit32.bxor(bit32.lrotate(ma_1, 7), string.byte(tostring(mc_3))), 20)
    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(tI, 2435531357), 2921752244), (bit32.bxor(bit32.band(tI, 1859435938), 22580148))), 2921752244), 22580148) == tI then
        mc_3 = { "+", "-", "%", "!", "?", "$", "&", "#", "@" }
    else
        mc_3 = { "$", "-", "&", "!", "#", "?", "+", "@", "%" }
    end
    ma_1 = (ma_1 + 2) % 4
until (ma_1 * 3 + 2) % 4 == 1
for k, v in mc_3 do
    ls[#ls + 1] = v
end
Library, SaveManager, Toggles, Options, ln, lg, la, k5, l9, lz, lc, kY, lM = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
lz = fn655
lc = fn6
kY = fn734
lM = fn610
ln = "#7fd47f"
lg = "#6ec1ff"
la = "#e8a34d"
k5 = "#8b93a3"
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = k3, Copyable = true }, "|", k8 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
l9 = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gamepad-2"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in l9 do
    fn120(v)
end
kZ, l1, lQ, le, lX, l2, lV, lq, k2, lO, lu, k6, lF, l5, lp, lW, lm, k4, l_, lk, lN, k1, lE, lZ, k_, l8, l3, lh, lS, lH, lJ, lf, lI, lU, lj, k9, l6, lt = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
lq = fn600
k2 = fn862
lO = fn507
lu = fn671
k6 = fn358
lF = fn474
l5 = fn802
lp = fn154
kZ = { part = nil, held = false }
l1 = { index = 0, busyUntil = 0, stayPart = nil, stayCFrame = nil }
lW = fn436
lm = fn668
k4 = fn665
l_ = fn151
lk = fn395
lN = fn303
k1 = fn580
lE = fn549
lZ = fn669
k_ = fn221
l8 = function()
    local ot = lF("ShopList")
    for k, v in k7 do
        if ot[v] then
            local oq = kX[v]
            local ou = oq and lE(oq)
            if ou then
                pcall(function()
                    BuySpecialPack:FireServer(oq)
                end)
                return true
            end
        end
    end
    return false
end
l3 = fn814
lh = fn467
lS = fn532
lH = function()
    local ph
    local attr = LocalPlayer:GetAttribute("HoldingPack")
    local pj = not attr or not l5("PlaceList", attr)
    if pj then
        return false
    end
    ph = lS()
    if not ph then
        return false
    end
    local pi_1 = k2()
    if pi_1 then
        pi_1.CFrame = CFrame.new(ph + Vector3.new(0, 4, 0))
        pi_1.AssemblyLinearVelocity = Vector3.zero
    end
    pcall(function()
        PlacePack:FireServer(ph)
    end)
    return true
end
lJ = function()
    local PlacedPacks = Workspace:FindFirstChild("PlacedPacks")
    if not PlacedPacks then
        return false
    end
    local pp = Workspace:GetServerTimeNow()
    local UserId = LocalPlayer.UserId
    for i, child in PlacedPacks:GetChildren() do
        local py = child
        if py:GetAttribute("OwnerUserId") == UserId then
            local po_1 = string.match(py.Name, "^Placed_(.+)$") or py.Name
            if not not l5("OpenList", po_1) then
                local po_2 = tonumber(py:GetAttribute("ReadyAtClock")) or 0
                if pp >= po_2 then
                    local OpenPrompt = py:FindFirstChild("OpenPrompt", true)
                    local pr_2 = OpenPrompt and OpenPrompt:IsA("ProximityPrompt")
                    if pr_2 then
                        lN(OpenPrompt)
                        pcall(function()
                            ClaimLetter:FireServer(py)
                        end)
                        return true
                    end
                end
            end
        end
    end
    return false
end
lf = fn387
lQ = { Letters = fn703, Symbols = fn586, Words = fn148 }
lI = fn233
lU = function()
    local pY_1
    local pV = lF("UpgradeList")
    for k, v in lx do
        local p5 = v
        if pV[p5] then
            local pW = tonumber(LocalPlayer:GetAttribute("Upg" .. p5)) or 0
            if pW < UpgradeData.maxLevel(p5) then
                local pW_1 = UpgradeData.costFor(p5, pW)
                local pX_1 = UpgradeData.currencyOf(p5)
                if pX_1 == "Diamonds" then
                    local pX_2 = lu()
                    local pZ_1 = tonumber(pW_1) or math.huge
                    pY_1 = pX_2 >= pZ_1
                else
                    local pX_3 = lO()
                    local pZ_2 = tonumber(pW_1) or math.huge
                    pY_1 = pX_3 >= pZ_2
                end
                if pY_1 then
                    pcall(function()
                        BuyUpgrade:FireServer(p5)
                    end)
                    return
                end
            end
        end
    end
end
lj = function()
    local p6 = lF("SellList")
    local p8 = Options.SellKeepAmount and Options.SellKeepAmount.Value or 0
    for k, v in ls do
        local qf = v
        local p8_1 = p6[qf] and lp(qf) > p8
        if p8_1 then
            pcall(function()
                SellLetters:FireServer(qf, 1)
            end)
            return
        end
    end
end
local function md_1()
    local qp
    qp = nil
    local qo, Label, qr, qs
    qp = "Unknown"
    pcall(function()
        local qh_1
        local qg_1
        if identifyexecutor then
            qh_1, qg_1 = identifyexecutor()
            local qi = qh_1 ~= ""
            local qj = type(qh_1) == "string" and qi
            if qj then
                local qi_1 = type(qg_1) == "string" and qg_1 ~= "" and qh_1 .. " " .. qg_1
                qp = qi_1 or qh_1
            end
        end
    end)
    local AccountGroup = l9.Info:AddLeftGroupbox("Account", "circle-user")
    AccountGroup:AddLabel(lM("User", LocalPlayer.Name, ln), true)
    AccountGroup:AddLabel(lM("Status", "Keyless", ln), true)
    AccountGroup:AddLabel(lM("Executor", qp, ln), true)
    local GameInfoGroup = l9.Info:AddLeftGroupbox("Game Info", "gamepad-2")
    GameInfoGroup:AddLabel(kY(k8 .. " [" .. tostring(game.PlaceId) .. "]", lg), true)
    GameInfoGroup:AddLabel(lM("Place ID", tostring(game.PlaceId), lg), true)
    Label = GameInfoGroup:AddLabel(lM("Session time", "0s", la), true)
    qs = tostring(game.JobId)
    local qu = #qs > 18 and string.sub(qs, 1, 18) .. "..."
    local qu_1 = qu or qs
    GameInfoGroup:AddLabel(lM("Server", qu_1, k5), true)
    GameInfoGroup:AddButton({
        Text = "Copy join script (Job ID)",
        Func = function()
            local e0 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, qs)
            lz(e0, "Copied join script to clipboard")
        end
    })
    qr = os.clock()
    task.spawn(function()
        local qm_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            local ql = math.floor(os.clock() - qr)
            if ql < 60 then
                qm_1 = ql .. "s"
            elseif ql < 3600 then
                qm_1 = string.format("%dm %ds", math.floor((ql) / (60)), ql % 60)
            else
                qm_1 = string.format("%dh %dm", math.floor((ql) / (3600)), math.floor((ql % 3600) / (60)))
            end
            Label:SetText(lM("Session time", qm_1, la))
        end
    end)
    local ScriptsGroup = l9.Info:AddRightGroupbox("Scripts", "package")
    ScriptsGroup:AddLabel(kY("Included in this hub", k5), true)
    ScriptsGroup:AddLabel(kY(k8, lg), true)
    local FeaturesGroup = l9.Info:AddRightGroupbox("Features", "list")
    FeaturesGroup:AddLabel(kY("Automation", lg), true)
    FeaturesGroup:AddLabel(kY("Misc Utilities", k5), true)
    local SocialsGroup = l9.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = lc })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            lz(k0, "Copied Rscripts profile to clipboard")
        end
    })
    local TempoHubGroup = l9.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
    TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
    TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
    TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
    TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = lc })
    qo = {
        [1] = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w",
        [2] = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99",
        [3] = "0xaE95A405D007a6F858E5d35714111B075fEFb40a",
        [4] = "0xaE95A405D007a6F858E5d35714111B075fEFb40a",
        [5] = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp",
        [6] = "",
        [7] = ""
    }
    local DonationsGroup = l9.Info:AddRightGroupbox("Donations", "heart")
    DonationsGroup:AddLabel(kY("All donations are optional but appreciated.", la), true)
    DonationsGroup:AddLabel(kY("If you donate you get a special role, just PING after you donate.", ln), true)
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(kY("LTC / Litecoin", "#345d9d"), true)
    DonationsGroup:AddButton({
        Text = "Copy Litecoin Address",
        Func = function()
            lz(qo[1], "Copied Litecoin address")
        end
    })
    DonationsGroup:AddLabel(kY("BTC / Bitcoin", "#f7931a"), true)
    DonationsGroup:AddButton({
        Text = "Copy Bitcoin Address",
        Func = function()
            lz(qo[2], "Copied Bitcoin address")
        end
    })
    DonationsGroup:AddLabel(kY("ETH / Ethereum", "#627eea"), true)
    DonationsGroup:AddButton({
        Text = "Copy Ethereum Address",
        Func = function()
            lz(qo[3], "Copied Ethereum address")
        end
    })
    DonationsGroup:AddLabel(kY("USDT", "#26a17b"), true)
    DonationsGroup:AddButton({
        Text = "Copy USDT Address",
        Func = function()
            lz(qo[4], "Copied USDT address")
        end
    })
    DonationsGroup:AddLabel(kY("Solana", "#14f195"), true)
    DonationsGroup:AddButton({
        Text = "Copy Solana Address",
        Func = function()
            lz(qo[5], "Copied Solana address")
        end
    })
    DonationsGroup:AddLabel(kY("PayPal", "#0070ba"), true)
    DonationsGroup:AddButton({
        Text = "Copy PayPal Link",
        Func = function()
            lz(qo[6], "Copied PayPal link")
        end
    })
    DonationsGroup:AddLabel(kY("Venmo", "#008cff"), true)
    DonationsGroup:AddButton({
        Text = "Copy Venmo Link",
        Func = function()
            lz(qo[7], "Copied Venmo link")
        end
    })
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(kY("Don't have any of the listed currencies but still wanna donate?", k5), true)
    DonationsGroup:AddLabel(kY("DM me and we'll work something out.", lg), true)
    local FaqGroup = l9.Info:AddRightGroupbox("FAQ", "circle-help")
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
end
md_1()
local PacksGroup = l9.Main:AddLeftGroupbox("Packs", "package")
PacksGroup:AddToggle("AutoBuyPacks", { Text = "Auto Buy Packs", Default = false })
PacksGroup:AddDropdown("PackList", { Text = "Packs", Values = lb, Default = lb, Multi = true, SelectAllButtons = true })
PacksGroup:AddSlider("KeepMoney", { Text = "Keep Money", Default = 0, Min = 0, Max = 10000000, Rounding = 0 })
PacksGroup:AddToggle("AutoBuyShop", { Text = "Auto Buy Shop", Default = false })
PacksGroup:AddDropdown("ShopList", { Text = "Shop", Values = k7, Default = k7, Multi = true, SelectAllButtons = true })
PacksGroup:AddSlider("KeepDiamonds", { Text = "Keep Diamonds", Default = 0, Min = 0, Max = 1000000, Rounding = 0 })
PacksGroup:AddToggle("AutoPlacePacks", { Text = "Auto Place Packs", Default = false })
PacksGroup:AddDropdown("PlaceList", { Text = "Place", Values = me, Default = me, Multi = true, SelectAllButtons = true })
PacksGroup:AddToggle("AutoOpenPacks", { Text = "Auto Open Packs", Default = false })
PacksGroup:AddDropdown("OpenList", { Text = "Open", Values = me, Default = me, Multi = true, SelectAllButtons = true })
local EconomyGroup = l9.Main:AddRightGroupbox("Economy", "coins")
EconomyGroup:AddToggle("AutoDropOff", { Text = "Auto Drop Off", Default = false })
EconomyGroup:AddDropdown("DropOffList", { Text = "Drop Off", Values = mb, Default = mb, Multi = true, SelectAllButtons = true })
EconomyGroup:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
EconomyGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
EconomyGroup:AddDropdown("UpgradeList", { Text = "Upgrades", Values = lx, Default = lx, Multi = true, SelectAllButtons = true })
EconomyGroup:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
EconomyGroup:AddDropdown("SellList", {
    Text = "Sell",
    Values = ls,
    Default = {},
    Multi = true,
    SelectAllButtons = true,
    Expandable = true
})
EconomyGroup:AddSlider("SellKeepAmount", { Text = "Keep Amount", Default = 0, Min = 0, Max = 50, Rounding = 0 })
le = {
    { id = "buy", dwell = 0.7 },
    { id = "place", dwell = 0.55 },
    { id = "open", dwell = 0.8 },
    { id = "collect", dwell = 0.7 },
    { id = "dropLetters", dwell = 1 },
    { id = "dropSymbols", dwell = 1 },
    { id = "dropWords", dwell = 1 }
}
k9 = fn322
l6 = fn50
lt = fn179
task.spawn(autoSellLoop)
local function mc_5()
    local MovementGroup = l9.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    local FlyGroup = l9.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local function gm(gn)
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not gn)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not gn
            end
        end)
        if not gn then
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
    RunService.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = LocalPlayer.Character
            if Character then
                for i, descendant in Character:GetDescendants() do
                    local qT_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if qT_2 then
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
            local q0_1 = lq()
            if q0_1 then
                q0_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    local CurrentCamera = Workspace.CurrentCamera
    RunService.RenderStepped:Connect(function(gU)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local q5_1 = lq()
            if q5_1 then
                q5_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local q5_3 = k2()
            local q6 = lq()
            if q5_3 and q6 then
                q6.PlatformStand = true
                local q6_1 = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    q6_1 += CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    q6_1 -= CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    q6_1 -= CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    q6_1 += CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    q6_1 += Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    q6_1 -= Vector3.new(0, 1, 0)
                end
                q5_3.AssemblyLinearVelocity = Vector3.zero
                if q6_1.Magnitude > 0 then
                    q5_3.CFrame = q5_3.CFrame + q6_1.Unit * Options.FlySpeed.Value * gU
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local rc = lq()
            if rc then
                rc.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local rh = lq()
            if rh then
                rh.WalkSpeed = 16
            end
        end
    end)
    Toggles.AntiGameplayPause:OnChanged(function()
        gm(Toggles.AntiGameplayPause.Value)
    end)
    gm(true)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                gm(true)
            end
        end
    end)
    return gm
end
lX = mc_5()
local function mm(hm)
    local hn
    hn = tick()
    local ho = tick()
    pcall(function()
        for k, v in getconnections(LocalPlayer.Idled) do
            local rq = v
            pcall(function()
                rq:Disable()
            end)
        end
    end)
    local function hu()
        local CurrentCamera = Workspace.CurrentCamera
        if not CurrentCamera then
            return
        end
        VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
        task.wait(0.1)
        VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
        ho = tick()
    end
    local connection2 = UserInputService.InputBegan:Connect(function()
        hn = tick()
    end)
    local connection = UserInputService.InputChanged:Connect(function(hE)
        local UserInputType = hE.UserInputType
        if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
            hn = tick()
        end
    end)
    hm:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            if Toggles.AntiAfk.Value then
                local rw = tick() - hn
                local rx = tick() - ho
                if rw >= 300 and rx >= 60 then
                    pcall(hu)
                else
                    if rw < 300 and rx >= 300 then
                        pcall(hu)
                    end
                end
            end
        end
    end)
    return connection2, connection
end
local MenuGroup = l9.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
l2, lV = mm(MenuGroup)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(l9.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/CollectTheAlphabet")
local ml = SaveManager:BuildConfigSection(l9.Settings)
SaveManager:LoadAutoloadConfig()
local function mk(hZ)
    local function h_(h0, h1)
        local rB_1 = (h0 == "Toggle" and Toggles or Options)[h1]
        local rA_2 = type(rB_1) == "table" and rB_1.Type == h0
        return rA_2 and rB_1 or nil
    end
    local function h9(ia, ib)
        local Type = ib.Type
        if Type == "Toggle" then
            return { idx = ia, type = "Toggle", value = ib.Value == true }
        elseif Type == "Slider" then
            return { idx = ia, type = "Slider", value = tostring(ib.Value) }
        elseif Type == "Dropdown" then
            return { idx = ia, type = "Dropdown", multi = ib.Multi == true, value = ib.Value }
        elseif Type == "Input" then
            local rF = ib.Value or ""
            return { idx = ia, type = "Input", text = tostring(rF) }
        elseif Type == "ColorPicker" then
            return { idx = ia, type = "ColorPicker", value = ib.Value:ToHex(), transparency = ib.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = ia,
                type = "KeyPicker",
                mode = ib.Mode,
                key = ib.Value,
                modifiers = ib.Modifiers,
                toggled = ib.Toggled
            }
        else
            return nil
        end
    end
    local function ie()
        local rL = {}
        for k, v in { Toggles, Options } do
            for k, v in v do
                local rM = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if rM then
                    local rM_1 = h9(k, v)
                    if rM_1 then
                        rL[#rL + 1] = rM_1
                    end
                end
            end
        end
        table.sort(rL, function(iq, ir)
            if iq.type ~= ir.type then
                return iq.type < ir.type
            end
            return iq.idx < ir.idx
        end)
        return { objects = rL }
    end
    local function is(it)
        local r1
        r1 = nil
        local r2 = type(it) ~= "table" or type(it.idx) ~= "string" or type(it.type) ~= "string" or SaveManager.Ignore[it.idx]
        if r2 then
            return false
        end
        r1 = h_(it.type, it.idx)
        if not r1 then
            return false
        end
        local r2_1 = pcall(function()
            if it.type == "Input" then
                if type(it.text) ~= "string" then
                    return
                end
                r1:SetValue(it.text)
            elseif it.type == "ColorPicker" then
                r1:SetValueRGB(Color3.fromHex(it.value), it.transparency)
            elseif it.type == "KeyPicker" then
                r1:SetValue({ it.key, it.mode, it.modifiers })
                if it.mode == "Toggle" and it.toggled ~= nil then
                    r1.Toggled = it.toggled
                    r1:Update()
                end
            else
                r1:SetValue(it.value)
            end
        end)
        return r2_1
    end
    hZ:AddDivider()
    hZ:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    hZ:AddButton("Export Config to Clipboard", function()
        local r8_1
        local r7_1
        r7_1, r8_1 = pcall(HttpService.JSONEncode, HttpService, ie())
        if not r7_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local r7_2 = setclipboard or toclipboard
        local r7_3 = type(r7_2) ~= "function" or not pcall(r7_2, r8_1)
        if r7_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    hZ:AddButton("Import Config from Clipboard Text", function()
        local sg_1
        local se = Options.SaveManager_ImportSource.Value
        local se_1
        local sk = if se then 1 else 0
        local si = 2075 * sk + 507 * (1 - sk)
        local sj = 4086 * sk + 3933 * (1 - sk)
        if not ((si * 2750 + sj * 3683 + si * sj) % 16777213 == 12456225) then
            se = ""
        end
        local sf = tostring(se):match("^%s*(.-)%s*$")
        if sf == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        se_1, sg_1 = pcall(HttpService.JSONDecode, HttpService, sf)
        local sf_1 = not se_1 or type(sg_1) ~= "table" or type(sg_1.objects) ~= "table"
        if sf_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local se_2 = 0
        for k, v in sg_1.objects do
            if is(v) then
                se_2 += 1
            end
        end
        if se_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local sg_2 = se_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(se_2, sg_2), 6)
    end)
end
mk(ml)
Library:OnUnload(fn795)
end)(...)

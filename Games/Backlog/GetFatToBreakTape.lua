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
getgenv().TempoHoodSubtitle = "GET FAT TO BREAK TAPE"
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
local r7_11
local r7_3_2
local Toggles
local connection3
local Level
local Pet
local lP
local GetRebirthData
local lw
local GetImpactData
local lV
local lC
local C_S_TrySpin
local GetTrailData
local connection2
local SceneHelper
local mp
local TryTeleportWorld
local l6
local lO
local mv
local Stats
local bodyVelocity
local lU
local lB
local LocalPlayer
local li
local FoodConfig
local lH
local VirtualUser
local lo
local l5
local lN
local mu
local TryUnlockImpact
local mb
local ImpactConfig
local lA
local mh
local lh
local lZ
local TryUnlockFood
local ln
local RebirthHelper
local GetAchievementData
local Pem
local lS
local mz
local AchievementHelper
local mg
local onRemoveHatchAnimation
local lY
local l3
local lL
local CollectionService
local TryEquipImpact
local bodyGyro
local PlayerTryClickRE
local win
local ly
local mf
local coin
local TrailConfig
local lE
local ml
local connection
local l2
local lK
local mr
local lr
local l8
local LuckConfig
local mx
local TryEquipTrail
local le
local PlayerIsEat
local lD
local UserInputService
local GetFoodData
local function worker13()
    while not mg.Unloaded do
        task.wait(2)
        if lO("AntiAfk") then
            local r1 = tick() - le
            local r2 = tick() - mz
            if r1 >= 300 and r2 >= 60 then
                pcall(mf)
            else
                if r1 < 300 and r2 >= 300 then
                    pcall(mf)
                end
            end
        end
    end
end
local function worker2()
    while not mg.Unloaded do
        local qv = lO("AutoScroll") or lO("TeleportEnd")
        if qv then
            if not LocalPlayer:GetAttribute("AutoRun") then
                LocalPlayer:SetAttribute("AutoRun", true)
            end
            if ln() then
                if lO("TeleportEnd") then
                    lN()
                end
            elseif not lO("CustomWalkSpeed") then
                mb(lZ(lY.WalkSpeed))
            end
        end
        task.wait(0.2)
    end
end
local function fn19()
    lo = GetRebirthData:InvokeServer()
end
local function fn34()
    local oT_1
    local oS_1
    oS_1, oT_1 = pcall(function()
        return GetAchievementData:InvokeServer()
    end)
    local oU = not oT_1
    local oV = not oS_1
    local oZ = if oV then 1 else 0
    local oX = 546 * oZ + 1522 * (1 - oZ)
    local oY = 2321 * oZ + 1063 * (1 - oZ)
    if not ((oX * 1971 + oY * 3576 + oX * oY) % 16777213 == 10643328) then
        oV = oU
    end
    if oV then
        return
    end
    for k, v in oT_1 do
        local oS_2 = mx[k]
        local oT_2 = oS_2 and AchievementHelper.getAchievementConfig(k)
        local oU_1 = oT_2
        if oT_2 then
            oT_2 = oU_1[v + 1]
        end
        local oU_2 = oT_2
        if oT_2 then
            oT_2 = oS_2() >= oU_2.need
        end
        if oT_2 then
            mp:FireServer(k)
        end
    end
end
local function fn44(bt)
    local oa_1
    local n9_1
    n9_1, oa_1 = pcall(Pem.isHavePem, "World" .. bt)
    return n9_1 and oa_1
end
local function fn53(ba)
    local nV = ba and tonumber(ba.Value)
    return nV or 0
end
local function fn67(b2)
    return b2.add and b2.add.power or 0
end
local function worker10()
    local rv = 0
    while not mg.Unloaded do
        if lO("AutoWinArea") then
            local rw = lD[lw(lY.TeleportWorld)[1]] or lr
            local rw_1 = rw ~= lr
            local ry = lO("WinAreaFollowWorld") and rw_1
            if ry then
                if tick() - rv >= 10 then
                    rv = tick()
                    TryTeleportWorld:FireServer(rw)
                end
            elseif not ln() then
                lh()
            end
        end
        task.wait(lZ(lY.WinDelay))
    end
end
local function worker4()
    local qz_1
    local qy_1
    while not mg.Unloaded do
        if lO("AutoSpin") then
            qy_1, qz_1 = pcall(function()
                return ml:InvokeServer()
            end)
            local qA = qy_1 and qz_1
            if qA then
                local qy_2 = tonumber(qz_1.total) or 0
                qA = qy_2 >= 1
            end
            if qA then
                pcall(function()
                    C_S_TrySpin:InvokeServer()
                end)
            end
        end
        task.wait(lZ(lY.SpinDelay))
    end
end
local function fn125()
    local Race = workspace:FindFirstChild("Race")
    local pz = l5()
    local pA = Race and Race:FindFirstChild("Return")
    if not pz or not pA then
        return
    end
    if pz.Transparency < 1 then
        lC(pz.Position + Vector3.new(0, 4, 0))
    elseif not LocalPlayer:GetAttribute("ReturnCoolDown") then
        lC(pA.Position + Vector3.new(0, 4, 0))
    end
end
local function fn126()
    mr = {}
    for k, v in CollectionService:GetTagged("RewardTape") do
        local nN = v.PrimaryPart and v:GetAttribute("Need")
        if nN then
            mr[#mr + 1] = v
        end
    end
    table.sort(mr, function(a7, a8)
        return a7:GetAttribute("Need") < a8:GetAttribute("Need")
    end)
end
local function onUnload()
    mg:Unload()
end
local function fn139(ep)
    l3()
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = ep
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 9000
    bodyGyro.CFrame = workspace.CurrentCamera.CFrame
    bodyGyro.Parent = ep
end
local function fn154(dw)
    local DiscordGroup = dw:AddLeftGroupbox("Discord", nil, true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = lU })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = lU })
end
local function fn222()
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
end
local function fn226()
    local Race = workspace:FindFirstChild("Race")
    local ps = Race and Race:FindFirstChild("WinModel")
    local pr_1 = ps
    if ps then
        ps = pr_1.PrimaryPart
    end
    local pt = ps
    if not pt then
        local ps_1 = pr_1 and pr_1:FindFirstChild("Main")
        pt = ps_1
    end
    return pt
end
local function fn232(bi)
    local n0 = bi
    local n1 = {}
    if n0 then
        n0 = typeof(bi.Value) == "table"
    end
    if n0 then
        for k, v in bi.Value do
            if v then
                n1[#n1 + 1] = k
            end
        end
        table.sort(n1)
    else
        if bi and bi.Value then
            n1[1] = bi.Value
        end
    end
    return n1
end
local function fn233(ax, ay)
    local nF_1
    local nE_1
    nF_1, nE_1 = LuckConfig[ax], LuckConfig[ay]
    if nF_1.CostType ~= nE_1.CostType then
        return nF_1.CostType == "coin"
    elseif nF_1.CostPrice ~= nE_1.CostPrice then
        return nF_1.CostPrice < nE_1.CostPrice
    else
        return ax < ay
    end
end
local function worker8()
    local qN_1
    while not mg.Unloaded do
        local qM = lO("AutoBuyImpact") or lO("AutoEquipImpact")
        local qM_1
        if qM then
            qM_1, qN_1 = pcall(function()
                return GetImpactData:InvokeServer()
            end)
            if qM_1 and qN_1 then
                if lO("AutoBuyImpact") then
                    l2(ImpactConfig, qN_1, TryUnlockImpact, mv(lY.ImpactReserve), false)
                end
                if lO("AutoEquipImpact") then
                    li(ImpactConfig, qN_1, TryEquipImpact, ly, false)
                end
            end
        end
        task.wait(lZ(lY.ImpactDelay))
    end
end
local function onTeleportEnd(dL)
    local pV = not dL
    if pV ~= false then
        pV = not lO("AutoScroll")
    end
    if pV then
        LocalPlayer:SetAttribute("AutoRun", false)
        mb(16)
    end
end
local function fn265(bd)
    local nY = Toggles[bd]
    return nY ~= nil and nY.Value == true
end
local function onJumpRequest()
    if not lO("InfiniteJump") then
        return
    end
    local Character = LocalPlayer.Character
    local p9 = Character and Character:FindFirstChildOfClass("Humanoid")
    if p9 then
        p9:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end
local function fn281()
    if setclipboard then
        setclipboard(l8)
    elseif toclipboard then
        toclipboard(l8)
    end
    mg:Notify("Copied Discord invite to clipboard")
end
local function fn311()
    mg.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
local function fn323()
    local nK = 1
    while nK <= 3 do
        local nL = nK
        if SceneHelper.GetWorldId(nL) == game.PlaceId then
            return nL
        end
        nK += 1
    end
    return 1
end
local function worker9()
    while not mg.Unloaded do
        if lO("AutoEquipPets") then
            pcall(Pet.EquipBestPet)
        end
        task.wait(lZ(lY.PetDelay))
    end
end
local function onAutoScroll(dG)
    local pT = not dG
    if pT ~= false then
        pT = not lO("TeleportEnd")
    end
    if pT then
        LocalPlayer:SetAttribute("AutoRun", false)
        mb(16)
    end
end
local function fn420()
    LocalPlayer:SetAttribute("AutoRun", false)
    mb(16)
    onRemoveHatchAnimation(false)
    l3()
    connection:Disconnect()
    connection2:Disconnect()
    connection3:Disconnect()
    select("#", "Get Fat to Break Tape unloaded")
end
local function onInputBegan()
    le = tick()
end
local function onDeleteRarities(dY)
    lL = {}
    for k, v in dY do
        if v and lV[k] then
            lL[lV[k]] = true
        end
    end
end
local function fn458()
    local oJ = Stats.getStats("OnlineTime") or 0
    return oJ
end
local function fn471()
    local oN = Stats.getStats("BreakTape") or 0
    return oN
end
local function worker3()
    while not mg.Unloaded do
        if lO("AutoAchievements") then
            mu()
        end
        task.wait(lZ(lY.AchievementDelay))
    end
end
local function fn523()
    local nx_1
    local nw_1
    if identifyexecutor then
        nx_1, nw_1 = identifyexecutor()
        local ny = nx_1 ~= ""
        local nz = type(nx_1) == "string" and ny
        if nz then
            local ny_1 = type(nw_1) == "string" and nw_1 ~= "" and nx_1 .. " " .. nw_1
            local nw_2 = ny_1
            local nD = if nw_2 then 1 else 0
            local nB = 1553 * nD + 29 * (1 - nD)
            local nC = 1987 * nD + 763 * (1 - nD)
            if not ((nB * 3246 + nC * 3087 + nB * nC) % 16777213 == 14260718) then
                nw_2 = nx_1
            end
            lK = nw_2
        end
    end
end
local function fn563()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    mz = tick()
end
local function worker6()
    local qF_1
    while not mg.Unloaded do
        local qE = lO("AutoBuyFood") or lO("AutoEquipFood")
        local qE_1
        if qE then
            qE_1, qF_1 = pcall(function()
                return GetFoodData:InvokeServer()
            end)
            if qE_1 and qF_1 then
                if lO("AutoBuyFood") then
                    l2(FoodConfig, qF_1, TryUnlockFood, mv(lY.FoodReserve), true)
                end
                if lO("AutoEquipFood") then
                    li(FoodConfig, qF_1, lE, lH, true)
                end
            end
        end
        task.wait(lZ(lY.FoodDelay))
    end
end
local function fn597(bM, bN, bO, bP, bQ)
    local os_1
    local oq = not bN or not bN.Unlock
    local oq_1
    if oq then
        return
    end
    os_1, oq_1 = nil, -1
    for k in bN.Unlock do
        local ot_1 = bM[k]
        local ou = ot_1
        if ou then
            local ov = not bQ or mh(ot_1.world)
            ou = ov
        end
        if ou then
            local ou_1 = bP(ot_1)
            if ou_1 > oq_1 then
                oq_1 = ou_1
                os_1 = k
            end
        end
    end
    if os_1 and os_1 ~= bN.Equip then
        bO:FireServer(os_1)
    end
end
local function fn623()
    return lo and lo.level or 0
end
local function fn628(c6)
    local Character = LocalPlayer.Character
    local pH = Character and Character:FindFirstChildOfClass("Humanoid")
    local pG_1 = pH
    if pH then
        pH = pG_1.WalkSpeed ~= c6
    end
    if pH then
        pG_1.WalkSpeed = c6
    end
end
local function worker7()
    local qJ_1
    while not mg.Unloaded do
        local qI = lO("AutoBuyTrail") or lO("AutoEquipTrail")
        local qI_1
        if qI then
            qI_1, qJ_1 = pcall(function()
                return GetTrailData:InvokeServer()
            end)
            if qI_1 and qJ_1 then
                if lO("AutoBuyTrail") then
                    l2(TrailConfig, qJ_1, lA, mv(lY.TrailReserve), false)
                end
                if lO("AutoEquipTrail") then
                    li(TrailConfig, qJ_1, TryEquipTrail, ly, false)
                end
            end
        end
        task.wait(lZ(lY.TrailDelay))
    end
end
local function fn693()
    if not lo or not lo.level then
        return false
    elseif lo.level >= 29 then
        return false
    else
        return Level.Value >= RebirthHelper.getMaxLevel(lo.level)
    end
end
local function fn781(by, bz, bA, bB, bC)
    if not bz or not bz.CanUnlock then
        return
    end
    for k, v in by do
        if v.id == bz.CanUnlock and v.type == "coin" and not bz.Unlock[k] then
            local od_2 = v.price <= bB
            if od_2 then
                local oe = not bC or mh(v.world)
                od_2 = oe
            end
            if od_2 then
                bA:FireServer(k)
            end
            return
        end
    end
end
local function fn783(b5)
    return b5.add or 0
end
local function worker()
    local qq = 0
    while not mg.Unloaded do
        local qu = if lO("AutoFeed") then 1 else 0
        if qu == 1 then
            if LocalPlayer:GetAttribute("Eating") then
                PlayerTryClickRE:FireServer(true)
            elseif tick() - qq >= 1 then
                qq = tick()
                PlayerIsEat:FireServer()
            end
        end
        task.wait(lZ(lY.FeedDelay))
    end
end
local function onTeleportToWorld()
    local p4 = lD[lw(lY.TeleportWorld)[1]]
    if p4 then
        TryTeleportWorld:FireServer(p4)
    end
end
local function worker12()
    local RunService = game:GetService("RunService")
    while not mg.Unloaded do
        RunService.Stepped:Wait()
        local Character = LocalPlayer.Character
        local rN = Character and Character:FindFirstChild("HumanoidRootPart")
        local rN_1 = lO("Noclip") and Character
        if rN_1 then
            for i, descendant in Character:GetDescendants() do
                local rM_1 = descendant:IsA("BasePart") and descendant.CanCollide
                if rM_1 then
                    descendant.CanCollide = false
                end
            end
        end
        if lO("CustomWalkSpeed") then
            mb(lZ(lY.PlayerWalkSpeed))
        end
        local rM_2 = lO("Fly") and rN
        if rM_2 then
            if not bodyVelocity or bodyVelocity.Parent ~= rN then
                lS(rN)
            end
            local CurrentCamera = workspace.CurrentCamera
            local rN_2 = Vector3.zero
            for k, v in l6 do
                if UserInputService:IsKeyDown(k) then
                    rN_2 = rN_2 + v
                end
            end
            if rN_2.Magnitude > 0 then
                local rO_1 = CurrentCamera.CFrame:VectorToWorldSpace(Vector3.new(rN_2.X, 0, rN_2.Z))
                local rO_2 = Vector3.new(rO_1.X, rO_1.Y + rN_2.Y, rO_1.Z)
                bodyVelocity.Velocity = rO_2.Unit * lZ(lY.FlySpeed)
            else
                bodyVelocity.Velocity = Vector3.zero
            end
            bodyGyro.CFrame = CurrentCamera.CFrame
        elseif bodyVelocity then
            l3()
        end
    end
end
local function fn809()
    return LocalPlayer:GetAttribute("State") == "Race"
end
local function worker5()
    while not mg.Unloaded do
        local qC = lO("AutoRebirth") and lB()
        if qC then
            lP:FireServer()
        end
        task.wait(lZ(lY.RebirthDelay))
    end
end
local function onInputChanged(eM)
    local UserInputType = eM.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        le = tick()
    end
end
local function onOnClientEvent(aZ)
    lo = aZ
end
local function onCustomWalkSpeed(eg)
    if not eg then
        mb(16)
    end
end
local function fn846()
    local oL = Stats.getStats("OpenEgg") or 0
    return oL
end
local function worker11()
    while not mg.Unloaded do
        if lO("AutoUnlockWorlds") then
            for k, v in { 2, 3 } do
                local rD = not mh(v) and win.Value >= SceneHelper.GetWorldUnlockMoney(v)
                if rD then
                    TryTeleportWorld:FireServer(v)
                    break
                end
            end
        end
        task.wait(lZ(lY.WorldDelay))
    end
end
local function fn869(bp)
    return coin.Value - lZ(bp)
end
GetImpactData = nil
le = nil
coin = nil
onRemoveHatchAnimation = nil
lh = nil
li = nil
GetTrailData = nil
GetFoodData = nil
connection = nil
ln = nil
lo = nil
TryTeleportWorld = nil
Pet = nil
lr = nil
TryEquipImpact = nil
Pem = nil
TryUnlockImpact = nil
Stats = nil
lw = nil
TryEquipTrail = nil
ly = nil
AchievementHelper = nil
lA = nil
lB = nil
lC = nil
lD = nil
lE = nil
TryUnlockFood = nil
lH = nil
SceneHelper = nil
connection3 = nil
lK = nil
lL = nil
RebirthHelper = nil
lN = nil
lO = nil
lP = nil
LuckConfig = nil
PlayerTryClickRE = nil
lS = nil
ImpactConfig = nil
lU = nil
lV = nil
PlayerIsEat = nil
TrailConfig = nil
lY = nil
lZ = nil
FoodConfig = nil
local EggOpener, PetHelper
connection2 = nil
Toggles = nil
l2 = nil
l3 = nil
l5 = nil
l6 = nil
l8 = nil
bodyGyro = nil
mb = nil
bodyVelocity = nil
mf = nil
mg = nil
mh = nil
LocalPlayer = nil
C_S_TrySpin = nil
UserInputService = nil
ml = nil
VirtualUser = nil
mp = nil
Level = nil
mr = nil
CollectionService = nil
GetAchievementData = nil
mu = nil
mv = nil
GetRebirthData = nil
mx = nil
win = nil
mz = nil
local l4, DeletePets, GetPlayerPetData, CanAddPet, C_S_DoLuck, TotalExp, mn, mK, mM, mN
l4 = nil
DeletePets = nil
GetPlayerPetData = nil
CanAddPet = nil
C_S_DoLuck = nil
TotalExp = nil
mn = nil
CollectionService, VirtualUser, UserInputService, LocalPlayer = nil, nil, nil, nil
local r7_13 = game:GetService("Players")
local r7_8 = game:GetService("ReplicatedStorage")
CollectionService = game:GetService("CollectionService")
VirtualUser = game:GetService("VirtualUser")
UserInputService = game:GetService("UserInputService")
LocalPlayer = r7_13.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end
l8, r7_11, PlayerIsEat, PlayerTryClickRE, lP, TryUnlockFood, lE, lA, TryEquipTrail, TryUnlockImpact, TryEquipImpact, TryTeleportWorld, GetFoodData, GetTrailData, GetImpactData, GetRebirthData, GetAchievementData, mp, ml, C_S_TrySpin, C_S_DoLuck, CanAddPet, GetPlayerPetData, DeletePets, l4, FoodConfig, TrailConfig, ImpactConfig, LuckConfig, RebirthHelper, SceneHelper, PetHelper, AchievementHelper, Stats, Pem, Pet, EggOpener, r7_13, coin, win, Level, TotalExp, mg, Toggles, lY, lK, lU = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
l8 = "https://discord.gg/K7Qxnxkk46"
if mp and not RebirthHelper and (not GetAchievementData or not GetAchievementData) and (not Level or not Level or not mp and GetAchievementData) and (Level and Level and (not Toggles and GetAchievementData) or Toggles and mp and (RebirthHelper or not Level)) or not (mp and not RebirthHelper and (not GetAchievementData or not GetAchievementData) and (not Level or not Level or not mp and GetAchievementData) and (Level and Level and (not Toggles and GetAchievementData) or Toggles and mp and (RebirthHelper or not Level))) then
    r7_11 = r7_8:WaitForChild("Remote")
else
    r7_8 = r7_11:WaitForChild("Remote")
end
local r7_4 = r7_11:WaitForChild("Event")
local r7_17 = r7_11:WaitForChild("Function")
PlayerIsEat = r7_4:WaitForChild("Eat"):WaitForChild("PlayerIsEat")
PlayerTryClickRE = r7_4:WaitForChild("Eat"):WaitForChild("PlayerTryClickRE")
if (not GetRebirthData and not GetRebirthData and (not AchievementHelper or SceneHelper) or (not GetRebirthData and AchievementHelper or (not GetRebirthData or GetRebirthData)) or (AchievementHelper or not SceneHelper or (SceneHelper or not GetRebirthData)) and (SceneHelper and GetRebirthData or (AchievementHelper or GetRebirthData))) and (((AchievementHelper or not GetRebirthData) and (GetRebirthData or not GetRebirthData) or not SceneHelper and not GetRebirthData and (not AchievementHelper and AchievementHelper)) and (SceneHelper and not GetRebirthData or not SceneHelper and GetRebirthData or not AchievementHelper and AchievementHelper and (GetRebirthData or not AchievementHelper))) and not ((not GetRebirthData and not GetRebirthData and (not AchievementHelper or SceneHelper) or (not GetRebirthData and AchievementHelper or (not GetRebirthData or GetRebirthData)) or (AchievementHelper or not SceneHelper or (SceneHelper or not GetRebirthData)) and (SceneHelper and GetRebirthData or (AchievementHelper or GetRebirthData))) and (((AchievementHelper or not GetRebirthData) and (GetRebirthData or not GetRebirthData) or not SceneHelper and not GetRebirthData and (not AchievementHelper and AchievementHelper)) and (SceneHelper and not GetRebirthData or not SceneHelper and GetRebirthData or not AchievementHelper and AchievementHelper and (GetRebirthData or not AchievementHelper)))) then
    r7_4 = TryUnlockFood:WaitForChild("Rebirth"):WaitForChild("TryRebirth")
    lP = TryUnlockFood:WaitForChild("Rebirth"):WaitForChild("RebirthDataChanged")
    mK = TryUnlockFood:WaitForChild("Food"):WaitForChild("TryUnlockFood")
    lA = TryUnlockFood:WaitForChild("Food"):WaitForChild("TryEquipFood")
    lE = TryUnlockFood:WaitForChild("Trail"):WaitForChild("TryUnlockTrail")
else
    lP = r7_4:WaitForChild("Rebirth"):WaitForChild("TryRebirth")
    mK = r7_4:WaitForChild("Rebirth"):WaitForChild("RebirthDataChanged")
    TryUnlockFood = r7_4:WaitForChild("Food"):WaitForChild("TryUnlockFood")
    lE = r7_4:WaitForChild("Food"):WaitForChild("TryEquipFood")
    lA = r7_4:WaitForChild("Trail"):WaitForChild("TryUnlockTrail")
end
TryEquipTrail = r7_4:WaitForChild("Trail"):WaitForChild("TryEquipTrail")
TryUnlockImpact = r7_4:WaitForChild("Impact"):WaitForChild("TryUnlockImpact")
TryEquipImpact = r7_4:WaitForChild("Impact"):WaitForChild("TryEquipImpact")
TryTeleportWorld = r7_4:WaitForChild("World"):WaitForChild("TryTeleportWorld")
GetFoodData = r7_17:WaitForChild("Food"):WaitForChild("GetFoodData")
GetTrailData = r7_17:WaitForChild("Trail"):WaitForChild("GetTrailData")
GetImpactData = r7_17:WaitForChild("Impact"):WaitForChild("GetImpactData")
GetRebirthData = r7_17:WaitForChild("Rebirth"):WaitForChild("GetRebirthData")
GetAchievementData = r7_17:WaitForChild("Achievement"):WaitForChild("GetAchievementData")
if not win and ml and (not TryEquipImpact and TryEquipImpact) and (not TryEquipImpact and not ml or not CanAddPet and not r7_13) and (not CanAddPet or ml or not win and r7_13 or (r7_13 or not win) and (not ml or not win)) or ((CanAddPet or ml) and (CanAddPet and ml) and (ml and TryEquipImpact or (r7_13 or not r7_13)) or (not Stats and not ml or CanAddPet and not TryEquipImpact) and (win or not CanAddPet or ml and TryEquipImpact)) or not (not win and ml and (not TryEquipImpact and TryEquipImpact) and (not TryEquipImpact and not ml or not CanAddPet and not r7_13) and (not CanAddPet or ml or not win and r7_13 or (r7_13 or not win) and (not ml or not win)) or ((CanAddPet or ml) and (CanAddPet and ml) and (ml and TryEquipImpact or (r7_13 or not r7_13)) or (not Stats and not ml or CanAddPet and not TryEquipImpact) and (win or not CanAddPet or ml and TryEquipImpact))) then
    mp = r7_4:WaitForChild("Achievement"):WaitForChild("TryClaimAchievement")
    ml = r7_17:WaitForChild("Spin"):WaitForChild("[C-S]GetSpinData")
    C_S_TrySpin = r7_17:WaitForChild("Spin"):WaitForChild("[C-S]TrySpin")
else
    ml = C_S_TrySpin:WaitForChild("Achievement"):WaitForChild("TryClaimAchievement")
    mp = r7_4:WaitForChild("Spin"):WaitForChild("[C-S]GetSpinData")
    r7_17 = r7_4:WaitForChild("Spin"):WaitForChild("[C-S]TrySpin")
end
C_S_DoLuck = r7_17:WaitForChild("Luck"):WaitForChild("[C-S]DoLuck")
CanAddPet = r7_17:WaitForChild("Pet"):WaitForChild("CanAddPet")
GetPlayerPetData = r7_17:WaitForChild("Pet"):WaitForChild("GetPlayerPetData")
DeletePets = r7_4:WaitForChild("Pet"):WaitForChild("DeletePets")
l4 = {
    r7_4:WaitForChild("Luck"):WaitForChild("[S-C]DoLuck"),
    r7_4:WaitForChild("Luck"):WaitForChild("[S-C]DoLuck3")
}
FoodConfig = require(r7_8.Config.FoodHelper.FoodConfig)
TrailConfig = require(r7_8.Config.TrailHelper.TrailConfig)
ImpactConfig = require(r7_8.Config.ImpactHelper.ImpactConfig)
LuckConfig = require(r7_8.Config.LuckHelper.LuckConfig)
RebirthHelper = require(r7_8.Config.RebirthHelper)
SceneHelper = require(r7_8.Config.SceneHelper)
PetHelper = require(r7_8.Config.PetHelper)
local r7_2 = require(r7_8.Utils.AbbNumber)
AchievementHelper = require(r7_8.Config.AchievementHelper)
Stats = require(r7_8.GuiUtils.Stats)
Pem = require(r7_8.GuiUtils.Pem)
Pet = require(r7_8.GuiUtils.Pet)
EggOpener = require(r7_8.GuiUtils.EggOpener)
r7_13 = LocalPlayer:WaitForChild("Eco")
coin = r7_13:WaitForChild("coin")
win = r7_13:WaitForChild("win")
local r7_6 = LocalPlayer:WaitForChild("LevelHolder")
Level = r7_6:WaitForChild("Level")
TotalExp = r7_6:WaitForChild("TotalExp")
if (false and Level or not Level and Level) and (Level or not mg or (mg or not mg)) or not ((false and Level or not Level and Level) and (Level or not mg or (mg or not mg))) then
    mg = getgenv().Library
    pcall(fn311)
    mN = getgenv().ThemeManager
    mM = getgenv().SaveManager
    Toggles = mg.Toggles
    lY = mg.Options
else
    lY = getgenv().Library
    pcall(fn311)
    mg = getgenv().ThemeManager
    mN = getgenv().SaveManager
    mM = lY.Options
end
lU = fn281
lK = "Unknown"
pcall(fn523)
local r7_12 = {}
for k in LuckConfig do
    r7_12[#r7_12 + 1] = k
end
mn = nil
r7_13 = 4
repeat
    if r7_13 * 124149325 + 10 + 6 <= r7_13 * 124149325 + 10 + 6 + 5 then
        table.sort(r7_12, fn233)
        r7_3_2 = {}
        mn = {}
    else
        table.sort(mn, fn233)
        r7_12 = {}
        r7_3_2 = {}
    end
    r7_13 = (r7_13 + 0) % 8
until (r7_13 * 7 + 5) % 8 == 1
for k, v in r7_12 do
    r7_13 = LuckConfig[v]
    r7_8 = r7_13.CostType == "coin" and r7_2.AbbreviateNumber(r7_13.CostPrice)
    r7_17 = r7_8 or tostring(r7_13.CostType) .. " " .. tostring(r7_13.CostPrice)
    r7_8 = r7_17
    r7_17 = r7_13.DisPlayEggName or v
    r7_13 = r7_17 .. " (" .. r7_8 .. ")"
    if mn[r7_13] then
        r7_13 = r7_13 .. " " .. v
    end
    r7_3_2[#r7_3_2 + 1] = r7_13
    mn[r7_13] = v
end
lV = nil
r7_17 = { "Common", "UnCommon", "Rare", "Epic", "Legendary", "Mythic", "Exclusive" }
lV = {}
for k, v in r7_17 do
    lV[v] = k
end
lL, lD, lr, lo, mr, mx, lZ, lO, lw, mv, mh, l2, li, lH, ly, mu, lB, ln, onRemoveHatchAnimation, l5, lC, lh, mb, lN = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
lL = {}
r7_6 = { "World 1", "World 2", "World 3" }
lD = { ["World 1"] = 1, ["World 2"] = 2, ["World 3"] = 3 }
r7_13 = fn323
lr = r7_13()
lo = nil
pcall(fn19)
mK.OnClientEvent:Connect(onOnClientEvent)
mr = {}
r7_11 = fn126
r7_11()
CollectionService:GetInstanceAddedSignal("RewardTape"):Connect(r7_11)
lZ = fn53
lO = fn265
lw = fn232
mv = fn869
mh = fn44
l2 = fn781
li = fn597
lH = fn67
ly = fn783
mx = { Time = fn458, Egg = fn846, Tape = fn471, Rebirth = fn623 }
mu = fn34
lB = fn693
ln = fn809
onRemoveHatchAnimation = function(cA)
    for k, v in l4 do
        local pn = v
        pcall(function()
            for i, v in ipairs(getconnections(pn.OnClientEvent)) do
                if cA then
                    v:Disable()
                else
                    v:Enable()
                end
            end
        end)
    end
    if cA then
        pcall(EggOpener.Reset)
    end
end
l5 = fn226
lC = function(cS)
    local Character
    Character = nil
    Character = LocalPlayer.Character
    if not Character or not Character.PrimaryPart then
        return
    end
    pcall(function()
        Character:PivotTo(CFrame.new(cS))
    end)
end
lh = fn125
mb = fn628
lN = function()
    local Character = LocalPlayer.Character
    if not Character or not Character.PrimaryPart then
        return
    end
    local Value = TotalExp.Value
    for k, v in mr do
        local pS = v
        local pL = mg.Unloaded or not ln()
        if pL then
            return
        end
        if not pS:GetAttribute("IsTouch") then
            pcall(function()
                Character:PivotTo(CFrame.new(pS.PrimaryPart.Position))
            end)
            task.wait(lZ(lY.TapeDelay))
            if pS:GetAttribute("Need") > Value then
                return
            end
        end
    end
end
r7_4 = mg:CreateWindow({
    Title = "Tempo Hub",
    Footer = "https://discord.gg/K7Qxnxkk46 | Get Fat to Break Tape",
    Icon = 18657887261,
    NotifySide = "Right",
    ShowCustomCursor = false,
    Size = UDim2.fromOffset(760, 620)
})
r7_12 = {
    Info = r7_4:AddTab("Info", "info"),
    Main = r7_4:AddTab("Main", "drumstick"),
    Gear = r7_4:AddTab("Gear", "shirt"),
    Eggs = r7_4:AddTab("Eggs", "egg"),
    Worlds = r7_4:AddTab("Worlds", "globe"),
    Player = r7_4:AddTab("Player", "user"),
    Settings = r7_4:AddTab("Settings", "settings")
}
for k, v in r7_12 do
    fn154(v)
end
mK = r7_12.Info:AddLeftGroupbox("Basic Info", "circle-user")
mK:AddLabel("Executor: " .. lK, true)
mK:AddLabel("Game: Get Fat to Break Tape", true)
mK:AddLabel("Player: " .. LocalPlayer.Name, true)
mK:AddLabel("Status: Keyless", true)
r7_2 = r7_12.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
r7_2:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
r7_2:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
r7_2:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
r7_2:AddButton({ Text = "Copy Discord Invite", Func = lU })
r7_11 = r7_12.Info:AddRightGroupbox("FAQ", "circle-help")
r7_11:AddLabel("Where do I get a good config?", true)
r7_11:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
r7_11:AddLabel("How do I import / export configs?", true)
r7_11:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
r7_11:AddLabel("How do I report bugs?", true)
r7_11:AddLabel("Join the Discord and post it in the bugs channel.", true)
r7_11:AddLabel("How do I make suggestions?", true)
r7_11:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
r7_11:AddLabel("How do I get help or updates?", true)
r7_11:AddLabel("Join the Discord, updates and support are posted there first.", true)
r7_4 = r7_12.Main:AddLeftGroupbox("Auto Feed", "utensils")
r7_4:AddToggle("AutoFeed", { Text = "Auto Feed", Default = false })
r7_4:AddSlider("FeedDelay", { Text = "Click Delay", Default = 0.05, Min = 0.02, Max = 0.5, Rounding = 2 })
r7_13 = r7_12.Main:AddRightGroupbox("Auto Scroll", "wind")
r7_13:AddToggle("AutoScroll", { Text = "Auto Scroll", Default = false, Callback = onAutoScroll })
r7_13:AddToggle("TeleportEnd", { Text = "Teleport To End Of Map", Default = false, Callback = onTeleportEnd })
r7_13:AddSlider("WalkSpeed", { Text = "Walk Speed", Default = 90, Min = 16, Max = 250, Rounding = 0 })
r7_13:AddSlider("TapeDelay", { Text = "Tape Delay", Default = 0.25, Min = 0.1, Max = 2, Rounding = 2 })
local AutoSpinGroup = r7_12.Main:AddLeftGroupbox("Auto Spin", "disc-3")
AutoSpinGroup:AddToggle("AutoSpin", { Text = "Auto Spin Wheel", Default = false })
AutoSpinGroup:AddSlider("SpinDelay", { Text = "Loop Delay", Default = 1.5, Min = 0.5, Max = 30, Rounding = 1 })
local AutoAchievementsGroup = r7_12.Main:AddLeftGroupbox("Auto Achievements", "award")
AutoAchievementsGroup:AddToggle("AutoAchievements", { Text = "Auto Claim Achievements", Default = false })
AutoAchievementsGroup:AddSlider("AchievementDelay", { Text = "Loop Delay", Default = 3, Min = 1, Max = 60, Rounding = 1 })
local AutoRebirthGroup = r7_12.Main:AddRightGroupbox("Auto Rebirth", "crown")
AutoRebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
AutoRebirthGroup:AddSlider("RebirthDelay", { Text = "Loop Delay", Default = 3, Min = 1, Max = 30, Rounding = 1 })
local AutoFoodGroup = r7_12.Gear:AddLeftGroupbox("Auto Food", "cookie")
AutoFoodGroup:AddToggle("AutoBuyFood", { Text = "Auto Buy Best Affordable Food", Default = false })
AutoFoodGroup:AddToggle("AutoEquipFood", { Text = "Auto Equip Best Food", Default = false })
AutoFoodGroup:AddInput("FoodReserve", { Text = "Keep Coin Reserve", Default = "0", Numeric = true, Finished = true })
AutoFoodGroup:AddSlider("FoodDelay", { Text = "Loop Delay", Default = 1, Min = 0.5, Max = 15, Rounding = 1 })
local AutoTrailGroup = r7_12.Gear:AddRightGroupbox("Auto Trail", "sparkle")
AutoTrailGroup:AddToggle("AutoBuyTrail", { Text = "Auto Buy Best Affordable Trail", Default = false })
AutoTrailGroup:AddToggle("AutoEquipTrail", { Text = "Auto Equip Best Trail", Default = false })
AutoTrailGroup:AddInput("TrailReserve", { Text = "Keep Coin Reserve", Default = "0", Numeric = true, Finished = true })
AutoTrailGroup:AddSlider("TrailDelay", { Text = "Loop Delay", Default = 2, Min = 0.5, Max = 15, Rounding = 1 })
local AutoAuraGroup = r7_12.Gear:AddRightGroupbox("Auto Aura", "flame")
AutoAuraGroup:AddToggle("AutoBuyImpact", { Text = "Auto Buy Best Affordable Aura", Default = false })
AutoAuraGroup:AddToggle("AutoEquipImpact", { Text = "Auto Equip Best Aura", Default = false })
AutoAuraGroup:AddInput("ImpactReserve", { Text = "Keep Coin Reserve", Default = "0", Numeric = true, Finished = true })
AutoAuraGroup:AddSlider("ImpactDelay", { Text = "Loop Delay", Default = 2, Min = 0.5, Max = 15, Rounding = 1 })
local AutoPetsGroup = r7_12.Gear:AddLeftGroupbox("Auto Pets", "paw-print")
AutoPetsGroup:AddToggle("AutoEquipPets", { Text = "Auto Equip Best Pets", Default = false })
AutoPetsGroup:AddSlider("PetDelay", { Text = "Loop Delay", Default = 5, Min = 3, Max = 60, Rounding = 1 })
local AutoDeletePetsGroup = r7_12.Eggs:AddLeftGroupbox("Auto Delete Pets", "trash-2")
AutoDeletePetsGroup:AddToggle("AutoDeletePets", { Text = "Auto Delete Pets", Default = false })
AutoDeletePetsGroup:AddDropdown("DeleteRarities", {
    Text = "Rarities To Delete",
    Values = r7_17,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Callback = onDeleteRarities
})
AutoDeletePetsGroup:AddToggle("SkipLockedPets", { Text = "Skip Locked", Default = true })
AutoDeletePetsGroup:AddToggle("SkipStarPets", { Text = "Skip Star Pets", Default = true })
AutoDeletePetsGroup:AddInput("KeepBestPets", {
    Text = "Keep Best Amount",
    Default = "3",
    Numeric = true,
    Finished = false,
    AllowEmpty = false,
    EmptyReset = "0",
    ClearTextOnFocus = false
})
AutoDeletePetsGroup:AddSlider("DeleteDelay", { Text = "Loop Delay", Default = 3, Min = 1, Max = 60, Rounding = 1 })
r7_8 = r7_12.Eggs:AddRightGroupbox("Auto Hatch", "egg")
r7_8:AddToggle("AutoHatch", { Text = "Auto Hatch", Default = false })
r7_8:AddDropdown("HatchEgg", { Text = "Egg", Values = r7_3_2, Default = {}, Multi = true, Searchable = true, AllowNull = true })
r7_8:AddInput("HatchAmount", {
    Text = "Amount",
    Default = "3",
    Numeric = true,
    Finished = false,
    AllowEmpty = false,
    EmptyReset = "1",
    ClearTextOnFocus = false
})
r7_8:AddToggle("RemoveHatchAnimation", { Text = "Remove Hatch Animation", Default = true, Callback = onRemoveHatchAnimation })
r7_8:AddInput("EggReserve", { Text = "Keep Coin Reserve", Default = "0", Numeric = true, Finished = true })
r7_8:AddSlider("EggDelay", { Text = "Loop Delay", Default = 0.5, Min = 0.2, Max = 10, Rounding = 1 })
local mX = {
    "Puwede kang mag-hatch ng kahit ilang itlog na gusto mo, halimbawa 10, 20, 30 o higit pa.",
    "You can hatch as many eggs as you want, for example 10, 20, 30 or more.",
    "Kamu bisa menetaskan telur sebanyak yang kamu mau, misalnya 10, 20, 30 atau lebih.",
    "Вы можете открыть столько яиц, сколько хотите, например 10, 20, 30 или больше.",
    "คุณสามารถฟักไข่ได้มากเท่าที่ต้องการ เช่น 10, 20, 30 หรือมากกว่านั้น",
    "Voce pode chocar quantos ovos quiser, por exemplo 10, 20, 30 ou mais.",
    "Ban co the mo bao nhieu trung tuy thich, vi du 10, 20, 30 hoac hon."
}
local AmountGroup = r7_12.Eggs:AddRightGroupbox("Amount", "circle-help")
for k, v in mX do
    AmountGroup:AddLabel('<font color="rgb(90,220,120)">' .. v .. "</font>", true)
end
bodyVelocity, bodyGyro, l6, connection, le, mz, connection2, connection3, l3, lS, mf = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local r7_3_3 = r7_12.Worlds:AddRightGroupbox("Worlds", "map")
r7_3_3:AddToggle("AutoUnlockWorlds", { Text = "Auto Unlock Worlds", Default = false })
r7_3_3:AddSlider("WorldDelay", { Text = "Loop Delay", Default = 5, Min = 2, Max = 60, Rounding = 1 })
r7_3_3:AddDropdown("TeleportWorld", {
    Text = "Teleport To",
    Values = r7_6,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true
})
r7_3_3:AddButton({ Text = "Teleport To World", Func = onTeleportToWorld })
r7_4 = r7_12.Worlds:AddLeftGroupbox("Auto Win", "trophy")
r7_4:AddToggle("AutoWinArea", { Text = "Auto Instant-Win", Default = false })
r7_4:AddToggle("WinAreaFollowWorld", { Text = "Teleport To Selected World First", Default = false })
r7_4:AddSlider("WinDelay", { Text = "Loop Delay", Default = 0.2, Min = 0.1, Max = 5, Rounding = 2 })
r7_17 = r7_12.Player:AddRightGroupbox("Movement", "footprints")
r7_17:AddToggle("CustomWalkSpeed", { Text = "Walk Speed", Default = false, Callback = onCustomWalkSpeed })
r7_17:AddSlider("PlayerWalkSpeed", { Text = "Walk Speed Amount", Default = 60, Min = 16, Max = 500, Rounding = 0 })
r7_17:AddToggle("Fly", { Text = "Fly", Default = false })
r7_17:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 80, Min = 16, Max = 500, Rounding = 0 })
r7_17:AddToggle("Noclip", { Text = "Noclip", Default = false })
r7_17:AddToggle("InfiniteJump", { Text = "Infinite Jump", Default = false })
bodyVelocity = nil
bodyGyro = nil
l6 = {
    [Enum.KeyCode.W] = Vector3.new(0, 0, -1),
    [Enum.KeyCode.S] = Vector3.new(0, 0, 1),
    [Enum.KeyCode.A] = Vector3.new(-1, 0, 0),
    [Enum.KeyCode.D] = Vector3.new(1, 0, 0),
    [Enum.KeyCode.Space] = Vector3.new(0, 1, 0),
    [Enum.KeyCode.LeftControl] = Vector3.new(0, -1, 0)
}
l3 = fn222
lS = fn139
connection = UserInputService.JumpRequest:Connect(onJumpRequest)
r7_13 = r7_12.Settings:AddLeftGroupbox("Menu", "wrench")
r7_13:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
le = tick()
mz = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local qh = v
        pcall(function()
            qh:Disable()
        end)
    end
end)
mf = fn563
connection2 = UserInputService.InputBegan:Connect(onInputBegan)
connection3 = UserInputService.InputChanged:Connect(onInputChanged)
r7_13:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
r7_13:AddButton("Unload", onUnload)
mg.ToggleKeybind = lY.MenuKeybind
mg:OnUnload(fn420)
mN:SetLibrary(mg)
mN:SetFolder("TempoHub")
mN:SaveDefault("Mint")
mM:SetLibrary(mg)
mM:IgnoreThemeSettings()
mM:SetIgnoreIndexes({ "MenuKeybind" })
mM:SetFolder("TempoHub/GetFatToBreakTape")
mM:BuildConfigSection(r7_12.Settings)
mN:ApplyToTab(r7_12.Settings)
mN:LoadDefault()
mM:LoadAutoloadConfig()
onRemoveHatchAnimation(lO("RemoveHatchAnimation"))
task.spawn(worker)
task.spawn(worker2)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
task.spawn(worker6)
task.spawn(worker7)
task.spawn(worker8)
task.spawn(function()
    local qS_1
    local qZ = false
    repeat
        local qQ
        if not mg.Unloaded then
            local qR = lO("AutoDeletePets") and next(lL)
            local qR_1
            if qR then
                qR_1, qS_1 = pcall(function()
                    return GetPlayerPetData:InvokeServer()
                end)
                if qR_1 and qS_1 then
                    local max = math.max
                    local floor = math.floor
                    local qU = tonumber(lY.KeepBestPets.Value) or 0
                    local qV = max(0, floor(qU))
                    local qR_3 = {}
                    local qT_2 = {}
                    qQ = {}
                    local qU_1 = {}
                    for k, v in qS_1.UnEquipPet do
                        qU_1[#qU_1 + 1] = v
                        local GUID = v.GUID
                        local qW_1 = PetHelper.GetPetAddFromID(v.ID) or 0
                        qQ[GUID] = qW_1
                    end
                    table.sort(qU_1, function(gE, gF)
                        return qQ[gE.GUID] > qQ[gF.GUID]
                    end)
                    local qS_3 = math.min(qV, #qU_1)
                    local q7 = 1
                    while q7 <= qS_3 do
                        local q8 = q7
                        qR_3[qU_1[q8].GUID] = true
                        q7 += 1
                    end
                    for k, v in qU_1 do
                        if #qT_2 >= 20 then
                            break
                        end
                        local qS_4 = PetHelper.GetPetRarityFromID(v.ID)
                        local qU_2 = lO("SkipLockedPets") and v.isLock
                        local qU_3 = (lO("SkipStarPets"))
                        if qU_3 then
                            qU_3 = v.Star > 0 or v.Super > 0
                        end
                        if lL[qS_4] and not qU_2 and not qU_3 and not qR_3[v.GUID] then
                            qT_2[#qT_2 + 1] = v
                        end
                    end
                    if #qT_2 > 0 then
                        DeletePets:FireServer(qT_2)
                    end
                end
            end
            task.wait(lZ(lY.DeleteDelay))
        else
            qZ = true
        end
    until qZ
end)
task.spawn(worker9)
task.spawn(function()
    local ro = false
    repeat
        if not mg.Unloaded then
            if lO("AutoHatch") then
                local max = math.max
                local rj_3
                local floor = math.floor
                local rk_3
                local rl = tonumber(lY.HatchAmount.Value) or 1
                local rh = max(1, floor(rl))
                for k, v in lw(lY.HatchEgg) do
                    local rj_1 = mg.Unloaded or not lO("AutoHatch")
                    if rj_1 then
                        break
                    else
                        local ri = mn[v]
                        local rj_2 = ri and LuckConfig[ri]
                        local rk_1 = rj_2
                        if rj_2 then
                            local rl_1 = rk_1.CostType ~= "coin" or mv(lY.EggReserve) >= rk_1.CostPrice * rh
                            rj_2 = rl_1
                        end
                        if rj_2 then
                            rj_3, rk_3 = pcall(function()
                                return CanAddPet:InvokeServer(rh)
                            end)
                            if rj_3 and rk_3 then
                                pcall(function()
                                    C_S_DoLuck:InvokeServer(ri, rh)
                                end)
                            end
                        end
                    end
                end
            end
            task.wait(lZ(lY.EggDelay))
        else
            ro = true
        end
    until ro
end)
task.spawn(worker10)
task.spawn(worker11)
task.spawn(worker12)
task.spawn(worker13)
end)(...)

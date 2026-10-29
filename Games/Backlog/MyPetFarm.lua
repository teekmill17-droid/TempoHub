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
getgenv().TempoHoodSubtitle = "MY PET FARM"
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
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local State = require(Shared:WaitForChild("State"))
local SEED_ID_ATTR = State.Seed.Id
local TOOL_GUID_ATTR = State.Tool.Guid
local GRID_PURCHASABLE_ATTR = State.Grid.Purchasable
local TREE_GROUND_PILE_ATTR = State.TreeClicker.GroundPile
local TREE_LOCAL_VISUAL_ATTR = State.TreeClicker.LocalVisual
local TREE_SLOT_INDEX_ATTR = State.TreeClicker.SlotIndex
local FOOD_ID_ATTR = State.Food.Id
local FEED_CLASS_ATTR = State.Feed.Class
local function getRemote(name)
    return Remotes:FindFirstChild(name)
end
local AutoRollRemote = getRemote("AutoRollRequest")
local PlaceFeedMachine = getRemote("PlaceFeedMachine")
local TreeClicker = getRemote("TreeClickerRequest")
local RollLuckUpgrade = getRemote("RollLuckUpgradeRequest")
local RollDropAreaUpgrade = getRemote("RollDropAreaUpgradeRequest")
local RebirthRemote = getRemote("RebirthRequest")
local GearPurchase = getRemote("GearShopPurchaseRequest")
local CosmeticPurchase = getRemote("CosmeticShopPurchaseRequest")
local CrateRollPurchaseRequest = getRemote("CrateRollPurchaseRequest")
local CrateRollEffect = getRemote("CrateRollEffect")
local PromptInteract = getRemote("PromptInteract")
local RARITIES = { "Common", "Rare", "Epic", "Legendary", "Mythical", "Secret" }
local GEAR_IDS = { "JamBarrel", "UpgradedJamBarrel", "GoldenJamBarrel" }
local COSMETIC_IDS = { "Path", "GrassPath", "TikiTorch", "Arch", "Fountain", "Golden Fountain" }
local SEED_IDS = {
    "PineappleSeed", "PumpkinSeed", "PurpleShroomSeed", "WatermelonSeed", "GlowshroomSeed",
    "CornSeed", "CabbageSeed", "MushroomSeed", "PotatoSeed",
    "AppleTreeSeed", "CherryTreeSeed", "OrangeTreeSeed", "BananaTreeSeed", "FigTreeSeed",
    "PlumTreeSeed", "GoldenAppleTreeSeed", "CactusSeed", "BloodOrangeTreeSeed",
    "DurianTreeSeed", "DragonfruitTreeSeed",
}
local UPGRADE_NAMES = { "Roll Luck", "Roll Drop Area" }
local nonceCounter = 0
local function nextNonce()
    nonceCounter = nonceCounter + 1
    return nonceCounter
end
local function selectedSet(value)
    local set = {}
    if type(value) == "table" then
        for name, state in pairs(value) do
            if state then
                set[name] = true
            end
        end
    end
    return set
end
local cachedPlot = nil
local function getPlot()
    if cachedPlot and cachedPlot.Parent then
        return cachedPlot
    end
    cachedPlot = nil
    local plots = workspace:FindFirstChild("Plots")
    if not plots then
        return nil
    end
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            cachedPlot = plot
            return plot
        end
    end
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return nil
    end
    local best, bestDist
    for _, plot in ipairs(plots:GetChildren()) do
        local part = plot:FindFirstChildWhichIsA("BasePart", true)
        if part then
            local dist = (part.Position - root.Position).Magnitude
            if not bestDist or dist < bestDist then
                bestDist = dist
                best = plot
            end
        end
    end
    cachedPlot = best
    return best
end
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = getgenv().Library
pcall(function()
    Library.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end)
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
local Toggles = Library.Toggles
local Options = Library.Options
local DISCORD_LINK = "https://discord.gg/K7Qxnxkk46"
local function copyDiscord()
    if setclipboard then
        setclipboard(DISCORD_LINK)
    elseif toclipboard then
        toclipboard(DISCORD_LINK)
    end
    Library:Notify("Copied Discord invite to clipboard")
end
local selectedRarities = {}
local selectedUpgrades = {}
local selectedSeeds = {}
local selectedGears = {}
local selectedCosmetics = {}
local petMoneyThresholds = {}
local movementBusy = false
local function petKey(pet)
    return tostring(pet:GetAttribute("PetID") or pet:GetAttribute("PetIndex") or pet:GetDebugId())
end
local function beginMovement()
    if movementBusy then
        return false
    end
    movementBusy = true
    return true
end
local function endMovement()
    movementBusy = false
end
local function selectedRarityArray()
    local array = {}
    for _, rarity in ipairs(RARITIES) do
        if selectedRarities[rarity] then
            array[#array + 1] = rarity
        end
    end
    if #array == 0 then
        for _, rarity in ipairs(RARITIES) do
            array[#array + 1] = rarity
        end
    end
    return array
end
local function sendAutoRoll(action)
    if not AutoRollRemote then
        return
    end
    pcall(function()
        AutoRollRemote:FireServer({
            action = action,
            autoPurchase = Toggles.RollAutoPurchase.Value == true,
            selectedRarities = selectedRarityArray(),
        })
    end)
end
local purchasedOfferIds = {}
if CrateRollEffect and CrateRollPurchaseRequest then
    CrateRollEffect.OnClientEvent:Connect(function(data)
        if type(data) ~= "table" then return end
        if not Toggles.AutoRoll or not Toggles.AutoRoll.Value then return end
        if data.action == "showOffers" and type(data.offers) == "table" then
            if data.ownerUserId ~= LocalPlayer.UserId then return end
            for _, offer in ipairs(data.offers) do
                if type(offer) == "table" and offer.offerId then
                    local rarity = offer.rarity
                    local shouldPurchase = false
                    if Toggles.RollAutoPurchase and Toggles.RollAutoPurchase.Value then
                        if next(selectedRarities) == nil or selectedRarities[rarity] then
                            shouldPurchase = true
                        end
                    end
                    if shouldPurchase then
                        if not purchasedOfferIds[offer.offerId] then
                            purchasedOfferIds[offer.offerId] = true
                            pcall(function()
                                CrateRollPurchaseRequest:FireServer(offer.offerId)
                            end)
                            task.delay(10, function()
                                purchasedOfferIds[offer.offerId] = nil
                            end)
                        end
                    end
                end
            end
        end
    end)
end
local function refreshAutoRoll()
    if Toggles.AutoRoll.Value then
        sendAutoRoll("settings")
    end
end
local function firePromptsByTheme(theme, filter, tpToPrompts)
    local plot = getPlot()
    if not plot then
        return
    end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local oldCFrame = hrp and hrp.CFrame
    local didTeleport = false
    local prompts = {}
    for _, descendant in ipairs(plot:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.Name == "__LocalPrompt_" .. theme then
            table.insert(prompts, descendant)
        end
    end
    for _, descendant in ipairs(prompts) do
        if Library.Unloaded then
            break
        end
        if descendant:IsDescendantOf(workspace) and descendant.Parent then
            local part = descendant.Parent
            if part:IsA("Attachment") then
                part = part.Parent
            end
            if not filter or (part and filter(part, descendant)) then
                if tpToPrompts and hrp and part and part:IsA("BasePart") then
                    local dist = (hrp.Position - part.Position).Magnitude
                    if dist > descendant.MaxActivationDistance then
                        hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                        hrp.AssemblyLinearVelocity = Vector3.new()
                        task.wait(0.1)
                        didTeleport = true
                    end
                end
                if descendant:IsDescendantOf(workspace) then
                    pcall(fireproximityprompt, descendant)
                    task.wait(0.08)
                end
            end
        end
    end
    if didTeleport and hrp and oldCFrame then
        hrp.CFrame = oldCFrame
        hrp.AssemblyLinearVelocity = Vector3.new()
        task.wait(0.1)
    end
end
local function seedTools(includeAll)
    local tools = {}
    local containers = { LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character }
    for _, container in ipairs(containers) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") then
                    local seedId = item:GetAttribute(SEED_ID_ATTR)
                    if type(seedId) == "string" and seedId ~= "" then
                        if includeAll or selectedSeeds[seedId] then
                            tools[#tools + 1] = item
                        end
                    end
                end
            end
        end
    end
    return tools
end
local function unlockedGridParts(plot)
    local parts = {}
    for _, folderName in ipairs({ "StarterArea", "GridAreas" }) do
        local folder = plot:FindFirstChild(folderName)
        if folder then
            for _, part in ipairs(folder:GetChildren()) do
                if part:IsA("BasePart") and part:GetAttribute("GridUnlocked") == true then
                    parts[#parts + 1] = part
                end
            end
        end
    end
    return parts
end
local function plantCFrames(plot, parts)
    local positions = {}
    for _, model in ipairs(plot:GetChildren()) do
        if model:IsA("Model") and model:GetAttribute(FEED_CLASS_ATTR) ~= nil then
            local ok, cframe = pcall(function()
                return (model:GetBoundingBox())
            end)
            if ok and cframe then
                positions[#positions + 1] = cframe.Position
            end
        end
    end
    local cframes = {}
    for _, part in ipairs(parts) do
        for _, x in ipairs({ -5, 0, 5 }) do
            for _, z in ipairs({ -5, 0, 5 }) do
                local cframe = part.CFrame * CFrame.new(x, part.Size.Y / 2 + 1.5, z)
                local available = true
                for _, position in ipairs(positions) do
                    if Vector2.new(cframe.Position.X - position.X, cframe.Position.Z - position.Z).Magnitude < 4.5 then
                        available = false
                        break
                    end
                end
                if available then
                    cframes[#cframes + 1] = cframe
                end
            end
        end
    end
    return cframes
end
local function doPlant(includeAll)
    if not PlaceFeedMachine then
        return
    end
    local plot = getPlot()
    if not plot then
        return
    end
    local tools = seedTools(includeAll)
    if #tools == 0 then
        return
    end
    local parts = unlockedGridParts(plot)
    if #parts == 0 then
        return
    end
    local cframes = plantCFrames(plot, parts)
    if #cframes == 0 then
        return
    end
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then
        return
    end
    local cframeIndex = 1
    for _, tool in ipairs(tools) do
        if Library.Unloaded or not (Toggles.AutoPlant.Value or Toggles.AutoPlantAll.Value) then
            return
        end
        local guid = tool:GetAttribute(TOOL_GUID_ATTR)
        if type(guid) == "string" and guid ~= "" then
            pcall(function()
                humanoid:EquipTool(tool)
            end)
            task.wait(0.1)
            while tool.Parent and cframes[cframeIndex] do
                if Library.Unloaded or not (Toggles.AutoPlant.Value or Toggles.AutoPlantAll.Value) then
                    return
                end
                local cframe = cframes[cframeIndex]
                cframeIndex = cframeIndex + 1
                pcall(function()
                    PlaceFeedMachine:FireServer(nextNonce(), cframe, guid)
                end)
                task.wait(0.3)
            end
            pcall(function()
                if tool.Parent == character then
                    humanoid:UnequipTools()
                end
            end)
            task.wait(Options.PlantDelay.Value or 0.5)
        end
    end
end
local function doCollectPetMoney()
    local plot = getPlot()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not plot or not root then
        return
    end
    if not beginMovement() then
        return
    end
    local oldCFrame = root.CFrame
    local moved = false
    for _, pet in ipairs(plot:GetChildren()) do
        if Library.Unloaded or not Toggles.AutoCollectPetMoney.Value then
            break
        end
        if pet:IsA("Model") and pet:GetAttribute("PetIndex") ~= nil
            and (tonumber(pet:GetAttribute("Money")) or 0) >= (petMoneyThresholds[petKey(pet)] or 1000) then
            root.CFrame = pet:GetPivot() + Vector3.new(0, 2, 0)
            root.AssemblyLinearVelocity = Vector3.new()
            task.wait(0.2)
            moved = true
        end
    end
    if moved and root.Parent then
        root.CFrame = oldCFrame
        root.AssemblyLinearVelocity = Vector3.new()
    end
    endMovement()
end
local function treeModels(plot)
    local trees = {}
    for _, model in ipairs(plot:GetChildren()) do
        if model:IsA("Model") then
            if model:FindFirstChild("LeafShake", true) or string.find(model.Name, "Tree") then
                trees[#trees + 1] = model
            end
        end
    end
    return trees
end
local function doShake()
    if not TreeClicker then
        return
    end
    local plot = getPlot()
    if not plot then
        return
    end
    local shakes = math.floor(tonumber(Options.ShakeCount.Value) or 3)
    for _, tree in ipairs(treeModels(plot)) do
        if Library.Unloaded or not Toggles.AutoShake.Value then
            return
        end
        for _ = 1, shakes do
            if Library.Unloaded or not Toggles.AutoShake.Value then
                return
            end
            pcall(function()
                TreeClicker:FireServer(tree)
            end)
            task.wait(0.05)
        end
    end
end
local function doHarvest()
    local plot = getPlot()
    if not plot or not PromptInteract then
        return
    end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and not beginMovement() then
        return
    end
    local oldCFrame = root and root.CFrame
    local moved = false
    local function collect(action, target)
        if root then
            root.CFrame = target.CFrame + Vector3.new(0, 3, 0)
            root.AssemblyLinearVelocity = Vector3.new()
            task.wait(0.1)
            moved = true
        end
        pcall(function()
            PromptInteract:FireServer(action, target, false)
        end)
        task.wait(0.15)
    end
    for _, descendant in ipairs(plot:GetDescendants()) do
        if Library.Unloaded then
            break
        end
        if Toggles.HarvestPatches.Value
            and descendant:IsA("ProximityPrompt")
            and descendant.Name == "__LocalPrompt_PatchHarvest"
            and descendant.Parent
            and descendant.Parent:IsA("Attachment")
            and descendant.Parent.Parent
            and descendant.Parent.Parent:IsA("BasePart") then
            collect("PatchHarvest", descendant.Parent.Parent)
        elseif Toggles.HarvestTreeGround.Value
            and descendant:IsA("BasePart")
            and descendant:GetAttribute(TREE_GROUND_PILE_ATTR) == true
            and descendant:GetAttribute(TREE_LOCAL_VISUAL_ATTR) ~= true
            and descendant:GetAttribute(TREE_SLOT_INDEX_ATTR) ~= nil
            and descendant:GetAttribute(FOOD_ID_ATTR) ~= nil then
            collect("TreeGroundPickup", descendant)
        end
    end
    if moved and root and oldCFrame then
        root.CFrame = oldCFrame
        root.AssemblyLinearVelocity = Vector3.new()
    end
    if root then
        endMovement()
    end
end
local function doFeed()
    firePromptsByTheme("PetFeed")
end
local function doUpgrades()
    for _, name in ipairs(UPGRADE_NAMES) do
        if Library.Unloaded or not Toggles.AutoUpgrade.Value then
            return
        end
        if selectedUpgrades[name] then
            if name == "Roll Luck" and RollLuckUpgrade then
                pcall(function()
                    RollLuckUpgrade:FireServer(nextNonce())
                end)
            elseif name == "Roll Drop Area" and RollDropAreaUpgrade then
                pcall(function()
                    RollDropAreaUpgrade:FireServer(nextNonce())
                end)
            end
            task.wait(0.15)
        end
    end
end
local function doRebirth()
    if RebirthRemote then
        pcall(function()
            RebirthRemote:FireServer(nextNonce())
        end)
    end
end
local function doBuyGears()
    if not GearPurchase then
        return
    end
    for _, id in ipairs(GEAR_IDS) do
        if Library.Unloaded or not Toggles.AutoBuyGears.Value then
            return
        end
        if selectedGears[id] then
            pcall(function()
                GearPurchase:FireServer(nextNonce(), id)
            end)
            task.wait(0.15)
        end
    end
end
local function doBuyCosmetics()
    if not CosmeticPurchase then
        return
    end
    for _, id in ipairs(COSMETIC_IDS) do
        if Library.Unloaded or not Toggles.AutoBuyCosmetics.Value then
            return
        end
        if selectedCosmetics[id] then
            pcall(function()
                CosmeticPurchase:FireServer(nextNonce(), id)
            end)
            task.wait(0.15)
        end
    end
end
local function doExpand()
    local plot = getPlot()
    if not plot or not PromptInteract then
        return
    end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and not beginMovement() then
        return
    end
    local oldCFrame = root and root.CFrame
    local moved = false
    for _, part in ipairs(plot:GetDescendants()) do
        if Library.Unloaded or not Toggles.AutoExpand.Value then
            break
        end
        if part:IsA("BasePart") and part:GetAttribute(GRID_PURCHASABLE_ATTR) == true then
            if root then
                root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                root.AssemblyLinearVelocity = Vector3.new()
                task.wait(0.1)
                moved = true
            end
            pcall(function()
                PromptInteract:FireServer("GridPartUnlock", part, false)
            end)
            task.wait(0.15)
        end
    end
    if moved and root and oldCFrame then
        root.CFrame = oldCFrame
        root.AssemblyLinearVelocity = Vector3.new()
    end
    if root then
        endMovement()
    end
end
local function moveToRollButton()
    local plot = getPlot()
    if not plot then
        return nil
    end
    local prompt
    for _, descendant in ipairs(plot:GetDescendants()) do
        if descendant.Name == "__LocalPrompt_CrateRoll" and descendant:IsA("ProximityPrompt") then
            prompt = descendant
            break
        end
    end
    local button = prompt and prompt.Parent and prompt.Parent.Parent
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and not beginMovement() then
        return nil
    end
    if button and button:IsA("BasePart") and root then
        if (root.Position - button.Position).Magnitude > 6 then
            root.CFrame = button.CFrame + Vector3.new(0, 3, 0)
            root.AssemblyLinearVelocity = Vector3.new()
            task.wait(0.15)
        end
    end
    if root then
        endMovement()
    end
    return prompt
end
local function doManualAutoRoll()
    local prompt = moveToRollButton()
    if prompt and prompt.Parent then
        pcall(fireproximityprompt, prompt)
    end
end
local Window = Library:CreateWindow({
    Title = "Build a Pet Farm",
    Footer = "Tempo Hub",
    Size = UDim2.fromOffset(940, 660),
    ShowCustomCursor = false,
})
Library.ShowCustomCursor = false
local Tabs = {
    Farm = Window:AddTab("Farm", "sprout"),
    Roll = Window:AddTab("Roll", "dices"),
    Shop = Window:AddTab("Shop", "shopping-cart"),
    Settings = Window:AddTab("Settings", "settings"),
}
local function AddDiscordButton(Tab)
    Tab:AddLeftGroupbox("Discord"):AddButton({
        Text = "Join Discord For Dupe",
        Func = copyDiscord,
    })
end
for _, Tab in Tabs do
    AddDiscordButton(Tab)
end
local PlantGroup = Tabs.Farm:AddLeftGroupbox("Auto Plant", "shovel")
PlantGroup:AddToggle("AutoPlant", {
    Text = "Auto Plant",
    Default = false,
})
PlantGroup:AddToggle("AutoPlantAll", {
    Text = "Auto Plant All",
    Default = false,
})
PlantGroup:AddDropdown("PlantSeeds", {
    Text = "Seeds To Plant",
    Values = SEED_IDS,
    Default = {},
    Multi = true,
    AllowNull = true,
    Searchable = true,
    Callback = function(value)
        selectedSeeds = selectedSet(value)
    end,
})
PlantGroup:AddSlider("PlantDelay", {
    Text = "Plant Delay",
    Default = 0.5,
    Min = 0.2,
    Max = 5,
    Rounding = 1,
})
PlantGroup:AddSlider("PlantLoopDelay", {
    Text = "Loop Delay",
    Default = 1,
    Min = 0.5,
    Max = 10,
    Rounding = 1,
})
local ShakeGroup = Tabs.Farm:AddLeftGroupbox("Auto Shake Trees", "wind")
ShakeGroup:AddToggle("AutoShake", {
    Text = "Auto Shake Trees",
    Default = false,
})
ShakeGroup:AddSlider("ShakeCount", {
    Text = "Shakes Per Tree",
    Default = 3,
    Min = 1,
    Max = 20,
    Rounding = 0,
})
ShakeGroup:AddSlider("ShakeDelay", {
    Text = "Loop Delay",
    Default = 0.5,
    Min = 0.2,
    Max = 10,
    Rounding = 1,
})
local HarvestGroup = Tabs.Farm:AddRightGroupbox("Auto Harvest", "hand")
HarvestGroup:AddToggle("HarvestPatches", {
    Text = "Harvest Patches",
    Default = false,
})
HarvestGroup:AddToggle("HarvestTreeGround", {
    Text = "Collect Tree Fruit",
    Default = false,
})
HarvestGroup:AddSlider("HarvestDelay", {
    Text = "Loop Delay",
    Default = 0.5,
    Min = 0.2,
    Max = 10,
    Rounding = 1,
})
local FeedGroup = Tabs.Farm:AddRightGroupbox("Auto Feed", "bone")
FeedGroup:AddToggle("AutoFeed", {
    Text = "Auto Feed Pets",
    Default = false,
})
FeedGroup:AddSlider("FeedDelay", {
    Text = "Loop Delay",
    Default = 0.5,
    Min = 0.2,
    Max = 10,
    Rounding = 1,
})
local PetMoneyGroup = Tabs.Farm:AddRightGroupbox("Pet Money", "coins")
PetMoneyGroup:AddToggle("AutoCollectPetMoney", {
    Text = "Auto Collect Money From Pets",
    Default = false,
})
PetMoneyGroup:AddSlider("PetMoneyDelay", {
    Text = "Loop Delay",
    Default = 2,
    Min = 0.5,
    Max = 15,
    Rounding = 1,
})
local petMoneySliderIds = {}
local petAddedConnection
local function addPetMoneySlider(pet)
    if not pet:IsA("Model") or pet:GetAttribute("PetIndex") == nil then
        return
    end
    local key = petKey(pet)
    if petMoneySliderIds[key] then
        return
    end
    petMoneySliderIds[key] = true
    petMoneyThresholds[key] = petMoneyThresholds[key] or 1000
    local nickname = pet:GetAttribute("PetNickname")
    local name = type(nickname) == "string" and nickname ~= "" and (pet.Name .. " (" .. nickname .. ")") or pet.Name
    PetMoneyGroup:AddSlider("PetMoneyThreshold_" .. key, {
        Text = name .. " - Collect at This Amount",
        Default = petMoneyThresholds[key],
        Min = 0,
        Max = 1000000,
        Rounding = 0,
        Callback = function(value)
            petMoneyThresholds[key] = tonumber(value) or 1000
        end,
    })
end
local petPlot = getPlot()
if petPlot then
    for _, pet in ipairs(petPlot:GetChildren()) do
        addPetMoneySlider(pet)
    end
    petAddedConnection = petPlot.ChildAdded:Connect(addPetMoneySlider)
end
local ExpandGroup = Tabs.Farm:AddRightGroupbox("Auto Expand", "maximize")
ExpandGroup:AddToggle("AutoExpand", {
    Text = "Auto Expand Farm",
    Default = false,
})
ExpandGroup:AddSlider("ExpandDelay", {
    Text = "Loop Delay",
    Default = 2,
    Min = 0.5,
    Max = 15,
    Rounding = 1,
})
local RollGroup = Tabs.Roll:AddLeftGroupbox("Auto Roll", "dices")
RollGroup:AddToggle("AutoRoll", {
    Text = "Auto Roll",
    Default = false,
    Callback = function(state)
        if state then
            task.spawn(function()
                moveToRollButton()
                if Toggles.AutoRoll.Value then
                    sendAutoRoll("start")
                end
            end)
        else
            sendAutoRoll("stop")
        end
    end,
})
RollGroup:AddToggle("RollAutoPurchase", {
    Text = "Auto Purchase Rolled",
    Default = false,
    Callback = refreshAutoRoll,
})
RollGroup:AddDropdown("RollRarities", {
    Text = "Rarities To Keep",
    Values = RARITIES,
    Default = {},
    Multi = true,
    AllowNull = true,
    Searchable = true,
    Callback = function(value)
        selectedRarities = selectedSet(value)
        refreshAutoRoll()
    end,
})
local UpgradeGroup = Tabs.Roll:AddRightGroupbox("Auto Upgrades", "trending-up")
UpgradeGroup:AddToggle("AutoUpgrade", {
    Text = "Auto Upgrade",
    Default = false,
})
UpgradeGroup:AddDropdown("Upgrades", {
    Text = "Upgrades To Buy",
    Values = UPGRADE_NAMES,
    Default = {},
    Multi = true,
    AllowNull = true,
    Searchable = true,
    Callback = function(value)
        selectedUpgrades = selectedSet(value)
    end,
})
UpgradeGroup:AddSlider("UpgradeDelay", {
    Text = "Loop Delay",
    Default = 1,
    Min = 0.3,
    Max = 10,
    Rounding = 1,
})
local RebirthGroup = Tabs.Roll:AddRightGroupbox("Auto Rebirth", "rotate-ccw")
RebirthGroup:AddToggle("AutoRebirth", {
    Text = "Auto Rebirth",
    Default = false,
})
RebirthGroup:AddSlider("RebirthDelay", {
    Text = "Loop Delay",
    Default = 2,
    Min = 0.5,
    Max = 15,
    Rounding = 1,
})
local GearGroup = Tabs.Shop:AddLeftGroupbox("Auto Buy Gears", "wrench")
GearGroup:AddToggle("AutoBuyGears", {
    Text = "Auto Buy Gears",
    Default = false,
})
GearGroup:AddDropdown("Gears", {
    Text = "Gears To Buy",
    Values = GEAR_IDS,
    Default = {},
    Multi = true,
    AllowNull = true,
    Searchable = true,
    Callback = function(value)
        selectedGears = selectedSet(value)
    end,
})
GearGroup:AddSlider("GearDelay", {
    Text = "Loop Delay",
    Default = 2,
    Min = 0.5,
    Max = 15,
    Rounding = 1,
})
local CosmeticGroup = Tabs.Shop:AddRightGroupbox("Auto Buy Cosmetics", "palette")
CosmeticGroup:AddToggle("AutoBuyCosmetics", {
    Text = "Auto Buy Cosmetics",
    Default = false,
})
CosmeticGroup:AddDropdown("Cosmetics", {
    Text = "Cosmetics To Buy",
    Values = COSMETIC_IDS,
    Default = {},
    Multi = true,
    AllowNull = true,
    Searchable = true,
    Callback = function(value)
        selectedCosmetics = selectedSet(value)
    end,
})
CosmeticGroup:AddSlider("CosmeticDelay", {
    Text = "Loop Delay",
    Default = 2,
    Min = 0.5,
    Max = 15,
    Rounding = 1,
})
local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddLabel("UI Keybind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "UI Keybind",
})
local antiAfkConnection
MenuGroup:AddToggle("AntiAfk", {
    Text = "Anti-AFK",
    Default = true,
    Callback = function(state)
        if state then
            if not antiAfkConnection then
                antiAfkConnection = LocalPlayer.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        elseif antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
        end
    end,
})
MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)
Library.ToggleKeybind = Options.MenuKeybind
Library:OnUnload(function()
    if Toggles.AutoRoll.Value then
        sendAutoRoll("stop")
    end
    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end
    if petAddedConnection then
        petAddedConnection:Disconnect()
        petAddedConnection = nil
    end
    select("#", "Build a Pet Farm unloaded")
end)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Mint")
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/BuildAPetFarm")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
ThemeManager:LoadDefault()
SaveManager:LoadAutoloadConfig()
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoPlant.Value or Toggles.AutoPlantAll.Value then
            doPlant(Toggles.AutoPlantAll.Value)
        end
        task.wait(Options.PlantLoopDelay.Value or 1)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoShake.Value then
            doShake()
        end
        task.wait(Options.ShakeDelay.Value or 0.5)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.HarvestPatches.Value or Toggles.HarvestTreeGround.Value then
            doHarvest()
        end
        task.wait(Options.HarvestDelay.Value or 0.5)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoFeed.Value then
            doFeed()
        end
        task.wait(Options.FeedDelay.Value or 0.5)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoCollectPetMoney.Value then
            doCollectPetMoney()
        end
        task.wait(Options.PetMoneyDelay.Value or 2)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoExpand.Value then
            doExpand()
        end
        task.wait(Options.ExpandDelay.Value or 2)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoUpgrade.Value then
            doUpgrades()
        end
        task.wait(Options.UpgradeDelay.Value or 1)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoRebirth.Value then
            doRebirth()
        end
        task.wait(Options.RebirthDelay.Value or 2)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoBuyGears.Value then
            doBuyGears()
        end
        task.wait(Options.GearDelay.Value or 2)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoBuyCosmetics.Value then
            doBuyCosmetics()
        end
        task.wait(Options.CosmeticDelay.Value or 2)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoRoll and Toggles.AutoRoll.Value then
            doManualAutoRoll()
        end
        task.wait(1.5)
    end
end)
Library:Notify("Build a Pet Farm loaded")
end)(...)

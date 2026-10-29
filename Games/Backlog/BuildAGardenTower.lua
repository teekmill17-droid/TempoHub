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
getgenv().TempoHoodSubtitle = "BUILD A GARDEN TOWER"
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
local tE_14, tE_17
local tE_22_1, tE_22_9
local VariationUtility
local nf
local mU
local mf
local ni
local mi
local nl
local m_
local ml
local Label
local mH
local mo
local m5
local l5
local mE
local m8
local l8
local mQ
local mx
local IngredientShopRemote
local mb
local mT
local connection
local mD
local mZ
local mG
local mn
local mJ
local l4
local m4
local na
local mS
local nd
local GridUtility
local mz
local ng
local mV
local mY
local mC
local connection2
local mF
local m0
local mI
local m3
local l6
local m9
local ms
local Options
local nc
local mR
local function fn23(bc)
    if mI.Unloaded then
        return false
    end
    local oH = mz[bc]
    return oH ~= nil and oH.Value == true
end
local function fn40()
    local Character = m5.Character
    local pa = Character and Character:FindFirstChildWhichIsA("Humanoid")
    return pa
end
local function fn53(br)
    local oU = mF(br, {})
    if typeof(oU) ~= "table" then
        return {}
    end
    local oV = {}
    for k, v in pairs(oU) do
        if v == true then
            oV[k] = true
        else
            local oU_1 = typeof(k) == "number" and typeof(v) == "string"
            if oU_1 then
                oV[v] = true
            end
        end
    end
    return oV
end
local function worker6()
    while not mI.Unloaded do
        task.wait(0.5)
        if mY("AutoBuySeeds") then
            pcall(nf)
            task.wait(mn("BuySeedsDelay", 0.4))
        end
    end
end
local function worker()
    local s2_1
    while true do
        task.wait(1)
        if mI.Unloaded then
            break
        end
        local s1 = math.floor(os.clock() - mJ)
        if s1 < 60 then
            s2_1 = s1 .. "s"
        elseif s1 < 3600 then
            s2_1 = string.format("%dm %ds", math.floor((s1) / (60)), s1 % 60)
        else
            s2_1 = string.format("%dh %dm", math.floor((s1) / (3600)), math.floor((s1 % 3600) / (60)))
        end
        Label:SetText(l5("Session time", s2_1, m3))
    end
end
local function onOnClientEvent(cl)
    if typeof(cl) ~= "table" then
        return
    end
    if cl.eventType == "placementSync" then
        mi(cl.items)
    elseif cl.eventType == "placementAdded" then
        local floorIndex = cl.floorIndex
        local pX_1 = mD(cl.center)
        local pY = mD(cl.size)
        if floorIndex and pX_1 and pY then
            local p__1 = ml[floorIndex] or {}
            ml[floorIndex] = p__1
            local pZ_2 = ml[floorIndex]
            local p__2 = cl.uid
            local p3 = if p__2 then 1 else 0
            local p1 = 3936 * p3 + 1825 * (1 - p3)
            local p2 = 276 * p3 + 1981 * (1 - p3)
            if not ((p1 * 1856 + p2 * 393 + p1 * p2) % 16777213 == 8500020) then
                p__2 = tostring(pX_1)
            end
            pZ_2[p__2] = { center = pX_1, size = pY }
        end
    elseif cl.eventType == "placementRemoved" then
        local floorIndex = cl.floorIndex
        if floorIndex and ml[floorIndex] and cl.uid then
            ml[floorIndex][cl.uid] = nil
        end
    end
end
local function fn102(aw, ax)
    return aw.price < ax.price
end
local function fn132(a0, a1)
    return string.format('<font color="%s">%s</font>', a1, a0)
end
local function fn136(gV)
    local DiscordGroup = gV:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = ms })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = ms })
end
local function fn139(dd)
    local qR = VariationUtility.parseName(dd.Name)
    local qS = mC[qR]
    return qS and (qS.sell_price or 0) or 0
end
local function fn147(a3, a4, a5)
    return string.format("<b>%s</b> %s %s", a3, mf("-", "#5a6070"), mf(a4, a5))
end
local function fn160(bC, bD)
    if not m4(bC) then
        return true
    end
    return l8(bC)[bD] == true
end
local function fn170()
    connection:Disconnect()
    connection2:Disconnect()
end
local function fn194(c0, c1, c2)
    local qB, qC, qD, qE, qH, qI, qJ, qK, qM, qN, qO, qP
    local qG = 9
    while true do
        local qG_1 = 6847 - qG
        do
            if qG_1 < 6840 then
                if qG_1 < 6837 then
                    if qG_1 < 6836 then
                        if qG_1 < 6835 then
                            if qG_1 == 6834 then
                                qG = 6
                            else
                                break
                            end
                        elseif qG_1 == 6835 then
                            qP = qO
                            qG = 1
                        else
                            qG = 7096
                            continue
                        end
                    elseif qG_1 == 6836 then
                        qO += qN
                        qG = 0
                    else
                        qG = 6841
                        continue
                    end
                elseif qG_1 < 6839 then
                    if qG_1 < 6838 then
                        return qB.Position
                    end
                    qB = math.floor(c0.Size.X / 2) - math.ceil(c2.X / 2)
                    qC = math.floor(c0.Size.Z / 2) - math.ceil(c2.Z / 2)
                    qD = math.max(1, math.floor(c2.X + 0.5))
                    qE = ni(c1)
                    qJ = -qB
                    qH = qB
                    qI = qD
                    qG = 3
                else
                    qG = 11
                end
            elseif qG_1 < 6847 then
                if qG_1 < 6844 then
                    if qG_1 < 6841 then
                        qB = -qC
                        qO = qB
                        qM = qC
                        qN = qD
                        qG = 0
                    elseif qG_1 < 6842 then
                        if qG_1 == 6841 then
                            qJ += qI
                            qG = 3
                        else
                            qG = 6847
                            continue
                        end
                    elseif qG_1 < 6843 then
                        return nil
                    elseif qG_1 == 6843 then
                        qK = qJ
                        qG = 7
                    else
                        qG = 6846
                        continue
                    end
                elseif qG_1 < 6845 then
                    if qG_1 == 6844 then
                        qG = if qI > 0 and qJ <= qH or qI <= 0 and qJ >= qH then 4 else 5
                    else
                        qG = 6842
                        continue
                    end
                elseif qG_1 < 6846 then
                    break
                else
                    qB = GridUtility.snapPosition(CFrame.new(qK, 0, qP), 1, c2)
                    qG = if GridUtility.validPlacement(qB, c2, c0.Size, qE) then 10 else 8
                end
            elseif qG_1 < 7096 then
                if qG_1 == 6847 then
                    qG = if qN > 0 and qO <= qM or qN <= 0 and qO >= qM then 12 else 13
                else
                    break
                end
            else
                break
            end
        end
    end
end
local function fn200(bn, bo)
    local oP = (tonumber(mF(bn, bo)))
    local oT = if oP then 1 else 0
    local oR = 1873 * oT + 3124 * (1 - oT)
    local oS = 2673 * oT + 3522 * (1 - oT)
    if not ((oR * 2417 + oS * 1394 + oR * oS) % 16777213 == 13259732) then
        oP = bo
    end
    return oP
end
local function fn206()
    local rr = mV()
    if not rr then
        return
    end
    local CrateStack = rr:FindFirstChild("CrateStack")
    local rr_1 = not CrateStack or not CrateStack:FindFirstChild("StackCrate")
    if rr_1 then
        return
    end
    local rr_2 = mH()
    if not rr_2 then
        return
    end
    local rt = CrateStack:FindFirstChild("Base") and CrateStack.Base:FindFirstChild("thing") and CrateStack.Base.thing:FindFirstChild("PickupPrompt")
    local rs_1 = rt
    if rt then
        rt = rs_1.Parent
    end
    if rt then
        rt = rs_1.Parent:IsA("BasePart")
    end
    if rt then
        rr_2.CFrame = rs_1.Parent.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.12)
    end
    pcall(function()
        mS:FireServer({ event_type = "pickup" })
    end)
    task.wait(0.35)
    if na() then
        pcall(function()
            mS:FireServer({ event_type = "sell" })
        end)
    end
end
local function onRscripts()
    mE(mU, "Copied Rscripts profile to clipboard")
end
local function onInputBegan()
    nc = tick()
end
local function worker5()
    while not mI.Unloaded do
        task.wait(0.6)
        if mY("AutoBuyPets") then
            pcall(mb)
            task.wait(mn("BuyPetsDelay", 0.45))
        end
    end
end
local function fn334()
    local Character = m5.Character
    local o7 = Character and Character:FindFirstChild("HumanoidRootPart")
    return o7
end
local function fn350(b6)
    local pD_1
    local pC_1
    local pB_1
    if typeof(b6) == "Vector3" then
        return b6
    elseif typeof(b6) == "string" then
        pD_1, pB_1, pC_1 = string.match(b6, "([^,]+),%s*([^,]+),%s*([^,]+)")
        if pD_1 and pB_1 and pC_1 then
            return Vector3.new(tonumber(pD_1), tonumber(pB_1), tonumber(pC_1))
        end
        return nil
    else
        return nil
    end
end
local function fn356(bi, bj)
    local oK = Options[bi]
    if oK == nil then
        return bj
    end
    return oK.Value
end
local function fn363()
    mE(mZ, "Copied Discord invite to clipboard")
end
local function worker9()
    while not mI.Unloaded do
        task.wait(0.35)
        if mY("AutoCollectCrates") then
            pcall(mR)
            task.wait(mn("CollectCratesDelay", 0.75))
        end
    end
end
local function onCopyJoinScript_JobID()
    local hb = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, m0)
    mE(hb, "Copied join script to clipboard")
end
local function fn424()
    pcall(function()
        m_:FireServer({ eventType = "requestSync" })
    end)
end
local function worker11()
    while not mI.Unloaded do
        task.wait(2)
        if mY("AntiAfk") then
            local tv = tick() - nc
            local tw = tick() - m8
            if tv >= 300 and tw >= 60 then
                pcall(mQ)
            else
                if tv < 300 and tw >= 300 then
                    pcall(mQ)
                end
            end
        end
    end
end
local function fn461()
    local sY_1
    local sX_1
    if identifyexecutor then
        sY_1, sX_1 = identifyexecutor()
        local sZ = sY_1 ~= ""
        local s_ = type(sY_1) == "string" and sZ
        if s_ then
            local sZ_1 = type(sX_1) == "string" and sX_1 ~= "" and sY_1 .. " " .. sX_1
            l4 = sZ_1 or sY_1
        end
    end
end
local function fn493(aU, aV)
    if setclipboard then
        setclipboard(aU)
    elseif toclipboard then
        toclipboard(aU)
    end
    mI:Notify(aV)
end
local function fn525(cH)
    local qc = {}
    local qe = ml[cH] or {}
    for k, v in pairs(qe) do
        table.insert(qc, v)
    end
    return qc
end
local function fn541(am, an)
    if am.order == an.order then
        if am.price == an.price then
            return am.name < an.name
        end
        return am.price < an.price
    end
    return am.order < an.order
end
local function worker10()
    while not mI.Unloaded do
        task.wait(0.25)
        local s7 = mY("AutoCollectPlants") and not na()
        if s7 then
            pcall(mG)
            task.wait(mn("CollectPlantsDelay", 0.35))
        end
    end
end
local function fn549(cN)
    local qm = { m5.Backpack }
    if m5.Character then
        table.insert(qm, m5.Character)
    end
    for i, v in ipairs(qm) do
        for i, child in v:GetChildren() do
            local qm_1 = child:IsA("Tool") and child:GetAttribute("placeable") == true
            if qm_1 then
                local qm_2 = VariationUtility.parseName(child.Name)
                local qn = mC[qm_2] and mT(cN, qm_2)
                if qn then
                    return child, qm_2
                end
            end
        end
    end
    return nil
end
local function worker4()
    while not mI.Unloaded do
        task.wait(0.6)
        if mY("AutoBuyCosmetics") then
            pcall(mo)
            task.wait(mn("BuyCosmeticsDelay", 0.45))
        end
    end
end
local function worker8()
    while not mI.Unloaded do
        task.wait(0.35)
        local ta = mY("AutoPlaceSeeds") and not na()
        if ta then
            pcall(nl)
            task.wait(mn("PlaceSeedsDelay", 0.35))
        end
    end
end
local function fn608(bz)
    return next(l8(bz)) ~= nil
end
local function onInputChanged(iu)
    local UserInputType = iu.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        nc = tick()
    end
end
local function worker7()
    while not mI.Unloaded do
        task.wait(0.5)
        local tc = mY("AutoSell") and not na()
        if tc then
            pcall(l6)
            task.wait(mn("SellDelay", 1))
        end
    end
end
local function worker2()
    while not mI.Unloaded do
        task.wait(0.5)
        if mY("AutoBuyFloorUpgrades") then
            pcall(mx)
            task.wait(mn("FloorUpgradesDelay", 0.35))
        end
    end
end
local function fn666()
    local player_info = m5:FindFirstChild("player_info")
    local pd = player_info
    if pd then
        local pe = player_info:GetAttribute("Cash") or 0
        pd = pe
    end
    return pd or 0
end
local function worker3()
    while not mI.Unloaded do
        task.wait(0.75)
        if mY("AutoUpgradeFloor") then
            pcall(ng)
            task.wait(mn("UpgradeFloorDelay", 2))
        end
    end
end
local function fn688(cc)
    ml = {}
    if typeof(cc) ~= "table" then
        return
    end
    for k, v in cc do
        local floorIndex = v.floorIndex
        local pL = mD(v.center)
        local pM = mD(v.size)
        if floorIndex and pL and pM then
            local pO_1 = ml[floorIndex] or {}
            ml[floorIndex] = pO_1
            local pN_2 = ml[floorIndex]
            local pO_2 = v.uid or tostring(pL)
            pN_2[pO_2] = { center = pL, size = pM }
        end
    end
end
local function fn690()
    local Plots = m9:FindFirstChild("Plots")
    if not Plots then
        return nil
    end
    for i, child in Plots:GetChildren() do
        if child:GetAttribute("Owner_id") == m5.UserId then
            return child
        end
    end
    return nil
end
local function fn738()
    local CurrentCamera = m9.CurrentCamera
    if not CurrentCamera then
        return
    end
    nd:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    nd:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    m8 = tick()
end
local function fn742()
    local player_info = m5:FindFirstChild("player_info")
    local pk = player_info
    if pk then
        local pl = player_info:GetAttribute("OwnedFloors") or 1
        pk = pl
    end
    return pk or 1
end
local function fn758()
    local Character = m5.Character
    local po = Character ~= nil and Character:GetAttribute("CarryingCrates") == true
    return po
end
local function fn795(aG, aH)
    return aG.price < aH.price
end
local function onUnload()
    mI:Unload()
end
local function fn836()
    IngredientShopRemote:FireServer({ event_type = "request_shop_data" })
end
l4 = nil
l5 = nil
l6 = nil
l8 = nil
VariationUtility = nil
mb = nil
GridUtility = nil
mf = nil
connection2 = nil
mi = nil
ml = nil
mn = nil
mo = nil
ms = nil
Options = nil
mx = nil
mz = nil
connection = nil
mC = nil
mD = nil
mE = nil
mF = nil
mG = nil
mH = nil
mI = nil
mJ = nil
mQ = nil
mR = nil
local l7, ma, mc, me, GlobalVariables, mj, mk, mm, FloorUpgradeData, mq, mr, mt, CosmeticData, mw, my, mB, PlotServiceRemote, mL, mM, mN, mO, mP
mS = nil
mT = nil
mU = nil
mV = nil
mY = nil
mZ = nil
m_ = nil
m0 = nil
Label = nil
m3 = nil
m4 = nil
m5 = nil
m8 = nil
m9 = nil
na = nil
nc = nil
nd = nil
IngredientShopRemote = nil
nf = nil
ng = nil
ni = nil
nl = nil
local mW, mX, m1, CosmeticShopFunction, m7, nb, IngredientShopFunction, nj, nk, nr, ns, nt, nu, nv, nw, nx, ny, nz, nA, nB, nC, nD, nE
local nq_1
mW = nil
mX = nil
m1 = nil
CosmeticShopFunction = nil
m7 = nil
nb = nil
IngredientShopFunction = nil
nj = nil
nk = nil
local nF, nG, nH, MenuGroup
tE_14, nw, nj, nC, nd, m9, m5, nB, mZ, mU, nu, nt, ns, nq_1, tE_17, mC, ny, my, CosmeticData, FloorUpgradeData, mk, GlobalVariables, GridUtility, VariationUtility, l7, tE_22_1, nx, nv, IngredientShopFunction, IngredientShopRemote, nb, CosmeticShopFunction, m1, m_, mW, mS, mM, PlotServiceRemote, nr, mI, nA, nz, mz, Options, mq, mm = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local tE_7 = 172
repeat
    nD = (tE_7 * 17 + 9) % 26 + 1
    if nD <= 13 then
        if nD <= 7 then
            if nD <= 4 then
                if nD <= 2 then
                    if nD <= 1 then
                        nE = (vector.create((tE_7 * 6 + 3) % 11 + 1, (tE_7 * 5 + 1) % 13 + 1, (tE_7 * 9 + 15) % 17 + 1))
                        nF = (vector.create((tE_7 * 3 + 7) % 11 + 1, (tE_7 * 3 + 2) % 13 + 1, (tE_7 * 1 + 1) % 17 + 1))
                        nG = (vector.create((tE_7 * 1 + 1) % 5 + 1, (tE_7 * 2 + 4) % 7 + 1, (tE_7 * 2 + 2) % 9 + 1))
                        if math.abs((vector.angle(nE, nF, nG))) - math.abs((vector.angle(nF, nE, nG))) == 2 then
                            nw = nu:WaitForChild("Shared")
                        else
                            nu = nw:WaitForChild("Shared")
                        end
                        tE_7 = (tE_7 + 49) % 208
                    else
                        local u_ = bit32.rrotate(bit32.bxor(bit32.lrotate(tE_7, 13), string.byte(tostring(FloorUpgradeData))), 16)
                        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(u_, 3144364859), 1367870485), (bit32.bxor(bit32.band(u_, 1150602436), 4221475559))), 1367870485), 4221475559) == u_ then
                            nt = nu:WaitForChild("Modules")
                        else
                            nu = nt:WaitForChild("Modules")
                        end
                        tE_7 = (tE_7 + 153) % 208
                    end
                elseif nD <= 3 then
                    local us = bit32.rrotate(bit32.bxor(bit32.lrotate(tE_7, 18), string.byte(tostring(nj))), 3)
                    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(us, 2575937333), 2350727182), (bit32.bxor(bit32.band(us, 1719029962), 3876301235))), 2350727182), 3876301235) ~= us then
                        nt = ns:WaitForChild("Data")
                    else
                        ns = nt:WaitForChild("Data")
                    end
                    tE_7 = (tE_7 + 127) % 208
                else
                    nE = { "csjfwiocagn", "juzqus", "mmojrxpng", "dzlj", "snjrdhru", "blnf", "vcaaiyaywk", "cbtwgnfryt" }
                    local ur = tE_7
                    nF = nE[ur % 8 + 1]
                    if nF:len() <= nF:reverse():rep(ur % 3 + 2):len() then
                        nq_1 = nt:WaitForChild("Utility")
                    else
                        nt = nq_1:WaitForChild("Utility")
                    end
                    tE_7 = (tE_7 + 101) % 208
                end
            elseif nD <= 6 then
                if nD <= 5 then
                    if tE_7 * 52236409 + 8 + 6 <= tE_7 * 52236409 + 8 + 6 + 5 then
                        tE_17 = nt:WaitForChild("Functions")
                    else
                        nt = tE_17:WaitForChild("Functions")
                    end
                    tE_7 = (tE_7 + 49) % 208
                else
                    if ((mC or not IngredientShopFunction) and (IngredientShopFunction and mC) or (IngredientShopFunction or mC) and (mC and IngredientShopFunction) or (IngredientShopFunction and not IngredientShopFunction or (not mC or not mC) or IngredientShopFunction and IngredientShopFunction and (IngredientShopFunction or IngredientShopFunction))) and ((IngredientShopFunction and mC or (not IngredientShopFunction or IngredientShopFunction)) and (IngredientShopFunction and not mC and (mC and IngredientShopFunction)) or (not mC or IngredientShopFunction or (IngredientShopFunction or mC)) and (not mC and mC or (not mC or not IngredientShopFunction))) or not (((mC or not IngredientShopFunction) and (IngredientShopFunction and mC) or (IngredientShopFunction or mC) and (mC and IngredientShopFunction) or (IngredientShopFunction and not IngredientShopFunction or (not mC or not mC) or IngredientShopFunction and IngredientShopFunction and (IngredientShopFunction or IngredientShopFunction))) and ((IngredientShopFunction and mC or (not IngredientShopFunction or IngredientShopFunction)) and (IngredientShopFunction and not mC and (mC and IngredientShopFunction)) or (not mC or IngredientShopFunction or (IngredientShopFunction or mC)) and (not mC and mC or (not mC or not IngredientShopFunction)))) then
                        mC = require(ns:WaitForChild("PlantData"))
                        ny = require(ns:WaitForChild("EggData"))
                    else
                        ns = require(ny:WaitForChild("PlantData"))
                        mC = require(ny:WaitForChild("EggData"))
                    end
                    tE_7 = (tE_7 + 153) % 208
                end
            else
                nE = (vector.create((tE_7 * 3 + 1) % 11 + 1, (tE_7 * 11 + 6) % 13 + 1, (tE_7 * 14 + 6) % 17 + 1))
                nF = (vector.create((tE_7 * 5 + 2) % 11 + 1, (tE_7 * 4 + 2) % 13 + 1, (tE_7 * 4 + 7) % 17 + 1))
                nG = (vector.create((tE_7 * 1 + 5) % 5 + 1, (tE_7 * 2 + 3) % 7 + 1, (tE_7 * 2 + 3) % 9 + 1))
                if math.abs((vector.angle(nE, nF, nG))) - math.abs((vector.angle(nF, nE, nG))) == 0 then
                    my = require(ns:WaitForChild("PetData"))
                    CosmeticData = require(ns:WaitForChild("CosmeticData"))
                else
                    ns = require(CosmeticData:WaitForChild("PetData"))
                    my = require(CosmeticData:WaitForChild("CosmeticData"))
                end
                tE_7 = (tE_7 + 127) % 208
            end
        elseif nD <= 10 then
            if nD <= 9 then
                if nD <= 8 then
                    nE = (vector.create((tE_7 * 1 + 9) % 11 + 1, (tE_7 * 9 + 1) % 13 + 1, (tE_7 * 15 + 10) % 17 + 1))
                    nF = (vector.create((tE_7 * 6 + 1) % 11 + 1, (tE_7 * 11 + 9) % 13 + 1, (tE_7 * 2 + 7) % 17 + 1))
                    local uN = vector.dot(nE, nF)
                    if uN * uN <= vector.dot(nE, nE) * vector.dot(nF, nF) then
                        FloorUpgradeData = require(ns:WaitForChild("FloorUpgradeData"))
                    else
                        ns = require(FloorUpgradeData:WaitForChild("FloorUpgradeData"))
                    end
                    tE_7 = (tE_7 + 101) % 208
                else
                    local vb = bit32.rrotate(bit32.bxor(bit32.lrotate(tE_7, 4), string.byte(tostring(nb))), 18)
                    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(vb, 3567004289), 2417215562), (bit32.bxor(bit32.band(vb, 727963006), 523757744))), 2417215562), 523757744) == vb then
                        mk = require(ns:WaitForChild("FloorPriceData"))
                        GlobalVariables = require(ns:WaitForChild("GlobalVariables"))
                    else
                        ns = require(GlobalVariables:WaitForChild("FloorPriceData"))
                        mk = require(GlobalVariables:WaitForChild("GlobalVariables"))
                    end
                    tE_7 = (tE_7 + 205) % 208
                end
            else
                nE = (vector.create((tE_7 * 1 + 7) % 11 + 1, (tE_7 * 7 + 9) % 13 + 1, (tE_7 * 2 + 8) % 17 + 1))
                nF = (vector.create((tE_7 * 4 + 7) % 11 + 1, (tE_7 * 11 + 12) % 13 + 1, (tE_7 * 1 + 3) % 17 + 1))
                nG = (vector.create((tE_7 * 3 + 9) % 11 + 1, (tE_7 * 6 + 2) % 13 + 1, (tE_7 * 10 + 6) % 17 + 1))
                nH = (vector.create((tE_7 * 3 + 5) % 11 + 1, (tE_7 * 10 + 10) % 13 + 1, (tE_7 * 5 + 2) % 17 + 1))
                if vector.dot(vector.cross(nE, nF), (vector.cross(nG, nH))) == vector.dot(nE, nG) * vector.dot(nF, nH) - vector.dot(nE, nH) * vector.dot(nF, nG) + 4 then
                    l7 = require(GridUtility:WaitForChild("GridUtility"))
                    nq_1 = require(GridUtility:WaitForChild("VariationUtility"))
                    tE_17 = require(VariationUtility:WaitForChild("ResolvePlaceableTemplate"))
                else
                    GridUtility = require(nq_1:WaitForChild("GridUtility"))
                    VariationUtility = require(nq_1:WaitForChild("VariationUtility"))
                    l7 = require(tE_17:WaitForChild("ResolvePlaceableTemplate"))
                end
                tE_7 = (tE_7 + 101) % 208
            end
        elseif nD <= 12 then
            if nD <= 11 then
                nE = (vector.create((tE_7 * 6 + 7) % 11 + 1, (tE_7 * 11 + 9) % 13 + 1, (tE_7 * 13 + 3) % 17 + 1))
                nF = (vector.create((tE_7 * 7 + 9) % 11 + 1, (tE_7 * 2 + 13) % 13 + 1, (tE_7 * 12 + 16) % 17 + 1))
                nG = (vector.create((tE_7 * 6 + 4) % 11 + 1, (tE_7 * 4 + 3) % 13 + 1, (tE_7 * 13 + 8) % 17 + 1))
                if vector.dot(vector.cross(nE, nF), nG) == vector.dot(vector.cross(nF, nG), nE) then
                    tE_22_1 = nw:WaitForChild("Remotes")
                else
                    nw = tE_22_1:WaitForChild("Remotes")
                end
                tE_7 = (tE_7 + 127) % 208
            else
                local uv = bit32.rrotate(bit32.bxor(bit32.lrotate(tE_7, 24), string.byte(tostring(tE_22_1))), 27)
                if bit32.bxor(bit32.lrotate(bit32.bxor(uv, 2789495754), 2), 2568048426) == bit32.lrotate(uv, 2) then
                    nx = tE_22_1:WaitForChild("Events")
                else
                    tE_22_1 = nx:WaitForChild("Events")
                end
                tE_7 = (tE_7 + 23) % 208
            end
        else
            if (tE_7 * 1 + 5) * 21 % 4 == ((tE_7 * 1 + 5) * 21 + 4) % 4 then
                nv = tE_22_1:WaitForChild("Functions")
            else
                tE_22_1 = nv:WaitForChild("Functions")
            end
            tE_7 = (tE_7 + 153) % 208
        end
    elseif nD <= 20 then
        if nD <= 17 then
            if nD <= 15 then
                if nD <= 14 then
                    if tE_7 * 71033105 + 5 + 1 <= tE_7 * 71033105 + 5 + 1 + 1 then
                        IngredientShopFunction = nv:WaitForChild("IngredientShopFunction")
                        IngredientShopRemote = nx:WaitForChild("IngredientShopRemote")
                    else
                        nv = IngredientShopFunction:WaitForChild("IngredientShopFunction")
                        nx = IngredientShopRemote:WaitForChild("IngredientShopRemote")
                    end
                    tE_7 = (tE_7 + 179) % 208
                else
                    nE = {
                        "rpygaxaakm",
                        "pvhdtofnl",
                        "rthlsbuuwbr",
                        "fxlyoy",
                        "qpccly",
                        "kquvnbuqfln",
                        "dfjshmnzux",
                        "yuhikdhn",
                        "qdnsmaj",
                        "qjk",
                        "swoetf"
                    }
                    local uy = tE_7
                    nF = nE[uy % 11 + 1]
                    if nF:len() <= nF:gsub("(.)", "%1%1", uy % 3 % 2 + 1):len() then
                        nb = nv:WaitForChild("PetShopFunction")
                        CosmeticShopFunction = nv:WaitForChild("CosmeticShopFunction")
                        m1 = nv:WaitForChild("SellServiceRemoteFunction")
                    else
                        nv = CosmeticShopFunction:WaitForChild("PetShopFunction")
                        m1 = CosmeticShopFunction:WaitForChild("CosmeticShopFunction")
                        nb = CosmeticShopFunction:WaitForChild("SellServiceRemoteFunction")
                    end
                    tE_7 = (tE_7 + 75) % 208
                end
            elseif nD <= 16 then
                nE = (vector.create((tE_7 * 5 + 7) % 11 + 1, (tE_7 * 11 + 5) % 13 + 1, (tE_7 * 8 + 1) % 17 + 1))
                nF = (vector.create((tE_7 * 2 + 7) % 11 + 1, (tE_7 * 8 + 6) % 13 + 1, (tE_7 * 14 + 13) % 17 + 1))
                nG = (vector.create((tE_7 * 3 + 6) % 11 + 1, (tE_7 * 4 + 4) % 13 + 1, (tE_7 * 3 + 2) % 17 + 1))
                nH = (vector.create((tE_7 * 5 + 4) % 11 + 1, (tE_7 * 10 + 2) % 13 + 1, (tE_7 * 4 + 9) % 17 + 1))
                if vector.dot(vector.cross(nE, nF), (vector.cross(nG, nH))) == vector.dot(nE, nG) * vector.dot(nF, nH) - vector.dot(nE, nH) * vector.dot(nF, nG) then
                    m_ = nx:WaitForChild("GridPlacementRemoteEvent")
                    mW = nx:WaitForChild("FruitCollectionRemote")
                    mS = nx:WaitForChild("CrateStackRemote")
                else
                    nx = mW:WaitForChild("GridPlacementRemoteEvent")
                    mS = mW:WaitForChild("FruitCollectionRemote")
                    m_ = mW:WaitForChild("CrateStackRemote")
                end
                tE_7 = (tE_7 + 49) % 208
            else
                nE = { "bvve", "mlq", "hexfydhp", "srvbpzsf", "ytpzzpeuge", "qujwzvm", "dabf", "wwztvrbzat" }
                local ve = tE_7
                nF = nE[ve % 8 + 1]
                if nF:len() <= nF:reverse():rep(ve % 3 + 2):len() then
                    mM = nx:WaitForChild("FloorUpgradeRemote")
                    PlotServiceRemote = nx:WaitForChild("PlotServiceRemote")
                else
                    nx = PlotServiceRemote:WaitForChild("FloorUpgradeRemote")
                    mM = PlotServiceRemote:WaitForChild("PlotServiceRemote")
                end
                tE_7 = (tE_7 + 23) % 208
            end
        elseif nD <= 19 then
            if nD <= 18 then
                nE = (vector.create((tE_7 * 4 + 6) % 11 + 1, (tE_7 * 8 + 12) % 13 + 1, (tE_7 * 2 + 3) % 17 + 1))
                nF = (vector.create((tE_7 * 3 + 1) % 11 + 1, (tE_7 * 4 + 11) % 13 + 1, (tE_7 * 15 + 11) % 17 + 1))
                nG = (vector.create((tE_7 * 1 + 1) % 5 + 1, (tE_7 * 5 + 5) % 7 + 1, (tE_7 * 3 + 7) % 9 + 1))
                if math.abs((vector.angle(nE, nF, nG))) - math.abs((vector.angle(nF, nE, nG))) == 0 then
                    nr = ""
                else
                    nx = ""
                end
                tE_7 = (tE_7 + 101) % 208
            else
                nE = (vector.create((tE_7 * 7 + 7) % 11 + 1, (tE_7 * 10 + 2) % 13 + 1, (tE_7 * 7 + 11) % 17 + 1))
                nF = (vector.create((tE_7 * 2 + 1) % 11 + 1, (tE_7 * 7 + 7) % 13 + 1, (tE_7 * 4 + 8) % 17 + 1))
                nG = (vector.create((tE_7 * 1 + 1) % 5 + 1, (tE_7 * 2 + 6) % 7 + 1, (tE_7 * 5 + 4) % 9 + 1))
                if math.abs((vector.angle(nE, nF, nG))) - math.abs((vector.angle(nF, nE, nG))) == 0 then
                    mI = getgenv().Library
                    nA = getgenv().ThemeManager
                    nz = getgenv().SaveManager
                    mz = mI.Toggles
                    Options = mI.Options
                else
                    nz = getgenv().Library
                    nr = getgenv().ThemeManager
                    nA = getgenv().SaveManager
                    mI = nz.Toggles
                    mz = nz.Options
                end
                tE_7 = (tE_7 + 153) % 208
            end
        else
            nE = {
                "hwxcdkgr",
                "iuelfkywwvy",
                "yjsdgydafjj",
                "hgnioxzw",
                "uwxylqr",
                "kgdbcb",
                "ikjpgcnj",
                "vnkofhotk",
                "wwxxl",
                "ukdffmuff"
            }
            local ui = tE_7
            nF = nE[ui % 10 + 1]
            if nF:len() <= nF:gsub("(.)", "%1%1", ui % 3 % 2 + 1):len() then
                mq = {}
            else
                nd = {}
            end
            tE_7 = (tE_7 + 75) % 208
        end
    elseif nD <= 23 then
        if nD <= 22 then
            if nD <= 21 then
                nE = { "eyoinkqtabh", "cvgccocs", "iacjeas", "mbgg", "cbjffiqkif", "axkfqwbec", "xmevfzms" }
                local vc = tE_7
                nF = nE[vc % 7 + 1]
                if nF:len() >= nF:reverse():rep(vc % 3 + 2):len() then
                    mC = {}
                else
                    mm = {}
                end
                tE_7 = (tE_7 + 101) % 208
            else
                if (tE_7 * 2 + 9) * 16 % 3 == ((tE_7 * 2 + 9) * 16 + 3) % 3 then
                    tE_14 = game:GetService("Players")
                else
                    mI = game:GetService("Players")
                end
                tE_7 = (tE_7 + 75) % 208
            end
        else
            nE = (vector.create((tE_7 * 7 + 3) % 11 + 1, (tE_7 * 9 + 6) % 13 + 1, (tE_7 * 1 + 5) % 17 + 1))
            nF = (vector.create((tE_7 * 5 + 5) % 11 + 1, (tE_7 * 4 + 5) % 13 + 1, (tE_7 * 14 + 1) % 17 + 1))
            local uK = vector.cross(nE, nF)
            local uL = vector.dot(nE, nF)
            if vector.dot(uK, uK) + uL * uL == vector.dot(nE, nE) * vector.dot(nF, nF) + 4 then
                ny = game:GetService("ReplicatedStorage")
            else
                nw = game:GetService("ReplicatedStorage")
            end
            tE_7 = (tE_7 + 49) % 208
        end
    elseif nD <= 25 then
        if nD <= 24 then
            nD = {
                "ioiyhuig",
                "gaiqirhilf",
                "qnpwvwlqalxx",
                "xhlkzamrqh",
                "abrez",
                "hdcfnria",
                "mewx",
                "uelsro",
                "ivgt",
                "suq",
                "bdfcqpii",
                "jzkgxcogftj",
                "brtueewrsj",
                "zwqehmgpqjjv",
                "rilranvhdnkl",
                "gzuclpodwps"
            }
            if nD[(tE_7 * 45 + 73) % 16 + 1] <= nD[(tE_7 * 45 + 73) % 16 + 1] then
                nj = game:GetService("CollectionService")
                nC = game:GetService("UserInputService")
                nd = game:GetService("VirtualUser")
                m9 = game:GetService("Workspace")
            else
                m9 = game:GetService("CollectionService")
                nd = game:GetService("UserInputService")
                nj = game:GetService("VirtualUser")
                nC = game:GetService("Workspace")
            end
            tE_7 = (tE_7 + 23) % 208
        else
            nD = (vector.create((tE_7 * 4 + 9) % 11 + 1, (tE_7 * 11 + 13) % 13 + 1, (tE_7 * 9 + 12) % 17 + 1))
            nE = (vector.create((tE_7 * 3 + 1) % 11 + 1, (tE_7 * 3 + 6) % 13 + 1, (tE_7 * 9 + 13) % 17 + 1))
            nF = (vector.create((tE_7 * 1 + 3) % 11 + 1, (tE_7 * 6 + 10) % 13 + 1, (tE_7 * 3 + 3) % 17 + 1))
            nG = (vector.create((tE_7 * 4 + 2) % 5 + 1, (tE_7 * 4 + 3) % 7 + 1, (tE_7 * 2 + 2) % 9 + 1))
            if vector.dot(vector.cross(nD, (vector.cross(nE, nF))), nG) == vector.dot(nE * vector.dot(nD, nF) - nF * vector.dot(nD, nE), nG) then
                m5 = tE_14.LocalPlayer
                nB = "Build a Garden Tower"
                mZ = "https://discord.gg/K7Qxnxkk46"
            else
                tE_14 = m5.LocalPlayer
                mZ = "Build a Garden Tower"
                nB = "https://discord.gg/K7Qxnxkk46"
            end
            tE_7 = (tE_7 + 205) % 208
        end
    else
        nD = (vector.create((tE_7 * 4 + 3) % 11 + 1, (tE_7 * 5 + 4) % 13 + 1, (tE_7 * 3 + 9) % 17 + 1))
        nE = (vector.create((tE_7 * 5 + 5) % 11 + 1, (tE_7 * 10 + 2) % 13 + 1, (tE_7 * 11 + 5) % 17 + 1))
        nF = (vector.create((tE_7 * 6 + 4) % 11 + 1, (tE_7 * 11 + 12) % 13 + 1, (tE_7 * 15 + 4) % 17 + 1))
        nG = (vector.create((tE_7 * 3 + 5) % 5 + 1, (tE_7 * 1 + 3) % 7 + 1, (tE_7 * 3 + 7) % 9 + 1))
        if vector.dot(vector.cross(nD, (vector.cross(nE, nF))), nG) == vector.dot(nE * vector.dot(nD, nF) - nF * vector.dot(nD, nE), nG) then
            mU = "https://discord.gg/K7Qxnxkk46"
        else
            mW = "https://discord.gg/K7Qxnxkk46"
        end
        tE_7 = (tE_7 + 127) % 208
    end
until (tE_7 * 119 + 141) % 208 == 17
nD = {}
for k, v in pairs(mC) do
    tE_14 = typeof(v) == "table" and v.buy_price
    if tE_14 then
        local tE_22_2 = v.metadata
        if tE_22_2 then
            tE_7 = v.metadata.event or v.metadata.isRobux
            tE_22_2 = tE_7
        end
        tE_14 = not tE_22_2
    end
    if tE_14 then
        tE_14 = table.insert
        local tE_22_3 = v.buy_price
        tE_7 = v.rarity and v.rarity.order
        tE_17 = tE_7 or 0
        tE_14(nD, { name = k, price = tE_22_3, order = tE_17 })
    end
end
local tE_22_4 = 0
repeat
    tE_14 = {
        "oxvnqyasq",
        "jknjjnppbmm",
        "pnmtklkrg",
        "ywvfbmlxcvl",
        "luaiy",
        "zhtzpghbynu",
        "hqbofemdj",
        "nmcxcgt",
        "yhnhtmv"
    }
    local va = tE_22_4
    tE_7 = tE_14[va % 9 + 1]
    if tE_7:len() >= tE_7:reverse():rep(va % 3 + 2):len() then
        table.sort(nD, fn541)
    else
        table.sort(nD, fn541)
    end
    tE_22_4 = (tE_22_4 + 3) % 4
until (tE_22_4 * 1 + 3) % 4 == 2
for i, v in ipairs(nD) do
    table.insert(mq, v.name)
    mm[v.name] = v.price
end
mL = {}
mN = {}
tE_14 = {}
for k, v in pairs(ny) do
    local tE_22_5 = typeof(v) == "table" and v.Price
    if tE_22_5 then
        table.insert(tE_14, { name = k, price = v.Price })
    end
end
local tE_22_6 = 6
repeat
    tE_7 = {
        "epnoc",
        "ryko",
        "pnvfctzjnlgw",
        "arxeraobzf",
        "ajphzrhanh",
        "ehjrfdboiyr",
        "bbxzlt",
        "aaxcuahef",
        "cmyfo",
        "qhw",
        "skibcpgvbi",
        "lpey",
        "fbmrxv",
        "gqqcpiguv",
        "khhe"
    }
    if tE_7[(tE_22_6 * 5 + 24) % 15 + 1] < tE_7[(tE_22_6 * 5 + 24) % 15 + 1] then
        table.sort(tE_14, fn102)
    else
        table.sort(tE_14, fn102)
    end
    tE_22_6 = (tE_22_6 + 6) % 8
until (tE_22_6 * 5 + 1) % 8 == 5
for i, v in ipairs(tE_14) do
    table.insert(mN, v.name)
    mL[v.name] = v.price
end
me = {}
mj = {}
tE_14 = {}
for k, v in pairs(CosmeticData) do
    local tE_22_7 = typeof(v) == "table" and v.buy_price
    if tE_22_7 then
        table.insert(tE_14, { name = k, price = v.buy_price })
    end
end
table.sort(tE_14, fn795)
for i, v in ipairs(tE_14) do
    table.insert(mj, v.name)
    me[v.name] = v.price
end
m7 = {}
tE_14 = { "harvest", "growth", "double", "pet_slot" }
tE_14 = FloorUpgradeData.row_order or tE_14
for i, v in ipairs(tE_14) do
    tE_14 = FloorUpgradeData.upgrades[v]
    if tE_14 then
        table.insert(m7, tE_14.display)
    end
end
mO = {}
for k, v in pairs(FloorUpgradeData.upgrades) do
    mO[v.display] = k
end
m3, ml, mE, ms, mf, l5, mY, mF, mn, l8, m4, mT, mH, mt, mc, nk, na, mV, mD, mi, mB, mr, ni, mX, ma, mP, mw, mG, mR, l6, nf, nl, ng, mx, mb, mo = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
nr = { "Highest Market Price", "Closest", "Random" }
mE = fn493
ms = fn363
mf = fn132
l5 = fn147
tE_17 = "#7fd47f"
nt = "#6ec1ff"
m3 = "#e8a34d"
ns = "#8b93a3"
mY = fn23
mF = fn356
mn = fn200
l8 = fn53
if (false and not mi or false and not mi) and ((not mi or nr) and (mi or false)) or (not mi or nr or nr and nr) and (nr or nr or false) or not ((false and not mi or false and not mi) and ((not mi or nr) and (mi or false)) or (not mi or nr or nr and nr) and (nr or nr or false)) then
    m4 = fn608
    mT = fn160
else
    mT = fn608
    m4 = fn160
end
mH = fn334
mt = fn40
mc = fn666
nk = fn742
na = fn758
mV = fn690
mD = fn350
ml = {}
mi = fn688
m_.OnClientEvent:Connect(onOnClientEvent)
mB = fn424
mB()
mr = function(cy)
    local p9_1
    local p8 = VariationUtility.parseName(cy)
    local p8_1
    local p7 = l7(p8)
    if not p7 then
        return Vector3.new(4, 0.1, 4)
    elseif p7:IsA("BasePart") then
        return p7.Size
    elseif p7.PrimaryPart then
        return p7.PrimaryPart.Size
    else
        p8_1, p9_1 = pcall(function()
            return p7:GetExtentsSize()
        end)
        if p8_1 and p9_1 then
            return Vector3.new(p9_1.X, 0.1, p9_1.Z)
        end
        return Vector3.new(4, 0.1, 4)
    end
end
if (not mP and l8 or mP and not l8) and (mP and l8 or (l8 or l8)) and ((l8 or mP or not mP and not mP) and ((not l8 or not mP) and (not l8 or l8))) or not ((not mP and l8 or mP and not l8) and (mP and l8 or (l8 or l8)) and ((l8 or mP or not mP and not mP) and ((not l8 or not mP) and (not l8 or l8)))) then
    ni = fn525
    mX = fn549
else
    mX = fn525
    ni = fn549
end
ma = fn194
mP = fn139
mw = function(dk, dl)
    local q2 = mF("CollectPriority", "Highest Market Price")
    if q2 == "Random" then
        local q8 = #dk
        local q7 = -1
        while false and q8 <= 2 or true and q8 >= 2 do
            local q9 = q8
            local q3_1 = math.random(q9)
            dk[q9], dk[q3_1] = dk[q3_1], dk[q9]
            q8 += q7
        end
        return
    end
    if q2 == "Closest" then
        table.sort(dk, function(dr, ds)
            local base2 = dr:FindFirstChild("base")
            local base = ds:FindFirstChild("base")
            local qX = base2 and base2.Position
            local qV_1 = qX or dr:GetPivot().Position
            local qX_1 = base
            if qX_1 then
                qX_1 = base.Position
            end
            local qV_2 = qX_1 or ds:GetPivot().Position
            return (qV_1 - dl.Position).Magnitude < (qV_2 - dl.Position).Magnitude
        end)
        return
    end
    table.sort(dk, function(dC, dD)
        return mP(dC) > mP(dD)
    end)
end
mG = function()
    local rb = mH()
    if not rb then
        return
    end
    local rc = {}
    for k, v in nj:GetTagged("plant") do
        local rd_1 = v:GetAttribute("OwnerUserId") == m5.UserId and v:GetAttribute("Ripe") == true
        if rd_1 then
            table.insert(rc, v)
        end
    end
    if #rc == 0 then
        return
    end
    mw(rc, rb)
    for i, v in ipairs(rc) do
        local rq = v
        local rc_1 = mI.Unloaded or not mY("AutoCollectPlants")
        if rc_1 then
            return
        end
        local base = rq:FindFirstChild("base")
        local rd_2 = base and base:IsA("BasePart")
        if rd_2 then
            rb.CFrame = base.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.12)
            pcall(function()
                mW:FireServer(rq)
            end)
            task.wait(mn("CollectPlantsDelay", 0.35))
        end
    end
end
mR = fn206
l6 = function()
    local rz = mt()
    if rz then
        rz:UnequipTools()
    end
    local rz_1 = mY("SellSeeds")
    local rA = mY("SellPets")
    local rB = mY("SellCosmetics")
    if not (rz_1 or rA or rB) then
        pcall(function()
            m1:InvokeServer({})
        end)
        return
    end
    local Backpack = m5:FindFirstChild("Backpack")
    if not Backpack then
        return
    end
    for i, child in Backpack:GetChildren() do
        local rO = child
        local rC_2 = mI.Unloaded or not mY("AutoSell")
        if rC_2 then
            return
        end
        local rC_3 = rO:IsA("Tool") and rO.Name ~= "Edit Tool" and rO.Name ~= "SpeedCoil"
        if rC_3 then
            local rC_4 = VariationUtility.parseName(rO.Name)
            local rD_1 = mC[rC_4] ~= nil
            local rE = my[rC_4] ~= nil
            local rF = CosmeticData[rC_4] ~= nil
            local attr = rO:GetAttribute("placeable")
            local rG = false
            local rH = attr == true
            if rD_1 and rz_1 then
                if rH then
                    rG = mY("SellPlaceableSeeds")
                else
                    rG = true
                end
            else
                if rE and rA then
                    rG = true
                else
                    if rF and rB then
                        rG = true
                    end
                end
            end
            if rG then
                local floor = math.floor
                local rD_2 = rO:GetAttribute("Count") or 1
                local ry = floor(rD_2)
                if ry > 0 then
                    pcall(function()
                        m1:InvokeServer({ to_sell = { name = rO.Name, count = ry } })
                    end)
                    task.wait(0.2)
                end
            end
        end
    end
end
nf = function()
    if na() then
        return
    end
    local rQ = mn("BuySeedsMinCash", 0)
    for i, v in ipairs(mq) do
        local result
        local rZ = v
        local rR = mI.Unloaded or not mY("AutoBuySeeds")
        if rR then
            return
        end
        if mT("BuySeedsList", rZ) then
            local rR_1 = mm[rZ] or 0
            local rR_2 = mc() - rR_1 >= rQ and mc() >= rR_1
            if rR_2 then
                result = nil
                pcall(function()
                    result = IngredientShopFunction:InvokeServer({ event_type = "purchase", plant = rZ })
                end)
                if result and result.success then
                    task.wait(mn("BuySeedsDelay", 0.4))
                else
                    if result and result.no_cash then
                        return
                    end
                    task.wait(0.15)
                end
            end
        end
    end
end
nl = function()
    local r3_1
    local r2_1
    if na() then
        return
    end
    local r0 = mV()
    if not r0 then
        return
    end
    local Parking = r0:FindFirstChild("Parking")
    if not Parking then
        return
    end
    local r0_1 = mt()
    if not r0_1 then
        return
    end
    mB()
    task.wait(0.2)
    r2_1, r3_1 = mX("PlaceSeedsList")
    if not r2_1 then
        return
    end
    r0_1:EquipTool(r2_1)
    task.wait(0.2)
    local r0_2 = mr(r3_1)
    local r2_2 = nk()
    for i = 1, r2_2 do
        local r8 = i
        local r2_3 = mI.Unloaded or not mY("AutoPlaceSeeds")
        if r2_3 then
            return
        end
        local r2_4 = Parking:FindFirstChild("grid_" .. r8)
        local r3_2 = r2_4 and r2_4:IsA("BasePart")
        if r3_2 then
            local r_ = ma(r2_4, r8, r0_2)
            if r_ then
                pcall(function()
                    m_:FireServer({ eventType = "requestPlacement", floorIndex = r8, rotation = 0, position = r_ })
                end)
                task.wait(mn("PlaceSeedsDelay", 0.35))
                return
            end
        end
    end
end
ng = function()
    local r9
    r9 = nk() + 1
    if r9 > (GlobalVariables.MAX_FLOORS or 4) then
        return
    end
    local sa_1 = mk[r9]
    if not sa_1 then
        return
    end
    local sb = sa_1.currency
    local si = if sb then 1 else 0
    local sg = 1759 * si + 2702 * (1 - si)
    local sh = 3224 * si + 3977 * (1 - si)
    if not ((sg * 1753 + sh * 3699 + sg * sh) % 16777213 == 3902906) then
        sb = "Cash"
    end
    local sc = sb
    local player_info = m5:FindFirstChild("player_info")
    local sd = player_info
    if sd then
        local se = player_info:GetAttribute(sc) or 0
        sd = se
    end
    if (sd or 0) < sa_1.price then
        return
    end
    pcall(function()
        PlotServiceRemote:FireServer({ event_type = "buy_floor", floor_level = r9 })
    end)
end
mx = function()
    local sk = mV()
    if not sk then
        return
    end
    local Details = sk:FindFirstChild("Details")
    if not Details then
        return
    end
    local sk_1 = mn("FloorUpgradesMinCash", 0)
    local sm = nk()
    for i = 1, sm do
        local su = i
        local sm_1 = Details:FindFirstChild("floor" .. su)
        if sm_1 then
            for i, v in ipairs(m7) do
                local sn = mI.Unloaded or not mY("AutoBuyFloorUpgrades")
                if sn then
                    return
                end
                if mT("FloorUpgradeList", v) then
                    local sj = mO[v]
                    local sn_1 = sj and FloorUpgradeData.upgrades[sj]
                    if sn_1 then
                        local sn_2 = sm_1:GetAttribute("upgrade_" .. sj) or 0
                        if sn_2 < sn_1.max_level then
                            local sn_3 = FloorUpgradeData.price(su, sn_2)
                            local so_1 = mc() - sn_3 >= sk_1 and mc() >= sn_3
                            if so_1 then
                                pcall(function()
                                    mM:FireServer({ event_type = "buy", floor = su, upgrade = sj })
                                end)
                                task.wait(mn("FloorUpgradesDelay", 0.35))
                            end
                        end
                    end
                end
            end
        end
    end
end
mb = function()
    if na() then
        return
    end
    local sC = mn("BuyPetsMinCash", 0)
    for i, v in ipairs(mN) do
        local result
        local sL = v
        local sD = mI.Unloaded or not mY("AutoBuyPets")
        if sD then
            return
        end
        if mT("BuyPetsList", sL) then
            local sD_1 = mL[sL] or 0
            local sD_2 = mc() - sD_1 >= sC and mc() >= sD_1
            if sD_2 then
                result = nil
                pcall(function()
                    result = nb:InvokeServer({ event_type = "purchase", egg = sL })
                end)
                if result and result.success then
                    task.wait(mn("BuyPetsDelay", 0.45))
                else
                    if result and result.no_cash then
                        return
                    end
                    task.wait(0.15)
                end
            end
        end
    end
end
mo = function()
    if na() then
        return
    end
    local sN = mn("BuyCosmeticsMinCash", 0)
    for i, v in ipairs(mj) do
        local result
        local sW = v
        local sO = mI.Unloaded or not mY("AutoBuyCosmetics")
        if sO then
            return
        end
        if mT("BuyCosmeticsList", sW) then
            local sO_1 = me[sW] or 0
            local sO_2 = mc() - sO_1 >= sN and mc() >= sO_1
            if sO_2 then
                result = nil
                pcall(function()
                    result = CosmeticShopFunction:InvokeServer({ event_type = "purchase", cosmetic = sW })
                end)
                if result and result.success then
                    task.wait(mn("BuyCosmeticsDelay", 0.45))
                else
                    if result and result.no_cash then
                        return
                    end
                    task.wait(0.15)
                end
            end
        end
    end
end
pcall(fn836)
tE_14 = mI:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = mZ, Copyable = true }, "|", nB },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local nq_2 = {
    Info = tE_14:AddTab("Info", "info"),
    Main = tE_14:AddTab("Main", "sprout"),
    Settings = tE_14:AddTab("Settings", "settings")
}
nq_2.Farm = nq_2.Main:AddSubTab("Farm", "wheat")
nq_2.Shop = nq_2.Main:AddSubTab("Shop", "shopping-cart")
nq_2.Floors = nq_2.Main:AddSubTab("Floors", "layers")
tE_7 = fn136
for k, v in nq_2 do
    if v ~= nq_2.Main then
        tE_7(v)
    end
end
l4, tE_22_9, nv, Label, m0, nu = nil, nil, nil, nil, nil, nil
tE_14 = 12
repeat
    tE_7 = (tE_14 * 2 + 0) % 3 + 1
    if tE_7 <= 2 then
        if tE_7 <= 1 then
            tE_7 = (vector.create((tE_14 * 2 + 1) % 11 + 1, (tE_14 * 10 + 8) % 13 + 1, (tE_14 * 3 + 5) % 17 + 1))
            nw = (vector.create((tE_14 * 2 + 3) % 11 + 1, (tE_14 * 5 + 5) % 13 + 1, (tE_14 * 9 + 8) % 17 + 1))
            nx = (vector.create((tE_14 * 2 + 1) % 11 + 1, (tE_14 * 5 + 10) % 13 + 1, (tE_14 * 1 + 11) % 17 + 1))
            if vector.dot(vector.cross(tE_7, nw), nx) == vector.dot(vector.cross(nw, nx), tE_7) + 3 then
                tE_17 = "Unknown"
                pcall(fn461)
                mf = Label.Info:AddLeftGroupbox("Account", "circle-user")
                mf:AddLabel(nq_2("User", l5.Name, tE_22_9), true)
                mf:AddLabel(nq_2("Status", "Keyless", tE_22_9), true)
                mf:AddLabel(nq_2("Executor", "Unknown", tE_22_9), true)
                m3 = Label.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                m3:AddLabel(nB(nv .. " [" .. tostring(game.PlaceId) .. "]", l4), true)
                m3:AddLabel(nq_2("Place ID", tostring(game.PlaceId), l4), true)
                m5 = m3:AddLabel(nq_2("Session time", "0s", nt), true)
            else
                l4 = "Unknown"
                pcall(fn461)
                tE_22_9 = nq_2.Info:AddLeftGroupbox("Account", "circle-user")
                tE_22_9:AddLabel(l5("User", m5.Name, tE_17), true)
                tE_22_9:AddLabel(l5("Status", "Keyless", tE_17), true)
                tE_22_9:AddLabel(l5("Executor", l4, tE_17), true)
                nv = nq_2.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                nv:AddLabel(mf(nB .. " [" .. tostring(game.PlaceId) .. "]", nt), true)
                nv:AddLabel(l5("Place ID", tostring(game.PlaceId), nt), true)
                Label = nv:AddLabel(l5("Session time", "0s", m3), true)
            end
            tE_14 = (tE_14 + 17) % 24
        else
            tE_7 = (vector.create((tE_14 * 4 + 4) % 11 + 1, (tE_14 * 10 + 10) % 13 + 1, (tE_14 * 11 + 2) % 17 + 1))
            nw = (vector.create((tE_14 * 6 + 5) % 11 + 1, (tE_14 * 8 + 3) % 13 + 1, (tE_14 * 15 + 14) % 17 + 1))
            nx = (vector.create((tE_14 * 2 + 6) % 11 + 1, (tE_14 * 2 + 11) % 13 + 1, (tE_14 * 14 + 14) % 17 + 1))
            if vector.dot(vector.cross(tE_7, nw), nx) == vector.dot(vector.cross(nw, nx), tE_7) + 3 then
                nu = tostring(game.JobId)
            else
                m0 = tostring(game.JobId)
            end
            tE_14 = (tE_14 + 5) % 24
        end
    else
        if (tE_14 * 3 + 1) * 13 % 4 == ((tE_14 * 3 + 1) * 13 + 4) % 4 then
            nu = #m0 > 18
        else
            m0 = #nu > 18
        end
        tE_14 = (tE_14 + 14) % 24
    end
until (tE_14 * 11 + 10) % 24 == 10
if nu then
    tE_14 = 3
    repeat
        local uc = bit32.rrotate(bit32.bxor(bit32.lrotate(tE_14, 20), string.byte(tostring(tE_14))), 14)
        if bit32.bxor(bit32.lrotate(bit32.bxor(uc, 332912666), 14), 4127622389) == bit32.lrotate(uc, 14) then
            nu = string.sub(m0, 1, 18) .. "..."
        else
            m0 = string.sub(nu, 1, 18) .. "..."
        end
        tE_14 = (tE_14 + 7) % 8
    until (tE_14 * 1 + 4) % 8 == 6
end
tE_14 = nu or m0
mJ, MenuGroup, nc, m8, connection, connection2, mQ = nil, nil, nil, nil, nil, nil, nil
nx = tE_14
nv:AddLabel(l5("Server", nx, ns), true)
nv:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
mJ = os.clock()
task.spawn(worker)
tE_17 = nq_2.Info:AddRightGroupbox("Scripts", "package")
tE_17:AddLabel(mf("Included in this hub", ns), true)
tE_17:AddLabel(mf(nB, nt), true)
tE_7 = nq_2.Info:AddRightGroupbox("Features", "list")
tE_7:AddLabel(mf("Auto Farm", nt), true)
tE_7:AddLabel(mf("Auto Shop", m3), true)
tE_7:AddLabel(mf("Floor Upgrades", ns), true)
local tE_22_10 = nq_2.Info:AddRightGroupbox("Socials", "link")
tE_22_10:AddButton({ Text = "Discord", Func = ms })
tE_22_10:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = nq_2.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = ms })
local FaqGroup = nq_2.Info:AddRightGroupbox("FAQ", "circle-help")
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
local CollectGroup = nq_2.Farm:AddLeftGroupbox("Collect", "hand")
CollectGroup:AddToggle("AutoCollectPlants", { Text = "Auto Collect Placed Plants", Default = false })
CollectGroup:AddDropdown("CollectPriority", { Values = nr, Default = 1, Text = "Collect Priority" })
CollectGroup:AddSlider("CollectPlantsDelay", { Text = "Collect Delay", Default = 0.35, Min = 0.1, Max = 2, Rounding = 2 })
CollectGroup:AddToggle("AutoCollectCrates", { Text = "Auto Collect Crates", Default = false })
CollectGroup:AddSlider("CollectCratesDelay", { Text = "Crate Delay", Default = 0.75, Min = 0.2, Max = 5, Rounding = 2 })
nH = nq_2.Farm:AddLeftGroupbox("Place", "shovel")
nH:AddToggle("AutoPlaceSeeds", { Text = "Auto Place Seeds", Default = false })
nH:AddDropdown("PlaceSeedsList", { Values = mq, Multi = true, Searchable = true, AllowNull = true, Text = "Seeds", Default = {} })
nH:AddSlider("PlaceSeedsDelay", { Text = "Place Delay", Default = 0.35, Min = 0.1, Max = 2, Rounding = 2 })
nG = nq_2.Farm:AddRightGroupbox("Sell", "badge-dollar-sign")
nG:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
nG:AddToggle("SellSeeds", { Text = "Sell Plants", Default = true })
nG:AddToggle("SellPlaceableSeeds", { Text = "Sell Placeable Seeds", Default = false })
nG:AddToggle("SellPets", { Text = "Sell Pets", Default = false })
nG:AddToggle("SellCosmetics", { Text = "Sell Cosmetics", Default = false })
nG:AddSlider("SellDelay", { Text = "Sell Delay", Default = 1, Min = 0.25, Max = 10, Rounding = 2 })
nF = nq_2.Shop:AddLeftGroupbox("Seeds", "sprout")
nF:AddToggle("AutoBuySeeds", { Text = "Auto Buy Seeds", Default = false })
nF:AddDropdown("BuySeedsList", { Values = mq, Multi = true, Searchable = true, AllowNull = true, Text = "Seeds", Default = {} })
nF:AddSlider("BuySeedsDelay", { Text = "Buy Delay", Default = 0.4, Min = 0.1, Max = 3, Rounding = 2 })
nF:AddSlider("BuySeedsMinCash", { Text = "Min Cash", Default = 0, Min = 0, Max = 100000000, Rounding = 0, Compact = true })
nE = nq_2.Shop:AddLeftGroupbox("Pets", "paw-print")
nE:AddToggle("AutoBuyPets", { Text = "Auto Buy Pets", Default = false })
nE:AddDropdown("BuyPetsList", { Values = mN, Multi = true, Searchable = true, AllowNull = true, Text = "Eggs", Default = {} })
nE:AddSlider("BuyPetsDelay", { Text = "Buy Delay", Default = 0.45, Min = 0.1, Max = 3, Rounding = 2 })
nE:AddSlider("BuyPetsMinCash", { Text = "Min Cash", Default = 0, Min = 0, Max = 100000000, Rounding = 0, Compact = true })
nD = nq_2.Shop:AddRightGroupbox("Cosmetics", "sparkles")
nD:AddToggle("AutoBuyCosmetics", { Text = "Auto Buy Cosmetics", Default = false })
nD:AddDropdown("BuyCosmeticsList", { Values = mj, Multi = true, Searchable = true, AllowNull = true, Text = "Cosmetics", Default = {} })
nD:AddSlider("BuyCosmeticsDelay", { Text = "Buy Delay", Default = 0.45, Min = 0.1, Max = 3, Rounding = 2 })
nD:AddSlider("BuyCosmeticsMinCash", { Text = "Min Cash", Default = 0, Min = 0, Max = 100000000, Rounding = 0, Compact = true })
ny = nq_2.Floors:AddLeftGroupbox("Floor", "building-2")
ny:AddToggle("AutoUpgradeFloor", { Text = "Auto Upgrade Floor", Default = false })
ny:AddSlider("UpgradeFloorDelay", { Text = "Upgrade Delay", Default = 2, Min = 0.5, Max = 15, Rounding = 2 })
nw = nq_2.Floors:AddRightGroupbox("Upgrades", "arrow-big-up")
if nw and mJ and (not TempoHubGroup or not mJ) and ((not TempoHubGroup or mJ) and (mJ or CollectGroup)) or not (nw and mJ and (not TempoHubGroup or not mJ) and ((not TempoHubGroup or mJ) and (mJ or CollectGroup))) then
    nw:AddToggle("AutoBuyFloorUpgrades", { Text = "Auto Buy Floor Upgrades", Default = false })
    nw:AddDropdown("FloorUpgradeList", { Values = m7, Multi = true, Searchable = true, AllowNull = true, Text = "Upgrades", Default = {} })
    nw:AddSlider("FloorUpgradesDelay", { Text = "Buy Delay", Default = 0.35, Min = 0.1, Max = 3, Rounding = 2 })
    nw:AddSlider("FloorUpgradesMinCash", { Text = "Min Cash", Default = 0, Min = 0, Max = 100000000, Rounding = 0, Compact = true })
    task.spawn(worker10)
    task.spawn(worker9)
    task.spawn(worker8)
    task.spawn(worker7)
    task.spawn(worker6)
    task.spawn(worker5)
    task.spawn(worker4)
    task.spawn(worker3)
    task.spawn(worker2)
    MenuGroup = nq_2.Settings:AddLeftGroupbox("Menu", "menu")
else
    m7:AddToggle("AutoBuyFloorUpgrades", { Text = "Auto Buy Floor Upgrades", Default = false })
    m7:AddDropdown("FloorUpgradeList", {
        Multi = true,
        Searchable = true,
        Values = MenuGroup,
        AllowNull = true,
        Default = {},
        Text = "Upgrades"
    })
    m7:AddSlider("FloorUpgradesDelay", { Min = 0.1, Text = "Buy Delay", Rounding = 2, Default = 0.35, Max = 3 })
    m7:AddSlider("FloorUpgradesMinCash", { Text = "Min Cash", Max = 100000000, Rounding = 0, Min = 0, Compact = true, Default = 0 })
    task.spawn(worker10)
    task.spawn(worker9)
    task.spawn(worker8)
    task.spawn(worker7)
    task.spawn(worker6)
    task.spawn(worker5)
    task.spawn(worker4)
    task.spawn(worker3)
    task.spawn(worker2)
    nq_2 = nw.Settings:AddLeftGroupbox("Menu", "menu")
end
nc = tick()
m8 = tick()
pcall(function()
    for i, v in ipairs(getconnections(m5.Idled)) do
        local tp = v
        pcall(function()
            tp:Disable()
        end)
    end
end)
mQ = fn738
connection = nC.InputBegan:Connect(onInputBegan)
connection2 = nC.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(worker11)
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
mI.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddButton("Unload", onUnload)
mI:OnUnload(fn170)
nA:SetLibrary(mI)
nz:SetLibrary(mI)
nz:IgnoreThemeSettings()
nz:SetIgnoreIndexes({ "MenuKeybind" })
nA:SetFolder("TempoHub")
nz:SetFolder("TempoHub/build-a-garden-tower")
nA:SaveDefault("Monochrome")
nz:BuildConfigSection(nq_2.Settings)
nA:ApplyToTab(nq_2.Settings)
nA:LoadDefault()
nz:LoadAutoloadConfig()
end)(...)

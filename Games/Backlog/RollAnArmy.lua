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
getgenv().TempoHoodSubtitle = "ROLL AN ARMY!"
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
local v5_9, v5_15, v5_18, v5_25
local Options
local nq
local n7
local m7
local nP
local nw
local connection2
local nV
local oj
local nj
local Workspace
local m0
local UnitInfo
local np
local n6
local m6
local nO
local nv
local Label
local nc
local nU
local nB
local UserInputService
local DataService
local oq
local no
local SaveManager
local nN
local nu
local HttpService
local nb
local nT
local nA
local oh
local nh
local nZ
local nG
local op
local n4
local nM
local ox
local connection
local oa
local na
local og
local nY
local nF
local oo
local nm
local m3
local nL
local ow
local ns
local n9
local m9
local nR
local ny
local VirtualUser
local nf
local LocalPlayer
local nE
local om
local getUpgradeCost
local n2
local Toggles
local ov
local RebirthConfig
local n8
local m8
local nQ
local MutationInfo
local CurrentCamera2
local Library
local nW
local nD
local ol
local nk
local n1
local m1
local nJ
function fns.onCopyVenmoLink()
    op(oq, "Copied Venmo link")
end
function fns.fn33(an, ao, ap)
    return string.format("<b>%s</b> %s %s", an, nZ("-", "#5a6070"), nZ(ao, ap))
end
function fns.fn41()
    local p0_1
    local p__1
    p__1, p0_1 = pcall(function()
        return DataService.client:get()
    end)
    local p1 = p__1 and typeof(p0_1) == "table"
    if p1 then
        return p0_1
    end
    return nil
end
function fns.fn60()
    local rc = nu()
    if not rc then
        return
    end
    for i, child in ipairs(rc:GetChildren()) do
        if child:IsA("Tool") then
            child.Parent = LocalPlayer.Backpack
        end
    end
end
function fns.fn65()
    pcall(function()
        nb:FireServer()
    end)
end
function fns.fn82()
    local ua_1
    local t9_1
    if identifyexecutor then
        ua_1, t9_1 = identifyexecutor()
        local ub = ua_1 ~= ""
        local uc = type(ua_1) == "string" and ub
        if uc then
            local ub_1 = type(t9_1) == "string" and t9_1 ~= "" and ua_1 .. " " .. t9_1
            na = ub_1 or ua_1
        end
    end
end
function fns.fn89()
    if not Toggles.WalkSpeedEnabled.Value then
        local u_ = nm()
        if u_ then
            u_.WalkSpeed = 16
        end
    end
end
function fns.onRscripts()
    if setclipboard then
        setclipboard(nL)
    elseif toclipboard then
        toclipboard(nL)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
function fns.onCopyBitcoinAddress()
    op(nf, "Copied Bitcoin address")
end
function fns.onUnload()
    Library:Unload()
end
function fns.antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            ox(true)
        end
    end
end
function fns.fn136(ak, al)
    return string.format('<font color="%s">%s</font>', al, ak)
end
function fns.onCopyUSDTAddress()
    op(m6, "Copied USDT address")
end
function fns.fn175(aK)
    if Library.Unloaded then
        return false
    end
    local pJ = Toggles[aK]
    return pJ ~= nil and pJ.Value == true
end
function fns.onRollOnce()
    task.spawn(nq)
end
function fns.fn194()
    local s1 = om()
    if not s1 then
        return
    end
    local Money_Claim = s1:FindFirstChild("Money Claim")
    local s1_1 = Money_Claim and Money_Claim:FindFirstChild("Hitbox")
    local s2_1 = s1_1
    if s1_1 then
        s1_1 = s2_1:IsA("BasePart")
    end
    if s1_1 then
        nW(s2_1.Position)
        task.wait(0.35)
    end
    local s1_2 = oh()
    if s1_2 and s1_2.auto_collect_on ~= true then
        pcall(function()
            oj:FireServer()
        end)
    end
end
function fns.onInputChanged(hC)
    local UserInputType = hC.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        oa = tick()
    end
end
function fns.fn213(b8)
    if not b8 then
        return false
    end
    local qZ = nu()
    local q_ = nm()
    if not qZ or not q_ then
        return false
    end
    for i, child in ipairs(qZ:GetChildren()) do
        local q__1 = child ~= b8
        local q0_1 = child:IsA("Tool") and q__1
        if q0_1 then
            child.Parent = LocalPlayer.Backpack
        end
    end
    if b8.Parent ~= qZ then
        b8.Parent = qZ
    end
    return true
end
function fns.fn228()
    if not Toggles.Fly.Value then
        local uY = nm()
        if uY then
            uY.PlatformStand = false
        end
    end
end
function fns.fn271(bV)
    local qC = not bV or not bV:IsA("Tool")
    if qC then
        return nil
    end
    local attr2 = bV:GetAttribute("UnitName")
    local qD = attr2 == ""
    local qE = typeof(attr2) ~= "string" or qD
    if qE then
        return nil
    end
    local qD_1 = UnitInfo[attr2]
    if not qD_1 then
        return nil
    end
    local qE_1 = bV:GetAttribute("UnitId") or bV.Name
    local qF = tonumber(bV:GetAttribute("Level")) or 1
    local attr = bV:GetAttribute("Mutation")
    local Rarity = qD_1.Rarity
    local qI = tonumber(qD_1.Cost) or 0
    return {
        tool = bV,
        unitName = attr2,
        unitId = qE_1,
        level = qF,
        mutation = attr,
        rarity = Rarity,
        cost = qI,
        dps = nv(attr2, bV:GetAttribute("Level"), bV:GetAttribute("Mutation"))
    }
end
function fns.fn278()
    local vq = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local vr = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if vr then
                local vr_1 = nJ(k, v)
                if vr_1 then
                    vq[#vq + 1] = vr_1
                end
            end
        end
    end
    table.sort(vq, function(jj, jk)
        if jj.type ~= jk.type then
            return jj.type < jk.type
        end
        return jj.idx < jk.idx
    end)
    return { objects = vq }
end
function fns.fn285(aV)
    local pR = nA(aV, {})
    if typeof(pR) ~= "table" then
        return {}
    end
    local pS = {}
    for k, v in pairs(pR) do
        if v == true then
            pS[k] = true
        else
            local pR_1 = typeof(k) == "number" and typeof(v) == "string"
            if pR_1 then
                pS[v] = true
            end
        end
    end
    return pS
end
function fns.fn296(fj)
    local tx
    for i, v in ipairs(ny()) do
        local ty = n1(v)
        if ty then
            local tz = nA("PlaceMinRarity", "Common")
            if nD(ty.rarity) >= nD(tz) then
                local tA = not fj or ty.dps > fj
                if tA then
                    tA = not tx or ty.dps > tx.dps
                end
                if tA then
                    tx = ty
                end
            end
        end
    end
    return tx
end
function fns.fn309()
    local sW = m7("PlotExpansion")
    local sX = sW < math.huge and nV() >= sW
    if sX then
        pcall(function()
            m0:InvokeServer("PurchaseUpgrade", "PlotExpansion")
        end)
    end
end
function fns.onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local uJ_1 = nm()
        if uJ_1 then
            uJ_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
function fns.worker5()
    while not Library.Unloaded do
        task.wait(1.25)
        if nU("AutoCollect") then
            pcall(ns)
        end
        if nU("AutoSell") then
            pcall(n2)
        end
        if nU("AutoPlace") then
            pcall(nP)
        end
        if nU("AutoReplace") then
            pcall(nT)
        end
    end
end
function fns.onCopyPayPalLink()
    op(ow, "Copied PayPal link")
end
function fns.fn351(ad, ae)
    if setclipboard then
        setclipboard(ad)
    elseif toclipboard then
        toclipboard(ad)
    end
    Library:Notify(ae)
end
function fns.worker4()
    while not Library.Unloaded do
        task.wait(1)
        if nU("AutoBuyUpgrades") then
            pcall(m9)
        end
        if nU("AutoExpandPlot") then
            pcall(nR)
        end
        if nU("AutoBuySlots") then
            pcall(nE)
        end
        if nU("AutoGemShop") then
            pcall(nG)
        end
        if nU("AutoRebirth") then
            pcall(n7)
        end
    end
end
function fns.fn368()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    n4 = tick()
end
function fns.fn369()
    local qK = {}
    local qL = nu()
    if qL then
        for i, child in ipairs(qL:GetChildren()) do
            if child:IsA("Tool") then
                qK[#qK + 1] = child
            end
        end
    end
    for i, child in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if child:IsA("Tool") then
            qK[#qK + 1] = child
        end
    end
    return qK
end
function fns.onInputBegan()
    oa = tick()
end
function fns.fn451()
    local rA = oh()
    local rB = not rA
    local rC = {}
    if not rB then
        rB = typeof(rA.Slots) ~= "table"
    end
    if rB then
        return rC
    end
    for k, v in pairs(rA.Slots) do
        local rA_1 = typeof(v) == "table" and typeof(v.slotName) == "string"
        if rA_1 then
            rC[v.slotName] = v
        end
    end
    return rC
end
local function fn486()
    for i, v in ipairs(ny()) do
        local tp = Library.Unloaded or not nU("AutoSell")
        if tp then
            break
        end
        local tp_1 = n1(v)
        if ov(tp_1) then
            m1(v)
            task.wait(0.1)
            pcall(function()
                m0:InvokeServer("Sell One")
            end)
            task.wait(0.2)
        end
    end
    nY()
end
local function fn498()
    local s4 = oh()
    if not s4 then
        return
    end
    local GetRebirthCost = RebirthConfig.GetRebirthCost
    local s6 = tonumber(s4.Rebirths) or 0
    local s4_1 = GetRebirthCost(s6)
    if nV() >= s4_1 then
        pcall(function()
            oo:InvokeServer()
        end)
    end
end
local function fn499()
    local r1 = 0
    for k, v in pairs(ol()) do
        if v.purchased == true then
            r1 += 1
        end
    end
    return r1
end
local function worker2()
    while not Library.Unloaded do
        if nU("AutoRoll") then
            pcall(nq)
            task.wait(nA("AutoRollDelay", 2.5))
        else
            task.wait(0.35)
        end
    end
end
local function onExportConfigToClipboard()
    local vO_1
    local vN_1
    vN_1, vO_1 = pcall(HttpService.JSONEncode, HttpService, nw())
    if not vN_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local vN_2 = setclipboard or toclipboard
    local vN_3 = type(vN_2) ~= "function" or not pcall(vN_2, vO_1)
    if vN_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function fn531(cQ)
    local rU = oh()
    local rV = not rU or typeof(rU.UpgradeBoardLevels) ~= "table"
    if rV then
        return 0
    end
    local rV_1 = tonumber(rU.UpgradeBoardLevels[cQ]) or 0
    return rV_1
end
local function onCopyJoinScript_JobID()
    local ue = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, n6)
    if setclipboard then
        setclipboard(ue)
    elseif toclipboard then
        toclipboard(ue)
    end
    Library:Notify("Copied join script to clipboard")
end
local function onImportConfigFromClipboardTex()
    local vT_1
    local vR = Options.SaveManager_ImportSource.Value or ""
    local vR_1
    local vS = tostring(vR):match("^%s*(.-)%s*$")
    if vS == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    vR_1, vT_1 = pcall(HttpService.JSONDecode, HttpService, vS)
    local vS_1 = not vR_1 or type(vT_1) ~= "table" or type(vT_1.objects) ~= "table"
    if vS_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local vR_2 = 0
    for i, v in ipairs(vT_1.objects) do
        if n8(v) then
            vR_2 += 1
        end
    end
    if vR_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local vT_2 = vR_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(vR_2, vT_2), 6)
end
local function worker3()
    while not Library.Unloaded do
        task.wait(0.75)
        if nU("AutoBuy") then
            pcall(nh)
        end
    end
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local u1 = tick() - oa
            local u2 = tick() - n4
            if u1 >= 300 and u2 >= 60 then
                pcall(nO)
            else
                if u1 < 300 and u2 >= 300 then
                    pcall(nO)
                end
            end
        end
    end
end
local function fn572(gp)
    local DiscordGroup = gp:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = n9 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = n9 })
end
local function onRenderStepped(ic)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local uO_1 = nm()
        if uO_1 then
            uO_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local uO_3 = m8()
        local uP = nm()
        if uO_3 and uP then
            uP.PlatformStand = true
            local uP_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                uP_1 = uP_1 + CurrentCamera2.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                uP_1 = uP_1 - CurrentCamera2.CFrame.LookVector
            end
            local uX = if UserInputService:IsKeyDown(Enum.KeyCode.A) then 1 else 0
            if uX == 1 then
                uP_1 = uP_1 - CurrentCamera2.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                uP_1 = uP_1 + CurrentCamera2.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                uP_1 = uP_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                uP_1 = uP_1 - Vector3.new(0, 1, 0)
            end
            uO_3.Velocity = Vector3.zero
            if uP_1.Magnitude > 0 then
                uO_3.CFrame = uO_3.CFrame + uP_1.Unit * Options.FlySpeed.Value * ic
            end
        end
    end
end
local function fn602(eZ)
    if not eZ then
        return false
    end
    local tk = nD(nA("SellMaxRarity", "Common"))
    if nD(eZ.rarity) > tk then
        return false
    end
    local tk_1 = nA("SellMaxCost", 100000)
    if eZ.cost > tk_1 then
        return false
    end
    local tk_2 = nA("SellMaxDps", 100000)
    if eZ.dps > tk_2 then
        return false
    end
    return true
end
local function worker()
    local uh_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local ug = math.floor(os.clock() - nM)
        if ug < 60 then
            uh_1 = ug .. "s"
        elseif ug < 3600 then
            uh_1 = string.format("%dm %ds", math.floor((ug) / (60)), ug % 60)
        else
            uh_1 = string.format("%dh %dm", math.floor((ug) / (3600)), math.floor((ug % 3600) / (60)))
        end
        Label:SetText(nN("Session time", uh_1, np))
    end
end
local function onCopySolanaAddress()
    op(m3, "Copied Solana address")
end
local function fn621()
    pcall(function()
        connection:Disconnect()
    end)
    pcall(function()
        connection2:Disconnect()
    end)
    ox(false)
    local v0 = nm()
    if v0 then
        v0.PlatformStand = false
        v0.WalkSpeed = 16
    end
end
local function onCopyEthereumAddress()
    op(nc, "Copied Ethereum address")
end
local function fn652(K, L)
    return K.order < L.order
end
local function fn664()
    local qc = nu()
    local qd = qc and qc:FindFirstChild("HumanoidRootPart")
    return qd
end
local function fn687()
    op(nQ, "Copied Discord invite to clipboard")
end
local function fn696(aQ, aR)
    local pP = Options[aQ]
    if pP == nil then
        return aR
    end
    return pP.Value
end
local function fn718(bx)
    local qn = m8()
    local qo = not qn or typeof(bx) ~= "Vector3"
    if qo then
        return false
    end
    qn.CFrame = CFrame.new(bx + Vector3.new(0, 3, 0))
    return true
end
local function fn734(cn)
    local rk = cn
    local rl = {}
    if rk then
        rk = cn:FindFirstChild("Plot Layers")
    end
    local rm = rk
    if not rm then
        return rl
    end
    for i, child in ipairs(rm:GetChildren()) do
        local Slots = child:FindFirstChild("Slots")
        if Slots then
            for i, child in ipairs(Slots:GetChildren()) do
                local rk_2 = child:IsA("Model") and child:FindFirstChild("UnitPlacement")
                if rk_2 then
                    rl[#rl + 1] = child
                end
            end
        end
    end
    table.sort(rl, function(cx, cy)
        return cx.Name < cy.Name
    end)
    return rl
end
local function fn763(c9, da)
    local r9 = nk(da)
    if not next(r9) then
        return true
    end
    return r9[c9] == true
end
local function fn767(i2, i3)
    local va_1 = (i2 == "Toggle" and Toggles or Options)[i3]
    local u9_2 = type(va_1) == "table" and va_1.Type == i2
    return u9_2 and va_1 or nil
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local uB_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if uB_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function fn818()
    local p9 = nu()
    local qa = p9 and p9:FindFirstChildOfClass("Humanoid")
    return qa
end
local function fn845(i8, i9)
    local Type = i9.Type
    if Type == "Toggle" then
        return { idx = i8, type = "Toggle", value = i9.Value == true }
    elseif Type == "Slider" then
        return { idx = i8, type = "Slider", value = tostring(i9.Value) }
    elseif Type == "Dropdown" then
        return { idx = i8, type = "Dropdown", multi = i9.Multi == true, value = i9.Value }
    elseif Type == "Input" then
        local vh = i9.Value
        local vl = if vh then 1 else 0
        local vj = 3053 * vl + 2590 * (1 - vl)
        local vk = 1328 * vl + 1763 * (1 - vl)
        if not ((vj * 8 + vk * 3305 + vj * vk) % 16777213 == 8467848) then
            vh = ""
        end
        return { idx = i8, type = "Input", text = tostring(vh) }
    elseif Type == "ColorPicker" then
        return { idx = i8, type = "ColorPicker", value = i9.Value:ToHex(), transparency = i9.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = i8,
            type = "KeyPicker",
            mode = i9.Mode,
            key = i9.Value,
            modifiers = i9.Modifiers,
            toggled = i9.Toggled
        }
    else
        return nil
    end
end
local function onCopyLitecoinAddress()
    op(nj, "Copied Litecoin address")
end
local function fn870(bF, bG, bH)
    local qs = UnitInfo[bF]
    if not qs then
        return 0
    end
    local qt = tonumber(qs.BaseDPS) or 0
    local qt_1 = tonumber(bG) or 1
    local qt_2 = oh()
    local qv = qt_2
    local qw = 1
    if qv then
        qv = qt_2.PermUpgrades
    end
    if qv then
        qv = qt_2.PermUpgrades.DamageMulti
    end
    if qv then
        local qv_1 = (tonumber(qt_2.PermUpgrades.DamageMulti))
        local qB = if qv_1 then 1 else 0
        local qz = 3951 * qB + 1131 * (1 - qB)
        local qA = 2243 * qB + 3083 * (1 - qB)
        if not ((qz * 1340 + qA * 3804 + qz * qA) % 16777213 == 5911592) then
            qv_1 = 1
        end
        qw = qv_1
    end
    local qt_3 = 1
    local qv_2 = bH ~= ""
    local qx = typeof(bH) == "string" and qv_2
    if qx then
        local qv_3 = MutationInfo[bH]
        if qv_3 and qv_3.DamageMultiplier then
            local qx_2 = tonumber(qv_3.DamageMultiplier) or 1
            qt_3 = qx_2
        end
    end
    return math.floor(qt + (qt_1 - 1) * (qt / 3) * qw) * qt_3
end
local function fn890()
    local rK = oh()
    local rL = not rK
    local rM = {}
    if not rL then
        rL = typeof(rK.units) ~= "table"
    end
    if rL then
        return rM
    end
    for k, v in pairs(rK.units) do
        local rK_1 = typeof(v) == "table" and typeof(v.unitId) == "string"
        if rK_1 then
            rM[v.unitId] = v
        end
    end
    return rM
end
local function fn922()
    local p3 = oh()
    local p4 = p3 and tonumber(p3.Money)
    return p4 or 0
end
local function fn932(bC)
    return og[bC] or 0
end
local function fn934()
    local Plots = Workspace:FindFirstChild("Plots")
    if not Plots then
        return nil
    end
    for i, child in ipairs(Plots:GetChildren()) do
        local qf_1 = child:GetAttribute("OwnerId") == LocalPlayer.UserId or child:GetAttribute("OwnerUserId") == LocalPlayer.UserId
        if qf_1 then
            return child
        end
    end
    return nil
end
local function fn940()
    return LocalPlayer.Character
end
local function fn943(cV)
    local rX = nF[cV]
    if not rX then
        return math.huge
    end
    local rY = no(cV)
    local rZ = nB[cV]
    if rZ and rY >= rZ then
        return math.huge
    end
    return getUpgradeCost.GetUpgradeCost(rX, math.max(rY, 1))
end
local function fn962()
    ox(Toggles.AntiGameplayPause.Value)
end
m0 = nil
m1 = nil
Toggles = nil
m3 = nil
SaveManager = nil
m6 = nil
m7 = nil
m8 = nil
m9 = nil
na = nil
nb = nil
nc = nil
connection2 = nil
Library = nil
nf = nil
nh = nil
DataService = nil
nj = nil
nk = nil
getUpgradeCost = nil
nm = nil
no = nil
np = nil
nq = nil
RebirthConfig = nil
ns = nil
connection = nil
nu = nil
nv = nil
nw = nil
MutationInfo = nil
ny = nil
nA = nil
nB = nil
nD = nil
nE = nil
nF = nil
nG = nil
UnitInfo = nil
nJ = nil
nL = nil
nM = nil
nN = nil
local Buy_Unit, ng, GetSlotCost, nz, nC, nH, nK
nO = nil
nP = nil
nQ = nil
nR = nil
nT = nil
nU = nil
nV = nil
nW = nil
LocalPlayer = nil
nY = nil
nZ = nil
Workspace = nil
n1 = nil
n2 = nil
n4 = nil
n6 = nil
n7 = nil
n8 = nil
n9 = nil
oa = nil
HttpService = nil
Label = nil
CurrentCamera2 = nil
VirtualUser = nil
og = nil
oh = nil
UserInputService = nil
oj = nil
ol = nil
om = nil
oo = nil
op = nil
oq = nil
Options = nil
ov = nil
ow = nil
ox = nil
local nS, n_, CoreGui, GuiService, od, ot
nS = nil
n_ = nil
CoreGui = nil
GuiService = nil
od = nil
ot = nil
local DonationsGroup
UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, LocalPlayer, nQ, nL, UnitInfo, v5_18, MutationInfo, RebirthConfig, GetSlotCost, getUpgradeCost, DataService, nb, Buy_Unit, m0, ot, oo, oj, og = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local v5_30 = game:GetService("Players")
local v5_32 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
LocalPlayer = v5_30.LocalPlayer
local v5_21 = "Roll an Army"
nQ = "https://discord.gg/K7Qxnxkk46"
if ((nb and not CoreGui or not ot and not MutationInfo) and (v5_18 and not MutationInfo and (CoreGui and not v5_18)) or ((not CoreGui or not ot) and (not ot or nb) or MutationInfo and not MutationInfo and (MutationInfo and MutationInfo))) and not ((nb and not CoreGui or not ot and not MutationInfo) and (v5_18 and not MutationInfo and (CoreGui and not v5_18)) or ((not CoreGui or not ot) and (not ot or nb) or MutationInfo and not MutationInfo and (MutationInfo and MutationInfo))) then
    v5_32 = "https://discord.gg/K7Qxnxkk46"
    nL = require(UnitInfo:WaitForChild("Utility"):WaitForChild("Info"):WaitForChild("UnitInfo"))
else
    nL = "https://discord.gg/K7Qxnxkk46"
    UnitInfo = require(v5_32:WaitForChild("Utility"):WaitForChild("Info"):WaitForChild("UnitInfo"))
end
v5_18 = require(v5_32:WaitForChild("Utility"):WaitForChild("Info"):WaitForChild("Rarities"))
local v5_6 = require(v5_32:WaitForChild("Utility"):WaitForChild("Info"):WaitForChild("BoardInfo"))
MutationInfo = require(v5_32:WaitForChild("Utility"):WaitForChild("Info"):WaitForChild("MutationInfo"))
local v5_34 = require(v5_32:WaitForChild("Utility"):WaitForChild("Info"):WaitForChild("CrateInfo"))
RebirthConfig = require(v5_32:WaitForChild("Utility"):WaitForChild("Info"):WaitForChild("RebirthConfig"))
GetSlotCost = require(v5_32:WaitForChild("Utility"):WaitForChild("Prices"):WaitForChild("GetSlotCost"))
getUpgradeCost = require(v5_32:WaitForChild("Utility"):WaitForChild("Prices"):WaitForChild("getUpgradeCost"))
DataService = require(v5_32:WaitForChild("Data"):WaitForChild("DataService"))
local v5_16 = v5_32:WaitForChild("Remotes")
if (not ot or not MutationInfo) and (not VirtualUser or not MutationInfo) and (not ot and not VirtualUser or (not VirtualUser or ot)) or not ((not ot or not MutationInfo) and (not VirtualUser or not MutationInfo) and (not ot and not VirtualUser or (not VirtualUser or ot))) then
    nb = v5_16:WaitForChild("RollRequest")
    Buy_Unit = v5_16:WaitForChild("Buy Unit")
    m0 = v5_16:WaitForChild("InteractPlot")
    ot = v5_16:WaitForChild("PurchaseGemShop")
else
    v5_16 = Buy_Unit:WaitForChild("RollRequest")
    m0 = Buy_Unit:WaitForChild("Buy Unit")
    ot = Buy_Unit:WaitForChild("InteractPlot")
    nb = Buy_Unit:WaitForChild("PurchaseGemShop")
end
if (not RebirthConfig or not LocalPlayer) and (not LocalPlayer or RebirthConfig) or (not LocalPlayer or RebirthConfig or (not LocalPlayer or RebirthConfig)) or not ((not RebirthConfig or not LocalPlayer) and (not LocalPlayer or RebirthConfig) or (not LocalPlayer or RebirthConfig or (not LocalPlayer or RebirthConfig))) then
    oo = v5_16:WaitForChild("Rebirth")
    oj = v5_16:WaitForChild("AutoCollect")
    og = {}
    v5_9 = {}
else
    oj = og:WaitForChild("Rebirth")
    v5_9 = og:WaitForChild("AutoCollect")
    oo = {}
end
local v5_24 = {}
for k, v in pairs(v5_18) do
    v5_30 = #v5_24 + 1
    v5_16 = v.Order or 0
    v5_24[v5_30] = { name = k, order = v5_16 }
end
local v5_4 = 3
repeat
    v5_30 = (vector.create((v5_4 * 4 + 9) % 11 + 1, (v5_4 * 2 + 11) % 13 + 1, (v5_4 * 6 + 3) % 17 + 1))
    v5_16 = (vector.create((v5_4 * 3 + 9) % 11 + 1, (v5_4 * 1 + 6) % 13 + 1, (v5_4 * 11 + 17) % 17 + 1))
    v5_32 = (vector.create((v5_4 * 1 + 5) % 5 + 1, (v5_4 * 5 + 3) % 7 + 1, (v5_4 * 4 + 5) % 9 + 1))
    if math.abs((vector.angle(v5_30, v5_16, v5_32))) - math.abs((vector.angle(v5_16, v5_30, v5_32))) == 5 then
        table.sort(v5_24, fn652)
    else
        table.sort(v5_24, fn652)
    end
    v5_4 = (v5_4 + 1) % 4
until (v5_4 * 1 + 0) % 4 == 0
for i, v in ipairs(v5_24) do
    og[v.name] = v.order
    v5_9[#v5_9 + 1] = v.name
end
nK, nF, nB, nz = nil, nil, nil, nil
v5_30 = 7
repeat
    v5_16 = {
        "wdlgfsknr",
        "oluiofdib",
        "kanl",
        "sfurbk",
        "qram",
        "gydyvrs",
        "tdcgw",
        "znxzdbdvz",
        "mwtycr",
        "pgoj",
        "nilofermz"
    }
    local wP = v5_30
    v5_4 = v5_16[wP % 11 + 1]
    if v5_4:len() <= v5_4:gsub("(.)", "%1%1", wP % 3 % 2 + 1):len() then
        nK = {
            "Roll Luck",
            "Number Rolls",
            "Money Multiplier",
            "Damage Upgrade",
            "PlotExpansion",
            "Zombie Tier Upgrade"
        }
        nF = {
            ["Roll Luck"] = v5_6.RollUpgrades["Roll Luck"].BaseUpgradeCost,
            ["Number Rolls"] = v5_6.RollUpgrades["Number Rolls"].BaseUpgradeCost,
            ["Money Multiplier"] = v5_6.BaseUpgrades["Money Multiplier"].BaseUpgradeCost,
            ["Damage Upgrade"] = v5_6.BaseUpgrades["Damage Upgrade"].BaseUpgradeCost,
            PlotExpansion = v5_6.PlotExpansion.BaseUpgradeCost,
            ["Zombie Tier Upgrade"] = v5_6["Zombie Tier Upgrade"].BaseUpgradeCost
        }
        nB = {
            ["Roll Luck"] = v5_6.RollUpgrades["Roll Luck"].upgradeMax,
            ["Number Rolls"] = v5_6.RollUpgrades["Number Rolls"].upgradeMax,
            ["Money Multiplier"] = v5_6.BaseUpgrades["Money Multiplier"].upgradeMax,
            ["Damage Upgrade"] = v5_6.BaseUpgrades["Damage Upgrade"].upgradeMax,
            PlotExpansion = v5_6.PlotExpansion.upgradeMax,
            ["Zombie Tier Upgrade"] = v5_6["Zombie Tier Upgrade"].upgradeMax
        }
        nz = {}
    else
        nz = {
            "Money Multiplier",
            "Roll Luck",
            "Zombie Tier Upgrade",
            "Damage Upgrade",
            "Number Rolls",
            "PlotExpansion"
        }
        nB = {
            PlotExpansion = nK.PlotExpansion.BaseUpgradeCost,
            ["Zombie Tier Upgrade"] = nK["Zombie Tier Upgrade"].BaseUpgradeCost,
            ["Damage Upgrade"] = nK.BaseUpgrades["Damage Upgrade"].BaseUpgradeCost,
            ["Roll Luck"] = nK.RollUpgrades["Roll Luck"].BaseUpgradeCost,
            ["Number Rolls"] = nK.RollUpgrades["Number Rolls"].BaseUpgradeCost,
            ["Money Multiplier"] = nK.BaseUpgrades["Money Multiplier"].BaseUpgradeCost
        }
        nF = {
            PlotExpansion = nK.PlotExpansion.upgradeMax,
            ["Number Rolls"] = nK.RollUpgrades["Number Rolls"].upgradeMax,
            ["Roll Luck"] = nK.RollUpgrades["Roll Luck"].upgradeMax,
            ["Damage Upgrade"] = nK.BaseUpgrades["Damage Upgrade"].upgradeMax,
            ["Zombie Tier Upgrade"] = nK["Zombie Tier Upgrade"].upgradeMax,
            ["Money Multiplier"] = nK.BaseUpgrades["Money Multiplier"].upgradeMax
        }
        v5_6 = {}
    end
    v5_30 = (v5_30 + 1) % 8
until (v5_30 * 1 + 1) % 8 == 1
for k, v in pairs(MutationInfo) do
    if v.GemShop == true then
        nz[#nz + 1] = k
    end
end
for k, v in pairs(v5_34) do
    if v.GemShop == true then
        nz[#nz + 1] = k
    end
end
table.sort(nz)
Library, SaveManager, Toggles, Options, np, nj, nf, nc, m6, m3, ow, oq, op, n9, nZ, nN, nU, nA, nk, oh, nV, v5_4, nu, nm, m8, om, nW, nD, nv, n1, ny, m1, nY, nC, ol, nS, no, m7, n_, nH, nq, nh, m9, nE, nR, ns, n7, nG, ov, n2, ng, nP, nT = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
v5_6 = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
op = fns.fn351
n9 = fn687
nZ = fns.fn136
nN = fns.fn33
local v5_10 = "#7fd47f"
v5_24 = "#6ec1ff"
np = "#e8a34d"
v5_34 = "#8b93a3"
nj = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
nf = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
nc = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
m6 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
m3 = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
ow = ""
oq = ""
local v5_28 = "#345d9d"
local v5_1 = "#f7931a"
local v5_13 = "#627eea"
local v5_27 = "#26a17b"
local v5_39 = "#14f195"
local v5_12 = "#0070ba"
if (not v5_4 and v5_4 or "" or (v5_4 or v5_4) and false) and ("" and (false or (not v5_4 or v5_4))) or not ((not v5_4 and v5_4 or "" or (v5_4 or v5_4) and false) and ("" and (false or (not v5_4 or v5_4)))) then
    v5_25 = "#008cff"
    nU = fns.fn175
    nA = fn696
    nk = fns.fn285
    oh = fns.fn41
else
    nU = "#008cff"
    oh = fns.fn175
    nk = fn696
    v5_25 = fns.fn285
    nA = fns.fn41
end
nV = fn922
nu = fn940
nm = fn818
m8 = fn664
om = fn934
nW = fn718
nD = fn932
nv = fn870
n1 = fns.fn271
ny = fns.fn369
m1 = fns.fn213
nY = fns.fn60
nC = fn734
ol = fns.fn451
nS = fn890
no = fn531
m7 = fn943
n_ = fn499
nH = fn763
nq = fns.fn65
nh = function()
    local sb = om()
    if not sb then
        return
    end
    local Podiums = sb:FindFirstChild("Podiums")
    local sc_3
    if not Podiums then
        return
    end
    local sb_1 = nA("AutoBuyMaxPrice", 100000)
    local sd = nV()
    for i, child in ipairs(Podiums:GetChildren()) do
        local sq = child
        local sc_1 = Library.Unloaded or not nU("AutoBuy")
        if sc_1 then
            break
        end
        for i, child in ipairs(sq:GetChildren()) do
            local sw = child
            if sw:IsA("Model") then
                local sc_2 = UnitInfo[sw.Name]
                if sc_2 then
                    local se = tonumber(sc_2.Cost) or math.huge
                    local se_2
                    local se_1 = se <= sb_1 and se <= sd and nH(sc_2.Rarity, "AutoBuyRarities")
                    if se_1 then
                        sc_3, se_2 = pcall(function()
                            return Buy_Unit:InvokeServer(sw.Name, sq.Name)
                        end)
                        if sc_3 and se_2 == "Success" then
                            sd = nV()
                        end
                        task.wait(0.15)
                    end
                end
            end
        end
    end
end
m9 = function()
    local sx = nk("UpgradeSelect")
    if not next(sx) then
        return
    end
    for i, v in ipairs(nK) do
        local sG = v
        local sy = Library.Unloaded or not nU("AutoBuyUpgrades")
        if sy then
            break
        elseif sx[sG] then
            local sy_1 = m7(sG)
            local sz = sy_1 < math.huge and nV() >= sy_1
            if sz then
                pcall(function()
                    m0:InvokeServer("PurchaseUpgrade", sG)
                end)
                task.wait(0.2)
            end
        end
    end
end
nE = function()
    local sH = om()
    local sH_4
    if not sH then
        return
    end
    local sI = ol()
    for i, v in ipairs(nC(sH)) do
        local sV = v
        local sH_1 = Library.Unloaded or not nU("AutoBuySlots")
        if sH_1 then
            break
        else
            local sH_2 = sI[sV.Name]
            local sJ = not sH_2 or sH_2.purchased ~= true
            local sJ_1
            if sJ then
                local sH_3 = GetSlotCost.getcost(n_())
                if nV() >= sH_3 then
                    sH_4, sJ_1 = pcall(function()
                        return m0:InvokeServer("PurchaseSlot", sV)
                    end)
                    if sH_4 and sJ_1 == "Success" then
                        task.wait(0.25)
                    else
                        break
                    end
                else
                    break
                end
            end
        end
    end
end
nR = fns.fn309
ns = fns.fn194
n7 = fn498
nG = function()
    local s8 = nk("GemShopSelect")
    if not next(s8) then
        return
    end
    for i, v in ipairs(nz) do
        local tj = v
        local s9 = Library.Unloaded or not nU("AutoGemShop")
        if s9 then
            break
        elseif s8[tj] then
            pcall(function()
                ot:InvokeServer("Purchase", tj)
            end)
            task.wait(0.2)
        end
    end
end
ov = fn602
n2 = fn486
ng = fns.fn296
nP = function()
    local tI = om()
    local tI_4
    if not tI then
        return
    end
    local tJ = ol()
    for i, v in ipairs(nC(tI)) do
        local tT = v
        local tI_1 = Library.Unloaded or not nU("AutoPlace")
        if tI_1 then
            break
        else
            local tI_2 = tJ[tT.Name]
            local tK = tI_2 and tI_2.purchased == true
            local tK_1
            if tK then
                local tL_1 = typeof(tI_2.unitPlaced) ~= "string" or tI_2.unitPlaced == ""
                tK = tL_1
            end
            if tK then
                local tI_3 = ng(nil)
                if not tI_3 then
                    break
                end
                m1(tI_3.tool)
                task.wait(0.1)
                tI_4, tK_1 = pcall(function()
                    return m0:InvokeServer("PlaceUnit", tT)
                end)
                nY()
                task.wait(0.2)
                if not tI_4 or tK_1 ~= "Success" then
                    break
                end
                tJ = ol()
            end
        end
    end
end
nT = function()
    local tX = om()
    if not tX then
        return
    end
    local tY = ol()
    local tZ = nS()
    local t_ = nA("ReplaceMinDpsGain", 1)
    for i, v in ipairs(nC(tX)) do
        local t8 = v
        local tX_1 = Library.Unloaded or not nU("AutoReplace")
        if tX_1 then
            break
        else
            local tX_2 = tY[t8.Name]
            local t0 = tX_2 and tX_2.purchased == true and typeof(tX_2.unitPlaced) == "string" and tX_2.unitPlaced ~= ""
            if t0 then
                local t0_1 = tZ[tX_2.unitPlaced]
                local tX_3 = 0
                if t0_1 then
                    tX_3 = nv(t0_1.UnitName, t0_1.level, t0_1.Mutation)
                end
                local t0_2 = ng(tX_3 + t_ - 0.001)
                if t0_2 and t0_2.dps >= tX_3 + t_ then
                    pcall(function()
                        m0:InvokeServer("RemoveUnit", t8)
                    end)
                    task.wait(0.2)
                    m1(t0_2.tool)
                    task.wait(0.1)
                    pcall(function()
                        m0:InvokeServer("PlaceUnit", t8)
                    end)
                    nY()
                    task.wait(0.25)
                    tY = ol()
                    tZ = nS()
                end
            end
        end
    end
end
v5_16 = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = nQ, Copyable = true }, "|", v5_21 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
local v5_38 = {
    Info = v5_16:AddTab("Info", "info"),
    Main = v5_16:AddTab("Main", "gamepad-2"),
    Player = v5_16:AddTab("Player", "person-standing"),
    Settings = v5_16:AddTab("Settings", "settings")
}
v5_38.Roll = v5_38.Main:AddSubTab("Roll", "dices")
v5_38.Plot = v5_38.Main:AddSubTab("Plot", "map-pin")
v5_38.Shop = v5_38.Main:AddSubTab("Shop", "store")
v5_18 = fn572
for k, v in v5_38 do
    if v ~= v5_38.Main then
        v5_18(v)
    end
end
na, v5_30, v5_32, Label, n6, v5_4 = nil, nil, nil, nil, nil, nil
v5_16 = 4
repeat
    v5_18 = (v5_16 * 2 + 0) % 3 + 1
    if v5_18 <= 2 then
        if v5_18 <= 1 then
            if (not v5_30 or v5_30) and (v5_30 and v5_30) and (v5_30 and not na or not v5_30 and not na) or not ((not v5_30 or v5_30) and (v5_30 and v5_30) and (v5_30 and not na or not v5_30 and not na)) then
                n6 = tostring(game.JobId)
            else
                v5_32 = tostring(game.JobId)
            end
            v5_16 = (v5_16 + 11) % 24
        else
            if v5_16 * 88712887 + 4 + 7 >= v5_16 * 88712887 + 4 + 7 + 2 then
                n6 = #v5_4 > 18
            else
                v5_4 = #n6 > 18
            end
            v5_16 = (v5_16 + 20) % 24
        end
    else
        v5_18 = {
            "qvuic",
            "jnmq",
            "vdmkrk",
            "dtpszrupd",
            "hhnbmlrd",
            "whzbgj",
            "sogmz",
            "cvtood",
            "gkplqk",
            "uqfaf",
            "waqoyftnc"
        }
        local wJ = v5_16
        v5_15 = v5_18[wJ % 11 + 1]
        if v5_15:len() <= v5_15:gsub("(.)", "%1%1", wJ % 3 % 2 + 1):len() then
            na = "Unknown"
            pcall(fns.fn82)
            v5_30 = v5_38.Info:AddLeftGroupbox("Account", "circle-user")
            v5_30:AddLabel(nN("User", LocalPlayer.Name, v5_10), true)
            v5_30:AddLabel(nN("Status", "Keyless", v5_10), true)
            v5_30:AddLabel(nN("Executor", na, v5_10), true)
            v5_32 = v5_38.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            v5_32:AddLabel(nZ(v5_21 .. " [" .. tostring(game.PlaceId) .. "]", v5_24), true)
            v5_32:AddLabel(nN("Place ID", tostring(game.PlaceId), v5_24), true)
            Label = v5_32:AddLabel(nN("Session time", "0s", np), true)
        else
            np = "Unknown"
            pcall(fns.fn82)
            v5_21 = nN.Info:AddLeftGroupbox("Account", "circle-user")
            v5_21:AddLabel(v5_24("User", v5_32.Name, Label), true)
            v5_21:AddLabel(v5_24("Status", "Keyless", Label), true)
            v5_21:AddLabel(v5_24("Executor", np, Label), true)
            v5_10 = nN.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            v5_10:AddLabel(v5_30(na .. " [" .. tostring(game.PlaceId) .. "]", v5_38), true)
            v5_10:AddLabel(v5_24("Place ID", tostring(game.PlaceId), v5_38), true)
            nZ = v5_10:AddLabel(v5_24("Session time", "0s", LocalPlayer), true)
        end
        v5_16 = (v5_16 + 17) % 24
    end
until (v5_16 * 17 + 17) % 24 == 13
if v5_4 then
    v5_30 = 0
    repeat
        v5_16 = (vector.create((v5_30 * 2 + 4) % 11 + 1, (v5_30 * 8 + 8) % 13 + 1, (v5_30 * 5 + 11) % 17 + 1))
        v5_18 = (vector.create((v5_30 * 6 + 7) % 11 + 1, (v5_30 * 6 + 11) % 13 + 1, (v5_30 * 7 + 15) % 17 + 1))
        v5_15 = (vector.create((v5_30 * 1 + 3) % 5 + 1, (v5_30 * 2 + 3) % 7 + 1, (v5_30 * 5 + 4) % 9 + 1))
        if math.abs((vector.angle(v5_16, v5_18, v5_15))) - math.abs((vector.angle(v5_18, v5_16, v5_15))) == 0 then
            v5_4 = string.sub(n6, 1, 18) .. "..."
        else
            n6 = string.sub(v5_4, 1, 18) .. "..."
        end
        v5_30 = (v5_30 + 7) % 8
    until (v5_30 * 3 + 4) % 8 == 1
end
v5_30 = v5_4 or n6
nM, v5_16, DonationsGroup, oa, n4, connection, connection2, CurrentCamera2, nO, ox, od, nJ, nw, n8 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local o2 = v5_30
v5_32:AddLabel(nN("Server", o2, v5_34), true)
v5_32:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
nM = os.clock()
task.spawn(worker)
local ScriptsGroup = v5_38.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(nZ("Included in this hub", v5_34), true)
ScriptsGroup:AddLabel(nZ(v5_21, v5_24), true)
local FeaturesGroup = v5_38.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(nZ("Auto Roll / Buy", v5_24), true)
FeaturesGroup:AddLabel(nZ("Auto Place / Replace", np), true)
FeaturesGroup:AddLabel(nZ("Auto Upgrades / Slots / Expand", v5_10), true)
FeaturesGroup:AddLabel(nZ("Auto Sell / Collect / Gem Shop / Rebirth", v5_34), true)
local SocialsGroup = v5_38.Info:AddRightGroupbox("Socials", "link")
if (od and SocialsGroup and (od and not SocialsGroup) or (not oa and not od or not od and not od)) and not (od and SocialsGroup and (od and not SocialsGroup) or (not oa and not od or not od and not od)) then
    v5_16:AddButton({ Text = "Discord", Func = v5_38 })
    v5_16:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
    n9 = SocialsGroup.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
else
    SocialsGroup:AddButton({ Text = "Discord", Func = n9 })
    SocialsGroup:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
    v5_16 = v5_38.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
end
if (n8 and not connection or (CurrentCamera2 or not CurrentCamera2) or (not connection and not connection or (nO or not CurrentCamera2))) and (not connection and not CurrentCamera2 or not nO and n8 or (not nO or not CurrentCamera2 or (not connection or not nO))) and not ((n8 and not connection or (CurrentCamera2 or not CurrentCamera2) or (not connection and not connection or (nO or not CurrentCamera2))) and (not connection and not CurrentCamera2 or not nO and n8 or (not nO or not CurrentCamera2 or (not connection or not nO)))) then
    DonationsGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
    DonationsGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
    DonationsGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
    DonationsGroup:AddButton({ Text = "Copy Discord Invite", Func = v5_38 })
    n9 = v5_16.Info:AddRightGroupbox("Donations", "heart")
else
    v5_16:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
    v5_16:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
    v5_16:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
    v5_16:AddButton({ Text = "Copy Discord Invite", Func = n9 })
    DonationsGroup = v5_38.Info:AddRightGroupbox("Donations", "heart")
end
DonationsGroup:AddLabel(nZ("All donations are optional but appreciated.", np), true)
DonationsGroup:AddLabel(nZ("If you donate you get a special role, just PING after you donate.", v5_10), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(nZ("LTC / Litecoin", v5_28), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(nZ("BTC / Bitcoin", v5_1), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = fns.onCopyBitcoinAddress })
DonationsGroup:AddLabel(nZ("ETH / Ethereum", v5_13), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(nZ("USDT", v5_27), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = fns.onCopyUSDTAddress })
DonationsGroup:AddLabel(nZ("Solana", v5_39), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(nZ("PayPal", v5_12), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = fns.onCopyPayPalLink })
DonationsGroup:AddLabel(nZ("Venmo", v5_25), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = fns.onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(nZ("Don't have any of the listed currencies but still wanna donate?", v5_34), true)
DonationsGroup:AddLabel(nZ("DM me and we'll work something out.", v5_24), true)
local FaqGroup = v5_38.Info:AddRightGroupbox("FAQ", "circle-help")
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
local AutoRollGroup = v5_38.Roll:AddLeftGroupbox("Auto Roll", "dices")
AutoRollGroup:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
AutoRollGroup:AddSlider("AutoRollDelay", { Text = "Roll Delay", Default = 2.5, Min = 1, Max = 8, Rounding = 2 })
AutoRollGroup:AddButton({ Text = "Roll Once", Func = fns.onRollOnce })
local AutoBuyGroup = v5_38.Roll:AddRightGroupbox("Auto Buy", "shopping-cart")
AutoBuyGroup:AddToggle("AutoBuy", { Text = "Auto Buy", Default = false })
AutoBuyGroup:AddDropdown("AutoBuyRarities", {
    Text = "Buy Rarities",
    Values = v5_9,
    Default = {
        Common = true,
        Uncommon = true,
        Rare = true,
        Epic = true,
        Legendary = true,
        Mythic = true,
        Exotic = true,
        Divine = true,
        Secret = true,
        Omega = true,
        Limited = true
    },
    Multi = true,
    Searchable = true,
    AllowNull = true
})
AutoBuyGroup:AddSlider("AutoBuyMaxPrice", { Text = "Max Buy Price", Default = 100000, Min = 50, Max = 1000000000000, Rounding = 0 })
local AutoPlaceGroup = v5_38.Plot:AddLeftGroupbox("Auto Place", "map-pin")
AutoPlaceGroup:AddToggle("AutoPlace", { Text = "Auto Place", Default = false })
AutoPlaceGroup:AddDropdown("PlaceMinRarity", { Text = "Min Place Rarity", Values = v5_9, Default = "Common" })
local AutoReplaceGroup = v5_38.Plot:AddRightGroupbox("Auto Replace", "replace")
AutoReplaceGroup:AddToggle("AutoReplace", { Text = "Auto Replace with Better", Default = false })
AutoReplaceGroup:AddSlider("ReplaceMinDpsGain", { Text = "Min DPS Gain", Default = 1, Min = 1, Max = 1000000, Rounding = 0 })
local SlotsGroup = v5_38.Plot:AddLeftGroupbox("Slots", "layout-grid")
SlotsGroup:AddToggle("AutoBuySlots", { Text = "Auto Buy Slots", Default = false })
local ExpandGroup = v5_38.Plot:AddRightGroupbox("Expand", "expand")
ExpandGroup:AddToggle("AutoExpandPlot", { Text = "Auto Expand Plot", Default = false })
v5_18 = v5_38.Plot:AddLeftGroupbox("Collect", "package-open")
v5_18:AddToggle("AutoCollect", { Text = "Auto Collect Money", Default = false })
v5_4 = v5_38.Plot:AddRightGroupbox("Auto Sell", "banknote")
v5_4:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
v5_4:AddDropdown("SellMaxRarity", { Text = "Max Sell Rarity", Values = v5_9, Default = "Common" })
v5_4:AddSlider("SellMaxCost", { Text = "Max Sell Cost", Default = 1000, Min = 50, Max = 1000000000, Rounding = 0 })
v5_4:AddSlider("SellMaxDps", { Text = "Max Sell DPS", Default = 100, Min = 1, Max = 100000000, Rounding = 0 })
local AutoBuyUpgradesGroup = v5_38.Shop:AddLeftGroupbox("Auto Buy Upgrades", "arrow-big-up")
AutoBuyUpgradesGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
AutoBuyUpgradesGroup:AddDropdown("UpgradeSelect", {
    Text = "Upgrades",
    Values = nK,
    Default = {
        ["Roll Luck"] = true,
        ["Number Rolls"] = true,
        ["Money Multiplier"] = true,
        ["Damage Upgrade"] = true
    },
    Multi = true,
    Searchable = true,
    AllowNull = true
})
local AutoGemShopGroup = v5_38.Shop:AddRightGroupbox("Auto Gem Shop", "gem")
AutoGemShopGroup:AddToggle("AutoGemShop", { Text = "Auto Gem Shop", Default = false })
AutoGemShopGroup:AddDropdown("GemShopSelect", {
    Text = "Gem Shop Items",
    Values = nz,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true
})
local RebirthGroup = v5_38.Shop:AddLeftGroupbox("Rebirth", "refresh-cw")
RebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
local MovementGroup = v5_38.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = v5_38.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
oa = tick()
n4 = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local uq = v
        pcall(function()
            uq:Disable()
        end)
    end
end)
nO = fns.fn368
connection = UserInputService.InputBegan:Connect(fns.onInputBegan)
connection2 = UserInputService.InputChanged:Connect(fns.onInputChanged)
v5_15 = v5_38.Settings:AddLeftGroupbox("Menu")
v5_15:AddButton("Unload", fns.onUnload)
v5_15:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
v5_15:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
ox = function(hK)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not hK)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not hK
        end
    end)
    if not hK then
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
Toggles.AntiGameplayPause:OnChanged(fn962)
task.spawn(fns.antiGameplayPauseLoop)
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(fns.onJumpRequest)
CurrentCamera2 = Workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fns.fn228)
Toggles.WalkSpeedEnabled:OnChanged(fns.fn89)
task.spawn(antiAfkLoop)
task.spawn(worker2)
task.spawn(worker3)
task.spawn(fns.worker4)
task.spawn(fns.worker5)
v5_6:SetLibrary(Library)
v5_6:SetFolder("TempoHub")
v5_6:SaveDefault("Evil Hello Kitty")
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/RollAnArmy")
local o4 = SaveManager:BuildConfigSection(v5_38.Settings)
od = fn767
nJ = fn845
nw = fns.fn278
n8 = function(jm)
    local vK
    vK = nil
    local vL = type(jm) ~= "table" or type(jm.idx) ~= "string" or type(jm.type) ~= "string" or SaveManager.Ignore[jm.idx]
    if vL then
        return false
    end
    vK = od(jm.type, jm.idx)
    if not vK then
        return false
    end
    local vL_1 = pcall(function()
        if jm.type == "Input" then
            if type(jm.text) ~= "string" then
                return
            end
            vK:SetValue(jm.text)
        elseif jm.type == "ColorPicker" then
            vK:SetValueRGB(Color3.fromHex(jm.value), jm.transparency)
        elseif jm.type == "KeyPicker" then
            vK:SetValue({ jm.key, jm.mode, jm.modifiers })
            if jm.mode == "Toggle" and jm.toggled ~= nil then
                vK.Toggled = jm.toggled
                vK:Update()
            end
        else
            vK:SetValue(jm.value)
        end
    end)
    return vL_1
end
o4:AddDivider()
o4:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
o4:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
o4:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
v5_6:ApplyToTab(v5_38.Settings)
v5_6:LoadDefault()
SaveManager:LoadAutoloadConfig()
Library:OnUnload(fn621)
end)(...)

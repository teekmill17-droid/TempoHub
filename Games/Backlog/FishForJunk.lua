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
getgenv().TempoHoodSubtitle = "FISH FOR JUNK"
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
local p7_10, p7_12
local kk
local k2
local j1
local kK
local ItemData
local PurchaseUpgrade
local VirtualUser
local jP
local kx
local SellItem
local kW
local kD
local kj
local Library
local Toggles
local kp
local j6
local kP
local jO
local kc
local kV
local kC
local PurchaseRod
local k0
local j_
local kI
local ko
local j5
local SaveManager
local kv
local kb
local Label
local jT
local kB
local kh
local connection
local jZ
local LocalPlayer
local UpgradesData
local j4
local HttpService
local jM
local kt
local SellAllItems
local UserInputService
local jS
local kA
local kg
local kZ
local AutoCast
local connection2
local km
local j3
local kM
local ks
local j9
local kS
local kz
local EquipRod
local kY
local jX
local CurrentCamera
local kl
local k3
local j2
local kL
local kr
local j8
local kR
local jQ
local ReplicaClient
local ke
local kX
local jW
local Options
function fns.fn29(cl, cm)
    return string.format('<font color="%s">%s</font>', cm, cl)
end
function fns.onRenderStepped(e8)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local ox_1 = kt()
        if ox_1 then
            ox_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local ox_3 = kh()
        local oy = kt()
        if ox_3 and oy then
            oy.PlatformStand = true
            local oy_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                oy_1 = oy_1 + CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                oy_1 = oy_1 - CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                oy_1 = oy_1 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                oy_1 = oy_1 + CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                oy_1 = oy_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                oy_1 = oy_1 - Vector3.new(0, 1, 0)
            end
            ox_3.Velocity = Vector3.zero
            if oy_1.Magnitude > 0 then
                ox_3.CFrame = ox_3.CFrame + oy_1.Unit * Options.FlySpeed.Value * e8
            end
        end
    end
end
function fns.onCopySolanaAddress()
    jW(kV, "Copied Solana address")
end
function fns.fn59(ah)
    local DiscordGroup = ah:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = kY })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = kY })
end
function fns.fn74()
    local ne = Options.AutoBuyRodMax and Options.AutoBuyRodMax.Value
    local nf = ne
    if ne then
        ne = j3[nf]
    end
    local nf_1 = ne
    if ne then
        ne = nf_1.Price
    end
    return ne or math.huge
end
function fns.fn101(gl, gm)
    local Type = gm.Type
    if Type == "Toggle" then
        return { idx = gl, type = "Toggle", value = gm.Value == true }
    elseif Type == "Slider" then
        return { idx = gl, type = "Slider", value = tostring(gm.Value) }
    elseif Type == "Dropdown" then
        return { idx = gl, type = "Dropdown", multi = gm.Multi == true, value = gm.Value }
    elseif Type == "Input" then
        local pj = gm.Value or ""
        return { idx = gl, type = "Input", text = tostring(pj) }
    elseif Type == "ColorPicker" then
        return { idx = gl, type = "ColorPicker", value = gm.Value:ToHex(), transparency = gm.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = gl,
            type = "KeyPicker",
            mode = gm.Mode,
            key = gm.Value,
            modifiers = gm.Modifiers,
            toggled = gm.Toggled
        }
    else
        return nil
    end
end
function fns.fn103()
    local oa_1 = Options.AutoBuyUpgradeTarget and Options.AutoBuyUpgradeTarget.Value or kl
    if oa_1 == kj then
        j8("LuckMultiplier")
        return
    end
    if oa_1 == kg then
        j8("ValueMultiplier")
        return
    end
    if j8("LuckMultiplier") then
        return
    end
    j8("ValueMultiplier")
end
local function fn136()
    local nl_1
    local nk_1
    if identifyexecutor then
        nl_1, nk_1 = identifyexecutor()
        local nm = nl_1 ~= ""
        local nn = type(nl_1) == "string" and nm
        if nn then
            local nm_1 = type(nk_1) == "string" and nk_1 ~= "" and nl_1 .. " " .. nk_1
            j1 = nm_1 or nl_1
        end
    end
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local ov_1 = kt()
        if ov_1 then
            ov_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function onInputChanged(fS)
    local UserInputType = fS.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        ke = tick()
    end
end
local function onCopyLitecoinAddress()
    jW(jT, "Copied Litecoin address")
end
local function fn156()
    local nV = kb()
    local nW = kr()
    local nX = j_()
    for k, v in j9 do
        local nY = v.Price > 0 and v.Price <= nW and v.Price <= nV and not kX(v.Name)
        if nY then
            if v.World ~= "ForestWorld" or nX then
                j2(PurchaseRod, v.Name)
                task.wait(0.2)
                j2(EquipRod, v.Name)
                return
            end
        end
    end
end
local function fn212(co, cp, cq)
    return string.format("<b>%s</b> %s %s", co, kA("-", "#5a6070"), kA(cp, cq))
end
local function worker5()
    while not Library.Unloaded do
        task.wait(0.5)
        if j6("AutoBuyUpgrades") then
            pcall(kK)
        end
    end
end
local function onImportConfigFromClipboardTex()
    local pV_1
    local pT = Options.SaveManager_ImportSource.Value
    local pT_1
    local pZ = if pT then 1 else 0
    local pX = 878 * pZ + 3699 * (1 - pZ)
    local pY = 3117 * pZ + 3052 * (1 - pZ)
    if not ((pX * 706 + pY * 371 + pX * pY) % 16777213 == 4513001) then
        pT = ""
    end
    local pU = tostring(pT):match("^%s*(.-)%s*$")
    if pU == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    pT_1, pV_1 = pcall(HttpService.JSONDecode, HttpService, pU)
    local pU_1 = not pT_1 or type(pV_1) ~= "table" or type(pV_1.objects) ~= "table"
    if pU_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local pT_2 = 0
    for k, v in pV_1.objects do
        if jQ(v) then
            pT_2 += 1
        end
    end
    if pT_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local pV_2 = pT_2 == 1 and ""
    local pZ_1 = if pV_2 then 1 else 0
    local pX_1 = 3565 * pZ_1 + 2048 * (1 - pZ_1)
    local pY_1 = 561 * pZ_1 + 810 * (1 - pZ_1)
    if not ((pX_1 * 3393 + pY_1 * 1925 + pX_1 * pY_1) % 16777213 == 15175935) then
        pV_2 = "s"
    end
    Library:Notify(("Imported %d setting%s"):format(pT_2, pV_2), 6)
end
local function onCopyUSDTAddress()
    jW(kZ, "Copied USDT address")
end
local function fn245()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    kc = tick()
end
local function fn251()
    connection:Disconnect()
    connection2:Disconnect()
    kW(false)
    pcall(function()
        AutoCast.Stop()
    end)
    select("#", "Unloaded!")
end
local function fn288()
    Library.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
local function fn293(bc)
    local mE = typeof(bc.Rarity) == "string" and bc.Rarity ~= ""
    if mE then
        return bc.Rarity
    end
    local mE_1 = typeof(bc.ItemId) == "string" and ItemData.GetItemById(bc.ItemId)
    local mF = mE_1
    if mE_1 then
        mE_1 = mF.Rarity
    end
    return mE_1 or "Common"
end
local function fn306()
    if not Toggles.Fly.Value then
        local oH = kt()
        if oH then
            oH.PlatformStand = false
        end
    end
end
local function onCopyPayPalLink()
    jW(kS, "Copied PayPal link")
end
local function fn352()
    local m2 = kk()
    local m3 = m2 and m2.UnlockedWorlds
    local m3_1 = typeof(m3) == "table" and m3.ForestWorld == true
    return m3_1
end
local function fn392(bQ)
    local m8 = kk()
    local m9 = m8 and m8.Inventory
    local m8_1 = m9
    if m9 then
        m9 = m8_1.Rods
    end
    local m8_2 = m9
    local m9_1 = typeof(m8_2) == "table" and m8_2[bQ] ~= nil
    return m9_1
end
local function fn407()
    ReplicaClient.OnNew("PlayerData", jO)
end
local function fn419()
    local l0 = kB()
    local l1 = l0 and l0:FindFirstChildOfClass("Humanoid")
    return l1
end
local function onCopyBitcoinAddress()
    jW(jP, "Copied Bitcoin address")
end
local function fn431()
    jW(kC, "Copied Discord invite to clipboard")
end
local function worker2()
    local nv_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local nu = math.floor(os.clock() - kx)
        if nu < 60 then
            nv_1 = nu .. "s"
        elseif nu < 3600 then
            nv_1 = string.format("%dm %ds", math.floor((nu) / (60)), nu % 60)
        else
            nv_1 = string.format("%dh %dm", math.floor((nu) / (3600)), math.floor((nu % 3600) / (60)))
        end
        Label:SetText(kp("Session time", nv_1, j5))
    end
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            kW(true)
        end
    end
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local oh_1 = kB()
        if oh_1 then
            for i, descendant in oh_1:GetDescendants() do
                local oh_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if oh_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function onUnload()
    Library:Unload()
end
local function fn491()
    local mn = kk()
    local mo = mn and typeof(mn.Money) == "number"
    if mo then
        return mn.Money
    end
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local mo_1 = leaderstats and leaderstats:FindFirstChild("Money")
    local mn_2 = mo_1
    if mo_1 then
        mo_1 = tonumber(mn_2.Value)
    end
    return mo_1 or 0
end
local function fn513(ew)
    local n6 = kk()
    if not n6 then
        return false
    end
    local Upgrades = n6.Upgrades
    local NormalizeLevel = UpgradesData.NormalizeLevel
    local n8 = typeof(Upgrades) == "table" and Upgrades[ew]
    local n7_1 = n8 or 0
    local n8_1 = NormalizeLevel(n7_1)
    local n6_2 = UpgradesData.GetCost(ew, n8_1)
    local n7_2 = typeof(n6_2) == "number" and n6_2 > 0 and kb() >= n6_2
    if n7_2 then
        j2(PurchaseUpgrade, ew)
        return true
    end
    return false
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local o7 = tick() - ke
            local o8 = tick() - kc
            if o7 >= 300 and o8 >= 60 then
                pcall(jZ)
            else
                if o7 < 300 and o8 >= 300 then
                    pcall(jZ)
                end
            end
        end
    end
end
local function fn529()
    return LocalPlayer.Character
end
local function onExportConfigToClipboard()
    local pN_1
    local pM_1
    pM_1, pN_1 = pcall(HttpService.JSONEncode, HttpService, kv())
    if not pM_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local pM_2 = setclipboard or toclipboard
    local pM_3 = type(pM_2) ~= "function" or not pcall(pM_2, pN_1)
    if pM_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function fn548(aa, ab)
    if setclipboard then
        setclipboard(aa)
    elseif toclipboard then
        toclipboard(aa)
    end
    Library:Notify(ab)
end
local function worker()
    local mb, mc, md, mh, mi
    local me = 10
    while true do
        local me_1 = 2844 - me
        do
            if me_1 < 2833 then
                if me_1 < 2828 then
                    if me_1 < 2826 then
                        if me_1 < 2825 then
                            if me_1 < 2824 then
                                break
                            elseif me_1 == 2824 then
                                md = mc.Data.Inventory
                                me = 16
                            else
                                me = 2833
                                continue
                            end
                        else
                            mh = 1
                            me = 15
                        end
                    elseif me_1 < 2827 then
                        if me_1 == 2826 then
                            mh += 1
                            me = 15
                        else
                            me = 9555
                            continue
                        end
                    else
                        mc = os.clock() < mb
                        me = 7
                    end
                elseif me_1 < 2830 then
                    if me_1 < 2829 then
                        me = if md then 0 else 5
                    else
                        me = if mh <= 128 then 9 else 1
                    end
                elseif me_1 < 2831 then
                    if me_1 == 2830 then
                        me = 13
                    else
                        me = 1339
                        continue
                    end
                elseif me_1 < 2832 then
                    if me_1 == 2831 then
                        me = 8
                    else
                        me = 2830
                        continue
                    end
                else
                    md = mc.Data
                    me = 6
                end
            elseif me_1 < 2840 then
                if me_1 < 2839 then
                    if me_1 < 2836 then
                        if me_1 < 2834 then
                            if me_1 == 2833 then
                                me = 4
                            else
                                me = 2824
                                continue
                            end
                        elseif me_1 < 2835 then
                            if me_1 == 2834 then
                                mb = os.clock() + 30
                                me = 4
                            else
                                me = 7993
                                continue
                            end
                        elseif me_1 == 2835 then
                            mi = mh
                            me = 3
                        else
                            me = 12426
                            continue
                        end
                    elseif me_1 < 2837 then
                        break
                    elseif me_1 < 2838 then
                        if me_1 == 2837 then
                            me = if mc then 19 else 14
                        else
                            me = 2838
                            continue
                        end
                    elseif me_1 == 2838 then
                        me = if md then 20 else 16
                    else
                        me = 2833
                        continue
                    end
                else
                    me = 18
                end
            elseif me_1 < 2843 then
                if me_1 < 2842 then
                    if me_1 < 2841 then
                        if me_1 == 2840 then
                            me = 2
                        else
                            me = 2832
                            continue
                        end
                    elseif me_1 == 2841 then
                        mc = ReplicaClient.FromId(mi)
                        md = mc
                        me = if md then 12 else 6
                    else
                        me = 2839
                        continue
                    end
                elseif me_1 == 2842 then
                    mc = not jS
                    me = if mc then 17 else 7
                else
                    me = 2825
                    continue
                end
            elseif me_1 < 7993 then
                if me_1 < 2844 then
                    if me_1 == 2843 then
                        task.wait(0.25)
                        me = 11
                    else
                        me = 2827
                        continue
                    end
                elseif me_1 == 2844 then
                    jO(mc)
                    return
                else
                    break
                end
            else
                break
            end
        end
    end
end
local function fn555(av)
    local l6 = Toggles[av]
    return l6 ~= nil and l6.Value == true
end
local function fn578()
    kW(Toggles.AntiGameplayPause.Value)
end
local function worker4()
    while not Library.Unloaded do
        task.wait(0.6)
        if j6("AutoBuyRods") then
            pcall(jM)
        end
    end
end
local function worker3()
    while not Library.Unloaded do
        task.wait(0.4)
        if j6("AutoSell") then
            pcall(kM)
        end
    end
end
local function onCopyJoinScript_JobID()
    local ns = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, kR)
    if setclipboard then
        setclipboard(ns)
    elseif toclipboard then
        toclipboard(ns)
    end
    Library:Notify("Copied join script to clipboard")
end
local function fn656(bq)
    for k, v in bq do
        if v then
            return true
        end
    end
    return false
end
local function onCopyEthereumAddress()
    jW(k2, "Copied Ethereum address")
end
local function fn680(bu)
    if typeof(bu) ~= "table" then
        return false
    end
    if (Options.AutoSellMode and Options.AutoSellMode.Value or ks) ~= ko then
        return true
    end
    local mW_2 = jX(Options.AutoSellRarities)
    local mX_1 = jX(Options.AutoSellVariants)
    local mY = k0(mW_2) and not mW_2[km(bu)]
    if mY then
        return false
    end
    local mY_1 = k0(mX_1) and not mX_1[j4(bu)]
    if mY_1 then
        return false
    end
    local mY_2 = k0(mW_2) or k0(mX_1)
    return mY_2
end
local function fn681()
    local l3 = kB()
    local l4 = l3 and l3:FindFirstChild("HumanoidRootPart")
    return l4
end
local function fn683(aB)
    if aB and aB.Data then
        jS = aB
    end
end
local function fn722(a7)
    local mw = 0
    for k, v in a7 do
        if typeof(v) == "table" then
            mw += 1
        end
    end
    return mw
end
local function fn737()
    local nK = k3()
    if kD(nK) <= 0 then
        return
    end
    if (Options.AutoSellMode and Options.AutoSellMode.Value or ks) ~= ko then
        j2(SellAllItems)
        return
    end
    local nL_2 = 0
    for k, v in nK do
        local nK_1 = typeof(k) == "string" and kL(v)
        if nK_1 then
            j2(SellItem, k)
            nL_2 += 1
            task.wait(0.15)
        end
    end
    if nL_2 == 0 then
        return
    end
end
local function onCopyVenmoLink()
    jW(kP, "Copied Venmo link")
end
local function fn799()
    local mq = kk()
    local mr = mq and mq.Inventory
    local mq_1 = mr
    if mr then
        mr = mq_1.Items
    end
    local mq_2 = mr
    if typeof(mq_2) ~= "table" then
        return {}
    end
    return mq_2
end
local function fn805()
    return jS and jS.Data or nil
end
local function onInputBegan()
    ke = tick()
end
local function onRscripts()
    jW(kz, "Copied Rscripts profile to clipboard")
end
local function fn880(bj)
    local mK = typeof(bj.Variant) == "string" and bj.Variant ~= ""
    if mK then
        return bj.Variant
    end
    return "Normal"
end
local function fn893()
    local pp = {}
    for k, v in { Toggles, Options } do
        for k, v in v do
            local pq = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if pq then
                local pq_1 = kI(k, v)
                if pq_1 then
                    pp[#pp + 1] = pq_1
                end
            end
        end
    end
    table.sort(pp, function(gy, gz)
        if gy.type ~= gz.type then
            return gy.type < gz.type
        end
        return gy.idx < gz.idx
    end)
    return { objects = pp }
end
local function fn895(gd, ge)
    local pc_1 = (gd == "Toggle" and Toggles or Options)[ge]
    local pb_2 = type(pc_1) == "table" and pc_1.Type == gd
    return pb_2 and pc_1 or nil
end
local function fn906(bm)
    local mM = bm and bm.Value
    if typeof(mM) ~= "table" then
        return {}
    end
    return mM
end
local function fn918()
    if Toggles.AutoPerfectCast.Value then
        pcall(function()
            AutoCast.Stop()
        end)
    end
end
local function fn934()
    if not Toggles.WalkSpeedEnabled.Value then
        local oJ = kt()
        if oJ then
            oJ.WalkSpeed = 16
        end
    end
end
jM = nil
jO = nil
jP = nil
jQ = nil
jS = nil
jT = nil
jW = nil
jX = nil
AutoCast = nil
jZ = nil
j_ = nil
j1 = nil
j2 = nil
j3 = nil
j4 = nil
j5 = nil
j6 = nil
PurchaseUpgrade = nil
j8 = nil
j9 = nil
SellAllItems = nil
kb = nil
kc = nil
SellItem = nil
ke = nil
EquipRod = nil
kg = nil
kh = nil
PurchaseRod = nil
kj = nil
kk = nil
kl = nil
km = nil
UpgradesData = nil
ko = nil
kp = nil
ItemData = nil
kr = nil
ks = nil
kt = nil
kv = nil
kx = nil
ReplicaClient = nil
kz = nil
local jN, Hold, jU, PowerBar, Effects, kw
kA = nil
kB = nil
kC = nil
kD = nil
Options = nil
CurrentCamera = nil
connection2 = nil
LocalPlayer = nil
kI = nil
Toggles = nil
kK = nil
kL = nil
kM = nil
HttpService = nil
SaveManager = nil
kP = nil
VirtualUser = nil
kR = nil
kS = nil
UserInputService = nil
Label = nil
kV = nil
kW = nil
kX = nil
kY = nil
kZ = nil
connection = nil
k0 = nil
Library = nil
k2 = nil
k3 = nil
local lh, li, lj, lk, ll
local lu
UserInputService, VirtualUser, HttpService, LocalPlayer = nil, nil, nil, nil
local p7_13 = game:GetService("Players")
local p7_9 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
LocalPlayer = p7_13.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end
if setthreadidentity then
    setthreadidentity(8)
end
ReplicaClient, ItemData, UpgradesData, PurchaseRod, EquipRod, SellItem, SellAllItems, PurchaseUpgrade, Effects, AutoCast, PowerBar, Hold, Library, SaveManager, Toggles, Options, kC, kz, kw, ks, ko, kl, kj, kg, j9, j3 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local p7_14 = "Fish For Junk"
ReplicaClient = require(p7_9:WaitForChild("ReplicaClient"))
local p7_5 = require(p7_9:WaitForChild("Handlers"):WaitForChild("RodData"))
ItemData = require(p7_9:WaitForChild("Handlers"):WaitForChild("ItemData"))
UpgradesData = require(p7_9:WaitForChild("Handlers"):WaitForChild("UpgradesData"))
local p7_16 = p7_9:WaitForChild("Remotes"):WaitForChild("Gameplay")
PurchaseRod = p7_16:WaitForChild("PurchaseRod")
EquipRod = p7_16:WaitForChild("EquipRod")
SellItem = p7_16:WaitForChild("SellItem")
SellAllItems = p7_16:WaitForChild("SellAllItems")
PurchaseUpgrade = p7_16:WaitForChild("PurchaseUpgrade")
local p7_4 = LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("ClientLoader")
local p7_2 = p7_4:WaitForChild("Handlers"):WaitForChild("ItemController")
Effects = require(p7_2:WaitForChild("Effects"))
AutoCast = require(p7_2:WaitForChild("AutoCast"))
PowerBar = require(p7_2:WaitForChild("PowerBar"))
Hold = require(p7_2:WaitForChild("Hold"))
Library = getgenv().Library
pcall(fn288)
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
kC = "https://discord.gg/K7Qxnxkk46"
kz = "https://discord.gg/K7Qxnxkk46"
kw = 2
ks = "All"
ko = "Filtered"
kl = "Both"
kj = "Luck Multiplier"
kg = "Value Multiplier"
local RarityOrder = ItemData.RarityOrder
local VariantOrder = ItemData.VariantOrder
j9 = p7_5.GetAllRods()
if ((SellItem or SellItem) and SellItem or "https://discord.gg/K7Qxnxkk46" and (SellItem and kz)) and (SellItem and (SellItem and 29) or false and (not SellItem or 29)) and (false and (not SellItem and SellItem) and (not SellItem or false or SellItem and SellItem) or (kz and not SellItem or false or false)) and not (((SellItem or SellItem) and SellItem or "https://discord.gg/K7Qxnxkk46" and (SellItem and kz)) and (SellItem and (SellItem and 29) or false and (not SellItem or 29)) and (false and (not SellItem and SellItem) and (not SellItem or false or SellItem and SellItem) or (kz and not SellItem or false or false))) then
    j3 = {}
    p7_12 = {}
else
    p7_12 = {}
    j3 = {}
end
for k, v in j9 do
    p7_12[#p7_12 + 1] = v.DisplayName
    j3[v.DisplayName] = v
end
jS, jW, kY, kB, kt, kh, j6, jO, kk, kb, k3, kD, km, j4, jX, k0, kL, j_, kX, kr, j2, jN = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
jW = fn548
kY = fn431
p7_9 = fns.fn59
kB = fn529
kt = fn419
kh = fn681
j6 = fn555
jO = fn683
pcall(fn407)
task.spawn(worker)
kk = fn805
if not kY and not j4 and false and (kB and j4 or (kk or not kY)) or not (not kY and not j4 and false and (kB and j4 or (kk or not kY))) then
    kb = fn491
    k3 = fn799
else
    k3 = fn491
    kb = fn799
end
kD = fn722
km = fn293
j4 = fn880
jX = fn906
k0 = fn656
kL = fn680
j_ = fn352
kX = fn392
kr = fns.fn74
j2 = function(b7, ...)
    local b8
    b8 = { ... }
    pcall(function()
        b7:FireServer(table.unpack(b8))
    end)
end
jN = function(cc, ...)
    local nh = 8
    if getthreadidentity then
        pcall(function()
            nh = getthreadidentity()
        end)
    end
    if setthreadidentity then
        pcall(setthreadidentity, 2)
    end
    local ni = table.pack(pcall(cc, ...))
    if setthreadidentity then
        pcall(setthreadidentity, nh)
    end
    if ni[1] then
        return table.unpack(ni, 2, ni.n)
    end
    return nil
end
p7_2 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = kC, Copyable = true }, "|", p7_14 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
p7_4 = {
    Info = p7_2:AddTab("Info", "info"),
    Main = p7_2:AddTab("Main", "fish"),
    Player = p7_2:AddTab("Player", "person-standing"),
    Settings = p7_2:AddTab("Settings", "settings")
}
for k, v in { p7_4.Main, p7_4.Player, p7_4.Settings } do
    p7_9(v)
end
lh, p7_5, j5, p7_16, j1, p7_2, li, Label, kR, p7_10, kA, kp = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
p7_13 = 13
repeat
    p7_9 = (p7_13 * 5 + 6) % 8 + 1
    if p7_9 <= 4 then
        if p7_9 <= 2 then
            if p7_9 <= 1 then
                lj = {
                    "xvuzftfi",
                    "jtwvnhc",
                    "qmex",
                    "mfzpilwswwj",
                    "dwejffi",
                    "uiafldgfmse",
                    "fipy",
                    "wghzwhub",
                    "ojcwocpdci"
                }
                local q7 = p7_13
                lk = lj[q7 % 9 + 1]
                if lk:len() >= lk:gsub("(.)", "%1%1", q7 % 3 % 2 + 1):len() then
                    j5 = fn212
                else
                    kp = fn212
                end
                p7_13 = (p7_13 + 29) % 64
            else
                if (kp or p7_2) and (not kA or not p7_2) and (not p7_13 and p7_2 and (not kA or p7_13)) or not ((kp or p7_2) and (not kA or not p7_2) and (not p7_13 and p7_2 and (not kA or p7_13))) then
                    lh = "#7fd47f"
                else
                    p7_16 = "#7fd47f"
                end
                p7_13 = (p7_13 + 61) % 64
            end
        elseif p7_9 <= 3 then
            lj = (vector.create((p7_13 * 5 + 9) % 11 + 1, (p7_13 * 10 + 12) % 13 + 1, (p7_13 * 1 + 6) % 17 + 1))
            lk = (vector.create((p7_13 * 1 + 7) % 11 + 1, (p7_13 * 1 + 1) % 13 + 1, (p7_13 * 15 + 14) % 17 + 1))
            ll = (vector.create((p7_13 * 2 + 2) % 5 + 1, (p7_13 * 2 + 1) % 7 + 1, (p7_13 * 1 + 6) % 9 + 1))
            if math.abs((vector.angle(lj, lk, ll))) - math.abs((vector.angle(lk, lj, ll))) == 2 then
                li = "#6ec1ff"
            else
                p7_5 = "#6ec1ff"
            end
            p7_13 = (p7_13 + 29) % 64
        else
            lj = { "rhxstzjxq", "xyabhxk", "ibxhjbcdu", "luyo", "uniesfn", "oqm", "cwm", "kyneizpjsi" }
            local qK = p7_13
            lk = lj[qK % 8 + 1]
            if lk:len() <= lk:reverse():rep(qK % 3 + 2):len() then
                j5 = "#e8a34d"
            else
                lh = "#e8a34d"
            end
            p7_13 = (p7_13 + 37) % 64
        end
    elseif p7_9 <= 6 then
        if p7_9 <= 5 then
            if (p7_13 * 2 + 2) * 16 % 3 == ((p7_13 * 2 + 2) * 16 + 4) % 3 then
                p7_2 = "#8b93a3"
                p7_16 = "Unknown"
                pcall(fn136)
                p7_5 = (nil):AddLeftGroupbox("Account", "circle-user")
                p7_5:AddLabel(kA("User", lh.Name, p7_4), true)
                p7_5:AddLabel(kA("Status", "Keyless", p7_4), true)
                p7_5:AddLabel(kA("Executor", "Unknown", p7_4), true)
                j1 = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
                j1:AddLabel(li(Label .. " [" .. tostring(game.PlaceId) .. "]", j5), true)
                j1:AddLabel(kA("Place ID", tostring(game.PlaceId), j5), true)
                kp = j1:AddLabel(kA("Session time", "0s", LocalPlayer), true)
            else
                p7_16 = "#8b93a3"
                j1 = "Unknown"
                pcall(fn136)
                p7_2 = p7_4.Info:AddLeftGroupbox("Account", "circle-user")
                p7_2:AddLabel(kp("User", LocalPlayer.Name, lh), true)
                p7_2:AddLabel(kp("Status", "Keyless", lh), true)
                p7_2:AddLabel(kp("Executor", j1, lh), true)
                li = p7_4.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                li:AddLabel(kA(p7_14 .. " [" .. tostring(game.PlaceId) .. "]", p7_5), true)
                li:AddLabel(kp("Place ID", tostring(game.PlaceId), p7_5), true)
                Label = li:AddLabel(kp("Session time", "0s", j5), true)
            end
            p7_13 = (p7_13 + 21) % 64
        else
            local qz = bit32.rrotate(bit32.bxor(bit32.lrotate(p7_13, 27), string.byte(tostring(li))), 12)
            if bit32.bxor(bit32.lrotate(bit32.bxor(qz, 2690852204), 30), 672713051) == bit32.lrotate(qz, 30) then
                kR = tostring(game.JobId)
            else
                p7_10 = tostring(game.JobId)
            end
            p7_13 = (p7_13 + 5) % 64
        end
    elseif p7_9 <= 7 then
        p7_9 = (vector.create((p7_13 * 2 + 4) % 11 + 1, (p7_13 * 6 + 11) % 13 + 1, (p7_13 * 6 + 3) % 17 + 1))
        lj = (vector.create((p7_13 * 3 + 9) % 11 + 1, (p7_13 * 2 + 11) % 13 + 1, (p7_13 * 9 + 1) % 17 + 1))
        lk = (vector.create((p7_13 * 3 + 7) % 5 + 1, (p7_13 * 3 + 4) % 7 + 1, (p7_13 * 2 + 4) % 9 + 1))
        if math.abs((vector.angle(p7_9, lj, lk))) - math.abs((vector.angle(lj, p7_9, lk))) == 1 then
            kR = #p7_10 > 18
        else
            p7_10 = #kR > 18
        end
        p7_13 = (p7_13 + 21) % 64
    else
        p7_9 = {
            "ygqea",
            "fanls",
            "rvdhkzcuay",
            "rnvoy",
            "khccvyugr",
            "nmmexhtq",
            "cgakfeg",
            "fepb",
            "hkxizionx",
            "pwsl",
            "cei"
        }
        local qy = p7_13
        lj = p7_9[qy % 11 + 1]
        if lj:len() >= lj:gsub("(.)", "%1%1", qy % 3 % 2 + 1):len() then
            p7_2 = fns.fn29
        else
            kA = fns.fn29
        end
        p7_13 = (p7_13 + 21) % 64
    end
until (p7_13 * 35 + 40) % 64 == 15
if p7_10 then
    p7_13 = 0
    repeat
        p7_2 = {
            "tvbno",
            "flarj",
            "mxqglksrdyds",
            "odbdv",
            "wdpl",
            "pcncb",
            "hqwnam",
            "hyn",
            "xhtvquwjkqc",
            "khjptgwtrfbu"
        }
        if p7_2[(p7_13 * 62 + 75) % 10 + 1] <= p7_2[(p7_13 * 62 + 75) % 10 + 1] then
            p7_10 = string.sub(kR, 1, 18) .. "..."
        else
            kR = string.sub(p7_10, 1, 18) .. "..."
        end
        p7_13 = (p7_13 + 7) % 8
    until (p7_13 * 7 + 7) % 8 == 0
end
p7_13 = p7_10 or kR
kx, jT, jP, k2, kZ, kV, kS, kP, lu, CurrentCamera, ke, kc, connection, connection2, kM, jM, j8, kK, kW, jZ, jU, kI, kv, jQ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local lv = p7_13
li:AddLabel(kp("Server", lv, p7_16), true)
li:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
kx = os.clock()
task.spawn(worker2)
ll = p7_4.Info:AddRightGroupbox("Scripts", "package")
ll:AddLabel(kA("Included in this hub", p7_16), true)
ll:AddLabel(kA(p7_14, p7_5), true)
lj = p7_4.Info:AddRightGroupbox("Features", "list")
lj:AddLabel(kA("Auto Perfect Cast", p7_5), true)
lj:AddLabel(kA("Auto Sell", j5), true)
lj:AddLabel(kA("Auto Buy Rods", lh), true)
lj:AddLabel(kA("Auto Buy Upgrades", p7_16), true)
p7_10 = p7_4.Info:AddRightGroupbox("Socials", "link")
p7_10:AddButton({ Text = "Discord", Func = kY })
p7_10:AddButton({ Text = "Rscripts", Func = onRscripts })
p7_2 = p7_4.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
p7_2:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
p7_2:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
p7_2:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
p7_2:AddButton({ Text = "Copy Discord Invite", Func = kY })
jT = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
jP = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
k2 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
kZ = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
kV = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
kS = ""
kP = ""
local lw = "#345d9d"
if ((not kx and not p7_10 or not p7_10 and kx) and ((not p7_10 or kI) and (not kI or not kI)) or ((not kx or p7_10) and (kx and kx) or (not kI or p7_10 or (kx or kI)))) and ((not kx and kI and (p7_10 or kI) or (not kI and not kI or kI and not kI)) and (kx and p7_10 and (not kI and not kI) and (kx and not kI or (not kI or not kx)))) or not (((not kx and not p7_10 or not p7_10 and kx) and ((not p7_10 or kI) and (not kI or not kI)) or ((not kx or p7_10) and (kx and kx) or (not kI or p7_10 or (kx or kI)))) and ((not kx and kI and (p7_10 or kI) or (not kI and not kI or kI and not kI)) and (kx and p7_10 and (not kI and not kI) and (kx and not kI or (not kI or not kx))))) then
    lu = "#f7931a"
end
local lt = "#627eea"
local ls = "#26a17b"
local lr = "#14f195"
local lq = "#0070ba"
local lp = "#008cff"
local DonationsGroup = p7_4.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(kA("All donations are optional but appreciated.", j5), true)
DonationsGroup:AddLabel(kA("If you donate you get a special role, just PING after you donate.", lh), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(kA("LTC / Litecoin", lw), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(kA("BTC / Bitcoin", lu), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(kA("ETH / Ethereum", lt), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(kA("USDT", ls), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(kA("Solana", lr), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = fns.onCopySolanaAddress })
DonationsGroup:AddLabel(kA("PayPal", lq), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(kA("Venmo", lp), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(kA("Don't have any of the listed currencies but still wanna donate?", p7_16), true)
DonationsGroup:AddLabel(kA("DM me and we'll work something out.", p7_5), true)
local FaqGroup = p7_4.Info:AddRightGroupbox("FAQ", "circle-help")
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
local FishingGroup = p7_4.Main:AddLeftGroupbox("Fishing", "fish")
FishingGroup:AddToggle("AutoPerfectCast", { Text = "Auto Perfect Cast", Default = false })
local ShopGroup = p7_4.Main:AddLeftGroupbox("Shop", "shopping-cart")
ShopGroup:AddToggle("AutoBuyRods", { Text = "Auto Buy Rods", Default = false })
ShopGroup:AddDropdown("AutoBuyRodMax", { Text = "Max Rod", Values = p7_12, Default = p7_12[#p7_12] })
ShopGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
ShopGroup:AddDropdown("AutoBuyUpgradeTarget", { Text = "Upgrade", Values = { kj, kg, kl }, Default = kl })
local SellingGroup = p7_4.Main:AddRightGroupbox("Selling", "tag")
SellingGroup:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
SellingGroup:AddDropdown("AutoSellMode", { Text = "Sell Mode", Values = { ks, ko }, Default = ko })
SellingGroup:AddDropdown("AutoSellRarities", {
    Text = "Rarities",
    Values = RarityOrder,
    Default = { "Common", "Uncommon", "Rare" },
    Multi = true,
    SelectAllButtons = true,
    Expandable = true
})
SellingGroup:AddDropdown("AutoSellVariants", {
    Text = "Variants",
    Values = VariantOrder,
    Default = { "Normal", "Big", "Huge" },
    Multi = true,
    SelectAllButtons = true
})
Toggles.AutoPerfectCast:OnChanged(fn918)
task.spawn(function()
    local nJ = false
    repeat
        local nE
        if not Library.Unloaded then
            if not j6("AutoPerfectCast") then
                task.wait(0.15)
            else
                if AutoCast.IsEnabled() then
                    pcall(function()
                        AutoCast.Stop()
                    end)
                end
                local nF = PowerBar.IsOpen() or Effects.IsBusy()
                if nF then
                    task.wait(0.1)
                else
                    nE = false
                    jN(function()
                        Hold.UnequipCaughtItem()
                        Effects.BeginCast(nil, kw, function()
                            nE = true
                        end)
                    end)
                    local nF_1 = os.clock()
                    while true do
                        local nG_1 = not nE and os.clock() - nF_1 < 30 and j6("AutoPerfectCast") and not Library.Unloaded
                        if nG_1 then
                            task.wait(0.05)
                            continue
                        end
                        break
                    end
                    local nG_2 = 3.5 - (os.clock() - nF_1)
                    if nG_2 > 0 then
                        local nF_2 = os.clock() + nG_2
                        while true do
                            local nG_3 = os.clock() < nF_2 and j6("AutoPerfectCast") and not Library.Unloaded
                            if nG_3 then
                                task.wait(0.05)
                                continue
                            end
                            break
                        end
                    end
                end
            end
        else
            nJ = true
        end
    until nJ
end)
kM = fn737
task.spawn(worker3)
jM = fn156
task.spawn(worker4)
j8 = fn513
kK = fns.fn103
task.spawn(worker5)
local MovementGroup = p7_4.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
lk = p7_4.Player:AddRightGroupbox("Fly", "feather")
lk:AddToggle("Fly", { Text = "Fly", Default = false })
lk:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
RunService.RenderStepped:Connect(fns.onRenderStepped)
Toggles.Fly:OnChanged(fn306)
Toggles.WalkSpeedEnabled:OnChanged(fn934)
kW = function(fu)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not fu)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not fu
        end
    end)
    if not fu then
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
Toggles.AntiGameplayPause:OnChanged(fn578)
task.spawn(antiGameplayPauseLoop)
local MenuGroup = p7_4.Settings:AddLeftGroupbox("Menu", "menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
ke = tick()
kc = tick()
pcall(function()
    for k, v in getconnections(LocalPlayer.Idled) do
        local oZ = v
        pcall(function()
            oZ:Disable()
        end)
    end
end)
jZ = fn245
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", onUnload)
task.spawn(antiAfkLoop)
Library:OnUnload(fn251)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Linoria")
ThemeManager:ApplyToTab(p7_4.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/FishForJunk")
p7_9 = SaveManager:BuildConfigSection(p7_4.Settings)
if (false and lv and (not ll or not ll) or (not ll or lu or (not lv or lu))) and (not lv or lu or (not lv or lu) or lv and lu and (lv and lu)) and not ((false and lv and (not ll or not ll) or (not ll or lu or (not lv or lu))) and (not lv or lu or (not lv or lu) or lv and lu and (lv and lu))) then
    jT = fn895
else
    jU = fn895
end
kI = fns.fn101
kv = fn893
jQ = function(gB)
    local pG
    pG = nil
    local pH = type(gB) ~= "table"
    local pL = if pH then 1 else 0
    local pJ = 2515 * pL + 2366 * (1 - pL)
    local pK = 2401 * pL + 3285 * (1 - pL)
    if not ((pJ * 3613 + pK * 2642 + pJ * pK) % 16777213 == 4691439) then
        pH = type(gB.idx) ~= "string"
    end
    if not pH then
        pH = type(gB.type) ~= "string"
    end
    if not pH then
        pH = SaveManager.Ignore[gB.idx]
    end
    if pH then
        return false
    end
    pG = jU(gB.type, gB.idx)
    if not pG then
        return false
    end
    local pH_1 = pcall(function()
        if gB.type == "Input" then
            if type(gB.text) ~= "string" then
                return
            end
            pG:SetValue(gB.text)
        elseif gB.type == "ColorPicker" then
            pG:SetValueRGB(Color3.fromHex(gB.value), gB.transparency)
        elseif gB.type == "KeyPicker" then
            pG:SetValue({ gB.key, gB.mode, gB.modifiers })
            if gB.mode == "Toggle" and gB.toggled ~= nil then
                pG.Toggled = gB.toggled
                pG:Update()
            end
        else
            pG:SetValue(gB.value)
        end
    end)
    return pH_1
end
p7_9:AddDivider()
p7_9:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
p7_9:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
p7_9:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
end)(...)

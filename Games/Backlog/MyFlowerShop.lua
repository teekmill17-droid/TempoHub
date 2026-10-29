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
getgenv().TempoHoodSubtitle = "MY FLOWER SHOP"
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
local yV_6, yV_8, yV_10, ShopGroup, MenuGroup, yV_27, yV_29, yV_30, yV_32
local nG
local op
local n4
local oQ
local Displays
local LocalPlayer
local nt
local UpgradeConfig
local oW
local connection
local oD
local nz
local og
local o1
local nY
local oJ
local nF
local oo
local n3
local oP
local nL
local ow
local ns
local n9
local oV
local nR
local oC
local ny
local of
local o0
local nX
local oI
local nE
local om
local o6
local n2
local oO
local nK
local ov
local nr
local n8
local oU
local Planters
local oB
local nx
local oe
local o_
local Options
local VirtualUser
local nD
local ol
local o5
local n1
local oN
local nJ
local ou
local n7
local oT
local nP
local oA
local nw
local ReplicaController
local oZ
local nV
local oG
local nC
local oj
local o4
local oM
local nI
local ot
local Library
local oS
local nO
local oz
local nv
local oc
local CollectionService
local nU
local oF
local nB
local oi
local o3
local n_
local oL
local nH
local oq
local EquipmentConfig
local oR
local nN
local oy
local nu
local ob
local oX
local nT
local Workspace
local connection2
local Knit
local o2
local Toggles
local oK
function fns.fn4()
    for i, v in ipairs(ou) do
        if ov("BuyDecorItems", v) then
            if n9("DecorShop", v, 1) then
                task.wait(0.15)
                return
            end
        end
    end
end
function fns.worker3()
    while not Library.Unloaded do
        if oc("AutoHarvest") then
            pcall(n4)
        end
        if oc("AutoPlantSeeds") then
            pcall(oX)
        end
        if oc("AutoStockFlowers") then
            pcall(oQ)
        end
        if oc("AutoCraftBouquets") then
            pcall(nN)
        end
        if oc("AutoPlaceBouquets") then
            pcall(oM)
        end
        if oc("AutoCheckout") then
            pcall(oT)
        end
        task.wait(nX("FarmDelay", 0.35))
    end
end
function fns.fn16()
    local uR = ob()
    local uS = uR and uR:GetAttribute("ShopOpen") == true
    if uS then
        return
    end
    if oF then
        pcall(function()
            nv(oF:ToggleShopOpen())
        end)
    end
end
function fns.fn29(eN)
    local tV_1
    local tS = eN
    local tT = {}
    if tS then
        tS = eN:FindFirstChild("Objects")
    end
    local tU = tS
    local tU_1
    if not tU then
        return tT
    end
    for i, child in ipairs(tU:GetChildren()) do
        if child:IsA("Model") then
            local Position = child:GetPivot().Position
            tU_1, tV_1 = oI(child)
            table.insert(tT, { position = Position, radius = math.max(tU_1, tV_1) * 0.55 })
        end
    end
    return tT
end
function fns.fn46(ab)
    local pV = {}
    if not ab then
        return pV
    end
    for i, child in ipairs(ab:GetChildren()) do
        table.insert(pV, child.Name)
    end
    table.sort(pV)
    return pV
end
function fns.fn55()
    for i, v in ipairs(ns) do
        if ov("BuySeedItems", v) then
            if n9("SeedShop", v, 1) then
                task.wait(0.15)
                return
            end
        end
    end
end
function fns.fn70(fE, fF, fG, fH)
    local uK = 0
    local uK_1
    local uL = fF:FindFirstChild(fE)
    local uL_2
    if uL then
        local uM_1 = (tonumber(uL:GetAttribute("Price")))
        local uQ = if uM_1 then 1 else 0
        local uO = 543 * uQ + 3321 * (1 - uQ)
        local uP = 799 * uQ + 3193 * (1 - uQ)
        if not ((uO * 972 + uP * 3579 + uO * uP) % 16777213 == 3821274) then
            uM_1 = 0
        end
        uK = uM_1
    end
    local uL_1 = uK > 0 and oP() < uK
    if uL_1 then
        return false
    end
    uK_1, uL_2 = oC(fE, fF, fG, fH)
    if not uK_1 then
        return false
    end
    local uM_2 = nv(o3:Place(fE, uK_1, "Furniture", {}))
    if uM_2 == true then
        if uL_2 then
            o2[uL_2] = nil
        end
        task.wait(0.2)
        return true
    end
    if uL_2 then
        o2[uL_2] = true
    end
    return false
end
function fns.fn81(aF, aG)
    return string.format('<font color="%s">%s</font>', aG, aF)
end
function fns.worker2()
    while not Library.Unloaded do
        task.wait(2)
        if oc("AntiAfk") then
            local yG = tick() - ow
            local yH = tick() - ot
            if yG >= 300 and yH >= 60 then
                pcall(n8)
            else
                if yG < 300 and yH >= 300 then
                    pcall(n8)
                end
            end
        end
    end
end
function fns.worker()
    local ys_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local yr = math.floor(os.clock() - om)
        if yr < 60 then
            ys_1 = yr .. "s"
        elseif yr < 3600 then
            ys_1 = string.format("%dm %ds", math.floor((yr) / (60)), yr % 60)
        else
            ys_1 = string.format("%dh %dm", math.floor((yr) / (3600)), math.floor((yr % 3600) / (60)))
        end
        o1:SetText(oS("Session time", ys_1, oi))
    end
end
function fns.fn133(ek)
    return string.format("%.1f:%.1f", ek.X, ek.Z)
end
function fns.fn164()
    local yb = tonumber(n7("PlaceDisplayRotation", "0")) or 0
    local yb_1 = nX("PlaceDisplaySpacing", 4)
    for i, v in ipairs(oB) do
        if ov("PlaceDisplayItems", v) then
            if n3(v, Displays, yb, yb_1) then
                return
            end
        end
    end
end
function fns.fn172()
    local yl_1
    local yk_1
    if identifyexecutor then
        yl_1, yk_1 = identifyexecutor()
        local ym = yl_1 ~= ""
        local yn = type(yl_1) == "string" and ym
        if yn then
            local ym_1 = type(yk_1) == "string" and yk_1 ~= "" and yl_1 .. " " .. yk_1
            nO = ym_1 or yl_1
        end
    end
end
function fns.fn174()
    local sf = ob()
    local sg = {}
    if not sf then
        return sg
    end
    for i, v in ipairs(CollectionService:GetTagged("FlowerDisplay")) do
        if v:IsDescendantOf(sf) then
            table.insert(sg, v)
        end
    end
    return sg
end
function fns.onInputBegan()
    ow = tick()
end
function fns.onUnload()
    Library:Unload()
end
function fns.fn211(gm)
    local vz = tonumber(gm:GetAttribute("Max")) or 8
    local vA = 0
    for k, v in pairs(gm:GetAttributes()) do
        local vz_1 = type(k) == "string" and k:sub(1, 6) == "Stock_" and typeof(v) == "number"
        if vz_1 then
            vA = vA + v
        end
    end
    return vA < vz
end
function fns.fn248()
    local sA = ob()
    if not sA then
        return nil
    end
    for i, v in ipairs(CollectionService:GetTagged("CraftTable")) do
        if v:IsDescendantOf(sA) then
            return v
        end
    end
end
function fns.fn274()
    select("#", "Unloaded!")
end
function fns.fn304()
    for i, v in ipairs(nH()) do
        if nK(v) then
            local vJ
            for i, v in ipairs(oL) do
                if ov("StockFlowerItems", v) then
                    vJ = o5(v)
                    if vJ then
                        break
                    end
                end
            end
            if not vJ then
                vJ = o5(nil)
                local vK_1 = vJ and not ov("StockFlowerItems", vJ.Name)
                if vK_1 then
                    vJ = nil
                end
            end
            local vK_2 = vJ and oz(vJ)
            if vK_2 then
                local vJ_1 = nv(ny:StockFlower(v))
                if vJ_1 == true then
                    task.wait(0.1)
                    return
                end
            end
        end
    end
end
function fns.fn306()
    local r6 = ob()
    local r7 = {}
    if not r6 then
        return r7
    end
    for i, v in ipairs(CollectionService:GetTagged("Planter")) do
        if v:IsDescendantOf(r6) then
            table.insert(r7, v)
        end
    end
    return r7
end
function fns.fn314(bg, bh)
    local qp = nD(bg)
    if not oV(qp) then
        return bh
    end
    local qq
    for k, v in pairs(qp) do
        if v then
            local qp_1 = tonumber(k)
            if qp_1 ~= nil then
                local qr = qq == nil or qp_1 < tonumber(qq)
                if qr then
                    qq = k
                end
            else
                local qp_2 = qq == nil or tostring(k) < tostring(qq)
                if qp_2 then
                    qq = k
                end
            end
        end
    end
    return qq or bh
end
function fns.fn315(aR)
    local p6 = Toggles[aR]
    return p6 ~= nil and p6.Value == true
end
function fns.fn324(ba, bb)
    local qn = nD(ba)
    if not oV(qn) then
        return true
    end
    return qn[bb] == true
end
function fns.fn352()
    nU(op, "Copied Discord invite to clipboard")
end
function fns.fn366(cs)
    local Character = LocalPlayer.Character
    if Character then
        for i, child in ipairs(Character:GetChildren()) do
            local ru_1 = (child:IsA("Tool"))
            if ru_1 then
                local rv_1 = child:GetAttribute("SeedType") == cs or child.Name == cs
                ru_1 = rv_1
            end
            if ru_1 then
                return child
            end
        end
    end
    local Backpack = LocalPlayer:FindFirstChild("Backpack")
    if not Backpack then
        return nil
    end
    for i, child in ipairs(Backpack:GetChildren()) do
        local ru_3 = (child:IsA("Tool"))
        if ru_3 then
            local rv_2 = child:GetAttribute("SeedType") == cs or child.Name == cs
            ru_3 = rv_2
        end
        if ru_3 then
            return child
        end
    end
end
function fns.fn394()
    local qO = nP()
    return qO and qO.Data
end
function fns.fn398(e5)
    local ue = ob()
    if not ue then
        return nil
    end
    local uf = ue:FindFirstChild("Building") and ue.Building:FindFirstChild("BuildArea")
    if not uf then
        return nil
    elseif e5 == "Planter" then
        return uf:FindFirstChild("Farm")
    else
        return uf:FindFirstChild("Floor1")
    end
end
function fns.fn401(eY, eZ, e_)
    local t2 = Vector3.new(eY.X, 0, eY.Z)
    for i, v in ipairs(eZ) do
        local Magnitude = (t2 - Vector3.new(v.position.X, 0, v.position.Z)).Magnitude
        if Magnitude < math.max(e_, v.radius) then
            return true
        end
    end
    return false
end
local function fn434()
    local Character = LocalPlayer.Character
    local rc = Character and Character:FindFirstChild("HumanoidRootPart")
    return rc
end
local function fn435()
    for i, v in ipairs(n2()) do
        local uX = tonumber(v:GetAttribute("Slots")) or 1
        local u9 = 1
        while u9 <= uX do
            local vb = u9
            local attr3 = v:GetAttribute("Slot_" .. vb .. "_Seed")
            local attr2 = v:GetAttribute("Slot_" .. vb .. "_Ready")
            local attr = v:GetAttribute("Slot_" .. vb .. "_Locked")
            local u_ = not attr
            if u_ ~= false then
                u_ = attr3
            end
            if u_ then
                u_ = attr3 ~= ""
            end
            if u_ then
                u_ = attr2
            end
            if u_ then
                u_ = ov("HarvestSeedItems", attr3)
            end
            if u_ then
                local uX_2 = nv(nB:Harvest(v, vb))
                if uX_2 == true then
                    task.wait(0.1)
                    return
                end
            end
            u9 += 1
        end
    end
end
local function fn449()
    oD()
    local wO = ob()
    if not wO then
        return
    end
    local wP = wO:FindFirstChild("Building") and wO.Building:FindFirstChild("Register")
    if not wP then
        return
    end
    local CheckoutPrompt = wP:FindFirstChild("CheckoutPrompt", true)
    if not CheckoutPrompt or not CheckoutPrompt.Enabled then
        return
    end
    if CheckoutPrompt.ActionText ~= "Checkout" then
        return
    end
    local wO_3 = nR()
    local Parent = CheckoutPrompt.Parent
    local wR = wO_3 and Parent and Parent:IsA("BasePart")
    if wR then
        if (wO_3.Position - Parent.Position).Magnitude > 12 then
            wO_3.CFrame = Parent.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.15)
        end
    end
    o0(CheckoutPrompt)
end
local function fn450()
    for i, v in ipairs(n2()) do
        local vc = tonumber(v:GetAttribute("Slots")) or 1
        local vq = 1
        while vq <= vc do
            local vr = vq
            local attr2 = v:GetAttribute("Slot_" .. vr .. "_Seed")
            local attr = v:GetAttribute("Slot_" .. vr .. "_Locked")
            local ve = not attr
            local vg = not attr2 or attr2 == ""
            local vc_2 = ve
            if ve ~= false then
                vc_2 = vg
            end
            if vc_2 then
                for i, v2 in ipairs(ns) do
                    if ov("PlantSeedItems", v2) then
                        local vc_3 = of(v2)
                        local vd_2 = vc_3 and oz(vc_3)
                        if vd_2 then
                            local vc_4 = nv(nB:PlantSeed(v, v2, vr))
                            if vc_4 == true then
                                task.wait(0.1)
                                return
                            end
                        end
                    end
                end
            end
            vq += 1
        end
    end
end
local function worker5()
    while not Library.Unloaded do
        if oc("AutoBuyPlanters") then
            pcall(nT)
        end
        if oc("AutoBuyDisplays") then
            pcall(oK)
        end
        if oc("AutoPlacePlanters") then
            pcall(n1)
        end
        if oc("AutoPlaceDisplays") then
            pcall(o6)
        end
        task.wait(nX("BuildDelay", 0.45))
    end
end
local function fn487(dX, dY)
    if not nr then
        return nil
    end
    local to = nv(nr:GetShopStock(dX))
    if type(to) ~= "table" then
        return nil
    end
    for i, v in ipairs(to) do
        local to_1 = type(v) == "table" and v.Name == dY
        if to_1 then
            return i, v
        end
    end
end
local function fn496()
    local Plots = Workspace:FindFirstChild("Plots")
    if not Plots then
        return nil
    end
    local q0 = Plots:FindFirstChild(LocalPlayer.Name .. "Plot")
    if q0 then
        return q0
    end
    for i, child in ipairs(Plots:GetChildren()) do
        if child:GetAttribute("Owner") == LocalPlayer.Name then
            return child
        end
    end
end
local function fn497(fb, fc, fd, fe)
    local uk = fc:FindFirstChild(fb)
    local um = fc == Planters and "Planter" or "Display"
    local ul_1 = nt(um)
    local um_1 = ob()
    local un = uk and ul_1
    local un_1
    local uo = un and um_1
    local uo_1
    if not uo then
        return nil
    end
    uo_1, un_1 = oI(uk)
    local uk_1 = oA(um_1)
    local um_2 = math.max(uo_1, un_1) * 0.5 + 0.5
    local max = math.max
    local floor = math.floor
    local ur = tonumber(fe) or math.ceil(um_2 + 1)
    local us = max(1, floor(ur))
    local up_1 = ul_1.Size.X * 0.5 - um_2
    local uq_1 = ul_1.Size.Z * 0.5 - um_2
    if up_1 < 0 or uq_1 < 0 then
        return nil
    end
    local uC = -up_1
    while us > 0 and uC <= up_1 or us <= 0 and uC >= up_1 do
        local uD = uC
        local uH = -uq_1
        while us > 0 and uH <= uq_1 or us <= 0 and uH >= uq_1 do
            local uI = uH
            local um_6 = ul_1.CFrame:PointToWorldSpace(Vector3.new(uD, 0, uI))
            local up_2 = oe(um_6, ul_1, uo_1, un_1, fd)
            local um_7 = oZ(up_2)
            local ur_1 = not o2[um_7] and nz(ul_1, up_2) and not nV(up_2, uk_1, us - 0.25)
            if ur_1 then
                local ur_2 = CFrame.new(up_2)
                local Angles = CFrame.Angles
                local uv = tonumber(fd) or 0
                local ut_1 = ur_2 * Angles(0, math.rad(uv), 0)
                return ut_1, um_7
            end
            uH += us
        end
        uC += us
    end
end
local function fn500(ay, az)
    if setclipboard then
        setclipboard(ay)
    elseif toclipboard then
        toclipboard(ay)
    end
    Library:Notify(az)
end
local function fn507(a1)
    local qc = Options[a1]
    return qc and qc.Value or {}
end
local function worker4()
    while not Library.Unloaded do
        if oc("AutoBuySeeds") then
            pcall(n_)
        end
        if oc("AutoBuySupplies") then
            pcall(nJ)
        end
        if oc("AutoBuyDecorations") then
            pcall(nI)
        end
        if oc("AutoBuyUpgrades") then
            pcall(oW)
        end
        if oc("AutoHireStaff") then
            pcall(nx)
        end
        task.wait(nX("ShopDelay", 0.5))
    end
end
local function onCopyJoinScript_JobID()
    local yp = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, oU)
    if setclipboard then
        setclipboard(yp)
    elseif toclipboard then
        toclipboard(yp)
    end
    Library:Notify("Copied join script to clipboard")
end
local function fn558(eG, eH)
    local tN = eG.CFrame:PointToObjectSpace(eH)
    local tO = eG.Size.X * 0.5
    local tP = eG.Size.Z * 0.5
    local tQ = math.abs(tN.X) <= tO - 0.5 and math.abs(tN.Z) <= tP - 0.5
    return tQ
end
local function fn560(d5, d6, d7)
    local tx_1
    local tw_1
    tx_1, tw_1 = oO(d5, d6)
    if not tx_1 then
        return false
    elseif tw_1.Locked then
        return false
    else
        local ty = tonumber(tw_1.Stock) or 0
        local ty_1 = tonumber(tw_1.Cost) or 0
        if ty <= 0 then
            return false
        end
        local ty_2 = ty_1 > 0 and oP() < ty_1
        if ty_2 then
            return false
        end
        local tw_3 = d7 or 1
        local ty_3 = nv(nr:BuyItem(d5, tx_1, tw_3))
        return ty_3 == true
    end
end
local function fn579()
    local qU = nw()
    local qV = qU and typeof(qU.Cash) == "number"
    if qV then
        return qU.Cash
    end
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local qV_1 = leaderstats and leaderstats:FindFirstChild("Cash")
    local qU_2 = qV_1
    if qV_1 then
        qV_1 = tonumber(qU_2.Value)
    end
    return qV_1 or 0
end
local function fn583()
    if not ny then
        return
    end
    for i, v in ipairs(oN()) do
        if nE(v) then
            local wr
            for i, v in ipairs(oq) do
                if ov("PlaceBouquetItems", v) then
                    wr = oo(v)
                    if wr then
                        break
                    end
                end
            end
            if not wr then
                wr = oo(nil)
                if wr then
                    local attr = wr:GetAttribute("Container")
                    local wt = attr and not ov("PlaceBouquetItems", attr)
                    if wt then
                        wr = nil
                    end
                end
            end
            local ws_2 = wr and oz(wr)
            if ws_2 then
                local wr_1 = nv(ny:BulkStockArrangement(v))
                if wr_1 ~= true then
                    wr_1 = nv(ny:StockArrangement(v))
                end
                if wr_1 == true then
                    task.wait(0.15)
                    return
                end
            end
        end
    end
end
local function fn606()
    local xm = nv(o_:GetApplicants())
    if type(xm) ~= "table" then
        return
    end
    local xn = nv(o_:GetStaffLimits())
    local xo = nv(o_:GetMyStaff())
    local xp = type(xn) == "table"
    if xp then
        xp = xn.limits or xn
    end
    local xq_2 = xp or {}
    for i, v in ipairs(ol) do
        if ov("HireStaffItems", v) then
            local xp_1 = 0
            local xq_3 = type(xo) == "table" and type(xo[v]) == "table"
            if xq_3 then
                for k in pairs(xo[v]) do
                    xp_1 = xp_1 + 1
                end
            end
            local xq_4 = tonumber(xq_2[v]) or 0
            if xp_1 < xq_4 then
                local xp_2 = xm[v]
                if type(xp_2) == "table" then
                    local xq_5 = #xp_2
                    local xF = 1
                    while xF <= xq_5 do
                        local xG = xF
                        local xp_3 = nv(o_:HireApplicant(v, xG))
                        if xp_3 == true then
                            task.wait(0.3)
                            return
                        end
                        xF += 1
                    end
                end
            end
        end
    end
end
local function fn618()
    for k, v in pairs(ReplicaController._replicas) do
        local qG = type(v.Data) == "table" and v.Data.Cash ~= nil
        if qG then
            return v
        end
    end
end
local function fn636()
    local x2 = tonumber(n7("PlacePlanterRotation", "0")) or 0
    local x2_1 = nX("PlacePlanterSpacing", 4)
    for i, v in ipairs(oG) do
        if ov("PlacePlanterItems", v) then
            if n3(v, Planters, x2, x2_1) then
                return
            end
        end
    end
end
local function fn644()
    local xU = tonumber(n7("BuyDisplayRotation", "0")) or 0
    local xU_1 = nX("BuyDisplaySpacing", 4)
    for i, v in ipairs(oB) do
        if ov("BuyDisplayItems", v) then
            if n3(v, Displays, xU, xU_1) then
                return
            end
        end
    end
end
local function fn650()
    if not oy then
        return
    end
    local vY = og()
    if not vY then
        return
    end
    local vZ = nL()
    if #vZ == 0 then
        return
    end
    local v_ = nY()
    for i, v in ipairs(oq) do
        if ov("CraftBouquetItems", v) then
            local v0 = nF:FindFirstChild(v)
            local v1 = v0 and tonumber(v0:GetAttribute("requiredLevel"))
            if v_ >= (v1 or 1) then
                local v1_2 = v0 and tonumber(v0:GetAttribute("maxFlowers"))
                local v0_1 = v1_2
                local v6 = if v0_1 then 1 else 0
                local v4 = 2109 * v6 + 1049 * (1 - v6)
                local v5 = 1888 * v6 + 906 * (1 - v6)
                if not ((v4 * 584 + v5 * 477 + v4 * v5) % 16777213 == 6114024) then
                    v0_1 = 1
                end
                local v1_3 = {}
                local v2_1 = v0_1
                local v0_2 = math.min(v2_1, #vZ)
                local wf = 1
                while wf <= v0_2 do
                    local wg = wf
                    table.insert(v1_3, vZ[wg])
                    wf += 1
                end
                if #v1_3 > 0 then
                    local v0_3 = nv(oy:StartArranging(vY))
                    if v0_3 ~= true then
                        return
                    end
                    local v0_4 = false
                    local v2_2 = {}
                    for i, v in ipairs(v1_3) do
                        local v1_4 = nv(oy:ReserveFlower(v))
                        if v1_4 == true then
                            table.insert(v2_2, v)
                        else
                            v0_4 = true
                            break
                        end
                    end
                    if v0_4 or #v2_2 == 0 then
                        pcall(function()
                            nv(oy:CancelArranging())
                        end)
                        return
                    end
                    local v0_5 = { container = v, accents = {}, flowers = v2_2 }
                    local v1_6 = nv(oy:FinishArranging(v0_5))
                    if v1_6 ~= true then
                        pcall(function()
                            nv(oy:CancelArranging())
                        end)
                        return
                    end
                    task.wait(0.2)
                    return
                end
            end
        end
    end
end
local function fn653()
    local xI = (tonumber(n7("BuyPlanterRotation", "0")))
    local xN = if xI then 1 else 0
    local xL = 3696 * xN + 3451 * (1 - xN)
    local xM = 2239 * xN + 4032 * (1 - xN)
    if not ((xL * 911 + xM * 2839 + xL * xM) % 16777213 == 1221708) then
        xI = 0
    end
    local xJ = xI
    local xI_1 = nX("BuyPlanterSpacing", 4)
    for i, v in ipairs(oG) do
        if ov("BuyPlanterItems", v) then
            if n3(v, Planters, xJ, xI_1) then
                return
            end
        end
    end
end
local function fn662(aW, aX)
    local p9 = Options[aW]
    local qa = p9 and tonumber(p9.Value)
    return qa or aX
end
local function onInputChanged(j7)
    local UserInputType = j7.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        ow = tick()
    end
end
local function fn702()
    connection:Disconnect()
    connection2:Disconnect()
end
local function fn709(a6)
    for k, v in pairs(a6) do
        if v then
            return true
        end
    end
    return false
end
local function fn729(aI, aJ, aK)
    return string.format("<b>%s</b> %s %s", aI, nu("-", "#5a6070"), nu(aJ, aK))
end
local function fn742()
    for i, v in ipairs(o4) do
        if ov("BuySupplyItems", v) then
            if n9("SupplyShop", v, 1) then
                task.wait(0.15)
                return
            end
        end
    end
end
local function fn758()
    local w9 = nw()
    local xa = oP()
    if ov("BuyUpgradeItems", "Advertising") then
        local xb_1 = w9 and w9.Upgrades and tonumber(w9.Upgrades.Advertising)
        local xc_1 = xb_1 or 0
        local Advertising = UpgradeConfig.Advertising
        local xd_1 = Advertising
        if xd_1 then
            xd_1 = not Advertising.maxLevel or xc_1 < Advertising.maxLevel
        end
        if xd_1 then
            local xd_2 = Advertising.cost and Advertising.cost(xc_1)
            if xa >= (xd_2 or 0) then
                local xb_4 = nv(oR:Purchase("Advertising"))
                if xb_4 == true then
                    task.wait(0.2)
                    return
                end
            end
        end
    end
    if ov("BuyUpgradeItems", "Backpack") then
        local xb_5 = nv(oR:Purchase("Backpack"))
        if xb_5 == true then
            task.wait(0.2)
            return
        end
    end
    if ov("BuyUpgradeItems", "Craft Table") then
        local xb_6 = w9 and w9.EquipmentLevels and tonumber(w9.EquipmentLevels.CraftTable)
        local w9_1 = xb_6 or 1
        local w9_2 = EquipmentConfig.GetUpgradeCostForEquipment("CraftTable", w9_1)
        if w9_2 and xa >= w9_2 then
            local w9_3 = nv(oJ:UpgradeEquipment("CraftTable"))
            if w9_3 == true then
                task.wait(0.2)
                return
            end
        end
    end
    local w9_4 = nv(o3:GetExpansionData())
    if type(w9_4) ~= "table" then
        return
    end
    local xi = if ov("BuyUpgradeItems", "Shop Expansion") then 1 else 0
    if xi == 1 then
        local xb_9 = ob() and ob():GetAttribute("BuildingLevel")
        local xc_4 = tonumber(xb_9) or 1
        local xc_5 = xc_4 + 1
        local xb_11 = w9_4.Shop and w9_4.Shop[xc_5]
        local xd_3 = xb_11
        if xb_11 then
            xb_11 = tonumber(xd_3.cost)
        end
        local xe_2 = xb_11 or 0
        local xb_12 = xd_3
        if xb_12 then
            xb_12 = xa >= xe_2
        end
        if xb_12 then
            local xb_13 = nv(o3:PurchaseExpansion("Shop", xc_5))
            if xb_13 == true then
                task.wait(0.25)
                return
            end
        end
    end
    if ov("BuyUpgradeItems", "Farm Expansion") then
        local xb_14 = ob() and ob():GetAttribute("FarmLevel")
        local xc_6 = tonumber(xb_14) or 1
        local xc_7 = xc_6 + 1
        local xb_16 = w9_4.Farm and w9_4.Farm[xc_7]
        local w9_5 = xb_16
        if xb_16 then
            xb_16 = tonumber(w9_5.cost)
        end
        local xd_5 = xb_16 or 0
        local xb_17 = w9_5
        if xb_17 then
            xb_17 = xa >= xd_5
        end
        if xb_17 then
            local w9_7 = nv(o3:PurchaseExpansion("Farm", xc_7))
            if w9_7 == true then
                task.wait(0.25)
                return
            end
        end
    end
end
local function fn777()
    local sI = nw()
    local sJ = sI and tonumber(sI.Level)
    return sJ or 1
end
local function fn801()
    nB = Knit.GetService("GrowingService")
    ny = Knit.GetService("FlowerDisplayService")
    nr = Knit.GetService("ShopService")
    o3 = Knit.GetService("PlacementService")
    o_ = Knit.GetService("StaffService")
    oR = Knit.GetService("UpgradeService")
    oJ = Knit.GetService("EquipmentService")
    oF = Knit.GetService("CustomerService")
    oy = Knit.GetService("ArrangementService")
end
local function fn827(dR)
    local tk = tonumber(dR:GetAttribute("Max")) or 8
    local Arrangements = dR:FindFirstChild("_Arrangements")
    local tm = Arrangements and #Arrangements:GetChildren()
    return (tm or 0) < tk
end
local function onRscripts()
    nU(oj, "Copied Rscripts profile to clipboard")
end
local function fn835(jf)
    local DiscordGroup = jf:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = nG })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = nG })
end
local function fn837(cn)
    local ro = nC()
    if not (ro and cn) then
        return false
    elseif cn.Parent == LocalPlayer.Character then
        return true
    else
        ro:EquipTool(cn)
        task.wait(0.15)
        return cn.Parent == LocalPlayer.Character
    end
end
local function fn842(et, eu, ev, ew, ex)
    local tI = math.max(1, math.round(ev))
    local tJ = math.max(1, math.round(ew))
    local tK = tonumber(ex) or 0
    local tL = tK % 360
    if tL == 90 or tL == 270 or tL == -90 or tL == -270 then
        tI, tJ = tJ, tI
    end
    local tK_2 = tI / 2 % 1
    local tI_1 = tJ / 2 % 1
    local tJ_1 = eu.Position.Y + eu.Size.Y / 2
    return Vector3.new(math.floor((et.X - tK_2) / 1 + 0.5) * 1 + tK_2, tJ_1, math.floor((et.Z - tI_1) / 1 + 0.5) * 1 + tI_1)
end
local function fn843()
    local so = ob()
    local sp = {}
    if not so then
        return sp
    end
    for i, v in ipairs(CollectionService:GetTagged("ArrangementDisplay")) do
        if v:IsDescendantOf(so) then
            table.insert(sp, v)
        end
    end
    return sp
end
local function fn850()
    local Character = LocalPlayer.Character
    local rf = Character and Character:FindFirstChildOfClass("Humanoid")
    return rf
end
local function fn882()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    ot = tick()
end
nr = nil
ns = nil
nt = nil
nu = nil
nv = nil
nw = nil
nx = nil
ny = nil
nz = nil
connection2 = nil
nB = nil
nC = nil
nD = nil
nE = nil
nF = nil
nG = nil
nH = nil
nI = nil
nJ = nil
nK = nil
nL = nil
Displays = nil
nN = nil
nO = nil
nP = nil
Planters = nil
nR = nil
connection = nil
nT = nil
nU = nil
nV = nil
Options = nil
nX = nil
nY = nil
Toggles = nil
n_ = nil
n1 = nil
n2 = nil
n3 = nil
n4 = nil
EquipmentConfig = nil
Library = nil
n7 = nil
n8 = nil
n9 = nil
UpgradeConfig = nil
ob = nil
oc = nil
ReplicaController = nil
local Flowers
oe = nil
of = nil
og = nil
Knit = nil
oi = nil
oj = nil
ol = nil
om = nil
oo = nil
op = nil
oq = nil
ot = nil
ou = nil
ov = nil
ow = nil
LocalPlayer = nil
oy = nil
oz = nil
oA = nil
oB = nil
oC = nil
oD = nil
Workspace = nil
oF = nil
oG = nil
VirtualUser = nil
oI = nil
oJ = nil
oK = nil
oL = nil
oM = nil
oN = nil
oO = nil
oP = nil
oQ = nil
oR = nil
oS = nil
oT = nil
oU = nil
oV = nil
oW = nil
oX = nil
CollectionService = nil
oZ = nil
o_ = nil
o0 = nil
o1 = nil
o2 = nil
o3 = nil
o4 = nil
o5 = nil
o6 = nil
CollectionService, VirtualUser, Workspace, LocalPlayer, op, oj, Knit, ReplicaController, UpgradeConfig, EquipmentConfig, Flowers, yV_6, Planters, Displays, yV_29, nF, nB, ny, nr, o3, o_, oR, oJ, oF, oy, yV_27 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local yV_13 = game:GetService("Players")
local yV_4 = game:GetService("ReplicatedStorage")
CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
Workspace = game:GetService("Workspace")
LocalPlayer = yV_13.LocalPlayer
local yV_18 = "My Flower Shop"
op = "https://discord.gg/K7Qxnxkk46"
oj = "https://discord.gg/K7Qxnxkk46"
Knit = require(yV_4:WaitForChild("Packages"):WaitForChild("Knit"))
ReplicaController = require(yV_4:WaitForChild("ReplicaController"))
UpgradeConfig = require(yV_4:WaitForChild("Shared"):WaitForChild("UpgradeConfig"))
if ((o_ and ny or (not Workspace or o_)) and ((not o_ or yV_13) and (Workspace and yV_29)) or (yV_29 and not yV_29 or (ny or UserInputService) or not Workspace and not ny and (not Workspace and not Workspace))) and not ((o_ and ny or (not Workspace or o_)) and ((not o_ or yV_13) and (Workspace and yV_29)) or (yV_29 and not yV_29 or (ny or UserInputService) or not Workspace and not ny and (not Workspace and not Workspace))) then
    yV_4 = require(EquipmentConfig:WaitForChild("Shared"):WaitForChild("EquipmentConfig"))
else
    EquipmentConfig = require(yV_4:WaitForChild("Shared"):WaitForChild("EquipmentConfig"))
end
local yV_25 = yV_4:WaitForChild("Assets")
Flowers = yV_25:WaitForChild("Flowers")
local yV_17 = yV_25:WaitForChild("Seeds")
if (false and yV_17 or yV_17 and false) and (o3 and false and (false and o3)) and not ((false and yV_17 or yV_17 and false) and (o3 and false and (false and o3))) then
    yV_25 = yV_6:WaitForChild("Supplies")
else
    yV_6 = yV_25:WaitForChild("Supplies")
end
local yV_2 = yV_25:WaitForChild("Objects")
Planters = yV_2:WaitForChild("Planters")
Displays = yV_2:WaitForChild("Displays")
yV_29 = yV_2:WaitForChild("Decor")
if (not yV_29 or yV_18 or not yV_17 and yV_13 or not yV_13 and not yV_29 and (yV_18 and not yV_13)) and (yV_17 or not yV_13 or (yV_29 or not yV_29) or (not yV_29 and yV_18 or yV_18 and not yV_17)) and not ((not yV_29 or yV_18 or not yV_17 and yV_13 or not yV_13 and not yV_29 and (yV_18 and not yV_13)) and (yV_17 or not yV_13 or (yV_29 or not yV_29) or (not yV_29 and yV_18 or yV_18 and not yV_17))) then
    yV_27:WaitForChild("Arrangements")
    nF = fn801
else
    nF = yV_25:WaitForChild("Arrangements")
    yV_27 = fn801
end
yV_13 = pcall(yV_27)
if not yV_13 then
    yV_2 = os.clock()
    while os.clock() - yV_2 < 10 do
        yV_13 = pcall(yV_27)
        if yV_13 then
            break
        end
        task.wait(0.25)
    end
end
ns, o4 = nil, nil
local yV_15 = fns.fn46
ns = yV_15(yV_17)
o4 = {}
for i, v in ipairs(yV_15(yV_6)) do
    if v ~= "Lock" then
        table.insert(o4, v)
    end
end
oL, oG, oB, ou, oq, ol, Library, Toggles, Options, oi, o2, nU, nG, nu, oS, oc, nX, nD, oV, ov, n7, nv, nP, nw, oP, ob, nR, nC, o0, oz, of, o5, n2, nH, oN, og, nY, nL, oo, nE, oO, n9, oZ, oI, oe, nz, oA, nV, nt, oC, n3, oD, n4, oX, nK, oQ, nN, oM, nI, oT, n_, nJ, oW, nx, nT, oK, n1, o6 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
oL = yV_15(Flowers)
oG = yV_15(Planters)
oB = yV_15(Displays)
ou = yV_15(yV_29)
oq = yV_15(nF)
if (o6 and o6 or not o6 and not oG) and (not o6 or not o6 or o6 and not oG) and ((oG or oG) and (o6 and o6) or (not o6 or not o6 or (not o6 or o6))) and not ((o6 and o6 or not o6 and not oG) and (not o6 or not o6 or o6 and not oG) and ((oG or oG) and (o6 and o6) or (not o6 or not o6 or (not o6 or o6)))) then
    yV_30 = { "Gardener", "Cashier" }
    ol = { "Advertising", "Craft Table", "Shop Expansion", "Farm Expansion", "Backpack" }
    yV_8 = { "225", "0", "315", "135", "45", "180", "270", "90" }
else
    ol = { "Gardener", "Cashier" }
    yV_8 = { "Advertising", "Shop Expansion", "Farm Expansion", "Backpack", "Craft Table" }
    yV_30 = { "0", "45", "90", "135", "180", "225", "270", "315" }
end
Library = getgenv().Library
yV_17 = getgenv().ThemeManager
yV_27 = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
nU = fn500
nG = fns.fn352
nu = fns.fn81
oS = fn729
local yV_20 = "#7fd47f"
local yV_31 = "#6ec1ff"
oi = "#e8a34d"
local yV_19 = "#8b93a3"
oc = fns.fn315
nX = fn662
nD = fn507
oV = fn709
ov = fns.fn324
n7 = fns.fn314
nv = function(bs)
    local qz
    local qA
    local qB
    local qC
    local qD = typeof(bs) == "table" and bs.andThen
    if qD then
        qA, qz, qC, qB = nil, nil, nil, nil
        bs:andThen(function(by, bz, bA)
            qA = true
            qz, qC, qB = by, bz, bA
        end):catch(function(bF)
            qA = true
            qz, qC = false, tostring(bF)
        end)
        local qD_1 = os.clock()
        while true do
            local qE = not qA and os.clock() - qD_1 < 8
            if qE then
                task.wait(0.05)
                continue
            end
            break
        end
        return qz, qC, qB
    end
    return bs
end
nP = fn618
nw = fns.fn394
oP = fn579
ob = fn496
nR = fn434
nC = fn850
o0 = function(cj)
    if not cj then
        return false
    elseif fireproximityprompt then
        return pcall(function()
            local rh = cj.HoldDuration or 0
            fireproximityprompt(cj, rh)
        end)
    else
        return pcall(function()
            cj:InputHoldBegin()
            local rl = cj.HoldDuration or 0
            task.wait(math.max(0.05, rl))
            cj:InputHoldEnd()
        end)
    end
end
oz = fn837
of = fns.fn366
o5 = function(cH)
    local function rS(cJ)
        if not cJ:IsA("Tool") then
            return false
        elseif not Flowers:FindFirstChild(cJ.Name) then
            return false
        else
            if cH and cH ~= "" then
                return cJ.Name == cH
            end
            return true
        end
    end
    local Character = LocalPlayer.Character
    if Character then
        for i, child in ipairs(Character:GetChildren()) do
            if rS(child) then
                return child
            end
        end
    end
    local Backpack = LocalPlayer:FindFirstChild("Backpack")
    if not Backpack then
        return nil
    end
    for i, child in ipairs(Backpack:GetChildren()) do
        if rS(child) then
            return child
        end
    end
end
n2 = fns.fn306
nH = fns.fn174
oN = fn843
og = fns.fn248
nY = fn777
nL = function()
    local dq = {}
    local function dr(ds)
        if not ds then
            return
        end
        for i, child in ipairs(ds:GetChildren()) do
            local sL = child:IsA("Tool") and Flowers:FindFirstChild(child.Name)
            if sL then
                local sL_1 = tonumber(child:GetAttribute("Count")) or 1
                local sL_2 = math.max(1, sL_1)
                local sW = 1
                while sW <= sL_2 do
                    table.insert(dq, child.Name)
                    sW += 1
                end
            end
        end
    end
    dr(LocalPlayer:FindFirstChild("Backpack"))
    dr(LocalPlayer.Character)
    return dq
end
oo = function(dD)
    local function s5(dF)
        local sZ = not dF:IsA("Tool")
        local s4 = if sZ then 1 else 0
        local s2 = 1417 * s4 + 2995 * (1 - s4)
        local s3 = 2499 * s4 + 3738 * (1 - s4)
        if not ((s2 * 55 + s3 * 2158 + s2 * s3) % 16777213 == 9011860) then
            sZ = not dF:GetAttribute("IsArrangement")
        end
        if sZ then
            return false
        end
        local attr = dF:GetAttribute("Container")
        if dD and dD ~= "" then
            return attr == dD
        end
        return true
    end
    local Character = LocalPlayer.Character
    if Character then
        for i, child in ipairs(Character:GetChildren()) do
            if s5(child) then
                return child
            end
        end
    end
    local Backpack = LocalPlayer:FindFirstChild("Backpack")
    if not Backpack then
        return nil
    end
    for i, child in ipairs(Backpack:GetChildren()) do
        if s5(child) then
            return child
        end
    end
end
nE = fn827
oO = fn487
n9 = fn560
o2 = {}
oZ = fns.fn133
oI = function(em)
    local tG_1
    local tF_1
    local tE_1
    if not em then
        return 2, 2
    elseif em.PrimaryPart then
        return em.PrimaryPart.Size.X, em.PrimaryPart.Size.Z
    else
        tF_1, tE_1, tG_1 = pcall(function()
            return em:GetBoundingBox()
        end)
        local tE_2 = tF_1 and typeof(tG_1) == "Vector3"
        if tE_2 then
            return tG_1.X, tG_1.Z
        end
        return 2, 2
    end
end
oe = fn842
nz = fn558
oA = fns.fn29
nV = fns.fn401
nt = fns.fn398
oC = fn497
n3 = fns.fn70
oD = fns.fn16
n4 = fn435
oX = fn450
nK = fns.fn211
oQ = fns.fn304
nN = fn650
oM = fn583
nI = fns.fn4
oT = fn449
n_ = fns.fn55
nJ = fn742
oW = fn758
nx = fn606
nT = fn653
oK = fn644
n1 = fn636
o6 = fns.fn164
yV_25 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = op, Copyable = true }, "|", yV_18 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
yV_6 = {
    Info = yV_25:AddTab("Info", "info"),
    Main = yV_25:AddTab("Main", "flower-2"),
    Settings = yV_25:AddTab("Settings", "settings")
}
yV_6.Farm = yV_6.Main:AddSubTab("Farm", "sprout")
yV_6.Shop = yV_6.Main:AddSubTab("Shop", "shopping-cart")
yV_6.Build = yV_6.Main:AddSubTab("Build", "hammer")
yV_4 = fn835
for k, v in yV_6 do
    if v ~= yV_6.Main then
        yV_4(v)
    end
end
nO, yV_13, yV_15, o1, oU, yV_25 = nil, nil, nil, nil, nil, nil
yV_2 = 8
repeat
    yV_4 = (yV_2 * 2 + 0) % 3 + 1
    if yV_4 <= 2 then
        if yV_4 <= 1 then
            local Ah = bit32.rrotate(bit32.bxor(bit32.lrotate(yV_2, 30), string.byte(tostring(o1))), 24)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(Ah, 738081225), 359194013), (bit32.bxor(bit32.band(Ah, 3556886070), 1512109426))), 359194013), 1512109426) == Ah then
                yV_25 = #oU > 18
            else
                oU = #yV_25 > 18
            end
            yV_2 = (yV_2 + 2) % 24
        else
            yV_4 = (vector.create((yV_2 * 3 + 9) % 11 + 1, (yV_2 * 2 + 11) % 13 + 1, (yV_2 * 6 + 8) % 17 + 1))
            yV_29 = (vector.create((yV_2 * 4 + 3) % 11 + 1, (yV_2 * 9 + 5) % 13 + 1, (yV_2 * 9 + 5) % 17 + 1))
            yV_10 = (vector.create((yV_2 * 5 + 7) % 11 + 1, (yV_2 * 6 + 5) % 13 + 1, (yV_2 * 14 + 6) % 17 + 1))
            yV_32 = (vector.create((yV_2 * 1 + 2) % 11 + 1, (yV_2 * 1 + 13) % 13 + 1, (yV_2 * 2 + 14) % 17 + 1))
            if vector.dot(vector.cross(yV_4, yV_29), (vector.cross(yV_10, yV_32))) == vector.dot(yV_4, yV_10) * vector.dot(yV_29, yV_32) - vector.dot(yV_4, yV_32) * vector.dot(yV_29, yV_10) + 1 then
                yV_18 = "Unknown"
                pcall(fns.fn172)
                yV_15 = (nil):AddLeftGroupbox("Account", "circle-user")
                yV_15:AddLabel(yV_6("User", oS.Name, LocalPlayer), true)
                yV_15:AddLabel(yV_6("Status", "Keyless", LocalPlayer), true)
                yV_15:AddLabel(yV_6("Executor", "Unknown", LocalPlayer), true)
                oi = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
                oi:AddLabel(yV_13(nu .. " [" .. tostring(game.PlaceId) .. "]", o1), true)
                oi:AddLabel(yV_6("Place ID", tostring(game.PlaceId), o1), true)
                yV_20 = oi:AddLabel(yV_6("Session time", "0s", nO), true)
            else
                nO = "Unknown"
                pcall(fns.fn172)
                yV_13 = yV_6.Info:AddLeftGroupbox("Account", "circle-user")
                yV_13:AddLabel(oS("User", LocalPlayer.Name, yV_20), true)
                yV_13:AddLabel(oS("Status", "Keyless", yV_20), true)
                yV_13:AddLabel(oS("Executor", nO, yV_20), true)
                yV_15 = yV_6.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                yV_15:AddLabel(nu(yV_18 .. " [" .. tostring(game.PlaceId) .. "]", yV_31), true)
                yV_15:AddLabel(oS("Place ID", tostring(game.PlaceId), yV_31), true)
                o1 = yV_15:AddLabel(oS("Session time", "0s", oi), true)
            end
            yV_2 = (yV_2 + 11) % 24
        end
    else
        yV_4 = (vector.create((yV_2 * 6 + 8) % 11 + 1, (yV_2 * 5 + 5) % 13 + 1, (yV_2 * 15 + 2) % 17 + 1))
        yV_29 = (vector.create((yV_2 * 7 + 3) % 11 + 1, (yV_2 * 5 + 6) % 13 + 1, (yV_2 * 9 + 5) % 17 + 1))
        local z_ = vector.dot(yV_4, yV_29)
        if z_ * z_ >= vector.dot(yV_4, yV_4) * vector.dot(yV_29, yV_29) + 1 then
            o1 = tostring(game.JobId)
        else
            oU = tostring(game.JobId)
        end
        yV_2 = (yV_2 + 23) % 24
    end
until (yV_2 * 23 + 10) % 24 == 14
if yV_25 then
    yV_13 = 7
    repeat
        yV_2 = (vector.create((yV_13 * 5 + 7) % 11 + 1, (yV_13 * 3 + 12) % 13 + 1, (yV_13 * 2 + 14) % 17 + 1))
        local Aa = vector.floor(yV_2) + vector.ceil(yV_2 * -1)
        if vector.dot(Aa, Aa) == 0 then
            yV_25 = string.sub(oU, 1, 18) .. "..."
        else
            oU = string.sub(yV_25, 1, 18) .. "..."
        end
        yV_13 = (yV_13 + 7) % 8
    until (yV_13 * 3 + 5) % 8 == 7
end
yV_13 = yV_25
local pR = if yV_13 then 1 else 0
local pP = 1587 * pR + 2617 * (1 - pR)
local pQ = 1823 * pR + 2672 * (1 - pR)
if not ((pP * 3934 + pQ * 1227 + pP * pQ) % 16777213 == 11373180) then
    yV_13 = oU
end
om, yV_10, yV_29, yV_4, ShopGroup, MenuGroup, ow, ot, connection, connection2, n8 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local yV_1 = yV_13
yV_15:AddLabel(oS("Server", yV_1, yV_19), true)
yV_15:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
om = os.clock()
task.spawn(fns.worker)
local ScriptsGroup = yV_6.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(nu("Included in this hub", yV_19), true)
ScriptsGroup:AddLabel(nu(yV_18, yV_31), true)
yV_32 = yV_6.Info:AddRightGroupbox("Features", "list")
if ((yV_29 or not ShopGroup) and (not MenuGroup and not yV_4) or (MenuGroup or yV_29) and (yV_4 or n8) or (not MenuGroup or not ShopGroup) and (not n8 and not ShopGroup) and (not MenuGroup or not yV_4 or (not yV_4 or not yV_10)) or (not MenuGroup or not MenuGroup or MenuGroup and not yV_10) and (MenuGroup or yV_10 or ShopGroup and not yV_10) and ((yV_29 or MenuGroup) and (not MenuGroup or MenuGroup) or (n8 and not ShopGroup or MenuGroup and not yV_29))) and not ((yV_29 or not ShopGroup) and (not MenuGroup and not yV_4) or (MenuGroup or yV_29) and (yV_4 or n8) or (not MenuGroup or not ShopGroup) and (not n8 and not ShopGroup) and (not MenuGroup or not yV_4 or (not yV_4 or not yV_10)) or (not MenuGroup or not MenuGroup or MenuGroup and not yV_10) and (MenuGroup or yV_10 or ShopGroup and not yV_10) and ((yV_29 or MenuGroup) and (not MenuGroup or MenuGroup) or (n8 and not ShopGroup or MenuGroup and not yV_29))) then
    oi:AddLabel(yV_32("Auto Farm", nu), true)
    oi:AddLabel(yV_32("Auto Shop", yV_20), true)
    oi:AddLabel(yV_32("Auto Build", yV_10), true)
    oi:AddLabel(yV_32("Auto Craft", yV_19), true)
    yV_6 = (nil):AddRightGroupbox("Socials", "link")
else
    yV_32:AddLabel(nu("Auto Farm", yV_31), true)
    yV_32:AddLabel(nu("Auto Shop", oi), true)
    yV_32:AddLabel(nu("Auto Build", yV_19), true)
    yV_32:AddLabel(nu("Auto Craft", yV_20), true)
    yV_10 = yV_6.Info:AddRightGroupbox("Socials", "link")
end
yV_10:AddButton({ Text = "Discord", Func = nG })
yV_10:AddButton({ Text = "Rscripts", Func = onRscripts })
yV_29 = yV_6.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
yV_29:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
yV_29:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
yV_29:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
yV_29:AddButton({ Text = "Copy Discord Invite", Func = nG })
yV_4 = yV_6.Info:AddRightGroupbox("FAQ", "circle-help")
yV_4:AddLabel("Where do I get a good config?", true)
yV_4:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
yV_4:AddLabel("How do I import / export configs?", true)
yV_4:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
yV_4:AddLabel("How do I report bugs?", true)
yV_4:AddLabel("Join the Discord and post it in the bugs channel.", true)
yV_4:AddLabel("How do I make suggestions?", true)
yV_4:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
yV_4:AddLabel("How do I get help or updates?", true)
yV_4:AddLabel("Join the Discord, updates and support are posted there first.", true)
yV_25 = yV_6.Farm:AddLeftGroupbox("Farm", "sprout")
yV_25:AddToggle("AutoPlantSeeds", { Text = "Auto Plant Seeds", Default = false })
yV_25:AddDropdown("PlantSeedItems", { Text = "Seeds", Values = ns, Default = {}, Multi = true, Searchable = true, AllowNull = true })
yV_25:AddToggle("AutoHarvest", { Text = "Auto Harvest", Default = false })
yV_25:AddDropdown("HarvestSeedItems", {
    Text = "Harvest seeds",
    Values = ns,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true
})
yV_25:AddToggle("AutoStockFlowers", { Text = "Auto Stock Flowers", Default = false })
yV_25:AddDropdown("StockFlowerItems", { Text = "Flowers", Values = oL, Default = {}, Multi = true, Searchable = true, AllowNull = true })
yV_25:AddDivider("Bouquets")
yV_25:AddToggle("AutoCraftBouquets", { Text = "Auto Craft Bouquets", Default = false })
yV_25:AddDropdown("CraftBouquetItems", { Text = "Bouquets", Values = oq, Default = {}, Multi = true, Searchable = true, AllowNull = true })
yV_25:AddToggle("AutoPlaceBouquets", { Text = "Auto Place Bouquets", Default = false })
yV_25:AddDropdown("PlaceBouquetItems", {
    Text = "Place bouquets",
    Values = oq,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true
})
yV_2 = yV_6.Farm:AddRightGroupbox("Checkout", "banknote")
yV_2:AddToggle("AutoCheckout", { Text = "Auto Checkout", Default = false })
yV_2:AddSlider("FarmDelay", { Text = "Farm delay", Default = 0.35, Min = 0.1, Max = 5, Rounding = 2, Suffix = "s" })
ShopGroup = yV_6.Shop:AddLeftGroupbox("Shop", "shopping-bag")
ShopGroup:AddToggle("AutoBuySeeds", { Text = "Auto Buy Seeds", Default = false })
ShopGroup:AddDropdown("BuySeedItems", { Text = "Seeds", Values = ns, Default = {}, Multi = true, Searchable = true, AllowNull = true })
ShopGroup:AddToggle("AutoBuySupplies", { Text = "Auto Buy Supplies", Default = false })
ShopGroup:AddDropdown("BuySupplyItems", { Text = "Supplies", Values = o4, Default = {}, Multi = true, Searchable = true, AllowNull = true })
ShopGroup:AddToggle("AutoBuyDecorations", { Text = "Auto Buy Decorations", Default = false })
ShopGroup:AddDropdown("BuyDecorItems", {
    Text = "Decorations",
    Values = ou,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true
})
ShopGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
ShopGroup:AddDropdown("BuyUpgradeItems", {
    Text = "Upgrades",
    Values = yV_8,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true
})
local StaffGroup = yV_6.Shop:AddRightGroupbox("Staff", "users")
StaffGroup:AddToggle("AutoHireStaff", { Text = "Auto Hire Staff", Default = false })
StaffGroup:AddDropdown("HireStaffItems", { Text = "Roles", Values = ol, Default = {}, Multi = true, Searchable = true, AllowNull = true })
StaffGroup:AddSlider("ShopDelay", { Text = "Shop delay", Default = 0.5, Min = 0.1, Max = 5, Rounding = 2, Suffix = "s" })
local BuyGroup = yV_6.Build:AddLeftGroupbox("Buy", "package-plus")
BuyGroup:AddToggle("AutoBuyPlanters", { Text = "Auto Buy Planters", Default = false })
BuyGroup:AddDropdown("BuyPlanterItems", { Text = "Planters", Values = oG, Default = {}, Multi = true, Searchable = true, AllowNull = true })
BuyGroup:AddDropdown("BuyPlanterRotation", {
    Text = "Planter rotation",
    Values = yV_30,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true
})
BuyGroup:AddSlider("BuyPlanterSpacing", { Text = "Planter spacing", Default = 4, Min = 2, Max = 16, Rounding = 0 })
BuyGroup:AddToggle("AutoBuyDisplays", { Text = "Auto Buy Displays", Default = false })
BuyGroup:AddDropdown("BuyDisplayItems", { Text = "Displays", Values = oB, Default = {}, Multi = true, Searchable = true, AllowNull = true })
BuyGroup:AddDropdown("BuyDisplayRotation", {
    Text = "Display rotation",
    Values = yV_30,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true
})
BuyGroup:AddSlider("BuyDisplaySpacing", { Text = "Display spacing", Default = 4, Min = 2, Max = 16, Rounding = 0 })
local PlaceGroup = yV_6.Build:AddRightGroupbox("Place", "move")
PlaceGroup:AddToggle("AutoPlacePlanters", { Text = "Auto Place Planters", Default = false })
PlaceGroup:AddDropdown("PlacePlanterItems", { Text = "Planters", Values = oG, Default = {}, Multi = true, Searchable = true, AllowNull = true })
PlaceGroup:AddDropdown("PlacePlanterRotation", {
    Text = "Planter rotation",
    Values = yV_30,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true
})
PlaceGroup:AddSlider("PlacePlanterSpacing", { Text = "Planter spacing", Default = 4, Min = 2, Max = 16, Rounding = 0 })
PlaceGroup:AddToggle("AutoPlaceDisplays", { Text = "Auto Place Displays", Default = false })
PlaceGroup:AddDropdown("PlaceDisplayItems", { Text = "Displays", Values = oB, Default = {}, Multi = true, Searchable = true, AllowNull = true })
PlaceGroup:AddDropdown("PlaceDisplayRotation", {
    Text = "Display rotation",
    Values = yV_30,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true
})
PlaceGroup:AddSlider("PlaceDisplaySpacing", { Text = "Display spacing", Default = 4, Min = 2, Max = 16, Rounding = 0 })
PlaceGroup:AddSlider("BuildDelay", { Text = "Build delay", Default = 0.45, Min = 0.1, Max = 5, Rounding = 2, Suffix = "s" })
MenuGroup = yV_6.Settings:AddLeftGroupbox("Menu", "settings")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", fns.onUnload)
Library:OnUnload(fns.fn274)
yV_17:SetLibrary(Library)
yV_17:SetFolder("TempoHub")
yV_17:SaveDefault("Monochrome")
yV_17:ApplyToTab(yV_6.Settings)
yV_17:LoadDefault()
yV_27:SetLibrary(Library)
yV_27:IgnoreThemeSettings()
yV_27:SetIgnoreIndexes({ "MenuKeybind" })
yV_27:SetFolder("TempoHub/MyFlowerShop")
yV_27:BuildConfigSection(yV_6.Settings)
yV_27:LoadAutoloadConfig()
ow = tick()
ot = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local yA = v
        pcall(function()
            yA:Disable()
        end)
    end
end)
n8 = fn882
connection = UserInputService.InputBegan:Connect(fns.onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
Library:OnUnload(fn702)
task.spawn(fns.worker2)
task.spawn(fns.worker3)
task.spawn(worker4)
task.spawn(worker5)
Library:Notify("My Flower Shop loaded")
end)(...)

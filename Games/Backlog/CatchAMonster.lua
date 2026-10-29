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
getgenv().TempoHoodSubtitle = "CATCH A MONSTER"
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
local gY
local g0
local hm
local hp
local hs
local g6
local g9
local Recover
local gR
local connection
local hf
local gX
local hi
local g_
local VirtualUser
local ho
local g2
local hr
local gQ
local hb
local gT
local gW
local g4
local RunService
local g7
local ht
local Options
local hd
local gS
local gV
local hg
local UserInputService
local function fn12(aN)
    return g2 == nil or g2[aN.TmplId] == true
end
local function fn45()
    for i, v in ipairs(gR) do
        pcall(v)
    end
end
local function fn133()
    if gT.AutoClaimAchieve.Value then
        pcall(gW)
    end
end
local function onInputBegan()
    hg = tick()
end
local function fn149()
    local jN = gT.AutoHeal.Value and Recover and hm()
    if jN then
        local jN_1 = hr()
        if jN_1 then
            local CFrame = jN_1.CFrame
            jN_1.CFrame = Recover.CFrame + Vector3.new(0, 4, 0)
            local jN_2 = 0
            while true do
                local jP_1 = hm() and jN_2 < 6 and gT.AutoHeal.Value and not g0.Unloaded
                if jP_1 then
                    task.wait(0.3)
                    jN_2 = jN_2 + 0.3
                    continue
                end
                break
            end
            local jP_2 = hr()
            if jP_2 then
                jP_2.CFrame = CFrame
            end
        end
    end
end
local function fn153()
    if not gT.AutoFarm.Value then
        task.wait(0.25)
        return
    end
    task.wait(Options.FarmDelay.Value)
    local iS = ho(Options.FarmRange.Value)
    if #iS == 0 then
        return
    end
    if Options.FarmMode.Value == "All In Range" then
        for k, v in iS do
            gY(v.info.MonsterId)
        end
    else
        local iT = iS[1]
        for k, v in iS do
            if v.dist < iT.dist then
                iT = v
            end
        end
        if gT.FarmTeleport.Value then
            local iS_1 = hr()
            if iS_1 and iT.info.CurrentCFrame then
                iS_1.CFrame = CFrame.new(iT.info.CurrentCFrame.Position + Vector3.new(0, Options.FarmHover.Value, 0))
            end
        end
        gY(iT.info.MonsterId)
    end
end
local function onRefreshPetList()
    Options.FeedTarget:SetValues(g_())
end
local function fn193()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    local kC = g9()
    if kC then
        kC.PlatformStand = false
    end
end
local function onStepped()
    if gT.NoClip.Value then
        local kt = gS()
        if kt then
            for i, descendant in ipairs(kt:GetDescendants()) do
                local kt_1 = descendant:IsA("BasePart") and descendant.CanCollide
                if kt_1 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function onUnload()
    g0:Unload()
end
local function fn280()
    return ht.ClientPlayerManager.GetGamePlayer()
end
local function fn283()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    hb = tick()
end
local function fn287()
    setclipboard(g4)
    g0:Notify("Copied Discord invite to clipboard")
end
local function fn349()
    local ie = gS()
    local ig = ie and ie:FindFirstChild("HumanoidRootPart")
    return ig
end
local function fn376()
    Recover = workspace.Area.Root.ServerZone:FindFirstChild("Recover")
end
local function fn402()
    gQ()
    local kO = hr()
    local kP = g9()
    if not kO or not kP then
        return
    end
    kP.PlatformStand = true
    connection = RunService.RenderStepped:Connect(function()
        if not gT.Fly.Value then
            return
        end
        local kE = hr()
        local kF = g9()
        if not kE or not kF or not workspace.CurrentCamera then
            return
        end
        kF.PlatformStand = true
        local Value = Options.FlySpeed.Value
        local kH_2 = Vector3.zero
        if kF.MoveDirection.Magnitude > 0 then
            kH_2 = kF.MoveDirection
        end
        local kF_1 = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            kF_1 = 1
        else
            local kN = if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then 1 else 0
            if kN == 1 then
                kF_1 = -1
            end
        end
        kE.AssemblyLinearVelocity = kH_2 * Value + Vector3.new(0, kF_1 * Value, 0)
    end)
end
local function fn444()
    return hd.Character
end
local function fn465()
    if gT.AntiAfk.Value then
        local lv = tick() - hg
        local lw = tick() - hb
        if lv >= 300 and lw >= 60 then
            pcall(gX)
        else
            if lv < 300 and lw >= 300 then
                pcall(gX)
            end
        end
    end
end
local function fn466(cH)
    local j3 = gV
    local j4 = {}
    if j3 then
        j3 = gV.Tmpls
    end
    if j3 then
        for k in pairs(gV.Tmpls) do
            local j3_1 = cH.pet:GetExpItemCount(k)
            if j3_1 and j3_1 > 0 then
                j4[#j4 + 1] = { TmplId = k, Count = j3_1 }
            end
        end
    end
    return j4
end
local function fn525()
    if gT.WalkSpeedEnabled.Value then
        local kj = g9()
        if kj then
            kj.WalkSpeed = Options.WalkSpeed.Value
        end
    end
end
local function onJumpRequest()
    if gT.InfJump.Value then
        local ko = g9()
        if ko then
            ko:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function onInputChanged(ew)
    local UserInputType = ew.UserInputType
    local lq = UserInputType == Enum.UserInputType.MouseMovement
    local lu = if lq then 1 else 0
    local ls = 1952 * lu + 2975 * (1 - lu)
    local lt = 1206 * lu + 2528 * (1 - lu)
    if not ((ls * 2418 + lt * 1053 + ls * lt) % 16777213 == 8343966) then
        lq = UserInputType == Enum.UserInputType.Gamepad1
    end
    if lq then
        hg = tick()
    end
end
local function fn568()
    if gT.AutoEquipBest.Value then
        pcall(function()
            local jC = hf.CheckCanEquipBest == nil or hf.CheckCanEquipBest(hp())
            if jC then
                hf.ClientEquipBest()
            end
        end)
    end
end
local function fn571()
    local iu = false
    local iv = {}
    for k, v in pairs(Options.FarmEnemies.Value) do
        if v then
            iu = true
            local iw_1 = hs[k]
            if iw_1 then
                for k in pairs(iw_1) do
                    iv[k] = true
                end
            end
        end
    end
    g2 = iu and iv or nil
end
local function fn599()
    local iq_1
    local ip_1
    if identifyexecutor then
        iq_1, ip_1 = identifyexecutor()
        local ir = iq_1 ~= ""
        local is = type(iq_1) == "string" and ir
        if is then
            local ir_1 = type(ip_1) == "string" and ip_1 ~= "" and iq_1 .. " " .. ip_1
            g7 = ir_1 or iq_1
        end
    end
end
local function fn608(A)
    gR[#gR + 1] = A
end
local function fn617()
    if gT.Fly.Value then
        hi()
    else
        gQ()
    end
end
local function fn676()
    local il = gS()
    local im = il and il:FindFirstChildOfClass("Humanoid")
    return im
end
local function fn682()
    if not gT.MonsterESP.Value then
        g6()
    end
end
Recover = nil
Options = nil
gQ = nil
gR = nil
gS = nil
gT = nil
connection = nil
gV = nil
gW = nil
gX = nil
gY = nil
g_ = nil
g0 = nil
g2 = nil
g4 = nil
g6 = nil
g7 = nil
g9 = nil
hb = nil
hd = nil
hf = nil
hg = nil
hi = nil
UserInputService = nil
VirtualUser = nil
hm = nil
ho = nil
hp = nil
RunService = nil
hr = nil
hs = nil
ht = nil
local gM, gN, gZ, g1, g3, g5, g8, ha, hc, he, hh, hk, MonsterSystem, hu
local hy_1
local hv_1
local hG_1
local hF_1
local hE_1
local hD_1
local hC_1
local CfgMonster
local hz_1
local hA_1
RunService, VirtualUser, UserInputService, hd = nil, nil, nil, nil
local Players = game:GetService("Players")
RunService = game:GetService("RunService")
VirtualUser = game:GetService("VirtualUser")
UserInputService = game:GetService("UserInputService")
hd = Players.LocalPlayer
while not hd do
    task.wait()
    hd = Players.LocalPlayer
end
hA_1, g4, hv_1, g0, hG_1, hF_1, gT, Options, ht, MonsterSystem, hk, hf, ha, g5, g3, CfgMonster, gZ, hC_1, gV, gR, hy_1, gN, hE_1, hD_1, hp, hh, gS, hr, g9, hz_1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local hx = 32
repeat
    local hw_1 = (hx * 1 + 0) % 13 + 1
    if hw_1 <= 7 then
        if hw_1 <= 4 then
            if hw_1 <= 2 then
                if hw_1 <= 1 then
                    local hH_1 = { "oxahwjnpb", "cavtqicni", "pjoqwfzu", "lhbkjt", "amjw", "pornem", "tljjk", "mjgo", "mati" }
                    local mf = hx
                    local hI_1 = hH_1[mf % 9 + 1]
                    if hI_1:len() <= hI_1:reverse():rep(mf % 3 + 2):len() then
                        MonsterSystem = ht.MonsterSystem
                        hk = ht.MgrMonsterClient
                        hf = ht.PetSystem
                        ha = ht.AchieveSystem
                        g5 = ht.AchieveUtil
                    else
                        hf = MonsterSystem.MonsterSystem
                        g5 = MonsterSystem.MgrMonsterClient
                        ha = MonsterSystem.PetSystem
                        ht = MonsterSystem.AchieveSystem
                        hk = MonsterSystem.AchieveUtil
                    end
                    hx = (hx + 40) % 104
                else
                    local hH_2 = (vector.create((hx * 7 + 7) % 11 + 1, (hx * 4 + 7) % 13 + 1, (hx * 8 + 13) % 17 + 1))
                    local hI_2 = (vector.create((hx * 7 + 4) % 11 + 1, (hx * 10 + 3) % 13 + 1, (hx * 11 + 2) % 17 + 1))
                    local hJ_1 = (vector.create((hx * 1 + 5) % 5 + 1, (hx * 5 + 1) % 7 + 1, (hx * 3 + 7) % 9 + 1))
                    if math.abs((vector.angle(hH_2, hI_2, hJ_1))) - math.abs((vector.angle(hI_2, hH_2, hJ_1))) == 3 then
                        ht = CfgMonster.AreaSystem
                        gV = CfgMonster.CfgMonster
                        g3 = CfgMonster.CfgAchieve
                        gZ = CfgMonster.CfgAreaRegion
                        hC_1 = CfgMonster.CfgPetExpItem
                    else
                        g3 = ht.AreaSystem
                        CfgMonster = ht.CfgMonster
                        gZ = ht.CfgAchieve
                        hC_1 = ht.CfgAreaRegion
                        gV = ht.CfgPetExpItem
                    end
                    hx = (hx + 1) % 104
                end
            elseif hw_1 <= 3 then
                local mx = bit32.rrotate(bit32.bxor(bit32.lrotate(hx, 28), string.byte(tostring(g0))), 11)
                if bit32.bxor(bit32.lrotate(bit32.bxor(mx, 191366692), 14), 25756378) ~= bit32.lrotate(mx, 14) then
                    hp = {}
                    hE_1 = fn608
                    gR = function(D)
                        gN(function()
                            D:Disconnect()
                        end)
                        return D
                    end
                    gN = function(H, I)
                        task.spawn(function()
                            while not g0.Unloaded do
                                task.wait(H)
                                I()
                            end
                        end)
                    end
                    hD_1 = fn280
                else
                    gR = {}
                    gN = fn608
                    hE_1 = function(D)
                        gN(function()
                            D:Disconnect()
                        end)
                        return D
                    end
                    hD_1 = function(H, I)
                        task.spawn(function()
                            while not g0.Unloaded do
                                task.wait(H)
                                I()
                            end
                        end)
                    end
                    hp = fn280
                end
                hx = (hx + 40) % 104
            else
                local hH_3 = { "hqnt", "cqzfxzpt", "aijp", "dzlritshlrc", "ttkvio", "dkmbhync", "hauelgzi", "wpsobe" }
                local l3 = hx
                local hI_3 = hH_3[l3 % 8 + 1]
                if hI_3:len() <= hI_3:reverse():rep(l3 % 3 + 2):len() then
                    hh = function(Q)
                        local h9_2
                        local h8_3
                        h8_3, h9_2 = pcall(function()
                            return ht.Localizer.Translate(Q)
                        end)
                        local ia = h8_3 and type(h9_2) == "string"
                        if ia and h9_2 ~= "" then
                            return h9_2
                        end
                        return tostring(Q)
                    end
                    gS = fn444
                    hr = fn349
                    g9 = fn676
                else
                    gS = function(Q)
                        local h9_1
                        local h8_1
                        h8_1, h9_1 = pcall(function()
                            return ht.Localizer.Translate(Q)
                        end)
                        local ia = h8_1 and type(h9_1) == "string"
                        if ia and h9_1 ~= "" then
                            return h9_1
                        end
                        return tostring(Q)
                    end
                    g9 = fn444
                    hh = fn349
                    hr = fn676
                end
                hx = (hx + 53) % 104
            end
        elseif hw_1 <= 6 then
            if hw_1 <= 5 then
                local hH_4 = (vector.create((hx * 7 + 2) % 11 + 1, (hx * 8 + 9) % 13 + 1, (hx * 7 + 7) % 17 + 1))
                local hI_4 = (vector.create((hx * 3 + 6) % 11 + 1, (hx * 11 + 6) % 13 + 1, (hx * 15 + 9) % 17 + 1))
                local mm = vector.cross(hH_4, hI_4)
                local mn = vector.dot(hH_4, hI_4)
                if vector.dot(mm, mm) + mn * mn == vector.dot(hH_4, hH_4) * vector.dot(hI_4, hI_4) then
                    hz_1 = fn287
                    hy_1 = g0:CreateWindow({
                        Title = "Tempo Hub",
                        Footer = g4 .. " | " .. hA_1,
                        Icon = 18657887261,
                        NotifySide = "Right",
                        ShowCustomCursor = false
                    })
                else
                    g0 = fn287
                    g4 = hA_1:CreateWindow({
                        ShowCustomCursor = false,
                        NotifySide = "Right",
                        Icon = 18657887261,
                        Title = "Tempo Hub",
                        Footer = hy_1 .. " | " .. hz_1
                    })
                end
                hx = (hx + 1) % 104
            else
                hx = (hx + 27) % 104
            end
        else
            local hH_5 = (vector.create((hx * 6 + 7) % 11 + 1, (hx * 3 + 2) % 13 + 1, (hx * 2 + 13) % 17 + 1))
            local hI_5 = (vector.create((hx * 4 + 1) % 11 + 1, (hx * 7 + 10) % 13 + 1, (hx * 10 + 17) % 17 + 1))
            local hJ_2 = (vector.create((hx * 3 + 6) % 5 + 1, (hx * 1 + 3) % 7 + 1, (hx * 5 + 5) % 9 + 1))
            if math.abs((vector.angle(hH_5, hI_5, hJ_2))) - math.abs((vector.angle(hI_5, hH_5, hJ_2))) == 5 then
                ht = "Catch a Monster"
            else
                hA_1 = "Catch a Monster"
            end
            hx = (hx + 66) % 104
        end
    elseif hw_1 <= 10 then
        if hw_1 <= 9 then
            if hw_1 <= 8 then
                if (hx * 3 + 7) * 5 % 4 == ((hx * 3 + 7) * 5 + 0) % 4 then
                    g4 = "https://discord.gg/K7Qxnxkk46"
                else
                    g0 = "https://discord.gg/K7Qxnxkk46"
                end
                hx = (hx + 53) % 104
            else
                if (hx * 2 + 4) * 16 % 3 == ((hx * 2 + 4) * 16 + 1) % 3 then
                    g0 = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
                else
                    hv_1 = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
                end
                hx = (hx + 1) % 104
            end
        else
            local hH_6 = {
                "nofmugp",
                "zxppzo",
                "yiknm",
                "jjeynqojwxno",
                "xkvcq",
                "xhqemfieqlcs",
                "ngbvxbwcoyb",
                "bizsmbou",
                "ftjisbteodkn",
                "lsfeqigoge",
                "ryrmnom"
            }
            if hH_6[(hx * 35 + 17) % 11 + 1] <= hH_6[(hx * 35 + 17) % 11 + 1] then
                g0 = getgenv().Library
            else
                hv_1 = getgenv().Library
            end
            hx = (hx + 14) % 104
        end
    elseif hw_1 <= 12 then
        if hw_1 <= 11 then
            if (hx * 2 + 4) * 13 % 3 == ((hx * 2 + 4) * 13 + 1) % 3 then
                hv_1 = getgenv().ThemeManager
                hG_1 = getgenv().SaveManager
            else
                hG_1 = getgenv().ThemeManager
                hF_1 = getgenv().SaveManager
            end
            hx = (hx + 53) % 104
        else
            if (hx * 2 + 8) * 4 % 3 == ((hx * 2 + 8) * 4 + 7) % 3 then
                g0 = Options.Toggles
                gT = Options.Options
            else
                gT = g0.Toggles
                Options = g0.Options
            end
            hx = (hx + 79) % 104
        end
    else
        local hw_2 = (vector.create((hx * 4 + 1) % 11 + 1, (hx * 2 + 6) % 13 + 1, (hx * 10 + 12) % 17 + 1))
        local mj = vector.floor(hw_2) + vector.ceil(hw_2 * -1)
        if vector.dot(mj, mj) == 4 then
            gN = getrenv()._G.PathTool
        else
            ht = getrenv()._G.PathTool
        end
        hx = (hx + 14) % 104
    end
until (hx * 61 + 84) % 104 == 86
if g0.ScreenGui then
    local hv_2 = 1
    repeat
        local hw_3 = {
            "lagswqmzqpb",
            "bvjpnkjdf",
            "mwqqvvo",
            "krkhljthsbz",
            "ocojt",
            "mtdtjvufa",
            "pvqz",
            "llnfixpydh",
            "yetifzczrv",
            "ecgkugrth"
        }
        local mu = hv_2
        local hx_1 = hw_3[mu % 10 + 1]
        if hx_1:len() <= hx_1:gsub("(.)", "%1%1", mu % 3 % 2 + 1):len() then
            g0.ScreenGui.Parent = hd:WaitForChild("PlayerGui")
        else
            hd.ScreenGui.Parent = g0:WaitForChild("PlayerGui")
        end
        hv_2 = (hv_2 + 6) % 8
    until (hv_2 * 5 + 0) % 8 == 3
end
local hx_2 = nil
local hw_4 = 3
repeat
    if (((hx_2 or hx_2) and (not hx_2 or hw_4) or (hx_2 or hw_4) and (hx_2 or hx_2)) and ((not hx_2 or not hw_4 or not hw_4 and not hw_4) and (not hw_4 and hw_4 or (hw_4 or not hw_4))) or (hw_4 and not hx_2 or hw_4 and not hx_2) and ((not hw_4 or not hw_4) and (not hw_4 and hx_2)) and ((not hx_2 and not hw_4 or (not hw_4 or not hw_4)) and ((hw_4 or hx_2) and (hw_4 and not hx_2)))) and not (((hx_2 or hx_2) and (not hx_2 or hw_4) or (hx_2 or hw_4) and (hx_2 or hx_2)) and ((not hx_2 or not hw_4 or not hw_4 and not hw_4) and (not hw_4 and hw_4 or (hw_4 or not hw_4))) or (hw_4 and not hx_2 or hw_4 and not hx_2) and ((not hw_4 or not hw_4) and (not hw_4 and hx_2)) and ((not hx_2 and not hw_4 or (not hw_4 or not hw_4)) and ((hw_4 or hx_2) and (hw_4 and not hx_2)))) then
        hy_1 = {
            Info = hx_2:AddTab("Info", "info"),
            Main = hx_2:AddTab("Main", "swords"),
            Settings = hx_2:AddTab("Settings", "settings"),
            Player = hx_2:AddTab("Player", "user"),
            Pets = hx_2:AddTab("Pets", "paw-print"),
            Teleport = hx_2:AddTab("Teleport", "map-pin")
        }
    else
        hx_2 = {
            Info = hy_1:AddTab("Info", "info"),
            Main = hy_1:AddTab("Main", "swords"),
            Pets = hy_1:AddTab("Pets", "paw-print"),
            Player = hy_1:AddTab("Player", "user"),
            Teleport = hy_1:AddTab("Teleport", "map-pin"),
            Settings = hy_1:AddTab("Settings", "settings")
        }
    end
    hw_4 = (hw_4 + 0) % 8
until (hw_4 * 5 + 5) % 8 == 4
for k, v in hx_2 do
    local DiscordGroup = v:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = hz_1 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = hz_1 })
end
g7 = nil
local BasicInfoGroup = hx_2.Info:AddLeftGroupbox("Basic Info", "circle-user")
g7 = "Unknown"
pcall(fn599)
BasicInfoGroup:AddLabel("Executor: " .. g7, true)
BasicInfoGroup:AddLabel("Game: " .. hA_1, true)
BasicInfoGroup:AddLabel("Player: " .. hd.Name, true)
BasicInfoGroup:AddLabel("Status: Keyless", true)
local TempoHubGroup = hx_2.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = hz_1 })
local FaqGroup = hx_2.Info:AddRightGroupbox("FAQ", "circle-help")
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
hs = nil
local hK = {}
hs = {}
if CfgMonster and CfgMonster.Tmpls then
    for k, v in pairs(CfgMonster.Tmpls) do
        local hv_5 = hh(v.Name)
        if not hs[hv_5] then
            hs[hv_5] = {}
            hK[#hK + 1] = hv_5
        end
        hs[hv_5][k] = true
    end
end
g2, g8, gY, ho = nil, nil, nil, nil
table.sort(hK)
local AutoFarmGroup = hx_2.Main:AddLeftGroupbox("Auto Farm", "swords")
AutoFarmGroup:AddToggle("AutoFarm", { Text = "Auto Farm", Default = false })
AutoFarmGroup:AddDropdown("FarmEnemies", {
    Values = hK,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Text = "Selected Enemies"
})
AutoFarmGroup:AddDropdown("FarmMode", {
    Values = { "Nearest", "All In Range" },
    Default = "Nearest",
    Multi = false,
    Searchable = true,
    AllowNull = true,
    Text = "Target Mode"
})
AutoFarmGroup:AddSlider("FarmRange", { Text = "Max Distance", Default = 150, Min = 20, Max = 1000, Rounding = 0, Suffix = " studs" })
AutoFarmGroup:AddSlider("FarmDelay", { Text = "Attack Delay", Default = 0.3, Min = 0.1, Max = 2, Rounding = 2, Suffix = "s" })
AutoFarmGroup:AddToggle("FarmTeleport", { Text = "Teleport To Target", Default = false })
AutoFarmGroup:AddSlider("FarmHover", { Text = "Teleport Hover Height", Default = 12, Min = 0, Max = 40, Rounding = 0, Suffix = " studs" })
g2 = nil
Options.FarmEnemies:OnChanged(fn571)
fn571()
g8 = fn12
gY = function(aQ)
    pcall(function()
        MonsterSystem.ClientAttackMonster(aQ)
    end)
end
ho = function(aV)
    local iP, iQ
    iP = hr()
    if not iP then
        return {}
    end
    iQ = {}
    hk.IterMonster(function(a_)
        local iK = a_.IsAlive and a_:IsAlive() and a_.CurrentCFrame and g8(a_)
        if iK then
            local Magnitude = (a_.CurrentCFrame.Position - iP.Position).Magnitude
            if Magnitude <= aV then
                iQ[#iQ + 1] = { info = a_, dist = Magnitude }
            end
        end
    end)
    return iQ
end
hD_1(0.05, fn153)
hc = nil
local AutoCatchGroup = hx_2.Main:AddRightGroupbox("Auto Catch", "hand")
AutoCatchGroup:AddToggle("AutoCatch", { Text = "Auto Catch", Default = false })
AutoCatchGroup:AddSlider("CatchDelay", { Text = "Catch Delay", Default = 0.4, Min = 0.1, Max = 2, Rounding = 2, Suffix = "s" })
AutoCatchGroup:AddToggle("CatchTeleport", { Text = "Teleport To Catchable", Default = false })
hc = function(bm)
    pcall(function()
        MonsterSystem.ClientCatchMonsterStart(bm)
    end)
end
hD_1(0.05, function()
    local i7
    i7 = nil
    if not gT.AutoCatch.Value then
        task.wait(0.25)
        return
    end
    task.wait(Options.CatchDelay.Value)
    i7 = {}
    hk.IterSelfCanCatchBattleMonster(function(bu)
        i7[#i7 + 1] = bu
    end)
    for k, v in i7 do
        if gT.CatchTeleport.Value then
            local i8 = hr()
            if i8 and v.CurrentCFrame then
                i8.CFrame = CFrame.new(v.CurrentCFrame.Position + Vector3.new(0, 6, 0))
            end
        end
        hc(v.MonsterId)
    end
end)
gW = nil
local AutoClaimGroup = hx_2.Main:AddRightGroupbox("Auto Claim", "trophy")
AutoClaimGroup:AddToggle("AutoClaimAchieve", { Text = "Auto Claim Achievements", Default = false })
gW = function()
    local jh = hp()
    if not jh then
        return
    end
    for k, v in pairs(gZ.Tmpls) do
        local jq = v
        local ji_1 = not jh.achieve:IsRewardTaken(jq.TmplId) and g5.GetDataCount(jh, jq.DataId) >= jq.Count
        if ji_1 then
            pcall(function()
                ha.ClientTakeAchieveReward(jq.GroupId, jq.TmplId)
            end)
        end
    end
    for k in pairs(gZ.Groups) do
        local ju = k
        if not jh.achieve:IsGroupRewardTaken(ju) then
            local ji_2 = true
            for k, v in pairs(gZ.Tmpls) do
                local jj = v.GroupId == ju and not jh.achieve:IsRewardTaken(v.TmplId) and g5.GetDataCount(jh, v.DataId) < v.Count
                if jj then
                    ji_2 = false
                    break
                end
            end
            if ji_2 then
                pcall(function()
                    ha.ClientTakeAchieveReward(ju, 0)
                end)
            end
        end
    end
end
hD_1(3, fn133)
Recover, g1, hm, g_, hu = nil, nil, nil, nil, nil
local AutomationGroup = hx_2.Pets:AddLeftGroupbox("Automation", "sparkles")
local FeedingGroup = hx_2.Pets:AddRightGroupbox("Feeding", "bone")
AutomationGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false })
AutomationGroup:AddToggle("AutoHeal", { Text = "Auto Heal Pets", Default = false })
hD_1(2, fn568)
Recover = nil
pcall(fn376)
hm = function()
    local jK
    jK = nil
    local jL = hp()
    if not jL then
        return false
    end
    jK = false
    jL.pet:IterEquipedItem(function(ca)
        local jI = ca.IsDead and ca:IsDead()
        if jI then
            jK = true
            return false
        end
    end)
    return jK
end
hD_1(1, fn149)
g1 = {}
g_ = function()
    g1 = {}
    local j0 = {}
    local j1 = hp()
    if j1 then
        j1.pet:IterEquipedItem(function(cu)
            local jV_1
            local jU_1
            jU_1, jV_1 = pcall(function()
                return hh(cu:GetTmpl().Name)
            end)
            local jU_2 = jU_1 and jV_1 or "Pet"
            local jV_2 = jU_2 .. " #" .. tostring(cu:GetId())
            g1[jV_2] = cu:GetId()
            j0[#j0 + 1] = jV_2
        end)
    end
    return j0
end
FeedingGroup:AddDropdown("FeedTarget", {
    Values = g_(),
    Default = nil,
    Multi = false,
    Searchable = true,
    AllowNull = true,
    Text = "Feed Target Pet"
})
FeedingGroup:AddButton({ Text = "Refresh Pet List", Func = onRefreshPetList })
FeedingGroup:AddToggle("AutoFeed", { Text = "Auto Feed (Exp Items)", Default = false })
hu = fn466
hD_1(3, function()
    if not gT.AutoFeed.Value then
        return
    end
    local Value = Options.FeedTarget.Value
    local kb = Value and g1[Value]
    if not kb then
        return
    end
    local kd_1 = hp()
    if not kd_1 then
        return
    end
    local kc = hu(kd_1)
    if #kc > 0 then
        pcall(function()
            hf.ClientFeed(kb, {}, kc)
        end)
    end
end)
connection, gQ, hi = nil, nil, nil
local MovementGroup = hx_2.Player:AddLeftGroupbox("Movement", "move")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "Walk Speed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "Walk Speed Amount", Default = 16, Min = 16, Max = 300, Rounding = 0 })
hD_1(0.2, fn525)
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
hE_1(UserInputService.JumpRequest:Connect(onJumpRequest))
MovementGroup:AddToggle("NoClip", { Text = "No Clip", Default = false })
hE_1(RunService.Stepped:Connect(onStepped))
MovementGroup:AddToggle("Fly", { Text = "Fly", Default = false })
MovementGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 300, Rounding = 0 })
gQ = fn193
hi = fn402
gT.Fly:OnChanged(fn617)
gN(gQ)
he, g6 = nil, nil
local VisualsGroup = hx_2.Player:AddRightGroupbox("Visuals", "eye")
VisualsGroup:AddToggle("MonsterESP", { Text = "Monster ESP", Default = false })
he = {}
g6 = function()
    for k, v in pairs(he) do
        local k_ = v
        pcall(function()
            k_:Destroy()
        end)
        he[k] = nil
    end
end
gT.MonsterESP:OnChanged(fn682)
gN(g6)
hD_1(0.5, function()
    local k4
    if not gT.MonsterESP.Value then
        return
    end
    k4 = {}
    hk.IterMonster(function(dW)
        local k1 = dW.Model and dW:IsAlive()
        if k1 then
            k4[dW.MonsterId] = true
            local k1_1 = he[dW.MonsterId]
            if not k1_1 or k1_1.Parent == nil then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(255, 80, 80)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Adornee = dW.Model
                highlight.Parent = dW.Model
                he[dW.MonsterId] = highlight
            end
        end
    end)
    for k, v in pairs(he) do
        local lb = v
        if not k4[k] then
            pcall(function()
                lb:Destroy()
            end)
            he[k] = nil
        end
    end
end)
gM = nil
gM = {}
local hA_4 = {}
if hC_1 and hC_1.Tmpls then
    for k, v in pairs(hC_1.Tmpls) do
        local hv_7 = hh(v.Name)
        if gM[hv_7] then
            hv_7 = hv_7 .. " (" .. tostring(k) .. ")"
        end
        gM[hv_7] = k
        hA_4[#hA_4 + 1] = hv_7
    end
end
table.sort(hA_4)
local TeleportGroup = hx_2.Teleport:AddLeftGroupbox("Teleport", "map-pin")
TeleportGroup:AddDropdown("TeleportRegion", {
    Values = hA_4,
    Default = hA_4[1],
    Multi = false,
    Searchable = true,
    AllowNull = true,
    Text = "Destination"
})
TeleportGroup:AddButton({
    Text = "Teleport",
    Func = function()
        local Value = Options.TeleportRegion.Value
        local lc = Value and gM[Value]
        if lc then
            pcall(function()
                g3.ClientTeleportToAreaRegion(lc)
            end)
        end
    end
})
local MenuGroup = nil
local hv_8 = 0
repeat
    local hw_9 = { "bka", "ekuqk", "ixq", "smoksmg", "ryfpyhxkcx", "hhskdffo", "jchq", "ufogzdz", "ztn" }
    if hw_9[(hv_8 * 92 + 42) % 9 + 1] < hw_9[(hv_8 * 92 + 42) % 9 + 1] then
        hx_2 = MenuGroup.Settings:AddLeftGroupbox("Menu", "settings")
    else
        MenuGroup = hx_2.Settings:AddLeftGroupbox("Menu", "settings")
    end
    hv_8 = (hv_8 + 3) % 4
until (hv_8 * 3 + 2) % 4 == 3
hg, hb, gX = nil, nil, nil
local hw_10 = 0
repeat
    if (hw_10 * 1 + 0) % 2 + 1 <= 1 then
        if (hw_10 * 3 + 8) * 5 % 4 == ((hw_10 * 3 + 8) * 5 + 14) % 4 then
            gX = tick()
            hg = tick()
            pcall(function()
                for i, v in ipairs(getconnections(hd.Idled)) do
                    local lm = v
                    pcall(function()
                        lm:Disable()
                    end)
                end
            end)
            hb = fn283
        else
            hg = tick()
            hb = tick()
            pcall(function()
                for i, v in ipairs(getconnections(hd.Idled)) do
                    local lm = v
                    pcall(function()
                        lm:Disable()
                    end)
                end
            end)
            gX = fn283
        end
        hw_10 = (hw_10 + 1) % 8
    else
        if hw_10 * 122176651 + 10 + 7 <= hw_10 * 122176651 + 10 + 7 + 1 then
            hE_1(UserInputService.InputBegan:Connect(onInputBegan))
            hE_1(UserInputService.InputChanged:Connect(onInputChanged))
            MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
            hD_1(2, fn465)
        else
            MenuGroup(hE_1.InputBegan:Connect(onInputBegan))
            MenuGroup(hE_1.InputChanged:Connect(onInputChanged))
            hD_1:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
            UserInputService(2, fn465)
        end
        hw_10 = (hw_10 + 7) % 8
    end
until (hw_10 * 7 + 3) % 8 == 3
local hv_10 = 3
repeat
    local hw_11 = {
        "nfzqpxhmhx",
        "menfscyjvu",
        "sbtavn",
        "hiz",
        "rlusivjuo",
        "jsruwgtnxkz",
        "qwttt",
        "qdvuo",
        "kdluxgsoyqy",
        "jvul",
        "uzkktrxyimi",
        "qzwmtez",
        "oazowkssgqei"
    }
    if hw_11[(hv_10 * 80 + 31) % 13 + 1] <= hw_11[(hv_10 * 80 + 31) % 13 + 1] then
        g0.ToggleKeybind = Options.MenuKeybind
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        MenuGroup:AddButton("Unload", onUnload)
        g0:OnUnload(fn45)
        hG_1:SetLibrary(g0)
        hG_1:SetFolder("TempoHub")
        hG_1:SaveDefault("Mint")
        hG_1:ApplyToTab(hx_2.Settings)
        hG_1:LoadDefault()
        hF_1:SetLibrary(g0)
        hF_1:IgnoreThemeSettings()
        hF_1:SetIgnoreIndexes({ "MenuKeybind" })
        hF_1:SetFolder("TempoHub/catch-a-monster")
        hF_1:BuildConfigSection(hx_2.Settings)
        hF_1:LoadAutoloadConfig()
    else
        hF_1.ToggleKeybind = MenuGroup.MenuKeybind
        Options:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Options:AddButton("Unload", onUnload)
        hF_1:OnUnload(fn45)
        g0:SetLibrary(hF_1)
        g0:SetFolder("TempoHub")
        g0:SaveDefault("Mint")
        g0:ApplyToTab(hG_1.Settings)
        g0:LoadDefault()
        hx_2:SetLibrary(hF_1)
        hx_2:IgnoreThemeSettings()
        hx_2:SetIgnoreIndexes({ "MenuKeybind" })
        hx_2:SetFolder("TempoHub/catch-a-monster")
        hx_2:BuildConfigSection(hG_1.Settings)
        hx_2:LoadAutoloadConfig()
    end
    hv_10 = (hv_10 + 2) % 4
until (hv_10 * 3 + 0) % 4 == 3
end)(...)

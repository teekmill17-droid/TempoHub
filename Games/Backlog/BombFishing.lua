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
getgenv().TempoHoodSubtitle = "BOMB FISHING!"
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
local j1
local kK
local kq
local j7
local CollectionService
local jP
local kx
local kd
local jV
local kj
local j0
local kJ
local onIdled
local CFrame2
local kP
local UserInputService
local kc
local FishItem
local ThemeManager
local ki
local j_
local kI
local ko
local j5
local kO
local connection
local kb
local kU
local jT
local kB
local kh
local Config
local kH
local VirtualUser
local j4
local kN
local kt
local ka
local kT
local jS
local kA
local kg
local jY
local setThrowing
local km
local j3
local kM
local ks
local j9
local kS
local jR
local kz
local LocalPlayer
local jX
local kF
local kl
local Util
local kL
local kr
local KnitClient
local kR
local jQ
local ky
local ke
local jW
local kE
local kk
local function fn23()
    local mQ_1
    local mP_1
    mP_1, mQ_1 = pcall(function()
        return KnitClient.UI.OtherScreen.Gameplay.ChargeBar.how.Position.Y.Scale
    end)
    if not mP_1 or not mQ_1 then
        return 1
    end
    local mP_2 = Util.number.proximityValue(mQ_1, 0, 1, 0.5, 1)
    return math.round(mP_2 * 10) / 10
end
local function fn24()
    ThemeManager:LoadDefault()
end
local function worker3()
    while not kH.Unloaded do
        if kt then
            pcall(function()
                kP.SellInventory:Fire()
            end)
        end
        task.wait(3)
    end
end
local function onIslandSelect(fo)
    kg = fo
end
local function worker5()
    while not kH.Unloaded do
        if kd then
            pcall(function()
                local nT = kM()
                if nT and nT.CollectClass then
                    kb.SendTagData:Fire("Collect", nT.CollectClass.Object, "collectCash")
                end
            end)
        end
        task.wait(2)
    end
end
local function onTeleport()
    j9(kg)
end
local function worker4()
    while not kH.Unloaded do
        if kl then
            pcall(function()
                local np = kM()
                if np and np.AquariumClass then
                    local nq_1 = j0:getDataReplica(true)
                    local nr = jW:getAquariumMaxFishNo({ DataReplica = nq_1 })
                    local ns = 0
                    for k in pairs(nq_1.Data.PlacedFishes) do
                        ns = ns + 1
                    end
                    local nt = nr - ns
                    if nt > 0 then
                        local nr_1 = {}
                        for k, v in pairs(nq_1.Data.Inventory.Fishes) do
                            local nq_2 = FishItem.createClass(v)
                            if nq_2 then
                                local ns_1 = #nr_1 + 1
                                local nu = tonumber(k)
                                local nv = jW:getCash({ FishItem = nq_2 }) or 0
                                nr_1[ns_1] = { uid = nu, cash = nv }
                            end
                        end
                        table.sort(nr_1, function(cY, cZ)
                            return cY.cash > cZ.cash
                        end)
                        local nq_3 = math.min(nt, #nr_1)
                        local nM = 1
                        while nM <= nq_3 do
                            local nN = nM
                            kb.SendTagData:Fire("Aquarium", np.AquariumClass.Object, "addFish", { UniqueId = nr_1[nN].uid })
                            task.wait(0.3)
                            nM += 1
                        end
                    end
                end
            end)
        end
        task.wait(2)
    end
end
local function worker8()
    while not kH.Unloaded do
        if jY then
            pcall(function()
                local Price, os_2
                local ot_1
                local Data = j0:getDataReplica(true).Data
                local Cash = Data.Cash
                local Luck
                ot_1, Price = nil, nil
                for k, v in pairs(Config.Bomb.Bombs) do
                    if v.Price and v.Price > 0 and v.Price <= Cash and not Data.PurchasedBombs[k] then
                        local ou_2 = not Price
                        local oI = if ou_2 then 1 else 0
                        local oG = 2480 * oI + 2914 * (1 - oI)
                        local oH = 1792 * oI + 1140 * (1 - oI)
                        if not ((oG * 42 + oH * 2508 + oG * oH) % 16777213 == 9042656) then
                            ou_2 = v.Price > Price
                        end
                        if ou_2 then
                            ot_1 = k
                            Price = v.Price
                        end
                    end
                end
                if ot_1 then
                    kA.Purchase:Fire(ot_1)
                    task.wait(0.5)
                end
                os_2, Luck = nil, nil
                for k in pairs(Data.PurchasedBombs) do
                    local ot_2 = Config.Bomb.Bombs[k]
                    if ot_2 and (not Luck or ot_2.Luck > Luck) then
                        os_2 = k
                        Luck = ot_2.Luck
                    end
                end
                if os_2 and Data.EquippedBomb ~= os_2 then
                    kA.Equip:Fire(os_2)
                end
            end)
        end
        task.wait(3)
    end
end
local function worker6()
    while not kH.Unloaded do
        if j7 then
            pcall(function()
                local nX = j4:getClass("player", LocalPlayer, true)
                local nY = nX and nX:GetPrivateReplica(true)
                if nY then
                    local nY_1 = nY.Data.PlaytimeRewards_PlayedTime or 0
                    for i, v in ipairs(Config.PlaytimeRewards.Rewards) do
                        local nY_2 = not nY.Data.ClaimedPlaytimeRewards[tostring(i)]
                        if nY_2 ~= false then
                            nY_2 = nY_1 >= v.Time
                        end
                        if nY_2 then
                            kF.Claim:Fire(i)
                        end
                    end
                end
            end)
        end
        task.wait(5)
    end
end
local function onJoinDiscordForDupes_KeylessS()
    if setclipboard then
        setclipboard(ke)
    end
    kH:Notify("Discord invite copied.", 4)
end
local function fn179()
    local mq = kM()
    if mq and mq.Base then
        for i, v in ipairs(CollectionService:GetTagged("CageBridge")) do
            if v:IsDescendantOf(mq.Base) then
                return v
            end
        end
    end
    return nil
end
local function fn191(ai)
    local l7_1, l7_2
    local l6_1
    for i, v in ipairs(ai) do
        l6_1, l7_1 = pcall(game.HttpGet, game, v)
        local l8 = l6_1 and type(l7_1) == "string" and #l7_1 > 200
        local l8_1
        if l8 then
            local l6_2 = loadstring(l7_1)
            if l6_2 then
                l7_2, l8_1 = pcall(l6_2)
                local l6_3 = l7_2 and type(l8_1) == "table"
                if l6_3 then
                    return l8_1
                end
            end
        end
    end
    return nil
end
local function worker10()
    while not kH.Unloaded do
        if jQ and kS then
            pcall(function()
                if not kR.currentEventClass then
                    local o0 = Config.Event.Events[kS]
                    local o1 = o0 and o0.Price and j0:getDataReplica(true).Data.Cash >= o0.Price
                    if o1 then
                        kj.Purchase:Fire(kS)
                    end
                end
            end)
        end
        task.wait(3)
    end
end
local function onPerfectScore(ff)
    kr = ff
end
local function worker11()
    while not kH.Unloaded do
        if kO then
            pcall(function()
                local o8 = ko()
                if o8 then
                    kb.SendTagData:Fire("CageBridge", o8, "claimFishes")
                end
            end)
        end
        task.wait(2)
    end
end
local function fn371()
    ThemeManager:SaveDefault("Mint")
end
local function fn386()
    local mG = j4:getClass("player", LocalPlayer)
    if mG then
        local mH = mG:GetPublicReplica(true)
        if mH and mH.Data and mH.Data.BombValues then
            return mH.Data.BombValues.State
        end
        return nil
    end
    return nil
end
local function onAutoThrow(fd)
    kz = fd
end
local function onDisableFishReveal(fh)
    kL = fh
end
local function fn498(eN, eO, eP)
    if kL and eO and eO.IsMine then
        eO.CurrentBombState = "throwing"
        return
    end
    return setThrowing(eN, eO, eP)
end
local function fn510(eU, eV, eW)
    if kL and eV and eV.IsMine then
        eV.CurrentBombState = "throwed"
        task.defer(function()
            pcall(function()
                jR.Finished:Fire()
            end)
        end)
        return
    end
    return jX(eU, eV, eW)
end
local function fn529()
    pcall(function()
        local Character = LocalPlayer.Character
        local m2 = Character and Character:FindFirstChildOfClass("Humanoid")
        if m2 then
            m2.Health = 0
        end
    end)
end
local function onResetDelay(fl)
    j3 = fl
end
local function worker2()
    while not kH.Unloaded do
        if kz or kr then
            local ne_1 = pcall(function()
                local m5_4
                local m4 = kk()
                local m4_1
                if m4 == "throwing" then
                    if not j_ then
                        local m6_1 = kr and 1
                        local nd = if m6_1 then 1 else 0
                        local nb = 365 * nd + 1144 * (1 - nd)
                        local nc = 478 * nd + 3564 * (1 - nd)
                        if not ((nb * 1605 + nc * 2827 + nb * nc) % 16777213 == 2111601) then
                            m6_1 = jP()
                        end
                        local m5_2 = m6_1
                        jR.Throw:Fire(m5_2)
                        j_ = true
                        if ka then
                            task.delay(j3, jV)
                        end
                    end
                else
                    j_ = false
                    if kz and m4 == nil then
                        m4_1, m5_4 = kU()
                        if m5_4 then
                            jR.Start:Fire(m5_4.UniqueId)
                        end
                    end
                end
            end)
            if not ne_1 then
                j_ = false
            end
        end
        task.wait(0.1)
    end
end
local function worker9()
    while not kH.Unloaded do
        if jT then
            pcall(function()
                local Cash = j0:getDataReplica(true).Data.Cash
                for i, v in ipairs(Config.Merchant.Potions) do
                    if v.Price and Cash >= v.Price then
                        ks.Purchase:Fire(i)
                    end
                end
            end)
        end
        task.wait(5)
    end
end
local function fn658()
    pcall(function()
        local mZ_1
        local mY_1
        mY_1, mZ_1 = kU()
        local mY_2 = kM()
        if not mZ_1 or not mZ_1.Hrp or not mY_2 or not mY_2.AquariumClass then
            return
        end
        local m__1 = mY_2.AquariumClass.Model and mY_2.AquariumClass.Model:FindFirstChild("TouchPart")
        if m__1 then
            mZ_1.Hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            mZ_1.Hrp:PivotTo(m__1.CFrame + Vector3.new(0, 3, 0))
        end
    end)
end
local function worker12()
    while not kH.Unloaded do
        if kJ then
            pcall(function()
                local Boosts = j0:getDataReplica(true).Data.Boosts
                for i in ipairs(Config.Merchant.Potions) do
                    local pf = Boosts["Potion" .. i]
                    if not pf or pf.Duration <= 0 then
                        ks.Purchase:Fire(i)
                    end
                end
            end)
        end
        task.wait(5)
    end
end
local function worker()
    while not kH.Unloaded do
        if ki then
            pcall(function()
                local ng = j0:getDataReplica(true)
                if ng then
                    local ni = Config.Rebirth.Rebirths[ng.Data.Rebirth + 1]
                    if ni and ng.Data.Cash >= ni.Requirements.Cash then
                        kT.Rebirth:Fire()
                    end
                end
            end)
        end
        task.wait(1)
    end
end
local function fn839()
    for k, v in pairs(jS.classes) do
        if v.IsMine then
            return v
        end
    end
    return nil
end
local function onResetAfterThrow(fj)
    ka = fj
end
local function fn851()
    local mz = j4:getClass("player", LocalPlayer)
    if mz then
        local CharacterClass = mz.CharacterClass
        if CharacterClass and not CharacterClass.Dead then
            return mz, CharacterClass
        end
        return nil, nil
    end
    return nil, nil
end
local function worker7()
    while not kH.Unloaded do
        if j1 then
            pcall(function()
                local Data = j0:getDataReplica(true).Data
                local RewardedTime = Data.DailyRewards.RewardedTime
                local oi = (RewardedTime == 0 or workspace:GetServerTimeNow() - RewardedTime >= Config.DailyRewards.WaitTime) and Config.DailyRewards.Rewards[Data.DailyRewards.Day + 1]
                if oi then
                    kK.Claim:Fire()
                end
            end)
        end
        task.wait(10)
    end
end
jP = nil
jQ = nil
jR = nil
jS = nil
jT = nil
FishItem = nil
jV = nil
jW = nil
jX = nil
jY = nil
Config = nil
j_ = nil
j0 = nil
j1 = nil
Util = nil
j3 = nil
j4 = nil
j5 = nil
CFrame2 = nil
j7 = nil
KnitClient = nil
j9 = nil
ka = nil
kb = nil
kc = nil
kd = nil
ke = nil
LocalPlayer = nil
kg = nil
kh = nil
ki = nil
kj = nil
kk = nil
kl = nil
km = nil
VirtualUser = nil
ko = nil
onIdled = nil
kq = nil
kr = nil
ks = nil
kt = nil
connection = nil
UserInputService = nil
kx = nil
ky = nil
kz = nil
kA = nil
kB = nil
ThemeManager = nil
kE = nil
kF = nil
setThrowing = nil
kH = nil
kI = nil
kJ = nil
kK = nil
kL = nil
kM = nil
kN = nil
kO = nil
kP = nil
CollectionService = nil
kR = nil
kS = nil
kT = nil
kU = nil
local TweenService
local MenuGroup
local Window
local k4_1
local k2_1
CollectionService, TweenService, UserInputService, VirtualUser, LocalPlayer, kH = nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
TweenService = game:GetService("TweenService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
LocalPlayer = Players.LocalPlayer
local function kW()
    local lI
    local lG
    local lH
    local textButton
    local frame3
    local lK
    frame3 = nil
    lG = nil
    lH = nil
    lI = nil
    textButton = nil
    lK = nil
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TempoLoader"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 2147483647
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local lM = gethui and gethui()
    local lN = lM or game:GetService("CoreGui")
    screenGui.Parent = lN
    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Size = 0
    blurEffect.Parent = game:GetService("Lighting")
    local frame4 = Instance.new("Frame")
    frame4.Size = UDim2.fromScale(1, 1)
    frame4.BackgroundTransparency = 1
    frame4.Parent = screenGui
    frame3 = Instance.new("Frame")
    frame3.AnchorPoint = Vector2.new(0.5, 0.5)
    frame3.Position = UDim2.fromScale(0.5, 0.5)
    frame3.Size = UDim2.fromOffset(460, 0)
    frame3.AutomaticSize = Enum.AutomaticSize.Y
    frame3.BackgroundTransparency = 1
    frame3.Parent = frame4
    local uIListLayout = Instance.new("UIListLayout")
    uIListLayout.FillDirection = Enum.FillDirection.Vertical
    uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uIListLayout.Padding = UDim.new(0, 8)
    uIListLayout.Parent = frame3
    lK = function(w)
        local uIStroke = Instance.new("UIStroke")
        uIStroke.Color = Color3.fromRGB(0, 0, 0)
        uIStroke.Thickness = 2
        uIStroke.Transparency = 0.1
        uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        uIStroke.Parent = w
        return uIStroke
    end
    local function lN_3(z, A, B, C, D)
        local textLabel = Instance.new("TextLabel")
        textLabel.BackgroundTransparency = 1
        textLabel.Size = UDim2.fromOffset(460, A + 6)
        textLabel.Font = B
        textLabel.Text = z
        textLabel.TextSize = A
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextTransparency = C
        textLabel.LayoutOrder = D
        lK(textLabel)
        textLabel.Parent = frame3
        return textLabel
    end
    lG = "https://discord.gg/K7Qxnxkk46"
    lN_3("Made Tempo Marketplace && MM", 26, Enum.Font.GothamBold, 0, 1)
    textButton = Instance.new("TextButton")
    textButton.BackgroundTransparency = 1
    textButton.AutoButtonColor = false
    textButton.Size = UDim2.fromOffset(460, 24)
    textButton.Font = Enum.Font.GothamSemibold
    textButton.RichText = true
    textButton.Text = "<u>" .. lG .. "</u>  (click to copy)"
    textButton.TextSize = 16
    textButton.TextColor3 = Color3.fromRGB(120, 160, 255)
    textButton.LayoutOrder = 2
    lK(textButton)
    textButton.Parent = frame3
    textButton.MouseEnter:Connect(function()
        textButton.TextColor3 = Color3.fromRGB(170, 200, 255)
    end)
    textButton.MouseLeave:Connect(function()
        textButton.TextColor3 = Color3.fromRGB(120, 160, 255)
    end)
    textButton.Activated:Connect(function()
        if setclipboard then
            setclipboard(lG)
        end
        textButton.Text = "<u>" .. lG .. "</u>  (copied!)"
        task.delay(1.5, function()
            textButton.Text = "<u>" .. lG .. "</u>  (click to copy)"
        end)
    end)
    local lO = lN_3("Join for Dupes and Keyless Scripts. Dupes will always be announced and never gatekept in Tempo.", 13, Enum.Font.GothamMedium, 0.2, 3)
    lO.TextWrapped = true
    lO.Size = UDim2.fromOffset(420, 34)
    lI = lN_3("Tempo Bypassing", 14, Enum.Font.GothamMedium, 0.05, 4)
    lI.Size = UDim2.fromOffset(460, 18)
    local frame2 = Instance.new("Frame")
    frame2.LayoutOrder = 5
    frame2.Size = UDim2.fromOffset(300, 6)
    frame2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame2.BackgroundTransparency = 0.85
    frame2.BorderSizePixel = 0
    frame2.Parent = frame3
    local uICorner2 = Instance.new("UICorner")
    uICorner2.CornerRadius = UDim.new(1, 0)
    uICorner2.Parent = frame2
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromScale(0, 1)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BorderSizePixel = 0
    frame.Parent = frame2
    local uICorner = Instance.new("UICorner")
    uICorner.CornerRadius = UDim.new(1, 0)
    uICorner.Parent = frame
    lH = true
    task.spawn(function()
        local lD = 0
        while lH do
            lD = lD % 3 + 1
            lI.Text = "Tempo Bypassing" .. string.rep(".", lD)
            task.wait(0.35)
        end
    end)
    TweenService:Create(blurEffect, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = 18 }):Play()
    local lP_1 = { 0.35, 0.55, 0.72, 0.9, 1 }
    for i, v in ipairs(lP_1) do
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromScale(v, 1) }):Play()
        task.wait(0.55)
    end
    lH = false
    task.wait(0.25)
    local lP_2 = TweenInfo.new(0.4, Enum.EasingStyle.Quad)
    for i, descendant in ipairs(frame3:GetDescendants()) do
        local lQ = descendant:IsA("TextLabel") or descendant:IsA("TextButton")
        if lQ then
            TweenService:Create(descendant, lP_2, { TextTransparency = 1 }):Play()
        else
            local l5 = if descendant:IsA("UIStroke") then 1 else 0
            if l5 == 1 then
                TweenService:Create(descendant, lP_2, { Transparency = 1 }):Play()
            end
        end
    end
    TweenService:Create(frame2, lP_2, { BackgroundTransparency = 1 }):Play()
    TweenService:Create(frame, lP_2, { BackgroundTransparency = 1 }):Play()
    TweenService:Create(blurEffect, lP_2, { Size = 0 }):Play()
    task.wait(0.45)
    blurEffect:Destroy()
    screenGui:Destroy()
end
local TeleportGroup
kW()
kH = getgenv().Library
if not kH then
    return
end
ThemeManager, ke, KnitClient, Util, Config, FishItem, jR, kT, kP, kK, kF, kA, ks, kj, kb, j4, j0, jW, jS, kR, kg, kz, kr, ki, ka, j3, j_, kt, kl, kd, j7, j1, jY, jT, jQ, kS, kO, kJ, kL, setThrowing, jX, Window, TeleportGroup, k4_1, MenuGroup, k2_1, j5, kM, ko, kU, kk, jP, j9, km, jV = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
local Options = kH.Options
ke = "https://discord.gg/K7Qxnxkk46"
KnitClient = require(ReplicatedStorage.src.Modules.KnitClient)
Util = require(ReplicatedStorage.Util)
Config = require(ReplicatedStorage.Config)
FishItem = require(ReplicatedStorage.src.Shared.FishItem)
jR = KnitClient.GetService("BombService")
kT = KnitClient.GetService("RebirthService")
kP = KnitClient.GetService("SellService")
kK = KnitClient.GetService("DailyRewardService")
kF = KnitClient.GetService("PlaytimeRewardService")
kA = KnitClient.GetService("BombShopService")
ks = KnitClient.GetService("MerchantService")
kj = KnitClient.GetService("EventService")
kb = KnitClient.GetService("BaseService")
j4 = KnitClient.GetController("PlayerController")
j0 = KnitClient.GetController("DataController")
jW = KnitClient.GetController("CalculateController")
jS = KnitClient.GetController("BaseController")
local kV_1 = KnitClient.GetController("BombController")
kR = KnitClient.GetController("EventController")
kM = fn839
ko = fn179
kU = fn851
kk = fn386
jP = fn23
kg = "Normal Island"
j9 = function(bl)
    pcall(function()
        local mV_1
        local mU_1
        mU_1, mV_1 = kU()
        if not mV_1 or not mV_1.Hrp then
            return
        end
        if bl == "Volcano Island" then
            local VolcanoMap = workspace:FindFirstChild("VolcanoMap")
            local mW = VolcanoMap and VolcanoMap:FindFirstChild("Teleport")
            if mW then
                mV_1.Hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                mV_1.Hrp:PivotTo(mW.CFrame)
            end
        else
            mV_1:TeleportToBase()
        end
    end)
end
km = fn658
kz = false
kr = false
ki = false
ka = false
j3 = 1
j_ = false
if (not kA and not jS or (not jS or not kt) or not kt and not k2_1 and (not jX or kA)) and (jS and not kt and (not jX or k2_1) and (kt or not kt or not kt and not k2_1)) or not ((not kA and not jS or (not jS or not kt) or not kt and not k2_1 and (not jX or kA)) and (jS and not kt and (not jX or k2_1) and (kt or not kt or not kt and not k2_1))) then
    jV = fn529
    task.spawn(worker2)
    task.spawn(worker)
    kt = false
    kl = false
else
    kl = fn529
    task.spawn(worker2)
    task.spawn(worker)
    jV = false
    kt = false
end
kd = false
j7 = false
j1 = false
jY = false
if (not ko and ko or (kl or kl) or (not ko or not j0 or (kl or ko))) and (not kl and ko or not j0 and ko or (j0 or not kl) and (not ko and not ko)) and not ((not ko and ko or (kl or kl) or (not ko or not j0 or (kl or ko))) and (not kl and ko or not j0 and ko or (j0 or not kl) and (not ko and not ko))) then
    jX = false
else
    jT = false
end
jQ = false
kS = nil
kO = false
kJ = false
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
task.spawn(worker6)
task.spawn(worker7)
task.spawn(worker8)
task.spawn(worker9)
task.spawn(worker10)
task.spawn(worker11)
task.spawn(worker12)
kL = false
setThrowing = kV_1.setThrowing
kV_1.setThrowing = fn498
jX = kV_1.setThrowed
if (not jR or false or (not jR or j9) or (not jP or jP or jP and not jR) or j9 and jP and (false and jR) and (jR or jP or not jR and jR)) and ((jP or not jP) and (not jP and not jP) and (jP or j9 or j9 and not jR) and (not jP and j9 and (j9 and jR) or (j9 and j9 or false and jR))) and not ((not jR or false or (not jR or j9) or (not jP or jP or jP and not jR) or j9 and jP and (false and jR) and (jR or jP or not jR and jR)) and ((jP or not jP) and (not jP and not jP) and (jP or j9 or j9 and not jR) and (not jP and j9 and (j9 and jR) or (j9 and j9 or false and jR)))) then
    Window.setThrowed = fn510
    kH = kV_1:CreateWindow({
        Footer = "Tempo Hub",
        Title = "Bomb Fishing!",
        ShowCustomCursor = false,
        AutoShow = true,
        Center = true,
        Size = UDim2.fromOffset(760, 600),
        NotifySide = "Right",
        Resizable = true
    })
else
    kV_1.setThrowed = fn510
    Window = kH:CreateWindow({
        Title = "Bomb Fishing!",
        Footer = "Tempo Hub",
        NotifySide = "Right",
        ShowCustomCursor = false,
        Center = true,
        AutoShow = true,
        Resizable = true,
        Size = UDim2.fromOffset(760, 600)
    })
end
local k9 = {
    Main = Window:AddTab("Automation", "bomb"),
    Farm = Window:AddTab("Farm", "fish"),
    Player = Window:AddTab("Player", "user"),
    Settings = Window:AddTab("Settings", "settings")
}
local BombingGroup = k9.Main:AddLeftGroupbox("Bombing")
if (not k4_1 and ThemeManager or (k9 or kA)) and ((k4_1 or not k9) and (not k9 or kA)) and ((not kA or k4_1) and (kA and not kA) or (not k9 or k4_1 or (kA or not kA))) or not ((not k4_1 and ThemeManager or (k9 or kA)) and ((k4_1 or not k9) and (not k9 or kA)) and ((not kA or k4_1) and (kA and not kA) or (not k9 or k4_1 or (kA or not kA)))) then
    TeleportGroup = k9.Main:AddLeftGroupbox("Teleport")
else
    k9 = TeleportGroup.Main:AddLeftGroupbox("Teleport")
end
local Events_RebirthGroup = k9.Main:AddRightGroupbox("Events & Rebirth")
local Aquarium_SellingGroup = k9.Farm:AddLeftGroupbox("Aquarium & Selling")
local Shop_RewardsGroup = k9.Farm:AddRightGroupbox("Shop & Rewards")
local MainGroup = k9.Settings:AddLeftGroupbox("Main")
if (not KnitClient or jR or (not KnitClient or not jS) or jS and jR and (BombingGroup and jS)) and ((BombingGroup or not jS) and (KnitClient and jS) or (not jS or BombingGroup or (not KnitClient or not jR))) and ((not BombingGroup and not KnitClient or KnitClient and jS) and (jS and not KnitClient and (BombingGroup and BombingGroup)) or ((not jR or not jS) and (not KnitClient or BombingGroup) or (BombingGroup or not jS or not jR and not BombingGroup))) and not ((not KnitClient or jR or (not KnitClient or not jS) or jS and jR and (BombingGroup and jS)) and ((BombingGroup or not jS) and (KnitClient and jS) or (not jS or BombingGroup or (not KnitClient or not jR))) and ((not BombingGroup and not KnitClient or KnitClient and jS) and (jS and not KnitClient and (BombingGroup and BombingGroup)) or ((not jR or not jS) and (not KnitClient or BombingGroup) or (BombingGroup or not jS or not jR and not BombingGroup)))) then
    k9 = MenuGroup.Settings:AddRightGroupbox("Menu")
else
    MenuGroup = k9.Settings:AddRightGroupbox("Menu")
end
BombingGroup:AddButton({
    Text = "Join Discord for Dupes/Keyless Scripts",
    Tooltip = "Copies the invite link to your clipboard.",
    Func = onJoinDiscordForDupes_KeylessS
})
BombingGroup:AddToggle("AutoThrow", { Text = "Auto Throw", Default = false, Callback = onAutoThrow })
BombingGroup:AddToggle("PerfectScore", { Text = "Auto Perfect Charge Score", Default = false, Callback = onPerfectScore })
BombingGroup:AddToggle("DisableFishReveal", { Text = "Disable Fish Reveal & Charge Animation", Default = false, Callback = onDisableFishReveal })
BombingGroup:AddToggle("ResetAfterThrow", { Text = "Reset After Throwing", Default = false, Callback = onResetAfterThrow })
BombingGroup:AddSlider("ResetDelay", { Text = "Reset Delay", Default = 1, Min = 0, Max = 10, Rounding = 1, Callback = onResetDelay })
TeleportGroup:AddDropdown("IslandSelect", {
    Text = "Island",
    Values = { "Normal Island", "Volcano Island" },
    Default = "Normal Island",
    Multi = false,
    Callback = onIslandSelect
})
TeleportGroup:AddButton({ Text = "Teleport", Func = onTeleport })
local k2_2 = {}
j5 = {}
for k, v in pairs(Config.Event.Events) do
    if v.Price then
        k2_2[#k2_2 + 1] = v.FullName
        j5[v.FullName] = k
    end
end
table.sort(k2_2)
Events_RebirthGroup:AddDropdown("WeatherSelect", {
    Text = "Weather",
    Values = k2_2,
    Default = k2_2[1],
    Multi = false,
    Searchable = true,
    Callback = function(fw)
        kS = j5[fw]
    end
})
kS = j5[k2_2[1]]
Events_RebirthGroup:AddToggle("AutoWeather", {
    Text = "Auto Weather",
    Default = false,
    Callback = function(fz)
        jQ = fz
    end
})
Events_RebirthGroup:AddToggle("AutoRebirth", {
    Text = "Auto Rebirth",
    Default = false,
    Callback = function(fB)
        ki = fB
    end
})
Aquarium_SellingGroup:AddButton({
    Text = "Open Aquarium UI",
    Func = function()
        km()
    end
})
Aquarium_SellingGroup:AddToggle("AutoSell", {
    Text = "Auto Sell All Fish",
    Default = false,
    Callback = function(fE)
        kt = fE
    end
})
Aquarium_SellingGroup:AddToggle("EquipBestAquarium", {
    Text = "Equip Best for Aquarium",
    Default = false,
    Callback = function(fG)
        kl = fG
    end
})
Aquarium_SellingGroup:AddToggle("AutoCollect", {
    Text = "Auto Collect Money from Aquarium",
    Default = false,
    Callback = function(fI)
        kd = fI
    end
})
Aquarium_SellingGroup:AddToggle("AutoCage", {
    Text = "Auto Collect Fish from Cage",
    Default = false,
    Callback = function(fK)
        kO = fK
    end
})
Shop_RewardsGroup:AddToggle("AutoPotion", {
    Text = "Auto Use Potion",
    Default = false,
    Callback = function(fM)
        kJ = fM
    end
})
Shop_RewardsGroup:AddToggle("AutoBuyBombs", {
    Text = "Auto Purchase Best Affordable Bombs",
    Default = false,
    Callback = function(fO)
        jY = fO
    end
})
Shop_RewardsGroup:AddToggle("AutoBuyMerchant", {
    Text = "Auto Buy Merchant Stock",
    Default = false,
    Callback = function(fQ)
        jT = fQ
    end
})
Shop_RewardsGroup:AddToggle("AutoPlaytime", {
    Text = "Auto Claim Playtime Rewards",
    Default = false,
    Callback = function(fS)
        j7 = fS
    end
})
Shop_RewardsGroup:AddToggle("AutoDaily", {
    Text = "Auto Claim Daily Rewards",
    Default = false,
    Callback = function(fU)
        j1 = fU
    end
})
local MovementGroup = k9.Player:AddLeftGroupbox("Movement")
local CustomRespawnGroup = k9.Player:AddRightGroupbox("Custom Respawn")
kq = false
kN = false
kI = 60
kx = 16
kE = false
kh = false
task.spawn(function()
    while not kH.Unloaded do
        if kN then
            local Character = LocalPlayer.Character
            local pA = Character and Character:FindFirstChild("HumanoidRootPart")
            local pB = Character
            local pC = pA
            if pB then
                pB = Character:FindFirstChildOfClass("Humanoid")
            end
            local pz_1 = pB
            if pA then
                pA = pz_1
            end
            if pA then
                pz_1.PlatformStand = true
                local pz_2 = Vector3.new(0, 0, 0)
                local CFrame = workspace.CurrentCamera.CFrame
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    pz_2 = pz_2 + CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    pz_2 = pz_2 - CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    pz_2 = pz_2 - CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    pz_2 = pz_2 + CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    pz_2 = pz_2 + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    pz_2 = pz_2 - Vector3.new(0, 1, 0)
                end
                if pz_2.Magnitude > 0 then
                    pz_2 = pz_2.Unit
                end
                pC.AssemblyLinearVelocity = pz_2 * kI
            end
        end
        task.wait()
    end
end)
task.spawn(function()
    while not kH.Unloaded do
        if kE then
            local pH = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if pH then
                pH.WalkSpeed = kx
            end
        end
        task.wait(0.2)
    end
end)
task.spawn(function()
    while not kH.Unloaded do
        if kq then
            local Character = LocalPlayer.Character
            if Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    local pN_1 = descendant:IsA("BasePart") and descendant.CanCollide
                    if pN_1 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
        task.wait()
    end
end)
UserInputService.JumpRequest:Connect(function()
    if kh and not kH.Unloaded then
        local pV_1 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if pV_1 then
            pV_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
MovementGroup:AddToggle("Fly", {
    Text = "Fly",
    Default = false,
    Callback = function(gy)
        kN = gy
        if not gy then
            local pY = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if pY then
                pY.PlatformStand = false
            end
        end
    end
})
MovementGroup:AddSlider("FlySpeed", {
    Text = "Fly Speed",
    Default = 60,
    Min = 10,
    Max = 300,
    Rounding = 0,
    Callback = function(gD)
        kI = gD
    end
})
MovementGroup:AddToggle("WalkSpeedEnabled", {
    Text = "WalkSpeed",
    Default = false,
    Callback = function(gF)
        kE = gF
        if not gF then
            local p0 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if p0 then
                p0.WalkSpeed = 16
            end
        end
    end
})
MovementGroup:AddSlider("WalkSpeed", {
    Text = "WalkSpeed Amount",
    Default = 16,
    Min = 16,
    Max = 300,
    Rounding = 0,
    Callback = function(gK)
        kx = gK
    end
})
MovementGroup:AddToggle("Noclip", {
    Text = "Noclip",
    Default = false,
    Callback = function(gM)
        kq = gM
    end
})
MovementGroup:AddToggle("InfJump", {
    Text = "Infinite Jump",
    Default = false,
    Callback = function(gO)
        kh = gO
    end
})
CFrame2 = nil
kc = false
LocalPlayer.CharacterAdded:Connect(function(gS)
    if not kc or not CFrame2 or kH.Unloaded then
        return
    end
    task.spawn(function()
        local HumanoidRootPart = gS:WaitForChild("HumanoidRootPart", 10)
        if not HumanoidRootPart then
            return
        end
        gS:WaitForChild("Humanoid", 5)
        task.wait(0.3)
        if kc and CFrame2 then
            pcall(function()
                HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                gS:PivotTo(CFrame2)
            end)
        end
    end)
end)
CustomRespawnGroup:AddToggle("RespawnLocationEnabled", {
    Text = "Force Custom Respawn",
    Default = false,
    Callback = function(g3)
        kc = g3
    end
})
CustomRespawnGroup:AddButton({
    Text = "Set Respawn Location",
    Func = function()
        local Character = LocalPlayer.Character
        local p9 = Character and Character:FindFirstChild("HumanoidRootPart")
        if p9 then
            CFrame2 = p9.CFrame
            kH:Notify("Respawn location saved.", 4)
        else
            kH:Notify("Character not found.", 4)
        end
    end
})
kB = false
connection = nil
onIdled = function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end
task.spawn(function()
    while not kH.Unloaded do
        if kB then
            onIdled()
        end
        task.wait(60)
    end
end)
MainGroup:AddToggle("AntiAfk", {
    Text = "Anti-AFK",
    Default = true,
    Callback = function(hj)
        kB = hj
        if hj then
            if not connection then
                connection = LocalPlayer.Idled:Connect(onIdled)
            end
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end
})
ky = { "50%", "75%", "90%", "100%", "110%", "125%", "150%" }
MenuGroup:AddDropdown("UIScale", {
    Text = "UI Scale",
    Values = ky,
    Default = 4,
    Multi = false,
    Callback = function(hp)
        local qd = hp
        if type(hp) == "number" then
            qd = ky[hp]
        end
        local qe = tonumber((tostring(qd):gsub("%%", "")))
        if qe and qe >= 25 then
            kH:SetDPIScale(qe)
        end
    end
})
MenuGroup:AddLabel("Menu keybind"):AddKeyPicker("MenuKeybind", { Default = "RightControl", NoUI = true, Text = "Menu keybind" })
kH.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddButton({
    Text = "Unload",
    Func = function()
        kH:Unload()
    end
})
if ThemeManager then
    local kV_3 = 0
    repeat
        local kW_3 = { "rtjpdvajllr", "tsudfzjsqm", "xsaht", "dpit", "hmhqhctole", "vjpbobiuhcg", "doc", "lcq" }
        local rf = kV_3
        local kX_1 = kW_3[rf % 8 + 1]
        if kX_1:len() >= kX_1:gsub("(.)", "%1%1", rf % 3 % 2 + 1):len() then
            k9:SetLibrary(ThemeManager)
            k9:SetFolder("TempoHub")
            k9:ApplyToTab(kH.Settings)
            pcall(fn371)
            pcall(fn24)
        else
            ThemeManager:SetLibrary(kH)
            ThemeManager:SetFolder("TempoHub")
            ThemeManager:ApplyToTab(k9.Settings)
            pcall(fn371)
            pcall(fn24)
        end
        kV_3 = (kV_3 + 1) % 4
    until (kV_3 * 1 + 2) % 4 == 3
end
if SaveManager then
    local kV_4 = 0
    repeat
        local kW_4 = {
            "jtdujxdbu",
            "cmoxam",
            "zsqeq",
            "dub",
            "vfhesb",
            "ivseomyregf",
            "jjkimjzquj",
            "nrwkqubae",
            "keoudl"
        }
        local rn = kV_4
        local kX_2 = kW_4[rn % 9 + 1]
        if kX_2:len() <= kX_2:reverse():rep(rn % 3 + 2):len() then
            SaveManager:SetLibrary(kH)
            SaveManager:IgnoreThemeSettings()
            SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
            SaveManager:SetFolder("TempoHub/BombFishing")
            SaveManager:BuildConfigSection(k9.Settings)
            SaveManager:LoadAutoloadConfig()
        else
            k9:SetLibrary(SaveManager)
            k9:IgnoreThemeSettings()
            k9:SetIgnoreIndexes({ "MenuKeybind" })
            k9:SetFolder("TempoHub/BombFishing")
            k9:BuildConfigSection(kH.Settings)
            k9:LoadAutoloadConfig()
        end
        kV_4 = (kV_4 + 7) % 8
    until (kV_4 * 1 + 4) % 8 == 3
end
kH:OnUnload(function()
    kz = false
    kr = false
    ki = false
    ka = false
    kL = false
    kt = false
    kl = false
    kd = false
    j7 = false
    j1 = false
    jY = false
    jT = false
    jQ = false
    kO = false
    kJ = false
    kB = false
    kN = false
    kE = false
    kq = false
    kh = false
    kc = false
    pcall(function()
        local Character = LocalPlayer.Character
        local qh = Character and Character:FindFirstChildOfClass("Humanoid")
        if qh then
            qh.PlatformStand = false
            qh.WalkSpeed = 16
        end
    end)
    if connection then
        connection:Disconnect()
        connection = nil
    end
end)
end)(...)

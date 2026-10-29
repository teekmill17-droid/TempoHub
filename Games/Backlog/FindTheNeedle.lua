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
getgenv().TempoHoodSubtitle = "FIND THE NEEDLE!"
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
local l4
local Bridge
local l7
local lP
local mw
local lS
local mz
local lV
local mC
local lY
local mj
local l0
local l3
local mp
local mL
local mO
local lO
local l9
local mR
local lR
local mc
local DifficultyData
local Options
local mE
local mH
local mo
local Toggles
local lQ
local mA
local mh
local lW
local mk
local mG
local l1
local Library
local function fn32(dC)
    local Lobby = l0:FindFirstChild("Lobby")
    local pH = Lobby and Lobby:FindFirstChild("Pads")
    local pG_1 = pH
    if pH then
        pH = pG_1:FindFirstChild("Pad" .. tostring(dC))
    end
    local pG_2 = pH
    if not pG_2 then
        return nil
    end
    local Fill = pG_2:FindFirstChild("Fill")
    local pI = Fill and Fill:IsA("BasePart")
    if pI then
        return Fill.Position, Fill
    elseif pG_2:IsA("Model") then
        return pG_2:GetPivot().Position, nil
    else
        return nil
    end
end
local function onRenderStepped()
    if Library.Unloaded then
        return
    end
    pcall(lR)
end
local function fn118(ai, aj, ak)
    return string.format("<b>%s</b> %s %s", ai, mC("-", "#5a6070"), mC(aj, ak))
end
local function fn121()
    local ny = tonumber(lW:GetAttribute("HayCapacity")) or 5
    return ny
end
local function fn161()
    l3(mh, "Copied Discord invite to clipboard")
end
local function fn212()
    local nw = tonumber(lW:GetAttribute("HayCarried")) or 0
    return nw
end
local function fn242()
    local pt = Options.LobbyDifficulty and Options.LobbyDifficulty.Value
    local pt_1 = pt ~= ""
    local pv = type(pt) == "string" and pt_1
    if pv then
        return pt
    end
    return DifficultyData.Default or "Easy"
end
local function fn292(ec)
    local DiscordGroup = ec:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = mR })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = mR })
end
local function fn309()
    if not Toggles.NeedleEsp.Value then
        lV()
    end
end
local function fn359(aU)
    local nA = Options[aU]
    if not nA then
        return {}
    end
    local Value = nA.Value
    if type(Value) == "table" then
        return Value
    end
    local nA_1 = Value ~= ""
    local nC = type(Value) == "string" and nA_1
    if nC then
        return { [Value] = true }
    end
    return {}
end
local function fn367()
    local nS_1
    local nR = not l7.highlight or not l7.highlight.Parent
    local nR_3
    if nR then
        local highlight = Instance.new("Highlight")
        highlight.Name = "TempoNeedleEsp"
        highlight.FillColor = Color3.fromRGB(255, 105, 180)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.4
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = nil
        highlight.Parent = mj
        l7.highlight = highlight
    end
    local nR_2 = not l7.text and typeof(Drawing) == "table" and type(Drawing.new) == "function"
    if nR_2 then
        nR_3, nS_1 = pcall(Drawing.new, "Text")
        if nR_3 and nS_1 then
            nS_1.Size = 16
            nS_1.Center = true
            nS_1.Outline = true
            nS_1.OutlineColor = Color3.fromRGB(0, 0, 0)
            nS_1.Color = Color3.fromRGB(255, 105, 180)
            if Drawing.Fonts and Drawing.Fonts.UI then
                nS_1.Font = Drawing.Fonts.UI
            end
            nS_1.Visible = false
            l7.text = nS_1
        end
    end
end
local function fn418()
    local Main = l0:FindFirstChild("Main")
    local nL = Main and Main:FindFirstChild("Needle")
    local nK_1 = nL
    if nL then
        nL = nK_1:IsA("BasePart")
    end
    if nL then
        nL = nK_1.Parent
    end
    if nL then
        return nK_1
    end
    return nil
end
local function fn429(aB)
    local np_1
    local no_1
    no_1, np_1 = pcall(Bridge.GetBridge, aB)
    if no_1 then
        return np_1
    end
    return nil
end
local function fn432()
    return lO() >= mL()
end
local function fn481(Y, Z)
    if setclipboard then
        setclipboard(Y)
    elseif toclipboard then
        toclipboard(Y)
    end
    Library:Notify(Z)
end
local function fn491(an)
    if Library.Unloaded then
        return false
    end
    local nf = Toggles[an]
    return nf ~= nil and nf.Value == true
end
local function fn573()
    local n1_1
    local n0_1
    if not lS("NeedleEsp") then
        if l7.highlight or l7.text then
            lV()
        end
        return
    end
    mG()
    local nY_2 = mp()
    local highlight = l7.highlight
    local text = l7.text
    if not nY_2 then
        if highlight then
            highlight.Adornee = nil
        end
        if text then
            text.Visible = false
        end
        return
    end
    if highlight then
        highlight.Adornee = nY_2
    end
    if not text then
        return
    end
    local CurrentCamera = l0.CurrentCamera
    if not CurrentCamera then
        text.Visible = false
        return
    end
    n1_1, n0_1 = CurrentCamera:WorldToViewportPoint(nY_2.Position)
    if n0_1 and n1_1.Z > 0 then
        local n0_2 = CurrentCamera.CFrame.Position
        local nZ_2 = l4()
        if nZ_2 then
            n0_2 = nZ_2.Position
        end
        local nZ_3 = math.floor((nY_2.Position - n0_2).Magnitude + 0.5)
        text.Text = "Needle [" .. nZ_3 .. "m]"
        text.Position = Vector2.new(n1_1.X, n1_1.Y - 18)
        text.Visible = true
    else
        text.Visible = false
    end
end
local function fn622(a1)
    local nF = not a1
    local nJ = if nF then 1 else 0
    local nH = 1892 * nJ + 1318 * (1 - nJ)
    local nI = 957 * nJ + 427 * (1 - nJ)
    if not ((nH * 3462 + nI * 507 + nH * nI) % 16777213 == 8845947) then
        nF = not fireclickdetector
    end
    if nF then
        return
    end
    pcall(fireclickdetector, a1)
end
local function fn628()
    local PlayerGui = lW:FindFirstChild("PlayerGui")
    local po = PlayerGui and PlayerGui:FindFirstChild("LobbyUIs")
    local pn_1 = po
    if po then
        po = pn_1:FindFirstChild("QueueUI")
    end
    local pn_2 = po
    if po then
        po = pn_2:FindFirstChild("PartyBar")
    end
    local pn_3 = po
    return pn_3 ~= nil and pn_3.Visible == true
end
local function worker2()
    while not Library.Unloaded do
        task.wait(1.5)
        if lS("AutoUpgrade") then
            pcall(mz)
        end
        if lS("AutoBuyBomb") then
            pcall(mO)
        end
    end
end
local function fn680(bJ)
    local oj = mp()
    if not oj then
        return false
    end
    local ol = os.clock()
    if ol - mc.lastNeedle < 0.35 then
        return true
    end
    mc.lastNeedle = ol
    if not bJ then
        mo(oj.Position + Vector3.new(0, 3, 0))
    end
    lQ(oj:FindFirstChild("NeedlePrompt"))
    mH(oj:FindFirstChild("ClickDetector"))
    return true
end
local function fn684()
    local Character = lW.Character
    local nj = Character and Character:FindFirstChildOfClass("Humanoid")
    return nj
end
local function fn693(aG)
    local nr = l4()
    local ns = not nr or typeof(aG) ~= "Vector3"
    if ns then
        return false
    end
    nr.CFrame = CFrame.new(aG)
    nr.AssemblyLinearVelocity = Vector3.zero
    return true
end
local function worker()
    while not Library.Unloaded do
        local p0 = (lS("AutoPickHay"))
        if not p0 then
            local p1_1 = lS("AutoSellHay") and lO() > 0
            p0 = p1_1
        end
        local p1_2 = p0
        if lS("AutoFindNeedle") then
            pcall(l1, p1_2)
        end
        local p0_1 = lS("AutoSellHay") and lO() > 0
        if p0_1 then
            local p1_3 = mA() or not lS("AutoPickHay")
            p0_1 = p1_3
        end
        if p0_1 then
            pcall(mk)
        elseif lS("AutoPickHay") then
            pcall(mE)
        end
        task.wait(0.08)
    end
end
local function fn774()
    local Main = l0:FindFirstChild("Main")
    local oe = Main and Main:FindFirstChild("SellStand")
    return oe
end
local function worker3()
    while not Library.Unloaded do
        if lS("AutoCreateGame") then
            pcall(lY)
        end
        if lS("AutoStart") then
            pcall(mw)
        end
        task.wait(0.4)
    end
end
local function fn797()
    local Character = lW.Character
    local nm = Character and Character:FindFirstChild("HumanoidRootPart")
    return nm
end
local function fn810()
    local pA = Options.PlayerLimit and Options.PlayerLimit.Value
    local pA_1 = tonumber(pA)
    if pA_1 and pA_1 >= 1 and pA_1 <= 4 then
        return math.floor(pA_1)
    end
    return 1
end
local function fn838()
    lV()
end
local function fn859()
    local nu = tonumber(lW:GetAttribute("Diamonds")) or 0
    return nu
end
local function fn882()
    return mj
end
local function fn892()
    if l7.highlight then
        pcall(function()
            l7.highlight:Destroy()
        end)
        l7.highlight = nil
    end
    if l7.text then
        pcall(function()
            l7.text:Remove()
        end)
        l7.text = nil
    end
end
local function fn895(af, ag)
    return string.format('<font color="%s">%s</font>', ag, af)
end
lO = nil
lP = nil
lQ = nil
lR = nil
lS = nil
lV = nil
lW = nil
lY = nil
l0 = nil
l1 = nil
l3 = nil
l4 = nil
l7 = nil
l9 = nil
mc = nil
DifficultyData = nil
mh = nil
Options = nil
mj = nil
mk = nil
mo = nil
mp = nil
Toggles = nil
mw = nil
local lM, lN, lT, lU, lZ, l_, l2, l5, l6, l8, ma, mb, md, me, mg, HayConfig, mm, mn, mq, ms, mt, mu, BombData, SaveManager, my
mz = nil
mA = nil
mC = nil
mE = nil
mG = nil
mH = nil
Library = nil
mL = nil
Bridge = nil
local mN
mO = nil
mR = nil
local UpgradeData, ThemeManager, mF, mI, mK, mP, mQ, mS
local mU_1
local mV_3
local m4 = if not game:IsLoaded() then 1 else 0
if m4 == 1 then
    game.Loaded:Wait()
end
lM, mU_1, mK, mF, my, mt, mj, md, l8, l5, l0, lW, lP = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local mT = 8
repeat
    local mV_1 = (mT * 4 + 1) % 5 + 1
    if mV_1 <= 3 then
        if mV_1 <= 2 then
            if mV_1 <= 1 then
                local mW_1 = {
                    "xaaydphkm",
                    "tycvaakzvia",
                    "dcywuxneoyc",
                    "kjmtsjh",
                    "cclbh",
                    "mwcijoywog",
                    "cdfwhxbxkrs",
                    "flf",
                    "dsnpm",
                    "nxfywzw",
                    "cnne"
                }
                local ue = mT
                local mX_1 = mW_1[ue % 11 + 1]
                if mX_1:len() >= mX_1:gsub("(.)", "%1%1", ue % 3 % 2 + 1):len() then
                    mt = game:GetService("UserInputService")
                    mF = game:GetService("VirtualUser")
                    my = game:GetService("HttpService")
                else
                    mF = game:GetService("UserInputService")
                    my = game:GetService("VirtualUser")
                    mt = game:GetService("HttpService")
                end
                mT = (mT + 9) % 40
            else
                local mW_2 = { "yyfxfvxv", "sjmczcbcgtk", "oxubgscdu", "mhnbxfai", "ayrwdftxv", "ryikignolf", "ayhafv" }
                local uc = mT
                local mX_2 = mW_2[uc % 7 + 1]
                if mX_2:len() >= mX_2:reverse():rep(uc % 3 + 2):len() then
                    l8 = game:GetService("CoreGui")
                    mj = game:GetService("GuiService")
                    md = game:GetService("TeleportService")
                else
                    mj = game:GetService("CoreGui")
                    md = game:GetService("GuiService")
                    l8 = game:GetService("TeleportService")
                end
                mT = (mT + 24) % 40
            end
        else
            local uh = bit32.rrotate(bit32.bxor(bit32.lrotate(mT, 12), string.byte(tostring(lP))), 8)
            if bit32.bxor(bit32.lrotate(bit32.bxor(uh, 2984514464), 10), 2421064391) ~= bit32.lrotate(uh, 10) then
                l0 = game:GetService("Lighting")
                lW = game:GetService("Workspace")
                lM = lP.LocalPlayer
                l5 = fn882
            else
                l5 = game:GetService("Lighting")
                l0 = game:GetService("Workspace")
                lW = lM.LocalPlayer
                lP = fn882
            end
            mT = (mT + 29) % 40
        end
    elseif mV_1 <= 4 then
        if (mT * 3 + 7) * 5 % 4 == ((mT * 3 + 7) * 5 + 15) % 4 then
            mj = game:GetService("Players")
        else
            lM = game:GetService("Players")
        end
        mT = (mT + 19) % 40
    else
        local mV_2 = {
            "ekgwslbaeo",
            "gtmlrgq",
            "jxlbkcvh",
            "ahengrssxuo",
            "wgndwmfaezs",
            "tezp",
            "ornwbgufxo",
            "mog",
            "clygehoyc",
            "caahkqvlwp"
        }
        local t0 = mT
        local mW_3 = mV_2[t0 % 10 + 1]
        if mW_3:len() <= mW_3:gsub("(.)", "%1%1", t0 % 3 % 2 + 1):len() then
            mU_1 = game:GetService("ReplicatedStorage")
            mK = game:GetService("RunService")
        else
            mK = game:GetService("ReplicatedStorage")
            mU_1 = game:GetService("RunService")
        end
        mT = (mT + 39) % 40
    end
until (mT * 37 + 13) % 40 == 29
if getgenv then
    mN, mV_3 = nil, nil
    local mT_1 = 2
    repeat
        if (mT_1 * 1 + 0) % 2 + 1 <= 1 then
            local tZ = bit32.rrotate(bit32.bxor(bit32.lrotate(mT_1, 17), string.byte(tostring(mN))), 17)
            if bit32.bxor(bit32.lrotate(bit32.bxor(tZ, 1339852362), 12), 3362039037) == bit32.lrotate(tZ, 12) then
                getgenv().gethui = lP
                mN = getgenv().__TempoFindTheNeedleLib
            else
                getgenv().gethui = mN
                lP = getgenv().__TempoFindTheNeedleLib
            end
            mT_1 = (mT_1 + 7) % 8
        else
            local mW_5 = {
                "zruoufenypve",
                "yiflkuxa",
                "yalsprzmwf",
                "qtqqruxl",
                "ybcafkrqts",
                "edb",
                "uakqzgaejuu",
                "slkp",
                "uedjvt",
                "fjbaxnpv",
                "lhqivo"
            }
            if mW_5[(mT_1 * 33 + 35) % 11 + 1] < mW_5[(mT_1 * 33 + 35) % 11 + 1] then
                mN = mV_3
            else
                mV_3 = mN
            end
            mT_1 = (mT_1 + 3) % 8
        end
    until (mT_1 * 5 + 0) % 8 == 4
    if mV_3 then
        mV_3 = mN.Unload
    end
    if mV_3 then
        pcall(function()
            mN:Unload()
        end)
    end
end
pcall(function()
    gethui = lP
end)
if setthreadidentity then
    setthreadidentity(8)
end
mn, mh, ma, l6, l2, lZ, lU, lN, mP, Bridge, UpgradeData, BombData, HayConfig, DifficultyData, l9 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
mn = "Find the Needle"
mh = "https://discord.gg/K7Qxnxkk46"
ma = "https://discord.gg/K7Qxnxkk46"
l6 = "https://tempohub.shop"
l2 = "#7fd47f"
lZ = "#6ec1ff"
lU = "#e8a34d"
lN = "#8b93a3"
mP = "#e05a5a"
Bridge = require(mU_1:WaitForChild("Packages"):WaitForChild("Bridge"))
local GameSettings = require(mU_1:WaitForChild("GameSettings"))
UpgradeData = GameSettings.UpgradeData
BombData = GameSettings.BombData
HayConfig = GameSettings.HayConfig
DifficultyData = GameSettings.DifficultyData
local ClientServices = mU_1:FindFirstChild("ClientServices")
local mY = ClientServices and ClientServices:FindFirstChild("HayClient")
local lX = mY
if lX then
    pcall(function()
        l9 = require(lX)
    end)
end
Library, ThemeManager, SaveManager = nil, nil, nil
Library = getgenv().Library
ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
if getgenv then
    getgenv().__TempoFindTheNeedleLib = Library
end
Toggles, Options, mc, l7, lT, l3, mR, mC, mg, lS, ms, l4, mS, mo, l_, lO, mL, mA, me, lQ, mH, mp, lV, mG, lR, mm, l1, mk, mq, mE, mz, mO, mu, mI, mb, mQ, lY, mw = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Toggles = Library.Toggles
Options = Library.Options
mc = { lastDig = 0, lastSell = 0, lastNeedle = 0, lastSync = 0, lastCreate = 0, lastStart = 0 }
l7 = { highlight = nil, text = nil }
l3 = fn481
mR = fn161
mC = fn895
mg = fn118
lS = fn491
ms = fn684
l4 = fn797
mS = fn429
mo = fn693
l_ = fn859
lO = fn212
mL = fn121
mA = fn432
me = fn359
lQ = function(aZ)
    if not aZ then
        return
    end
    pcall(function()
        aZ.HoldDuration = 0
        aZ.RequiresLineOfSight = false
        aZ.MaxActivationDistance = 1000
    end)
    if fireproximityprompt then
        pcall(fireproximityprompt, aZ)
    end
end
mH = fn622
mp = fn418
lV = fn892
mG = fn367
lR = fn573
mm = fn774
l1 = fn680
mk = function()
    local oq
    oq = nil
    oq = mS("HayBridge")
    if not oq then
        return false
    end
    local ot = mm()
    local ou = l4()
    if ot and ou then
        local Position = ot:GetPivot().Position
        if (ou.Position - Position).Magnitude > 20 then
            mo(Position + Vector3.new(0, 4, 0))
        end
    end
    local ot_1 = os.clock()
    if ot_1 - mc.lastSell < 0.4 then
        return true
    end
    mc.lastSell = ot_1
    pcall(function()
        oq:FireServer("sell")
    end)
    return true
end
mq = function(b3, b4)
    local oE_1
    local oD_1
    local oC_1
    local oB_1
    local oA_1
    if not l9 then
        return nil
    end
    local Renderer = l9.Renderer
    local oz = type(Renderer) ~= "table" or type(Renderer.PartToPiece) ~= "table"
    local oz_1
    if oz then
        return nil
    end
    oB_1, oz_1, oA_1 = nil, nil, nil
    oE_1, oC_1, oD_1 = nil, nil, nil
    for k, v in Renderer.PartToPiece do
        local oy
        local oO = v
        local oF = typeof(k) == "Instance" and k.Parent and type(oO) == "number"
        if oF then
            oy = false
            pcall(function()
                oy = Renderer:IsExposed(oO) == true
            end)
            if oy then
                local Position = k.Position
                local Magnitude = (Position - b3).Magnitude
                if Magnitude <= b4 then
                    if not oz_1 or Magnitude < oz_1 then
                        oB_1 = oO
                        oz_1 = Magnitude
                        oA_1 = Position
                    end
                else
                    if not oC_1 or Magnitude < oC_1 then
                        oE_1 = oO
                        oC_1 = Magnitude
                        oD_1 = Position
                    end
                end
            end
        end
    end
    if oB_1 then
        return oB_1, oA_1, false
    end
    return oE_1, oD_1, true
end
mE = function()
    local oP
    local oV_1
    if not l9 then
        return false
    elseif lW:GetAttribute("HayReady") ~= true then
        local oS_1 = os.clock()
        if oS_1 - mc.lastSync > 2 then
            mc.lastSync = oS_1
            local oQ = mS("HayBridge")
            if oQ then
                pcall(function()
                    oQ:FireServer("sync")
                end)
            end
        end
        return false
    elseif mA() then
        return false
    else
        local oS_2 = l4()
        if not oS_2 then
            return false
        end
        local oT = tonumber(HayConfig.MaxReach) or 45
        local oT_1
        oP, oV_1, oT_1 = mq(oS_2.Position, oT)
        if not oP then
            local Field = l9.Field
            if Field and Field.Center then
                mo(Field.Center + Vector3.new(0, 8, 0))
            end
            return false
        end
        if oT_1 and oV_1 then
            mo(oV_1 + Vector3.new(0, 4, 0))
        end
        local oS_5 = tonumber(HayConfig.AbsoluteMaxDigsPerSecond) or 15
        local oS_6 = 1 / math.max(oS_5, 1)
        local oT_3 = os.clock()
        if oT_3 - mc.lastDig < oS_6 then
            return true
        end
        mc.lastDig = oT_3
        local oR = mS("HayBridge")
        if oR then
            pcall(function()
                oR:FireServer(oP)
            end)
        end
        return true
    end
end
mz = function()
    local o0 = me("UpgradeTypes")
    local o_ = mS("UpgradeBridge")
    if not o_ then
        return
    end
    for k, v in UpgradeData.Order do
        local o7 = v
        if o0[o7] == true then
            pcall(function()
                o_:FireServer(o7)
            end)
        end
    end
end
mO = function()
    local o9 = me("BombTypes")
    local o8 = mS("BombBridge")
    if not o8 then
        return
    end
    local pa = l_()
    for k, v in BombData.ShopOrder do
        local pm = v
        if o9[pm] == true then
            local pb = BombData.Get(pm)
            if pb and pb.Currency == "Diamonds" then
                if pa >= (pb.Price or 0) then
                    pcall(function()
                        o8:FireServer("buy", pm)
                    end)
                end
            else
                pcall(function()
                    o8:FireServer("buy", pm)
                end)
            end
        end
    end
end
mu = fn628
mI = fn242
mb = fn810
mQ = fn32
lY = function()
    local pK
    local pL
    local pO_1
    local pM = mS("QueueBridge")
    if not pM then
        return false
    elseif mu() then
        return true
    else
        local pN = os.clock()
        local pN_1
        if pN - mc.lastCreate < 2 then
            return true
        end
        mc.lastCreate = pN
        pL = mb()
        pK = mI()
        pN_1, pO_1 = mQ(pL)
        local pP = l4()
        if pN_1 then
            mo(pN_1 + Vector3.new(0, 3, 0))
        end
        if firetouchinterest and pO_1 and pP then
            pcall(firetouchinterest, pP, pO_1, 0)
            pcall(firetouchinterest, pP, pO_1, 1)
        end
        pcall(function()
            pM:FireServer("size", pL, pK)
        end)
        return true
    end
end
mw = function()
    local pS
    pS = nil
    pS = mS("QueueBridge")
    if not pS then
        return false
    end
    local pT = os.clock()
    if pT - mc.lastStart < 1 then
        return true
    end
    mc.lastStart = pT
    pcall(function()
        pS:FireServer("start")
    end)
    return true
end
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = mh, Copyable = true }, "|", mn },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    SidebarCompacted = true,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
Window:SetGlow(true, { Color = Color3.fromRGB(255, 105, 180), Radius = 24, Transparency = 0.55 })
lT = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gamepad-2"),
    Lobby = Window:AddTab("Lobby", "door-open"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in lT do
    if k ~= "Info" then
        fn292(v)
    end
end
local AutomationGroup = lT.Main:AddLeftGroupbox("Automation", "bot")
AutomationGroup:AddToggle("AutoFindNeedle", { Text = "Auto Find Needle", Default = false })
AutomationGroup:AddToggle("AutoPickHay", { Text = "Auto Pick Hay", Default = false })
AutomationGroup:AddToggle("AutoSellHay", { Text = "Auto Sell Hay", Default = false })
AutomationGroup:AddDivider("Upgrades")
AutomationGroup:AddToggle("AutoUpgrade", { Text = "Auto Upgrade", Default = false })
AutomationGroup:AddDropdown("UpgradeTypes", {
    Values = UpgradeData.Order,
    Default = { Backpack = true, Cooldown = true, Grab = true },
    Multi = true,
    AllowNull = true,
    Text = "Upgrades"
})
AutomationGroup:AddDivider("Bombs")
AutomationGroup:AddToggle("AutoBuyBomb", { Text = "Auto Buy Bomb", Default = false })
AutomationGroup:AddDropdown("BombTypes", {
    Values = BombData.ShopOrder,
    Default = { Regular = true },
    Multi = true,
    AllowNull = true,
    Text = "Bombs"
})
local VisualsGroup = lT.Main:AddRightGroupbox("Visuals", "eye")
VisualsGroup:AddToggle("NeedleEsp", { Text = "Needle ESP", Default = false })
local LobbyGroup = lT.Lobby:AddLeftGroupbox("Lobby", "users")
if (LobbyGroup and 3) or (LobbyGroup or 3) and (not LobbyGroup) or not ((LobbyGroup and 3) or (LobbyGroup or 3) and (not LobbyGroup)) then
    LobbyGroup:AddToggle("AutoCreateGame", { Text = "Auto Create Game", Default = false })
    LobbyGroup:AddDropdown("LobbyDifficulty", { Values = DifficultyData.Order, Default = "Easy", Multi = false, Text = "Difficulty" })
    LobbyGroup:AddDropdown("PlayerLimit", { Values = { "1", "2", "3", "4" }, Default = "1", Multi = false, Text = "Player Limit" })
    LobbyGroup:AddToggle("AutoStart", { Text = "Auto Start", Default = false })
else
    DifficultyData:AddToggle("AutoCreateGame", { Text = "Auto Create Game", Default = false })
    DifficultyData:AddDropdown("LobbyDifficulty", { Multi = false, Text = "Difficulty", Default = "Easy", Values = LobbyGroup.Order })
    DifficultyData:AddDropdown("PlayerLimit", { Multi = false, Text = "Player Limit", Default = "1", Values = { "3", "1", "4", "2" } })
    DifficultyData:AddToggle("AutoStart", { Text = "Auto Start", Default = false })
end
task.spawn(worker)
mK.RenderStepped:Connect(onRenderStepped)
Toggles.NeedleEsp:OnChanged(fn309)
Library:OnUnload(fn838)
task.spawn(worker2)
task.spawn(worker3)
local function mT_5()
    local q7
    local q6
    q6 = nil
    q7 = nil
    local Label2, Label3, q4, q5, Label
    local function q9()
        local qa = hookfunction ~= nil
        local qb = hookmetamethod ~= nil
        local qc = getrawmetatable ~= nil
        local qd = setrawmetatable ~= nil
        local qe = getgc ~= nil
        local qf = getgenv ~= nil
        local qg = getreg ~= nil
        local qh = getconnections ~= nil
        local qi = firesignal ~= nil
        local qj = getcallbackvalue ~= nil
        local qk = setclipboard ~= nil
        local ql = getcustomasset ~= nil
        local qm = getnamecallmethod ~= nil
        local qn = isexecutorclosure ~= nil
        local qo = fireproximityprompt ~= nil
        local qp = firetouchinterest ~= nil
        local qq = WebSocket ~= nil
        local qr = readfile ~= nil
        local qs = writefile ~= nil
        local qu = (request or http_request) ~= nil
        local qw = (debug and debug.getupvalues) ~= nil
        local qy = (debug and debug.setupvalue) ~= nil
        local qz = 0
        local qA = { qa, qb, qc, qd, qe, qf, qg, qh, qi, qj, qk, ql, qm, qn, qo, qp, qq, qr, qs, qu, qw, qy }
        for i, v in ipairs(qA) do
            if v then
                qz += 1
            end
        end
        local qa_1 = qz / #qA
        if qa_1 >= 0.9 then
            return mC("Full Support", l2)
        elseif qa_1 >= 0.6 then
            return mC("Half Support", lU)
        else
            return mC("Low Support", mP)
        end
    end
    q6 = "Unknown"
    pcall(function()
        local qJ_1
        local qI_1
        if identifyexecutor then
            qJ_1, qI_1 = identifyexecutor()
            local qK = qJ_1 ~= ""
            local qL = type(qJ_1) == "string" and qK
            if qL then
                local qK_1 = type(qI_1) == "string" and qI_1 ~= "" and qJ_1 .. " " .. qI_1
                q6 = qK_1 or qJ_1
            end
        end
    end)
    local ra = q9()
    q7 = os.clock()
    q4 = function()
        local qT = math.floor(os.clock() - q7)
        if qT < 60 then
            return qT .. "s"
        elseif qT < 3600 then
            return string.format("%dm %ds", math.floor((qT) / (60)), qT % 60)
        else
            return string.format("%dh %dm", math.floor((qT) / (3600)), math.floor((qT % 3600) / (60)))
        end
    end
    local UserGroup = lT.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = lW, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(mg("User", lW.DisplayName .. " @" .. lW.Name, l2), true)
    UserGroup:AddLabel(mg("UserId", tostring(lW.UserId), lZ), true)
    UserGroup:AddLabel(mg("Executor", q6 .. "  " .. ra, l2), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(mg("Session", q4(), lU), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            l3(lW.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            l3("https://www.roblox.com/users/" .. tostring(lW.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = lT.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(mg("Game", mn, lZ), true)
    Label2 = SessionGroup:AddLabel(mg("Players", "0/0", l2), true)
    q5 = tostring(game.JobId)
    local ra_1 = #q5 > 18 and string.sub(q5, 1, 18) .. "..."
    local rb = ra_1
    local rf = if rb then 1 else 0
    local rd = 529 * rf + 492 * (1 - rf)
    local re = 2927 * rf + 3547 * (1 - rf)
    if not ((rd * 1416 + re * 972 + rd * re) % 16777213 == 5142491) then
        rb = q5
    end
    local ra_2 = rb
    SessionGroup:AddLabel(mg("Job", ra_2, lN), true)
    Label = SessionGroup:AddLabel(mg("Ping", "0 ms", lU), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            l8:Teleport(game.PlaceId, lW)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            l3(q5, "Copied Job ID")
        end
    })
    task.spawn(function()
        local qZ_1
        local qY_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(mg("Session", q4(), lU))
            Label2:SetText(mg("Players", #lM:GetPlayers() .. "/" .. tostring(lM.MaxPlayers), l2))
            qY_1, qZ_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local qY_2 = qY_1 and qZ_1 .. " ms" or "n/a"
            Label:SetText(mg("Ping", qY_2, lU))
        end
    end)
    local SocialsGroup = lT.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = mR })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            if setclipboard then
                setclipboard(ma)
            elseif toclipboard then
                toclipboard(ma)
            end
            Library:Notify("Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            l3(l6, "Copied website link")
        end
    })
end
local function mU_3()
    local connection
    local MovementGroup = lT.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = lT.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local function f_(f0)
        local rj = if not f0:IsA("ProximityPrompt") then 1 else 0
        if rj == 1 then
            return
        end
        f0.HoldDuration = 0
        f0.MaxActivationDistance = 50
        f0.RequiresLineOfSight = false
    end
    connection = nil
    mK.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = lW.Character
            if Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    local rk_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if rk_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    mF.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local rs_1 = ms()
            if rs_1 then
                rs_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    local CurrentCamera = l0.CurrentCamera
    mK.RenderStepped:Connect(function(gn)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local rx_1 = ms()
            if rx_1 then
                rx_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local rx_3 = l4()
            local ry = ms()
            if rx_3 and ry then
                ry.PlatformStand = true
                local ry_1 = Vector3.zero
                local rD = if mF:IsKeyDown(Enum.KeyCode.W) then 1 else 0
                if rD == 1 then
                    ry_1 = ry_1 + CurrentCamera.CFrame.LookVector
                end
                if mF:IsKeyDown(Enum.KeyCode.S) then
                    ry_1 = ry_1 - CurrentCamera.CFrame.LookVector
                end
                if mF:IsKeyDown(Enum.KeyCode.A) then
                    ry_1 = ry_1 - CurrentCamera.CFrame.RightVector
                end
                if mF:IsKeyDown(Enum.KeyCode.D) then
                    ry_1 = ry_1 + CurrentCamera.CFrame.RightVector
                end
                if mF:IsKeyDown(Enum.KeyCode.Space) then
                    ry_1 = ry_1 + Vector3.new(0, 1, 0)
                end
                if mF:IsKeyDown(Enum.KeyCode.LeftControl) then
                    ry_1 = ry_1 - Vector3.new(0, 1, 0)
                end
                rx_3.Velocity = Vector3.zero
                if ry_1.Magnitude > 0 then
                    rx_3.CFrame = rx_3.CFrame + ry_1.Unit * Options.FlySpeed.Value * gn
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local rE = ms()
            if rE then
                rE.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local rG = ms()
            if rG then
                rG.WalkSpeed = 16
            end
        end
    end)
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in ipairs(l0:GetDescendants()) do
                pcall(f_, descendant)
            end
            connection = l0.DescendantAdded:Connect(function(gP)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(f_, gP)
                end
            end)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    Library:OnUnload(function()
        if connection then
            connection:Disconnect()
        end
    end)
end
local function mY_1()
    local MenuGroup = lT.Settings:AddLeftGroupbox("Menu", "logs")
    local gW = 0
    local gX = tick()
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local Label = MenuGroup:AddLabel("AFK triggers: 0")
    local function gZ()
        local CurrentCamera = l0.CurrentCamera
        if not CurrentCamera then
            return
        end
        my:CaptureController()
        my:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        gW = gW + 1
        gX = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. gW)
        end)
    end
    local connection2 = lW.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(gZ)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local rU = Toggles.AntiAfk.Value and tick() - gX >= 60
            if rU then
                pcall(gZ)
            end
        end
    end)
    MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
    MenuGroup:AddToggle("Disable3D", { Text = "Disable 3D Rendering", Default = false })
    MenuGroup:AddToggle("FpsBoost", { Text = "FPS Boost", Default = false })
    MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    local ScriptGroup = lT.Settings:AddLeftGroupbox("Script", "terminal")
    ScriptGroup:AddButton({
        Text = "Unload Script",
        Func = function()
            Library:Unload()
        end
    })
    local function hn(ho)
        pcall(function()
            md:SetGameplayPausedNotificationEnabled(not ho)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = mj:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not ho
            end
        end)
        if not ho then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(lW, "GameplayPaused", false)
            else
                lW.GameplayPaused = false
            end
        end)
    end
    Toggles.AntiGameplayPause:OnChanged(function()
        hn(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                hn(true)
            end
        end
    end)
    local hF = false
    local function hG()
        local JobId, PlaceId
        if hF then
            return
        end
        hF = true
        PlaceId, JobId = game.PlaceId, game.JobId
        local r2 = pcall(function()
            l8:TeleportToPlaceInstance(PlaceId, JobId, lW)
        end)
        if not r2 then
            pcall(function()
                l8:Teleport(PlaceId, lW)
            end)
        end
    end
    task.spawn(function()
        local RobloxPromptGui = mj:WaitForChild("RobloxPromptGui", 30)
        local r7 = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
        if not r7 then
            return
        end
        r7.ChildAdded:Connect(function(hY)
            if Library.Unloaded then
                return
            end
            if Toggles.AutoReconnect.Value and hY.Name == "ErrorPrompt" then
                hG()
            end
        end)
    end)
    l8.TeleportInitFailed:Connect(function()
        if Toggles.AutoReconnect.Value then
            hF = false
            hG()
        end
    end)
    Toggles.Disable3D:OnChanged(function()
        pcall(function()
            mK:Set3dRenderingEnabled(not Toggles.Disable3D.Value)
        end)
    end)
    local id = {
        ParticleEmitter = true,
        Trail = true,
        Smoke = true,
        Fire = true,
        Sparkles = true,
        Explosion = true,
        Beam = true
    }
    local function ie(ig)
        if id[ig.ClassName] then
            pcall(function()
                ig.Enabled = false
            end)
        end
    end
    local connection
    Toggles.FpsBoost:OnChanged(function()
        if Toggles.FpsBoost.Value then
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            end)
            pcall(function()
                l5.GlobalShadows = false
            end)
            pcall(function()
                l5.FogEnd = 9000000000
            end)
            for i, descendant in ipairs(l0:GetDescendants()) do
                pcall(ie, descendant)
            end
            connection = l0.DescendantAdded:Connect(function(iw)
                if Toggles.FpsBoost.Value then
                    pcall(ie, iw)
                end
            end)
        else
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            end)
            pcall(function()
                l5.GlobalShadows = true
            end)
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end)
    Library:OnUnload(function()
        if connection2 then
            connection2:Disconnect()
        end
        hn(false)
        pcall(function()
            mK:Set3dRenderingEnabled(true)
        end)
        if connection then
            connection:Disconnect()
        end
        if getgenv then
            getgenv().__TempoFindTheNeedleLib = nil
        end
    end)
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("TempoHub")
    ThemeManager:SaveDefault("Evil Hello Kitty")
    ThemeManager:ApplyToTab(lT.Settings)
    ThemeManager:LoadDefault()
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    SaveManager:SetFolder("TempoHub/FindTheNeedle")
    local iG = SaveManager:BuildConfigSection(lT.Settings)
    local function iH(iI, iJ)
        local sl_1 = (iI == "Toggle" and Toggles or Options)[iJ]
        local sk_2 = type(sl_1) == "table" and sl_1.Type == iI
        return sk_2 and sl_1 or nil
    end
    local function iP(iQ, iR)
        local Type = iR.Type
        if Type == "Toggle" then
            return { idx = iQ, type = "Toggle", value = iR.Value == true }
        elseif Type == "Slider" then
            return { idx = iQ, type = "Slider", value = tostring(iR.Value) }
        elseif Type == "Dropdown" then
            return { idx = iQ, type = "Dropdown", multi = iR.Multi == true, value = iR.Value }
        elseif Type == "Input" then
            local sp = iR.Value
            local st = if sp then 1 else 0
            local sr = 1848 * st + 2706 * (1 - st)
            local ss = 2579 * st + 3366 * (1 - st)
            if not ((sr * 920 + ss * 1087 + sr * ss) % 16777213 == 9269525) then
                sp = ""
            end
            return { idx = iQ, type = "Input", text = tostring(sp) }
        elseif Type == "ColorPicker" then
            return { idx = iQ, type = "ColorPicker", value = iR.Value:ToHex(), transparency = iR.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = iQ,
                type = "KeyPicker",
                mode = iR.Mode,
                key = iR.Value,
                modifiers = iR.Modifiers,
                toggled = iR.Toggled
            }
        else
            return nil
        end
    end
    local function iT()
        local sy = {}
        for i, v in ipairs({ Toggles, Options }) do
            for k, v in pairs(v) do
                local sz = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if sz then
                    local sz_1 = iP(k, v)
                    if sz_1 then
                        sy[#sy + 1] = sz_1
                    end
                end
            end
        end
        table.sort(sy, function(i0, i1)
            if i0.type ~= i1.type then
                return i0.type < i1.type
            end
            return i0.idx < i1.idx
        end)
        return { objects = sy }
    end
    local function i2(i3)
        local sP
        sP = nil
        local sQ = type(i3) ~= "table" or type(i3.idx) ~= "string" or type(i3.type) ~= "string"
        local sU = if sQ then 1 else 0
        local sS = 1071 * sU + 2383 * (1 - sU)
        local sT = 3911 * sU + 69 * (1 - sU)
        if not ((sS * 2536 + sT * 2504 + sS * sT) % 16777213 == 16697881) then
            sQ = SaveManager.Ignore[i3.idx]
        end
        if sQ then
            return false
        end
        sP = iH(i3.type, i3.idx)
        if not sP then
            return false
        end
        local sQ_1 = pcall(function()
            if i3.type == "Input" then
                if type(i3.text) ~= "string" then
                    return
                end
                sP:SetValue(i3.text)
            elseif i3.type == "ColorPicker" then
                sP:SetValueRGB(Color3.fromHex(i3.value), i3.transparency)
            elseif i3.type == "KeyPicker" then
                sP:SetValue({ i3.key, i3.mode, i3.modifiers })
                if i3.mode == "Toggle" and i3.toggled ~= nil then
                    sP.Toggled = i3.toggled
                    sP:Update()
                end
            else
                sP:SetValue(i3.value)
            end
        end)
        return sQ_1
    end
    iG:AddDivider()
    iG:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    iG:AddButton("Export Config to Clipboard", function()
        local sW_1
        local sV_1
        sV_1, sW_1 = pcall(mt.JSONEncode, mt, iT())
        if not sV_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local sV_2 = setclipboard or toclipboard
        local sV_3 = type(sV_2) ~= "function" or not pcall(sV_2, sW_1)
        if sV_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    iG:AddButton("Import Config from Clipboard Text", function()
        local s3_1
        local s1 = Options.SaveManager_ImportSource.Value or ""
        local s1_1
        local s2 = tostring(s1):match("^%s*(.-)%s*$")
        if s2 == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        s1_1, s3_1 = pcall(mt.JSONDecode, mt, s2)
        local s2_1 = not s1_1 or type(s3_1) ~= "table" or type(s3_1.objects) ~= "table"
        if s2_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local s1_2 = 0
        for i, v in ipairs(s3_1.objects) do
            if i2(v) then
                s1_2 += 1
            end
        end
        if s1_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local s3_2 = s1_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(s1_2, s3_2), 6)
    end)
    SaveManager:LoadAutoloadConfig()
end
mT_5()
mU_3()
mY_1()
if Toggles.HideUiOnStart.Value then
    Library:Toggle(false)
end
end)(...)

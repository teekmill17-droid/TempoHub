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
getgenv().TempoHoodSubtitle = "PAN THE RIVER"
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
local se_6, se_8, se_14, se_17, se_21
local k6
local lO
local kO
local lv
local lc
local UserInputService
local kU
local CollectionService
local li
local l_
local k_
local lH
local PlayerGui
local k5
local kN
local lu
local lT
local kT
local lA
local lh
local lZ
local kZ
local ln
local k4
local VirtualUser
local kM
local LocalPlayer
local lS
local kS
local lz
local lg
local connection
local lF
local connection5
local l3
local k3
local lL
local ls
local PanConfig
local lR
local Library
local Toggles
local kX
local lE
local ll
local SaveManager
local UpgradeConfig
local lK
local lr
local PanningConfig
local lQ
local kQ
local Workspace
local le
local lW
local connection4
local lk
local l1
local k1
local HttpService
local lq
local connection3
local Label
local kP
local lw
local ld
local Options
local kV
local lj
local connection2
local AutoPanLuck
local lI
local lp
function fns.fn5()
    local oN_1
    local oK = { [PanConfig.DefaultPan] = true }
    local Inventory = LocalPlayer:FindFirstChild("Inventory")
    local oM = Inventory and Inventory:FindFirstChild(PanConfig.InventoryCategory)
    local oM_1
    local oL_1 = oM
    if oM then
        oM = oL_1:IsA("StringValue")
    end
    if oM then
        oM = oL_1.Value ~= ""
    end
    if oM then
        oM_1, oN_1 = pcall(HttpService.JSONDecode, HttpService, oL_1.Value)
        local oL_2 = oM_1 and type(oN_1) == "table"
        if oL_2 then
            for k, v in oN_1 do
                local oL_3 = type(k) == "string" and tonumber(v) and tonumber(v) > 0
                if oL_3 then
                    oK[k] = true
                elseif type(v) == "string" then
                    oK[v] = true
                end
            end
        end
    end
    return oK
end
function fns.fn14()
    local oC = {}
    for k, v in lI() do
        if not lc(v:GetAttribute("Rarity")) then
            oC[#oC + 1] = v
        end
    end
    return oC
end
function fns.onCopyJoinScript_JobID()
    local eK = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, lL)
    lg(eK, "Copied join script to clipboard")
end
function fns.onCopyBitcoinAddress()
    lg(lv, "Copied Bitcoin address")
end
function fns.fn57()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local nv = leaderstats and leaderstats:FindFirstChild("Cash")
    if nv then
        local nv_1 = (tonumber(nv.Value))
        local nA_1 = if nv_1 then 1 else 0
        local ny_1 = 2671 * nA_1 + 1511 * (1 - nA_1)
        local nz_1 = 461 * nA_1 + 1734 * (1 - nA_1)
        if not ((ny_1 * 727 + nz_1 * 285 + ny_1 * nz_1) % 16777213 == 3304533) then
            nv_1 = 0
        end
        return nv_1
    end
    local PrivateStats = LocalPlayer:FindFirstChild("PrivateStats")
    local nv_2 = PrivateStats and PrivateStats:FindFirstChild("Currency")
    local nu_3 = nv_2
    if nv_2 then
        local nw = (tonumber(nu_3.Value))
        local nA_2 = if nw then 1 else 0
        local ny_2 = 2098 * nA_2 + 1407 * (1 - nA_2)
        local nz_2 = 2145 * nA_2 + 2493 * (1 - nA_2)
        if not ((ny_2 * 50 + nz_2 * 2625 + ny_2 * nz_2) % 16777213 == 10235735) then
            nw = 0
        end
        nv_2 = nw
    end
    return nv_2 or 0
end
local function onRscripts()
    lg(lK, "Copied Rscripts profile to clipboard")
end
local function fn87()
    local pz = lQ("AutoBuyUpgrade")
    local pA = lR()
    local Upgrades = LocalPlayer:FindFirstChild("Upgrades")
    if not Upgrades then
        return
    end
    for k, v in lz do
        if pz[v] then
            local pC = lu[v]
            local pD = Upgrades:FindFirstChild(pC)
            if pD then
                local pE = UpgradeConfig.GetLevel(pC, pD.Value)
                if not UpgradeConfig.IsMaxed(pC, pE) then
                    local pD_1 = UpgradeConfig.GetCost(pC, pE)
                    if pA >= pD_1 then
                        lS("UpgradeService", "Purchase", pC)
                        task.wait(0.15)
                        pA = lR()
                    end
                end
            end
        end
    end
end
local function fn95()
    local Equipment = LocalPlayer:FindFirstChild("Equipment")
    local oW = Equipment and Equipment:FindFirstChild(PanConfig.EquipmentKey)
    local oV_1 = oW
    if oW then
        oW = oV_1:IsA("StringValue")
    end
    if oW then
        oW = oV_1.Value ~= ""
    end
    if oW then
        return oV_1.Value
    end
    return PanConfig.DefaultPan
end
local function onRenderStepped(gg)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local qO_1 = kV()
        if qO_1 then
            qO_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local qO_3 = kN()
        local qP = kV()
        local qQ = Workspace.CurrentCamera
        local qV = if qQ then 1 else 0
        local qT = 3074 * qV + 3906 * (1 - qV)
        local qU = 3678 * qV + 3630 * (1 - qV)
        if not ((qT * 3698 + qU * 1439 + qT * qU) % 16777213 == 11189253) then
            qQ = lW
        end
        lW = qQ
        if qO_3 and qP and lW then
            qP.PlatformStand = true
            local qP_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                qP_1 = qP_1 + lW.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                qP_1 = qP_1 - lW.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                qP_1 = qP_1 - lW.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                qP_1 = qP_1 + lW.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                qP_1 = qP_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                qP_1 = qP_1 - Vector3.new(0, 1, 0)
            end
            qO_3.Velocity = Vector3.zero
            if qP_1.Magnitude > 0 then
                qO_3.CFrame = qO_3.CFrame + qP_1.Unit * Options.FlySpeed.Value * gg
            end
        end
    end
end
local function fn105(aE)
    local m7 = Options[aE]
    local m8 = m7 and m7.Value
    local m7_1 = {}
    if type(m8) ~= "table" then
        local m8_1 = m8 ~= ""
        local na = type(m8) == "string" and m8_1
        if na then
            m7_1[m8] = true
        end
        return m7_1
    end
    for k, v in m8 do
        local m8_2 = v == true
        local m9_1 = type(k) == "string" and m8_2
        if m9_1 then
            m7_1[k] = true
        elseif type(v) == "string" then
            m7_1[v] = true
        end
    end
    return m7_1
end
local function onInputBegan()
    k_ = tick()
end
local function fn159(cr)
    local ct = lQ("KeepRarities")
    return ct[cr] == true
end
local function fn168()
    Library.ScreenGui.Parent = PlayerGui
end
local function fn175()
    local py = if not kP("AutoSell") then 1 else 0
    if py == 1 then
        return false
    end
    local ps = k1()
    local pt = lk("AutoSellMode", lH)
    if pt == lE then
        local pt_1 = #ps
        local pu = tonumber(lk("AutoSellCount", 10)) or 10
        return pt_1 >= pu
    end
    return #ps > 0
end
local function fn199()
    lg(lO, "Copied Discord invite to clipboard")
end
local function worker4()
    while not Library.Unloaded do
        if kP("AutoBuyUpgrades") then
            pcall(lT)
        end
        if kP("AutoBuyPans") then
            pcall(kZ)
        end
        task.wait(0.6)
    end
end
local function fn203(ab, ac, ad)
    return string.format("<b>%s</b> %s %s", ab, kT("-", "#5a6070"), kT(ac, ad))
end
local function onImportConfigFromClipboardTex()
    local rR_1
    local rP = Options.SaveManager_ImportSource.Value or ""
    local rP_1
    local rQ = tostring(rP):match("^%s*(.-)%s*$")
    if rQ == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    rP_1, rR_1 = pcall(HttpService.JSONDecode, HttpService, rQ)
    local rQ_1 = not rP_1 or type(rR_1) ~= "table" or type(rR_1.objects) ~= "table"
    if rQ_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local rP_2 = 0
    for i, v in ipairs(rR_1.objects) do
        if ld(v) then
            rP_2 += 1
        end
    end
    if rP_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local rR_2 = rP_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(rP_2, rR_2), 6)
end
local function fn244()
    kQ(false)
    local r9 = ll("PanningController")
    if r9 then
        r9._autoPan = false
    end
    connection:Disconnect()
    connection2:Disconnect()
    connection3:Disconnect()
    connection4:Disconnect()
    connection5:Disconnect()
    k6(false)
    local r9_1 = kV()
    if r9_1 then
        r9_1.PlatformStand = false
        r9_1.WalkSpeed = 16
    end
end
local function worker2()
    while not Library.Unloaded do
        if lp then
            task.wait(0.15)
            continue
        end
        if kP("AutoPerfectPan") then
            pcall(lw, ll("PanningController"))
        end
        task.wait(0.2)
    end
end
local function fn260(aN, aO)
    local nl = Options[aN]
    if nl == nil or nl.Value == nil then
        return aO
    end
    return nl.Value
end
local function fn270()
    for k, v in CollectionService:GetTagged("LiveProximityPrompt") do
        local nW_1 = v:IsA("ProximityPrompt") and v:GetAttribute("Action") == "Sell"
        if nW_1 then
            return v
        end
    end
    local Game = Workspace:FindFirstChild("Game")
    local nX = Game and Game:FindFirstChild("ScriptingProperties")
    local nW_3 = nX
    if nX then
        nX = nW_3:FindFirstChild("_nodes")
    end
    local nW_4 = nX
    if nX then
        nX = nW_4:FindFirstChild("_shops")
    end
    local nW_5 = nX
    if nX then
        nX = nW_5:FindFirstChild("Sell")
    end
    local nW_6 = nX
    if nX then
        nX = nW_6:FindFirstChildWhichIsA("ProximityPrompt", true)
    end
    return nX
end
local function fn276()
    local rl = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local rm = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if rm then
                local rm_1 = kO(k, v)
                if rm_1 then
                    rl[#rl + 1] = rm_1
                end
            end
        end
    end
    table.sort(rl, function(hd, he)
        if hd.type ~= he.type then
            return hd.type < he.type
        end
        return hd.idx < he.idx
    end)
    return { objects = rl }
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local qJ_1 = kV()
        if qJ_1 then
            qJ_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn304()
    kQ(Toggles.AutoPerfectPan.Value)
    if not Toggles.AutoPerfectPan.Value then
        local qc = ll("PanningController")
        if qc then
            qc._autoPan = false
        end
    end
end
local function fn305()
    k6(Toggles.AntiGameplayPause.Value)
end
local function fn334()
    Library.ScreenGui.Parent = PlayerGui
end
local function fn353()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    kU = tick()
end
local function fn358(R, S)
    if setclipboard then
        setclipboard(R)
    elseif toclipboard then
        toclipboard(R)
    end
    Library:Notify(S)
end
local function onCopyVenmoLink()
    lg(lh, "Copied Venmo link")
end
local function fn390(cd)
    local op = kN()
    if not (op and cd) then
        return false
    end
    op.AssemblyLinearVelocity = Vector3.zero
    op.CFrame = cd
    return true
end
local function onCopyEthereumAddress()
    lg(ls, "Copied Ethereum address")
end
local function worker3()
    while not Library.Unloaded do
        local qi = kP("AutoSell") and kX()
        if qi and not lp then
            lp = true
            local qi_1 = ll("PanningController")
            pcall(l_, qi_1)
            pcall(k5)
            lp = false
        end
        task.wait(0.35)
    end
end
local function fn441(gS, gT)
    local q8_1 = (gS == "Toggle" and Toggles or Options)[gT]
    local q7_2 = type(q8_1) == "table" and q8_1.Type == gS
    return q7_2 and q8_1 or nil
end
local function fn466()
    local no = k4()
    local np = no and no:FindFirstChildOfClass("Humanoid")
    return np
end
local function onCopySolanaAddress()
    lg(lj, "Copied Solana address")
end
local function onExportConfigToClipboard()
    local rJ_1
    local rI_1
    rI_1, rJ_1 = pcall(HttpService.JSONEncode, HttpService, lZ())
    if not rI_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local rI_2 = setclipboard or toclipboard
    local rI_3 = type(rI_2) ~= "function"
    local rO = if rI_3 then 1 else 0
    local rM = 3688 * rO + 1618 * (1 - rO)
    local rN = 3455 * rO + 327 * (1 - rO)
    if not ((rM * 1598 + rN * 2292 + rM * rN) % 16777213 == 9777111) then
        rI_3 = not pcall(rI_2, rJ_1)
    end
    if rI_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function onCopyPayPalLink()
    lg(li, "Copied PayPal link")
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in Character:GetDescendants() do
                local qy_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if qy_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function fn521(bR)
    if not bR then
        return nil
    end
    local Parent = bR.Parent
    local n8 = Parent and Parent:IsA("BasePart")
    if n8 then
        return Parent.CFrame + Vector3.new(0, 3, 0)
    end
    local n8_1 = Parent and Parent:IsA("Model")
    if n8_1 then
        return Parent:GetPivot() * CFrame.new(0, 3, 0)
    end
    return nil
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            k6(true)
        end
    end
end
local function worker()
    local qa_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local p9 = math.floor(os.clock() - lr)
        if p9 < 60 then
            qa_1 = p9 .. "s"
        elseif p9 < 3600 then
            qa_1 = string.format("%dm %ds", math.floor((p9) / (60)), p9 % 60)
        else
            qa_1 = string.format("%dh %dm", math.floor((p9) / (3600)), math.floor((p9 % 3600) / (60)))
        end
        Label:SetText(kM("Session time", qa_1, lF))
    end
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local r2 = tick() - k_
            local r3 = tick() - kU
            if r2 >= 300 and r3 >= 60 then
                pcall(l1)
            else
                if r2 < 300 and r3 >= 300 then
                    pcall(l1)
                end
            end
        end
    end
end
local function fn570()
    gethui = function()
        return PlayerGui
    end
end
local function fn618()
    local pQ_1
    local pP_2
    local pM = l3()
    local pN = lR()
    local Name
    for k, v in lq do
        if v.Price > 0 and not pM[v.Name] and pN >= v.Price then
            pP_2, pQ_1 = lS("PanShopService", "Purchase", v.Name)
            local pR = pP_2 and type(pQ_1) == "table" and pQ_1.status == "Success"
            if pR then
                Name = v.Name
                pM[v.Name] = true
                break
            end
        end
    end
    local pP_3 = Name and le() ~= Name
    if pP_3 then
        lS("PanShopService", "Equip", Name)
    end
end
local function onCopyLitecoinAddress()
    lg(lA, "Copied Litecoin address")
end
local function fn636(et)
    local DiscordGroup = et:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = k3 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = k3 })
end
local function onCopyUSDTAddress()
    lg(ln, "Copied USDT address")
end
local function fn653(ay)
    if Library.Unloaded then
        return false
    end
    local m4 = Toggles[ay]
    return m4 ~= nil and m4.Value == true
end
local function fn670()
    local p2_1
    local p1_1
    if identifyexecutor then
        p2_1, p1_1 = identifyexecutor()
        local p3 = p2_1 ~= ""
        local p4 = type(p2_1) == "string" and p3
        if p4 then
            local p3_1 = type(p1_1) == "string" and p1_1 ~= "" and p2_1 .. " " .. p1_1
            kS = p3_1 or p2_1
        end
    end
end
local function fn673()
    local oi_1
    local od = PanningConfig.ResolveRegion()
    if not od then
        return nil
    end
    local oe = od.Size / 2
    local of = PanningConfig.EdgeAxis == "Z"
    local oh = PanningConfig.EdgeSign < 0 and -1 or 1
    local EdgeInset = PanningConfig.EdgeInset
    if of then
        oi_1 = Vector3.new(0, 0, oh * math.max(0, oe.Z - EdgeInset))
    else
        oi_1 = Vector3.new(oh * math.max(0, oe.X - EdgeInset), 0, 0)
    end
    local oe_1 = oi_1
    local of_1 = od.CFrame:PointToWorldSpace(oe_1)
    local oe_2 = RaycastParams.new()
    oe_2.FilterType = Enum.RaycastFilterType.Exclude
    local og_2 = k4()
    oe_2.FilterDescendantsInstances = { og_2, od }
    local od_1 = Workspace:Raycast(of_1 + Vector3.new(0, 20, 0), Vector3.new(0, -80, 0), oe_2)
    local od_2 = od_1 and od_1.Position or of_1
    return CFrame.new(od_2 + Vector3.new(0, 3, 0))
end
local function fn678()
    return LocalPlayer.Character
end
local function fn700()
    if not Toggles.Fly.Value then
        local qr = kV()
        if qr then
            qr.PlatformStand = false
        end
    end
end
local function fn813()
    local nr = k4()
    local ns = nr and nr:FindFirstChild("HumanoidRootPart")
    return ns
end
local function onInputChanged(gK)
    local UserInputType = gK.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        k_ = tick()
    end
end
local function fn852(Y, Z)
    return string.format('<font color="%s">%s</font>', Z, Y)
end
local function fn889(cX)
    if cX then
        PanningConfig.AutoPanLuck = PanningConfig.LuckMax
    else
        PanningConfig.AutoPanLuck = AutoPanLuck
    end
end
local function fn917(g_, g0)
    local Type = g0.Type
    if Type == "Toggle" then
        return { idx = g_, type = "Toggle", value = g0.Value == true }
    elseif Type == "Slider" then
        return { idx = g_, type = "Slider", value = tostring(g0.Value) }
    elseif Type == "Dropdown" then
        return { idx = g_, type = "Dropdown", multi = g0.Multi == true, value = g0.Value }
    elseif Type == "Input" then
        local rf = g0.Value
        local rj = if rf then 1 else 0
        local rh = 248 * rj + 3225 * (1 - rj)
        local ri = 3785 * rj + 3260 * (1 - rj)
        if not ((rh * 2414 + ri * 3033 + rh * ri) % 16777213 == 13017257) then
            rf = ""
        end
        return { idx = g_, type = "Input", text = tostring(rf) }
    elseif Type == "ColorPicker" then
        return { idx = g_, type = "ColorPicker", value = g0.Value:ToHex(), transparency = g0.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = g_,
            type = "KeyPicker",
            mode = g0.Mode,
            key = g0.Value,
            modifiers = g0.Modifiers,
            toggled = g0.Toggled
        }
    else
        return nil
    end
end
local function onUnload()
    Library:Unload()
end
local function fn987()
    if not Toggles.WalkSpeedEnabled.Value then
        local qt = kV()
        if qt then
            qt.WalkSpeed = 16
        end
    end
end
kM = nil
kN = nil
kO = nil
kP = nil
kQ = nil
Library = nil
kS = nil
kT = nil
kU = nil
kV = nil
kX = nil
connection = nil
kZ = nil
k_ = nil
AutoPanLuck = nil
k1 = nil
UpgradeConfig = nil
k3 = nil
k4 = nil
k5 = nil
k6 = nil
connection3 = nil
PanningConfig = nil
PanConfig = nil
lc = nil
ld = nil
le = nil
lg = nil
lh = nil
li = nil
lj = nil
lk = nil
ll = nil
connection5 = nil
ln = nil
PlayerGui = nil
lp = nil
lq = nil
lr = nil
ls = nil
LocalPlayer = nil
lu = nil
lv = nil
lw = nil
Workspace = nil
local kW, la, Knit, lf, ly
lz = nil
lA = nil
CollectionService = nil
connection4 = nil
lE = nil
lF = nil
lH = nil
lI = nil
HttpService = nil
lK = nil
lL = nil
VirtualUser = nil
lO = nil
Label = nil
lQ = nil
lR = nil
lS = nil
lT = nil
UserInputService = nil
Options = nil
lW = nil
Toggles = nil
lZ = nil
l_ = nil
connection2 = nil
l1 = nil
SaveManager = nil
l3 = nil
local CoreGui, GuiService, lN, lY
CoreGui = nil
GuiService = nil
lN = nil
lY = nil
local GameInfoGroup, mo, mp, mq
UserInputService, VirtualUser, HttpService, GuiService, CoreGui, CollectionService, Workspace, LocalPlayer, PlayerGui = nil, nil, nil, nil, nil, nil, nil, nil, nil
local se_7 = game:GetService("Players")
local se_1 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
CollectionService = game:GetService("CollectionService")
Workspace = game:GetService("Workspace")
LocalPlayer = se_7.LocalPlayer
PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if getgenv then
    getgenv().gethui = function()
        return PlayerGui
    end
end
Knit, PanConfig, PanningConfig, UpgradeConfig, AutoPanLuck, Library = nil, nil, nil, nil, nil, nil
pcall(fn570)
local se_18 = "Pan The River"
Knit = require(se_1:WaitForChild("Packages"):WaitForChild("Knit"))
PanConfig = require(se_1:WaitForChild("Modules"):WaitForChild("Shops"):WaitForChild("PanConfig"))
PanningConfig = require(se_1:WaitForChild("Modules"):WaitForChild("Panning"):WaitForChild("PanningConfig"))
UpgradeConfig = require(se_1:WaitForChild("Modules"):WaitForChild("Upgrades"):WaitForChild("UpgradeConfig"))
AutoPanLuck = PanningConfig.AutoPanLuck
Library = getgenv().Library
pcall(fn168)
if setthreadidentity then
    setthreadidentity(8)
end
SaveManager, Toggles, Options, lO, lK, lH, lE, lz, lu, lq = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
lO = "https://discord.gg/K7Qxnxkk46"
lK = "https://discord.gg/K7Qxnxkk46"
lH = "Always"
lE = "Count"
local Rarities = PanningConfig.Rarities
lz = { "Luck Multiplier", "Value Multiplier" }
lu = { ["Luck Multiplier"] = "LuckMultiplier", ["Value Multiplier"] = "ValueMultiplier" }
lq = PanConfig.GetAllPans()
se_1 = {}
for k, v in lq do
    se_1[#se_1 + 1] = v.Name
end
lF, lA, lv, ls, ln, lj, li, lh, lp, lg, k3, kT, kM, kP, lQ, lk, k4, kV, kN, lR, ll, kW, lS, la, lN, ly, lY, lI, lc, k1, l3, le, kQ, l_, lw, k5, kX, lT, kZ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
lg = fn358
k3 = fn199
kT = fn852
kM = fn203
local mm = "#7fd47f"
local ml = "#6ec1ff"
lF = "#e8a34d"
local se_5 = "#8b93a3"
lA = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
lv = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
ls = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
ln = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
lj = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
li = ""
lh = ""
local se_13 = "#345d9d"
local se_2 = "#f7931a"
if (l3 and not l3 or (lp or lp)) and (lp or not l3 or (l3 or l3)) or not ((l3 and not l3 or (lp or lp)) and (lp or not l3 or (l3 or l3))) then
    se_17 = "#627eea"
    se_8 = "#26a17b"
    se_21 = "#14f195"
    se_14 = "#0070ba"
    se_6 = "#008cff"
else
    se_21 = "#627eea"
    se_17 = "#26a17b"
    se_6 = "#14f195"
    se_8 = "#0070ba"
    se_14 = "#008cff"
end
kP = fn653
lQ = fn105
lk = fn260
k4 = fn678
kV = fn466
kN = fn813
lR = fns.fn57
ll = function(bb)
    local nC_1
    local nB_1
    nB_1, nC_1 = pcall(function()
        return Knit.GetController(bb)
    end)
    local nD = nB_1 and type(nC_1) == "table"
    if nD then
        return nC_1
    end
    return nil
end
kW = function(bj)
    local nG_1
    local nF_1
    nF_1, nG_1 = pcall(function()
        return Knit.GetService(bj)
    end)
    local nH = nF_1 and type(nG_1) == "table"
    if nH then
        return nG_1
    end
    return nil
end
lS = function(br, bs, ...)
    local nN
    local nO
    local nM
    nM = nil
    nN = nil
    nO = nil
    local nR_1
    local nQ_1
    local nP_1
    nO = kW(br)
    if not nO then
        return false, nil
    end
    nM = nO[bs]
    if type(nM) ~= "function" then
        return false, nil
    end
    nN = table.pack(...)
    nP_1, nQ_1, nR_1 = pcall(function()
        return nM(nO, table.unpack(nN, 1, nN.n)):await()
    end)
    if not nP_1 then
        return false, nil
    end
    return nQ_1, nR_1
end
la = fn270
lN = fn521
ly = fn673
lY = fn390
lI = function()
    local ch
    ch = {}
    local function ci(cj)
        if not cj then
            return
        end
        for i, child in cj:GetChildren() do
            local ou = child:IsA("Tool") and typeof(child:GetAttribute("Rarity")) == "string"
            if ou then
                ch[#ch + 1] = child
            end
        end
    end
    ci(LocalPlayer:FindFirstChild("Backpack"))
    ci(k4())
    return ch
end
lc = fn159
k1 = fns.fn14
l3 = fns.fn5
le = fn95
kQ = fn889
l_ = function(c0)
    if not c0 then
        return
    end
    c0._autoPan = false
    if not (c0._inStance or c0._panning or c0._inRegion or c0._entering) then
        return
    end
    pcall(function()
        c0:_requestExit()
    end)
    local oZ_1 = os.clock() + 8
    while true do
        local o_ = os.clock() < oZ_1 and not Library.Unloaded
        if o_ then
            if not c0._inStance and not c0._panning and not c0._exiting and not c0._entering then
                break
            end
            task.wait(0.1)
            continue
        end
        break
    end
end
lw = function(c8)
    if not c8 then
        return
    end
    kQ(true)
    if c8._active then
        c8._fill = 1
        pcall(function()
            c8:_collect()
        end)
        return
    end
    if c8._panning or c8._entering or c8._exiting then
        if c8._inStance then
            c8._autoPan = true
        end
        return
    end
    if not c8._inRegion then
        lY(ly())
        return
    end
    if not c8._inStance then
        pcall(function()
            c8:_enterStance()
        end)
        return
    end
    c8._autoPan = true
    pcall(function()
        c8:_beginPanCycle()
    end)
end
k5 = function()
    local pd = k1()
    local pd_2
    if #pd == 0 then
        return false
    end
    local pe = la()
    if not pe then
        return false
    end
    local pf = lQ("KeepRarities")
    local pf_1
    local pg = next(pf) ~= nil
    local pg_1, pg_2
    lY(lN(pe))
    task.wait(0.2)
    if not pg then
        pf_1, pg_1 = lS("SellService", "SellAll", pe)
        local ph_1 = pf_1 and type(pg_1) == "table" and pg_1.status == "Success"
        return ph_1
    end
    local pf_2 = false
    local pc = kV()
    for k, v in pd do
        local pr = v
        local pd_1 = Library.Unloaded or not kP("AutoSell")
        if pd_1 then
            break
        elseif not not pr.Parent then
            if pc then
                pcall(function()
                    pc:EquipTool(pr)
                end)
                task.wait(0.12)
            end
            pd_2, pg_2 = lS("SellService", "SellEquipped", pe)
            local ph_2 = pd_2 and type(pg_2) == "table" and pg_2.status == "Success"
            if ph_2 then
                pf_2 = true
            end
            task.wait(0.08)
        end
    end
    return pf_2
end
kX = fn175
lT = fn87
kZ = fn618
lp = false
local se_15 = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = lO, Copyable = true }, "|", se_18 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
pcall(fn334)
local se_19 = {
    Info = se_15:AddTab("Info", "info"),
    Main = se_15:AddTab("Main", "pickaxe"),
    Player = se_15:AddTab("Player", "person-standing"),
    Settings = se_15:AddTab("Settings", "settings")
}
local se_20 = fn636
for k, v in se_19 do
    se_20(v)
end
kS, se_15, GameInfoGroup, Label, lL, se_1 = nil, nil, nil, nil, nil, nil
se_7 = 5
repeat
    se_20 = (se_7 * 2 + 0) % 3 + 1
    if se_20 <= 2 then
        if se_20 <= 1 then
            local s3 = bit32.rrotate(bit32.bxor(bit32.lrotate(se_7, 8), string.byte(tostring(kS))), 25)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(s3, 869263585), 2420423429), (bit32.bxor(bit32.band(s3, 3425703710), 1413670397))), 2420423429), 1413670397) == s3 then
                se_1 = #lL > 18
            else
                lL = #se_1 > 18
            end
            se_7 = (se_7 + 2) % 24
        else
            se_20 = (vector.create((se_7 * 7 + 6) % 11 + 1, (se_7 * 5 + 2) % 13 + 1, (se_7 * 14 + 6) % 17 + 1))
            mo = (vector.create((se_7 * 4 + 6) % 11 + 1, (se_7 * 11 + 3) % 13 + 1, (se_7 * 6 + 4) % 17 + 1))
            mp = (vector.create((se_7 * 7 + 7) % 11 + 1, (se_7 * 4 + 13) % 13 + 1, (se_7 * 10 + 9) % 17 + 1))
            mq = (vector.create((se_7 * 6 + 3) % 11 + 1, (se_7 * 3 + 6) % 13 + 1, (se_7 * 7 + 12) % 17 + 1))
            if vector.dot(vector.cross(se_20, mo), (vector.cross(mp, mq))) == vector.dot(se_20, mp) * vector.dot(mo, mq) - vector.dot(se_20, mq) * vector.dot(mo, mp) then
                kS = "Unknown"
                pcall(fn670)
                se_15 = se_19.Info:AddLeftGroupbox("Account", "circle-user")
                se_15:AddLabel(kM("User", LocalPlayer.Name, mm), true)
                se_15:AddLabel(kM("Status", "Keyless", mm), true)
                se_15:AddLabel(kM("Executor", kS, mm), true)
                GameInfoGroup = se_19.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                GameInfoGroup:AddLabel(kT(se_18 .. " [" .. tostring(game.PlaceId) .. "]", ml), true)
                GameInfoGroup:AddLabel(kM("Place ID", tostring(game.PlaceId), ml), true)
                Label = GameInfoGroup:AddLabel(kM("Session time", "0s", lF), true)
            else
                mm = "Unknown"
                pcall(fn670)
                ml = GameInfoGroup.Info:AddLeftGroupbox("Account", "circle-user")
                ml:AddLabel(LocalPlayer("User", kS.Name, kM), true)
                ml:AddLabel(LocalPlayer("Status", "Keyless", kM), true)
                ml:AddLabel(LocalPlayer("Executor", "Unknown", kM), true)
                kT = GameInfoGroup.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                kT:AddLabel(se_19(lF .. " [" .. tostring(game.PlaceId) .. "]", Label), true)
                kT:AddLabel(LocalPlayer("Place ID", tostring(game.PlaceId), Label), true)
                se_18 = kT:AddLabel(LocalPlayer("Session time", "0s", se_15), true)
            end
            se_7 = (se_7 + 11) % 24
        end
    else
        se_20 = { "vknuyemookj", "xcpnqyn", "trwikt", "pvquykivspzo", "trscxnk", "gjj", "sepbcebqyu", "jkqo" }
        if se_20[(se_7 * 5 + 91) % 8 + 1] < se_20[(se_7 * 5 + 91) % 8 + 1] then
            se_1 = tostring(game.JobId)
        else
            lL = tostring(game.JobId)
        end
        se_7 = (se_7 + 23) % 24
    end
until (se_7 * 1 + 5) % 24 == 22
if se_1 then
    se_7 = 0
    repeat
        se_15 = {
            "oiqvncytjbyb",
            "yjlnxx",
            "sqq",
            "hfet",
            "muuquqbzcdr",
            "ctxrd",
            "yjvysc",
            "yyhfv",
            "xgj",
            "opymtplnw",
            "ctvpu",
            "kaybhqtf",
            "rpnwltmiqifu",
            "avqhf"
        }
        if se_15[(se_7 * 96 + 79) % 14 + 1] < se_15[(se_7 * 96 + 79) % 14 + 1] then
            lL = string.sub(se_1, 1, 18) .. "..."
        else
            se_1 = string.sub(lL, 1, 18) .. "..."
        end
        se_7 = (se_7 + 3) % 4
    until (se_7 * 1 + 3) % 4 == 2
end
se_7 = se_1 or lL
lr, connection, connection2, lW, connection3, k_, kU, connection4, connection5, k6, l1, lf, kO, lZ, ld = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local mA = se_7
GameInfoGroup:AddLabel(kM("Server", mA, se_5), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
lr = os.clock()
task.spawn(worker)
local ScriptsGroup = se_19.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(kT("Included in this hub", se_5), true)
ScriptsGroup:AddLabel(kT(se_18, ml), true)
mp = se_19.Info:AddRightGroupbox("Features", "list")
mp:AddLabel(kT("Auto Farm", ml), true)
mp:AddLabel(kT("Auto Sell", lF), true)
mp:AddLabel(kT("Auto Buy", se_5), true)
se_20 = se_19.Info:AddRightGroupbox("Socials", "link")
se_20:AddButton({ Text = "Discord", Func = k3 })
se_20:AddButton({ Text = "Rscripts", Func = onRscripts })
se_1 = se_19.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
se_1:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
se_1:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
se_1:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
se_1:AddButton({ Text = "Copy Discord Invite", Func = k3 })
se_15 = se_19.Info:AddRightGroupbox("Donations", "heart")
se_15:AddLabel(kT("All donations are optional but appreciated.", lF), true)
se_15:AddLabel(kT("If you donate you get a special role, just PING after you donate.", mm), true)
se_15:AddDivider()
se_15:AddLabel(kT("LTC / Litecoin", se_13), true)
se_15:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
se_15:AddLabel(kT("BTC / Bitcoin", se_2), true)
se_15:AddButton({ Text = "Copy Bitcoin Address", Func = fns.onCopyBitcoinAddress })
se_15:AddLabel(kT("ETH / Ethereum", se_17), true)
se_15:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
se_15:AddLabel(kT("USDT", se_8), true)
se_15:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
se_15:AddLabel(kT("Solana", se_21), true)
se_15:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
se_15:AddLabel(kT("PayPal", se_14), true)
se_15:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
se_15:AddLabel(kT("Venmo", se_6), true)
se_15:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
se_15:AddDivider()
se_15:AddLabel(kT("Don't have any of the listed currencies but still wanna donate?", se_5), true)
se_15:AddLabel(kT("DM me and we'll work something out.", ml), true)
local FaqGroup = se_19.Info:AddRightGroupbox("FAQ", "circle-help")
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
local PanningGroup = se_19.Main:AddLeftGroupbox("Panning", "waves")
PanningGroup:AddToggle("AutoPerfectPan", { Text = "Auto Perfect Pan", Default = false })
local SellGroup = se_19.Main:AddLeftGroupbox("Sell", "circle-dollar-sign")
SellGroup:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
SellGroup:AddDropdown("AutoSellMode", { Text = "When", Values = { lH, lE }, Default = lH })
SellGroup:AddSlider("AutoSellCount", { Text = "Item Count", Default = 10, Min = 1, Max = 200, Rounding = 0 })
SellGroup:AddDropdown("KeepRarities", {
    Text = "Keep Rarities",
    Values = Rarities,
    Default = {},
    Multi = true,
    Expandable = true,
    ExpandColumns = 2
})
local UpgradesGroup = se_19.Main:AddRightGroupbox("Upgrades", "trending-up")
UpgradesGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
UpgradesGroup:AddDropdown("AutoBuyUpgrade", {
    Text = "Upgrade",
    Values = lz,
    Default = { "Luck Multiplier" },
    Multi = true,
    Expandable = true,
    ExpandColumns = 1
})
local PansGroup = se_19.Main:AddRightGroupbox("Pans", "shopping-bag")
PansGroup:AddToggle("AutoBuyPans", { Text = "Auto Buy Pans", Default = false })
mq = se_19.Player:AddLeftGroupbox("Movement", "footprints")
mq:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
mq:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
mq:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
mq:AddToggle("NoClip", { Text = "NoClip", Default = false })
mq:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
mo = se_19.Player:AddRightGroupbox("Fly", "feather")
mo:AddToggle("Fly", { Text = "Fly", Default = false })
mo:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
Toggles.AutoPerfectPan:OnChanged(fn304)
task.spawn(worker2)
task.spawn(worker3)
task.spawn(worker4)
k6 = function(fJ)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not fJ)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not fJ
        end
    end)
    if not fJ then
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
Toggles.AntiGameplayPause:OnChanged(fn305)
Toggles.Fly:OnChanged(fn700)
Toggles.WalkSpeedEnabled:OnChanged(fn987)
connection = RunService.Stepped:Connect(onStepped)
connection2 = UserInputService.JumpRequest:Connect(onJumpRequest)
lW = Workspace.CurrentCamera
connection3 = RunService.RenderStepped:Connect(onRenderStepped)
local MenuGroup = se_19.Settings:AddLeftGroupbox("Menu", "menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
k_ = tick()
kU = tick()
pcall(function()
    for k, v in getconnections(LocalPlayer.Idled) do
        local q1 = v
        pcall(function()
            q1:Disable()
        end)
    end
end)
l1 = fn353
connection4 = UserInputService.InputBegan:Connect(onInputBegan)
connection5 = UserInputService.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", onUnload)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(se_19.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/PanTheRiver")
local mz = SaveManager:BuildConfigSection(se_19.Settings)
lf = fn441
kO = fn917
lZ = fn276
ld = function(hg)
    local rF
    rF = nil
    local rG = type(hg) ~= "table" or type(hg.idx) ~= "string" or type(hg.type) ~= "string" or SaveManager.Ignore[hg.idx]
    if rG then
        return false
    end
    rF = lf(hg.type, hg.idx)
    if not rF then
        return false
    end
    local rG_1 = pcall(function()
        if hg.type == "Input" then
            if type(hg.text) ~= "string" then
                return
            end
            rF:SetValue(hg.text)
        elseif hg.type == "ColorPicker" then
            rF:SetValueRGB(Color3.fromHex(hg.value), hg.transparency)
        elseif hg.type == "KeyPicker" then
            rF:SetValue({ hg.key, hg.mode, hg.modifiers })
            if hg.mode == "Toggle" and hg.toggled ~= nil then
                rF.Toggled = hg.toggled
                rF:Update()
            end
        else
            rF:SetValue(hg.value)
        end
    end)
    return rG_1
end
mz:AddDivider()
mz:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
mz:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
mz:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
task.spawn(antiGameplayPauseLoop)
task.spawn(antiAfkLoop)
Library:OnUnload(fn244)
Library:Notify(se_18 .. " loaded")
end)(...)

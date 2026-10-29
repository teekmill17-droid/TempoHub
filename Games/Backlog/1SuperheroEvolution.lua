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
getgenv().TempoHoodSubtitle = "+1 SUPERHERO EVOLUTION"
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
local wd_2, GameInfoGroup, wd_7, wd_9, wd_11, wd_13, wd_15, wd_26, wd_29, wd_32, wd_34, wd_44, wd_47
local ol
local o4
local n1
local connection
local nJ
local ot
local n7
local LocalPlayer
local nw
local od
local RebirthConfig
local nV
local Workspace
local Label
local oj
local o3
local n0
local CoreGui
local nI
local oq
local n6
local oR
local nO
local oy
local oc
local oX
local nU
local oE
local nB
local oi
local UserInputService
local n_
local oK
local nH
local op
local o8
local RequestTrain
local oQ
local nN
local ox
local ob
local oW
local nT
local CollectionService
local nA
local o1
local nZ
local oJ
local nG
local oo
local o7
local n4
local oP
local nM
local ow
local oa
local oV
local nS
local oC
local nz
local connection3
local nY
local oI
local connection2
local o6
local n3
local ov
local n9
local oU
local nR
local oB
local ny
local connection4
local o_
local connection5
local oH
local nE
local Options
local o5
local n2
local Id
local nK
local ou
local n8
local oT
local nQ
local oA
local oe
local oZ
local RequestAttack
function fns.fn22(dE)
    local sF = dE and dE.Wins
    local sG = op(sF)
    local sF_1 = nil
    for i, v in ipairs(oQ) do
        local sH = not nS(dE, v.Id) and v.UnlockCost > 0 and sG >= v.UnlockCost
        if sH then
            if not sF_1 or v.Id < sF_1.Id then
                sF_1 = v
            end
        end
    end
    return sF_1
end
function fns.fn34()
    local s8 = oV("HatchEggSelect") or oA[1]
    local s9 = tostring(s8)
    return ou[s9]
end
function fns.onCopyEthereumAddress()
    n7(ot, "Copied Ethereum address")
end
function fns.antiAfkLoop()
    while not oU.Unloaded do
        task.wait(2)
        if oq.AntiAfk.Value then
            local vj = tick() - o4
            local vk = tick() - o1
            if vj >= 300 and vk >= 60 then
                pcall(oE)
            else
                if vj < 300 and vk >= 300 then
                    pcall(oE)
                end
            end
        end
    end
end
function fns.worker7()
    while not oU.Unloaded do
        if nE("AutoHatchEggs") then
            pcall(oe)
            task.wait(oC("HatchDelay", 0.5))
        else
            if Id then
                oK(Id, false)
                Id = nil
            end
            task.wait(0.25)
        end
    end
end
function fns.fn113(ez)
    local th_1
    local tg_1
    th_1, tg_1 = oI(ez)
    if not th_1 then
        return
    end
    if tg_1 then
        n1(tg_1)
        task.wait(0.08)
    end
    n1(th_1)
end
function fns.onStepped()
    if oU.Unloaded then
        return
    end
    if oq.NoClip and oq.NoClip.Value then
        local uy_1 = n9()
        if uy_1 then
            for i, descendant in ipairs(uy_1:GetDescendants()) do
                local uy_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if uy_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
function fns.fn137(aq, ar)
    local qt = ou[aq]
    local qu = ou[ar]
    return (qt and qt.Cost or 0) < (qu and qu.Cost or 0)
end
function fns.fn157()
    pcall(function()
        RequestAttack:FireServer()
    end)
    pcall(function()
        n_:FireServer()
    end)
end
function fns.worker4()
    while not oU.Unloaded do
        local uo = nE("AutoTrain") and not nE("AutoWin")
        if uo then
            pcall(nB)
            task.wait(oC("TrainDelay", 0.05))
        else
            task.wait(0.2)
        end
    end
end
function fns.onImportConfigFromClipboardTex()
    local vZ_1
    local vX = Options.SaveManager_ImportSource.Value
    local vX_1
    local v2 = if vX then 1 else 0
    local v0 = 323 * v2 + 2968 * (1 - v2)
    local v1 = 186 * v2 + 620 * (1 - v2)
    if not ((v0 * 281 + v1 * 3584 + v0 * v1) % 16777213 == 817465) then
        vX = ""
    end
    local vY = tostring(vX):match("^%s*(.-)%s*$")
    if vY == "" then
        oU:Notify("Paste an exported config into the box first")
        return
    end
    vX_1, vZ_1 = pcall(oR.JSONDecode, oR, vY)
    local vY_1 = not vX_1 or type(vZ_1) ~= "table" or type(vZ_1.objects) ~= "table"
    if vY_1 then
        oU:Notify("That config could not be read")
        return
    end
    local vX_2 = 0
    for i, v in ipairs(vZ_1.objects) do
        if oa(v) then
            vX_2 += 1
        end
    end
    if vX_2 == 0 then
        oU:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local vZ_2 = vX_2 == 1 and "" or "s"
    oU:Notify(("Imported %d setting%s"):format(vX_2, vZ_2), 6)
end
function fns.fn193()
    local vz = {}
    for i, v in ipairs({ oq, Options }) do
        for k, v in pairs(v) do
            local vA = type(v) == "table" and type(v.Type) == "string" and not ow.Ignore[k]
            if vA then
                local vA_1 = nM(k, v)
                if vA_1 then
                    vz[#vz + 1] = vA_1
                end
            end
        end
    end
    table.sort(vz, function(jB, jC)
        if jB.type ~= jC.type then
            return jB.type < jC.type
        end
        return jB.idx < jC.idx
    end)
    return { objects = vz }
end
function fns.antiGameplayPauseLoop()
    while not oU.Unloaded do
        task.wait(1)
        if oq.AntiGameplayPause.Value then
            oy(true)
        end
    end
end
function fns.fn230(df)
    local si = tonumber(df)
    local sj
    local Map = Workspace:FindFirstChild("Map")
    for i, v in ipairs(CollectionService:GetTagged("ItemStand")) do
        if tonumber(v:GetAttribute("ItemId")) == si then
            local sl = Map and v:IsDescendantOf(Map)
            if sl then
                return v
            end
            sj = sj or v
        end
    end
    return sj
end
function fns.onJumpRequest()
    if oU.Unloaded then
        return
    end
    if oq.InfJump and oq.InfJump.Value then
        local uG_1 = n3()
        if uG_1 then
            uG_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
function fns.fn237(jp, jq)
    local Type = jq.Type
    if Type == "Toggle" then
        return { idx = jp, type = "Toggle", value = jq.Value == true }
    elseif Type == "Slider" then
        return { idx = jp, type = "Slider", value = tostring(jq.Value) }
    elseif Type == "Dropdown" then
        return { idx = jp, type = "Dropdown", multi = jq.Multi == true, value = jq.Value }
    elseif Type == "Input" then
        local vw = jq.Value or ""
        return { idx = jp, type = "Input", text = tostring(vw) }
    elseif Type == "ColorPicker" then
        return { idx = jp, type = "ColorPicker", value = jq.Value:ToHex(), transparency = jq.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = jp,
            type = "KeyPicker",
            mode = jq.Mode,
            key = jq.Value,
            modifiers = jq.Modifiers,
            toggled = jq.Toggled
        }
    else
        return nil
    end
end
function fns.onCopyUSDTAddress()
    n7(oo, "Copied USDT address")
end
function fns.onCopyVenmoLink()
    n7(n8, "Copied Venmo link")
end
function fns.fn257(aO, aP)
    if setclipboard then
        setclipboard(aO)
    elseif toclipboard then
        toclipboard(aO)
    end
    oU:Notify(aP)
end
function fns.fn275(jh, ji)
    local vp_1 = (jh == "Toggle" and oq or Options)[ji]
    local vo_2 = type(vp_1) == "table" and vp_1.Type == jh
    return vo_2 and vp_1 or nil
end
function fns.fn278()
    local qU = n9()
    local qV = qU and qU:FindFirstChildOfClass("Humanoid")
    return qV
end
function fns.worker3()
    while not oU.Unloaded do
        if nE("AutoClick") then
            pcall(nU)
            task.wait(oC("ClickDelay", 0.05))
        else
            task.wait(0.2)
        end
    end
end
function fns.onCopyPayPalLink()
    n7(od, "Copied PayPal link")
end
function fns.worker5()
    while not oU.Unloaded do
        if nE("AutoBuyHeroes") then
            pcall(oc)
            task.wait(oC("BuyHeroDelay", 0.5))
        else
            task.wait(0.25)
        end
    end
end
function fns.fn306(c_)
    local rZ = oV("TrainZone") or "Best Available"
    local r_ = tostring(rZ)
    if r_ ~= "Best Available" then
        return nT[r_] or 1
    end
    local rZ_2 = c_ and c_.Rebirths
    local r__1 = (tonumber(rZ_2))
    local r5 = if r__1 then 1 else 0
    local r3 = 2879 * r5 + 2024 * (1 - r5)
    local r4 = 3456 * r5 + 1058 * (1 - r5)
    if not ((r3 * 2186 + r4 * 1695 + r3 * r4) % 16777213 == 5324025) then
        r__1 = 0
    end
    local rZ_3 = -1
    local r0 = 1
    local r1 = r__1
    for i, v in ipairs(nQ) do
        if v.RebirthRequirement > 0 and v.RebirthRequirement <= r1 and v.Multiplier >= rZ_3 then
            rZ_3 = v.Multiplier
            r0 = v.Id
        end
    end
    if rZ_3 < 0 then
        for i, v in ipairs(nQ) do
            if v.RebirthRequirement == 0 and v.Multiplier >= rZ_3 and v.Multiplier <= 1 then
                rZ_3 = v.Multiplier
                r0 = v.Id
            end
        end
    end
    return r0
end
function fns.fn312()
    if not oq.WalkSpeedEnabled.Value then
        local uY = n3()
        if uY then
            uY.WalkSpeed = 16
        end
    end
end
function fns.fn316(cQ)
    local rN = nO()
    if not rN or not cQ then
        return false
    end
    rN.AssemblyLinearVelocity = Vector3.zero
    rN.AssemblyAngularVelocity = Vector3.zero
    rN.CFrame = cQ.CFrame + Vector3.new(0, 3, 0)
    return true
end
function fns.onCopyJoinScript_JobID()
    local gE = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, nz)
    n7(gE, "Copied join script to clipboard")
end
function fns.fn335()
    local tR = o5(true)
    if not tR then
        return
    end
    local tS = nZ(tR)
    if not tS then
        return
    end
    local tR_1 = nY(tS.Id)
    if not tR_1 then
        return
    end
    o_(tR_1)
    o5(true)
end
function fns.fn339(ce, cf, cg)
    local rj = not ce
    local ro = if rj then 1 else 0
    local rm = 2831 * ro + 672 * (1 - ro)
    local rn = 771 * ro + 3212 * (1 - ro)
    if not ((rm * 137 + rn * 1305 + rm * rn) % 16777213 == 3576703) then
        rj = type(ce.CompletedStages) ~= "table"
    end
    if rj then
        return false
    end
    local rj_1 = ce.CompletedStages[cf] or ce.CompletedStages[tostring(cf)]
    if type(rj_1) ~= "table" then
        return false
    end
    local rj_2 = rj_1[cg] == true or rj_1[tostring(cg)] == true
    return rj_2
end
function fns.fn346()
    if not oq.AutoHatchEggs.Value and Id then
        oK(Id, false)
        Id = nil
    end
end
function fns.worker()
    local uk_1
    while true do
        task.wait(1)
        if oU.Unloaded then
            break
        end
        local uj = math.floor(os.clock() - oP)
        if uj < 60 then
            uk_1 = uj .. "s"
        elseif uj < 3600 then
            uk_1 = string.format("%dm %ds", math.floor((uj) / (60)), uj % 60)
        else
            uk_1 = string.format("%dh %dm", math.floor((uj) / (3600)), math.floor((uj % 3600) / (60)))
        end
        Label:SetText(o8("Session time", uk_1, oJ))
    end
end
function fns.fn371(bv, bw)
    local qO = Options[bv]
    if qO and qO.Value ~= nil then
        local qP_1 = tonumber(qO.Value) or bw
        return qP_1
    end
    return bw
end
function fns.fn396()
    local rp = oV("WinStage") or nH[1]
    local rq = tostring(rp)
    local rp_1 = tonumber(string.match(rq, "Stage (%d+)")) or 1
    return rp_1
end
function fns.fn397()
    local uc_1
    local ub_1
    if identifyexecutor then
        uc_1, ub_1 = identifyexecutor()
        local ud = uc_1 ~= ""
        local ue = type(uc_1) == "string" and ud
        if ue then
            local ud_1 = type(ub_1) == "string" and ub_1 ~= "" and uc_1 .. " " .. ub_1
            local ub_2 = ud_1
            local ui = if ub_2 then 1 else 0
            local ug = 57 * ui + 1959 * (1 - ui)
            local uh = 2642 * ui + 1199 * (1 - ui)
            if not ((ug * 3969 + uh * 3375 + ug * uh) % 16777213 == 9293577) then
                ub_2 = uc_1
            end
            n4 = ub_2
        end
    end
end
function fns.fn408(bN)
    local q3_1
    local q2 = not bN
    local q2_1
    if q2 ~= false then
        q2 = nw
    end
    if q2 then
        q2 = os.clock() - o6 < 0.35
    end
    if q2 then
        return nw
    end
    q2_1, q3_1 = pcall(function()
        return n6:InvokeServer()
    end)
    local q4 = q2_1 and type(q3_1) == "table"
    if q4 then
        nw = q3_1
        o6 = os.clock()
        return q3_1
    end
    return nw
end
function fns.fn421(b9)
    for i, v in ipairs(CollectionService:GetTagged("Stage")) do
        if tonumber(v:GetAttribute("Stage")) == b9 then
            return v
        end
    end
    return nil
end
function fns.fn449()
    if not oq.Fly.Value then
        local uW = n3()
        if uW then
            uW.PlatformStand = false
        end
    end
end
function fns.fn452(gn)
    local DiscordGroup = gn:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = nV })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = nV })
end
function fns.worker6()
    while not oU.Unloaded do
        if nE("AutoRebirth") then
            pcall(nJ)
            task.wait(oC("RebirthDelay", 1))
        else
            task.wait(0.25)
        end
    end
end
function fns.onUnload()
    oU:Unload()
end
local function fn507(O, P)
    return O.Id < P.Id
end
local function fn514()
    local qy_1
    local qx_1
    if typeof(gethui) == "function" then
        qx_1, qy_1 = pcall(gethui)
        if qx_1 and qy_1 then
            return qy_1
        end
        return CoreGui
    end
    return CoreGui
end
local function fn518()
    if Id then
        oK(Id, false)
        Id = nil
    end
    connection:Disconnect()
    connection2:Disconnect()
    connection3:Disconnect()
    connection4:Disconnect()
    connection5:Disconnect()
    oy(false)
    select("#", "Unloaded!")
end
local function fn528(cr, cs)
    local rs = {}
    for i, v in ipairs(CollectionService:GetTagged("Stage")) do
        local rt = tonumber(v:GetAttribute("Stage"))
        local ru = tonumber(v:GetAttribute("World"))
        if rt and ru and rt <= cs then
            table.insert(rs, { Folder = v, Stage = rt, World = ru })
        end
    end
    table.sort(rs, function(cA, cB)
        return cA.Stage < cB.Stage
    end)
    for i, v in ipairs(rs) do
        if not oT(cr, v.World, v.Stage) then
            return v
        end
    end
    return nil
end
local function fn529()
    local qB = nA()
    if syn and syn.protect_gui then
        syn.protect_gui(oU.ScreenGui)
    elseif protect_gui then
        protect_gui(oU.ScreenGui)
    end
    oU.ScreenGui.Parent = qB
end
local function fn561(Q, R)
    local qi = (tonumber(string.match(Q, "^(%d+)")))
    local qo = if qi then 1 else 0
    local qm = 12 * qo + 2767 * (1 - qo)
    local qn = 1896 * qo + 353 * (1 - qo)
    if not ((qm * 2883 + qn * 2359 + qm * qn) % 16777213 == 4530012) then
        qi = 0
    end
    local qj = qi
    local qi_1 = tonumber(string.match(R, "^(%d+)")) or 0
    return qj < qi_1
end
local function fn573(ag, ah)
    if ag == "Best Available" then
        return true
    elseif ah == "Best Available" then
        return false
    else
        local qp = tonumber(string.match(ag, "Zone (%d+)")) or 0
        local qp_1 = tonumber(string.match(ah, "Zone (%d+)")) or 0
        return qp < qp_1
    end
end
local function onExportConfigToClipboard()
    local vU_1
    local vT_1
    vT_1, vU_1 = pcall(oR.JSONEncode, oR, o7())
    if not vT_1 then
        oU:Notify("Failed to encode the config")
        return
    end
    local vT_2 = setclipboard or toclipboard
    local vT_3 = type(vT_2) ~= "function" or not pcall(vT_2, vU_1)
    if vT_3 then
        oU:Notify("Your executor does not support copying to the clipboard")
        return
    end
    oU:Notify("Config copied to clipboard", 6)
end
local function fn595()
    return LocalPlayer.Character
end
local function fn621()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    oX:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    oX:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    o1 = tick()
end
local function onCopyLitecoinAddress()
    n7(oB, "Copied Litecoin address")
end
local function onCopySolanaAddress()
    n7(oj, "Copied Solana address")
end
local function fn693()
    n7(oi, "Copied Discord invite to clipboard")
end
local function fn697()
    local q_ = n9()
    local q0 = q_ and q_:FindFirstChild("HumanoidRootPart")
    return q0
end
local function fn698(d3)
    local s_ = oV("BuyHeroMode") or "Next Affordable"
    local s0 = tostring(s_)
    if s0 == "Best Affordable" then
        return oW(d3)
    elseif s0 == "Selected Hero" then
        local s__1 = oV("BuyHeroSelect") or ""
        local s0_1 = tostring(s__1)
        local s__2 = oH[s0_1]
        if not s__2 then
            return nil
        end
        for i, v in ipairs(oQ) do
            if v.Id == s__2 then
                if nS(d3, v.Id) then
                    return nil
                end
                local s0_2 = d3 and d3.Wins
                if op(s0_2) >= v.UnlockCost then
                    return v
                end
                return nil
            end
        end
        return nil
    else
        return n2(d3)
    end
end
local function fn700()
    local tI = o5()
    if not tI then
        return
    end
    local tJ = o3(tI)
    local tI_1 = nN(tJ) or nN(1)
    if not tI_1 then
        return
    end
    local Hitbox = tI_1:FindFirstChild("Hitbox")
    if Hitbox then
        n1(Hitbox)
    else
        local BasePart = tI_1:FindFirstChildWhichIsA("BasePart", true)
        if BasePart then
            n1(BasePart)
        end
    end
    pcall(function()
        RequestTrain:FireServer()
    end)
    pcall(function()
        n_:FireServer()
    end)
end
local function onCopyBitcoinAddress()
    n7(ox, "Copied Bitcoin address")
end
local function fn719(aY, aZ, a_)
    return string.format("<b>%s</b> %s %s", aY, nK("-", "#5a6070"), nK(aZ, a_))
end
local function fn722(bk)
    if oU.Unloaded then
        return false
    end
    local qF = oq[bk]
    return qF ~= nil and qF.Value == true
end
local function onInputBegan()
    o4 = tick()
end
local function fn733()
    local tE = o5(true)
    if not tE then
        return
    end
    local tF = ol()
    local tG = n0(tE, tF)
    if tG then
        oZ(tG)
        return
    end
    nG(tF)
end
local function fn748()
    local tU = o5(true)
    if not tU then
        return
    end
    local tV = tonumber(tU.Rebirths) or 0
    local tV_1 = RebirthConfig.getThreshold(tV)
    local tW_1 = tonumber(tU.Level) or 0
    if tW_1 < tV_1 then
        return
    end
    pcall(function()
        nR:InvokeServer()
    end)
    o5(true)
end
local function fn753(bq)
    local qL = Options[bq]
    return qL and qL.Value or nil
end
local function fn764(cU)
    local rR = tostring(cU)
    for i, v in ipairs(CollectionService:GetTagged("TrainingZone")) do
        if tostring(v:GetAttribute("ZoneId")) == rR then
            return v
        end
    end
    return nil
end
local function onRenderStepped(hZ)
    if oU.Unloaded then
        return
    end
    nI = Workspace.CurrentCamera
    if oq.WalkSpeedEnabled and oq.WalkSpeedEnabled.Value then
        local uL_1 = n3()
        if uL_1 then
            uL_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if oq.Fly and oq.Fly.Value then
        local uL_3 = nO()
        local uM = n3()
        if uL_3 and uM and nI then
            uM.PlatformStand = true
            local uM_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                uM_1 += nI.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                uM_1 -= nI.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                uM_1 -= nI.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                uM_1 += nI.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                uM_1 += Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                uM_1 -= Vector3.new(0, 1, 0)
            end
            uL_3.AssemblyLinearVelocity = Vector3.zero
            if uM_1.Magnitude > 0 then
                uL_3.CFrame = uL_3.CFrame + uM_1.Unit * Options.FlySpeed.Value * hZ
            end
        end
    end
end
local function onRscripts()
    n7(ob, "Copied Rscripts profile to clipboard")
end
local function onInputChanged(iT)
    local UserInputType = iT.UserInputType
    local ve = UserInputType == Enum.UserInputType.MouseMovement
    local vi = if ve then 1 else 0
    local vg = 1261 * vi + 2782 * (1 - vi)
    local vh = 44 * vi + 3319 * (1 - vi)
    if not ((vg * 776 + vh * 3272 + vg * vh) % 16777213 == 1177988) then
        ve = UserInputType == Enum.UserInputType.Gamepad1
    end
    if ve then
        o4 = tick()
    end
end
local function fn799(b4, b5)
    if not b4 or not b4.UnlockedItems then
        return false
    end
    local ra_1 = b4.UnlockedItems[tostring(b5)] == true or b4.UnlockedItems[b5] == true
    return ra_1
end
local function fn810()
    oy(oq.AntiGameplayPause.Value)
end
local function fn812(aV, aW)
    return string.format('<font color="%s">%s</font>', aW, aV)
end
local function worker2()
    while not oU.Unloaded do
        if nE("AutoWin") then
            pcall(ov)
            task.wait(oC("WinDelay", 0.35))
        else
            task.wait(0.2)
        end
    end
end
local function fn858(dQ)
    local sP = dQ and dQ.Wins
    local sQ = op(sP)
    local sP_1 = nil
    for i, v in ipairs(oQ) do
        local sR = not nS(dQ, v.Id) and v.UnlockCost > 0 and sQ >= v.UnlockCost
        if sR then
            if not sP_1 or v.Gain > sP_1.Gain or v.Gain == sP_1.Gain and v.Id > sP_1.Id then
                sP_1 = v
            end
        end
    end
    return sP_1
end
local function fn969(ae, af)
    return ae.Id < af.Id
end
local function fn987(cG)
    local rJ = ny(cG)
    if not rJ then
        return nil, nil
    end
    local Pad = rJ:FindFirstChild("Pad")
    local rL = Pad and Pad:FindFirstChild("Free")
    local rK_1 = rL
    if rL then
        rL = rK_1:FindFirstChild("Pad")
    end
    local rK_2 = rL
    local Spawn = rJ:FindFirstChild("Spawn")
    return rK_2, Spawn
end
nw = nil
ny = nil
nz = nil
nA = nil
nB = nil
Label = nil
nE = nil
nG = nil
nH = nil
nI = nil
nJ = nil
nK = nil
nM = nil
nN = nil
nO = nil
nQ = nil
nR = nil
nS = nil
nT = nil
nU = nil
nV = nil
RequestAttack = nil
connection5 = nil
nY = nil
nZ = nil
n_ = nil
n0 = nil
n1 = nil
n2 = nil
n3 = nil
n4 = nil
RequestTrain = nil
n6 = nil
n7 = nil
n8 = nil
n9 = nil
oa = nil
ob = nil
oc = nil
od = nil
oe = nil
connection4 = nil
oi = nil
local AlyaNum, AutoHatch, HatchEgg, nL, nP, og, oh
oj = nil
ol = nil
Options = nil
connection2 = nil
oo = nil
op = nil
oq = nil
ot = nil
ou = nil
ov = nil
ow = nil
ox = nil
oy = nil
LocalPlayer = nil
oA = nil
oB = nil
oC = nil
CollectionService = nil
oE = nil
Workspace = nil
oH = nil
oI = nil
oJ = nil
oK = nil
CoreGui = nil
connection = nil
Id = nil
oP = nil
oQ = nil
oR = nil
oT = nil
oU = nil
oV = nil
oW = nil
oX = nil
RebirthConfig = nil
oZ = nil
o_ = nil
connection3 = nil
o1 = nil
UserInputService = nil
o3 = nil
o4 = nil
o5 = nil
o6 = nil
o7 = nil
o8 = nil
local oG, GuiService, oS
UserInputService, oX, oR, GuiService, CoreGui, Workspace, CollectionService, LocalPlayer = nil, nil, nil, nil, nil, nil, nil, nil
local wd_21 = game:GetService("Players")
local wd_39 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
if (not Workspace or not CoreGui or (wd_39 or CoreGui)) and ((wd_39 or Workspace) and (not wd_39 or not wd_39)) and not ((not Workspace or not CoreGui or (wd_39 or CoreGui)) and ((wd_39 or Workspace) and (not wd_39 or not wd_39))) then
    oR = game:GetService("VirtualUser")
    oX = game:GetService("HttpService")
else
    oX = game:GetService("VirtualUser")
    oR = game:GetService("HttpService")
end
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
CollectionService = game:GetService("CollectionService")
LocalPlayer = wd_21.LocalPlayer
if setthreadidentity then
    setthreadidentity(8)
end
wd_13, wd_26, wd_9, wd_7, wd_21, n6, RequestTrain, n_, RequestAttack, nR, nP, nL, HatchEgg, AutoHatch, AlyaNum, wd_11, wd_44, wd_29, RebirthConfig, oS, oQ, wd_47, oH = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local wd_41 = 6
repeat
    wd_32 = (wd_41 * 11 + 5) % 14 + 1
    if wd_32 <= 7 then
        if wd_32 <= 4 then
            if wd_32 <= 2 then
                if wd_32 <= 1 then
                    if (wd_41 * 2 + 1) * 4 % 3 == ((wd_41 * 2 + 1) * 4 + 2) % 3 then
                        wd_47 = require(oH:WaitForChild("Client"):WaitForChild("EnemyRenderController"))
                        oS = {}
                        wd_39 = {}
                        oQ = {}
                    else
                        oS = require(wd_39:WaitForChild("Client"):WaitForChild("EnemyRenderController"))
                        oQ = {}
                        wd_47 = {}
                        oH = {}
                    end
                    wd_41 = (wd_41 + 23) % 112
                else
                    wd_15 = (vector.create((wd_41 * 1 + 6) % 11 + 1, (wd_41 * 4 + 9) % 13 + 1, (wd_41 * 8 + 16) % 17 + 1))
                    wd_2 = (vector.create((wd_41 * 4 + 3) % 11 + 1, (wd_41 * 5 + 1) % 13 + 1, (wd_41 * 2 + 10) % 17 + 1))
                    wd_34 = (vector.create((wd_41 * 2 + 3) % 5 + 1, (wd_41 * 3 + 5) % 7 + 1, (wd_41 * 5 + 4) % 9 + 1))
                    if math.abs((vector.angle(wd_15, wd_2, wd_34))) - math.abs((vector.angle(wd_2, wd_15, wd_34))) == 0 then
                        wd_13 = "+1 Superhero Evolution"
                    else
                        nR = "+1 Superhero Evolution"
                    end
                    wd_41 = (wd_41 + 93) % 112
                end
            elseif wd_32 <= 3 then
                local xF = bit32.rrotate(bit32.bxor(bit32.lrotate(wd_41, 19), string.byte(tostring(wd_11))), 6)
                if bit32.bxor(bit32.lrotate(bit32.bxor(xF, 3728454767), 26), 3212373713) == bit32.lrotate(xF, 26) then
                    wd_26 = wd_39:WaitForChild("Shared")
                else
                    wd_39 = wd_26:WaitForChild("Shared")
                end
                wd_41 = (wd_41 + 51) % 112
            else
                if (wd_41 * 3 + 3) * 9 % 4 == ((wd_41 * 3 + 3) * 9 + 8) % 4 then
                    wd_9 = wd_26:WaitForChild("Remotes")
                else
                    wd_26 = wd_9:WaitForChild("Remotes")
                end
                wd_41 = (wd_41 + 37) % 112
            end
        elseif wd_32 <= 6 then
            if wd_32 <= 5 then
                wd_15 = {
                    "daxsmhcxg",
                    "meltmvoo",
                    "kazrryxxi",
                    "bsxz",
                    "koujz",
                    "ekzpcl",
                    "raazv",
                    "azpnhpf",
                    "nxokjpv",
                    "ceq",
                    "nmf"
                }
                local w0 = wd_41
                wd_2 = wd_15[w0 % 11 + 1]
                if wd_2:len() <= wd_2:gsub("(.)", "%1%1", w0 % 3 % 2 + 1):len() then
                    wd_7 = wd_26:WaitForChild("Config")
                else
                    wd_26 = wd_7:WaitForChild("Config")
                end
                wd_41 = (wd_41 + 51) % 112
            else
                wd_15 = (vector.create((wd_41 * 7 + 7) % 11 + 1, (wd_41 * 9 + 6) % 13 + 1, (wd_41 * 4 + 3) % 17 + 1))
                wd_2 = (vector.create((wd_41 * 2 + 1) % 11 + 1, (wd_41 * 8 + 10) % 13 + 1, (wd_41 * 12 + 8) % 17 + 1))
                wd_34 = (vector.create((wd_41 * 4 + 1) % 5 + 1, (wd_41 * 5 + 3) % 7 + 1, (wd_41 * 3 + 6) % 9 + 1))
                if math.abs((vector.angle(wd_15, wd_2, wd_34))) - math.abs((vector.angle(wd_2, wd_15, wd_34))) == 4 then
                    wd_39 = wd_21:WaitForChild("Packages")
                else
                    wd_21 = wd_39:WaitForChild("Packages")
                end
                wd_41 = (wd_41 + 65) % 112
            end
        else
            if wd_41 * 48259305 + 12 + 3 <= wd_41 * 48259305 + 12 + 3 + 1 then
                n6 = wd_9:WaitForChild("GetData")
                RequestTrain = wd_9:WaitForChild("RequestTrain")
            else
                wd_9 = RequestTrain:WaitForChild("GetData")
                n6 = RequestTrain:WaitForChild("RequestTrain")
            end
            wd_41 = (wd_41 + 51) % 112
        end
    elseif wd_32 <= 11 then
        if wd_32 <= 9 then
            if wd_32 <= 8 then
                local wP = bit32.rrotate(bit32.bxor(bit32.lrotate(wd_41, 24), string.byte(tostring(nR))), 5)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(wP, 3792898837), 484600770), (bit32.bxor(bit32.band(wP, 502068458), 4183923698))), 484600770), 4183923698) == wP then
                    n_ = wd_9:WaitForChild("PlayerClick")
                    RequestAttack = wd_9:WaitForChild("RequestAttack")
                else
                    wd_9 = RequestAttack:WaitForChild("PlayerClick")
                    n_ = RequestAttack:WaitForChild("RequestAttack")
                end
                wd_41 = (wd_41 + 107) % 112
            else
                if (not oH and wd_44 and (wd_44 or wd_44) and ((not AutoHatch or not wd_9) and (not oH or AutoHatch)) or (not wd_44 or wd_44 or (wd_44 or wd_26)) and (not AutoHatch and AutoHatch and (not nL and oH)) or (wd_26 and not wd_9 or (wd_26 or not wd_44) or (not oH or not wd_26 or nL and not wd_44)) and (not nL or wd_26 or wd_9 and not wd_44 or wd_9 and not oH and (wd_26 and AutoHatch))) and not (not oH and wd_44 and (wd_44 or wd_44) and ((not AutoHatch or not wd_9) and (not oH or AutoHatch)) or (not wd_44 or wd_44 or (wd_44 or wd_26)) and (not AutoHatch and AutoHatch and (not nL and oH)) or (wd_26 and not wd_9 or (wd_26 or not wd_44) or (not oH or not wd_26 or nL and not wd_44)) and (not nL or wd_26 or wd_9 and not wd_44 or wd_9 and not oH and (wd_26 and AutoHatch))) then
                    nL = HatchEgg:WaitForChild("RequestRebirth")
                    nR = HatchEgg:WaitForChild("RequestWorldChange")
                    wd_9 = HatchEgg:WaitForChild("TryPurchaseEgg")
                    nP = HatchEgg:WaitForChild("HatchEgg")
                else
                    nR = wd_9:WaitForChild("RequestRebirth")
                    nP = wd_9:WaitForChild("RequestWorldChange")
                    nL = wd_9:WaitForChild("TryPurchaseEgg")
                    HatchEgg = wd_9:WaitForChild("HatchEgg")
                end
                wd_41 = (wd_41 + 23) % 112
            end
        elseif wd_32 <= 10 then
            if (wd_41 * 2 + 7) * 13 % 3 == ((wd_41 * 2 + 7) * 13 + 8) % 3 then
                wd_9 = AlyaNum:WaitForChild("AutoHatch")
                wd_21 = require(AutoHatch:WaitForChild("AlyaNum"))
            else
                AutoHatch = wd_9:WaitForChild("AutoHatch")
                AlyaNum = require(wd_21:WaitForChild("AlyaNum"))
            end
            wd_41 = (wd_41 + 37) % 112
        else
            local xv = bit32.rrotate(bit32.bxor(bit32.lrotate(wd_41, 6), string.byte(tostring(wd_44))), 5)
            if bit32.bxor(bit32.lrotate(bit32.bxor(xv, 3905732465), 26), 3349361405) == bit32.lrotate(xv, 26) then
                wd_11 = require(wd_7:WaitForChild("ItemConfig"))
            else
                wd_7 = require(wd_11:WaitForChild("ItemConfig"))
            end
            wd_41 = (wd_41 + 79) % 112
        end
    elseif wd_32 <= 13 then
        if wd_32 <= 12 then
            wd_32 = {
                "ysozo",
                "fuo",
                "lpqecrgmet",
                "pzknb",
                "ewqhunxok",
                "oiqojd",
                "nvcdmelhd",
                "ylngc",
                "oksirjzc",
                "dbuqoyeoi",
                "tojgwtgnk",
                "rblkozcipah",
                "cpqbomjqegpw",
                "mgaafomvc",
                "xvh",
                "frkwz"
            }
            if wd_32[(wd_41 * 61 + 76) % 16 + 1] < wd_32[(wd_41 * 61 + 76) % 16 + 1] then
                wd_7 = require(wd_44:WaitForChild("ZoneConfig"))
            else
                wd_44 = require(wd_7:WaitForChild("ZoneConfig"))
            end
            wd_41 = (wd_41 + 37) % 112
        else
            wd_32 = {
                "bvhulpbtu",
                "tuocnpakicb",
                "fdtznyf",
                "yxkkyy",
                "buakbw",
                "mbpa",
                "ojktowuzlx",
                "xpfn",
                "sztpgtfwfno"
            }
            local xG = wd_41
            wd_15 = wd_32[xG % 9 + 1]
            if wd_15:len() >= wd_15:reverse():rep(xG % 3 + 2):len() then
                wd_7 = require(wd_29:WaitForChild("EggsConfig"))
            else
                wd_29 = require(wd_7:WaitForChild("EggsConfig"))
            end
            wd_41 = (wd_41 + 107) % 112
        end
    else
        if (wd_41 * 2 + 5) * 4 % 3 == ((wd_41 * 2 + 5) * 4 + 8) % 3 then
            wd_7 = require(RebirthConfig:WaitForChild("RebirthConfig"))
        else
            RebirthConfig = require(wd_7:WaitForChild("RebirthConfig"))
        end
        wd_41 = (wd_41 + 23) % 112
    end
until (wd_41 * 95 + 29) % 112 == 39
for k, v in pairs(wd_11) do
    wd_21 = type(k) == "number" and k < 100 and type(v) == "table" and not v.ProductId and not v.LimitedStockId
    if wd_21 then
        wd_21 = string.format
        wd_7 = tostring(v.Name)
        wd_39 = v.UnlockCost or 0
        wd_9 = wd_21("%d. %s (%s)", k, wd_7, tostring(wd_39))
        wd_21 = table.insert
        wd_7 = v.Name
        wd_39 = tonumber(v.UnlockCost) or 0
        wd_41 = tonumber(v.Gain) or 0
        wd_21(oQ, { Id = k, Name = wd_7, UnlockCost = wd_39, Gain = wd_41, Label = wd_9 })
        table.insert(wd_47, wd_9)
        oH[wd_9] = k
    end
end
wd_7, nT, nQ = nil, nil, nil
wd_21 = 0
repeat
    if wd_21 * 16605379 + 8 + 3 >= wd_21 * 16605379 + 8 + 3 + 1 then
        table.sort(nT, fn507)
        table.sort(wd_7, fn561)
        oQ = { "Best Available" }
        nQ = {}
        wd_47 = {}
    else
        table.sort(oQ, fn507)
        table.sort(wd_47, fn561)
        wd_7 = { "Best Available" }
        nT = {}
        nQ = {}
    end
    wd_21 = (wd_21 + 3) % 4
until (wd_21 * 1 + 3) % 4 == 2
for k, v in pairs(wd_44) do
    wd_21 = tonumber(k)
    wd_39 = wd_21 and type(v) == "table"
    if wd_39 then
        wd_39 = tonumber(v.Multiplier) or 1
        wd_9 = wd_39
        wd_39 = tonumber(v.RebirthRequirement) or 0
        wd_41 = wd_39
        wd_39 = string.format("Zone %d (%sx)", wd_21, tostring(wd_9))
        table.insert(nQ, { Id = wd_21, Multiplier = wd_9, RebirthRequirement = wd_41, Label = wd_39 })
        table.insert(wd_7, wd_39)
        nT[wd_39] = wd_21
    end
end
oA, ou = nil, nil
wd_9 = 0
repeat
    if (not wd_9 and oA or (not ou or not wd_9)) and (ou or not ou or (not wd_9 or wd_9)) and ((oA and not ou or (oA or not oA)) and (not wd_9 or not ou or (wd_9 or not oA))) or not ((not wd_9 and oA or (not ou or not wd_9)) and (ou or not ou or (not wd_9 or wd_9)) and ((oA and not ou or (oA or not oA)) and (not wd_9 or not ou or (wd_9 or not oA)))) then
        table.sort(nQ, fn969)
        table.sort(wd_7, fn573)
        oA = {}
        ou = {}
    else
        table.sort(ou, fn969)
        table.sort(nQ, fn573)
        wd_7 = {}
        oA = {}
    end
    wd_9 = (wd_9 + 0) % 4
until (wd_9 * 1 + 0) % 4 == 0
for k, v in pairs(wd_29) do
    wd_21 = type(v) == "table" and v.Currency == "Wins" and v.Cost
    if wd_21 then
        wd_21 = string.format("%s (%s Wins)", tostring(v.Name), tostring(v.Cost))
        table.insert(oA, wd_21)
        wd_39 = tonumber(v.Cost) or 0
        ou[wd_21] = { Id = k, Cost = wd_39, Name = v.Name }
    end
end
nH = nil
table.sort(oA, fns.fn137)
nH = {}
local p8 = 1
while p8 <= 45 do
    local p9 = p8
    table.insert(nH, "Stage " .. tostring(p9))
    p8 += 1
end
wd_9, oU, ow, oq, Options, oi, ob, oJ, oB, ox, ot, oo, oj, od, n8, nw, o6, Id, nA, n7, nV, nK, o8, nE, oV, oC, n9, n3, nO, o5, op, nS, ny, oT, ol, n0, oI, n1, nN, o3, nY, o_, n2, oW, nZ, oG, og, nG, oZ, ov, nU, nB, oc, nJ, oK, oe = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
nA = fn514
if (ob or oG or false and Options or (false and oG or (oG or not oU))) and (not Options and not oG or (Id or not Options) or (not oU or not oG or not Options and Options)) and ((ob and oU or oG and ob) and ((not oU or oU) and (Id and oi)) or (false or not Options or false or (oU or oG) and "https://discord.gg/K7Qxnxkk46")) or not ((ob or oG or false and Options or (false and oG or (oG or not oU))) and (not Options and not oG or (Id or not Options) or (not oU or not oG or not Options and Options)) and ((ob and oU or oG and ob) and ((not oU or oU) and (Id and oi)) or (false or not Options or false or (oU or oG) and "https://discord.gg/K7Qxnxkk46"))) then
    wd_9 = ""
else
    n7 = ""
end
oU = getgenv().Library
pcall(fn529)
local wd_18 = getgenv().ThemeManager
ow = getgenv().SaveManager
oq = oU.Toggles
Options = oU.Options
oi = "https://discord.gg/K7Qxnxkk46"
ob = "https://discord.gg/K7Qxnxkk46"
n7 = fns.fn257
if (ot or not oT or not oT and oT) and (false and oT or not Options and not oT) and not ((ot or not oT or not oT and oT) and (false and oT or not Options and not oT)) then
    nK = fn693
    nV = fn812
else
    nV = fn693
    nK = fn812
end
o8 = fn719
local wd_20 = "#7fd47f"
local wd_37 = "#6ec1ff"
oJ = "#e8a34d"
local wd_4 = "#8b93a3"
oB = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
ox = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
ot = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
oo = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
oj = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
od = ""
n8 = ""
wd_2 = "#345d9d"
wd_15 = "#f7931a"
wd_32 = "#627eea"
wd_29 = "#26a17b"
wd_44 = "#14f195"
wd_11 = "#0070ba"
wd_26 = "#008cff"
nE = fn722
oV = fn753
oC = fns.fn371
n9 = fn595
n3 = fns.fn278
nO = fn697
nw = nil
o6 = 0
o5 = fns.fn408
op = function(bX)
    local q7_1
    local q6_1
    if bX == nil then
        return 0
    elseif type(bX) == "number" then
        return bX
    else
        q6_1, q7_1 = pcall(function()
            return AlyaNum.new(bX):toNumber()
        end)
        local q8 = q6_1 and type(q7_1) == "number"
        if q8 then
            return q7_1
        end
        return 0
    end
end
nS = fn799
ny = fns.fn421
oT = fns.fn339
ol = fns.fn396
n0 = fn528
oI = fn987
n1 = fns.fn316
nN = fn764
o3 = fns.fn306
nY = fns.fn230
o_ = function(dq)
    if not dq then
        return false
    end
    local ProximityPrompt = dq:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not ProximityPrompt then
        return false
    end
    local sw = dq:FindFirstChild("Anchor") or dq:FindFirstChildWhichIsA("BasePart", true)
    if sw then
        n1(sw)
        task.wait(0.15)
    end
    if fireproximityprompt then
        local sw_1 = pcall(fireproximityprompt, ProximityPrompt)
        return sw_1
    elseif getconnections then
        local su = false
        for i, v in ipairs(getconnections(ProximityPrompt.Triggered)) do
            local sE = v
            pcall(function()
                if sE.Fire then
                    sE:Fire(LocalPlayer)
                    su = true
                elseif sE.Function then
                    sE.Function(LocalPlayer)
                    su = true
                end
            end)
        end
        return su
    else
        return false
    end
end
n2 = fns.fn22
oW = fn858
nZ = fn698
oG = fns.fn34
og = function(eq, er)
    local tb = eq and eq.CurrentWorld
    if tonumber(tb) == er then
        return true
    end
    local tb_1 = pcall(function()
        nP:InvokeServer(er)
    end)
    if tb_1 then
        task.wait(0.35)
        o5(true)
    end
    return tb_1
end
nG = fns.fn113
oZ = function(eF)
    og(o5(true), eF.World)
    local Barrier = eF.Folder:FindFirstChild("Barrier")
    local to = Barrier and Barrier:IsA("BasePart")
    if to then
        Barrier.CanCollide = false
    end
    local EnemySpawns = eF.Folder:FindFirstChild("EnemySpawns")
    local Spawn = eF.Folder:FindFirstChild("Spawn")
    if EnemySpawns then
        local tp_1 = (EnemySpawns:FindFirstChildWhichIsA("BasePart"))
        local ty = if tp_1 then 1 else 0
        local tw = 3825 * ty + 3068 * (1 - ty)
        local tx = 2861 * ty + 3296 * (1 - ty)
        if not ((tw * 3668 + tx * 2205 + tw * tx) % 16777213 == 14504717) then
            tp_1 = EnemySpawns:GetChildren()[1]
        end
        local tq_1 = tp_1
        if tq_1 then
            n1(tq_1)
        elseif Spawn then
            n1(Spawn)
        end
    elseif Spawn then
        n1(Spawn)
    end
    task.wait(0.25)
    local to_2 = os.clock() + 90
    local tD = false
    repeat
        local tm
        local tp_2 = os.clock() < to_2 and not oU.Unloaded and nE("AutoWin")
        if tp_2 then
            local tp_3 = o5(true)
            local tq_2 = tp_3 and oT(tp_3, eF.World, eF.Stage)
            if tq_2 then
                tD = true
            else
                tm = {}
                pcall(function()
                    local tj = {}
                    local tk = oS.getAliveEnemyRoots() or tj
                    tm = tk
                end)
                local tp_4 = nO()
                local tq_3 = tp_4 and type(tm) == "table" and #tm > 0
                if tq_3 then
                    local tq_4 = tm[1]
                    local tr = tq_4 and tq_4:IsA("BasePart")
                    if tr then
                        tp_4.AssemblyLinearVelocity = Vector3.zero
                        tp_4.AssemblyAngularVelocity = Vector3.zero
                        tp_4.CFrame = CFrame.new(tq_4.Position + Vector3.new(0, 3, 0))
                    end
                elseif EnemySpawns then
                    local tp_5 = EnemySpawns:FindFirstChildWhichIsA("BasePart") or EnemySpawns:GetChildren()[1]
                    if tp_5 then
                        n1(tp_5)
                    end
                end
                pcall(function()
                    RequestAttack:FireServer()
                end)
                task.wait(oC("WinAttackDelay", 0.06))
            end
        else
            tD = true
        end
    until tD
end
ov = fn733
nU = fns.fn157
nB = fn700
oc = fns.fn335
nJ = fn748
Id = nil
oK = function(fV, fW)
    pcall(function()
        AutoHatch:FireServer(fV, fW == true)
    end)
end
oe = function()
    local t0, t1
    t0 = oG()
    if not t0 then
        return
    end
    local t2 = o5(true)
    if not t2 then
        return
    end
    local t3 = op(t2.Wins)
    if t3 < t0.Cost then
        return
    end
    t1 = 1
    local t3_1 = t2.Eggs and tonumber(t2.Eggs.MultiHatch)
    if t3_1 then
        t1 = tonumber(t2.Eggs.MultiHatch)
    end
    local t2_1 = oV("HatchMode") or "Purchase"
    local t3_2 = tostring(t2_1)
    if t3_2 == "Game Auto Hatch" then
        if Id ~= t0.Id then
            if Id then
                oK(Id, false)
            end
            Id = t0.Id
            oK(t0.Id, true)
        end
        return
    end
    pcall(function()
        nL:FireServer(t0.Id, t1)
    end)
    task.wait(0.1)
    pcall(function()
        HatchEgg:FireServer(t0.Id)
    end)
    o5(true)
end
wd_39 = oU:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = oi, Copyable = true }, "|", wd_13 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
wd_34 = {
    Info = wd_39:AddTab("Info", "info"),
    Main = wd_39:AddTab("Main", "gamepad-2"),
    Player = wd_39:AddTab("Player", "person-standing"),
    Settings = wd_39:AddTab("Settings", "settings")
}
wd_41 = fns.fn452
for k, v in pairs(wd_34) do
    wd_41(v)
end
n4, Label, nz = nil, nil, nil
do
    n4 = "Unknown"
    pcall(fns.fn397)
    wd_21 = wd_34.Info:AddLeftGroupbox("Account", "circle-user")
    wd_21:AddLabel(o8("User", LocalPlayer.Name, wd_20), true)
    wd_21:AddLabel(o8("Status", "Keyless", wd_20), true)
    wd_21:AddLabel(o8("Executor", n4, wd_20), true)
    GameInfoGroup = wd_34.Info:AddLeftGroupbox("Game Info", "gamepad-2")
    GameInfoGroup:AddLabel(nK(wd_13 .. " [" .. tostring(game.PlaceId) .. "]", wd_37), true)
    GameInfoGroup:AddLabel(o8("Place ID", tostring(game.PlaceId), wd_37), true)
    Label = GameInfoGroup:AddLabel(o8("Session time", "0s", oJ), true)
end
nz = tostring(game.JobId)
wd_9 = #nz > 18
if wd_9 then
    wd_21 = 2
    repeat
        if wd_21 * 104436237 + 4 + 2 <= wd_21 * 104436237 + 4 + 2 + 1 then
            wd_9 = string.sub(nz, 1, 18) .. "..."
        else
            nz = string.sub(wd_9, 1, 18) .. "..."
        end
        wd_21 = (wd_21 + 7) % 8
    until (wd_21 * 7 + 5) % 8 == 4
end
wd_21 = wd_9 or nz
oP, nI, connection, connection2, connection3, o4, o1, connection4, connection5, oy, oE, oh, nM, o7, oa = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local wd_14 = wd_21
GameInfoGroup:AddLabel(o8("Server", wd_14, wd_4), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
oP = os.clock()
task.spawn(fns.worker)
local ScriptsGroup = wd_34.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(nK("Included in this hub", wd_4), true)
ScriptsGroup:AddLabel(nK(wd_13, wd_37), true)
local FeaturesGroup = wd_34.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(nK("Automation", wd_37), true)
FeaturesGroup:AddLabel(nK("Player Utilities", oJ), true)
FeaturesGroup:AddLabel(nK("Misc Utilities", wd_4), true)
local SocialsGroup = wd_34.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = nV })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = wd_34.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = nV })
wd_41 = wd_34.Info:AddRightGroupbox("Donations", "heart")
wd_41:AddLabel(nK("All donations are optional but appreciated.", oJ), true)
wd_41:AddLabel(nK("If you donate you get a special role, just PING after you donate.", wd_20), true)
wd_41:AddDivider()
wd_41:AddLabel(nK("LTC / Litecoin", wd_2), true)
wd_41:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
wd_41:AddLabel(nK("BTC / Bitcoin", wd_15), true)
wd_41:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
wd_41:AddLabel(nK("ETH / Ethereum", wd_32), true)
wd_41:AddButton({ Text = "Copy Ethereum Address", Func = fns.onCopyEthereumAddress })
wd_41:AddLabel(nK("USDT", wd_29), true)
wd_41:AddButton({ Text = "Copy USDT Address", Func = fns.onCopyUSDTAddress })
wd_41:AddLabel(nK("Solana", wd_44), true)
wd_41:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
wd_41:AddLabel(nK("PayPal", wd_11), true)
wd_41:AddButton({ Text = "Copy PayPal Link", Func = fns.onCopyPayPalLink })
wd_41:AddLabel(nK("Venmo", wd_26), true)
wd_41:AddButton({ Text = "Copy Venmo Link", Func = fns.onCopyVenmoLink })
wd_41:AddDivider()
wd_41:AddLabel(nK("Don't have any of the listed currencies but still wanna donate?", wd_4), true)
wd_41:AddLabel(nK("DM me and we'll work something out.", wd_37), true)
local FaqGroup = wd_34.Info:AddRightGroupbox("FAQ", "circle-help")
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
local WinGroup = wd_34.Main:AddLeftGroupbox("Win", "trophy")
WinGroup:AddToggle("AutoWin", { Text = "Auto Win", Default = false })
WinGroup:AddDropdown("WinStage", { Text = "Stage", Values = nH, Default = nH[1] })
WinGroup:AddSlider("WinAttackDelay", { Text = "Attack Delay", Default = 0.06, Min = 0.03, Max = 0.5, Rounding = 2 })
WinGroup:AddSlider("WinDelay", { Text = "Win Delay", Default = 0.35, Min = 0.1, Max = 3, Rounding = 2 })
local TrainGroup = wd_34.Main:AddLeftGroupbox("Train", "dumbbell")
TrainGroup:AddToggle("AutoClick", { Text = "Auto Click", Default = false })
TrainGroup:AddSlider("ClickDelay", { Text = "Click Delay", Default = 0.05, Min = 0.01, Max = 1, Rounding = 2 })
TrainGroup:AddToggle("AutoTrain", { Text = "Auto Train", Default = false })
TrainGroup:AddDropdown("TrainZone", { Text = "Zone", Values = wd_7, Default = wd_7[1] })
TrainGroup:AddSlider("TrainDelay", { Text = "Train Delay", Default = 0.05, Min = 0.01, Max = 1, Rounding = 2 })
local HeroesGroup = wd_34.Main:AddRightGroupbox("Heroes", "shield")
HeroesGroup:AddToggle("AutoBuyHeroes", { Text = "Auto Buy Heroes", Default = false })
HeroesGroup:AddDropdown("BuyHeroMode", {
    Text = "Buy Mode",
    Values = { "Next Affordable", "Best Affordable", "Selected Hero" },
    Default = "Next Affordable"
})
HeroesGroup:AddDropdown("BuyHeroSelect", { Text = "Hero", Values = wd_47, Default = wd_47[math.min(3, #wd_47)] })
HeroesGroup:AddSlider("BuyHeroDelay", { Text = "Buy Delay", Default = 0.5, Min = 0.1, Max = 5, Rounding = 2 })
local RebirthGroup = wd_34.Main:AddRightGroupbox("Rebirth", "rotate-ccw")
RebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
RebirthGroup:AddSlider("RebirthDelay", { Text = "Rebirth Delay", Default = 1, Min = 0.25, Max = 10, Rounding = 2 })
local HatchGroup = wd_34.Main:AddRightGroupbox("Hatch", "egg")
HatchGroup:AddToggle("AutoHatchEggs", { Text = "Auto Hatch", Default = false })
HatchGroup:AddDropdown("HatchEggSelect", { Text = "Egg", Values = oA, Default = oA[1] })
HatchGroup:AddDropdown("HatchMode", { Text = "Hatch Mode", Values = { "Purchase", "Game Auto Hatch" }, Default = "Purchase" })
HatchGroup:AddSlider("HatchDelay", { Text = "Hatch Delay", Default = 0.5, Min = 0.1, Max = 5, Rounding = 2 })
task.spawn(worker2)
task.spawn(fns.worker3)
task.spawn(fns.worker4)
task.spawn(fns.worker5)
task.spawn(fns.worker6)
task.spawn(fns.worker7)
oq.AutoHatchEggs:OnChanged(fns.fn346)
wd_9 = wd_34.Player:AddLeftGroupbox("Movement", "footprints")
wd_9:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
wd_9:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
wd_9:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
wd_9:AddToggle("NoClip", { Text = "NoClip", Default = false })
wd_9:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
wd_39 = wd_34.Player:AddRightGroupbox("Fly", "feather")
wd_39:AddToggle("Fly", { Text = "Fly", Default = false })
wd_39:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
nI = Workspace.CurrentCamera
connection = RunService.Stepped:Connect(fns.onStepped)
connection2 = UserInputService.JumpRequest:Connect(fns.onJumpRequest)
connection3 = RunService.RenderStepped:Connect(onRenderStepped)
if (oa and connection3 and (connection3 and oE) or SocialsGroup and not connection3 and (oa or wd_39)) and (not connection3 or SocialsGroup or not connection3 and not wd_39 or (not connection3 or connection3) and (not wd_39 or connection3)) or not ((oa and connection3 and (connection3 and oE) or SocialsGroup and not connection3 and (oa or wd_39)) and (not connection3 or SocialsGroup or not connection3 and not wd_39 or (not connection3 or connection3) and (not wd_39 or connection3))) then
    oq.Fly:OnChanged(fns.fn449)
    oq.WalkSpeedEnabled:OnChanged(fns.fn312)
    oy = function(iq)
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not iq)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not iq
            end
        end)
        if not iq then
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
else
    oy.Fly:OnChanged(fns.fn449)
    oy.WalkSpeedEnabled:OnChanged(fns.fn312)
    oq = function(iq)
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not iq)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not iq
            end
        end)
        if not iq then
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
end
oq.AntiGameplayPause:OnChanged(fn810)
task.spawn(fns.antiGameplayPauseLoop)
oy(true)
local MenuGroup = wd_34.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
oU.ToggleKeybind = Options.MenuKeybind
o4 = tick()
o1 = tick()
pcall(function()
    for k, v in getconnections(LocalPlayer.Idled) do
        local va = v
        pcall(function()
            va:Disable()
        end)
    end
end)
oE = fn621
connection4 = UserInputService.InputBegan:Connect(onInputBegan)
connection5 = UserInputService.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", fns.onUnload)
task.spawn(fns.antiAfkLoop)
oU:OnUnload(fn518)
wd_18:SetLibrary(oU)
wd_18:SetFolder("TempoHub")
wd_18:SaveDefault("Evil Hello Kitty")
wd_18:ApplyToTab(wd_34.Settings)
wd_18:LoadDefault()
ow:SetLibrary(oU)
ow:IgnoreThemeSettings()
ow:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
ow:SetFolder("TempoHub/Plus1SuperheroEvolution")
local wd_45 = ow:BuildConfigSection(wd_34.Settings)
oh = fns.fn275
nM = fns.fn237
o7 = fns.fn193
oa = function(jE)
    local vQ
    vQ = nil
    local vR = type(jE) ~= "table" or type(jE.idx) ~= "string" or type(jE.type) ~= "string" or ow.Ignore[jE.idx]
    if vR then
        return false
    end
    vQ = oh(jE.type, jE.idx)
    if not vQ then
        return false
    end
    local vR_1 = pcall(function()
        if jE.type == "Input" then
            if type(jE.text) ~= "string" then
                return
            end
            vQ:SetValue(jE.text)
        elseif jE.type == "ColorPicker" then
            vQ:SetValueRGB(Color3.fromHex(jE.value), jE.transparency)
        elseif jE.type == "KeyPicker" then
            vQ:SetValue({ jE.key, jE.mode, jE.modifiers })
            if jE.mode == "Toggle" and jE.toggled ~= nil then
                vQ.Toggled = jE.toggled
                vQ:Update()
            end
        else
            vQ:SetValue(jE.value)
        end
    end)
    return vR_1
end
wd_45:AddDivider()
wd_45:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
wd_45:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
wd_45:AddButton("Import Config from Clipboard Text", fns.onImportConfigFromClipboardTex)
ow:LoadAutoloadConfig()
oU:Notify("+1 Superhero Evolution loaded")
end)(...)

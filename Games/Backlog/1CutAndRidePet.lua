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
getgenv().TempoHoodSubtitle = "+1 CUT AND RIDE PET"
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
local xm_8
local xm_9_1
local xm_2_1
local Isinlan
local pj
local o0
local oI
local pp
local o6
local connection2
local Workspace
local ov
local OrmanConfig
local pU
local connection
local pB
local Library
local om
local pN
local oN
local pu
local ou
local pb
local oT
local pA
local YukseltAl
local ph
local pZ
local oZ
local oG
local Options
local o4
local pM
local pt
local Toggles
local pa
local pS
local oS
local pz
local pg
local pY
local o3
local pL
local oL
local py
local pX
local oX
local pE
local oE
local oi
local pr
local o8
local pQ
local oQ
local px
local GucTikla
local SatOdun
local pD
local oD
local pk
local o1
local RebirthYap
local LocalPlayer
local oo
local o7
local pP
local SatEsya
local pw
local pd
local pV
local oV
local function fn1(cv)
    local r3 = oQ[cv]
    if not r3 then
        return false
    elseif os.clock() >= r3 then
        oQ[cv] = nil
        return false
    else
        return true
    end
end
local function fn43()
    if not oD("AutoTrain") then
        return
    end
    local t9 = tonumber(pp("Guc")) or 0
    if t9 >= pw() then
        return
    end
    pcall(function()
        GucTikla:FireServer()
    end)
end
local function fn57()
    return LocalPlayer:FindFirstChild("sayac")
end
local function fn86(cd)
    local AutoUpgradeList = Options.AutoUpgradeList
    if not AutoUpgradeList then
        return false
    elseif AutoUpgradeList.Multi then
        return AutoUpgradeList.Value[cd] == true
    else
        return AutoUpgradeList.Value == cd
    end
end
local function fn93()
    if not oD("AutoSell") then
        return false
    end
    if (Options.SellWhen and Options.SellWhen.Value or "Always") == "Items Full" then
        return pZ()
    end
    local tO_2 = tonumber(pp("Odun")) or 0
    local tO_3 = tonumber(pp("Esya")) or 0
    local tO_4 = oD("SellWood")
    local tR = oD("SellItems")
    if tO_4 and tO_2 > 0 then
        return true
    end
    if tR and tO_3 > 0 then
        return true
    end
    return false
end
local function fn125()
    local ry_1
    local anahtar
    local rw = o8()
    ry_1, anahtar = 0, nil
    for k, v in OrmanConfig.AURALAR do
        local rz = type(v) == "table" and rw[v.anahtar] and k > ry_1
        if rz then
            ry_1 = k
            anahtar = v.anahtar
        end
    end
    return ry_1, anahtar
end
local function fn129()
    if connection then
        connection:Disconnect()
        connection = nil
    end
end
local function fn132(ci)
    local rW = not ci or not ci:IsA("ProximityPrompt")
    if rW then
        return
    end
    ci.HoldDuration = 0
    ci.MaxActivationDistance = math.max(ci.MaxActivationDistance, 20)
    ci.RequiresLineOfSight = false
    ci.Enabled = true
end
local function fn171()
    if not oD("AutoBuyUpgrades") then
        return
    end
    local uI = os.clock()
    if uI - pj < 0.8 then
        return
    end
    pj = uI
    if pU("Carry") then
        local uI_1 = oV()
        local uJ = uI_1 and oZ() >= uI_1
        if uJ then
            pcall(function()
                YukseltAl:FireServer("Kapasite")
            end)
        end
    end
end
local function worker2()
    local uM_1
    local uL_1
    while not Library.Unloaded do
        uL_1, uM_1 = pcall(function()
            pV()
            pA()
            pt()
            oo()
            oi()
            pX()
            pg()
        end)
        if not uL_1 then
            warn("[Tempo] farm loop:", uM_1)
            task.wait(0.5)
        elseif not oD("AutoFarm") then
            task.wait(0.2)
        else
            task.wait()
        end
    end
end
local function fn186(bi)
    if not bi then
        return
    end
    oX[bi] = os.clock() + pE
    if pa == bi then
        pa = nil
    end
end
local function fn188()
    if not oE() then
        return
    end
    local tY = Options.SellDelay and Options.SellDelay.Value or 1
    local tY_1 = os.clock()
    if tY_1 - px < tY then
        return
    end
    px = tY_1
    pa = nil
    local tX_2 = oD("SellWood")
    local tY_2 = oD("SellItems")
    pcall(function()
        Isinlan:FireServer("sell")
    end)
    task.wait(0.08)
    if tX_2 then
        pcall(function()
            SatOdun:FireServer()
        end)
    end
    if tY_2 then
        pcall(function()
            SatEsya:FireServer()
        end)
    end
    if oD("AutoFarm") then
        o6 = os.clock()
        local tX_3 = o4()
        if tX_3 then
            local tY_3 = pN(tX_3)
            if tY_3 then
                pQ(tY_3 * CFrame.new(0, 0, 2.5))
            end
        elseif oD("AutoBestZone") then
            pcall(function()
                Isinlan:FireServer("seviye")
            end)
            pr = os.clock()
        end
    elseif oD("AutoBestZone") then
        pcall(function()
            Isinlan:FireServer("seviye")
        end)
        pr = os.clock()
    end
end
local function fn204(av)
    local qp = Toggles[av]
    return qp ~= nil and qp.Value == true
end
local function fn233(bb)
    local qW = bb and bb.Parent and bb:IsA("Model") and not bb:GetAttribute("Devriliyor")
    return qW
end
local function fn246(be)
    local q0 = oX[be]
    if not q0 then
        return false
    elseif os.clock() >= q0 then
        oX[be] = nil
        return false
    else
        return true
    end
end
local function fn253(dD)
    local sZ = {}
    if not dD then
        return sZ
    end
    for i, child in dD:GetChildren() do
        local s_ = ph(child) and not o3(child)
        if s_ then
            sZ[#sZ + 1] = child
        end
    end
    return sZ
end
local function fn266(dA)
    local sV = pP()
    if not sV then
        return false
    end
    local Position = sV.Position
    local sX = dA or 35
    return oS(Position, sX)
end
local function fn283(ac, ad)
    if setclipboard then
        setclipboard(ac)
    elseif toclipboard then
        toclipboard(ac)
    end
    Library:Notify(ad)
end
local function fn340()
    if not oD("AutoBestZone") then
        return
    end
    local tG = oD("AutoFarm") and os.clock() - o6 < 8
    if tG then
        return
    end
    local tG_1 = os.clock()
    if tG_1 - pr < 12 then
        return
    end
    local tH = pP()
    local tI = ov(oN())
    if tH and tI then
        local Model = tI:FindFirstChildWhichIsA("Model")
        local tI_1 = Model and pN(Model)
        local tJ_2 = tI_1
        if tI_1 then
            tI_1 = (tJ_2.Position - tH.Position).Magnitude < 180
        end
        if tI_1 then
            return
        end
    end
    pr = tG_1
    pcall(function()
        Isinlan:FireServer("seviye")
    end)
end
local function fn363(cz)
    if cz then
        oQ[cz] = os.clock() + 2.5
    end
end
local function fn388(cZ)
    local sq_1
    local sp_1
    local so = cZ == "wood" and "Odunlar" or "Esyalar"
    local so_1 = Workspace:FindFirstChild(so)
    if not so_1 then
        return false
    end
    local sn_2 = cZ ~= "wood" and pZ()
    if sn_2 then
        return false
    end
    local sn_3 = pP()
    if not sn_3 then
        return false
    end
    sq_1, sp_1 = nil, nil
    for i, child in so_1:GetChildren() do
        if not oL(child) then
            local so_2 = o1(child)
            if so_2 then
                local Magnitude = (so_2.Position - sn_3.Position).Magnitude
                if not sp_1 or Magnitude < sp_1 then
                    sq_1 = child
                    sp_1 = Magnitude
                end
            end
        end
    end
    if not sq_1 then
        return false
    end
    return pM(sq_1)
end
local function fn390(dh, di)
    local sB_1
    local sA_1
    local sz = { Workspace:FindFirstChild("Esyalar"), Workspace:FindFirstChild("Odunlar") }
    sB_1, sA_1 = nil, nil
    local sC = pZ()
    for k, v in sz do
        if v then
            for i, child in v:GetChildren() do
                if not oL(child) then
                    local sz_1 = child.Name:match("^Esya") ~= nil
                    if not (sz_1 and sC) then
                        local sz_2 = o1(child)
                        if sz_2 then
                            local Magnitude = (sz_2.Position - dh).Magnitude
                            if Magnitude <= di and (not sA_1 or Magnitude < sA_1) then
                                sB_1 = child
                                sA_1 = Magnitude
                            end
                        end
                    end
                end
            end
        end
    end
    if not sB_1 then
        return false
    end
    return pM(sB_1)
end
local function fn454(bn)
    local attr = bn:GetAttribute("Kesen")
    return attr == LocalPlayer.UserId
end
local function fn455(g3)
    local DiscordGroup = g3:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = pL })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = pL })
end
local function fn464(cp)
    local rZ = cp and cp:FindFirstChildWhichIsA("ProximityPrompt", true)
    return rZ
end
local function fn481(aY)
    local qK = OrmanConfig.AGAC_KLASORLER and OrmanConfig.AGAC_KLASORLER[aY]
    if type(qK) ~= "string" then
        qK = "Agaclar" .. tostring(aY)
    end
    return Workspace:FindFirstChild(qK)
end
local function fn490(aj, ak)
    return string.format('<font color="%s">%s</font>', ak, aj)
end
local function fn499(dV)
    if #dV == 0 then
        return nil
    end
    return dV[math.random(1, #dV)]
end
local function fn528()
    if not oD("AutoRebirth") then
        return
    end
    local t5 = os.clock()
    if t5 - pd < 1.5 then
        return
    end
    local t6 = tonumber(pp("Guc")) or 0
    if t6 < pw() then
        return
    end
    pd = t5
    pcall(function()
        RebirthYap:FireServer()
    end)
end
local function fn541()
    local Character = LocalPlayer.Character
    local qw = Character and Character:FindFirstChild("HumanoidRootPart")
    return qw
end
local function fn555(iV)
    if not iV:IsA("ProximityPrompt") then
        return
    end
    iV.HoldDuration = 0
    iV.MaxActivationDistance = 50
    iV.RequiresLineOfSight = false
end
local function fn565()
    oI(false)
    pD()
    if connection2 then
        connection2:Disconnect()
    end
    local xf = om()
    if xf then
        xf.PlatformStand = false
        xf.WalkSpeed = 16
    end
end
local function fn575()
    local rh = {}
    local ri = LocalPlayer:GetAttribute("AuraSahip") or ""
    local rj = tostring(ri)
    for k in string.gmatch(rj, "[^,%s]+") do
        rh[k] = true
    end
    return rh
end
local function fn585()
    pY(pk, "Copied Discord invite to clipboard")
end
local function fn641()
    local tj = pP()
    if not tj then
        return nil
    end
    local tk = pa and ph(pa) and not o3(pa)
    if tk then
        return pa
    end
    pa = nil
    local tk_1 = ov(oN())
    local tl = oG(tk_1)
    if #tl == 0 then
        return nil
    end
    if (Options.FarmMode and Options.FarmMode.Value or "Nearest") == "Random" then
        pa = pb(tl)
    else
        pa = pS(tl, tj.Position)
    end
    return pa
end
local function fn659(am, an, ao)
    return string.format("<b>%s</b> %s %s", am, py("-", "#5a6070"), py(an, ao))
end
local function worker()
    local uP_1
    local uO_1
    while not Library.Unloaded do
        uO_1, uP_1 = pcall(oT)
        if not uO_1 then
            warn("[Tempo] train loop:", uP_1)
            task.wait(0.5)
        else
            local wait = task.wait
            local uP_2 = oD("AutoTrain") and 0.05
            local uQ = uP_2 or 0.25
            wait(uQ)
        end
    end
end
local function fn690(cs)
    if not cs then
        return nil
    end
    local r0 = cs:FindFirstChild("EsyaAnkor") or cs:FindFirstChild("EsyaAnkor", true)
    if not r0 then
        local r1 = cs:IsA("BasePart") and cs
        r0 = r1
    end
    if not r0 then
        r0 = cs.PrimaryPart
    end
    if not r0 then
        r0 = cs:FindFirstChildWhichIsA("BasePart", true)
    end
    return r0
end
local function fn733(dK, dL)
    local s8_1
    local s7_1
    s8_1, s7_1 = nil, nil
    for k, v in dK do
        local s9 = pN(v)
        if s9 then
            local Magnitude = (s9.Position - dL).Magnitude
            if not s7_1 or Magnitude < s7_1 then
                s8_1 = v
                s7_1 = Magnitude
            end
        end
    end
    return s8_1
end
local function fn776()
    local qD = tonumber(LocalPlayer:GetAttribute("Seviye"))
    if qD and qD > 0 then
        return qD
    end
    local max = math.max
    local qE_1 = (tonumber(pp("Bolge")))
    local qI = if qE_1 then 1 else 0
    local qG = 2886 * qI + 2941 * (1 - qI)
    local qH = 2969 * qI + 1686 * (1 - qI)
    if not ((qG * 139 + qH * 1646 + qG * qH) % 16777213 == 13856662) then
        qE_1 = 1
    end
    return max(1, qE_1)
end
local function fn797()
    if not oD("AutoFarm") then
        return
    end
    local tB = Options.FarmMode and Options.FarmMode.Value
    local tF = if tB then 1 else 0
    local tD = 1009 * tF + 1194 * (1 - tF)
    local tE = 4042 * tF + 2309 * (1 - tF)
    if not ((tD * 606 + tE * 803 + tD * tE) % 16777213 == 7935558) then
        tB = "Nearest"
    end
    if tB == "Ground Items" then
        if o7(60) then
            task.wait(0.05)
            return
        end
        local tA_2 = (ou("wood"))
        local tF_1 = if tA_2 then 1 else 0
        local tD_1 = 3270 * tF_1 + 1737 * (1 - tF_1)
        local tE_1 = 2927 * tF_1 + 2973 * (1 - tF_1)
        if not ((tD_1 * 3980 + tE_1 * 2374 + tD_1 * tE_1) % 16777213 == 12757375) then
            tA_2 = ou("item")
        end
        if tA_2 then
            task.wait(0.05)
            return
        end
        local tA_3 = o4()
        if tA_3 then
            pB(tA_3)
        else
            task.wait(0.15)
        end
        return
    end
    local tA_4 = os.clock()
    if tA_4 - o0 >= 0.45 then
        o0 = tA_4
        o7(14)
    end
    local tA_5 = o4()
    if tA_5 then
        pB(tA_5)
    else
        task.wait(0.08)
    end
end
local function fn809()
    local r6 = (tonumber(pp("Esya")))
    local sc = if r6 then 1 else 0
    local sa = 3197 * sc + 1132 * (1 - sc)
    local sb = 1531 * sc + 2439 * (1 - sc)
    if not ((sa * 3660 + sb * 4035 + sa * sb) % 16777213 == 5995999) then
        r6 = 0
    end
    local r7 = r6
    local r6_1 = tonumber(pp("Kapasite")) or 3
    return r7 >= r6_1
end
local function fn838()
    local Character = LocalPlayer.Character
    local qt = Character and Character:FindFirstChildOfClass("Humanoid")
    return qt
end
local function fn864()
    local rp = pu()
    local rq = 0
    for k in rp do
        if k > rq then
            rq = k
        end
    end
    return rq
end
local function fn879(aK)
    local qy = pz()
    local qz = qy and qy:FindFirstChild(aK)
    local qy_1 = qz
    if qz then
        qz = qy_1:IsA("ValueBase")
    end
    if qz then
        return qy_1.Value
    end
    return 0
end
local function fn883(br)
    local q6 = pP()
    local q7 = q6 and typeof(br) == "CFrame"
    if q7 then
        q6.CFrame = br + Vector3.new(0, 3, 0)
    end
end
local function fn890()
    local qB = tonumber(pp("Money")) or 0
    return qB
end
local function fn891()
    local q9 = {}
    local ra = LocalPlayer:GetAttribute("BaltaSahip") or ""
    local rb = tostring(ra)
    for k in string.gmatch(rb, "[^,%s]+") do
        local ra_1 = tonumber(k)
        if ra_1 then
            q9[ra_1] = true
        end
    end
    return q9
end
oi = nil
Options = nil
om = nil
oo = nil
Toggles = nil
ou = nil
ov = nil
YukseltAl = nil
Library = nil
Isinlan = nil
oD = nil
oE = nil
oG = nil
oI = nil
RebirthYap = nil
oL = nil
oN = nil
connection2 = nil
SatEsya = nil
oQ = nil
oS = nil
oT = nil
connection = nil
oV = nil
SatOdun = nil
oX = nil
oZ = nil
o0 = nil
o1 = nil
o3 = nil
o4 = nil
o6 = nil
o7 = nil
local AuraTak, on, op, AuraSatinAl, BaltaSec, SaveManager, oy, BaltaSatinAl, oF, oH, oK, oM, oR, oY, EsyaAlindi, o2, OdunAlindi
o8 = nil
pa = nil
pb = nil
OrmanConfig = nil
pd = nil
pg = nil
ph = nil
pj = nil
pk = nil
pp = nil
LocalPlayer = nil
pr = nil
pt = nil
pu = nil
Workspace = nil
pw = nil
px = nil
py = nil
pz = nil
pA = nil
pB = nil
pD = nil
pE = nil
pL = nil
pM = nil
pN = nil
pP = nil
pQ = nil
pS = nil
pU = nil
pV = nil
local AgacVur, pe, pf, pi, pl, pm, pn, po, ps, CoreGui, GuiService, pG, pH, HttpService, pJ, pK, VirtualUser, UserInputService, RunService
GucTikla = nil
pX = nil
pY = nil
pZ = nil
local qb
RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, LocalPlayer, pn, pk, pi, OrmanConfig, AgacVur, OdunAlindi, EsyaAlindi, SatOdun, SatEsya, RebirthYap, Isinlan, YukseltAl, BaltaSatinAl, BaltaSec, AuraSatinAl, AuraTak, GucTikla, pK, pG, pE, px, pr, po, pl, pj, pd, pa, o6, o0, oX, oQ, oK, Library, SaveManager, Toggles, Options, o2, oY, oR, oM, pe, pY, pL, py, pm, oD, om, pP, pz, pp, oZ, oN, ov, pN, ph, o3, oF, on, pQ, pu, o8, oH, op, pw, oV, pU, pH, ps, pf, o1, oL, oy, pZ, pM, ou, oS, o7, oG, pS, pb, o4, pB, pg, pV, oE, pA, pt, oT, oo, oi, pX = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local xm_5 = game:GetService("Players")
local xm_4 = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
LocalPlayer = xm_5.LocalPlayer
pn = "+1 Cut and Ride Pet"
pk = "https://discord.gg/K7Qxnxkk46"
pi = "https://discord.gg/K7Qxnxkk46"
OrmanConfig = require(xm_4:WaitForChild("Shared"):WaitForChild("OrmanConfig"))
AgacVur = xm_4:WaitForChild("AgacVur")
OdunAlindi = xm_4:WaitForChild("OdunAlindi")
EsyaAlindi = xm_4:WaitForChild("EsyaAlindi")
SatOdun = xm_4:WaitForChild("SatOdun")
SatEsya = xm_4:WaitForChild("SatEsya")
RebirthYap = xm_4:WaitForChild("RebirthYap")
Isinlan = xm_4:WaitForChild("Isinlan")
YukseltAl = xm_4:WaitForChild("YukseltAl")
BaltaSatinAl = xm_4:WaitForChild("BaltaSatinAl")
BaltaSec = xm_4:WaitForChild("BaltaSec")
AuraSatinAl = xm_4:WaitForChild("AuraSatinAl")
AuraTak = xm_4:WaitForChild("AuraTak")
GucTikla = xm_4:WaitForChild("GucTikla")
local p8 = { "Nearest", "Random", "Ground Items" }
local xm_3 = { "Carry" }
local xm_7 = { "Always", "Items Full" }
pK = 0.03
pG = 40
pE = 12
px = 0
pr = 0
po = 0
pl = 0
pj = 0
pd = 0
pa = nil
o6 = 0
o0 = 0
oX = {}
oQ = {}
oK = {
    CFrame.new(0, 0, 2.5),
    CFrame.new(2.5, 0, 0),
    CFrame.new(-2.5, 0, 0),
    CFrame.new(0, 0, -2.5),
    CFrame.new(2, 0, 2),
    CFrame.new(-2, 0, 2)
}
Library = getgenv().Library
if (VirtualUser and not ov or (not VirtualUser or EsyaAlindi) or (EsyaAlindi and ov or ov and not VirtualUser) or (not VirtualUser and not ov or (VirtualUser or EsyaAlindi)) and ((pV or not EsyaAlindi) and (VirtualUser and EsyaAlindi))) and not (VirtualUser and not ov or (not VirtualUser or EsyaAlindi) or (EsyaAlindi and ov or ov and not VirtualUser) or (not VirtualUser and not ov or (VirtualUser or EsyaAlindi)) and ((pV or not EsyaAlindi) and (VirtualUser and EsyaAlindi))) then
    local _ = getgenv().SaveManager
    xm_9_1 = getgenv().SaveManager
else
    xm_9_1 = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
end
Toggles = Library.Toggles
Options = Library.Options
pY = fn283
pL = fn585
py = fn490
pm = fn659
o2 = "#7fd47f"
oY = "#6ec1ff"
oR = "#e8a34d"
oM = "#8b93a3"
oD = fn204
om = fn838
pP = fn541
pz = fn57
pp = fn879
oZ = fn890
oN = fn776
ov = fn481
pN = function(a3)
    local qQ_1
    local qP_1
    qP_1, qQ_1 = pcall(function()
        return a3:GetPivot()
    end)
    local qR = qP_1 and typeof(qQ_1) == "CFrame"
    if qR then
        return qQ_1
    end
    local BasePart = a3:FindFirstChildWhichIsA("BasePart", true)
    return BasePart and BasePart.CFrame or nil
end
ph = fn233
o3 = fn246
oF = fn186
on = fn454
pQ = fn883
pu = fn891
o8 = fn575
oH = fn864
op = fn125
pw = function()
    local rH
    local rJ_1
    local rI = (tonumber(pp("Rebirths")))
    local rI_1
    local rO = if rI then 1 else 0
    local rM = 1047 * rO + 2010 * (1 - rO)
    local rN = 4047 * rO + 354 * (1 - rO)
    if not ((rM * 303 + rN * 252 + rM * rN) % 16777213 == 5574294) then
        rI = 0
    end
    rH = rI
    rI_1, rJ_1 = pcall(function()
        return OrmanConfig.rebirthGereken(rH)
    end)
    local rK = rI_1 and type(rJ_1) == "number"
    if rK then
        return rJ_1
    end
    return OrmanConfig.REBIRTH_TABAN_GUC or 20000
end
oV = function()
    local rP
    local rQ = tonumber(pp("Kapasite")) or 3
    local rQ_2
    local rR_1
    rP = math.max(0, rQ - 3)
    if rQ >= (OrmanConfig.KAPASITE_MAKS or 10) then
        return nil
    end
    rQ_2, rR_1 = pcall(function()
        return OrmanConfig.kapasiteFiyat(rP)
    end)
    local rS = rQ_2 and type(rR_1) == "number"
    if rS then
        return rR_1
    end
    return nil
end
pU = fn86
pH = fn132
ps = function(cl)
    pH(cl)
    if fireproximityprompt then
        pcall(fireproximityprompt, cl)
    else
        pcall(function()
            cl:InputHoldBegin()
            task.wait()
            cl:InputHoldEnd()
        end)
    end
end
pf = fn464
o1 = fn690
oL = fn1
oy = fn363
pZ = fn809
pM = function(cG)
    local sd
    local se = not cG or not cG.Parent or oL(cG)
    if se then
        return false
    end
    local se_1 = cG.Name:match("^Esya") ~= nil
    local sf = se_1 and pZ()
    if sf then
        oy(cG)
        return false
    end
    local se_2 = o1(cG)
    local sf_1 = pf(cG)
    if se_2 then
        pQ(se_2.CFrame)
    end
    if sf_1 then
        ps(sf_1)
    else
        local se_3 = cG.Name:match("^Odun") and OdunAlindi
        sd = se_3 or EsyaAlindi
        pcall(function()
            sd:FireServer(cG)
        end)
    end
    task.wait(0.08)
    if cG.Parent then
        oy(cG)
        return false
    end
    return true
end
ou = fn388
oS = fn390
o7 = fn266
oG = fn253
pS = fn733
pb = fn499
o4 = fn641
pB = function(ed)
    local tr = not ed or not ph(ed) or o3(ed)
    if tr then
        return false
    end
    pa = ed
    local tr_1 = pN(ed)
    if not tr_1 then
        return false
    end
    local ts = 1
    local ts_2
    pQ(tr_1 * oK[1])
    local tt = tr_1.Position
    local tr_2 = false
    local tu = 0
    while true do
        local tv = oD("AutoFarm") and ed.Parent and not ed:GetAttribute("Devriliyor")
        if not tv then
            local tr_3 = ed.Parent and pN(ed)
            if ts_2 then
                tt = tr_3.Position
            end
            local tr_4 = not ed.Parent or ed:GetAttribute("Devriliyor")
            if tr_4 then
                oS(tt, 25)
                oS(tt, 25)
            end
            if pa == ed then
                pa = nil
            end
            return true
        end
        if Library.Unloaded then
            break
        end
        pcall(function()
            AgacVur:FireServer(ed)
        end)
        tu += 1
        if on(ed) then
            tr_2 = true
        end
        local tv_1 = not tr_2
        if tv_1 ~= false then
            tv_1 = tu % 10 == 0
        end
        if tv_1 then
            ts = ts % #oK + 1
            local tv_2 = pN(ed)
            if tv_2 then
                pQ(tv_2 * oK[ts])
                tt = tv_2.Position
            end
        end
        local tv_3 = not tr_2
        if tv_3 ~= false then
            tv_3 = tu >= pG
        end
        if tv_3 then
            oF(ed)
            local tr_5 = ed.Parent and pN(ed)
            ts_2 = tr_5
            if ts_2 then
                tt = ts_2.Position
            end
            local tr_6 = not ed.Parent or ed:GetAttribute("Devriliyor")
            if tr_6 then
                oS(tt, 25)
                oS(tt, 25)
            end
            if pa == ed then
                pa = nil
            end
            return true
        end
        task.wait(pK)
    end
    return false
end
pg = fn797
pV = fn340
oE = fn93
pA = fn188
pt = fn528
oT = fn43
oo = function()
    local ul = if not oD("AutoBuyAxe") then 1 else 0
    if ul == 1 then
        return
    end
    local ud = os.clock()
    if ud - po < 0.75 then
        return
    end
    po = ud
    local ud_1 = pu()
    local ue = oZ()
    local uf
    for k, v in OrmanConfig.BALTA_SEVIYELER do
        local up = k
        local ug_1 = type(v) == "table" and not ud_1[up]
        if ug_1 then
            local ug_2 = tonumber(v.fiyat) or 0
            if ug_2 >= 0 and ue >= ug_2 then
                pcall(function()
                    BaltaSatinAl:FireServer(up)
                end)
                uf = up
                break
            end
        end
    end
    local ug_4 = uf or oH()
    local uc = ug_4
    if uc > 0 then
        task.defer(function()
            pcall(function()
                BaltaSec:FireServer(uc)
            end)
        end)
    end
end
oi = function()
    local ux_2
    local uw_3
    if not oD("AutoBuyPets") then
        return
    end
    local ut = os.clock()
    if ut - pl < 0.75 then
        return
    end
    pl = ut
    local ut_1 = o8()
    local uu = oZ()
    local anahtar
    for k, v in OrmanConfig.AURALAR do
        local uC = k
        local uw_1 = type(v) == "table" and type(v.anahtar) == "string" and not ut_1[v.anahtar]
        if uw_1 then
            local uw_2 = tonumber(v.fiyat) or 0
            if uu >= uw_2 then
                pcall(function()
                    AuraSatinAl:FireServer(uC)
                end)
                anahtar = v.anahtar
                break
            end
        end
    end
    uw_3, ux_2 = op()
    local us = anahtar or ux_2
    if us then
        task.defer(function()
            pcall(function()
                AuraTak:FireServer(us)
            end)
        end)
    end
end
pX = fn171
local xm_10 = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = pk, Copyable = true }, "|", pn },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
pe = {
    Info = xm_10:AddTab("Info", "info"),
    Main = xm_10:AddTab("Main", "axe"),
    Player = xm_10:AddTab("Player", "person-standing"),
    Settings = xm_10:AddTab("Settings", "settings")
}
for k, v in pe do
    fn455(v)
end
xm_10, xm_2_1, connection, connection2, xm_8, oI, pJ, pD, xm_5, qb = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if qb and not xm_5 and (not xm_5 or not xm_5) or (false or not xm_5 or not xm_5 and not xm_5) or not (qb and not xm_5 and (not xm_5 or not xm_5) or (false or not xm_5 or not xm_5 and not xm_5)) then
    xm_4 = pe.Main:AddLeftGroupbox("Farm", "trees")
    xm_4:AddToggle("AutoFarm", { Text = "Auto Farm Trees", Default = false })
    xm_4:AddDropdown("FarmMode", { Text = "Farm Mode", Values = p8, Default = 1 })
    xm_4:AddToggle("AutoBestZone", { Text = "Auto Best Zone", Default = false })
    xm_4:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
    xm_4:AddToggle("AutoTrain", { Text = "Auto Train", Default = false })
    xm_10 = pe.Main:AddLeftGroupbox("Sell", "badge-dollar-sign")
    xm_10:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
    xm_10:AddToggle("SellWood", { Text = "Sell Wood", Default = true })
    xm_10:AddToggle("SellItems", { Text = "Sell Items", Default = true })
    xm_10:AddDropdown("SellWhen", { Text = "Sell When", Values = xm_7, Default = 1 })
    xm_10:AddSlider("SellDelay", { Text = "Sell Delay", Default = 1, Min = 0.2, Max = 10, Rounding = 1 })
    local xm_2_2 = pe.Main:AddRightGroupbox("Shop", "shopping-cart")
    xm_2_2:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
    xm_2_2:AddDropdown("AutoUpgradeList", { Text = "Upgrades", Values = xm_3, Default = 1, Multi = true })
    xm_2_2:AddToggle("AutoBuyAxe", { Text = "Auto Buy Axe", Default = false })
    xm_2_2:AddToggle("AutoBuyPets", { Text = "Auto Buy Pets", Default = false })
    task.spawn(worker2)
    task.spawn(worker)
    xm_8 = function()
        local u4
        u4 = nil
        local u2, u3, u5, u6, Label, u8, u9, va, vb, vc
        local vj_2
        local vi_2
        local vh_2
        local vg_2
        u4 = "Unknown"
        pcall(function()
            local uT_2
            local uS_3
            if identifyexecutor then
                uT_2, uS_3 = identifyexecutor()
                local uU = uT_2 ~= ""
                local uV = type(uT_2) == "string" and uU
                if uV then
                    local uU_2 = type(uS_3) == "string" and uS_3 ~= "" and uT_2 .. " " .. uS_3
                    u4 = uU_2 or uT_2
                end
            end
        end)
        local AccountGroup = pe.Info:AddLeftGroupbox("Account", "circle-user")
        local vd_13
        AccountGroup:AddLabel(pm("User", LocalPlayer.Name, o2), true)
        AccountGroup:AddLabel(pm("Status", "Keyless", o2), true)
        AccountGroup:AddLabel(pm("Executor", u4, o2), true)
        local GameInfoGroup = pe.Info:AddLeftGroupbox("Game Info", "gamepad-2")
        GameInfoGroup:AddLabel(py(pn .. " [" .. tostring(game.PlaceId) .. "]", oY), true)
        GameInfoGroup:AddLabel(pm("Place ID", tostring(game.PlaceId), oY), true)
        Label = GameInfoGroup:AddLabel(pm("Session time", "0s", oR), true)
        u2 = tostring(game.JobId)
        local ve = #u2 > 18 and string.sub(u2, 1, 18) .. "..."
        local ve_4
        local vf = ve
        local vf_2
        local vo = if vf then 1 else 0
        local vm = 1304 * vo + 552 * (1 - vo)
        local vn = 3338 * vo + 1417 * (1 - vo)
        if not ((vm * 1383 + vn * 2671 + vm * vn) % 16777213 == 15071982) then
            vf = u2
        end
        local ve_3 = vf
        GameInfoGroup:AddLabel(pm("Server", ve_3, oM), true)
        GameInfoGroup:AddButton({
            Text = "Copy join script (Job ID)",
            Func = function()
                local hS = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, u2)
                pY(hS, "Copied join script to clipboard")
            end
        })
        u9 = os.clock()
        task.spawn(function()
            local u0_2
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                local u_ = math.floor(os.clock() - u9)
                if u_ < 60 then
                    u0_2 = u_ .. "s"
                elseif u_ < 3600 then
                    u0_2 = string.format("%dm %ds", math.floor((u_) / (60)), u_ % 60)
                else
                    u0_2 = string.format("%dh %dm", math.floor((u_) / (3600)), math.floor((u_ % 3600) / (60)))
                end
                Label:SetText(pm("Session time", u0_2, oR))
            end
        end)
        local ScriptsGroup = pe.Info:AddRightGroupbox("Scripts", "package")
        ScriptsGroup:AddLabel(py("Included in this hub", oM), true)
        ScriptsGroup:AddLabel(py(pn, oY), true)
        local FeaturesGroup = pe.Info:AddRightGroupbox("Features", "list")
        FeaturesGroup:AddLabel(py("Auto Farm", oY), true)
        FeaturesGroup:AddLabel(py("Auto Sell", oR), true)
        FeaturesGroup:AddLabel(py("Shop", o2), true)
        FeaturesGroup:AddLabel(py("Player", oM), true)
        local SocialsGroup = pe.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = pL })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                pY(pi, "Copied Rscripts profile to clipboard")
            end
        })
        local TempoHubGroup = pe.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
        TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
        TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
        TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
        TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = pL })
        vc = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
        u8 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
        u5 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
        vb = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
        va = ""
        u3 = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
        u6 = ""
        vd_13, ve_4, vf_2, vg_2, vh_2, vi_2, vj_2 = "#345d9d", "#f7931a", "#627eea", "#26a17b", "#14f195", "#0070ba", "#008cff"
        local DonationsGroup = pe.Info:AddRightGroupbox("Donations", "heart")
        DonationsGroup:AddLabel(py("All donations are optional but appreciated.", oR), true)
        DonationsGroup:AddLabel(py("If you donate you get a special role, just PING after you donate.", o2), true)
        DonationsGroup:AddDivider()
        DonationsGroup:AddLabel(py("LTC / Litecoin", vd_13), true)
        DonationsGroup:AddButton({
            Text = "Copy Litecoin Address",
            Func = function()
                pY(u3, "Copied Litecoin address")
            end
        })
        DonationsGroup:AddLabel(py("BTC / Bitcoin", ve_4), true)
        DonationsGroup:AddButton({
            Text = "Copy Bitcoin Address",
            Func = function()
                pY(vb, "Copied Bitcoin address")
            end
        })
        DonationsGroup:AddLabel(py("ETH / Ethereum", vf_2), true)
        DonationsGroup:AddButton({
            Text = "Copy Ethereum Address",
            Func = function()
                pY(u8, "Copied Ethereum address")
            end
        })
        DonationsGroup:AddLabel(py("USDT", vg_2), true)
        DonationsGroup:AddButton({
            Text = "Copy USDT Address",
            Func = function()
                pY(u5, "Copied USDT address")
            end
        })
        DonationsGroup:AddLabel(py("Solana", vh_2), true)
        DonationsGroup:AddButton({
            Text = "Copy Solana Address",
            Func = function()
                pY(vc, "Copied Solana address")
            end
        })
        DonationsGroup:AddLabel(py("PayPal", vi_2), true)
        DonationsGroup:AddButton({
            Text = "Copy PayPal Link",
            Func = function()
                pY(va, "Copied PayPal link")
            end
        })
        DonationsGroup:AddLabel(py("Venmo", vj_2), true)
        DonationsGroup:AddButton({
            Text = "Copy Venmo Link",
            Func = function()
                pY(u6, "Copied Venmo link")
            end
        })
        DonationsGroup:AddDivider()
        DonationsGroup:AddLabel(py("Don't have any of the listed currencies but still wanna donate?", oM), true)
        DonationsGroup:AddLabel(py("DM me and we'll work something out.", oY), true)
        local FaqGroup = pe.Info:AddRightGroupbox("FAQ", "circle-help")
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
    end
    xm_8()
    oI = function(iK)
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not iK)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not iK
            end
        end)
        if not iK then
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
    xm_7 = oI.Main:AddLeftGroupbox("Farm", "trees")
    xm_7:AddToggle("AutoFarm", { Text = "Auto Farm Trees", Default = false })
    xm_7:AddDropdown("FarmMode", { Text = "Farm Mode", Default = 1, Values = xm_8 })
    xm_7:AddToggle("AutoBestZone", { Text = "Auto Best Zone", Default = false })
    xm_7:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
    xm_7:AddToggle("AutoTrain", { Text = "Auto Train", Default = false })
    pe = oI.Main:AddLeftGroupbox("Sell", "badge-dollar-sign")
    pe:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
    pe:AddToggle("SellWood", { Text = "Sell Wood", Default = true })
    pe:AddToggle("SellItems", { Text = "Sell Items", Default = true })
    pe:AddDropdown("SellWhen", { Default = 1, Text = "Sell When", Values = xm_10 })
    pe:AddSlider("SellDelay", { Text = "Sell Delay", Min = 0.2, Max = 10, Default = 1, Rounding = 1 })
    xm_3 = oI.Main:AddRightGroupbox("Shop", "shopping-cart")
    xm_3:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
    xm_3:AddDropdown("AutoUpgradeList", { Text = "Upgrades", Default = 1, Multi = true, Values = xm_2_1 })
    xm_3:AddToggle("AutoBuyAxe", { Text = "Auto Buy Axe", Default = false })
    xm_3:AddToggle("AutoBuyPets", { Text = "Auto Buy Pets", Default = false })
    task.spawn(worker2)
    task.spawn(worker)
    p8 = function()
        local u4
        u4 = nil
        local u2, u3, u5, u6, Label, u8, u9, va, vb, vc
        local vj_1
        local vi_1
        local vh_1
        local vg_1
        u4 = "Unknown"
        pcall(function()
            local uT_1
            local uS_1
            if identifyexecutor then
                uT_1, uS_1 = identifyexecutor()
                local uU = uT_1 ~= ""
                local uV = type(uT_1) == "string" and uU
                if uV then
                    local uU_1 = type(uS_1) == "string" and uS_1 ~= "" and uT_1 .. " " .. uS_1
                    u4 = uU_1 or uT_1
                end
            end
        end)
        local AccountGroup = pe.Info:AddLeftGroupbox("Account", "circle-user")
        local vd_6
        AccountGroup:AddLabel(pm("User", LocalPlayer.Name, o2), true)
        AccountGroup:AddLabel(pm("Status", "Keyless", o2), true)
        AccountGroup:AddLabel(pm("Executor", u4, o2), true)
        local GameInfoGroup = pe.Info:AddLeftGroupbox("Game Info", "gamepad-2")
        GameInfoGroup:AddLabel(py(pn .. " [" .. tostring(game.PlaceId) .. "]", oY), true)
        GameInfoGroup:AddLabel(pm("Place ID", tostring(game.PlaceId), oY), true)
        Label = GameInfoGroup:AddLabel(pm("Session time", "0s", oR), true)
        u2 = tostring(game.JobId)
        local ve = #u2 > 18 and string.sub(u2, 1, 18) .. "..."
        local ve_2
        local vf = ve
        local vf_1
        local vo = if vf then 1 else 0
        local vm = 1304 * vo + 552 * (1 - vo)
        local vn = 3338 * vo + 1417 * (1 - vo)
        if not ((vm * 1383 + vn * 2671 + vm * vn) % 16777213 == 15071982) then
            vf = u2
        end
        local ve_1 = vf
        GameInfoGroup:AddLabel(pm("Server", ve_1, oM), true)
        GameInfoGroup:AddButton({
            Text = "Copy join script (Job ID)",
            Func = function()
                local hS = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, u2)
                pY(hS, "Copied join script to clipboard")
            end
        })
        u9 = os.clock()
        task.spawn(function()
            local u0_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                local u_ = math.floor(os.clock() - u9)
                if u_ < 60 then
                    u0_1 = u_ .. "s"
                elseif u_ < 3600 then
                    u0_1 = string.format("%dm %ds", math.floor((u_) / (60)), u_ % 60)
                else
                    u0_1 = string.format("%dh %dm", math.floor((u_) / (3600)), math.floor((u_ % 3600) / (60)))
                end
                Label:SetText(pm("Session time", u0_1, oR))
            end
        end)
        local ScriptsGroup = pe.Info:AddRightGroupbox("Scripts", "package")
        ScriptsGroup:AddLabel(py("Included in this hub", oM), true)
        ScriptsGroup:AddLabel(py(pn, oY), true)
        local FeaturesGroup = pe.Info:AddRightGroupbox("Features", "list")
        FeaturesGroup:AddLabel(py("Auto Farm", oY), true)
        FeaturesGroup:AddLabel(py("Auto Sell", oR), true)
        FeaturesGroup:AddLabel(py("Shop", o2), true)
        FeaturesGroup:AddLabel(py("Player", oM), true)
        local SocialsGroup = pe.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = pL })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                pY(pi, "Copied Rscripts profile to clipboard")
            end
        })
        local TempoHubGroup = pe.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
        TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
        TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
        TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
        TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = pL })
        vc = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
        u8 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
        u5 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
        vb = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
        va = ""
        u3 = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
        u6 = ""
        vd_6, ve_2, vf_1, vg_1, vh_1, vi_1, vj_1 = "#345d9d", "#f7931a", "#627eea", "#26a17b", "#14f195", "#0070ba", "#008cff"
        local DonationsGroup = pe.Info:AddRightGroupbox("Donations", "heart")
        DonationsGroup:AddLabel(py("All donations are optional but appreciated.", oR), true)
        DonationsGroup:AddLabel(py("If you donate you get a special role, just PING after you donate.", o2), true)
        DonationsGroup:AddDivider()
        DonationsGroup:AddLabel(py("LTC / Litecoin", vd_6), true)
        DonationsGroup:AddButton({
            Text = "Copy Litecoin Address",
            Func = function()
                pY(u3, "Copied Litecoin address")
            end
        })
        DonationsGroup:AddLabel(py("BTC / Bitcoin", ve_2), true)
        DonationsGroup:AddButton({
            Text = "Copy Bitcoin Address",
            Func = function()
                pY(vb, "Copied Bitcoin address")
            end
        })
        DonationsGroup:AddLabel(py("ETH / Ethereum", vf_1), true)
        DonationsGroup:AddButton({
            Text = "Copy Ethereum Address",
            Func = function()
                pY(u8, "Copied Ethereum address")
            end
        })
        DonationsGroup:AddLabel(py("USDT", vg_1), true)
        DonationsGroup:AddButton({
            Text = "Copy USDT Address",
            Func = function()
                pY(u5, "Copied USDT address")
            end
        })
        DonationsGroup:AddLabel(py("Solana", vh_1), true)
        DonationsGroup:AddButton({
            Text = "Copy Solana Address",
            Func = function()
                pY(vc, "Copied Solana address")
            end
        })
        DonationsGroup:AddLabel(py("PayPal", vi_1), true)
        DonationsGroup:AddButton({
            Text = "Copy PayPal Link",
            Func = function()
                pY(va, "Copied PayPal link")
            end
        })
        DonationsGroup:AddLabel(py("Venmo", vj_1), true)
        DonationsGroup:AddButton({
            Text = "Copy Venmo Link",
            Func = function()
                pY(u6, "Copied Venmo link")
            end
        })
        DonationsGroup:AddDivider()
        DonationsGroup:AddLabel(py("Don't have any of the listed currencies but still wanna donate?", oM), true)
        DonationsGroup:AddLabel(py("DM me and we'll work something out.", oY), true)
        local FaqGroup = pe.Info:AddRightGroupbox("FAQ", "circle-help")
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
    end
    p8()
end
pJ = fn555
pD = fn129
local function qa()
    local MovementGroup = pe.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = pe.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    RunService.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = LocalPlayer.Character
            if Character then
                for i, descendant in Character:GetDescendants() do
                    local vv_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if vv_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    UserInputService.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local vG_1 = om()
            if vG_1 then
                vG_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    local CurrentCamera = Workspace.CurrentCamera
    RunService.RenderStepped:Connect(function(jm)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local vL_1 = om()
            if vL_1 then
                vL_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local vL_3 = pP()
            local vM = om()
            if vL_3 and vM then
                vM.PlatformStand = true
                local vM_1 = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    vM_1 += CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    vM_1 -= CurrentCamera.CFrame.LookVector
                end
                local vR = if UserInputService:IsKeyDown(Enum.KeyCode.A) then 1 else 0
                if vR == 1 then
                    vM_1 -= CurrentCamera.CFrame.RightVector
                end
                local vR_1 = if UserInputService:IsKeyDown(Enum.KeyCode.D) then 1 else 0
                if vR_1 == 1 then
                    vM_1 += CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    vM_1 += Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    vM_1 -= Vector3.new(0, 1, 0)
                end
                vL_3.AssemblyLinearVelocity = Vector3.zero
                if vM_1.Magnitude > 0 then
                    vL_3.CFrame = vL_3.CFrame + vM_1.Unit * Options.FlySpeed.Value * jm
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local vS = om()
            if vS then
                vS.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local vX = om()
            if vX then
                vX.WalkSpeed = 16
            end
        end
    end)
    Toggles.AntiGameplayPause:OnChanged(function()
        oI(Toggles.AntiGameplayPause.Value)
    end)
    oI(true)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                oI(true)
            end
        end
    end)
    Toggles.InstantProximityPrompt:OnChanged(function()
        pD()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in Workspace:GetDescendants() do
                pcall(pJ, descendant)
            end
            connection = Workspace.DescendantAdded:Connect(function(jY)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(pJ, jY)
                end
            end)
        end
    end)
end
qa()
xm_5 = function(j1)
    local j2 = 0
    local j3 = tick()
    j1:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local Label = j1:AddLabel("AFK triggers: 0")
    local function j5()
        local CurrentCamera = Workspace.CurrentCamera
        if not CurrentCamera then
            return
        end
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        j2 += 1
        j3 = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. j2)
        end)
    end
    connection2 = LocalPlayer.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(j5)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local wd = Toggles.AntiAfk.Value and tick() - j3 >= 60
            if wd then
                pcall(j5)
            end
        end
    end)
    j1:AddButton({
        Text = "Unload UI",
        Func = function()
            Library:Unload()
        end
    })
end
local MenuGroup = pe.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
xm_5(MenuGroup)
xm_9_1:SetLibrary(Library)
xm_9_1:SetFolder("TempoHub")
xm_9_1:SaveDefault("Evil Hello Kitty")
xm_9_1:ApplyToTab(pe.Settings)
xm_9_1:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/CutAndRidePet")
local qc = SaveManager:BuildConfigSection(pe.Settings)
SaveManager:LoadAutoloadConfig()
qb = function(kw)
    local function kx(ky, kz)
        local wg_1 = (ky == "Toggle" and Toggles or Options)[kz]
        local wf_2 = type(wg_1) == "table" and wg_1.Type == ky
        return wf_2 and wg_1 or nil
    end
    local function kH(kI, kJ)
        local Type = kJ.Type
        if Type == "Toggle" then
            return { idx = kI, type = "Toggle", value = kJ.Value == true }
        elseif Type == "Slider" then
            return { idx = kI, type = "Slider", value = tostring(kJ.Value) }
        elseif Type == "Dropdown" then
            return { idx = kI, type = "Dropdown", multi = kJ.Multi == true, value = kJ.Value }
        elseif Type == "Input" then
            local wn = kJ.Value
            local wr = if wn then 1 else 0
            local wp = 1330 * wr + 516 * (1 - wr)
            local wq = 1655 * wr + 164 * (1 - wr)
            if not ((wp * 3273 + wq * 1867 + wp * wq) % 16777213 == 9644125) then
                wn = ""
            end
            return { idx = kI, type = "Input", text = tostring(wn) }
        elseif Type == "ColorPicker" then
            return { idx = kI, type = "ColorPicker", value = kJ.Value:ToHex(), transparency = kJ.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = kI,
                type = "KeyPicker",
                mode = kJ.Mode,
                key = kJ.Value,
                modifiers = kJ.Modifiers,
                toggled = kJ.Toggled
            }
        else
            return nil
        end
    end
    local function kL()
        local wt = {}
        for k, v in { Toggles, Options } do
            for k, v in v do
                local wu = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if wu then
                    local wu_1 = kH(k, v)
                    if wu_1 then
                        wt[#wt + 1] = wu_1
                    end
                end
            end
        end
        table.sort(wt, function(kU, kV)
            if kU.type ~= kV.type then
                return kU.type < kV.type
            end
            return kU.idx < kV.idx
        end)
        return { objects = wt }
    end
    local function kW(kX)
        local wQ
        wQ = nil
        local wR = type(kX) ~= "table" or type(kX.idx) ~= "string"
        local wV = if wR then 1 else 0
        local wT = 3506 * wV + 1948 * (1 - wV)
        local wU = 1783 * wV + 470 * (1 - wV)
        if not ((wT * 73 + wU * 1553 + wT * wU) % 16777213 == 9276135) then
            wR = type(kX.type) ~= "string"
        end
        if not wR then
            wR = SaveManager.Ignore[kX.idx]
        end
        if wR then
            return false
        end
        wQ = kx(kX.type, kX.idx)
        if not wQ then
            return false
        end
        local wR_1 = pcall(function()
            if kX.type == "Input" then
                if type(kX.text) ~= "string" then
                    return
                end
                wQ:SetValue(kX.text)
            elseif kX.type == "ColorPicker" then
                wQ:SetValueRGB(Color3.fromHex(kX.value), kX.transparency)
            elseif kX.type == "KeyPicker" then
                wQ:SetValue({ kX.key, kX.mode, kX.modifiers })
                if kX.mode == "Toggle" and kX.toggled ~= nil then
                    wQ.Toggled = kX.toggled
                    wQ:Update()
                end
            else
                wQ:SetValue(kX.value)
            end
        end)
        return wR_1
    end
    kw:AddDivider()
    kw:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    kw:AddButton("Export Config to Clipboard", function()
        local wX_1
        local wW_1
        wW_1, wX_1 = pcall(HttpService.JSONEncode, HttpService, kL())
        if not wW_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local wW_2 = setclipboard or toclipboard
        local wW_3 = type(wW_2) ~= "function" or not pcall(wW_2, wX_1)
        if wW_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    kw:AddButton("Import Config from Clipboard Text", function()
        local w1_1
        local w_ = Options.SaveManager_ImportSource.Value or ""
        local w__1
        local w0 = tostring(w_):match("^%s*(.-)%s*$")
        if w0 == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        w__1, w1_1 = pcall(HttpService.JSONDecode, HttpService, w0)
        local w0_1 = not w__1 or type(w1_1) ~= "table"
        local w5 = if w0_1 then 1 else 0
        local w3 = 1769 * w5 + 999 * (1 - w5)
        local w4 = 2610 * w5 + 3023 * (1 - w5)
        if not ((w3 * 942 + w4 * 2392 + w3 * w4) % 16777213 == 12526608) then
            w0_1 = type(w1_1.objects) ~= "table"
        end
        if w0_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local w__2 = 0
        for k, v in w1_1.objects do
            local xe = if kW(v) then 1 else 0
            if xe == 1 then
                w__2 += 1
            end
        end
        if w__2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local w1_2 = w__2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(w__2, w1_2), 6)
    end)
end
qb(qc)
Library:OnUnload(fn565)
end)(...)

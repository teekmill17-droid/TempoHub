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
getgenv().TempoHoodSubtitle = "RESCUE ANIMALS!"
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
local oy
local pf
local oX
local pl
local oi
local oK
local op
local UpgradeUtil
local Toggles
local TryUpgrade
local ox
local PLAYER_PICKAXES
local oW
local pD
local Library
local o1
local oJ
local pq
local oo
local o7
local pw
local TryCollectCurrency
local pC
local TryEquip
local pj
local o0
local oI
local pp
local on
local Options
local pv
local pc
local pB
local oB
local ItemUtil
local o_
local oH
local om
local o5
local oN
local pb
local oT
local TryRebirth
local ph
local TrySell
local ol
local o4
local TryPickup
local ot
local pa
local pz
local oz
local pg
local oY
local TryPurchase
local pm
local RebirthUtil
local oL
local ps
local oq
local oR
local py
local function fn39(aZ, a_)
    return aZ.order < a_.order
end
local function fn42(bP, bQ, bR)
    return string.format("<b>%s</b> %s %s", bP, oJ("-", "#5a6070"), oJ(bQ, bR))
end
local function fn97()
    local uY = pv()
    local uZ = not uY or type(uY.StoredItems) ~= "table"
    if uZ then
        return false
    end
    local uZ_1 = false
    for k, v in uY.StoredItems do
        if op(v) then
            local uY_1 = pa(TrySell, k)
            if uY_1 == true then
                uZ_1 = true
                break
            end
        end
    end
    return uZ_1
end
local function fn103(as, at)
    return as.order < at.order
end
local function fn105()
    local tN = pv()
    if not tN then
        return false
    end
    local tO = tN.Rebirth or 0
    if tO >= RebirthUtil.GetNumberOfRebirths() then
        return false
    end
    local tO_1 = RebirthUtil.GetRebirthRequirement(tO)
    if (tN.Cash or 0) < (tO_1 or math.huge) then
        return false
    end
    local tN_2 = pa(TryRebirth)
    return tN_2 == true
end
local function fn116()
    local uq = pv()
    if not uq then
        return false
    end
    local ur = Options.BuyFood and Options.BuyFood.Value
    local us = o_(ur)
    if not next(us) then
        return false
    end
    local ur_1 = uq.Boosts and uq.Boosts.Stock
    if type(ur_1) ~= "table" then
        return false
    end
    local ur_2 = uq.Cash or 0
    local uq_1 = false
    local uu = ur_2
    for k in us do
        local ur_3 = pC[k]
        if ur_3 then
            local us_1 = ur_1[ur_3]
            local uv = 0
            if type(us_1) == "table" then
                local uw_1 = tonumber(us_1.Stock) or tonumber(us_1.Amount)
                uv = uw_1 or 0
            elseif type(us_1) == "number" then
                uv = us_1
            end
            local us_2 = py[ur_3] or 0
            if uv > 0 and uu >= us_2 then
                local us_4 = pa(ps, ur_3)
                if us_4 == true then
                    uq_1 = true
                    uu -= us_2
                end
            end
        end
    end
    return uq_1
end
local function fn132()
    local t4 = pv()
    local t5 = not t4 or type(t4.Pickaxe) ~= "table"
    if t5 then
        return false
    end
    local t6 = t4.Pickaxe.Owned or {}
    local t6_1 = t4.Cash or 0
    local t6_2 = t4.Rebirth or 0
    local name2 = nil
    for k, v in pf do
        local t6_3 = not t6[v.name]
        if t6_3 ~= false then
            t6_3 = t6_2 >= v.rebirth
        end
        if t6_3 then
            t6_3 = t6_1 >= v.required
        end
        if t6_3 then
            local t6_4 = pa(TryPurchase, v.name)
            if t6_4 == true then
                name2 = v.name
                break
            end
        end
    end
    local name = nil
    local t7_1 = pv()
    local t9 = t7_1 and t7_1.Pickaxe and t7_1.Pickaxe.Owned
    local uj = if t9 then 1 else 0
    local uh = 3134 * uj + 2980 * (1 - uj)
    local ui = 2449 * uj + 9 * (1 - uj)
    if not ((uh * 1739 + ui * 3050 + uh * ui) % 16777213 == 3817429) then
        t9 = t6
    end
    local t5_3 = t7_1
    local t8_2 = t9
    if t5_3 then
        t5_3 = t7_1.Pickaxe
    end
    if t5_3 then
        t5_3 = t7_1.Pickaxe.Equipped
    end
    local t7_2 = t5_3
    for k, v in pf do
        if t8_2[v.name] then
            name = v.name
        end
    end
    if name and name ~= t7_2 then
        pa(TryEquip, name)
    end
    return name2 ~= nil
end
local function fn138()
    local rZ = {}
    for i, child in pj:GetChildren() do
        local Spawned = child:FindFirstChild("Spawned")
        if Spawned then
            for i, child2 in Spawned:GetChildren() do
                local r__1 = child2:GetAttribute("Name")
                if type(r__1) == "string" then
                    local r0 = ItemUtil.Get(r__1)
                    local r2 = r0 and r0.Rarity or "Common"
                    local r2_1 = #rZ + 1
                    local Name2 = child2.Name
                    local Name = child.Name
                    local r0_1 = r0 and r0.Display or r__1
                    local r5_1 = pb[r2] or 0
                    local r6 = tonumber(child2:GetAttribute("Health")) or 0
                    rZ[r2_1] = {
                        id = Name2,
                        spawner = Name,
                        name = r__1,
                        display = r0_1,
                        rarity = r2,
                        order = r5_1,
                        health = r6,
                        item = child2
                    }
                end
            end
        end
    end
    return rZ
end
local function fn143()
    local Character = o5.Character
    local rx = Character and Character:FindFirstChildOfClass("Humanoid")
    return rx
end
local function fn149(bM, bN)
    return string.format('<font color="%s">%s</font>', bN, bM)
end
local function worker()
    while Library and not Library.Unloaded do
        oz()
        task.wait(1)
    end
end
local function fn213()
    local dE = pa(TryCollectCurrency)
    return dE == true
end
local function fn225()
    local tj = pv()
    local tk = not tj or type(tj.StoredItems) ~= "table"
    if tk then
        return {}
    end
    local tk_1 = {}
    for k, v in tj.StoredItems do
        if v.Location == "PLOT" then
            local CaculateIncome = ItemUtil.CaculateIncome
            local tl = v.Level or 1
            local tm = CaculateIncome({ Level = tl, Name = v.Name, Mutation = v.Mutation, Traits = v.Traits })
            local tj_2 = #tk_1 + 1
            local Name = v.Name
            local tn = tonumber(tm) or 0
            tk_1[tj_2] = { id = k, name = Name, income = tn }
        end
    end
    return tk_1
end
local function fn254(aD, aE)
    local qW = pb[aD.rarity] or 0
    local qW_1 = pb[aE.rarity] or 0
    if qW ~= qW_1 then
        return qW < qW_1
    end
    return aD.display < aE.display
end
local function onSellNow()
    local vm = o1()
    if vm > 0 then
        local vo = vm == 1 and "" or "s"
        Library:Notify(("Sold %d animal%s"):format(vm, vo))
    else
        Library:Notify("No animals matched sell filters")
    end
end
local function fn365(b5)
    local rm = {}
    if type(b5) == "table" then
        for k, v in b5 do
            if v then
                rm[k] = true
            end
        end
    else
        local rn = b5 ~= ""
        local ro = type(b5) == "string" and rn
        if ro then
            rm[b5] = true
        end
    end
    return rm
end
local function fn384()
    local tR = pv()
    if not tR then
        return false
    end
    local tS = Options.BuyUpgrades and Options.BuyUpgrades.Value
    local tT = o_(tS)
    if not next(tT) then
        return false
    end
    local tS_1 = tR.Cash or 0
    local tU = false
    local tV = tS_1
    for k in tT do
        local tS_2 = oX[k]
        if tS_2 then
            local tW = tR.Upgrades and tR.Upgrades[tS_2] or 0
            local tW_1 = UpgradeUtil.GetMaxLevel(tS_2)
            if tW < tW_1 then
                local tW_2 = UpgradeUtil.GetPrice(tS_2, tW)
                local tT_3 = type(tW_2) == "number" and tV >= tW_2
                if tT_3 then
                    local tT_4 = pa(TryUpgrade, tS_2)
                    if tT_4 == true then
                        tU = true
                        tV -= tW_2
                    end
                end
            end
        end
    end
    return tU
end
local function fn390()
    local rD_1
    local rC_1
    rC_1, rD_1 = pcall(function()
        return pl.GetReplica()
    end)
    local rE = rC_1 and rD_1 and type(rD_1.Data) == "table"
    if rE then
        return rD_1.Data
    end
    return nil
end
local function fn423()
    local u6 = pv()
    local u7 = not u6 or type(u6.StoredItems) ~= "table"
    if u7 then
        return 0
    end
    local u7_1 = {}
    local u8 = 0
    for k, v in u6.StoredItems do
        if op(v) then
            u7_1[#u7_1 + 1] = k
        end
    end
    for k, v in u7_1 do
        if Library.Unloaded then
            break
        end
        local u6_1 = pa(TrySell, v)
        if u6_1 == true then
            u8 += 1
        end
        task.wait(0.08)
    end
    return u8
end
local function worker3()
    while not Library.Unloaded do
        if o7("AutoCollect") then
            pcall(o4)
        end
        if o7("AutoRebirth") then
            pcall(oH)
        end
        if o7("AutoBuyUpgrades") then
            pcall(pm)
        end
        if o7("AutoBuyPickaxes") then
            pcall(pB)
        end
        if o7("AutoFoodShop") then
            pcall(oo)
        end
        if o7("AutoSell") then
            pcall(pD)
        end
        task.wait(0.45)
    end
end
local function fn475()
    pw(oK, "Copied Discord invite to clipboard")
end
local function fn501(bU, bV)
    if setclipboard then
        setclipboard(bU)
    elseif toclipboard then
        toclipboard(bU)
    end
    Library:Notify(bV)
end
local function fn506()
    local sL = om()
    local sM = {}
    for k, v in sL do
        if oW(v) then
            sM[#sM + 1] = v
        end
    end
    local sL_1 = on(sM)
    if not sL_1 then
        return false
    elseif not pc(sL_1) then
        return false
    else
        local sM_1 = pa(TryPickup, sL_1.spawner, sL_1.id)
        return sM_1 == true
    end
end
local function fn575()
    local sU = pa(ol)
    if sU == true then
        return true
    end
    local Character = o5.Character
    local sV = Character and Character:FindFirstChildOfClass("Humanoid")
    local Backpack = o5:FindFirstChild("Backpack")
    if not (sV and Backpack) then
        return false
    end
    for i, child in Backpack:GetChildren() do
        local sV_2 = child:IsA("Tool") and child:GetAttribute("ItemId")
        if sV_2 then
            sV:EquipTool(child)
            task.wait(0.1)
            local sV_3 = pa(ot)
            return sV_3 == true
        end
    end
    return false
end
local function fn576()
    local Character = o5.Character
    local Backpack
    if Character then
        local Tool = Character:FindFirstChildOfClass("Tool")
        local s6_1 = Tool
        if s6_1 then
            local s8 = (Tool:HasTag("BoostTool"))
            local tc = if s8 then 1 else 0
            local ta = 4001 * tc + 95 * (1 - tc)
            local tb = 130 * tc + 2103 * (1 - tc)
            if not ((ta * 114 + tb * 1724 + ta * tb) % 16777213 == 1200364) then
                s8 = Tool:GetAttribute("BoostId")
            end
            s6_1 = s8
        end
        if s6_1 then
            return Tool
        end
        local Backpack2 = o5:FindFirstChild("Backpack")
        if not Backpack then
            return nil
        end
        for i, child in Backpack2:GetChildren() do
            local s6_3 = (child:IsA("Tool"))
            if s6_3 then
                local s7_2 = child:HasTag("BoostTool") or child:GetAttribute("BoostId")
                s6_3 = s7_2
            end
            if s6_3 then
                return child
            end
        end
        return nil
    end
    Backpack = o5:FindFirstChild("Backpack")
    if not Backpack then
        return nil
    end
    for i, child in Backpack:GetChildren() do
        local s6_5 = (child:IsA("Tool"))
        if s6_5 then
            local s7_3 = child:HasTag("BoostTool") or child:GetAttribute("BoostId")
            s6_5 = s7_3
        end
        if s6_5 then
            return child
        end
    end
    return nil
end
local function fn608(db)
    local sE_1
    local sD_1
    local sC_1
    local sz = oR()
    local sA = math.max(0.28, 0.55 / math.max(#sz, 1))
    local sI = 1
    local sG = 24
    while true do
        if not (sI <= sG) then
            return false
        end
        local sJ = sI
        if not db.item or not db.item.Parent then
            return false
        end
        local sB_1 = sz[(sJ - 1) % #sz + 1]
        sD_1, sE_1, sC_1 = pa(oI, sB_1, db.spawner, db.id)
        if sD_1 and sC_1 then
            break
        end
        local sB_3 = sD_1 and type(sE_1) == "number" and sE_1 <= 0
        if sB_3 then
            return true
        end
        task.wait(sA)
        sI += 1
    end
    return true
end
local function fn642(bb, bc)
    return bb.required < bc.required
end
local function fn658(aO, aP)
    return aO.damage < aP.damage
end
local function fn672(fy)
    if type(fy) ~= "table" then
        return false
    end
    return next(fy) ~= nil
end
local function worker4()
    while not Library.Unloaded do
        if o7("AutoRescue") then
            pcall(ox)
            task.wait(0.2)
        else
            task.wait(0.35)
        end
    end
end
local function fn688(b0)
    local rg = Toggles[b0]
    return rg ~= nil and rg.Value == true
end
local function fn731(fA)
    local uK = type(fA) ~= "table" or fA.Location ~= "TOOLBAR"
    if uK then
        return false
    end
    local uK_1 = ItemUtil.Get(fA.Name)
    local uM = uK_1 and uK_1.Rarity or "Common"
    local uM_1 = fA.Mutation
    local uX = if uM_1 then 1 else 0
    local uV = 3554 * uX + 3117 * (1 - uX)
    local uW = 2420 * uX + 2645 * (1 - uX)
    if not ((uV * 3364 + uW * 3770 + uV * uW) % 16777213 == 12902523) then
        uM_1 = "Normal"
    end
    local uN = uM_1
    local uM_2 = oN[fA.Name]
    local uU = if uM_2 then 1 else 0
    local uS = 1834 * uU + 840 * (1 - uU)
    local uT = 440 * uU + 2274 * (1 - uU)
    if not ((uS * 2398 + uT * 381 + uS * uT) % 16777213 == 5372532) then
        uM_2 = uK_1 and uK_1.Display
    end
    if not uM_2 then
        uM_2 = fA.Name
    end
    local uK_2 = uM_2
    local uM_3 = Options.SellRarity and Options.SellRarity.Value
    local uO_2 = o_(uM_3)
    local uM_4 = Options.SellMutation and Options.SellMutation.Value
    local uP = o_(uM_4)
    local uM_5 = Options.SellAnimals and Options.SellAnimals.Value
    local uQ = o_(uM_5)
    local uM_6 = not next(uO_2) or not uO_2[uM]
    if uM_6 then
        return false
    end
    local uL_2 = not next(uP) or not uP[uN]
    if uL_2 then
        return false
    end
    local uL_3 = next(uQ) and not uQ[uK_2]
    if uL_3 then
        return false
    end
    local uK_3 = o7("SellKeepTraits") and oy(fA.Traits)
    if uK_3 then
        return false
    end
    return true
end
local function fn754()
    return pg
end
local function fn763()
    local tv = pq()
    if not tv then
        return false
    end
    local tw = oL()
    if not tw then
        return false
    end
    if tv.Parent ~= o5.Character then
        tw:EquipTool(tv)
        task.wait(0.1)
    end
    local tv_1 = oT()
    if #tv_1 == 0 then
        return false
    end
    if (Options.FeedPriority and Options.FeedPriority.Value or "Best Earning") == "Random" then
        local tE = #tv_1
        local tD = -1
        while false and tE <= 2 or true and tE >= 2 do
            local tF = tE
            local tw_4 = math.random(tF)
            tv_1[tF], tv_1[tw_4] = tv_1[tw_4], tv_1[tF]
            tE += tD
        end
    else
        table.sort(tv_1, function(ep, eq)
            return ep.income > eq.income
        end)
    end
    for k, v in tv_1 do
        local tv_2 = pa(pp, v.id)
        if tv_2 == true then
            return true
        end
    end
    return false
end
local function worker2()
    while not Library.Unloaded do
        local w3 = false
        if o7("AutoPlace") then
            pcall(oY)
            w3 = true
        end
        if o7("AutoFeed") then
            pcall(oi)
            w3 = true
        end
        local w3_1 = w3 and 1 or 0.5
        task.wait(w3_1)
    end
end
local function fn882(gm)
    local DiscordGroup = gm:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = ph })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = ph })
end
local function fn897()
    local rN = PLAYER_PICKAXES:FindFirstChild(o5.Name)
    local rO = {}
    if not rN then
        return { 1 }
    end
    for i, child in rN:GetChildren() do
        local attr = child:GetAttribute("index")
        if type(attr) == "number" then
            rO[#rO + 1] = attr
        end
    end
    if #rO == 0 then
        rO[1] = 1
    end
    table.sort(rO)
    return rO
end
local function fn941()
    local vq = hookfunction ~= nil
    local vr = hookmetamethod ~= nil
    local vs = getrawmetatable ~= nil
    local vt = setrawmetatable ~= nil
    local vu = getgc ~= nil
    local vv = getgenv ~= nil
    local vw = getreg ~= nil
    local vx = getconnections ~= nil
    local vy = firesignal ~= nil
    local vz = getcallbackvalue ~= nil
    local vA = setclipboard ~= nil
    local vB = getcustomasset ~= nil
    local vC = getnamecallmethod ~= nil
    local vD = isexecutorclosure ~= nil
    local vE = fireproximityprompt ~= nil
    local vF = firetouchinterest ~= nil
    local vG = WebSocket ~= nil
    local vH = readfile ~= nil
    local vI = writefile ~= nil
    local vK = (request or http_request) ~= nil
    local vM = (debug and debug.getupvalues) ~= nil
    local vO = (debug and debug.setupvalue) ~= nil
    local vP = 0
    local vQ = { vq, vr, vs, vt, vu, vv, vw, vx, vy, vz, vA, vB, vC, vD, vE, vF, vG, vH, vI, vK, vM, vO }
    for i, v in ipairs(vQ) do
        if v then
            vP += 1
        end
    end
    local vq_1 = vP / #vQ
    if vq_1 >= 0.9 then
        return oJ("Full Support", oB)
    elseif vq_1 >= 0.6 then
        return oJ("Half Support", oq)
    else
        return oJ("Low Support", pz)
    end
end
local function fn957()
    local Character = o5.Character
    local rA = Character and Character:FindFirstChild("HumanoidRootPart")
    return rA
end
local function fn967(cU)
    local sk = Options.RescueRarity and Options.RescueRarity.Value
    local sl = o_(sk)
    local sk_1 = Options.RescueAnimals and Options.RescueAnimals.Value
    local sm = o_(sk_1)
    local sk_2 = next(sl) and not sl[cU.rarity]
    if sk_2 then
        return false
    end
    local sk_3 = next(sm) and not sm[cU.display]
    if sk_3 then
        return false
    end
    return true
end
oi = nil
ol = nil
om = nil
on = nil
oo = nil
op = nil
oq = nil
ot = nil
TryCollectCurrency = nil
ox = nil
oy = nil
oz = nil
oB = nil
TryEquip = nil
Library = nil
TryPurchase = nil
oH = nil
oI = nil
oJ = nil
oK = nil
oL = nil
TryPickup = nil
oN = nil
Options = nil
Toggles = nil
oR = nil
oT = nil
oW = nil
oX = nil
oY = nil
local oZ
o_ = nil
o0 = nil
o1 = nil
RebirthUtil = nil
o4 = nil
o5 = nil
local oh, oj, ou, ov, oA, oE, oG, oP, SaveManager, oU, ThemeManager, o2, o6
o7 = nil
UpgradeUtil = nil
pa = nil
pb = nil
pc = nil
PLAYER_PICKAXES = nil
pf = nil
pg = nil
ph = nil
ItemUtil = nil
pj = nil
pl = nil
pm = nil
TrySell = nil
pp = nil
pq = nil
ps = nil
pv = nil
pw = nil
TryUpgrade = nil
py = nil
pz = nil
TryRebirth = nil
pB = nil
pC = nil
pD = nil
local o9, pd, pk, po, pr, pt, pu, pF, pG, pH, pI, pJ, pK, pN, pO, pP, pQ, pR, pS, pT, pU
local pL_1
local pW, pX, pY
oh, pF, pt, pr, po, pk, pg, pd, o9, o6, o5, o2, o0 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local pE = 8
repeat
    pG = (pE * 1 + 2) % 4 + 1
    if pG <= 2 then
        if pG <= 1 then
            pH = (vector.create((pE * 4 + 4) % 11 + 1, (pE * 10 + 9) % 13 + 1, (pE * 10 + 8) % 17 + 1))
            pI = (vector.create((pE * 2 + 6) % 11 + 1, (pE * 11 + 4) % 13 + 1, (pE * 8 + 9) % 17 + 1))
            pJ = (vector.create((pE * 4 + 5) % 11 + 1, (pE * 11 + 1) % 13 + 1, (pE * 13 + 6) % 17 + 1))
            pK = (vector.create((pE * 5 + 9) % 11 + 1, (pE * 5 + 8) % 13 + 1, (pE * 11 + 2) % 17 + 1))
            if vector.dot(vector.cross(pH, pI), (vector.cross(pJ, pK))) == vector.dot(pH, pJ) * vector.dot(pI, pK) - vector.dot(pH, pK) * vector.dot(pI, pJ) then
                pg = game:GetService("CoreGui")
                pd = game:GetService("GuiService")
                o9 = game:GetService("TeleportService")
                o6 = game:GetService("Workspace")
            else
                o6 = game:GetService("CoreGui")
                o9 = game:GetService("GuiService")
                pd = game:GetService("TeleportService")
                pg = game:GetService("Workspace")
            end
            pE = (pE + 9) % 16
        else
            if (pE * 2 + 3) * 16 % 3 == ((pE * 2 + 3) * 16 + 5) % 3 then
                o2 = o0.LocalPlayer
                o5 = o2:WaitForChild("PlayerGui")
                oh = fn754
            else
                o5 = oh.LocalPlayer
                o2 = o5:WaitForChild("PlayerGui")
                o0 = fn754
            end
            pE = (pE + 13) % 16
        end
    elseif pG <= 3 then
        pG = (vector.create((pE * 1 + 4) % 11 + 1, (pE * 8 + 10) % 13 + 1, (pE * 2 + 2) % 17 + 1))
        pH = (vector.create((pE * 7 + 2) % 11 + 1, (pE * 3 + 12) % 13 + 1, (pE * 9 + 8) % 17 + 1))
        local ze = vector.dot(pG, pH)
        if ze * ze >= vector.dot(pG, pG) * vector.dot(pH, pH) + 1 then
            pk = game:GetService("Players")
        else
            oh = game:GetService("Players")
        end
        pE = (pE + 9) % 16
    else
        if (pF and pk or (not pF or pk)) and ((not pk or pk) and (pF or pk)) and (pF or pF or (pk or pk) or (pF and not pF or (pk or not pk))) or not ((pF and pk or (not pF or pk)) and ((not pk or pk) and (pF or pk)) and (pF or pF or (pk or pk) or (pF and not pF or (pk or not pk)))) then
            pF = game:GetService("ReplicatedStorage")
            pt = game:GetService("RunService")
            pr = game:GetService("UserInputService")
            po = game:GetService("VirtualUser")
            pk = game:GetService("HttpService")
        else
            pt = game:GetService("ReplicatedStorage")
            po = game:GetService("RunService")
            pk = game:GetService("UserInputService")
            pr = game:GetService("VirtualUser")
            pF = game:GetService("HttpService")
        end
        pE = (pE + 1) % 16
    end
until (pE * 13 + 6) % 16 == 14
if getgenv then
    oZ, pG = nil, nil
    pE = 7
    repeat
        pH = (pE * 1 + 1) % 2 + 1
        if pH <= 1 then
            pH = (vector.create((pE * 6 + 4) % 11 + 1, (pE * 5 + 3) % 13 + 1, (pE * 8 + 12) % 17 + 1))
            pI = (vector.create((pE * 6 + 1) % 11 + 1, (pE * 9 + 13) % 13 + 1, (pE * 8 + 10) % 17 + 1))
            local zd = vector.dot(pH, pI)
            if zd * zd <= vector.dot(pH, pH) * vector.dot(pI, pI) then
                getgenv().gethui = o0
                oZ = getgenv().__TempoRescueAnimalsLib
            else
                getgenv().gethui = oZ
                o0 = getgenv().__TempoRescueAnimalsLib
            end
            pE = (pE + 3) % 8
        else
            pH = (vector.create((pE * 7 + 4) % 11 + 1, (pE * 7 + 3) % 13 + 1, (pE * 2 + 3) % 17 + 1))
            pI = (vector.create((pE * 6 + 8) % 11 + 1, (pE * 1 + 1) % 13 + 1, (pE * 4 + 13) % 17 + 1))
            pJ = (vector.create((pE * 3 + 3) % 5 + 1, (pE * 4 + 2) % 7 + 1, (pE * 2 + 5) % 9 + 1))
            if math.abs((vector.angle(pH, pI, pJ))) - math.abs((vector.angle(pI, pH, pJ))) == 3 then
                oZ = pG
            else
                pG = oZ
            end
            pE = (pE + 1) % 8
        end
    until (pE * 3 + 3) % 8 == 4
    if pG then
        pG = oZ.Unload
    end
    if pG then
        pcall(function()
            oZ:Unload()
        end)
    end
end
pcall(function()
    gethui = o0
end)
if setthreadidentity then
    setthreadidentity(8)
end
oP, oK, oG, oE, oB, ou, oq, oj, pz, pP, pO, pN, pl, ItemUtil, pR, pS, UpgradeUtil, pQ, RebirthUtil, pL_1, pK, pJ, pI, pH, pG, pE, TryPickup, oI, TryPurchase, TryEquip, TryCollectCurrency, ot, ol, TryRebirth, TryUpgrade, ps, pp, TrySell, pj, PLAYER_PICKAXES, pb, pT = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local pM = 48
repeat
    pU = (pM * 11 + 2) % 24 + 1
    if pU <= 12 then
        if pU <= 6 then
            if pU <= 3 then
                if pU <= 2 then
                    if pU <= 1 then
                        local pV_1 = {
                            "ftljxd",
                            "dqfmqmagf",
                            "hjfx",
                            "cwd",
                            "szd",
                            "ebkrewmtgg",
                            "cxpbng",
                            "wivcz",
                            "qzzwnzyg",
                            "oyqlcops",
                            "ueffxfvskva",
                            "omcduom",
                            "yqr",
                            "mffwigw"
                        }
                        if pV_1[(pM * 57 + 4) % 14 + 1] <= pV_1[(pM * 57 + 4) % 14 + 1] then
                            pb = {}
                        else
                            oB = {}
                        end
                        pM = (pM + 35) % 96
                    else
                        local pV_2 = (vector.create((pM * 2 + 9) % 11 + 1, (pM * 9 + 6) % 13 + 1, (pM * 4 + 8) % 17 + 1))
                        pW = (vector.create((pM * 7 + 3) % 11 + 1, (pM * 6 + 2) % 13 + 1, (pM * 5 + 9) % 17 + 1))
                        local y3 = vector.dot(pV_2, pW)
                        if y3 * y3 <= vector.dot(pV_2, pV_2) * vector.dot(pW, pW) then
                            pT = {}
                        else
                            oj = {}
                        end
                        pM = (pM + 11) % 96
                    end
                else
                    if (pM * 3 + 2) * 21 % 4 == ((pM * 3 + 2) * 21 + 15) % 4 then
                        oK = "Rescue Animals!"
                        oP = "https://discord.gg/K7Qxnxkk46"
                        oE = "https://discord.gg/K7Qxnxkk46"
                        oG = "https://tempohub.shop"
                    else
                        oP = "Rescue Animals!"
                        oK = "https://discord.gg/K7Qxnxkk46"
                        oG = "https://discord.gg/K7Qxnxkk46"
                        oE = "https://tempohub.shop"
                    end
                    pM = (pM + 35) % 96
                end
            elseif pU <= 5 then
                if pU <= 4 then
                    local pV_3 = (vector.create((pM * 7 + 1) % 11 + 1, (pM * 2 + 9) % 13 + 1, (pM * 12 + 1) % 17 + 1))
                    pW = (vector.create((pM * 6 + 4) % 11 + 1, (pM * 5 + 7) % 13 + 1, (pM * 15 + 4) % 17 + 1))
                    pX = (vector.create((pM * 5 + 7) % 11 + 1, (pM * 8 + 10) % 13 + 1, (pM * 7 + 10) % 17 + 1))
                    pY = (vector.create((pM * 3 + 3) % 5 + 1, (pM * 3 + 3) % 7 + 1, (pM * 5 + 6) % 9 + 1))
                    if vector.dot(vector.cross(pV_3, (vector.cross(pW, pX))), pY) == vector.dot(pW * vector.dot(pV_3, pX) - pX * vector.dot(pV_3, pW), pY) + 1 then
                        pz = "#7fd47f"
                        oq = "#6ec1ff"
                        oj = "#e8a34d"
                        oB = "#8b93a3"
                        ou = "#e05a5a"
                    else
                        oB = "#7fd47f"
                        ou = "#6ec1ff"
                        oq = "#e8a34d"
                        oj = "#8b93a3"
                        pz = "#e05a5a"
                    end
                    pM = (pM + 35) % 96
                else
                    local pV_4 = { "mxrzzeu", "mih", "fjxyn", "hzdox", "pkuydbreo", "lafsf", "hrvthaf", "wuf" }
                    local yr = pM
                    pW = pV_4[yr % 8 + 1]
                    if pW:len() <= pW:gsub("(.)", "%1%1", yr % 3 % 2 + 1):len() then
                        pP = pF:WaitForChild("Library")
                    else
                        pF = pP:WaitForChild("Library")
                    end
                    pM = (pM + 83) % 96
                end
            else
                if (pK or pK or (pl or not pl)) and (not pl and not pK and (not oP and not pl)) and (not pl and pK or oP and not pK or (pK or pK or not pl and not pK)) and not ((pK or pK or (pl or not pl)) and (not pl and not pK and (not oP and not pl)) and (not pl and pK or oP and not pK or (pK or pK or not pl and not pK))) then
                    pP = pO:WaitForChild("Knit"):WaitForChild("Knit"):WaitForChild("Services")
                else
                    pO = pP:WaitForChild("Knit"):WaitForChild("Knit"):WaitForChild("Services")
                end
                pM = (pM + 83) % 96
            end
        elseif pU <= 9 then
            if pU <= 8 then
                if pU <= 7 then
                    if ((TryPurchase or oq or not oq and oq) and (not TryPurchase and not oq and (not oq and not PLAYER_PICKAXES)) or (not TryPurchase or not PLAYER_PICKAXES or (not ol or oq) or (not oq or TryPurchase) and (ol and not ol))) and (TryPurchase or oq or (not TryPurchase or not oq) or (TryPurchase or not TryPurchase or (not oq or ol)) or not oq and not PLAYER_PICKAXES and (not TryPurchase and TryPurchase) and ((oq or not oq) and (not PLAYER_PICKAXES and oq))) and not (((TryPurchase or oq or not oq and oq) and (not TryPurchase and not oq and (not oq and not PLAYER_PICKAXES)) or (not TryPurchase or not PLAYER_PICKAXES or (not ol or oq) or (not oq or TryPurchase) and (ol and not ol))) and (TryPurchase or oq or (not TryPurchase or not oq) or (TryPurchase or not TryPurchase or (not oq or ol)) or not oq and not PLAYER_PICKAXES and (not TryPurchase and TryPurchase) and ((oq or not oq) and (not PLAYER_PICKAXES and oq)))) then
                        pP = pN:WaitForChild("Balancing")
                    else
                        pN = pP:WaitForChild("Balancing")
                    end
                    pM = (pM + 35) % 96
                else
                    local pV_5 = (vector.create((pM * 1 + 9) % 11 + 1, (pM * 5 + 5) % 13 + 1, (pM * 7 + 3) % 17 + 1))
                    pW = (vector.create((pM * 6 + 8) % 11 + 1, (pM * 10 + 1) % 13 + 1, (pM * 12 + 5) % 17 + 1))
                    pX = (vector.create((pM * 3 + 5) % 5 + 1, (pM * 3 + 6) % 7 + 1, (pM * 3 + 6) % 9 + 1))
                    if math.abs((vector.angle(pV_5, pW, pX))) - math.abs((vector.angle(pW, pV_5, pX))) == 0 then
                        pl = require(pP:WaitForChild("Client"):WaitForChild("Saving"))
                        ItemUtil = require(pN:WaitForChild("ItemUtil"))
                        pR = require(pN:WaitForChild("PickaxeUtil"))
                        pS = require(pN:WaitForChild("BoostUtil"))
                    else
                        pR = require(pS:WaitForChild("Client"):WaitForChild("Saving"))
                        pl = require(ItemUtil:WaitForChild("ItemUtil"))
                        pP = require(ItemUtil:WaitForChild("PickaxeUtil"))
                        pN = require(ItemUtil:WaitForChild("BoostUtil"))
                    end
                    pM = (pM + 83) % 96
                end
            else
                local yQ = bit32.rrotate(bit32.bxor(bit32.lrotate(pM, 13), string.byte(tostring(pb))), 21)
                if bit32.bxor(bit32.lrotate(bit32.bxor(yQ, 979004389), 6), 2526738766) ~= bit32.lrotate(yQ, 6) then
                    pN = require(UpgradeUtil:WaitForChild("UpgradeUtil"))
                else
                    UpgradeUtil = require(pN:WaitForChild("UpgradeUtil"))
                end
                pM = (pM + 11) % 96
            end
        elseif pU <= 11 then
            if pU <= 10 then
                if (pM * 1 + 6) * 5 % 4 == ((pM * 1 + 6) * 5 + 8) % 4 then
                    pQ = require(pN:WaitForChild("RarityUtil"))
                else
                    pN = require(pQ:WaitForChild("RarityUtil"))
                end
                pM = (pM + 83) % 96
            else
                local pV_6 = (vector.create((pM * 2 + 8) % 11 + 1, (pM * 9 + 9) % 13 + 1, (pM * 7 + 3) % 17 + 1))
                pW = (vector.create((pM * 3 + 4) % 11 + 1, (pM * 9 + 1) % 13 + 1, (pM * 14 + 7) % 17 + 1))
                pX = (vector.create((pM * 2 + 2) % 5 + 1, (pM * 1 + 4) % 7 + 1, (pM * 1 + 2) % 9 + 1))
                if math.abs((vector.angle(pV_6, pW, pX))) - math.abs((vector.angle(pW, pV_6, pX))) == 0 then
                    RebirthUtil = require(pN:WaitForChild("RebirthUtil"))
                else
                    pN = require(RebirthUtil:WaitForChild("RebirthUtil"))
                end
                pM = (pM + 11) % 96
            end
        else
            local yP = bit32.rrotate(bit32.bxor(bit32.lrotate(pM, 13), string.byte(tostring(pH))), 14)
            if bit32.bxor(bit32.lrotate(bit32.bxor(yP, 998482324), 6), 3773326606) ~= bit32.lrotate(yP, 6) then
                pO = pL_1:WaitForChild("SpawnerService"):WaitForChild("RF")
            else
                pL_1 = pO:WaitForChild("SpawnerService"):WaitForChild("RF")
            end
            pM = (pM + 83) % 96
        end
    elseif pU <= 18 then
        if pU <= 15 then
            if pU <= 14 then
                if pU <= 13 then
                    if pM * 31460429 + 1 + 1 >= pM * 31460429 + 1 + 1 + 1 then
                        pO = pK:WaitForChild("PickaxeService"):WaitForChild("RF")
                    else
                        pK = pO:WaitForChild("PickaxeService"):WaitForChild("RF")
                    end
                    pM = (pM + 35) % 96
                else
                    local pV_7 = {
                        "hojlh",
                        "stuxfwqln",
                        "iwdomdhehyz",
                        "qmngocauxc",
                        "rufd",
                        "kbfhnxnvcq",
                        "pow",
                        "fmu",
                        "ykzthdk",
                        "muxwicc"
                    }
                    local zt = pM
                    pW = pV_7[zt % 10 + 1]
                    if pW:len() <= pW:gsub("(.)", "%1%1", zt % 3 % 2 + 1):len() then
                        pJ = pO:WaitForChild("SlotService"):WaitForChild("RF")
                    else
                        pO = pJ:WaitForChild("SlotService"):WaitForChild("RF")
                    end
                    pM = (pM + 35) % 96
                end
            else
                local pV_8 = {
                    "ivwsgpabc",
                    "qcdenpdw",
                    "pmji",
                    "dplcvrk",
                    "fyown",
                    "ctzibxetbc",
                    "mfgci",
                    "vljvtgtbm",
                    "quvkxo",
                    "tqnc",
                    "lqukgytrrwun",
                    "hbznlovt"
                }
                if pV_8[(pM * 62 + 100) % 12 + 1] < pV_8[(pM * 62 + 100) % 12 + 1] then
                    pO = pI:WaitForChild("RebirthService"):WaitForChild("RF")
                else
                    pI = pO:WaitForChild("RebirthService"):WaitForChild("RF")
                end
                pM = (pM + 11) % 96
            end
        elseif pU <= 17 then
            if pU <= 16 then
                local pV_9 = { "pgwusjb", "rwnfyp", "oosnfkwyx", "zmmazmi", "izskfvzvqo", "wrgcd", "eurozriwcgb", "cyglmeifiww" }
                local ys = pM
                pW = pV_9[ys % 8 + 1]
                if pW:len() >= pW:gsub("(.)", "%1%1", ys % 3 % 2 + 1):len() then
                    pO = pH:WaitForChild("UpgradeService"):WaitForChild("RF")
                else
                    pH = pO:WaitForChild("UpgradeService"):WaitForChild("RF")
                end
                pM = (pM + 11) % 96
            else
                local pV_10 = (vector.create((pM * 5 + 3) % 11 + 1, (pM * 10 + 12) % 13 + 1, (pM * 9 + 17) % 17 + 1))
                pW = (vector.create((pM * 7 + 2) % 11 + 1, (pM * 7 + 12) % 13 + 1, (pM * 3 + 6) % 17 + 1))
                pX = (vector.create((pM * 2 + 7) % 11 + 1, (pM * 8 + 1) % 13 + 1, (pM * 10 + 14) % 17 + 1))
                pY = (vector.create((pM * 6 + 3) % 11 + 1, (pM * 5 + 5) % 13 + 1, (pM * 13 + 6) % 17 + 1))
                if vector.dot(vector.cross(pV_10, pW), (vector.cross(pX, pY))) == vector.dot(pV_10, pX) * vector.dot(pW, pY) - vector.dot(pV_10, pY) * vector.dot(pW, pX) then
                    pG = pO:WaitForChild("BoostService"):WaitForChild("RF")
                else
                    pO = pG:WaitForChild("BoostService"):WaitForChild("RF")
                end
                pM = (pM + 35) % 96
            end
        else
            local pV_11 = (vector.create((pM * 5 + 4) % 11 + 1, (pM * 3 + 12) % 13 + 1, (pM * 2 + 14) % 17 + 1))
            pW = (vector.create((pM * 4 + 1) % 11 + 1, (pM * 2 + 13) % 13 + 1, (pM * 6 + 14) % 17 + 1))
            pX = (vector.create((pM * 5 + 9) % 11 + 1, (pM * 5 + 9) % 13 + 1, (pM * 2 + 3) % 17 + 1))
            pY = (vector.create((pM * 2 + 5) % 5 + 1, (pM * 1 + 1) % 7 + 1, (pM * 1 + 4) % 9 + 1))
            if vector.dot(vector.cross(pV_11, (vector.cross(pW, pX))), pY) == vector.dot(pW * vector.dot(pV_11, pX) - pX * vector.dot(pV_11, pW), pY) then
                pE = pO:WaitForChild("ItemService"):WaitForChild("RF")
            else
                pO = pE:WaitForChild("ItemService"):WaitForChild("RF")
            end
            pM = (pM + 83) % 96
        end
    elseif pU <= 21 then
        if pU <= 20 then
            if pU <= 19 then
                local pV_12 = {
                    "sspwwyf",
                    "lboduhcbpl",
                    "npwxyrn",
                    "qqlio",
                    "xvlnsgpqe",
                    "lnphymmm",
                    "zehzwltcn",
                    "kelmvuziiqx",
                    "vig"
                }
                local y1 = pM
                pW = pV_12[y1 % 9 + 1]
                if pW:len() >= pW:gsub("(.)", "%1%1", y1 % 3 % 2 + 1):len() then
                    pL_1 = TryPickup:WaitForChild("TryPickup")
                else
                    TryPickup = pL_1:WaitForChild("TryPickup")
                end
                pM = (pM + 83) % 96
            else
                if (ol or not pE or (pE or pE)) and (ol or not ol or (pE or TryEquip)) and ((pE or not TryEquip or not pE and ol) and (ol and pE and (not TryEquip or TryEquip))) and ((pE or pE or (TryEquip or not ol)) and (not TryEquip or pE or (not pE or ol)) and (ol or pE or not TryEquip and pE or (TryEquip and TryEquip or (ol or not pE)))) and not ((ol or not pE or (pE or pE)) and (ol or not ol or (pE or TryEquip)) and ((pE or not TryEquip or not pE and ol) and (ol and pE and (not TryEquip or TryEquip))) and ((pE or pE or (TryEquip or not ol)) and (not TryEquip or pE or (not pE or ol)) and (ol or pE or not TryEquip and pE or (TryEquip and TryEquip or (ol or not pE))))) then
                    pK = TryPurchase:WaitForChild("TryDamage")
                    oI = TryPurchase:WaitForChild("TryPurchase")
                else
                    oI = pK:WaitForChild("TryDamage")
                    TryPurchase = pK:WaitForChild("TryPurchase")
                end
                pM = (pM + 35) % 96
            end
        else
            local pV_13 = {
                "bpap",
                "pwr",
                "akiuqoxqaq",
                "itmtcuwfuq",
                "johblq",
                "afdbnzhdwy",
                "rzwlaie",
                "vmbzxp",
                "urqx",
                "ixenvyy",
                "fdnftxsx"
            }
            local y6 = pM
            pW = pV_13[y6 % 11 + 1]
            if pW:len() <= pW:gsub("(.)", "%1%1", y6 % 3 % 2 + 1):len() then
                TryEquip = pK:WaitForChild("TryEquip")
            else
                pK = TryEquip:WaitForChild("TryEquip")
            end
            pM = (pM + 83) % 96
        end
    elseif pU <= 23 then
        if pU <= 22 then
            pU = (vector.create((pM * 3 + 9) % 11 + 1, (pM * 2 + 2) % 13 + 1, (pM * 7 + 16) % 17 + 1))
            local pV_14 = (vector.create((pM * 3 + 2) % 11 + 1, (pM * 5 + 12) % 13 + 1, (pM * 15 + 15) % 17 + 1))
            local yR = vector.dot(pU, pV_14)
            if yR * yR >= vector.dot(pU, pU) * vector.dot(pV_14, pV_14) + 1 then
                pJ = TryCollectCurrency:WaitForChild("TryCollectCurrency")
                ol = TryCollectCurrency:WaitForChild("TryPlaceItem")
                ot = TryCollectCurrency:WaitForChild("TryPlaceBest")
            else
                TryCollectCurrency = pJ:WaitForChild("TryCollectCurrency")
                ot = pJ:WaitForChild("TryPlaceItem")
                ol = pJ:WaitForChild("TryPlaceBest")
            end
            pM = (pM + 35) % 96
        else
            pU = (vector.create((pM * 3 + 3) % 11 + 1, (pM * 4 + 12) % 13 + 1, (pM * 15 + 5) % 17 + 1))
            local pV_15 = (vector.create((pM * 5 + 8) % 11 + 1, (pM * 5 + 8) % 13 + 1, (pM * 8 + 5) % 17 + 1))
            pW = (vector.create((pM * 5 + 2) % 11 + 1, (pM * 6 + 11) % 13 + 1, (pM * 8 + 14) % 17 + 1))
            if vector.dot(vector.cross(pU, pV_15), pW) == vector.dot(vector.cross(pV_15, pW), pU) + 4 then
                pI = pG:WaitForChild("TryRebirth")
                pp = TryRebirth:WaitForChild("TryUpgrade")
                pH = TryUpgrade:WaitForChild("TryPurchase")
                ps = TryUpgrade:WaitForChild("TryUseBoost")
            else
                TryRebirth = pI:WaitForChild("TryRebirth")
                TryUpgrade = pH:WaitForChild("TryUpgrade")
                ps = pG:WaitForChild("TryPurchase")
                pp = pG:WaitForChild("TryUseBoost")
            end
            pM = (pM + 59) % 96
        end
    else
        if pT and RebirthUtil and (not pT or pK) and ((pK or pK) and (not pQ and not pQ)) or (not pQ and pQ and (pK and not pT) or (not pK or pQ) and (not pH or RebirthUtil)) or not (pT and RebirthUtil and (not pT or pK) and ((pK or pK) and (not pQ and not pQ)) or (not pQ and pQ and (pK and not pT) or (not pK or pQ) and (not pH or RebirthUtil))) then
            TrySell = pE:WaitForChild("TrySell")
            pj = o6:WaitForChild("SPAWNERS")
            PLAYER_PICKAXES = o6:WaitForChild("CASCHES"):WaitForChild("PLAYER_PICKAXES")
        else
            pE = PLAYER_PICKAXES:WaitForChild("TrySell")
            o6 = TrySell:WaitForChild("SPAWNERS")
            pj = TrySell:WaitForChild("CASCHES"):WaitForChild("PLAYER_PICKAXES")
        end
        pM = (pM + 35) % 96
    end
until (pM * 25 + 1) % 96 == 25
pU = {}
for k, v in pQ.Data do
    pE = #pU + 1
    pF = v.Order or 0
    pU[pE] = { name = k, order = pF }
end
pG = 0
repeat
    local yE = bit32.rrotate(bit32.bxor(bit32.lrotate(pG, 14), string.byte(tostring(pG))), 29)
    if bit32.bxor(bit32.lrotate(bit32.bxor(yE, 4008732276), 20), 1733226246) ~= bit32.lrotate(yE, 20) then
        table.sort(pU, fn103)
    else
        table.sort(pU, fn103)
    end
    pG = (pG + 0) % 4
until (pG * 3 + 0) % 4 == 0
for k, v in pU do
    pb[v.name] = v.order
    pT[#pT + 1] = v.name
end
pG, pF, oN = nil, nil, nil
pE = 4
repeat
    pH = (pE * 1 + 0) % 2 + 1
    if pH <= 1 then
        pH = { "ayjokb", "suazz", "ossulafrcwv", "xelio", "udvzllhbjg", "cnhyfuklj", "swyghvmh" }
        local y5 = pE
        pI = pH[y5 % 7 + 1]
        if pI:len() >= pI:reverse():rep(y5 % 3 + 2):len() then
            pF = {}
            pG = {}
        else
            pG = {}
            pF = {}
        end
        pE = (pE + 7) % 8
    else
        if (not oN and not oN or (pG or pG)) and ((pF or not pF) and (not pF or not oN)) and not ((not oN and not oN or (pG or pG)) and ((pF or not pF) and (not pF or not oN))) then
            pF = {}
        else
            oN = {}
        end
        pE = (pE + 3) % 8
    end
until (pE * 3 + 3) % 8 == 5
pH = {}
for k, v in ItemUtil.GetAll() do
    pE = v.Display or k
    pI = pE
    pE = #pH + 1
    pJ = v.Rarity or "Common"
    pK = v.Income or 0
    pH[pE] = { name = k, display = pI, rarity = pJ, income = pK }
    pF[pI] = k
    oN[k] = pI
end
pE = 6
repeat
    pF = {
        "pojz",
        "wodqieljb",
        "vmi",
        "txriglqmng",
        "lqqwtnfrph",
        "fwedtzerzfq",
        "qdenmdkbz",
        "cqbxrybvg",
        "xaas",
        "hzwjsi",
        "qumhw",
        "yjtwx"
    }
    local za = pE
    pI = pF[za % 12 + 1]
    if pI:len() <= pI:gsub("(.)", "%1%1", za % 3 % 2 + 1):len() then
        table.sort(pH, fn254)
    else
        table.sort(pH, fn254)
    end
    pE = (pE + 3) % 8
until (pE * 7 + 6) % 8 == 5
for k, v in pH do
    pG[#pG + 1] = v.display
end
pf = {}
pE = {}
for k, v in pR.GetAll() do
    if type(k) == "string" then
        pF = #pf + 1
        pH = v.Display or k
        pI = v.Required or 0
        pJ = v.Rebirth or 0
        pK = v.Damage or 0
        pf[pF] = { name = k, display = pH, required = pI, rebirth = pJ, damage = pK }
    end
end
local pL_2 = 3
repeat
    local zE = bit32.rrotate(bit32.bxor(bit32.lrotate(pL_2, 16), string.byte(tostring(pL_2))), 30)
    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(zE, 398533779), 3393778033), (bit32.bxor(bit32.band(zE, 3896433516), 3631300644))), 3393778033), 3631300644) == zE then
        table.sort(pf, fn658)
    else
        table.sort(pf, fn658)
    end
    pL_2 = (pL_2 + 4) % 8
until (pL_2 * 5 + 5) % 8 == 0
for k, v in pf do
    pE[#pE + 1] = v.display
end
pI, oX, pH = nil, nil, nil
pF = 3
repeat
    pE = (pF * 1 + 1) % 2 + 1
    if pE <= 1 then
        local zc = bit32.rrotate(bit32.bxor(bit32.lrotate(pF, 21), string.byte(tostring(pH))), 29)
        if bit32.bxor(bit32.lrotate(bit32.bxor(zc, 1180229246), 26), 4179190649) == bit32.lrotate(zc, 26) then
            pI = {}
        else
            pH = {}
        end
        pF = (pF + 1) % 8
    else
        pE = {
            "occucf",
            "gpixr",
            "ikbnduukor",
            "xktxxionqj",
            "xgpbnof",
            "ncqenflqfl",
            "dcqciaajokqn",
            "sam",
            "ofptairosi",
            "zjevovtybcpr",
            "ycwxhm",
            "gkssgvwlsub",
            "onzqjzseu",
            "deqtrnusxez"
        }
        if pE[(pF * 20 + 113) % 14 + 1] <= pE[(pF * 20 + 113) % 14 + 1] then
            oX = {}
            pH = {}
        else
            pH = {}
            oX = {}
        end
        pF = (pF + 7) % 8
    end
until (pF * 1 + 6) % 8 == 1
pE = {}
for k, v in UpgradeUtil.GetAll() do
    pF = v.Display or k
    pJ = pF
    pF = #pE + 1
    pK = v.Order or 0
    pE[pF] = { name = k, display = pJ, order = pK }
    oX[pJ] = k
end
pF = 5
repeat
    local zs = bit32.rrotate(bit32.bxor(bit32.lrotate(pF, 2), string.byte(tostring(pF))), 18)
    if bit32.bxor(bit32.lrotate(bit32.bxor(zs, 2273442268), 26), 1914570727) ~= bit32.lrotate(zs, 26) then
        table.sort(pE, fn39)
    else
        table.sort(pE, fn39)
    end
    pF = (pF + 6) % 8
until (pF * 5 + 6) % 8 == 5
for k, v in pE do
    pI[#pI + 1] = v.display
    pH[v.display] = true
end
pF, pC, py, pJ = nil, nil, nil, nil
pE = 3
repeat
    pK = (vector.create((pE * 4 + 7) % 11 + 1, (pE * 11 + 1) % 13 + 1, (pE * 10 + 12) % 17 + 1))
    local pL_3 = (vector.create((pE * 5 + 8) % 11 + 1, (pE * 3 + 9) % 13 + 1, (pE * 3 + 13) % 17 + 1))
    pM = (vector.create((pE * 2 + 7) % 5 + 1, (pE * 2 + 4) % 7 + 1, (pE * 4 + 4) % 9 + 1))
    if math.abs((vector.angle(pK, pL_3, pM))) - math.abs((vector.angle(pL_3, pK, pM))) == 1 then
        py = {}
        pF = {}
        pJ = {}
        pC = {}
    else
        pF = {}
        pC = {}
        py = {}
        pJ = {}
    end
    pE = (pE + 0) % 8
until (pE * 3 + 1) % 8 == 2
pK = {}
for k, v in pS.GetAll() do
    pE = v.Display or k
    local pL_4 = pE
    pE = v.Required or 0
    pM = pE
    pK[#pK + 1] = { name = k, display = pL_4, required = pM }
    pC[pL_4] = k
    py[k] = pM
end
table.sort(pK, fn642)
for k, v in pK do
    pF[#pF + 1] = v.display
    pJ[v.display] = true
end
pP = { "Lowest Rarity", "Highest Rarity", "Random" }
pO = { "Best Earning", "Random" }
pN = { "Normal", "Gold", "Diamond", "Rainbow" }
pM = { Common = true }
local pL_5 = { Normal = true }
pK = {}
for k, v in pT do
    pK[v] = true
end
Library = nil
Library = getgenv().Library
if getgenv then
    getgenv().__TempoRescueAnimalsLib = Library
end
ThemeManager, SaveManager, Toggles, Options, pu, oz, oJ, oA, pw, ph, o7, o_, oL, ov, pv, pa, oR, om, oW, on, pc, ox, o4, oY, pq, oT, oi, oH, pm, pB, oo, oy, op, pD, o1, pS = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
oz = function()
    local function q1(br)
        local q_ = not br or not br:IsA("ScreenGui")
        if q_ then
            return
        end
        br.ResetOnSpawn = false
        br.IgnoreGuiInset = true
        br.DisplayOrder = math.max(br.DisplayOrder, 1000)
        pcall(function()
            br.ClipToDeviceSafeArea = false
        end)
        pcall(function()
            br.ScreenInsets = Enum.ScreenInsets.None
        end)
        if br.Parent ~= pg then
            br.Parent = pg
        end
    end
    q1(Library.ScreenGui)
    if Library.ActiveLoading and Library.ActiveLoading.ScreenGui then
        q1(Library.ActiveLoading.ScreenGui)
    end
    for i, v in ipairs({ "Obsidian", "ObsidianLoading" }) do
        local q2_1 = pg:FindFirstChild(v) or o2:FindFirstChild(v)
        if q2_1 then
            q1(q2_1)
        end
    end
end
oz()
task.spawn(worker)
ThemeManager = getgenv().ThemeManager
if (o_ or not pc) and (not pq or not o_) and ((not pq or ThemeManager) and (pc and ThemeManager)) and not ((o_ or not pc) and (not pq or not o_) and ((not pq or ThemeManager) and (pc and ThemeManager))) then
    local _ = getgenv().SaveManager
else
    SaveManager = getgenv().SaveManager
end
Toggles = Library.Toggles
Options = Library.Options
oJ = fn149
oA = fn42
pw = fn501
ph = fn475
o7 = fn688
o_ = fn365
oL = fn143
ov = fn957
pv = fn390
if (ph and not ThemeManager or not ph and pS or (not oJ or not pS or (not oo or not oJ))) and not (ph and not ThemeManager or not ph and pS or (not oJ or not pS or (not oo or not oJ))) then
    oR = function(co, ...)
        local rL_2
        local rK_2
        local rJ_2
        local rI_2
        local rH_2
        local rG_2
        rG_2, rL_2, rJ_2, rH_2, rI_2, rK_2 = pcall(function(...)
            return co:InvokeServer(...)
        end, ...)
        if not rG_2 then
            return false, tostring(rL_2)
        end
        return rL_2, rJ_2, rH_2, rI_2, rK_2
    end
    pa = fn897
else
    pa = function(co, ...)
        local rL_1
        local rK_1
        local rJ_1
        local rI_1
        local rH_1
        local rG_1
        rG_1, rL_1, rJ_1, rH_1, rI_1, rK_1 = pcall(function(...)
            return co:InvokeServer(...)
        end, ...)
        if not rG_1 then
            return false, tostring(rL_1)
        end
        return rL_1, rJ_1, rH_1, rI_1, rK_1
    end
    oR = fn897
end
om = fn138
oW = fn967
on = function(c3)
    local ss
    ss = nil
    if #c3 == 0 then
        return nil
    end
    local su = Options.RescuePriority and Options.RescuePriority.Value
    local sy = if su then 1 else 0
    local sw = 3584 * sy + 409 * (1 - sy)
    local sx = 2320 * sy + 2534 * (1 - sy)
    if not ((sw * 3087 + sx * 2223 + sw * sx) % 16777213 == 7758835) then
        su = "Lowest Rarity"
    end
    ss = su
    if ss == "Random" then
        return c3[math.random(1, #c3)]
    end
    table.sort(c3, function(c7, c8)
        if c7.order ~= c8.order then
            if ss == "Highest Rarity" then
                return c7.order > c8.order
            end
            return c7.order < c8.order
        elseif c7.health ~= c8.health then
            return c7.health < c8.health
        else
            return c7.display < c8.display
        end
    end)
    return c3[1]
end
pc = fn608
ox = fn506
o4 = fn213
oY = fn575
pq = fn576
oT = fn225
oi = fn763
oH = fn105
pm = fn384
pB = fn132
oo = fn116
oy = fn672
op = fn731
pD = fn97
o1 = fn423
pR = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = oK, Copyable = true }, "|", oP },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
if ((pq or not oR) and (oR or oR) or (not Toggles or not oR) and (Toggles and not oR)) and (oR and Toggles or not oR and oR or (oW and oW or (not pq or not oR))) or not (((pq or not oR) and (oR or oR) or (not Toggles or not oR) and (Toggles and not oR)) and (oR and Toggles or not oR and oR or (oW and oW or (not pq or not oR)))) then
    pu = {
        Info = pR:AddTab("Info", "info"),
        Main = pR:AddTab("Main", "paw-print"),
        Player = pR:AddTab("Player", "person-standing"),
        Settings = pR:AddTab("Settings", "settings")
    }
else
    pR = {
        Player = pu:AddTab("Player", "person-standing"),
        Settings = pu:AddTab("Settings", "settings"),
        Main = pu:AddTab("Main", "paw-print"),
        Info = pu:AddTab("Info", "info")
    }
end
pS = fn882
for k, v in pu do
    if k ~= "Info" then
        pS(v)
    end
end
oU = nil
pW = pu.Main:AddLeftGroupbox("Rescue", "paw-print")
pW:AddToggle("AutoRescue", { Text = "Auto Rescue Animals", Default = false })
pW:AddDropdown("RescueRarity", { Text = "Rarity Filter", Values = pT, Default = pK, Multi = true, AllowEmpty = true })
pW:AddDropdown("RescueAnimals", {
    Text = "Specific Animals",
    Values = pG,
    Default = {},
    Multi = true,
    AllowEmpty = true,
    Searchable = true
})
pW:AddDropdown("RescuePriority", { Text = "Priority", Values = pP, Default = 1 })
local FarmGroup = pu.Main:AddRightGroupbox("Farm", "coins")
FarmGroup:AddToggle("AutoCollect", { Text = "Auto Collect Money", Default = false })
FarmGroup:AddToggle("AutoPlace", { Text = "Auto Place in Pen", Default = false })
FarmGroup:AddToggle("AutoFeed", { Text = "Auto Feed", Default = false })
FarmGroup:AddDropdown("FeedPriority", { Text = "Feed Priority", Values = pO, Default = 1 })
FarmGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
pU = pu.Main:AddRightGroupbox("Sell", "tags")
pU:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
pU:AddDropdown("SellRarity", { Text = "Sell Rarity", Values = pT, Default = pM, Multi = true, AllowEmpty = true })
pU:AddDropdown("SellMutation", { Text = "Sell Mutation", Values = pN, Default = pL_5, Multi = true, AllowEmpty = true })
pU:AddDropdown("SellAnimals", {
    Text = "Sell Animals",
    Values = pG,
    Default = {},
    Multi = true,
    AllowEmpty = true,
    Searchable = true
})
pU:AddToggle("SellKeepTraits", { Text = "Keep Traits", Default = true })
pU:AddButton({ Text = "Sell Now", Func = onSellNow })
pQ = pu.Main:AddLeftGroupbox("Shop", "shopping-bag")
pQ:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
pQ:AddDropdown("BuyUpgrades", { Text = "Upgrades", Values = pI, Default = pH, Multi = true, AllowEmpty = true })
pQ:AddToggle("AutoBuyPickaxes", { Text = "Auto Buy Pickaxes", Default = false })
pQ:AddToggle("AutoFoodShop", { Text = "Auto Food Shop", Default = false })
pQ:AddDropdown("BuyFood", { Text = "Food Shop", Values = pF, Default = pJ, Multi = true, AllowEmpty = true })
oU = fn941
pY = function()
    local wh
    local wd
    wd = nil
    wh = nil
    local Label, Label2, Label3, wf, wg
    wh = "Unknown"
    pcall(function()
        local vZ_1
        local vY_1
        if identifyexecutor then
            vZ_1, vY_1 = identifyexecutor()
            local v_ = vZ_1 ~= ""
            local v0 = type(vZ_1) == "string" and v_
            if v0 then
                local v__1 = type(vY_1) == "string" and vY_1 ~= "" and vZ_1 .. " " .. vY_1
                wh = v__1 or vZ_1
            end
        end
    end)
    local wi = oU()
    wd = os.clock()
    wg = function()
        local v5 = math.floor(os.clock() - wd)
        if v5 < 60 then
            return v5 .. "s"
        elseif v5 < 3600 then
            return string.format("%dm %ds", math.floor((v5) / (60)), v5 % 60)
        else
            return string.format("%dh %dm", math.floor((v5) / (3600)), math.floor((v5 % 3600) / (60)))
        end
    end
    local UserGroup = pu.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = o5, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(oA("User", o5.DisplayName .. " @" .. o5.Name, oB), true)
    UserGroup:AddLabel(oA("UserId", tostring(o5.UserId), ou), true)
    UserGroup:AddLabel(oA("Executor", wh .. "  " .. wi, oB), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(oA("Session", wg(), oq), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            pw(o5.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            pw("https://www.roblox.com/users/" .. tostring(o5.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = pu.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(oA("Game", oP, ou), true)
    Label2 = SessionGroup:AddLabel(oA("Players", "0/0", oB), true)
    wf = tostring(game.JobId)
    local wj_1 = #wf > 18 and string.sub(wf, 1, 18) .. "..."
    local wj_2 = wj_1 or wf
    SessionGroup:AddLabel(oA("Job", wj_2, oj), true)
    Label = SessionGroup:AddLabel(oA("Ping", "0 ms", oq), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            o9:Teleport(game.PlaceId, o5)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            pw(wf, "Copied Job ID")
        end
    })
    task.spawn(function()
        local v8_1
        local v7_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(oA("Session", wg(), oq))
            Label2:SetText(oA("Players", #oh:GetPlayers() .. "/" .. tostring(oh.MaxPlayers), oB))
            v7_1, v8_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local v7_2 = v7_1 and v8_1 .. " ms" or "n/a"
            Label:SetText(oA("Ping", v7_2, oq))
        end
    end)
    local SocialsGroup = pu.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = ph })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            pw(oG, "Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            pw(oE, "Copied website link")
        end
    })
end
pR = function()
    local MovementGroup = pu.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = pu.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local connection
    local function hN(hO)
        pcall(function()
            pd:SetGameplayPausedNotificationEnabled(not hO)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = pg:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not hO
            end
        end)
        if not hO then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(o5, "GameplayPaused", false)
            else
                o5.GameplayPaused = false
            end
        end)
    end
    local function h0(h1)
        if not h1:IsA("ProximityPrompt") then
            return
        end
        h1.HoldDuration = 0
        h1.MaxActivationDistance = 50
        h1.RequiresLineOfSight = false
    end
    pt.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if o7("NoClip") then
            local Character = o5.Character
            if Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    local wr_1 = descendant:IsA("BasePart") and descendant.CanCollide
                    if wr_1 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    pr.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if o7("InfJump") then
            local wz = oL()
            if wz then
                wz:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    pt.RenderStepped:Connect(function(ik)
        if Library.Unloaded then
            return
        end
        if o7("WalkSpeedEnabled") then
            local wB_1 = oL()
            local WalkSpeed = Options.WalkSpeed
            if wB_1 and WalkSpeed then
                wB_1.WalkSpeed = WalkSpeed.Value
            end
        end
        if o7("Fly") then
            local wB_2 = ov()
            local wC_2 = oL()
            local FlySpeed = Options.FlySpeed
            local CurrentCamera = o6.CurrentCamera
            if wB_2 and wC_2 and FlySpeed and CurrentCamera then
                wC_2.PlatformStand = true
                local wC_3 = Vector3.zero
                if pr:IsKeyDown(Enum.KeyCode.W) then
                    wC_3 += CurrentCamera.CFrame.LookVector
                end
                if pr:IsKeyDown(Enum.KeyCode.S) then
                    wC_3 -= CurrentCamera.CFrame.LookVector
                end
                if pr:IsKeyDown(Enum.KeyCode.A) then
                    wC_3 -= CurrentCamera.CFrame.RightVector
                end
                if pr:IsKeyDown(Enum.KeyCode.D) then
                    wC_3 += CurrentCamera.CFrame.RightVector
                end
                if pr:IsKeyDown(Enum.KeyCode.Space) then
                    wC_3 += Vector3.new(0, 1, 0)
                end
                if pr:IsKeyDown(Enum.KeyCode.LeftControl) then
                    wC_3 -= Vector3.new(0, 1, 0)
                end
                wB_2.AssemblyLinearVelocity = Vector3.zero
                if wC_3.Magnitude > 0 then
                    wB_2.CFrame = wB_2.CFrame + wC_3.Unit * FlySpeed.Value * ik
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local wL = oL()
            if wL then
                wL.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local wQ = oL()
            if wQ then
                wQ.WalkSpeed = 16
            end
        end
    end)
    Toggles.AntiGameplayPause:OnChanged(function()
        hN(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                hN(true)
            end
        end
    end)
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in ipairs(o6:GetDescendants()) do
                pcall(h0, descendant)
            end
            connection = o6.DescendantAdded:Connect(function(iV)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(h0, iV)
                end
            end)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    Library:OnUnload(function()
        hN(false)
        if connection then
            connection:Disconnect()
        end
    end)
end
do
    pY()
    pR()
    task.spawn(worker4)
    task.spawn(worker3)
    task.spawn(worker2)
    pX = function()
        local connection
        local MenuGroup = pu.Settings:AddLeftGroupbox("Menu")
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        local jj = 0
        local jk = tick()
        local Label
        local function jm()
            local CurrentCamera = o6.CurrentCamera
            if not CurrentCamera then
                return
            end
            po:CaptureController()
            po:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            jj += 1
            jk = tick()
            if Label then
                pcall(function()
                    Label:SetText("AFK triggers: " .. jj)
                end)
            end
        end
        connection = o5.Idled:Connect(function()
            if o7("AntiAfk") then
                pcall(jm)
            end
        end)
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        Label = MenuGroup:AddLabel("AFK triggers: 0")
        MenuGroup:AddButton({
            Text = "Unload UI",
            Func = function()
                Library:Unload()
            end
        })
        task.spawn(function()
            while not Library.Unloaded do
                task.wait(2)
                local xd = o7("AntiAfk") and tick() - jk >= 60
                if xd then
                    pcall(jm)
                end
            end
        end)
        Library:OnUnload(function()
            if connection then
                connection:Disconnect()
            end
            if getgenv then
                getgenv().__TempoRescueAnimalsLib = nil
            end
        end)
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("TempoHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(pu.Settings)
        ThemeManager:LoadDefault()
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/RescueAnimals")
        local jJ = SaveManager:BuildConfigSection(pu.Settings)
        local function jK(jL, jM)
            local xh_1 = (jL == "Toggle" and Toggles or Options)[jM]
            local xg_2 = type(xh_1) == "table" and xh_1.Type == jL
            local xg_3 = xg_2 and xh_1
            local xm = if xg_3 then 1 else 0
            local xk = 2136 * xm + 3132 * (1 - xm)
            local xl = 1938 * xm + 2426 * (1 - xm)
            if not ((xk * 2212 + xl * 460 + xk * xl) % 16777213 == 9755880) then
                xg_3 = nil
            end
            return xg_3
        end
        local function jT(jU, jV)
            local Type = jV.Type
            if Type == "Toggle" then
                return { idx = jU, type = "Toggle", value = jV.Value == true }
            elseif Type == "Slider" then
                return { idx = jU, type = "Slider", value = tostring(jV.Value) }
            elseif Type == "Dropdown" then
                return { idx = jU, type = "Dropdown", multi = jV.Multi == true, value = jV.Value }
            elseif Type == "Input" then
                local xo = jV.Value or ""
                return { idx = jU, type = "Input", text = tostring(xo) }
            elseif Type == "ColorPicker" then
                return { idx = jU, type = "ColorPicker", value = jV.Value:ToHex(), transparency = jV.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = jU,
                    type = "KeyPicker",
                    mode = jV.Mode,
                    key = jV.Value,
                    modifiers = jV.Modifiers,
                    toggled = jV.Toggled
                }
            else
                return nil
            end
        end
        local function jX()
            local xu = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local xv = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if xv then
                        local xv_1 = jT(k, v)
                        if xv_1 then
                            xu[#xu + 1] = xv_1
                        end
                    end
                end
            end
            table.sort(xu, function(j6, j7)
                if j6.type ~= j7.type then
                    return j6.type < j7.type
                end
                return j6.idx < j7.idx
            end)
            return { objects = xu }
        end
        local function j8(j9)
            local xL
            xL = nil
            local xM = type(j9) ~= "table" or type(j9.idx) ~= "string"
            local xQ = if xM then 1 else 0
            local xO = 664 * xQ + 148 * (1 - xQ)
            local xP = 805 * xQ + 962 * (1 - xQ)
            if not ((xO * 3373 + xP * 3737 + xO * xP) % 16777213 == 5782477) then
                xM = type(j9.type) ~= "string"
            end
            if not xM then
                xM = SaveManager.Ignore[j9.idx]
            end
            if xM then
                return false
            end
            xL = jK(j9.type, j9.idx)
            if not xL then
                return false
            end
            local xM_1 = pcall(function()
                if j9.type == "Input" then
                    if type(j9.text) ~= "string" then
                        return
                    end
                    xL:SetValue(j9.text)
                elseif j9.type == "ColorPicker" then
                    xL:SetValueRGB(Color3.fromHex(j9.value), j9.transparency)
                elseif j9.type == "KeyPicker" then
                    xL:SetValue({ j9.key, j9.mode, j9.modifiers })
                    if j9.mode == "Toggle" and j9.toggled ~= nil then
                        xL.Toggled = j9.toggled
                        xL:Update()
                    end
                else
                    xL:SetValue(j9.value)
                end
            end)
            return xM_1
        end
        jJ:AddDivider()
        jJ:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        jJ:AddButton({
            Text = "Export Config to Clipboard",
            Func = function()
                local xS_1
                local xR_1
                xR_1, xS_1 = pcall(pk.JSONEncode, pk, jX())
                if not xR_1 then
                    Library:Notify("Failed to encode the config")
                    return
                end
                local xR_2 = setclipboard or toclipboard
                local xR_3 = type(xR_2) ~= "function" or not pcall(xR_2, xS_1)
                if xR_3 then
                    Library:Notify("Your executor does not support copying to the clipboard")
                    return
                end
                Library:Notify("Config copied to clipboard", 6)
            end
        })
        jJ:AddButton({
            Text = "Import Config from Clipboard Text",
            Func = function()
                local xX_1
                local xV = Options.SaveManager_ImportSource.Value or ""
                local xV_1
                local xW = tostring(xV):match("^%s*(.-)%s*$")
                if xW == "" then
                    Library:Notify("Paste an exported config into the box first")
                    return
                end
                xV_1, xX_1 = pcall(pk.JSONDecode, pk, xW)
                local xW_1 = not xV_1 or type(xX_1) ~= "table" or type(xX_1.objects) ~= "table"
                if xW_1 then
                    Library:Notify("That is not a valid exported config")
                    return
                end
                local xV_2 = 0
                for i, v in ipairs(xX_1.objects) do
                    if j8(v) then
                        xV_2 += 1
                    end
                end
                if xV_2 == 0 then
                    Library:Notify("No settings in that config matched this script")
                    return
                end
                Options.SaveManager_ImportSource:SetValue("")
                local xX_2 = xV_2 == 1 and "" or "s"
                Library:Notify(("Imported %d setting%s"):format(xV_2, xX_2), 6)
            end
        })
        SaveManager:LoadAutoloadConfig()
    end
end
pX()
end)(...)

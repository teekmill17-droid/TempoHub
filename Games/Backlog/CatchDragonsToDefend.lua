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
getgenv().TempoHoodSubtitle = "CATCH DRAGONS TO DEFEND"
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
local sK
local CoreGui
local sN
local s8
local su
local sx
local te
local sW
local tk
local sk
local s1
local sG
local sJ
local s4
local EquipBest
local r4
local sP
local Rebirth
local sa
local LocalPlayer
local td
local sd
local Label
local sY
local sC
local BuyZone
local sF
local r3
local sp
local sL
local ss
local sO
local Toggles
local tc
local sR
local sy
local sU
local ClaimIndex
local sX
local ti
local sE
local si
local Library
local s2
local sH
local function fn17(gG)
    local Tokens = sE.Tokens
    local yJ = sE.Tokens[gG] or 0
    Tokens[gG] = yJ + 1
    return sE.Tokens[gG]
end
local function fn85(hL)
    sE.KeepEquipped = hL == true
end
local function fn211(f5)
    local yo = sH.Characters and sH.Characters[f5.Name]
    local yo_1 = type(yo) == "table" and type(yo.Rarity) == "number" and sx[yo.Rarity]
    local yq = yo_1 or "?"
    local yq_1 = type(yo) == "table" and type(yo.Name) == "string" and yo.Name
    local yp_1 = yq_1
    local yu = if yp_1 then 1 else 0
    local ys = 2876 * yu + 2175 * (1 - yu)
    local yt = 2419 * yu + 538 * (1 - yu)
    if not ((ys * 105 + yt * 150 + ys * yt) % 16777213 == 7621874) then
        yp_1 = f5.Name
    end
    return yp_1, yq
end
local function fn258(dT)
    local wN = type(dT) ~= "table"
    local wR = if wN then 1 else 0
    local wP = 1263 * wR + 2646 * (1 - wR)
    local wQ = 697 * wR + 2247 * (1 - wR)
    if not ((wP * 3235 + wQ * 3129 + wP * wQ) % 16777213 == 7147029) then
        wN = dT.Dead == true
    end
    if wN then
        return false
    end
    local wN_1 = type(dT.Extra) ~= "table" or dT.Extra.Name ~= "Money"
    if wN_1 then
        return false
    elseif typeof(dT.Position) ~= "Vector3" then
        return false
    else
        local CanCollect = dT.CanCollect
        if CanCollect == nil then
            return true
        elseif type(CanCollect) ~= "table" then
            return false
        else
            return table.find(CanCollect, LocalPlayer.Name) ~= nil
        end
    end
end
local function fn260(hP)
    local y8 = hP == hP
    local y9 = type(hP) == "number" and y8
    if y9 then
        sE.KeepBest = math.clamp(math.floor(hP), 0, 20)
    end
end
local function fn294(be)
    if type(be) ~= "number" then
        return false
    end
    local uQ = sx[be]
    return uQ ~= nil and sE.SelectedRarities[uQ] == true
end
local function fn376(fs)
    return string.format('<font color="%s"><b>Catch</b></font> <font color="%s">-</font> <font color="%s">%s</font>', sa, r4, sa, td(fs))
end
local function fn384(f3)
    if type(f3) ~= "number" then
        return "n/a"
    end
    return string.format("%.2f%%", f3)
end
local function fn396(hN)
    sE.KeepOneOfEach = hN == true
end
local function fn411(cz)
    local vM_1
    local vK = type(cz) ~= "table" or type(cz.Money) ~= "number"
    if vK then
        return false
    end
    local vK_1 = type(cz.Rebirth) == "number" and cz.Rebirth
    local vL = vK_1 or 0
    local vL_1
    vL_1, vM_1 = pcall(sH.GetRebirthPrice, math.max(0, math.floor(vL)))
    local vK_3 = vL_1 and type(vM_1) == "number" and cz.Money >= vM_1
    return vK_3
end
local function fn415(hD)
    local y0 = sd[hD]
    if y0 then
        sE.CatchBall = y0
    end
end
local function fn417(hA)
    sE.SellRarities = sK(hA)
end
local function fn443()
    local CharacterSpawns = sN:FindFirstChild("CharacterSpawns")
    local uI = CharacterSpawns and CharacterSpawns:FindFirstChild("Characters")
    return uI
end
local function fn452(en)
    local xd = {}
    if type(en) == "table" then
        for k, v in en do
            local xe_1 = v == true and type(k) == "string" and ss[k]
            if xe_1 then
                xd[k] = true
            else
                local xe_2 = type(v) == "string" and ss[v]
                if xe_2 then
                    xd[v] = true
                end
            end
        end
    else
        local xe_3 = type(en) == "string" and ss[en]
        if xe_3 then
            xd[en] = true
        end
    end
    return xd
end
local function fn551()
    local Character = LocalPlayer.Character
    local uC = Character and Character:FindFirstChildOfClass("Humanoid")
    return uC
end
local function fn571(hx)
    sE.SelectedRarities = sK(hx)
end
local function fn573()
    return sE.Status
end
local function fn604(hJ)
    local y5 = hJ == hJ
    local y6 = type(hJ) == "number" and y5
    if y6 then
        sE.SellDelay = math.clamp(hJ, 0.2, 5)
    end
end
local function fn681()
    local CatchGroup = sF.Main:AddLeftGroupbox("Catch", "target")
    Label = CatchGroup:AddLabel(s8("Idle"), true)
    CatchGroup:AddDivider()
    CatchGroup:AddToggle("AutoCatch", {
        Text = "Auto Catch",
        Default = false,
        Callback = function(iu)
            tc.SetFlag("AutoCatch", iu)
        end
    })
    CatchGroup:AddDropdown("CatchRarities", {
        Text = "Rarity Filter",
        Values = sx,
        Multi = true,
        Default = sx,
        Expandable = true,
        Callback = function(iy)
            tc.SetSelectedRarities(iy)
        end
    })
    CatchGroup:AddDropdown("CatchBall", {
        Text = "Capture Ball",
        Values = si,
        Default = 1,
        Callback = function(iB)
            tc.SetCatchBall(iB)
        end
    })
    CatchGroup:AddSlider("CatchDelay", {
        Text = "Catch Delay",
        Default = 0.45,
        Min = 0.2,
        Max = 3,
        Rounding = 2,
        Suffix = "s",
        Callback = function(iD)
            tc.SetCatchDelay(iD)
        end
    })
    tc.SetSelectedRarities(sx)
    tc.SetCatchBall(si[1])
    sU("Idle")
    local SellGroup = sF.Main:AddLeftGroupbox("Sell", "coins")
    SellGroup:AddToggle("AutoSell", {
        Text = "Auto Sell Characters",
        Default = false,
        Callback = function(iH)
            tc.SetFlag("AutoSell", iH)
        end
    })
    local iJ = SellGroup:AddDependencyBox()
    iJ:AddDropdown("SellRarities", {
        Text = "Sell Rarities",
        Values = sx,
        Multi = true,
        Default = { "Common" },
        Expandable = true,
        Callback = function(iK)
            tc.SetSellRarities(iK)
        end
    })
    iJ:AddToggle("KeepEquipped", {
        Text = "Keep Equipped",
        Default = true,
        Callback = function(iM)
            tc.SetKeepEquipped(iM)
        end
    })
    iJ:AddToggle("KeepOneOfEach", {
        Text = "Keep One Of Each",
        Default = false,
        Callback = function(iO)
            tc.SetKeepOneOfEach(iO)
        end
    })
    iJ:AddSlider("KeepBest", {
        Text = "Keep Best",
        Default = 0,
        Min = 0,
        Max = 10,
        Rounding = 0,
        Callback = function(iQ)
            tc.SetKeepBest(iQ)
        end
    })
    iJ:AddSlider("SellDelay", {
        Text = "Sell Delay",
        Default = 0.5,
        Min = 0.2,
        Max = 3,
        Rounding = 2,
        Suffix = "s",
        Callback = function(iS)
            tc.SetSellDelay(iS)
        end
    })
    iJ:SetupDependencies({ { Toggles.AutoSell, true } })
    tc.SetSellRarities({ "Common" })
    tc.SetKeepEquipped(true)
    tc.SetKeepOneOfEach(false)
    tc.SetKeepBest(0)
    tc.SetSellDelay(0.5)
    local AutomationGroup = sF.Main:AddRightGroupbox("Automation", "bot")
    AutomationGroup:AddToggle("AutoRebirth", {
        Text = "Auto Rebirth",
        Default = false,
        Callback = function(iW)
            tc.SetFlag("AutoRebirth", iW)
        end
    })
    AutomationGroup:AddToggle("AutoEquipBest", {
        Text = "Auto Equip Best",
        Default = false,
        Callback = function(iY)
            tc.SetFlag("AutoEquipBest", iY)
        end
    })
    AutomationGroup:AddToggle("AutoBuyUpgrades", {
        Text = "Auto Buy Affordable Upgrades",
        Default = false,
        Callback = function(i_)
            tc.SetFlag("AutoBuyUpgrades", i_)
        end
    })
    AutomationGroup:AddToggle("AutoBuyZones", {
        Text = "Auto Buy Zones",
        Default = false,
        Callback = function(i1)
            tc.SetFlag("AutoBuyZones", i1)
        end
    })
    AutomationGroup:AddToggle("AutoClaimIndex", {
        Text = "Auto Claim Index",
        Default = false,
        Callback = function(i3)
            tc.SetFlag("AutoClaimIndex", i3)
        end
    })
    AutomationGroup:AddToggle("AutoBuyBalls", {
        Text = "Auto Buy Capture Balls",
        Default = false,
        Callback = function(i5)
            tc.SetFlag("AutoBuyBalls", i5)
        end
    })
    AutomationGroup:AddToggle("AutoCollectGold", {
        Text = "Auto Collect Dropped Gold",
        Default = false,
        Callback = function(i7)
            tc.SetFlag("AutoCollectGold", i7)
        end
    })
end
local function fn684(cU, cV, cW, cX)
    local vW = cX > 6 or type(cV) ~= "string"
    if vW then
        return
    end
    local vW_1 = sH.Upgrades and sH.Upgrades[cV]
    if type(vW_1) ~= "table" then
        return
    end
    for k, v in pairs(vW_1) do
        if type(v) == "table" then
            local vW_2 = sH.UpgradeState(cU, cV, k)
            local vX_1 = vW_2 == "Unlocked" and type(v.Price) == "number" and sX(cU, v) >= v.Price
            if vX_1 then
                table.insert(cW, { menu = cV, id = k, price = v.Price })
            end
            if type(v.SubMenu) == "string" then
                sk(cU, v.SubMenu, cW, cX + 1)
            end
        end
    end
end
local function fn725(fq)
    return (tostring(fq):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
end
local function fn729(h2, h3)
    local zg = s2(setclipboard) and setclipboard
    local zh = zg
    if not zh then
        local zg_1 = s2(toclipboard) and toclipboard
        zh = zg_1 or nil
    end
    local zg_2 = zh
    if type(zg_2) ~= "function" then
        Library:Notify("Clipboard unavailable", 4)
        return
    end
    if pcall(zg_2, tostring(h2)) then
        local zg_3 = h3 or "Copied"
        Library:Notify(zg_3, 4)
    else
        Library:Notify("Clipboard copy failed", 4)
    end
end
local function fn827(cr)
    local vE = type(cr) ~= "table" or type(cr.MaxZone) ~= "number"
    local vJ = if vE then 1 else 0
    local vH = 1532 * vJ + 3364 * (1 - vJ)
    local vI = 272 * vJ + 875 * (1 - vJ)
    if not ((vH * 2961 + vI * 237 + vH * vI) % 16777213 == 5017420) then
        vE = type(cr.Money) ~= "number"
    end
    if vE then
        return false
    end
    local Zones = sH.Zones
    if type(Zones) ~= "table" then
        return false
    end
    if cr.MaxZone >= #Zones then
        return false
    end
    local vF_1 = Zones[cr.MaxZone]
    local vE_2 = type(vF_1) ~= "table" or type(vF_1.Price) ~= "number"
    if vE_2 then
        return false
    end
    return cr.Money >= vF_1.Price
end
local function fn835()
    ti(sG, "Copied Discord invite")
end
local function fn842(bv, bw)
    local u5_1
    local u4_1
    if bw == "Capture1" then
        u4_1, u5_1 = pcall(sH.GetModifiers, bv.Upgrades)
        local u6 = u4_1 and type(u5_1) == "table" and u5_1.UnlockCapture1 == true
        if u6 then
            return true
        end
        return false
    end
    local Inventory = bv.Inventory
    local u5_2 = type(Inventory) == "table" and Inventory[bw]
    local u5_3 = type(u5_2) == "number" and u5_2 > 0
    return u5_3
end
local function fn879()
    return CoreGui
end
local function fn888(ij)
    local DiscordGroup = ij:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = sR })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = sR })
end
local function fn891()
    gethui = r3
end
local function fn924()
    return sE.CatchStatus
end
local function fn927(fx)
    sE.CatchStatus = tostring(fx)
    if Label then
        pcall(function()
            Label:SetText(s8(sE.CatchStatus))
        end)
    end
end
local function fn974(hH)
    local y2 = hH == hH
    local y3 = type(hH) == "number" and y2
    if y3 then
        sE.CatchDelay = math.clamp(hH, 0.2, 5)
    end
end
local function fn995()
    local Character = LocalPlayer.Character
    local uw = Character and Character:FindFirstChild("HumanoidRootPart")
    return uw
end
local function fn1012(bM)
    return bM:GetAttribute("CaughtBy" .. tostring(LocalPlayer.UserId)) == true
end
local function fn1022(aj)
    return type(aj) == "function"
end
local function fn1039()
    local wy_1, wy_2, wy_3
    local DestroyAllDrops = sO.DestroyAllDrops
    local ww_3
    if type(DestroyAllDrops) ~= "function" then
        return nil
    end
    local wx = type(debug) == "table" and type(debug.getupvalue) == "function"
    local wx_1, wx_2, wx_3
    if wx then
        wx_1, wy_1 = pcall(debug.getupvalue, DestroyAllDrops, 1)
        local wz = wx_1 and type(wy_1) == "table"
        if wz then
            return wy_1
        end
        if type(getupvalues) == "function" then
            wx_2, wy_2 = pcall(getupvalues, DestroyAllDrops)
            if ww_3 then
                for k, v in pairs(wy_2) do
                    if type(v) == "table" then
                        for k, v2 in pairs(v) do
                            local ww_2 = type(v2) == "table" and type(v2.Extra) == "table" and v2.Extra.Name == "Money"
                            if ww_2 then
                                return v
                            end
                        end
                    end
                end
            end
        end
        return nil
    end
    if type(getupvalues) == "function" then
        wx_3, wy_3 = pcall(getupvalues, DestroyAllDrops)
        ww_3 = wx_3 and type(wy_3) == "table"
        if ww_3 then
            for k, v in pairs(wy_3) do
                if type(v) == "table" then
                    for k, v2 in pairs(v) do
                        local ww_4 = type(v2) == "table" and type(v2.Extra) == "table" and v2.Extra.Name == "Money"
                        if ww_4 then
                            return v
                        end
                    end
                end
            end
        end
    end
    return nil
end
local function fn1073()
    local us_1
    local ur_1
    if not sW() then
        return nil
    end
    ur_1, us_1 = pcall(sH.GetData)
    local ut = ur_1 and type(us_1) == "table"
    if ut then
        return us_1
    end
    return nil
end
local function fn1077(ew)
    local xp = {}
    local Equipped = ew.Equipped
    local xr = sE.KeepEquipped and type(Equipped) == "table"
    if xr then
        for i, v in ipairs(Equipped) do
            xp[v] = true
        end
    end
    local KeepBest = sE.KeepBest
    local xr_1 = type(KeepBest) == "number" and KeepBest > 0 and type(ew.Characters) == "table" and type(ew.Characters.Entries) == "table"
    if xr_1 then
        local xr_2 = {}
        for k, v in pairs(ew.Characters.Entries) do
            local xs_1 = type(v) == "table" and type(v.Name) == "string"
            if xs_1 then
                local xs_2 = sH.Characters and sH.Characters[v.Name]
                local xs_3 = type(xs_2) == "table" and type(xs_2.Damage) == "number" and xs_2.Damage
                local xt_1 = xs_3 or 0
                table.insert(xr_2, { id = k, damage = xt_1 })
            end
        end
        table.sort(xr_2, function(eO, eP)
            return eO.damage > eP.damage
        end)
        local xs_5 = math.min(KeepBest, #xr_2)
        local xM = 1
        while xM <= xs_5 do
            local xN = xM
            xp[xr_2[xN].id] = true
            xM += 1
        end
    end
    return xp
end
local function fn1125(ag)
    local up = typeof(cloneref) == "function" and typeof(ag) == "Instance"
    if up then
        return cloneref(ag)
    end
    return ag
end
local function fn1195(cI, cJ)
    local vO = cJ.PriceType or "Coins"
    local UpgradePriceTypes = sH.UpgradePriceTypes
    local vQ = type(UpgradePriceTypes) == "table" and (UpgradePriceTypes[vO] or UpgradePriceTypes.Coins)
    local vP_1 = type(vQ) ~= "table" or type(vQ.DataKey) ~= "string"
    if vP_1 then
        return cI.Money or 0
    end
    local vP_3 = cI[vQ.DataKey]
    local vO_3 = type(vP_3) == "number" and vP_3
    return vO_3 or 0
end
local function fn1209(a8)
    if typeof(a8) ~= "Instance" then
        return nil
    end
    local uK = sH.Characters and sH.Characters[a8.Name]
    local uK_1 = type(uK) == "table" and type(uK.Rarity) == "number"
    if uK_1 then
        return uK.Rarity
    end
    return nil
end
local function fn1214()
    for k in pairs(sE.Flags) do
        sE.Flags[k] = false
        sL(k)
    end
end
local function fn1247(bG)
    local CatchBall = sE.CatchBall
    if sY(bG, CatchBall) then
        return CatchBall
    end
    local vc = CatchBall ~= "Capture1" and sY(bG, "Capture1")
    if vc then
        return "Capture1"
    end
    return nil
end
local function fn1274(ch)
    if type(ch) ~= "table" then
        return false
    end
    local vx = sH.GetIndexRewards("Base")
    if type(vx) ~= "table" then
        return false
    end
    local vy = 0
    local vz = type(ch.IndexClaimed) == "table" and type(ch.IndexClaimed.Base) == "number"
    if vz then
        vy = math.max(0, math.floor(ch.IndexClaimed.Base))
    end
    local vz_1 = vx[vy + 1]
    local vx_1 = type(vz_1) ~= "table" or type(vz_1[1]) ~= "number"
    if vx_1 then
        return false
    end
    local vx_2 = sH.GetIndexUniqueCount(ch, "Base")
    local vy_1 = type(vx_2) == "number" and vx_2 >= vz_1[1]
    return vy_1
end
local function fn1294(gZ, g_)
    if sE.Flags[gZ] == nil then
        return
    end
    sE.Flags[gZ] = g_ == true
    if not sE.Flags[gZ] then
        sL(gZ)
        if gZ == "AutoCatch" then
            sU("Idle")
        end
        return
    end
    if gZ == "AutoCatch" then
        sU("Searching")
        sC(gZ, sE.CatchDelay, s4)
    elseif gZ == "AutoRebirth" then
        sC(gZ, 1, function()
            local yU = su()
            local yV = yU and tk(yU)
            if yV then
                Rebirth:FireServer()
            end
        end)
    elseif gZ == "AutoEquipBest" then
        sC(gZ, 2, function()
            EquipBest:FireServer()
        end)
    elseif gZ == "AutoBuyUpgrades" then
        sC(gZ, 0.75, sP)
    elseif gZ == "AutoBuyZones" then
        sC(gZ, 1, function()
            local yR = su()
            local yS = yR and sy(yR)
            if yS then
                BuyZone:FireServer()
            end
        end)
    elseif gZ == "AutoClaimIndex" then
        sC(gZ, 1.5, function()
            local yO = su()
            local yP = yO and s1(yO)
            if yP then
                ClaimIndex:FireServer("Base")
            end
        end)
    elseif gZ == "AutoBuyBalls" then
        sC(gZ, 1.25, te)
    elseif gZ == "AutoCollectGold" then
        sC(gZ, 0.35, sJ)
    elseif gZ == "AutoSell" then
        sC(gZ, sE.SellDelay, sp)
    end
end
local function fn1306()
    return not tc.Unloaded
end
r3 = nil
r4 = nil
Toggles = nil
sa = nil
sd = nil
ClaimIndex = nil
Label = nil
si = nil
BuyZone = nil
sk = nil
Library = nil
sp = nil
EquipBest = nil
ss = nil
Rebirth = nil
su = nil
sx = nil
sy = nil
sC = nil
sE = nil
sF = nil
sG = nil
sH = nil
sJ = nil
sK = nil
sL = nil
sN = nil
sO = nil
sP = nil
local Players, r5, r7, r8, BuyItem, SaveManager, sc, se, sh, sm, BuyUpgrade, so, sr, sv, sw, AttemptCatch, sA, sB, sD, sI, sM
sR = nil
LocalPlayer = nil
sU = nil
sW = nil
sX = nil
sY = nil
s1 = nil
s2 = nil
s4 = nil
CoreGui = nil
s8 = nil
tc = nil
td = nil
te = nil
ti = nil
tk = nil
local sQ, CollectDrop, Workspace, Lighting, s_, TeleportService, s3, SellCharacter, s7, s9, ta, tb, tf, tg, th, tj, tl, Options, ts, tw
if not game:IsLoaded() then
    game.Loaded:Wait()
end
Players, th, tg, ta, s9, s7, CoreGui, TeleportService, Lighting, Workspace, LocalPlayer, sM, sG, sD, sB, sx, ss = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
if (s7 and not s9 or s7 and s9 or s7 and not s7 and (s9 and s7)) and not (s7 and not s9 or s7 and s9 or s7 and not s7 and (s9 and s7)) then
    tg = game:GetService("RunService")
    th = game:GetService("UserInputService")
    s9 = game:GetService("VirtualUser")
    s7 = game:GetService("HttpService")
    ta = game:GetService("GuiService")
else
    th = game:GetService("RunService")
    tg = game:GetService("UserInputService")
    ta = game:GetService("VirtualUser")
    s9 = game:GetService("HttpService")
    s7 = game:GetService("GuiService")
end
CoreGui = game:GetService("CoreGui")
TeleportService = game:GetService("TeleportService")
Lighting = game:GetService("Lighting")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local to = "TempoCatchDragons"
local to_3
sM = "Catch Dragons To Defend"
local tq = "v0.4"
sG = "https://discord.gg/K7Qxnxkk46"
sD = "https://discord.gg/K7Qxnxkk46"
sB = "https://tempohub.shop"
sx = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Fabled" }
if (false or not s7 or not s7 and not s7 or not TeleportService and ss and (tq and not s7) or (not TeleportService and 6 and false or (tq or (TeleportService or sG)))) and (sG and s7 and 6 and (6 or (tq or s7)) or (ss and false and (s7 and not s7) or (sG or (false or not s7)))) and not ((false or not s7 or not s7 and not s7 or not TeleportService and ss and (tq and not s7) or (not TeleportService and 6 and false or (tq or (TeleportService or sG)))) and (sG and s7 and 6 and (6 or (tq or s7)) or (ss and false and (s7 and not s7) or (sG or (false or not s7))))) then
    sG = {}
else
    ss = {}
end
for i, v in ipairs(sx) do
    ss[v] = i
end
si, sd, r7, r3 = nil, nil, nil, nil
si = {
    "Basic Capture Ball",
    "Advanced Capture Ball",
    "Elite Capture Ball",
    "Supreme Capture Ball",
    "Apex Capture Ball"
}
sd = {
    ["Basic Capture Ball"] = "Capture1",
    ["Advanced Capture Ball"] = "Capture2",
    ["Elite Capture Ball"] = "Capture3",
    ["Supreme Capture Ball"] = "Capture4",
    ["Apex Capture Ball"] = "Capture5"
}
r7 = { "Capture2", "Capture3", "Capture4", "Capture5" }
r3 = fn879
if getgenv then
    getgenv().gethui = r3
end
tc, sN, sH, s2, sW = nil, nil, nil, nil, nil
pcall(fn891)
local function tr(F)
    local ue
    local uf
    local ud
    ud = nil
    ue = nil
    uf = nil
    local ug = F ~= ""
    local uh = type(F) == "string" and ug
    assert(uh, "A namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    uf = getgenv()
    assert(type(uf) == "table", "getgenv did not return a table")
    local ug_1 = uf[F]
    if ug_1 ~= nil then
        local uh_1 = type(ug_1) == "table" and type(ug_1.Unload) == "function"
        assert(uh_1, "Namespace is occupied")
        ug_1.Unload()
        assert(uf[F] == nil, "Previous instance did not release its namespace")
    end
    ue = {}
    ud = { State = {}, Unloaded = false }
    ud.Track = function(L)
        assert(type(L) == "function", "Cleanup must be callable")
        if ud.Unloaded then
            L()
        else
            table.insert(ue, L)
        end
        return L
    end
    ud.Unload = function()
        local t3_1
        local t2_1
        if ud.Unloaded then
            return
        end
        ud.Unloaded = true
        local t0 = {}
        local t7 = #ue
        local t6 = -1
        while false and t7 <= 1 or true and t7 >= 1 do
            local t8 = t7
            local t1_1 = table.remove(ue, t8)
            t2_1, t3_1 = pcall(t1_1)
            if not t2_1 then
                table.insert(t0, tostring(t3_1))
            end
            t7 += t6
        end
        table.clear(ud.State)
        if #t0 > 0 then
            error("Cleanup incomplete: " .. table.concat(t0, "; "), 0)
        end
        if uf[F] == ud then
            uf[F] = nil
        end
    end
    uf[F] = ud
    return ud
end
local function tv(Y, Z)
    local un = type(Y) == "table" and type(Y.Track) == "function"
    assert(un, "FeatureAPI required")
    local un_1 = type(Z) == "table" and type(Z.OnUnload) == "function"
    assert(un_1, "UI library required")
    assert(type(Z.Unload) == "function", "UI unload required")
    Y.Track(function()
        if not Z.Unloaded then
            Z:Unload()
        end
    end)
    Z:OnUnload(function()
        Y.Unload()
    end)
end
tc = tr(to)
local tu = fn1125
s2 = fn1022
sW = fn1306
local tt = tu(ReplicatedStorage)
sN = tu(Workspace)
local tn = tu(tt:WaitForChild("Services", 30))
assert(tn, "ReplicatedStorage.Services missing")
sH = require(tn)
assert(type(sH) == "table", "Services require failed")
assert(type(sH.GetData) == "function", "Services.GetData missing")
local tn_1 = type(sH.Remotes) == "userdata"
if not tn_1 then
    local to_1 = 4
    repeat
        if to_1 * 10172373 + 9 + 4 >= to_1 * 10172373 + 9 + 4 + 2 then
            sH = typeof(tn_1.Remotes) == "Instance"
        else
            tn_1 = typeof(sH.Remotes) == "Instance"
        end
        to_1 = (to_1 + 4) % 8
    until (to_1 * 5 + 7) % 8 == 7
end
AttemptCatch, Rebirth, EquipBest, BuyUpgrade, BuyZone, ClaimIndex, BuyItem = nil, nil, nil, nil, nil, nil, nil
assert(tn_1, "Services.Remotes missing")
tr = sH.Remotes
if (BuyUpgrade and not BuyUpgrade and (not Rebirth and not BuyItem) or (Rebirth or false) or ((BuyItem or 46) and (not BuyItem or BuyUpgrade) or BuyUpgrade and BuyItem and (BuyUpgrade and not BuyItem)) or (Rebirth and false or (not Rebirth or not Rebirth or not Rebirth)) and false) and not (BuyUpgrade and not BuyUpgrade and (not Rebirth and not BuyItem) or (Rebirth or false) or ((BuyItem or 46) and (not BuyItem or BuyUpgrade) or BuyUpgrade and BuyItem and (BuyUpgrade and not BuyItem)) or (Rebirth and false or (not Rebirth or not Rebirth or not Rebirth)) and false) then
    tr = AttemptCatch:WaitForChild("AttemptCatch", 10)
else
    AttemptCatch = tr:WaitForChild("AttemptCatch", 10)
end
Rebirth = tr:WaitForChild("Rebirth", 10)
EquipBest = tr:WaitForChild("EquipBest", 10)
BuyUpgrade = tr:WaitForChild("BuyUpgrade", 10)
BuyZone = tr:WaitForChild("BuyZone", 10)
ClaimIndex = tr:WaitForChild("ClaimIndex", 10)
if (not BuyUpgrade and AttemptCatch and (BuyZone or not BuyZone) or (not tr or not tr) and (not BuyZone or BuyUpgrade) or not AttemptCatch and not tr and (BuyUpgrade or not BuyZone) and (BuyItem and tr and (BuyZone or BuyZone))) and not (not BuyUpgrade and AttemptCatch and (BuyZone or not BuyZone) or (not tr or not tr) and (not BuyZone or BuyUpgrade) or not AttemptCatch and not tr and (BuyUpgrade or not BuyZone) and (BuyItem and tr and (BuyZone or BuyZone))) then
    tr = BuyItem:WaitForChild("BuyItem", 10)
else
    BuyItem = tr:WaitForChild("BuyItem", 10)
end
local tn_2 = AttemptCatch and AttemptCatch:IsA("RemoteFunction")
assert(tn_2, "AttemptCatch missing")
local tn_3 = Rebirth and Rebirth:IsA("RemoteEvent")
assert(tn_3, "Rebirth missing")
local tn_4 = EquipBest and EquipBest:IsA("RemoteEvent")
assert(tn_4, "EquipBest missing")
local tn_5 = BuyUpgrade and BuyUpgrade:IsA("RemoteFunction")
assert(tn_5, "BuyUpgrade missing")
local tn_6 = BuyZone and BuyZone:IsA("RemoteEvent")
assert(tn_6, "BuyZone missing")
local tn_7 = ClaimIndex and ClaimIndex:IsA("RemoteEvent")
assert(tn_7, "ClaimIndex missing")
local tn_8 = BuyItem and BuyItem:IsA("RemoteEvent")
SellCharacter = nil
local to_2 = 0
repeat
    if (not SellCharacter or not SellCharacter or not to_2 and to_2 or to_2 and not SellCharacter and (not SellCharacter and SellCharacter)) and not (not SellCharacter or not SellCharacter or not to_2 and to_2 or to_2 and not SellCharacter and (not SellCharacter and SellCharacter)) then
        assert(SellCharacter, "BuyItem missing")
        tr = tn_8:WaitForChild("SellCharacter", 10)
    else
        assert(tn_8, "BuyItem missing")
        SellCharacter = tr:WaitForChild("SellCharacter", 10)
    end
    to_2 = (to_2 + 2) % 8
until (to_2 * 5 + 2) % 8 == 4
local tn_9 = SellCharacter and SellCharacter:IsA("RemoteEvent")
to_3, tr, CollectDrop = nil, nil, nil
local tp_1 = 16
repeat
    ts = (tp_1 * 1 + 1) % 3 + 1
    if ts <= 2 then
        if ts <= 1 then
            ts = (vector.create((tp_1 * 2 + 5) % 11 + 1, (tp_1 * 5 + 1) % 13 + 1, (tp_1 * 12 + 7) % 17 + 1))
            tw = (vector.create((tp_1 * 1 + 8) % 11 + 1, (tp_1 * 6 + 13) % 13 + 1, (tp_1 * 14 + 15) % 17 + 1))
            local tx = (vector.create((tp_1 * 1 + 1) % 11 + 1, (tp_1 * 6 + 3) % 13 + 1, (tp_1 * 3 + 14) % 17 + 1))
            local ty = (vector.create((tp_1 * 5 + 2) % 5 + 1, (tp_1 * 4 + 1) % 7 + 1, (tp_1 * 2 + 1) % 9 + 1))
            if vector.dot(vector.cross(ts, (vector.cross(tw, tx))), ty) == vector.dot(tw * vector.dot(ts, tx) - tx * vector.dot(ts, tw), ty) + 5 then
                assert(tr, "ReplicatedStorage.Modules missing")
                tu = to_3(tr:WaitForChild("DropModule", 30))
            else
                assert(to_3, "ReplicatedStorage.Modules missing")
                tr = tu(to_3:WaitForChild("DropModule", 30))
            end
            tp_1 = (tp_1 + 13) % 24
        else
            ts = (vector.create((tp_1 * 6 + 2) % 11 + 1, (tp_1 * 7 + 5) % 13 + 1, (tp_1 * 10 + 3) % 17 + 1))
            tw = (vector.create((tp_1 * 2 + 6) % 11 + 1, (tp_1 * 3 + 4) % 13 + 1, (tp_1 * 1 + 1) % 17 + 1))
            local Fv = vector.dot(ts, tw)
            if Fv * Fv <= vector.dot(ts, ts) * vector.dot(tw, tw) then
                assert(tr, "DropModule missing")
                CollectDrop = tr:WaitForChild("CollectDrop", 10)
            else
                assert(CollectDrop, "DropModule missing")
                tr = CollectDrop:WaitForChild("CollectDrop", 10)
            end
            tp_1 = (tp_1 + 16) % 24
        end
    else
        if tp_1 * 101271647 + 12 + 2 >= tp_1 * 101271647 + 12 + 2 + 2 then
            assert(tu, "SellCharacter missing")
            tt = tn_9(to_3:WaitForChild("Modules", 30))
        else
            assert(tn_9, "SellCharacter missing")
            to_3 = tu(tt:WaitForChild("Modules", 30))
        end
        tp_1 = (tp_1 + 4) % 24
    end
until (tp_1 * 11 + 6) % 24 == 17
local tn_10 = CollectDrop and CollectDrop:IsA("RemoteEvent")
sO = nil
local to_4 = 6
repeat
    local Fw = bit32.rrotate(bit32.bxor(bit32.lrotate(to_4, 2), string.byte(tostring(sO))), 19)
    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(Fw, 788507509), 1239733987), (bit32.bxor(bit32.band(Fw, 3506459786), 1003944096))), 1239733987), 1003944096) == Fw then
        assert(tn_10, "CollectDrop missing")
        sO = require(tr)
    else
        assert(sO, "CollectDrop missing")
        tr = require(tn_10)
    end
    to_4 = (to_4 + 5) % 8
until (to_4 * 3 + 7) % 8 == 0
local tn_11 = type(sO) == "table"
if tn_11 then
    local to_5 = 1
    repeat
        local tp_2 = {
            "hxhiuych",
            "qbx",
            "pdd",
            "szmfjaiopj",
            "cmzbhomyo",
            "adfmffxz",
            "egm",
            "aami",
            "lhmgoesqxe",
            "tvsudxlzds",
            "jtechbte",
            "msxo"
        }
        local EI = to_5
        tr = tp_2[EI % 12 + 1]
        if tr:len() >= tr:reverse():rep(EI % 3 + 2):len() then
            sO = type(tn_11.DestroyAllDrops) == "function"
        else
            tn_11 = type(sO.DestroyAllDrops) == "function"
        end
        to_5 = (to_5 + 1) % 4
    until (to_5 * 1 + 1) % 4 == 3
end
sI, sE = nil, nil
local tp_3 = 6
repeat
    local to_6 = {
        "cwrnej",
        "imx",
        "vpvmndgck",
        "yufkzdk",
        "bvwxszoub",
        "nwxuprlp",
        "ugku",
        "wmkyivkyhq",
        "zkqtdqnmpwf",
        "vppbnni",
        "rvnbg",
        "tttwsrofdmc",
        "ssdr",
        "ymsm",
        "skhbpofksc"
    }
    if to_6[(tp_3 * 24 + 8) % 15 + 1] < to_6[(tp_3 * 24 + 8) % 15 + 1] then
        assert(sE, "DropModule require failed")
        tn_11 = 18
        sI = {
            CatchBall = "Capture1",
            Flags = {
                AutoEquipBest = false,
                AutoBuyBalls = false,
                AutoCollectGold = false,
                AutoRebirth = false,
                AutoBuyUpgrades = false,
                AutoSell = false,
                AutoClaimIndex = false,
                AutoBuyZones = false,
                AutoCatch = false
            },
            SelectedRarities = {},
            CatchDelay = 0.45,
            KeepBest = 0,
            Tokens = {},
            SellRarities = {},
            Status = "Ready",
            KeepEquipped = true,
            CatchStatus = "Idle",
            KeepOneOfEach = false,
            SellDelay = 0.5
        }
    else
        assert(tn_11, "DropModule require failed")
        sI = 18
        sE = {
            Flags = {
                AutoCatch = false,
                AutoRebirth = false,
                AutoEquipBest = false,
                AutoBuyUpgrades = false,
                AutoBuyZones = false,
                AutoClaimIndex = false,
                AutoBuyBalls = false,
                AutoCollectGold = false,
                AutoSell = false
            },
            SelectedRarities = {},
            SellRarities = {},
            CatchBall = "Capture1",
            CatchDelay = 0.45,
            SellDelay = 0.5,
            KeepEquipped = true,
            KeepOneOfEach = false,
            KeepBest = 0,
            Status = "Ready",
            CatchStatus = "Idle",
            Tokens = {}
        }
    end
    tp_3 = (tp_3 + 7) % 8
until (tp_3 * 7 + 1) % 8 == 4
for i, v in ipairs(sx) do
    sE.SelectedRarities[v] = true
end
Label, sa, r4, tl, su, r5, tf, s3, sQ, sA, sc, sY, so, tj, tb, r8, s1, sy, tk, sX, sk, sP, te, sw, s_, sJ, sK, se, sp = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
sE.SellRarities.Common = true
su = fn1073
r5 = fn995
tf = fn551
s3 = fn443
sQ = fn1209
sA = fn294
sc = function(bk)
    local uV_1
    local uU_1
    local uT = type(bk) ~= "table" or type(bk.Characters) ~= "table" or type(bk.Characters.Entries) ~= "table"
    if uT then
        return false
    end
    local uT_1 = 0
    for k in pairs(bk.Characters.Entries) do
        uT_1 += 1
    end
    uU_1, uV_1 = pcall(function()
        return sH.Stats.GetStat("PenSize", sH.Player, bk)
    end)
    local uW = not uU_1
    local u3 = if uW then 1 else 0
    local u1 = 767 * u3 + 1981 * (1 - u3)
    local u2 = 1994 * u3 + 1732 * (1 - u3)
    if not ((u1 * 1210 + u2 * 1350 + u1 * u2) % 16777213 == 5149368) then
        uW = type(uV_1) ~= "number"
    end
    if uW then
        return false
    end
    return uT_1 >= uV_1
end
sY = fn842
so = fn1247
tj = fn1012
tb = function()
    local vj_1
    local ve = s3()
    if not ve then
        return nil
    end
    local vf = r5()
    if not vf then
        return nil
    end
    local vg = math.huge
    local vh
    for i, child in ve:GetChildren() do
        local vr = child
        local vi = vr:IsA("Model") and vr.Parent == ve and not tj(vr)
        local vi_2
        if vi then
            local vi_1 = sQ(vr)
            if sA(vi_1) then
                vi_2, vj_1 = pcall(function()
                    return vr:GetPivot()
                end)
                local vk = vi_2 and typeof(vj_1) == "CFrame"
                if vk then
                    local Magnitude = (vf.Position - vj_1.Position).Magnitude
                    if Magnitude < vg then
                        vh = vr
                        vg = Magnitude
                    end
                end
            end
        end
    end
    return vh
end
r8 = function(b8)
    local vu_1
    local vs = r5()
    local vt = not vs or not b8 or not b8.Parent
    local vt_1
    if vt then
        return false
    end
    vt_1, vu_1 = pcall(function()
        return b8:GetPivot()
    end)
    local vv = not vt_1 or typeof(vu_1) ~= "CFrame"
    if vv then
        return false
    end
    vs.CFrame = vu_1 * CFrame.new(0, 0, 5)
    return true
end
s1 = fn1274
sy = fn827
tk = fn411
sX = fn1195
sk = fn684
sP = function()
    local v7
    local v8 = su()
    local v8_1
    if not v8 then
        return false
    end
    local v9 = {}
    local v9_1
    local wb = sH.Upgrades or {}
    for k, v in pairs(wb) do
        local wa_1 = type(k) == "string" and type(v) == "table"
        if wa_1 then
            sk(v8, k, v9, 0)
        end
    end
    if #v9 == 0 then
        return false
    end
    table.sort(v9, function(de, df)
        return de.price < df.price
    end)
    v7 = v9[1]
    v8_1, v9_1 = pcall(function()
        return BuyUpgrade:InvokeServer(v7.menu, v7.id)
    end)
    return v8_1 and v9_1 == true
end
te = function()
    local wm = su()
    local wn = not wm or type(wm.Money) ~= "number"
    if wn then
        return false
    end
    for i, v in ipairs(r7) do
        local wv = v
        local wn_1 = sH.Items and sH.Items[wv]
        local wn_2 = type(wn_1) == "table" and type(wn_1.Price) == "number" and type(wn_1.BuyProduct) ~= "string"
        if wn_2 then
            if wm.Money >= wn_1.Price then
                local wn_3 = pcall(function()
                    BuyItem:FireServer(wv)
                end)
                if wn_3 then
                    return true
                end
            end
        end
    end
    return false
end
sw = fn1039
s_ = fn258
sJ = function()
    local wS = sw()
    if type(wS) ~= "table" then
        sE.Status = "Drop registry unavailable"
        return false
    end
    local wT = r5()
    if not wT then
        return false
    end
    local wU = math.huge
    local wV
    for k, v in pairs(wS) do
        if s_(v) then
            local Magnitude = (wT.Position - v.Position).Magnitude
            if Magnitude < wU then
                wV = v
                wU = Magnitude
            end
        end
    end
    if wV == nil then
        return false
    elseif wU > sI then
        wT.CFrame = CFrame.new(wV.Position + Vector3.new(0, 3, 0))
        task.wait(0.08)
        local wU_1 = not sW() or not sE.Flags.AutoCollectGold
        if wU_1 then
            return false
        end
        local wT_1 = r5()
        if not wT_1 then
            return false
        end
        local Position = wT_1.Position
        local wT_2 = false
        for k, v in pairs(wS) do
            local xa = k
            local wS_1 = s_(v) and (Position - v.Position).Magnitude <= sI
            if wS_1 then
                local wS_2 = pcall(function()
                    CollectDrop:FireServer(xa)
                end)
                if wS_2 then
                    wT_2 = true
                end
            end
        end
        if wT_2 then
            sE.Status = "Collected gold"
        end
        return wT_2
    else
        local Position = wT.Position
        local wT_3 = false
        for k, v in pairs(wS) do
            local xa = k
            local wS_3 = s_(v) and (Position - v.Position).Magnitude <= sI
            if wS_3 then
                local wS_4 = pcall(function()
                    CollectDrop:FireServer(xa)
                end)
                if wS_4 then
                    wT_3 = true
                end
            end
        end
        if wT_3 then
            sE.Status = "Collected gold"
        end
        return wT_3
    end
end
sK = fn452
se = fn1077
sp = function()
    local xP = su()
    local xQ = not xP or type(xP.Characters) ~= "table" or type(xP.Characters.Entries) ~= "table"
    if xQ then
        return false
    elseif next(sE.SellRarities) == nil then
        sE.Status = "No sell rarities"
        return false
    else
        local xQ_1 = se(xP)
        local xR = {}
        for k, v in pairs(xP.Characters.Entries) do
            local xS_1 = type(v) == "table" and type(v.Name) == "string"
            if xS_1 then
                local Name = v.Name
                local xT = xR[v.Name] or 0
                xR[Name] = xT + 1
            end
        end
        for k, v in pairs(xP.Characters.Entries) do
            local x5 = v
            local xP_1 = type(x5) == "table" and type(x5.Name) == "string" and not xQ_1[k]
            if xP_1 then
                local xP_2 = sH.Characters and sH.Characters[x5.Name]
                local xP_3 = type(xP_2) == "table" and xP_2.Rarity
                local xP_4 = xP_3 or nil
                local xS_5 = type(xP_4) == "number" and sx[xP_4]
                local xP_5 = xS_5 or nil
                local xS_6 = xP_5
                if xP_5 then
                    xP_5 = sE.SellRarities[xS_6] == true
                end
                if xP_5 then
                    local xP_6 = not sE.KeepOneOfEach
                    if not xP_6 then
                        xP_6 = (xR[x5.Name] or 0) > 1
                    end
                    if xP_6 then
                        local xP_7 = pcall(function()
                            SellCharacter:FireServer(x5.Name)
                        end)
                        if xP_7 then
                            sE.Status = "Sold " .. x5.Name
                            return true
                        end
                    end
                end
            end
        end
        return false
    end
end
Label = nil
if (sp or sp or not tk and not tk) and (false and (false and not tk)) or (sp or sp) and (tk and false) and ((sp or tk) and (tk or false)) or not ((sp or sp or not tk and not tk) and (false and (false and not tk)) or (sp or sp) and (tk and false) and ((sp or tk) and (tk or false))) then
    sa = "#ff9ec8"
    r4 = "#ffd0e4"
else
    r4 = "#ff9ec8"
    sa = "#ffd0e4"
end
tl = {}
for k, v in pairs(sd) do
    tl[v] = k
end
Library, sh, SaveManager, Toggles, Options, sF, td, s8, sU, sv, sr, sm, s4, sL, sC, ti, sR, tr = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
td = fn725
s8 = fn376
sU = fn927
sv = function(fF, fG)
    local yh_1
    local yf_1
    local ye_1
    ye_1, yf_1 = pcall(sH.GetCatchChance, fF, fG)
    local yg = ye_1 and type(yf_1) == "number" and yf_1 > 0
    local yg_4
    if yg then
        return yf_1
    end
    local ye_2 = sH.Items and sH.Items[fF]
    local ye_3 = sH.Characters and sH.Characters[fG]
    local ye_4 = type(ye_2) ~= "table"
    local ym = if ye_4 then 1 else 0
    local yk = 603 * ym + 2370 * (1 - ym)
    local yl = 1935 * ym + 1256 * (1 - ym)
    if not ((yk * 2151 + yl * 3475 + yk * yl) % 16777213 == 9187983) then
        ye_4 = type(ye_3) ~= "table"
    end
    if ye_4 then
        return nil
    elseif fF == "Capture6" then
        return 100
    else
        local ye_5 = type(ye_2.Rarity) == "number" and ye_2.Rarity
        local yf_3 = ye_5 or 1
        local yf_4 = type(ye_3.Rarity) == "number" and ye_3.Rarity
        local yg_3 = (yf_4 or 1) - yf_3
        local ye_7 = 100
        if yg_3 > 0 then
            local yf_6 = ({ 25, 10, 2.5, 0.75, 0.1 })[yg_3]
            local ym_1 = if yf_6 then 1 else 0
            local yk_1 = 2470 * ym_1 + 1020 * (1 - ym_1)
            local yl_1 = 3045 * ym_1 + 101 * (1 - ym_1)
            if not ((yk_1 * 3817 + yl_1 * 2080 + yk_1 * yl_1) % 16777213 == 6505527) then
                yf_6 = 0.1
            end
            ye_7 = yf_6
        end
        local yf_7 = 1
        local yd = su()
        if yd then
            yg_4, yh_1 = pcall(function()
                return sH.Stats.GetStat("CaptureLuck", sH.Player, yd)
            end)
            local yi = yg_4 and type(yh_1) == "number"
            if yi then
                yf_7 = yh_1
            end
        end
        return math.clamp(ye_7 * yf_7, 0.1, 100)
    end
end
sr = fn384
sm = fn211
s4 = function()
    local yv, yw
    local yy_1
    local yx = su()
    local yx_1, yx_4
    if not yx then
        sU("Waiting for data")
        return false
    elseif sc(yx) then
        sE.Status = "Pen full"
        sU("Pen Full")
        return false
    else
        yv = so(yx)
        if not yv then
            sE.Status = "No capture ball"
            sU("No Capture Ball")
            return false
        end
        yw = tb(yx)
        if not yw then
            sE.Status = "No matching dragon"
            sU("No Matching Dragon")
            return false
        end
        yy_1, yx_1 = sm(yw)
        local yz = tl[yv]
        local yH = if yz then 1 else 0
        local yF = 407 * yH + 3806 * (1 - yH)
        local yG = 1933 * yH + 3197 * (1 - yH)
        if not ((yF * 1174 + yG * 1165 + yF * yG) % 16777213 == 3516494) then
            yz = yv
        end
        local yA = yz
        local yA_1
        local yz_1 = sv(yv, yw.Name)
        local yB = sr(yz_1)
        sU(string.format("Attempting %s (%s) · %s · %s", yy_1, yx_1, yB, yA))
        if not r8(yw) then
            sU("Teleport Failed")
            return false
        end
        task.wait(0.12)
        local yx_2 = not sW() or not sE.Flags.AutoCatch
        if yx_2 then
            sU("Idle")
            return false
        end
        local yx_3 = not yw.Parent or tj(yw)
        if yx_3 then
            sU("Target Lost")
            return false
        end
        yx_4, yA_1 = pcall(function()
            return AttemptCatch:InvokeServer(yv, yw)
        end)
        if yx_4 and yA_1 == true then
            sE.Status = "Caught"
            sU(string.format("Catch Complete · %s · %s", yy_1, yB))
            return true
        end
        sE.Status = "Catch failed"
        local yx_5 = type(yz_1) == "number" and yz_1 < 10
        if yx_5 then
            sU(string.format("Catch Failed · %s · %s - ball may be too weak", yy_1, yB))
        else
            sU(string.format("Catch Failed · %s · %s", yy_1, yB))
        end
        return false
    end
end
sL = fn17
sC = function(gJ, gK, gL)
    local gN = sL(gJ)
    task.spawn(function()
        local yM_1
        while true do
            local yL = sW() and sE.Tokens[gJ] == gN and sE.Flags[gJ]
            local yL_1
            if yL then
                yL_1, yM_1 = pcall(gL)
                if not yL_1 then
                    sE.Status = tostring(yM_1)
                end
                local yL_2 = gK
                if gJ == "AutoCatch" then
                    yL_2 = math.max(0.2, sE.CatchDelay)
                elseif gJ == "AutoSell" then
                    yL_2 = math.max(0.2, sE.SellDelay)
                end
                task.wait(yL_2)
                local yL_3 = not sW() or sE.Tokens[gJ] ~= gN or not sE.Flags[gJ]
                if yL_3 then
                    break
                end
                continue
            end
            break
        end
    end)
end
tc.SetFlag = fn1294
tc.SetSelectedRarities = fn571
tc.SetSellRarities = fn417
tc.SetCatchBall = fn415
tc.SetCatchDelay = fn974
tc.SetSellDelay = fn604
tc.SetKeepEquipped = fn85
tc.SetKeepOneOfEach = fn396
tc.SetKeepBest = fn260
tc.GetStatus = fn573
tc.GetCatchStatus = fn924
tc.Track(fn1214)
Library = getgenv().Library
if ((sF and not sL and (ti or ti) or (sU or not sU) and (not s8 or not sL)) and ((not Library or sU) and (sL or sF) and (not sL or sF or (not s8 or Library))) or (sF or not sF or not sL and sU) and (sF and not sL and (Library or Library)) and (s8 or not s8 or (s8 or not sF) or ti and sU and (sF and not ti))) and not ((sF and not sL and (ti or ti) or (sU or not sU) and (not s8 or not sL)) and ((not Library or sU) and (sL or sF) and (not sL or sF or (not s8 or Library))) or (sF or not sF or not sL and sU) and (sF and not sL and (Library or Library)) and (s8 or not s8 or (s8 or not sF) or ti and sU and (sF and not ti))) then
    local _ = getgenv().SaveManager
    sh = getgenv().SaveManager
else
    sh = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
end
Toggles, Options = Library.Toggles, Library.Options
tv(tc, Library)
ti = fn729
sR = fn835
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = sG, Copyable = true }, "|", sM, "|", tq },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    SidebarCompacted = true,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
if ((not sr or not tr) and (tr and not ti) and (sU or not td or (td or sU)) or (sm and sm or (not sr or sr)) and (sm or not sr or not tr and not sr)) and not ((not sr or not tr) and (tr and not ti) and (sU or not td or (td or sU)) or (sm and sm or (not sr or sr)) and (sm or not sr or not tr and not sr)) then
    sF:SetGlow(false)
    local tp_5 = {
        Player = sF:AddTab("Player", "person-standing"),
        Info = sF:AddTab("Info", "info"),
        Settings = sF:AddTab("Settings", "settings"),
        Main = sF:AddTab("Main", "gamepad-2")
    }
else
    Window:SetGlow(false)
    sF = {
        Info = Window:AddTab("Info", "info"),
        Main = Window:AddTab("Main", "gamepad-2"),
        Player = Window:AddTab("Player", "person-standing"),
        Settings = Window:AddTab("Settings", "settings")
    }
end
tr = fn888
for k, v in sF do
    if k ~= "Info" then
        tr(v)
    end
end
fn681()
local function tp_6()
    local zB
    local zz
    local zE
    local zC
    local zJ
    zz = nil
    zB = nil
    zC = nil
    zE = nil
    zJ = nil
    local zA, zD, zF, Label2, Label3, zI, zK, Label
    zE = function(jb)
        return (tostring(jb):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
    end
    zB = function(jd, je)
        return string.format('<font color="%s">%s</font>', je, zE(jd))
    end
    zI = function(jh, ji, jj)
        return string.format("<b>%s</b> %s %s", jh, zB("-", "#5a6070"), zB(ji, jj))
    end
    local zM = "#8b93a3"
    zA = "#e8a34d"
    zD = "#7fd47f"
    zJ = "Unknown"
    pcall(function()
        local zl_1
        local zk_1
        if type(identifyexecutor) == "function" then
            zl_1, zk_1 = identifyexecutor()
            local zm = zl_1 ~= ""
            local zn = type(zl_1) == "string" and zm
            if zn then
                local zm_1 = type(zk_1) == "string" and zk_1 ~= "" and zl_1 .. " " .. zk_1
                zJ = zm_1 or zl_1
            end
        end
    end)
    zz = os.clock()
    zF = function()
        local zs = math.floor(os.clock() - zz)
        if zs < 60 then
            return zs .. "s"
        elseif zs < 3600 then
            return string.format("%dm %ds", math.floor((zs) / (60)), zs % 60)
        else
            return string.format("%dh %dm", math.floor((zs) / (3600)), math.floor((zs % 3600) / (60)))
        end
    end
    local UserGroup = sF.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(zI("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, zD), true)
    UserGroup:AddLabel(zI("UserId", tostring(LocalPlayer.UserId), "#6ec1ff"), true)
    UserGroup:AddLabel(zI("Executor", zJ .. "  Remotes ready", zD), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(zI("Session", zF(), zA), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            ti(LocalPlayer.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            ti("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = sF.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddLabel(zI("Game", sM, "#6ec1ff"), true)
    Label2 = SessionGroup:AddLabel(zI("Players", "0/0", zD), true)
    zK = tostring(game.JobId)
    local zN = #zK > 18 and string.sub(zK, 1, 18) .. "..."
    local zP_1 = zN or zK
    SessionGroup:AddLabel(zI("Job", zP_1, zM), true)
    Label = SessionGroup:AddLabel(zI("Ping", "0 ms", zA), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Place",
        Func = function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            ti(zK, "Copied Job ID")
        end
    })
    zC = task.spawn(function()
        local zv_1
        local zu_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(zI("Session", zF(), zA))
            Label2:SetText(zI("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), zD))
            zu_1, zv_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local zu_2 = zu_1 and zv_1 .. " ms" or "n/a"
            Label:SetText(zI("Ping", zu_2, zA))
        end
    end)
    tc.Track(function()
        if coroutine.status(zC) ~= "dead" then
            task.cancel(zC)
        end
    end)
    local SocialsGroup = sF.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = sR })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            ti(sD, "Copied Rscripts profile")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            ti(sB, "Copied website link")
        end
    })
end
tp_6()
local function tq_1()
    local kp
    local kn
    local kq
    local ko
    local MovementGroup = sF.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = sF.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    kn = {}
    kp = {}
    kq = {}
    ko = {}
    local km = {}
    local function kr()
        for k, v in kn do
            if k.Parent then
                k.CanCollide = v
            end
        end
        table.clear(kn)
    end
    local function kw()
        for k, v in ko do
            if k.Parent then
                k.WalkSpeed = v
            end
        end
        table.clear(ko)
    end
    local function kA()
        for k, v in kp do
            if k.Parent then
                k.PlatformStand = v
            end
        end
        table.clear(kp)
    end
    local function kE(kF)
        local Ae = if not kF:IsA("ProximityPrompt") then 1 else 0
        if Ae == 1 then
            return
        end
        if kq[kF] == nil then
            kq[kF] = {
                HoldDuration = kF.HoldDuration,
                MaxActivationDistance = kF.MaxActivationDistance,
                RequiresLineOfSight = kF.RequiresLineOfSight
            }
        end
        kF.HoldDuration = 0
        kF.MaxActivationDistance = 50
        kF.RequiresLineOfSight = false
    end
    local function kH()
        for k, v in kq do
            if k.Parent then
                k.HoldDuration = v.HoldDuration
                k.MaxActivationDistance = v.MaxActivationDistance
                k.RequiresLineOfSight = v.RequiresLineOfSight
            end
        end
        table.clear(kq)
    end
    table.insert(km, tg.JumpRequest:Connect(function()
        if not Toggles.InfJump.Value or Library.Unloaded then
            return
        end
        local Am_1 = tf()
        if Am_1 then
            Am_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))
    table.insert(km, th.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        local Character = LocalPlayer.Character
        if Toggles.NoClip.Value and Character then
            for i, descendant in Character:GetDescendants() do
                if descendant:IsA("BasePart") then
                    if kn[descendant] == nil then
                        kn[descendant] = descendant.CanCollide
                    end
                    descendant.CanCollide = false
                end
            end
        elseif next(kn) ~= nil then
            kr()
        end
    end))
    table.insert(km, Workspace.DescendantAdded:Connect(function(k4)
        local AA = Toggles.InstantProximityPrompt.Value and k4:IsA("ProximityPrompt")
        if AA then
            kE(k4)
        end
    end))
    Toggles.InstantProximityPrompt:OnChanged(function(k8)
        if k8 then
            for k, v in Workspace:QueryDescendants("ProximityPrompt") do
                kE(v)
            end
        else
            kH()
        end
    end)
    table.insert(km, th.RenderStepped:Connect(function(le)
        if Library.Unloaded then
            return
        end
        local Character = LocalPlayer.Character
        local AN = Character and Character:FindFirstChildOfClass("Humanoid")
        local AO = Character
        if AO then
            AO = Character:FindFirstChild("HumanoidRootPart")
        end
        local AM_1 = AO
        local CurrentCamera = Workspace.CurrentCamera
        if Toggles.WalkSpeedEnabled.Value and AN then
            if ko[AN] == nil then
                ko[AN] = AN.WalkSpeed
            end
            AN.WalkSpeed = Options.WalkSpeed.Value
        else
            if AN and ko[AN] ~= nil then
                AN.WalkSpeed = ko[AN]
                ko[AN] = nil
            end
        end
        if Toggles.Fly.Value and AM_1 and AN and CurrentCamera then
            if kp[AN] == nil then
                kp[AN] = AN.PlatformStand
            end
            AN.PlatformStand = true
            local AO_5 = Vector3.zero
            local AU = if not tg:GetFocusedTextBox() then 1 else 0
            if AU == 1 then
                if tg:IsKeyDown(Enum.KeyCode.W) then
                    AO_5 += CurrentCamera.CFrame.LookVector
                end
                if tg:IsKeyDown(Enum.KeyCode.S) then
                    AO_5 -= CurrentCamera.CFrame.LookVector
                end
                if tg:IsKeyDown(Enum.KeyCode.A) then
                    AO_5 -= CurrentCamera.CFrame.RightVector
                end
                if tg:IsKeyDown(Enum.KeyCode.D) then
                    AO_5 += CurrentCamera.CFrame.RightVector
                end
                if tg:IsKeyDown(Enum.KeyCode.Space) then
                    AO_5 += Vector3.new(0, 1, 0)
                end
                if tg:IsKeyDown(Enum.KeyCode.LeftControl) then
                    AO_5 -= Vector3.new(0, 1, 0)
                end
            end
            AM_1.AssemblyLinearVelocity = Vector3.zero
            if AO_5.Magnitude > 0 then
                AM_1.CFrame = AM_1.CFrame + AO_5.Unit * Options.FlySpeed.Value * le
            end
        else
            if AN and kp[AN] ~= nil then
                AN.PlatformStand = kp[AN]
                kp[AN] = nil
            end
        end
    end))
    tc.Track(function()
        for k, v in km do
            v:Disconnect()
        end
        kr()
        kw()
        kA()
        kH()
    end)
end
tq_1()
local function tn_12()
    local Cr, Cs, Ct, Cu, Cv, Cw, Cx, Cy, Cz, CA, CB, CC, Label, CE
    CE = {}
    Cy = {}
    Ct = nil
    Cr = 0
    Cw = 0
    CA = false
    CB = os.clock()
    local MenuGroup = sF.Settings:AddLeftGroupbox("Menu", "logs")
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    Label = MenuGroup:AddLabel("AFK triggers: 0")
    Cs = function()
        local CurrentCamera
        CurrentCamera = Workspace.CurrentCamera
        local A5 = not CurrentCamera or not s2(ta.CaptureController) or not s2(ta.ClickButton2)
        if A5 then
            return false
        end
        local A5_1 = pcall(function()
            ta:CaptureController()
            ta:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        end)
        if not A5_1 then
            return false
        end
        Cw += 1
        CB = os.clock()
        pcall(function()
            Label:SetText("AFK triggers: " .. Cw)
        end)
        return true
    end
    Cv = function(l7)
        pcall(function()
            s7:SetGameplayPausedNotificationEnabled(not l7)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not l7
            end
        end)
        if not l7 then
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
    Cz = function(ml)
        local Bh = ml.ClassName == "ParticleEmitter"
        local Bl = if Bh then 1 else 0
        local Bj = 2225 * Bl + 1731 * (1 - Bl)
        local Bk = 2328 * Bl + 192 * (1 - Bl)
        if not ((Bj * 2911 + Bk * 754 + Bj * Bk) % 16777213 == 13412087) then
            Bh = ml.ClassName == "Trail"
        end
        if not Bh then
            Bh = ml.ClassName == "Smoke"
        end
        if not Bh then
            Bh = ml.ClassName == "Fire"
        end
        if not Bh then
            Bh = ml.ClassName == "Sparkles"
        end
        if not Bh then
            Bh = ml.ClassName == "Explosion"
        end
        if not Bh then
            Bh = ml.ClassName == "Beam"
        end
        if Bh then
            if CE[ml] == nil then
                CE[ml] = ml.Enabled
            end
            pcall(function()
                ml.Enabled = false
            end)
        end
    end
    Cu = function()
        for k, v in CE do
            local Bt = k
            local Bv = v
            if Bt.Parent then
                pcall(function()
                    Bt.Enabled = Bv
                end)
            end
        end
        table.clear(CE)
        if Ct then
            pcall(function()
                settings().Rendering.QualityLevel = Ct.Quality
            end)
            Lighting.GlobalShadows = Ct.Shadows
            Lighting.FogEnd = Ct.Fog
            Ct = nil
        end
    end
    MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
    MenuGroup:AddToggle("Disable3D", {
        Text = "Disable 3D Rendering",
        Default = false,
        Callback = function(mz)
            pcall(function()
                th:Set3dRenderingEnabled(not mz)
            end)
        end
    })
    MenuGroup:AddToggle("FpsBoost", {
        Text = "FPS Boost",
        Default = false,
        Callback = function(mE)
            if mE then
                if not Ct then
                    Ct = {
                        Quality = settings().Rendering.QualityLevel,
                        Shadows = Lighting.GlobalShadows,
                        Fog = Lighting.FogEnd
                    }
                end
                pcall(function()
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                end)
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 9000000000
                for k, v in Workspace:QueryDescendants("ParticleEmitter,Trail,Smoke,Fire,Sparkles,Beam") do
                    pcall(Cz, v)
                end
            else
                Cu()
            end
        end
    })
    MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    Cv(true)
    local ScriptGroup = sF.Settings:AddLeftGroupbox("Script", "terminal")
    ScriptGroup:AddButton({
        Text = "Unload Script",
        Func = function()
            Library:Unload()
        end
    })
    Toggles.AntiGameplayPause:OnChanged(function()
        Cv(Toggles.AntiGameplayPause.Value)
    end)
    if Toggles.AntiGameplayPause.Value then
        Cv(true)
    end
    table.insert(Cy, LocalPlayer.Idled:Connect(function()
        if Toggles.AntiAfk.Value and not Library.Unloaded then
            Cs()
        end
    end))
    table.insert(Cy, Workspace.DescendantAdded:Connect(function(mX)
        if Toggles.FpsBoost.Value then
            Cz(mX)
        end
    end))
    CC = function(m0)
        local BS = CA
        local BX = if BS then 1 else 0
        local BV = 1146 * BX + 2276 * (1 - BX)
        local BW = 687 * BX + 2347 * (1 - BX)
        if not ((BV * 1001 + BW * 1321 + BV * BW) % 16777213 == 2841975) then
            BS = Library.Unloaded
        end
        if not BS then
            BS = not Toggles.AutoReconnect.Value
        end
        if BS then
            return
        end
        CA = true
        local BR = Cr
        local BS_1 = pcall(function()
            if m0 then
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            else
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        end)
        if not BS_1 then
            CA = false
            if not m0 and BR == Cr then
                task.delay(1.5, function()
                    if BR == Cr then
                        CC(true)
                    end
                end)
            end
        end
    end
    table.insert(Cy, TeleportService.TeleportInitFailed:Connect(function(ni)
        local B1
        if ni == LocalPlayer and CA then
            CA = false
            B1 = Cr
            task.delay(3, function()
                if B1 == Cr then
                    CC(true)
                end
            end)
        end
    end))
    task.spawn(function()
        local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
        local Cc = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
        local Cc_1 = not Cc
        local Cd = Library.Unloaded
        local Ch = if Cd then 1 else 0
        local Cf = 1017 * Ch + 333 * (1 - Ch)
        local Cg = 2445 * Ch + 18 * (1 - Ch)
        if not ((Cf * 996 + Cg * 4071 + Cf * Cg) % 16777213 == 13453092) then
            Cd = Cc_1
        end
        if Cd then
            return
        end
        table.insert(Cy, Cc.ChildAdded:Connect(function(nx)
            if nx.Name == "ErrorPrompt" then
                CC(false)
            end
        end))
    end)
    Cx = task.spawn(function()
        while not Library.Unloaded do
            if Toggles.AntiGameplayPause.Value then
                Cv(true)
            end
            local Ci = Toggles.AntiAfk.Value and os.clock() - CB >= 60
            if Ci then
                Cs()
            end
            task.wait(1)
        end
    end)
    tc.Track(function()
        Cr += 1
        for k, v in Cy do
            v:Disconnect()
        end
        pcall(task.cancel, Cx)
        Cv(false)
        Cu()
        pcall(function()
            th:Set3dRenderingEnabled(true)
        end)
    end)
end
tn_12()
ts = function()
    local DC, DD, DE, DF
    sh:SetLibrary(Library)
    sh:SetFolder("TempoHub")
    sh:SaveDefault("Evil Hello Kitty")
    sh:ApplyToTab(sF.Settings)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    SaveManager:SetFolder("TempoHub/CatchDragonsToDefend")
    local DG = SaveManager:BuildConfigSection(sF.Settings)
    DF = function(nY, nZ)
        local CI_1 = (nY == "Toggle" and Toggles or Options)[nZ]
        local CH_2 = type(CI_1) == "table" and CI_1.Type == nY
        return CH_2 and CI_1 or nil
    end
    DD = function(n7, n8)
        local Type = n8.Type
        if Type == "Toggle" then
            return { idx = n7, type = "Toggle", value = n8.Value == true }
        elseif Type == "Slider" then
            return { idx = n7, type = "Slider", value = tostring(n8.Value) }
        elseif Type == "Dropdown" then
            return { idx = n7, type = "Dropdown", multi = n8.Multi == true, value = n8.Value }
        elseif Type == "Input" then
            local CM = n8.Value or ""
            return { idx = n7, type = "Input", text = tostring(CM) }
        elseif Type == "ColorPicker" then
            return { idx = n7, type = "ColorPicker", value = n8.Value:ToHex(), transparency = n8.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = n7,
                type = "KeyPicker",
                mode = n8.Mode,
                key = n8.Value,
                modifiers = n8.Modifiers,
                toggled = n8.Toggled
            }
        else
            return nil
        end
    end
    DC = function()
        local CV = {}
        for i, v in ipairs({ Toggles, Options }) do
            for k, v in pairs(v) do
                local CW = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if CW then
                    local CW_1 = DD(k, v)
                    if CW_1 then
                        CV[#CV + 1] = CW_1
                    end
                end
            end
        end
        table.sort(CV, function(oi, oj)
            if oi.type ~= oj.type then
                return oi.type < oj.type
            end
            return oi.idx < oj.idx
        end)
        return { objects = CV }
    end
    DE = function(om)
        local De
        De = nil
        local Df = type(om) ~= "table" or type(om.idx) ~= "string" or type(om.type) ~= "string" or SaveManager.Ignore[om.idx]
        if Df then
            return false
        end
        De = DF(om.type, om.idx)
        if not De then
            return false
        end
        local Df_1 = pcall(function()
            if om.type == "Input" then
                if type(om.text) ~= "string" then
                    return
                end
                De:SetValue(om.text)
            elseif om.type == "ColorPicker" then
                De:SetValueRGB(Color3.fromHex(om.value), om.transparency)
            elseif om.type == "KeyPicker" then
                De:SetValue({ om.key, om.mode, om.modifiers })
                if om.mode == "Toggle" and om.toggled ~= nil then
                    De.Toggled = om.toggled
                    De:Update()
                end
            else
                De:SetValue(om.value)
            end
        end)
        return Df_1
    end
    DG:AddDivider()
    DG:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    DG:AddButton("Export Config to Clipboard", function()
        local Dl_1
        local Dk_1
        Dk_1, Dl_1 = pcall(s9.JSONEncode, s9, DC())
        if Dk_1 then
            local Dk_2 = s2(setclipboard) and setclipboard
            local Dm = Dk_2
            if not Dm then
                local Dk_3 = s2(toclipboard) and toclipboard
                Dm = Dk_3 or nil
            end
            local Dk_4 = Dm
            local Dm_1 = type(Dk_4) == "function" and pcall(Dk_4, Dl_1)
            if Dm_1 then
                Library:Notify("Config copied to clipboard", 6)
                return
            end
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Failed to encode the config")
    end)
    DG:AddButton("Import Config from Clipboard Text", function()
        local Dr_1
        local Dp = Options.SaveManager_ImportSource.Value or ""
        local Dp_1
        local Dq = tostring(Dp):match("^%s*(.-)%s*$")
        if Dq == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        if #Dq > 262144 then
            Library:Notify("That config is too large")
            return
        end
        Dp_1, Dr_1 = pcall(s9.JSONDecode, s9, Dq)
        local Dq_1 = not Dp_1
        local Dv = if Dq_1 then 1 else 0
        local Dt = 848 * Dv + 2773 * (1 - Dv)
        local Du = 1685 * Dv + 3470 * (1 - Dv)
        if not ((Dt * 3400 + Du * 2041 + Dt * Du) % 16777213 == 7751165) then
            Dq_1 = type(Dr_1) ~= "table"
        end
        if not Dq_1 then
            Dq_1 = type(Dr_1.objects) ~= "table"
        end
        if Dq_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        if #Dr_1.objects > 2048 then
            Library:Notify("That config has too many records")
            return
        end
        local Dp_2 = 0
        for i, v in ipairs(Dr_1.objects) do
            if DE(v) then
                Dp_2 += 1
            end
        end
        if Dp_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local Dr_2 = Dp_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(Dp_2, Dr_2), 6)
    end)
    sh:LoadDefault()
    SaveManager:LoadAutoloadConfig()
    if Options.CatchBall then
        tc.SetCatchBall(Options.CatchBall.Value)
    end
    if Options.CatchRarities then
        tc.SetSelectedRarities(Options.CatchRarities.Value)
    end
    if Options.CatchDelay then
        tc.SetCatchDelay(Options.CatchDelay.Value)
    end
    if Options.SellRarities then
        tc.SetSellRarities(Options.SellRarities.Value)
    end
    if Options.SellDelay then
        tc.SetSellDelay(Options.SellDelay.Value)
    end
    if Options.KeepBest then
        tc.SetKeepBest(Options.KeepBest.Value)
    end
    if Toggles.KeepEquipped then
        tc.SetKeepEquipped(Toggles.KeepEquipped.Value)
    end
    if Toggles.KeepOneOfEach then
        tc.SetKeepOneOfEach(Toggles.KeepOneOfEach.Value)
    end
    if Toggles.HideUiOnStart and Toggles.HideUiOnStart.Value then
        pcall(function()
            Library:Toggle(false)
        end)
    end
end
ts()
end)(...)

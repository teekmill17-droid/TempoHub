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
getgenv().TempoHoodSubtitle = "+1 FAT PER CLICK"
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
local ip
local iL
local is
local iO
local iv
local iR
local Label
local iU
local Library
local ih
local onClickNow
local i_
local ik
local iH
local i2
local io
local onBuyBoostsNow
local Options
local iN
local iu
local h5
local ix
local iA
local connection
local RequestPets
local ig
local iZ
local iD
local ij
local onBuyUpgradesNow
local iJ
local connection2
local im
local iq
local onGoToBestTable
local EquipBestTitle
local onHatchNow
local ja
local h7
local Toggles
local onEquipBestNow
local ia
local iV
local iz
local ie
local VirtualUser
local onBuyBestFoodNow
local iF
local i0
local il
local iI
local function worker8()
    while not Library.Unloaded do
        if iF("AutoUpgrades") then
            onBuyUpgradesNow()
        end
        task.wait(is("UpgradeDelay", 2))
    end
end
local function worker13()
    while not Library.Unloaded do
        if iF("AutoEquipTitle") then
            iL()
        end
        task.wait(is("TitleDelay", 5))
    end
end
local function worker12()
    while not Library.Unloaded do
        if iF("AutoRollTitles") then
            i_()
        end
        task.wait(is("RollDelay", 1))
    end
end
local function fn51()
    ip(iR, "Copied Discord invite to clipboard")
end
local function worker11()
    while not Library.Unloaded do
        if iF("AutoEquipPets") then
            pcall(function()
                RequestPets:FireServer()
            end)
            onEquipBestNow()
        end
        task.wait(is("PetDelay", 3))
    end
end
local function fn79()
    pcall(function()
        ig:FireServer(true)
    end)
end
local function fn135(Z)
    local leaderstats = iU:FindFirstChild("leaderstats")
    local kc = leaderstats and leaderstats:FindFirstChild(Z)
    local kb_1 = kc
    if kc then
        kc = kb_1.Value
    end
    return kc or 0
end
local function fn150()
    local mw_1
    local mv_1
    if identifyexecutor then
        mw_1, mv_1 = identifyexecutor()
        local mx = mw_1 ~= ""
        local my = type(mw_1) == "string" and mx
        if my then
            local mx_1 = type(mv_1) == "string" and mv_1 ~= "" and mw_1 .. " " .. mv_1
            ix = mx_1 or mw_1
        end
    end
end
local function fn172(d_)
    local DiscordGroup = d_:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = ie })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = ie })
end
local function fn194()
    h7(Toggles.RemoveHatchAnim.Value)
end
local function onCopyJoinScript_JobID()
    local eg = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, h5)
    ip(eg, "Copied join script to clipboard")
end
local function worker5()
    while not Library.Unloaded do
        if iF("AutoRebirth") then
            iI()
        end
        task.wait(is("RebirthDelay", 3))
    end
end
local function worker9()
    while not Library.Unloaded do
        if iF("AutoBoosts") then
            onBuyBoostsNow()
        end
        task.wait(is("BoostDelay", 2))
    end
end
local function worker2()
    while not Library.Unloaded do
        task.wait(2)
        if iF("AntiAfk") then
            local mW = tick() - iH
            local mX = tick() - iD
            if mW >= 300 and mX >= 60 then
                pcall(iq)
            else
                if mW < 300 and mX >= 300 then
                    pcall(iq)
                end
            end
        end
    end
end
local function fn230()
    i2 = {}
    if not im or not im.Tables then
        return
    end
    for i, descendant in ipairs(workspace:GetDescendants()) do
        local k2_1 = descendant:IsA("TextLabel") and descendant.Name == "Name" and im.Tables[descendant.Text]
        if k2_1 then
            local Model = descendant:FindFirstAncestorWhichIsA("Model")
            if Model then
                i2[descendant.Text] = Model
            end
        end
    end
end
local function fn263()
    local lW = iu and iu.RollCost and ih("Wins") < iu.RollCost
    if lW then
        return
    end
    pcall(function()
        iO:FireServer()
    end)
end
local function worker7()
    while not Library.Unloaded do
        if iF("AutoFood") then
            onBuyBestFoodNow()
        end
        task.wait(is("FoodDelay", 5))
    end
end
local function fn313()
    local FatValue = iU:FindFirstChild("FatValue")
    return FatValue and FatValue.Value or 0
end
local function fn326()
    pcall(function()
        ig:FireServer(false)
    end)
end
local function worker()
    local mE_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local mD = math.floor(os.clock() - iV)
        if mD < 60 then
            mE_1 = mD .. "s"
        elseif mD < 3600 then
            mE_1 = string.format("%dm %ds", math.floor((mD) / (60)), mD % 60)
        else
            mE_1 = string.format("%dh %dm", math.floor((mD) / (3600)), math.floor((mD % 3600) / (60)))
        end
        Label:SetText(i0("Session time", mE_1, iJ))
    end
end
local function fn346()
    connection:Disconnect()
    connection2:Disconnect()
    h7(false)
end
local function fn347()
    pcall(function()
        EquipBestTitle:FireServer()
    end)
end
local function fn352(cd)
    local lA_1
    local lz = ij and ij.getTraitMultiplier
    local lz_1
    if lz then
        lz_1, lA_1 = pcall(ij.getTraitMultiplier, cd)
        local lB = lz_1 and tonumber(lA_1)
        if lB then
            return lA_1
        end
        return 1
    end
    return 1
end
local function fn354(dd)
    local lZ = Toggles[dd]
    return lZ ~= nil and lZ.Value == true
end
local function worker10()
    while not Library.Unloaded do
        if iF("AutoHatch") then
            onHatchNow()
        end
        task.wait(is("HatchDelay", 1))
    end
end
local function onInputChanged(e_)
    local UserInputType = e_.UserInputType
    local mR = UserInputType == Enum.UserInputType.MouseMovement
    local mV = if mR then 1 else 0
    local mT = 2268 * mV + 3030 * (1 - mV)
    local mU = 3694 * mV + 1348 * (1 - mV)
    if not ((mT * 128 + mU * 2796 + mT * mU) % 16777213 == 2219507) then
        mR = UserInputType == Enum.UserInputType.Gamepad1
    end
    if mR then
        iH = tick()
    end
end
local function fn391(n)
    local j9_1
    local j8_1
    if not n then
        return nil
    end
    j8_1, j9_1 = pcall(require, n)
    if j8_1 then
        return j9_1
    end
    return nil
end
local function fn406(c4, c5, c6)
    return string.format("<b>%s</b> %s %s", c4, ja("-", "#5a6070"), ja(c5, c6))
end
local function worker4()
    while not Library.Unloaded do
        local m0 = iF("AutoWin") and not iU:GetAttribute("AutoWins")
        if m0 then
            iv()
        end
        task.wait(is("WinDelay", 1))
    end
end
local function onOnClientEvent(b7, b8, b9)
    if type(b7) == "table" then
        io = b7
    end
    if tonumber(b9) then
        ik = tonumber(b9)
    end
end
local function fn478(di, dj)
    local l1 = Options[di]
    local l2 = l1 and tonumber(l1.Value)
    return l2 or dj
end
local function onRscripts()
    ip(iN, "Copied Rscripts profile to clipboard")
end
local function fn508()
    if not Toggles.AutoWin.Value then
        il()
    end
end
local function fn529()
    local Character = iU.Character
    if not Character then
        return nil
    end
    local Tool = Character:FindFirstChildOfClass("Tool")
    local kh_1 = Tool and Tool:GetAttribute("FatPerClick")
    if kh_1 then
        return Tool
    end
    return nil
end
local function fn532(dp)
    local l4 = Options[dp]
    return l4 and l4.Value or {}
end
local function onUnload()
    Library:Unload()
end
local function fn571(U, V)
    return U.amount < V.amount
end
local function fn580(cV, cW)
    if setclipboard then
        setclipboard(cV)
    elseif toclipboard then
        toclipboard(cV)
    end
    Library:Notify(cW)
end
local function fn583()
    local kF_1
    local kE_1
    if not iA then
        return
    end
    local kD = iU:GetAttribute("Level")
    if not kD then
        kE_1, kF_1 = pcall(iA.GetLevelInfo, iZ())
        kD = kE_1 and kF_1 or 0
    end
    local kE_3 = iA.RebirthLevelReq(ih("Rebirths"))
    if kE_3 <= (kD or 0) then
        pcall(function()
            ia:FireServer()
        end)
    end
end
local function onInputBegan()
    iH = tick()
end
local function fn650()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    iD = tick()
end
local function fn652(c1, c2)
    return string.format('<font color="%s">%s</font>', c2, c1)
end
local function fn655()
    local lf_1
    local le_1
    if not im or not im.Tables then
        return nil
    end
    local ld_1 = ih("Rebirths")
    lf_1, le_1 = nil, nil
    for k, v in pairs(im.Tables) do
        if not v.admin then
            local lg = false
            if v.gate == "open" then
                lg = true
            elseif v.gate == "rebirth" then
                lg = (v.rebirths or 0) <= ld_1
            elseif v.gate == "gamepass" then
                lg = iz(v.passId)
            end
            local lh_2 = lg
            if lh_2 then
                lh_2 = not le_1 or (v.mult or 0) > le_1
            end
            if lh_2 then
                lf_1 = k
                le_1 = v.mult or 0
            end
        end
    end
    return lf_1
end
local function worker6()
    while not Library.Unloaded do
        if iF("AutoTables") then
            onGoToBestTable()
        end
        task.wait(is("TableDelay", 2))
    end
end
local function worker3()
    while not Library.Unloaded do
        if iF("AutoClick") then
            onClickNow()
        end
        task.wait(is("ClickDelay", 0.1))
    end
end
h5 = nil
h7 = nil
Label = nil
ia = nil
connection = nil
ie = nil
ig = nil
ih = nil
onBuyBestFoodNow = nil
ij = nil
ik = nil
il = nil
im = nil
io = nil
ip = nil
iq = nil
Options = nil
is = nil
onHatchNow = nil
iu = nil
iv = nil
Toggles = nil
ix = nil
iz = nil
iA = nil
Library = nil
iD = nil
onClickNow = nil
iF = nil
iH = nil
iI = nil
iJ = nil
onBuyBoostsNow = nil
iL = nil
EquipBestTitle = nil
iN = nil
iO = nil
onEquipBestNow = nil
iR = nil
iU = nil
local h4, h6, h8, ic, iy, iC, iG, iQ, iS, iT
iV = nil
RequestPets = nil
VirtualUser = nil
iZ = nil
i_ = nil
i0 = nil
onBuyUpgradesNow = nil
i2 = nil
connection2 = nil
onGoToBestTable = nil
ja = nil
local iX, i3, MarketplaceService, i6, i8, i9, jj, jk, jl, jm, jo, jp
local jd_1, jd_4
MarketplaceService, VirtualUser, iU, iR, iN, iA, iy, iu = nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local AccountGroup
local jg = game:GetService("ReplicatedStorage")
MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
iU = Players.LocalPlayer
local jh = "+1 Fat Per Click"
iR = "https://discord.gg/K7Qxnxkk46"
iN = "https://discord.gg/K7Qxnxkk46"
local Shared = jg:FindFirstChild("Shared")
local je_5
iA = fn391(jg:FindFirstChild("FoodConfig"))
iy = fn391(jg:FindFirstChild("PetConfig"))
fn391(jg:FindFirstChild("UpgradeConfig"))
iu = fn391(jg:FindFirstChild("TitleConfig"))
local jb_1 = Shared and Shared:FindFirstChild("TableConfig")
im = fn391(jb_1)
local jb_2 = Shared and Shared:FindFirstChild("TraitConfig")
ij, ig, ia, h6, h4, i8, i6, i3, jj, RequestPets, iT, iS, iO, EquipBestTitle, jm, jl, jk, jd_1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local jc = 2
repeat
    local je_1 = (jc * 1 + 2) % 5 + 1
    if je_1 <= 3 then
        if je_1 <= 2 then
            if je_1 <= 1 then
                if jc * 131107847 + 3 + 7 <= jc * 131107847 + 3 + 7 + 2 then
                    i8 = jg:WaitForChild("HatchResult")
                    i6 = jg:WaitForChild("EquipPet")
                    i3 = jg:WaitForChild("UnequipPet")
                    jj = jg:WaitForChild("PetsUpdated")
                    RequestPets = jg:WaitForChild("RequestPets")
                else
                    jj = RequestPets:WaitForChild("HatchResult")
                    jg = RequestPets:WaitForChild("EquipPet")
                    i6 = RequestPets:WaitForChild("UnequipPet")
                    i8 = RequestPets:WaitForChild("PetsUpdated")
                    i3 = RequestPets:WaitForChild("RequestPets")
                end
                jc = (jc + 16) % 20
            else
                if jc * 126325665 + 13 + 2 >= jc * 126325665 + 13 + 2 + 1 then
                    iS = EquipBestTitle:WaitForChild("BuyUpgrade")
                    iO = EquipBestTitle:WaitForChild("BuyBoost")
                    jg = EquipBestTitle:WaitForChild("RollTitle")
                    iT = EquipBestTitle:WaitForChild("EquipBestTitle")
                else
                    iT = jg:WaitForChild("BuyUpgrade")
                    iS = jg:WaitForChild("BuyBoost")
                    iO = jg:WaitForChild("RollTitle")
                    EquipBestTitle = jg:WaitForChild("EquipBestTitle")
                end
                jc = (jc + 16) % 20
            end
        else
            if jc * 20554445 + 6 + 1 <= jc * 20554445 + 6 + 1 + 5 then
                jm = { "Walkspeed", "TrainingRate", "ClickRate" }
                jl = { "Damage", "Wins", "Luck" }
                jk = {}
            else
                jk = { "ClickRate", "Walkspeed", "TrainingRate" }
                jm = { "Luck", "Wins", "Damage" }
                jl = {}
            end
            jc = (jc + 16) % 20
        end
    elseif je_1 <= 4 then
        if (jk or not i8 or (not EquipBestTitle or jd_1)) and (not ia and not ia or (EquipBestTitle or not EquipBestTitle)) and not ((jk or not i8 or (not EquipBestTitle or jd_1)) and (not ia and not ia or (EquipBestTitle or not EquipBestTitle))) then
            iy = jd_1
        else
            jd_1 = iy
        end
        jc = (jc + 1) % 20
    else
        local je_2 = (vector.create((jc * 6 + 9) % 11 + 1, (jc * 3 + 11) % 13 + 1, (jc * 14 + 8) % 17 + 1))
        local jn_1 = (vector.create((jc * 4 + 3) % 11 + 1, (jc * 7 + 6) % 13 + 1, (jc * 10 + 1) % 17 + 1))
        jo = (vector.create((jc * 4 + 4) % 11 + 1, (jc * 10 + 6) % 13 + 1, (jc * 11 + 10) % 17 + 1))
        jp = (vector.create((jc * 1 + 6) % 11 + 1, (jc * 2 + 3) % 13 + 1, (jc * 9 + 1) % 17 + 1))
        if vector.dot(vector.cross(je_2, jn_1), (vector.cross(jo, jp))) == vector.dot(je_2, jo) * vector.dot(jn_1, jp) - vector.dot(je_2, jp) * vector.dot(jn_1, jo) + 5 then
            ig = fn391(jg)
            h4 = ij:WaitForChild("AutoWinsToggle")
            h6 = ij:WaitForChild("DoRebirth")
            jb_2 = ij:WaitForChild("EquipFood")
            ia = ij:WaitForChild("HatchEgg")
        else
            ij = fn391(jb_2)
            ig = jg:WaitForChild("AutoWinsToggle")
            ia = jg:WaitForChild("DoRebirth")
            h6 = jg:WaitForChild("EquipFood")
            h4 = jg:WaitForChild("HatchEgg")
        end
        jc = (jc + 16) % 20
    end
until (jc * 11 + 5) % 20 == 2
if jd_1 then
    jd_1 = iy.EGGS
end
if jd_1 then
    local jb_3 = {}
    for k, v in pairs(iy.EGGS) do
        local jc_1 = type(v) == "table" and v.cost and v.cost.kind == "wins"
        if jc_1 then
            local insert = table.insert
            local jd_2 = tonumber(v.cost.amount) or 0
            insert(jb_3, { key = k, amount = jd_2 })
        end
    end
    local je_3 = 7
    repeat
        if je_3 * 90568779 + 11 + 5 <= je_3 * 90568779 + 11 + 5 + 2 then
            table.sort(jb_3, fn571)
        else
            table.sort(jb_3, fn571)
        end
        je_3 = (je_3 + 4) % 8
    until (je_3 * 1 + 3) % 8 == 6
    for i, v in ipairs(jb_3) do
        table.insert(jk, v.key)
    end
end
ic, iC, i2, io, ik, Library, Toggles, Options, iJ, ih, iZ, iQ, onClickNow, iv, il, h7, iI, onBuyBestFoodNow, iz, iX, iG, onGoToBestTable, i9, onEquipBestNow, i_, iL, ip, ie, ja, i0, iF, is, h8, onBuyUpgradesNow, onBuyBoostsNow, onHatchNow = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
ih = fn135
iZ = fn313
iQ = fn529
onClickNow = function()
    local kn = iQ()
    if kn then
        pcall(function()
            kn:Activate()
        end)
    end
end
iv = fn79
il = fn326
ic = nil
h7 = function(aA)
    if aA then
        if ic then
            return
        end
        ic = {}
        if typeof(getconnections) == "function" then
            for i, v in ipairs(getconnections(i8.OnClientEvent)) do
                local kw = v
                pcall(function()
                    kw:Disable()
                end)
                table.insert(ic, kw)
            end
        end
        pcall(function()
            iU:SetAttribute("EggHatching", false)
        end)
    elseif ic then
        for i, v in ipairs(ic) do
            local kC = v
            pcall(function()
                kC:Enable()
            end)
        end
        ic = nil
    end
end
iI = fn583
onBuyBestFoodNow = function()
    local kL
    if not iA or not iA.Foods then
        return
    end
    local kM_1 = ih("Wins")
    local kN = ih("Rebirths")
    kL = nil
    for i, v in ipairs(iA.Foods) do
        local kO = not v.gamepass
        if kO ~= false then
            kO = not v.dailyReward
        end
        if kO then
            kO = (v.requiredWins or 0) <= kM_1
        end
        if kO then
            kO = (v.requiredRebirths or 0) <= kN
        end
        if kO then
            local kO_1 = not kL
            if not kO_1 then
                kO_1 = (v.fatPerClick or 0) > (kL.fatPerClick or 0)
            end
            if kO_1 then
                kL = v
            end
        end
    end
    if not kL then
        return
    end
    local kM_2 = iQ()
    if kM_2 and kM_2.Name == kL.name then
        return
    end
    pcall(function()
        h6:FireServer(kL.name)
    end)
end
iC = {}
iz = function(be)
    if be == nil then
        return false
    end
    if iC[be] == nil then
        iC[be] = false
        task.spawn(function()
            local kZ_1
            local kY_1
            kY_1, kZ_1 = pcall(function()
                return MarketplaceService:UserOwnsGamePassAsync(iU.UserId, be)
            end)
            local kY_2 = kY_1 and kZ_1 or false
            iC[be] = kY_2
        end)
    end
    return iC[be]
end
i2 = {}
iX = fn230
iG = fn655
onGoToBestTable = function()
    local ls
    local lq
    local lt
    local lr
    lq = nil
    lr = nil
    ls = nil
    lt = nil
    local lu = iG()
    local lu_2
    if not lu then
        return
    end
    if iU:GetAttribute("Training") == lu then
        return
    end
    ls = i2[lu]
    if not ls or not ls.Parent then
        iX()
        ls = i2[lu]
    end
    if not ls then
        return
    end
    local Character = iU.Character
    local lv_1 = Character and Character:FindFirstChild("HumanoidRootPart")
    lq = lv_1
    if not lq then
        return
    end
    lu_2, lr, lt = pcall(function()
        return ls:GetBoundingBox()
    end)
    if not lu_2 or not lr then
        return
    end
    pcall(function()
        lq.CFrame = CFrame.new(lr.X, lr.Y + lt.Y / 2 + 3, lr.Z)
    end)
end
io = {}
ik = 0
jj.OnClientEvent:Connect(onOnClientEvent)
i9 = fn352
onEquipBestNow = function()
    if #io == 0 or ik <= 0 then
        return
    end
    local lH_1 = table.clone(io)
    table.sort(lH_1, function(cp, cq)
        local lD = cp.mult or 0
        local lE = lD * i9(cp.traits)
        local lF = cq.mult or 0
        return lE > lF * i9(cq.traits)
    end)
    local lI = {}
    local lJ = math.min(ik, #lH_1)
    local lN = 1
    while lN <= lJ do
        local lO = lN
        lI[lH_1[lO].id] = true
        lN += 1
    end
    for i, v in ipairs(lH_1) do
        local lV = v
        if lI[lV.id] and not lV.equipped then
            pcall(function()
                i6:FireServer(lV.id)
            end)
        else
            if not lI[lV.id] and lV.equipped then
                pcall(function()
                    i3:FireServer(lV.id)
                end)
            end
        end
    end
end
i_ = fn263
iL = fn347
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
jg = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
ip = fn580
ie = fn51
ja = fn652
i0 = fn406
local jq = "#7fd47f"
jp = "#6ec1ff"
iJ = "#e8a34d"
jo = "#8b93a3"
iF = fn354
is = fn478
h8 = fn532
onBuyUpgradesNow = function()
    for k, v in pairs(h8("Upgrades")) do
        local mc = k
        if v then
            pcall(function()
                iT:FireServer(mc)
            end)
        end
    end
end
onBuyBoostsNow = function()
    for k, v in pairs(h8("Boosts")) do
        local mj = k
        if v then
            pcall(function()
                iS:FireServer(mj)
            end)
        end
    end
end
onHatchNow = function()
    local mm, mn
    mm = Options.Egg and Options.Egg.Value
    if not mm or mm == "" or not iy or not iy.EGGS then
        return
    end
    local mo_2 = iy.EGGS[mm]
    if not mo_2 or not mo_2.cost or mo_2.cost.kind ~= "wins" then
        return
    end
    mn = is("HatchCount", 1)
    local mp_1 = ih("Wins")
    if mp_1 < (mo_2.cost.amount or 0) * mn then
        return
    end
    pcall(function()
        h4:FireServer(mm, mn)
    end)
end
local Window = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = iR, Copyable = true }, "|", jh },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local jr = {}
jr.Info = Window:AddTab("Info", "info")
local MainTab = Window:AddTab("Main", "gamepad-2")
jr.Settings = Window:AddTab("Settings", "settings")
MainTab:SetSubTabAlignment("Center")
jr.Clicker = MainTab:AddSubTab("Clicker", "mouse-pointer-click")
jr.Economy = MainTab:AddSubTab("Economy", "coins")
jr.Pets = MainTab:AddSubTab("Pets", "paw-print")
jr.Titles = MainTab:AddSubTab("Titles", "crown")
for k, v in jr do
    fn172(v)
end
ix, AccountGroup, je_5, Label, h5, jd_4 = nil, nil, nil, nil, nil, nil
local jc_3 = 22
repeat
    local jf_2 = (jc_3 * 1 + 0) % 3 + 1
    if jf_2 <= 2 then
        if jf_2 <= 1 then
            local jf_3 = {
                "iyndlj",
                "cwnfaw",
                "ihqlyuxqbcx",
                "rjglilwg",
                "hxdxym",
                "uehx",
                "yscf",
                "ekwytvhen",
                "fbwcuvltobd"
            }
            local nx = jc_3
            jj = jf_3[nx % 9 + 1]
            if jj:len() <= jj:reverse():rep(nx % 3 + 2):len() then
                jd_4 = #h5 > 18
            else
                h5 = #jd_4 > 18
            end
            jc_3 = (jc_3 + 10) % 24
        else
            if (jc_3 * 2 + 7) * 4 % 3 == ((jc_3 * 2 + 7) * 4 + 0) % 3 then
                ix = "Unknown"
                pcall(fn150)
                AccountGroup = jr.Info:AddLeftGroupbox("Account", "circle-user")
                AccountGroup:AddLabel(i0("User", iU.Name, jq), true)
                AccountGroup:AddLabel(i0("Status", "Keyless", jq), true)
                AccountGroup:AddLabel(i0("Executor", ix, jq), true)
                je_5 = jr.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                je_5:AddLabel(ja(jh .. " [" .. tostring(game.PlaceId) .. "]", jp), true)
                je_5:AddLabel(i0("Place ID", tostring(game.PlaceId), jp), true)
                Label = je_5:AddLabel(i0("Session time", "0s", iJ), true)
            else
                iJ = "Unknown"
                pcall(fn150)
                jh = (nil):AddLeftGroupbox("Account", "circle-user")
                jh:AddLabel(jq("User", ja.Name, AccountGroup), true)
                jh:AddLabel(jq("Status", "Keyless", AccountGroup), true)
                jh:AddLabel(jq("Executor", iJ, AccountGroup), true)
                iU = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
                iU:AddLabel(Label(ix .. " [" .. tostring(game.PlaceId) .. "]", jr), true)
                iU:AddLabel(jq("Place ID", tostring(game.PlaceId), jr), true)
                je_5 = iU:AddLabel(jq("Session time", "0s", i0), true)
            end
            jc_3 = (jc_3 + 4) % 24
        end
    else
        local n_ = bit32.rrotate(bit32.bxor(bit32.lrotate(jc_3, 17), string.byte(tostring(Label))), 10)
        if bit32.bxor(bit32.lrotate(bit32.bxor(n_, 921630676), 2), 3686522704) ~= bit32.lrotate(n_, 2) then
            jd_4 = tostring(game.JobId)
        else
            h5 = tostring(game.JobId)
        end
        jc_3 = (jc_3 + 4) % 24
    end
until (jc_3 * 19 + 8) % 24 == 0
if jd_4 then
    local jb_5 = 2
    repeat
        local jc_4 = {
            "xvbdhio",
            "dfbwkl",
            "qqucjw",
            "hwmhwwldexs",
            "ohiqqlh",
            "rmigc",
            "mhpgrddau",
            "rci",
            "ksduo",
            "xtnndkfnapcm",
            "cncildrwi",
            "kltzb",
            "uuunrxayxls"
        }
        if jc_4[(jb_5 * 90 + 20) % 13 + 1] <= jc_4[(jb_5 * 90 + 20) % 13 + 1] then
            jd_4 = string.sub(h5, 1, 18) .. "..."
        else
            h5 = string.sub(jd_4, 1, 18) .. "..."
        end
        jb_5 = (jb_5 + 0) % 4
    until (jb_5 * 3 + 2) % 4 == 0
end
local jb_6 = jd_4 or h5
iV, iH, iD, connection, connection2, iq = nil, nil, nil, nil, nil, nil
je_5:AddLabel(i0("Server", jb_6, jo), true)
je_5:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
iV = os.clock()
task.spawn(worker)
local ScriptsGroup = jr.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(ja("Included in this hub", jo), true)
ScriptsGroup:AddLabel(ja(jh, jp), true)
local FeaturesGroup = jr.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(ja("Auto Click", jp), true)
FeaturesGroup:AddLabel(ja("Auto Win", jq), true)
FeaturesGroup:AddLabel(ja("Auto Rebirth", iJ), true)
FeaturesGroup:AddLabel(ja("Auto Tables", jp), true)
FeaturesGroup:AddLabel(ja("Auto Buy Food", jq), true)
FeaturesGroup:AddLabel(ja("Auto Buy Upgrades", iJ), true)
FeaturesGroup:AddLabel(ja("Auto Buy Boosts", jq), true)
FeaturesGroup:AddLabel(ja("Auto Hatch Eggs", jp), true)
FeaturesGroup:AddLabel(ja("Auto Equip Best Pet", jq), true)
FeaturesGroup:AddLabel(ja("Auto Roll & Equip Titles", iJ), true)
local SocialsGroup = jr.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = ie })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = jr.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = ie })
local FaqGroup = jr.Info:AddRightGroupbox("FAQ", "circle-help")
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
local AutoClickGroup = jr.Clicker:AddLeftGroupbox("Auto Click", "mouse-pointer-click")
AutoClickGroup:AddToggle("AutoClick", { Text = "Auto Click (+1 Fat)", Default = false })
AutoClickGroup:AddSlider("ClickDelay", { Text = "Click delay", Default = 0.1, Min = 0.05, Max = 5, Rounding = 2, Suffix = "s" })
AutoClickGroup:AddButton({ Text = "Click Now", Func = onClickNow })
local AutoWinGroup = jr.Clicker:AddLeftGroupbox("Auto Win", "trophy")
AutoWinGroup:AddToggle("AutoWin", { Text = "Auto Win", Default = false })
AutoWinGroup:AddSlider("WinDelay", { Text = "Refresh delay", Default = 1, Min = 0.2, Max = 30, Rounding = 1, Suffix = "s" })
jj = jr.Clicker:AddRightGroupbox("Auto Rebirth", "rotate-ccw")
jj:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
jj:AddSlider("RebirthDelay", { Text = "Rebirth delay", Default = 3, Min = 1, Max = 120, Rounding = 1, Suffix = "s" })
jj:AddButton({ Text = "Rebirth Now", Func = iI })
local AutoTablesGroup = jr.Clicker:AddRightGroupbox("Auto Tables", "table")
AutoTablesGroup:AddToggle("AutoTables", { Text = "Auto Best Table (by Rebirths)", Default = false })
AutoTablesGroup:AddSlider("TableDelay", { Text = "Table delay", Default = 2, Min = 0.5, Max = 30, Rounding = 1, Suffix = "s" })
AutoTablesGroup:AddButton({ Text = "Go To Best Table", Func = onGoToBestTable })
local AutoBuyFoodGroup = jr.Economy:AddLeftGroupbox("Auto Buy Food", "beef")
AutoBuyFoodGroup:AddToggle("AutoFood", { Text = "Auto Buy Best Food", Default = false })
AutoBuyFoodGroup:AddSlider("FoodDelay", { Text = "Food delay", Default = 5, Min = 1, Max = 120, Rounding = 0, Suffix = "s" })
AutoBuyFoodGroup:AddButton({ Text = "Buy Best Food Now", Func = onBuyBestFoodNow })
local AutoBuyUpgradesGroup = jr.Economy:AddLeftGroupbox("Auto Buy Upgrades", "arrow-up-circle")
AutoBuyUpgradesGroup:AddToggle("AutoUpgrades", { Text = "Auto Buy Upgrades", Default = false })
AutoBuyUpgradesGroup:AddDropdown("Upgrades", { Text = "Upgrades to buy", Values = jm, Multi = true, AllowNull = true, Default = {} })
AutoBuyUpgradesGroup:AddSlider("UpgradeDelay", { Text = "Upgrade delay", Default = 2, Min = 0.5, Max = 60, Rounding = 1, Suffix = "s" })
AutoBuyUpgradesGroup:AddButton({ Text = "Buy Upgrades Now", Func = onBuyUpgradesNow })
local AutoBuyBoostsGroup = jr.Economy:AddRightGroupbox("Auto Buy Boosts", "zap")
AutoBuyBoostsGroup:AddToggle("AutoBoosts", { Text = "Auto Buy Boosts", Default = false })
AutoBuyBoostsGroup:AddDropdown("Boosts", { Text = "Boosts to buy", Values = jl, Multi = true, AllowNull = true, Default = {} })
AutoBuyBoostsGroup:AddSlider("BoostDelay", { Text = "Boost delay", Default = 2, Min = 0.5, Max = 60, Rounding = 1, Suffix = "s" })
AutoBuyBoostsGroup:AddButton({ Text = "Buy Boosts Now", Func = onBuyBoostsNow })
local AutoHatchEggsGroup = jr.Pets:AddLeftGroupbox("Auto Hatch Eggs", "egg")
AutoHatchEggsGroup:AddToggle("AutoHatch", { Text = "Auto Hatch Eggs", Default = false })
AutoHatchEggsGroup:AddToggle("RemoveHatchAnim", { Text = "Remove Hatch Animation", Default = false })
AutoHatchEggsGroup:AddDropdown("Egg", { Text = "Egg", Values = jk, Multi = false, AllowNull = true, Default = jk[1] })
AutoHatchEggsGroup:AddSlider("HatchCount", { Text = "Eggs per hatch", Default = 1, Min = 1, Max = 3, Rounding = 0 })
AutoHatchEggsGroup:AddSlider("HatchDelay", { Text = "Hatch delay", Default = 1, Min = 0.2, Max = 30, Rounding = 1, Suffix = "s" })
AutoHatchEggsGroup:AddButton({ Text = "Hatch Now", Func = onHatchNow })
local AutoEquipPetsGroup = jr.Pets:AddRightGroupbox("Auto Equip Pets", "paw-print")
AutoEquipPetsGroup:AddToggle("AutoEquipPets", { Text = "Auto Equip Best Pets", Default = false })
AutoEquipPetsGroup:AddSlider("PetDelay", { Text = "Equip delay", Default = 3, Min = 0.5, Max = 60, Rounding = 1, Suffix = "s" })
AutoEquipPetsGroup:AddButton({ Text = "Equip Best Now", Func = onEquipBestNow })
local AutoRollTitlesGroup = jr.Titles:AddLeftGroupbox("Auto Roll Titles", "dices")
AutoRollTitlesGroup:AddToggle("AutoRollTitles", { Text = "Auto Roll Titles", Default = false })
AutoRollTitlesGroup:AddSlider("RollDelay", { Text = "Roll delay", Default = 1, Min = 0.3, Max = 30, Rounding = 1, Suffix = "s" })
AutoRollTitlesGroup:AddButton({ Text = "Roll Now", Func = i_ })
local AutoEquipTitlesGroup = jr.Titles:AddRightGroupbox("Auto Equip Titles", "crown")
AutoEquipTitlesGroup:AddToggle("AutoEquipTitle", { Text = "Auto Equip Best Title", Default = false })
AutoEquipTitlesGroup:AddSlider("TitleDelay", { Text = "Equip delay", Default = 5, Min = 1, Max = 120, Rounding = 0, Suffix = "s" })
AutoEquipTitlesGroup:AddButton({ Text = "Equip Best Title Now", Func = iL })
local MenuGroup = jr.Settings:AddLeftGroupbox("Menu", "menu")
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton({ Text = "Unload", Func = onUnload })
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(jr.Settings)
ThemeManager:LoadDefault()
jg:SetLibrary(Library)
jg:IgnoreThemeSettings()
jg:SetIgnoreIndexes({ "MenuKeybind" })
jg:SetFolder("TempoHub/plus-one-fat-per-click")
jg:BuildConfigSection(jr.Settings)
jg:LoadAutoloadConfig()
Toggles.AutoWin:OnChanged(fn508)
Toggles.RemoveHatchAnim:OnChanged(fn194)
h7(Toggles.RemoveHatchAnim.Value)
iH = tick()
iD = tick()
pcall(function()
    for i, v in ipairs(getconnections(iU.Idled)) do
        local mN = v
        pcall(function()
            mN:Disable()
        end)
    end
end)
iq = fn650
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
Library:OnUnload(fn346)
task.spawn(worker2)
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
task.spawn(worker13)
iX()
Library:Notify("+1 Fat Per Click loaded")
end)(...)

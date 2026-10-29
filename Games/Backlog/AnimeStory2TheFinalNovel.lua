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
getgenv().TempoHoodSubtitle = "ANIME STORY 2 THE FINAL NOVE"
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
local e_
local e2
local eK
local eQ
local eT
local eA
local eD
local e1
local eG
local eP
local eV
local eY
local eF
local e0
local eR
local ey
local eU
local eB
local function fn35(Z)
    local f0 = { "Activated", "MouseButton1Click", "MouseButton1Down", "MouseButton1Up" }
    local f1 = false
    for i, v in ipairs(f0) do
        local f0_1 = Z[v]
        if f0_1 then
            local f2 = pcall(firesignal, f0_1)
            f1 = f2 or f1
        end
    end
    return f1
end
local function fn80(ap, aq)
    local gg_1
    local gf_1
    local ge = {}
    if not ap then
        return ge
    end
    for i, descendant in ipairs(ap:GetDescendants()) do
        gf_1, gg_1 = pcall(aq, descendant)
        if gf_1 and gg_1 then
            ge[#ge + 1] = descendant
        end
    end
    return ge
end
local function fn92()
    local gG = setclipboard
    local gH = "https://discord.gg/K7Qxnxkk46"
    if not gG then
        gG = toclipboard
    end
    if not gG then
        gG = Clipboard and Clipboard.set
    end
    local gI_2 = gG
    if gI_2 then
        pcall(gI_2, gH)
        e1("Discord", "Copied invite to clipboard.")
        return
    end
    e1("Discord", gH)
end
local function fn110()
    local SelectedAmount = e0.SelectedAmount
    local gY = tonumber(SelectedAmount:gsub("x", ""))
    local gV = gY and eK(e0.SelectedBanner) and eY("summon_roll", e0.SelectedBanner, gY)
    if gV then
        return
    end
    if not eF() then
        return
    end
    local gV_1 = eP()
    if gV_1 then
        eR(gV_1)
    end
end
local function fn122(b2)
    e0.AutoSummon = b2
end
local function fn124(ay)
    for i, v in ipairs(ay) do
        if eR(v) then
            return true
        end
    end
    return false
end
local function fn126(aW, aX)
    local gK = e_(aX)
    local gL = gK and eD(gK)
    if gL then
        return gK
    end
    local gL_1 = e_(aW)
    if gL_1 then
        eR(gL_1)
        task.wait(0.2)
    end
    local gK_1 = e_(aX)
    local gL_2 = gK_1 and eD(gK_1)
    if gL_2 then
        return gK_1
    end
    return gK_1
end
local function fn160(V)
    local AbsolutePosition = V.AbsolutePosition
    local AbsoluteSize = V.AbsoluteSize
    return AbsolutePosition.X + AbsoluteSize.X / 2, AbsolutePosition.Y + AbsoluteSize.Y / 2
end
local function fn167(w, ...)
    local fF = not eQ or not (function(cP, cQ, cR)
        if type(cP) ~= "string" then
            return false
        end
        if #cP ~= cQ then
            return false
        end
        local cS = 5381
        local cT = buffer.fromstring(cP)
        local cU = 0
        while cU <= cQ - 4 do
            local cV = buffer.readu32(cT, cU)
            local cS_1 = bit32.bxor(cS, cV)
            cS = bit32.band(cS_1 * 33, 4294967295)
            cU = cU + 4
        end
        while cU < cQ do
            local cW = buffer.readu8(cT, cU)
            local cS_2 = bit32.bxor(cS, cW)
            cS = bit32.band(cS_2 * 33, 4294967295)
            cU = cU + 1
        end
        return cS == cR
    end)(type(eQ.SendServer), 8, 2851454103)
    if fF then
        return false
    end
    local fF_1 = pcall(eQ.SendServer, w, ...)
    return fF_1
end
local function fn196(b5)
    e0.AutoClaimBattlepass = b5
end
local function fn228()
    local SelectedAmount = e0.SelectedAmount
    local gT = SelectedAmount:gsub("x", "")
    local gQ = e_("main.Summon.Bottom.Summon." .. gT)
    local gR = gQ and eD(gQ)
    if gR then
        return gQ
    end
    local gQ_1 = e_("main.Summon.Bottom2.Summon." .. gT)
    local gR_1 = gQ_1 and eD(gQ_1)
    if gR_1 then
        return gQ_1
    end
    return nil
end
local function fn286(cY, cZ)
    if type(cY) ~= "number" then
        return false
    end
    if cY % 1 ~= 0 then
        return false
    end
    local c__1 = bit32.bxor(cY, 1540483477)
    local c__2 = bit32.band(c__1 * 403 + bit32.lshift(c__1, 24), 4294967295)
    local c__3 = bit32.bxor(c__2, bit32.rshift(c__2, 13))
    return c__3 == cZ
end
local function fn289(J)
    local fP = eT
    for i, v in ipairs(eB(J)) do
        local fQ = fP and fP:FindFirstChild(v)
        fP = fQ
        if not fP then
            return nil
        end
    end
    return fP
end
local function fn319(b1)
    e0.SelectedAmount = b1
end
local function fn321()
    if eY("unit_equip_best") then
        return
    end
    local hm = ey("main.Hud.Left.A.Units", "main.Units") or e_("main.Units")
    if not hm then
        return
    end
    local hm_1 = e_("main.Units.Base.Content.Left.Buttons.EquipBest")
    if hm_1 then
        eR(hm_1)
    end
end
local function fn371(aO, aP)
    eA.Notify(eA, { Title = aO, Content = aP, Duration = 4 })
end
local function fn384(C)
    local fH = (function(cP, cQ, cR)
        if type(cP) ~= "string" then
            return false
        end
        if #cP ~= cQ then
            return false
        end
        local cS = 5381
        local cT = buffer.fromstring(cP)
        local cU = 0
        while cU <= cQ - 4 do
            local cV = buffer.readu32(cT, cU)
            local cS_5 = bit32.bxor(cS, cV)
            cS = bit32.band(cS_5 * 33, 4294967295)
            cU = cU + 4
        end
        while cU < cQ do
            local cW = buffer.readu8(cT, cU)
            local cS_6 = bit32.bxor(cS, cW)
            cS = bit32.band(cS_6 * 33, 4294967295)
            cU = cU + 1
        end
        return cS == cR
    end)(C, 8, 1056807858) or (function(cP, cQ, cR)
        if type(cP) ~= "string" then
            return false
        end
        if #cP ~= cQ then
            return false
        end
        local cS = 5381
        local cT = buffer.fromstring(cP)
        local cU = 0
        while cU <= cQ - 4 do
            local cV = buffer.readu32(cT, cU)
            local cS_3 = bit32.bxor(cS, cV)
            cS = bit32.band(cS_3 * 33, 4294967295)
            cU = cU + 4
        end
        while cU < cQ do
            local cW = buffer.readu8(cT, cU)
            local cS_4 = bit32.bxor(cS, cW)
            cS = bit32.band(cS_4 * 33, 4294967295)
            cU = cU + 1
        end
        return cS == cR
    end)(C, 5, 1840067283)
    return fH
end
local function fn396()
    local ho = e_("battle.Hud.Top.Content.Speed")
    local hp = not ho or not eD(ho)
    if hp then
        return
    end
    local SelectedSpeed = e0.SelectedSpeed
    local hs = tonumber(SelectedSpeed:gsub("x", ""))
    local hp_1 = hs and eY("battle_speed", hs)
    if hp_1 then
        return
    end
    eR(ho)
    task.wait(0.05)
    local ho_1 = e_("battle.Hud.Top.Content.Speed.Settings." .. tostring(hs))
    if ho_1 then
        eR(ho_1)
    end
end
local function fn398(P)
    local fY = not P or not P:IsDescendantOf(eT)
    if fY then
        return false
    end
    local fY_1 = P
    while true do
        if not (fY_1 and fY_1 ~= eT) then
            return true
        end
        local fZ_1 = fY_1:IsA("GuiObject") and not fY_1.Visible
        if fZ_1 then
            break
        end
        fY_1 = fY_1.Parent
    end
    return false
end
local function fn403()
    ey("main.Hud.Left.C.Summon", "main.Summon")
end
local function fn407()
    if eY("achievement_claimall") then
        return
    end
    local g_ = ey("main.Hud.Left.Achievements", "main.Achievements")
    if not g_ then
        return
    end
    eG(g_, "ClaimAll")
    task.wait(0.1)
    eG(g_, "Claim")
end
local function fn418(b3)
    e0.AutoClaimAchievements = b3
end
local function fn440(bi)
    local g1 = e_(bi)
    if not g1 then
        return false
    end
    local g2 = false
    for i, child in ipairs(g1:GetChildren()) do
        local Notification = child:FindFirstChild("Notification")
        local Locked = child:FindFirstChild("Locked")
        local g4 = Notification and Notification:IsA("GuiObject") and Notification.Visible
        if g4 then
            local g1_2 = eR(child) or g2
            g2 = g1_2
            task.wait(0.08)
        else
            local g1_3 = Locked and Locked:IsA("GuiObject") and not Locked.Visible
            if g1_3 then
                local g1_4 = eR(child) or g2
                g2 = g1_4
                task.wait(0.08)
            end
        end
    end
    return g2
end
local function fn517()
    local hu = e_("battle.Result")
    local hv = not hu or not eD(hu)
    if hv then
        return
    end
    if e0.AutoNext then
        local hv_1 = e_("battle.Result.Base.Content.Buttons.Next")
        local hw = hv_1 and eR(hv_1)
        if hw then
            return
        end
    end
    if e0.AutoRetry then
        if eY("battle_replay") then
            return
        end
        local hv_2 = eV(hu, "Retry") or eV(hu, "Replay")
        if hv_2 then
            return
        end
        local hu_2 = e_("battle.Result.Base.Content.Buttons.Next")
        local hv_3 = hu_2 and eR(hu_2)
        if hv_3 then
            return
        end
    end
    if e0.AutoReturn then
        if eY("battle_leave") then
            eY("battle_end")
            return
        end
        local hu_3 = e_("battle.Result.Base.Content.Buttons.Return") or e_("battle.Result.Return")
        if hu_3 then
            eR(hu_3)
        end
    end
end
local function fn528(b4)
    e0.AutoClaimQuests = b4
end
local function fn531()
    if eY("battlepass_claimall") then
        return
    end
    local hk = ey("main.Hud.Right.A.Battlepass", "main.Battlepass")
    if not hk then
        return
    end
    eG(hk, "Claim")
end
local function fn537(F)
    local fJ = {}
    for k in string.gmatch(F, "[^%.]+") do
        fJ[#fJ + 1] = k
    end
    return fJ
end
local function fn543()
    local hc = ey("main.Hud.Left.B.Quests", "main.Quests")
    if not hc then
        return
    end
    local hc_1 = { "Daily", "Weekly", "Lost Swords", "GamePass Quest" }
    for i, v in ipairs(hc_1) do
        local hc_2 = e_("main.Quests.Base.Content.Left." .. v)
        if hc_2 then
            eR(hc_2)
            task.wait(0.1)
            eU("main.Quests.Base.Content.Top.Rewards")
        end
    end
    eU("main.Special quests.Base.Content.Top.Rewards")
    eU("main.Special quest menu.Base.Content.Top.Rewards")
end
local function fn544()
    local gN = ey("main.Hud.Left.C.Summon", "main.Summon")
    if not gN then
        return false
    end
    local gN_1 = e_("main.Summon.Top." .. e0.SelectedBanner)
    local gO = gN_1 and eR(gN_1)
    if gO then
        task.wait(0.15)
        return true
    end
    return eV(e_("main.Summon.Top"), e0.SelectedBanner)
end
local ex
ey = nil
eA = nil
eB = nil
eD = nil
eF = nil
eG = nil
local eJ
eK = nil
local eO
eP = nil
eQ = nil
eR = nil
eT = nil
eU = nil
eV = nil
local eX
eY = nil
e_ = nil
e0 = nil
e1 = nil
e2 = nil
local eH, eL, eS, eW, eZ, e4, e5, e8, fa, fb, fc, fg
local e7_1
local eN = (buffer.fromstring(")5512{nn&(5)4#o\".,n\x00\"54 -\x0c 25$3\x0e.&6 8n\x07-4$/5l\x13$/$6$%n3$-$ 2$2n- 5$25n%.6/-. %n\x07-4$/5o-4 4]+X!;Np5sGn!eNd}Xy2A@%5cWAD]#M~DC^S^C^B\x11yDSuknXF!^#wvu1#}t+!P*j_&g/W@;43,aNMXX@I\x02~I_Y@X\x02nM_I\x02oCBXIBX\x02nYXXCB_\x02~IXY^Bt[V^Z\x17rARENC_^YP\x17xYTR8wy;vwbVI9&oRXUJZdoeIKQJP`VKT@KSJvSsQN}?lj2,x4*CZ*T9X!cm)R*)<<$-f\x00=,f\x1c'8f\x0b'&<-&<f\x1b8--,f\x1b-<<!&/;fcDQ^TQBT=}IQjzeYqy}w2BUU3?#e%!jxmh*A2xEX@Iy/t7Sj%yNSlWH*qC0E.sJQSmEX:X*oeQPK\x04aUQMT\x04fAWPGAiaBa5QO+gqYjG6zjWsxy1L;n)O3I!KwbfJw7j2t5]#pQ9}rB@IT^hK^^FOHTie!XwS[To!!d!/e]CA}w!&goo|XBRPnC[Lin6vMJ7;(Mlb7y6Kj,Sj.#DsBUQDUtB_@T_G^ZmxSgPygaJv8M?lufvGPTAPaZRRYPh-=bCe[rv!?PH!O3KS;kJINZC[z{qbtrJCx[E198hi3A]&ae&oS^FZMxJVx;d9!J;(W]_)C;=g6IWK$x^FFDE\x0bjFD^E_)y?%*DOUqNjJz]OItPJZ5.*Pxg4:UdW@GTZ]YnsfK%d@gb*L{3.TZ}Ka{dt1_(zwH4p!Qt*L~Z]Z^ZIVxVJs$,]575FP-Xpj]#uvBCX\x17pVZR\x17dGRRSliDV!-1vaR9hS]RNyUTNHUV?y*Bu5s@p/ex)NJROYNY]MIC18Y(Vwz7YJfFE3wVURF_G1Urg*s1$9)S2@bvT}DBEGx%,n:T.8NMT)Fs*6^&-<?':#Vc3j!Aa0T18]Bz:_JND@AZKj0n9c#!]07%zf}K@JcA[]Kl[ZZA@kXK@ZsEMPbKVgLMH@xdz_-#-tERVCRcXPP[R;o-aL{4k_^EiFKCGhK^^FOZKYYjX%Q!maC+wE$U=*lU(q^S[_s^^az#[8Faboy[AGQvA@@[Z\x05p[CZyMLW}9072szwS(SH($,+k\x07$11) 5$66bC@GSJR[Yw,bg6Vk_^EmKGOyZOON=l]JN[Jk]@_K@XAuA@[gAYY[Z+..RHCQt#Zj7Ro0F0o[ZAk_[G^lK]Z\x10!62'6\x07<44?6bSD@UDuNFFMDh^VKyPM|WVS[nJMJNJYFhFZbVWL\x03pVNNLMgSRIuSKKIHuWFaW@D[QWPULRIH^TLWhJ[|J]YFLJsA]vA@@[Zt@AZ{PMAlpQ|W^QXZ[\x9a\x99\x99\x99\x99\x99\xa9?eXE]TV^K333333\xc3?.80-S+nKyZOOW^ueDG@TMU`ABEQHPpQRUAX@QXSQl5kH]]ELgmatchcG]M)d.L[zf[F^WW\xe0n\x06\xd9qQ\x05yMLWt^RS}W[Z~JKPxLMVCGXtN|}4X\x0fM39#\tA![\x01\xa0"))
local eM = (buffer.fromstring("\x0c*<*y\x0b<-+ v\x0b<)58 y0?y)+<*<7-wy\x1f855*y;8:2y-6y\x17<!-y.1<7y-10*y+<*,5-y\x0c\x10y675 y<!)6*<*y\x17<!-w}xi)./F$kL@HO\x0ftOHUR\x0fc@RD\x0fbNOUDOU\x0fmDGU\x0fcTUUNOR\x0fdPTHQcDRUgVAEPApKCCHAhd+vXCDCD3s;&)M.69@$z]DAx}3TwrYwCBYqW[SeFSSRS1_8dHo};vvNDRy*uHs2dS(xv_NwT[[PGqGZEQZB[9J_1i!LrAH4co:e7b,PM75RT1-b@Qv@WSLF@Px4l,9IJx?*&/_9vzAQp?CAhut6{}ALTH_^=;Sj{uv?xm8+c_#_Ni7qKwvenvI?Ki#/' `\x1f;+=:=`\x0c/=+`\r! :+ :`\x1a!>`\x1c+9/<*=o[ZAmBOGCoMFGKXKCK@Z]$8l;%dArUc),x0dEhCJELNObb3Ytjm&X)JOq)(W4MI8zeNKPAnVOWJ=4u&aT{^eweBx-^TCFkVZ0,=xdJaHrHz3)T9$[;j7&@_];vuwnT+-9CVXo1n6lwJWOFB.zkaU9H!50bCDWN6k+/1Z0rzwNsYUTq%AK{@Bc^Y1D[P%su$g*,Tj}Gn=o[ZA\x0e`KVZvrs/mr!Eb{Me[Yd+271ijzB[C^&ywjZocf:cZ93Z0aO$@MWRfBljHEEKHJBu{tc%QJ-a1$jyqO-[:WGA`TUNsDUSXPU5a):toWMFh}@:[DbIafBXH;e#),WBDrdp-$kfi8U50o?YHxMN{EHXDQL##mp-_X*[mN&m2g%f\x1c6/?4.z;/.57;.354z65;>?>tD4tERVCRuBCCXYl*aRAq-oLRY;}@lFJKb7?+ROu!B.kUn}Y4]6m+D{_Xe_LSOsP?(BTp[.;J3j3eDh#$uMzR$}OJ=}@6EQqBP9_JNBJM\rkVG\roFEW\r`\rpVNNLM{ONUyV[SWkO_INIL)UN=B(|HIRoXIHOStIYzU?/!MFT`TUNL@UHNOT,KtgSU-k+yDYAHp+*63yODthQwSbUVGTMJCU$oX44.S4-[zwAHAGPA@wTAA@5}M+*iVCH\x06gENOCPCKCHRUbDH@vU@@AaWJUAJRKl]JN[J{@HHCJgQ-QxEX@I@#+ux@{IVMnQTPXIjGY2o};l;0<43s\x0e(0023s\t2-y]GWfQbuHMd056o^IMXIh^C\\HC[BQRGG_VlAVC_RJuWZZTWU]^75K1uDSWBSbYQQZSrCTPETsDEE^_`QFBWFwLDDOFbSD@UDcTUUNOuDSWBSbWTkq(>//25<(vibVWLqFWVQMRGWU_Y[WD@b_BZS?Vd$IuHUMD$8*4eQPKvAPV]|MZ^KZk^]z[v]T[RPQjDXbNED$iKFFHKIAdPQJk@]Q\x00\x00\x00\x00\x00\x00\xfc?c__[lN_kJINZC[sRQVB[C}JG^NXw@MTDRuVCC[RvNWORg_F^C~C^FOiHr\x1f\xa9\x1c\xeb\x04/91,\x1e\x04\"=\xe7\x1b\xe4&{ONU\xc2\x11\xad\xb5!*8jPb\x08\x02L\x15@\x0b-H0\x17F\x18&t"))
local eI = (buffer.fromstring("\x0c*<*y\x0b<-+ v\x0b<)58 y0?y)+<*<7-wy\x1f855*y;8:2y-6y\x17<!-y.1<7y-10*y+<*,5-y\x0c\x10y675 y<!)6*<*y\x17<!-w/P#OpwHSUT@MhOQTUl@O@FDSwoI&u2+hxhh]A_?51O8Bu1eD}Fn$o[ZA\x0emBOGC\x0elOZZBK^O]]q^.m&jb:OJc1K3r);y:57}nL]mLZJLGMHG]Zo:I)?qo]_D_)t=v-eG(%Gy*t6AOfW@DQ@gPQQJKcIGB-@3r{!lgCK%($,?_VKAuJ.%$uDSWBSrDYFRYAX=I*x43nuj]zc}AP:h__7&Xm@{`ABEQHPDcBOGaaPSExL4Lv/@=V?1;Q:dWxwErkeTCGRCrIAAJCl#3P&I7Q1d)E:j%FWPxr:+r@xLMV/]30*zKwNHwKcnH0[F0nb*PF3N^PZTG?<->' )?;C%RDG#0tErF/vjI4IVb:;x}R34ZLDYPpdHrv2D*mI;+uDy[Rj/D3-HhF%yi7rCTPETe^VV]T,DLyBP]b:+57#0RhkBT6t\x03& 'i\r :*&;-i/&;i\x02,0%,::ifi\r<9,:eQPK]WPPz!N8?fZ:cz9PKJ{uba[itamc^C[RX9jQc/6SSM=xnpH^VjT9-trQ!.2;+5656)+AS-RCI,Tws(WQ:pvxGtW7>5;u%T?hT1iBxsxGTdn/S?BPw@fz2>61q\x0c*2201q\x1d0++02mq\x0c*2201q;`ABEQHPo&2E]PU^(%/{tdicL?,rTmYXC9ly5;7xFlpnW,KL9;sfmvB5NcTY@PFd}QD_2)nYr6SXMm_CPL$k#)(<>;8;;+$v%;:7c#K.{=]RwtlXYBnALD@oLYYAH]L^^:KE{3hpQ|W^QXZ[@S7^Y)ymzq+^H5QzFKCKo4(XFYhm;(68j]BYfN:,$9/T&hV[Ix$Zi$ykoHPAdPQJfIDLHdFML@S@H@KQVhNVVTU\x1bzVTNUOj[2Th1vfRP[ZVEV^V]GlP_RZ^R__uA@[wXU]YvU@@XQDUGGo^IMXInYXXCBUKg$qyQJ^CAcJJ_IX-u,9T}*fwr:lGL.XN-1@;ZWhYUtCVJOEGRCBuRITGACmH[B0({0,-0Y2J,6vWTSG^Fpvf/T,YraLVFJWAvmm(x^p/gSRI\x06cWSOV\x06dCURrDMDBUDE`LNTOUjEBHjE^_XoDE@Hc@UUMD]bL{XqudPQJbDH@vU@@Ao^IMXInYXXCBy]Zg]NQgUv/caW_BpYDu^_ZR|HIR\x1doXIHOS.,!+=*717'?qS^^PSQY[Suj^_DyN_^YE]FXFXND]XLpDE^\x11cTECHl^Bi^__DEnObI@OFDEuDSWBSbWTOKXXLeBnKqPST@YAI\x9a\x99\x99\x99\x99\x99\xc9?nLAAOLNFvTYYWTV^{ZY^JSKpMPHAi?a@CDPIQgP]DTBdGRRJCrORJCkVKSZxDIAIlMPUJlQLT]\xf0 \xba\xe2FPXEqED_P\x9dq\xa95!`\x00lHRB}Gu`Zh\xcc\x017\x03a)1\x048\x1c:/\x0e\x1a"))
local eE = (buffer.fromstring("*6621xmm%+6*7 l!-/m\x03!67#.\x0f#16'0\r-%5#;m\x04.7',6o\x10','5'&m0'.'#1'1m.#6'16m&-5,.-#&m\x04.7',6l.7#7FEPPHATEWW{GHEMIEHHzv*nykn@2r9)T29Vjo?[Y3{zIi12Lo[ZAiOCK}^KKJaN8N:&EUw(gMZRzRf3vixIU*yWLaQVQ($,+k\x140 616mNy%Aj0q@gl;,X0V%=DTp;TKH*kmsU`TUNsDUTSO.*VoHxgv}N{F/$tvNj,rn&kejIW!X?VU@@XQ\x1afQGAX@\x1avUGQ\x1aw[Z@QZ@\x1avA@@[ZG\x1azQL@nXQX^IXYnMXXYaai[5E;8VZy(5;gfT8;@!Mh@-fGjAHGNLMtNmtr7;D}*9NruZRc9JMA#x,&7zeZLDYmrzH@g$t0m3}AK6:gJKS^+$kf8A^[{UcQQ_XM}NI0yNRy:u0c*aC7e}[ySRtvwj8ahIJMY@X+NwYT^!nw]un+TGGsS3OZ*x]cTXnZ[@yl(+H1ZvYm9AwB3Jk}WIX?f0jP,!a\x05 &!o\x0b&<, =+o) =o\x04*6#*<<o`o\x0b:?*<kZI^UO*nHXyJa3eF-FgF=FGWD.zkCX$:?DO<J&Zy{P^F^]x*1m8nDN%:GjlKg4yMLW}IMQHz]KLbBv+b(?Orn-=LRB1$2>61q\x17*;q\r687+q\x1eq\x1d>++3:/>,,#[-5%0((/:rmn*c}$-rD[,qj/4GGAbwRZ_JYEx[g4OZaFp(Z7YWwny--SWpDE^t@DXAsTBE{gh;hb!FGt/)dh\x1b7(1=<x16.1,=x,7x;41(:79*<vpFMGpFQUFQ7_IGN}A?amI&Y1gih=cK8l}{TCFxY[W!])1fHR@l%?3;<|\x1a'6|\x1e74&|\x13|\x07<;&!zXh*~JKPmZKJMQwWV.I3hBA{liOYU]Z\x1a|AP\x1axQR@\x1av\x1aeAQG@GO[FDfOOZL]OEaCA:&?JityXN^OTMITRSkM7by/Qff5:9,,4=v\n=+-4,v\n=,-*6~JKP|S^VR}^KKSZO^LL$5,}a*_N8fEjETa*Uo&eQPK\x04wQIIKJv,m7r&)hJ[|J]YFLJ3NANF@t7vBCX\x17t[V^Z\x17fBRDCDmN_C@YXI|C_EXECBOTSNe_KOSJeX_INiVCH\x06dGRRJCVGUUpRCsRDTRYSVYCDwJWOFOt}S$e)I^mBEOmBYX_hCBGOfBXH[NNF!l@6!prCTPETsDEE^_AuDSWBStCBBYXaY@XEm2gToJ%gVAEPApKCCHAzEP[\x15d@PFAFnOYIXCZ^CED~JKP\x1fmZKJMQk_^ExO^_XDwUXXVUW_A)0<43s\x0834).xYt_VYPRSa@mFO@IKJz{3K}W+rgcBoDMBKIHlNCCMNLDiMWG!H(]\x00\x00\x00\x00\x00\x00\xe8?o^YJ_BDERDLQrzM&6:'1;+vTEN[^Tn%9{ktiJ__GNLO^HQd[^ZRxEX@IoROW^kOUEaX^Y\x11\x0cr\x12\xb6Q\xc7\x07d@ZJ\x1dR\x0c\xb0mYXC@V^Ciohs8\x05?\n\x06^+_.G4\x07*"))
local eC = (buffer.fromstring("\x0e+-*d\x00-7'+6 d\"+6d\x0f!=(!77dkd\x0014!74X9wlnClO+6T&LP{nZEBOBwDMv3?70p\r.;=7?2~/+;-*~3;0+p\x1c?-;p\x1d10*;0*p\n1.p\x0c;)?,:-KGOH\x08gENOCPCKCHRU*&#eh%=)Bzw16+WIy3w(:A*)VDimW`AWGAJ@EJPkB1Qg9t@A1@1F]clpo=r)%)9^_AeSu$# 55-$o\x13$24-5o\x03 2$o\x02./5$/5o\x03455./2o\x0f$95OuWMK]zMLLWV\tmHMkHXZ4k3XmEm6MyIBi,owlcZTkJgLEJCA@YUybHwvA=8k[b*?Y-10gIsFf$n-]qNBJM\rpVNNLMNa!]_1rKJnT_zYeq4gg4pwH:iR`TUNf@LDrQDDEN)(8pOym;Z6@Ye%8(R;gH:=J@EI@H^Gq)}(DEad*if9R(KZz7vt]xs_*6G\x06,5%.4`!54/-!4)/.`,/!$%$n)58FC*@;XwCBYxSNB@Ua^-WHyqcsnq5ak[fZ.WAjudrnSNV_#e:A!?;=3.,oW;-dc3Q}A-r)}IXjwX_UwXCBErYX]U:WU_y^dB-?36!a1s!mrDMDBUu@C;gZ/jHYxqAAF({AJi]4$t/jHY~H_[DNHQW&/RC#KC3ja0x*^S&4.%)!&f\x00=,f\x04-.<f\nf\x19=-;<;67UzxGQw>( =C2/,pC01,D+Zozx?!s#uGYDA7{J]YL]lW__T]xw;6sD+QGVP{gyNB`V_VPGVWqR]]VA4^p?HczwNDJN+7k_^Ey_GGED_f4u5(}%#W9qdT,NCqPST@YA4x;,SDdB}MImNwEi.-zq@WSFWf]UU^W!I5m[%GO-F49tY@LDC\x03lNEDH[H@HCY^k9$^[A9N{XTV[g[VNREOe{vLT;BOSPDb@MMC@BJ;gP[y8{gCP,iAv2yZOOW^2:K/SWHG.DnlMK3;j^_D\x0bhGJBF\x0biJ__GN[JXXrJSKVViU,EY^9s9}VB[JwCBYdSBCDX$d8fwg)G*fIDLHEx/VDO5R*P/)wewAHAGPA@fEJJAVx$r&+nZ[@|ZBB@A+D3UTr1CbSD@UDuNFFMD(Yo3my[AGQvA@@[Z\x05wX]W_uZV^?f^&BH=}sBcz`TUNbM@HLpTDRUR~JKP|S^VRnJZLKL`TUNrTLLNOdGh0GlU.N4p,lEcIBej[LH]Lm[FYMF^G}@]EL/?*&7^Ha~JKPx^RZlOZZ[eDiBKDMON*BX7hYNJ_Ni^__DEHK^^FOuYZOONlQLT]xP&(N$iVCH\x06wSCURUeZOD\ny_GGEDuA@[gAYY[Z|HIR\x1doXIODlJFN\x0bx[NNOkJgLEJCA@bCnELCJHIvGPTAPaTWnZ[@,5ci%{\x14\xaeG\xe1z\xb4?333333\xe3?fDIIGDFNcYJUq,#V*4#3?*=0hRSBk=CG_BTCcTY@PF/1/959~]QYWVwJWOFlowerpMPHAvRHXrXTU/;=*BVPGdKGO9-+<tQB[nJP@\xa4\x01`)o&\x08=\x1d7heIU5Vl"))
local ez = (buffer.fromstring("5916v\t-=+,+v\x1a9+=v\x1b76,=6,v\x14=>,v_wmc&WIh=nCXIrS@wxs.D&rneclcdPQJfIDLHdFML@S@H@KQV2L5a%SPjHmbcRA,_Lm1O5mMbE]O6:25u\x08+>82:7{*.>(/(u\x19:(>u\x1845/>5/u\x0f4+u\t>,:)?(\x1f:<;u\x11<&6:'1u3:'u\x1e0,90&&uzu\x11 %0&Yt;.^Xl=X(UzNOTxWZRVjN^HOHIK6v#q}Pc2x?Wya_.c1}^lrv$vTYYWTV^&pLW^I,3CHkBz?p,Vp{MCGo+)*k2zV@`TUNbM@HLc@UUMDQ@RRiR&rw]_0UZ?C)3=H{x?eKWmAJKu!]bcFBdMaxJ^G_Fzf^@HR1=K1}naa\x08-+,b\x06+1!-0&b$-0b\t';.'11bmb\x0672'1b[*TqED_~UHD:Ys?aYXoCQk/lCC/_Jkhdy5l0]4C@UUMD~MD@WDB.Y{&VS+_!H@dBb2.JW:_frDLQcJWfMLIAoemaLH=hnOTj}k/BmnL:2C\x19<:=s\x17: 0<!7s5<!s\x186*?6  s|s\x17&#6 bUCYJUcsZNCf3V4Fljm@:78z=T@je1r:vDX~S[TREfi;{dxFUqGPQUxcnP:^C/aELBE[LE[gi9nbtuWeW^285Gr}XB9BEpQRUAX@KnSPR;dse6*,:*ad;{M/,$drORJCh[HUOA[LL-Qh@aS^X4*QRwIAX[NNV_\x14rO^\x14nUJ\x14yUTN_TN\x14iJ__^sA]{V^QW@}cp7jkj,gRc;Ty6R/M;\x1e\x04+,( e\x161*7<ewe\x0401*($1,*+\x18e^IZI^_INF:(T6q.XLaxF@VNdFr9vGPTAPw@AAZ[-ujOdj#r.fFR1uHUMDOHu5{;;KP$wXq,6MI8/_e^P_CtXYCEX[)TXrDtND-zlliXOK^O}CDNE]TwBNO6IrJ2sRQVB[CIcTm(8RCtkvg-;agZG_V*rhVhfy=?;]o=D.ifW@DQ@qJBBI@sfK@2{3pqQMVJJ0iwd+GF,IaJg.qzM@YI_EyJaD@DP2)G_Ok_^EiFKCG{_OY^Y#YO%uJOKC=mFt}Dgl&QN+4}J_CFLN[JK|[@]NHJuTyR[T]_^s[P-bsulN_hCBGOYNE4$V7Mz]HGMH[MK7LhJ?9;dPQJfIDLHtP@VQVhNYoROW^RlvbD:cYnOYIODNKD^eL}6z.L?@w:CG9O:L@HO\x0fpTDRURg&\x01.)-%`\x134/29`r{AF[V[F[G\x14|AVtERVCR`^YSX@vWLQ^Q[YLQWVnZ[@X-1/LF$ZV^Y\x19dBZZXYoCBXIBXK_Bgt@AZf@XXZ[uCHBuCTPCTb@Qv@WSLF@dEhCJELNOsBUQDUdQRo^IMXIxMN|HIRoXIOD`TUNoDYUxZWWYZXPrTCuHUMD\x00\x00\x00\x00\x00\x00\xf8?oNMJ^G_wUDOZ_UsP__TCdE^CLSc@UUMDsPEE]TiTIQXqLQI@nSNV_\xe1\xfb\xdd\xc2,8.?\xb2\x9b\xfd>\xafb\x8eVeA[K\x9e`\xf8W\x01q\x04\xe1de-2$5f,N$\x12Y\x10\x02\x1eRD9\x14EB"))
local ew = (buffer.fromstring("FJBE\x05c^O\x05gNM_\x05jHCBN]NFNE_XkZ]W,_fmz6fL]QSBRzxYAyS4IM.-Tp(4403zoo$)3#/2$n''o&s$\n(\x04'9\x141IWq-(f;(RnItgs[ga9v%Sh^W^XO^_yZUU^IWaSd}^BsiF[Zqp,vOw@)dh(nh.=MqMwQ]Uc@UUTtB_@T_G^janB/D5s}(:n5{_#*2ttVuTgjfYLG\tkH]]ELYHZZXg_d(&2#ss97jN1oYo(ov=Dg3uA@[fQ@AFZ9BGFgc2)g-%6h%d6dnz$_qYh}2?m-bjKfMDKB@A(P%%pwzopZ{:/32ZV$XFF9ZQ%rd{!sLWQPDIlKUPQhDKDB@W^^3Hq1G?%$[Afy.8p_wT[[PGqGZEQZB[%(I*9c*V-e(r?}i!=Qe7!xi^OIBjKrAAz7Eeh7!FDYAu_Nt#*dJgICl[A\x1f,#m\"#(m ,#8,!m.!,$ b(<8$=m.4.!(cgo[ZAmBOGClOZZBK^O]]Kz9mtmp,-Cb!9:qED_uAEY@rUCDRB/ojTa^/EE2ADk[t)Txa@mFO@IKJrR6!XP_K:,}LRT+@OQm8HZueXE]TT(_K$f$fke63!;5USM!V]dTK-.xNEOfD^XNi^__DEn]NE_;[t%P2c^t+gKISHRbTIVBIQHo4ple@}v3Jx(YTQ-wCBYuZW_[wU^_S@S[SXBE@AINao,{tERVCRsEXGSX@Y8zhR)g5j8bw/CwgFEBVOWR_c9[qg+.Y{X8T,Y5I3NML@HO\x0fc@UUMDQ@RR,XX#n@m?.5Dt|_NRQHIXnTGX:A^W)DeWVPow?C7;34t\t/7754t\x0e5*t@yGiQk4)@Ot@AZgPAGLL9Zu*eC7zB;!!Lyt=)/8.!(F}/Yc+HQcfgEe0dP6?_#qyt6sXclb[DZ2QU9zN5?[Ihub:Cxko,OHW.Qzt%dQi_V_YN_^{WUOTNp,3uL$/RTWJDKTVPScs8LG,BiKj(vBCXt[V^ZuVCC[RGVDDy^KDNKXNSC(*9)w/^HgyHUYH6g_sLjaHfCR}A;gQXQW@QPvUZZQFjr7quJ_T\x1a{YRS_L_W_TNIo^COyNOOTU2OU)Mg~C^FO28R1P*[Lb=cbXj#S4JWyt,wOIFb{YTTZY[SpbV6U/tlZSZ\\KZ[}^QQZMzLELJ]LMkHGGL[gQXQW@QPuY[AZ@zNOT~JNRKy^HObT]TRETUbATTUo[ZAVu5Tsr?xY|MZ^KZ}JKKPQm[SN|UHyRSV^aB^Y\r~ZB_I^zEP[\x15f@XXZ[126$.)8SUw,cG]MLaG2Xr-!).n\x15.)43MN[[CJpJAKfPYPVAaTWb@WJUBWFGq@]QiDG@IyMLWj]LJA?902$$?>fAT[QTGQsGF]|WJFp]GW[FPjKHO[BZnOLK_F^pOUODJCaBWWOFeRG[VNx[TT_HgZG_VzGZBKc^C[RQEQE\xbe\xca\x0b\xc3\xe3f\xc2\xc0\x97\xbc\xf5\xa9I\xae8\xf8M\x12.n\xe91z\x03oUg) +D\x02\x1f(WP\x13Z\x0c,=;K\x19O"))
local e3 = (buffer.fromstring("R^VQ\x11wJ[\x11mVXWK\x11~\x11}^KKSZO^LLHiiX2%Y(PZ9$*q{^0YoAMT-s%ubVWL`OBJNb@KJFUFNFMWPpyp_w&bf6f/x7fSFx7oH/(X2Uq7ojobM@HL\x01dWDSXUIHOF\x01nOBDf;}MDEGsMaH1Lq/u{xx${qQ_{bVWL`OBJNb@KJFUFNFMWPCO%+zfEm5{G*8RWCWAA8uzHTr_WX^I4le7%Qo#SbI@/wcy+_{HvUW]wP]KKR:pVZRgVDD\x17fBRDC8yg*%24a[R)e?N$QYBvq:s^^@j^_DyN_YRU^:+Fe,)eV7,b?q1zKeR=O_CAP5AO\x01.)-%`\x134/29`rbC7lg1QlU7L;&c=[Y_txOTvEdSE_LSuj/*Y&d18$&?Q#O*$mh4jK5u$tkVX8^X@@BCr_BAA3g)9HEo($T(t87I^?O5,82g/#5$$9>7#}bAWsCb:IcaX%oJiUCy$,LxR@)yOFOI^ONyZOON?;}3],y=YH089RA;Ry.fW}KBKMZKJoCA[@ZOV[,!1k{0i0Nr6=s=uI$'22*#h\x14#53*2MdXgi4zRNo+Rq/^L9&@gSRI\x06eJGOK\x06gENOCPCKCHRUIf(w-/e9yMLW\x18v]@LG9]C3TsrDwq:Na[cvV&K-vBCXZVC^XY%P[7B%4&LrD}3{vI$Oy=lM`KBMDFG;v(qp)NU+)!Nc=YE&GA$zNOTVZORTUu5&V{?Si3;sMCGFY(m`QFBWFaVWWLMGY1aFZt@+#9SZb)60<43s\x15(9s\x118;)s\x1c>548+8083).84807w\n,4467w\x1b6--64w\n,4467w\x07:'?6mBJOg??7U=3P{(EtLT%]z~JKP\x1fx^RZ\x1flOZZ[:u63Q&dl2HzGZBKk]8]dSU1PvybQH-eEu{ONU\x1ayV[SW\x1a{YRS_L_W_TNICOG@\x00f[J\x00bKHZ\x00m\x00}[CCA@cYkGq?whpe*?#::d9(a0OzFKSOXm_ChWgapt_U!H8vBCX\x17t[V^Z\x17fBRDCD4Jr  =#;7?avcr0(_e=hJ.mYXC~IX^U.b*.Q2@SDHSXRBYWALRWi!i[D[QJ~JKPzNJVO}ZLKu#hGbT]TRETUsP__TC+%y^KDNKXNd_qLP61!gSRIaGKCuVCCB_mH>)<WuL2byfv4@{rh^W^XO^_zVTNUOzFKSOXYRN]/]T$vTYYWTV^Xmn6c/lOZZBKW*5?5&%a@mFO@IKJUDvbk_^Eo[_CZhOY^yH_[N_nU]]V_sBUQDUrEDD_^--$4 49#(WcjIEGJvJG_CTDGSFLBULMQGzE_EN@IgXcUH^FFBGHJAmKGO\nyZOONqED_~UHDcPDDKF^YIRt@AZgPAGLrP]]SPRZ{YTTZY[SWD_REX^_\x9a\x99\x99\x99\x99\x99\xb9?yLOzDIYEjEH@DE}gXBXS]TfZZ^iKZ?>/'8*nMXX@IhK^^FO}@]EL{F[CJyDYAH\xd32\xadmbVWLwM^AlFJK&\x0c<nlXYB\xb2\xed\xd1\x91FODsr:g.\x16\rS%2Q6]\x1bf\x11T\x00"))
e2, eZ, eT, eQ = nil, nil, nil, nil
local e6 = 2
repeat
    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(e6, 27), string.byte(tostring(eQ))), 10), 1848513101), 3803848944), (bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(e6, 27), string.byte(tostring(eQ))), 10), 2446454194), 3048018370))), 3803848944), 3048018370) ~= bit32.rrotate(bit32.bxor(bit32.lrotate(e6, 27), string.byte(tostring(eQ))), 10) then
        e2 = game:GetService(game)
        game.GetService(game, "Players")
        eT = game:GetService("VirtualInputManager")
        eZ = game
        eZ.WaitForChild(eZ, "ReplicatedStorage")
    else
        e4 = game:GetService("Players")
        e2 = game:GetService("ReplicatedStorage")
        eZ = game:GetService("VirtualInputManager")
        e5 = e4.LocalPlayer
        eT = e5:WaitForChild("PlayerGui")
    end
    e6 = (e6 + 7) % 8
until fn286((e6 * 1 + 0) % 8, 527583337)
e4, e5 = pcall(function()
    local API = e2:WaitForChild("API")
    local Utils = API:WaitForChild("Utils")
    return require(Utils:WaitForChild("network"))
end)
if e4 then
    eQ = e5
end
eA, e4, fc, e0, eY, eK, eB, e_, eD, eS, eH, eR, eL, eW, eG, eV, e1, e6, ey, eF, eP, fa, ex, eU, eO, eX, eJ, e8, fb, e7_1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local e9 = 56
repeat
    e5 = (e9 * 17 + 16) % 20 + 1
    if e5 <= 10 then
        if e5 <= 5 then
            if e5 <= 3 then
                if e5 <= 2 then
                    if e5 <= 1 then
                        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(e9, 8), string.byte(tostring(eU))), 23), 4164464201), 1475895454), (bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(e9, 8), string.byte(tostring(eU))), 23), 130503094), 652483559))), 1475895454), 652483559) == bit32.rrotate(bit32.bxor(bit32.lrotate(e9, 8), string.byte(tostring(eU))), 23) then
                            eU = fn440
                        else
                            e4 = fn440
                        end
                        e9 = (e9 + 13) % 80
                    else
                        if (e9 * 2 + 3) * 10 % 3 == ((e9 * 2 + 3) * 10 + 8) % 3 then
                            e1 = fn543
                        else
                            eO = fn543
                        end
                        e9 = (e9 + 53) % 80
                    end
                else
                    if bit32.bxor(bit32.lrotate(bit32.bxor(bit32.rrotate(bit32.bxor(bit32.lrotate(e9, 24), string.byte(tostring(eA))), 12), 1849429030), 12), 3233965795) == bit32.lrotate(bit32.rrotate(bit32.bxor(bit32.lrotate(e9, 24), string.byte(tostring(eA))), 12), 12) then
                        eX = fn531
                    else
                        eR = fn531
                    end
                    e9 = (e9 + 53) % 80
                end
            elseif e5 <= 4 then
                if e9 * 107929687 + 10 + 5 <= e9 * 107929687 + 10 + 5 + 2 then
                    eJ = fn321
                else
                    eL = fn321
                end
                e9 = (e9 + 33) % 80
            else
                local fd_1 = (vector.create((e9 * 5 + 5) % 11 + 1, (e9 * 10 + 9) % 13 + 1, (e9 * 10 + 7) % 17 + 1))
                local fe_1 = (vector.create((e9 * 5 + 5) % 11 + 1, (e9 * 5 + 6) % 13 + 1, (e9 * 1 + 15) % 17 + 1))
                local ff_1 = (vector.create((e9 * 2 + 7) % 11 + 1, (e9 * 9 + 12) % 13 + 1, (e9 * 8 + 11) % 17 + 1))
                fg = (vector.create((e9 * 1 + 7) % 5 + 1, (e9 * 4 + 4) % 7 + 1, (e9 * 4 + 1) % 9 + 1))
                if vector.dot(vector.cross(fd_1, (vector.cross(fe_1, ff_1))), fg) == vector.dot(fe_1 * vector.dot(fd_1, ff_1) - ff_1 * vector.dot(fd_1, fe_1), fg) + 2 then
                    eV = fn396
                else
                    e8 = fn396
                end
                e9 = (e9 + 73) % 80
            end
        elseif e5 <= 8 then
            if e5 <= 7 then
                if e5 <= 6 then
                    local fd_2 = (vector.create((e9 * 4 + 8) % 11 + 1, (e9 * 8 + 8) % 13 + 1, (e9 * 2 + 13) % 17 + 1))
                    local fe_2 = (vector.create((e9 * 6 + 8) % 11 + 1, (e9 * 7 + 2) % 13 + 1, (e9 * 11 + 4) % 17 + 1))
                    local ff_2 = (vector.create((e9 * 4 + 7) % 11 + 1, (e9 * 5 + 3) % 13 + 1, (e9 * 6 + 8) % 17 + 1))
                    fg = (vector.create((e9 * 6 + 4) % 11 + 1, (e9 * 7 + 5) % 13 + 1, (e9 * 13 + 2) % 17 + 1))
                    if vector.dot(vector.cross(fd_2, fe_2), (vector.cross(ff_2, fg))) == vector.dot(fd_2, ff_2) * vector.dot(fe_2, fg) - vector.dot(fd_2, fg) * vector.dot(fe_2, ff_2) + 2 then
                        eW = fn517
                    else
                        fb = fn517
                    end
                    e9 = (e9 + 33) % 80
                else
                    if e9 * 58339817 + 12 + 5 <= e9 * 58339817 + 12 + 5 + 1 then
                        e7_1 = function(bW, bX, bY)
                            task.spawn(function()
                                local hA_2
                                local hz_2
                                while true do
                                    hz_2, hA_2 = pcall(function()
                                        if e0[bW] then
                                            bY()
                                        end
                                    end)
                                    if not hz_2 then
                                        warn("[Anime Story 2 Automation] " .. tostring(hA_2))
                                    end
                                    task.wait(bX)
                                end
                            end)
                        end
                    else
                        eG = function(bW, bX, bY)
                            task.spawn(function()
                                local hA_1
                                local hz_1
                                while true do
                                    hz_1, hA_1 = pcall(function()
                                        if e0[bW] then
                                            bY()
                                        end
                                    end)
                                    if not hz_1 then
                                        warn("[Anime Story 2 Automation] " .. tostring(hA_1))
                                    end
                                    task.wait(bX)
                                end
                            end)
                        end
                    end
                    e9 = (e9 + 13) % 80
                end
            else
                if (e9 * 2 + 7) * 13 % 3 == ((e9 * 2 + 7) * 13 + 4) % 3 then
                    local Auto3 = eX.Auto
                    Auto3.CreateButton(Auto3, "Title")
                    local Auto2 = eX.Auto
                    local fl = { "Standard", "Slime" }
                    local fn = Auto2
                    local fd_4 = (fn:CreateDropdown(fc, Auto3))
                    fd_4.OnChanged(fd_4, Auto2)
                    local fq = { Values = { "50x", "1x", "10x" }, Title = "Summon Amount", Default = 2, Multi = false }
                    local Auto = eX.Auto
                    local fs = Auto:CreateDropdown("AmountDropdown", fl)
                    local ft = fn319
                    fs.OnChanged(fs, "Standard")
                    local fu = { Title = "Auto Summon", Default = false }
                    local fv = eX.Auto
                    local fw = fn122
                    fq = (fv:CreateToggle(ft, fq))
                    fq.OnChanged(fq, "10x")
                    fq = { Title = "Auto Claim Achievements", Default = false }
                    ft = eX.Auto
                    fv = fn418
                    fu = (ft:CreateToggle(fu, fw))
                    fu.OnChanged(fu, eX)
                    fw = { Title = "Auto Claim Quests", Default = false }
                    local fx = eX.Auto
                    fg = (fx:CreateToggle("Callback", eX))
                    fg.OnChanged(fg, "Default")
                    local fm = { Title = "Auto Claim Battlepass", Default = false }
                    fx = eX.Auto
                    local fz = fn196
                    fl = (fx:CreateToggle("Default", fv))
                    fl.OnChanged(fl, "Auto Summon")
                    local fj = eX.Auto
                    fv = { Title = "Auto Equip Best", Default = false }
                    fx = fj
                    fq = (fx:CreateToggle(fz, fq))
                    fq.OnChanged(fq, "AutoSummon")
                    fx = eX.Battle
                    fx.CreateButton(fx, "Auto Claim Battlepass")
                    local fB = { Title = "Game Speed", Default = 3, Values = { "2x", "1x", "3x" }, Multi = false }
                    local Battle = eX.Battle
                    local fD = (Battle:CreateDropdown(false, eX))
                    fD.OnChanged(fD, eX)
                    fD = eX.Battle
                    local fp = (fD:CreateToggle("Default", "Callback"))
                    fp.OnChanged(fp, eX)
                    fq = eX.Battle
                    fn = (fq:CreateToggle("1x", "1x"))
                    fn.OnChanged(fn, fv)
                    fn = eX.Battle
                    fq = fn
                    fj = (fq:CreateToggle("Title", fj))
                    fj.OnChanged(fj, "AutoClaimAchievements")
                    fl = { Title = "Auto Return", Default = false }
                    local fo = eX.Battle
                    fq = (fo:CreateToggle(fB, "Title"))
                    fq.OnChanged(fq, "Values")
                    fo = eX.Misc
                    fv = fo
                    fv.CreateButton(fv, "Values")
                    fx = { Title = "Open Summon", Callback = fn403 }
                    fz = eX.Misc
                    fz.CreateButton(fz, "Description")
                    fp = eX.Misc
                    fp.CreateButton(fp, eX)
                    fp = eX.Misc
                    fp.CreateButton(fp, eX)
                    fp = eX.Misc
                    fp.CreateButton(fp, "Join Discord for Keyless / Dupes")
                    fp = eX.Misc
                    fz = fp
                    fz.CreateButton(fz, "Banner")
                    eJ(fm, fp, "Title")
                    eJ("AutoSummon", fn, "3x")
                    eJ("Join Discord for Keyless / Dupes", "AutoReturn", "Auto Claim Quests")
                    eJ("GameSpeedDropdown", "Title", "Callback")
                    eJ(fl, eX, false)
                    eJ("Slime", fx, e7_1)
                    eJ(fw, eX, "Auto Game Speed")
                    eJ("Claim Everything Once", false, "Title")
                    eJ("Title", fn528, eJ)
                    eO.SelectTab(eO, fo)
                    e4(fs, eJ)
                else
                    local fd_6 = { Title = "Join Discord for Keyless / Dupes", Callback = e6 }
                    local Auto8 = fc.Auto
                    Auto8.CreateButton(Auto8, fd_6)
                    local fe_5 = { Title = "Banner", Values = { "Standard", "Slime" }, Multi = false, Default = 1 }
                    local Auto7 = fc.Auto
                    fg = function(b0)
                        e0.SelectedBanner = b0
                    end
                    local fd_7 = (Auto7:CreateDropdown("BannerDropdown", fe_5))
                    fd_7.OnChanged(fd_7, fg)
                    local fe_6 = { Title = "Summon Amount", Values = { "1x", "10x", "50x" }, Multi = false, Default = 2 }
                    local Auto6 = fc.Auto
                    fg = fn319
                    local fd_8 = (Auto6:CreateDropdown("AmountDropdown", fe_6))
                    fd_8.OnChanged(fd_8, fg)
                    local fe_7 = { Title = "Auto Summon", Default = false }
                    local Auto5 = fc.Auto
                    fg = fn122
                    local fd_9 = (Auto5:CreateToggle("AutoSummon", fe_7))
                    fd_9.OnChanged(fd_9, fg)
                    local fe_8 = { Title = "Auto Claim Achievements", Default = false }
                    local Auto4 = fc.Auto
                    fg = fn418
                    local fd_10 = (Auto4:CreateToggle("AutoClaimAchievements", fe_8))
                    fd_10.OnChanged(fd_10, fg)
                    local fe_9 = { Title = "Auto Claim Quests", Default = false }
                    local Auto3 = fc.Auto
                    fg = fn528
                    local fd_11 = (Auto3:CreateToggle("AutoClaimQuests", fe_9))
                    fd_11.OnChanged(fd_11, fg)
                    local fe_10 = { Title = "Auto Claim Battlepass", Default = false }
                    local Auto2 = fc.Auto
                    fg = fn196
                    local fd_12 = (Auto2:CreateToggle("AutoClaimBattlepass", fe_10))
                    fd_12.OnChanged(fd_12, fg)
                    local fe_11 = { Title = "Auto Equip Best", Default = false }
                    local Auto = fc.Auto
                    fg = function(b6)
                        e0.AutoEquipBest = b6
                    end
                    local fd_13 = (Auto:CreateToggle("AutoEquipBest", fe_11))
                    fd_13.OnChanged(fd_13, fg)
                    local fd_14 = { Title = "Join Discord for Keyless / Dupes", Callback = e6 }
                    local Battle6 = fc.Battle
                    Battle6.CreateButton(Battle6, fd_14)
                    local fe_13 = { Title = "Game Speed", Values = { "1x", "2x", "3x" }, Multi = false, Default = 3 }
                    local Battle5 = fc.Battle
                    fg = function(b7)
                        e0.SelectedSpeed = b7
                    end
                    local fd_15 = (Battle5:CreateDropdown("GameSpeedDropdown", fe_13))
                    fd_15.OnChanged(fd_15, fg)
                    local fe_14 = { Title = "Auto Game Speed", Default = false }
                    local Battle4 = fc.Battle
                    fg = function(b8)
                        e0.AutoGameSpeed = b8
                    end
                    local fd_16 = (Battle4:CreateToggle("AutoGameSpeed", fe_14))
                    fd_16.OnChanged(fd_16, fg)
                    local fe_15 = {
                        Title = "Auto Retry",
                        Description = "Uses Retry/Replay if present. Falls back to Next when this result UI only exposes Next.",
                        Default = false
                    }
                    local Battle3 = fc.Battle
                    fg = function(b9)
                        e0.AutoRetry = b9
                    end
                    local fd_17 = (Battle3:CreateToggle("AutoRetry", fe_15))
                    fd_17.OnChanged(fd_17, fg)
                    local fe_16 = { Title = "Auto Next", Default = false }
                    local Battle2 = fc.Battle
                    fg = function(ca)
                        e0.AutoNext = ca
                    end
                    local fd_18 = (Battle2:CreateToggle("AutoNext", fe_16))
                    fd_18.OnChanged(fd_18, fg)
                    local fe_17 = { Title = "Auto Return", Default = false }
                    local Battle = fc.Battle
                    fg = function(cb)
                        e0.AutoReturn = cb
                    end
                    local fd_19 = (Battle:CreateToggle("AutoReturn", fe_17))
                    fd_19.OnChanged(fd_19, fg)
                    local fd_20 = { Title = "Join Discord for Keyless / Dupes", Callback = e6 }
                    local Misc6 = fc.Misc
                    Misc6.CreateButton(Misc6, fd_20)
                    local fd_21 = { Title = "Open Summon", Callback = fn403 }
                    local Misc5 = fc.Misc
                    Misc5.CreateButton(Misc5, fd_21)
                    local fd_22 = {
                        Title = "Open Quests",
                        Callback = function()
                            ey("main.Hud.Left.B.Quests", "main.Quests")
                        end
                    }
                    local Misc4 = fc.Misc
                    Misc4.CreateButton(Misc4, fd_22)
                    local fd_23 = {
                        Title = "Open Achievements",
                        Callback = function()
                            ey("main.Hud.Left.Achievements", "main.Achievements")
                        end
                    }
                    local Misc3 = fc.Misc
                    Misc3.CreateButton(Misc3, fd_23)
                    local fd_24 = {
                        Title = "Open Battlepass",
                        Callback = function()
                            ey("main.Hud.Right.A.Battlepass", "main.Battlepass")
                        end
                    }
                    local Misc2 = fc.Misc
                    Misc2.CreateButton(Misc2, fd_24)
                    local fd_25 = {
                        Title = "Claim Everything Once",
                        Callback = function()
                            ex()
                            eO()
                            eX()
                            eJ()
                            e1("Automation", "Ran one manual claim/equip cycle.")
                        end
                    }
                    local Misc = fc.Misc
                    Misc.CreateButton(Misc, fd_25)
                    e7_1("AutoSummon", 0.75, fa)
                    e7_1("AutoClaimAchievements", 1.5, ex)
                    e7_1("AutoClaimQuests", 1.75, eO)
                    e7_1("AutoClaimBattlepass", 1.5, eX)
                    e7_1("AutoEquipBest", 2, eJ)
                    e7_1("AutoGameSpeed", 1, e8)
                    e7_1("AutoNext", 0.6, fb)
                    e7_1("AutoRetry", 0.6, fb)
                    e7_1("AutoReturn", 0.6, fb)
                    e4.SelectTab(e4, 1)
                    e1("Anime Story 2", "Fluent automation loaded.")
                end
                e9 = (e9 + 53) % 80
            end
        elseif e5 <= 9 then
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(e9, 22), string.byte(tostring(eX))), 12), 1452171951), 3775164673), (bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(e9, 22), string.byte(tostring(eX))), 12), 2842795344), 82517161))), 3775164673), 82517161) ~= bit32.rrotate(bit32.bxor(bit32.lrotate(e9, 22), string.byte(tostring(eX))), 12) then
                ey = loadstring(game:HttpGet(loadstring))()
            else
                eA = getgenv().Fluent
            end
            e9 = (e9 + 33) % 80
        else
            local fd_26 = {
                "kidnxortrbz",
                "rxymojijjzu",
                "hciyblzwi",
                "vsjtonxrjq",
                "iofdrrih",
                "vjcsmnmnq",
                "foafxofx",
                "vvkuma"
            }
            if fd_26[(e9 * 1 + 87) % 8 + 1] <= fd_26[(e9 * 1 + 87) % 8 + 1] then
                e4 = eA:CreateWindow({
                    Title = "Tempo Hub",
                    SubTitle = "Lust",
                    TabWidth = 160,
                    Size = UDim2.fromOffset(580, 460),
                    Resize = true,
                    MinSize = Vector2.new(520, 420),
                    Acrylic = true,
                    Theme = "Dark",
                    MinimizeKey = Enum.KeyCode.RightControl
                })
            else
                eA = e4:CreateWindow(Vector2.new)
            end
            e9 = (e9 + 13) % 80
        end
    elseif e5 <= 15 then
        if e5 <= 13 then
            if e5 <= 12 then
                if e5 <= 11 then
                    if e9 * 89223641 + 11 + 7 >= e9 * 89223641 + 11 + 7 + 3 then
                        e4 = fc
                    else
                        fc = {
                            Auto = e4:CreateTab({ Title = "Automation", Icon = "sparkles" }),
                            Battle = e4:CreateTab({ Title = "Battle", Icon = "swords" }),
                            Misc = e4:CreateTab({ Title = "Misc", Icon = "settings-2" })
                        }
                    end
                    e9 = (e9 + 53) % 80
                else
                    if e9 * 6299957 + 4 + 5 <= e9 * 6299957 + 4 + 5 + 1 then
                        e0 = {
                            AutoClaimAchievements = false,
                            AutoSummon = false,
                            SelectedBanner = "Standard",
                            SelectedAmount = "10x",
                            AutoClaimQuests = false,
                            AutoClaimBattlepass = false,
                            AutoEquipBest = false,
                            AutoRetry = false,
                            AutoNext = false,
                            AutoReturn = false,
                            AutoGameSpeed = false,
                            SelectedSpeed = "3x"
                        }
                        eY = fn167
                        eK = fn384
                        eB = fn537
                    else
                        eY = "AutoSummon"
                        e0 = fn167
                        eB = fn384
                        eK = fn537
                    end
                    e9 = (e9 + 73) % 80
                end
            else
                local fe_24 = ({
                    "kpnpnxrknz",
                    "suvkejuwqr",
                    "wiwama",
                    "iunrr",
                    "dpfw",
                    "kadh",
                    "uqbbv",
                    "quj",
                    "sptflk",
                    "gzlttpuzxs",
                    "dtxesyi"
                })[e9 % 11 + 1]
                local fd_28 = fe_24:len()
                local ff_15 = (fe_24:gsub("(.)", "%1%1", e9 % 3 % 2 + 1))
                if fd_28 >= ff_15:len() then
                    eS = fn289
                    e_ = fn398
                    eD = fn160
                else
                    e_ = fn289
                    eD = fn398
                    eS = fn160
                end
                e9 = (e9 + 33) % 80
            end
        elseif e5 <= 14 then
            if (e9 * 2 + 9) * 16 % 3 == ((e9 * 2 + 9) * 16 + 3) % 3 then
                eH = fn35
                eR = function(ai)
                    local ga, gb
                    local gc = not ai or not ai:IsDescendantOf(eT)
                    local gc_4
                    if gc then
                        return false
                    elseif not eD(ai) then
                        return false
                    else
                        local gc_3 = ai:IsA("GuiButton") and eH(ai)
                        if gc_3 then
                            return true
                        end
                        gc_4, ga, gb = pcall(eS, ai)
                        if not gc_4 then
                            return false
                        end
                        pcall(function()
                            eZ.SendMouseButtonEvent(eZ, ga, gb, 0, true, game, 0)
                            task.wait()
                            eZ.SendMouseButtonEvent(eZ, ga, gb, 0, false, game, 0)
                        end)
                        return true
                    end
                end
                eL = fn80
                eW = fn124
                eG = function(aC, aD)
                    return eW(eL(aC, function(aE)
                        local gw = aE:IsA("GuiButton") and aE.Name == aD
                        return gw
                    end))
                end
            else
                eL = fn35
                eH = function(ai)
                    local ga, gb
                    local gc = not ai or not ai:IsDescendantOf(eT)
                    local gc_2
                    if gc then
                        return false
                    elseif not eD(ai) then
                        return false
                    else
                        local gc_1 = ai:IsA("GuiButton") and eH(ai)
                        if gc_1 then
                            return true
                        end
                        gc_2, ga, gb = pcall(eS, ai)
                        if not gc_2 then
                            return false
                        end
                        pcall(function()
                            eZ.SendMouseButtonEvent(eZ, ga, gb, 0, true, game, 0)
                            task.wait()
                            eZ.SendMouseButtonEvent(eZ, ga, gb, 0, false, game, 0)
                        end)
                        return true
                    end
                end
                eR = fn80
                eG = fn124
                eW = function(aC, aD)
                    return eW(eL(aC, function(aE)
                        local gw = aE:IsA("GuiButton") and aE.Name == aD
                        return gw
                    end))
                end
            end
            e9 = (e9 + 13) % 80
        else
            if ((e9 and not eU or (eS or e9)) and (not eL and e_ and (not e_ and eU)) or ((not e9 or not e9) and (not eU and e_) or (not eL or eU or (not e9 or eS)))) and not ((e9 and not eU or (eS or e9)) and (not eL and e_ and (not e_ and eU)) or ((not e9 or not e9) and (not eU and e_) or (not eL or eU or (not e9 or eS)))) then
                eL = function(aH, aI)
                    return eW(eL(aH, function(aJ)
                        if not aJ:IsA("GuiButton") then
                            return false
                        elseif string.lower(aJ.Name) == string.lower(aI) then
                            return true
                        else
                            for i, descendant in ipairs(aJ:GetDescendants()) do
                                local gy = descendant:IsA("TextLabel") or descendant:IsA("TextButton")
                                if gy then
                                    if string.lower(descendant.Text) == string.lower(aI) then
                                        return true
                                    end
                                end
                            end
                            return false
                        end
                    end))
                end
            else
                eV = function(aH, aI)
                    return eW(eL(aH, function(aJ)
                        if not aJ:IsA("GuiButton") then
                            return false
                        elseif string.lower(aJ.Name) == string.lower(aI) then
                            return true
                        else
                            for i, descendant in ipairs(aJ:GetDescendants()) do
                                local gy = descendant:IsA("TextLabel") or descendant:IsA("TextButton")
                                if gy then
                                    if string.lower(descendant.Text) == string.lower(aI) then
                                        return true
                                    end
                                end
                            end
                            return false
                        end
                    end))
                end
            end
            e9 = (e9 + 33) % 80
        end
    elseif e5 <= 18 then
        if e5 <= 17 then
            if e5 <= 16 then
                if (e9 * 2 + 7) * 16 % 3 == ((e9 * 2 + 7) * 16 + 4) % 3 then
                    e6 = fn371
                else
                    e1 = fn371
                end
                e9 = (e9 + 73) % 80
            else
                if (e9 * 2 + 2) * 4 % 3 == ((e9 * 2 + 2) * 4 + 6) % 3 then
                    e6 = fn92
                else
                    ex = fn92
                end
                e9 = (e9 + 13) % 80
            end
        else
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(e9, 15), string.byte(tostring(eW))), 12), 3269327841), 2953597469), (bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(e9, 15), string.byte(tostring(eW))), 12), 1025639454), 3272329918))), 2953597469), 3272329918) == bit32.rrotate(bit32.bxor(bit32.lrotate(e9, 15), string.byte(tostring(eW))), 12) then
                ey = fn126
                eF = fn544
                eP = fn228
            else
                eP = fn126
                ey = fn544
                eF = fn228
            end
            e9 = (e9 + 33) % 80
        end
    elseif e5 <= 19 then
        e5 = {
            "cwwxumjza",
            "wbflhirc",
            "dqaciomarv",
            "rsbjug",
            "ccjznzwmf",
            "qoxhdqf",
            "psgrxvaxyes",
            "jrbwooh"
        }
        local fd_29 = e5[e9 % 8 + 1]
        e5 = e9 % 3 + 2
        local fe_25 = (fd_29:reverse())
        local iK = e5
        e5 = fd_29:len()
        local ff_16 = (fe_25:rep(iK))
        if e5 >= ff_16:len() then
            eY = fn110
        else
            fa = fn110
        end
        e9 = (e9 + 33) % 80
    else
        e5 = (vector.create((e9 * 1 + 2) % 11 + 1, (e9 * 7 + 6) % 13 + 1, (e9 * 12 + 14) % 17 + 1))
        local fd_30 = (vector.create((e9 * 4 + 8) % 11 + 1, (e9 * 3 + 5) % 13 + 1, (e9 * 4 + 15) % 17 + 1))
        local fe_26 = (vector.create((e9 * 5 + 5) % 11 + 1, (e9 * 11 + 13) % 13 + 1, (e9 * 9 + 7) % 17 + 1))
        local ff_17 = (vector.create((e9 * 2 + 4) % 5 + 1, (e9 * 2 + 4) % 7 + 1, (e9 * 5 + 5) % 9 + 1))
        if vector.dot(vector.cross(e5, (vector.cross(fd_30, fe_26))), ff_17) == vector.dot(fd_30 * vector.dot(e5, fe_26) - fe_26 * vector.dot(e5, fd_30), ff_17) + 1 then
            eH = fn407
        else
            ex = fn407
        end
        e9 = (e9 + 53) % 80
    end
until fn286((e9 * 27 + 6) % 80, 309464081)
end)(...)

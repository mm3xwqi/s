
UILib = {
    _font_face = Drawing.Fonts.UI,
    _font_size = 13,
    _drawings = {},
    _tree = {},
    _menu_open = true,
    _menu_toggled_at = 0,
    _watermark_enabled = true,
    _notifications = {},
    _notifications_spawned = 0,
    _open_tab = nil,
    _tab_change_at = 0,
    _inputs = {['m1']={id=0x01,held=false,click=false},['m2']={id=0x02,held=false,click=false},['mb']={id=0x04,held=false,click=false},['unbound']={id=0x08,held=false,click=false},['tab']={id=0x09,held=false,click=false},['enter']={id=0x0D,held=false,click=false},['shift']={id=0x10,held=false,click=false},['ctrl']={id=0x11,held=false,click=false},['alt']={id=0x12,held=false,click=false},['pause']={id=0x13,held=false,click=false},['capslock']={id=0x14,held=false,click=false},['esc']={id=0x1B,held=false,click=false},['space']={id=0x20,held=false,click=false},['pageup']={id=0x21,held=false,click=false},['pagedown']={id=0x22,held=false,click=false},['end']={id=0x23,held=false,click=false},['home']={id=0x24,held=false,click=false},['left']={id=0x25,held=false,click=false},['up']={id=0x26,held=false,click=false},['right']={id=0x27,held=false,click=false},['down']={id=0x28,held=false,click=false},['insert']={id=0x2D,held=false,click=false},['delete']={id=0x2E,held=false,click=false},['0']={id=0x30,held=false,click=false},['1']={id=0x31,held=false,click=false},['2']={id=0x32,held=false,click=false},['3']={id=0x33,held=false,click=false},['4']={id=0x34,held=false,click=false},['5']={id=0x35,held=false,click=false},['6']={id=0x36,held=false,click=false},['7']={id=0x37,held=false,click=false},['8']={id=0x38,held=false,click=false},['9']={id=0x39,held=false,click=false},['a']={id=0x41,held=false,click=false},['b']={id=0x42,held=false,click=false},['c']={id=0x43,held=false,click=false},['d']={id=0x44,held=false,click=false},['e']={id=0x45,held=false,click=false},['f']={id=0x46,held=false,click=false},['g']={id=0x47,held=false,click=false},['h']={id=0x48,held=false,click=false},['i']={id=0x49,held=false,click=false},['j']={id=0x4A,held=false,click=false},['k']={id=0x4B,held=false,click=false},['l']={id=0x4C,held=false,click=false},['m']={id=0x4D,held=false,click=false},['n']={id=0x4E,held=false,click=false},['o']={id=0x4F,held=false,click=false},['p']={id=0x50,held=false,click=false},['q']={id=0x51,held=false,click=false},['r']={id=0x52,held=false,click=false},['s']={id=0x53,held=false,click=false},['t']={id=0x54,held=false,click=false},['u']={id=0x55,held=false,click=false},['v']={id=0x56,held=false,click=false},['w']={id=0x57,held=false,click=false},['x']={id=0x58,held=false,click=false},['y']={id=0x59,held=false,click=false},['z']={id=0x5A,held=false,click=false},['numpad0']={id=0x60,held=false,click=false},['numpad1']={id=0x61,held=false,click=false},['numpad2']={id=0x62,held=false,click=false},['numpad3']={id=0x63,held=false,click=false},['numpad4']={id=0x64,held=false,click=false},['numpad5']={id=0x65,held=false,click=false},['numpad6']={id=0x66,held=false,click=false},['numpad7']={id=0x67,held=false,click=false},['numpad8']={id=0x68,held=false,click=false},['numpad9']={id=0x69,held=false,click=false},['multiply']={id=0x6A,held=false,click=false},['add']={id=0x6B,held=false,click=false},['separator']={id=0x6C,held=false,click=false},['subtract']={id=0x6D,held=false,click=false},['decimal']={id=0x6E,held=false,click=false},['divide']={id=0x6F,held=false,click=false},['f1']={id=0x70,held=false,click=false},['f2']={id=0x71,held=false,click=false},['f3']={id=0x72,held=false,click=false},['f4']={id=0x73,held=false,click=false},['f5']={id=0x74,held=false,click=false},['f6']={id=0x75,held=false,click=false},['f7']={id=0x76,held=false,click=false},['f8']={id=0x77,held=false,click=false},['f9']={id=0x78,held=false,click=false},['f10']={id=0x79,held=false,click=false},['f11']={id=0x7A,held=false,click=false},['f12']={id=0x7B,held=false,click=false},['numlock']={id=0x90,held=false,click=false},['scrolllock']={id=0x91,held=false,click=false},['lshift']={id=0xA0,held=false,click=false},['rshift']={id=0xA1,held=false,click=false},['lctrl']={id=0xA2,held=false,click=false},['rctrl']={id=0xA3,held=false,click=false},['lalt']={id=0xA4,held=false,click=false},['ralt']={id=0xA5,held=false,click=false},['semicolon']={id=0xBA,held=false,click=false},['plus']={id=0xBB,held=false,click=false},['comma']={id=0xBC,held=false,click=false},['minus']={id=0xBD,held=false,click=false},['period']={id=0xBE,held=false,click=false},['slash']={id=0xBF,held=false,click=false},['tilde']={id=0xC0,held=false,click=false},['lbracket']={id=0xDB,held=false,click=false},['backslash']={id=0xDC,held=false,click=false},['rbracket']={id=0xDD,held=false,click=false},['quote']={id=0xDE,held=false,click=false}},
    _slider_drag = nil,
    _menu_drag = nil,
    _menu_resize = nil,
    _min_w = 360,
    _min_h = 300,
    _watermark_drag = nil,
    _watermark_x = 20,
    _watermark_y = 20,
    _rainbow_enabled = false,
    _rainbow_hue = 0,
    _rainbow_last_t = 0,
    _tab_scroll = {},
    _scroll_step = 22,
    _scroll_drag = nil,
    _input_ctx = nil,
    _overwrite_menu_key = false,
    _menu_key = 'f1',
    _active_dropdown = nil,
    _active_colorpicker = nil,
    _copied_color = nil,
    _tooltip_hover_time = nil,
    _tooltip_mouse_prev = nil,
    _activities = {},

    title = 'My menu',
    _custom_title_enabled = false,
    _custom_title = '',
    w = 400,
    h = 480,
    x = 20,
    y = 100,
    _padding = 8,
    _tab_h = 40,
    _theming = {
        accent   = Color3.fromRGB(0, 128, 255),
        unsafe   = Color3.fromRGB(255, 255, 51),
        body     = Color3.fromRGB(5, 5, 5),
        text     = Color3.fromRGB(255, 255, 255),
        subtext  = Color3.fromRGB(120, 120, 120),
        border1  = Color3.fromRGB(40, 40, 40),
        border0  = Color3.fromRGB(32, 32, 32),
        surface1 = Color3.fromRGB(42, 42, 42),
        surface0 = Color3.fromRGB(24, 24, 24),
        crust    = Color3.fromRGB(0, 0, 0),
    },
}

local function clamp(x, a, b)
    if x > b then return b elseif x < a then return a else return x end
end

local function getDictLength(dict)
    local i = 0
    for _ in pairs(dict) do i = i + 1 end
    return i
end

local function rgbToHsv(r, g, b)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, v = 0, 0, max
    local d = max - min
    if max ~= 0 then s = d / max end
    if d == 0 then
        h = 0
    else
        if max == r then
            h = (g - b) / d
            if g < b then h = h + 6 end
        elseif max == g then
            h = (b - r) / d + 2
        elseif max == b then
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    return h, s, v
end

do
    function UILib:_KeyIDToName(keyId)
        for keyName, key in pairs(self._inputs) do
            if key.id == keyId then return keyName end
        end
        return nil
    end

    function UILib:_IsKeyPressed(keycode)
        return self._inputs[keycode].click
    end

    function UILib:_IsKeyHeld(keycode)
        return self._inputs[keycode].held
    end

    function UILib:_GetScreenSize()
        local screenSize = Vector2.new(1920, 1080)
        local camera = workspace.CurrentCamera
        if camera and camera.ViewportSize then
            screenSize = camera.ViewportSize
        end
        return screenSize
    end

    function UILib:_GetMousePos()
        local mousePos = Vector2.new()
        local myPlayer = game:GetService('Players').LocalPlayer
        if myPlayer then
            local myMouse = myPlayer:GetMouse()
            if myMouse then
                mousePos = Vector2.new(myMouse.X, myMouse.Y)
            end
        end
        return mousePos
    end

    function UILib:_IsMouseWithinBounds(origin, size)
        local mousePos = self:_GetMousePos()
        return mousePos.x >= origin.x and mousePos.x <= origin.x + size.x
           and mousePos.y >= origin.y and mousePos.y <= origin.y + size.y
    end
end

do
    function UILib:_GetTextBounds(text, fontFace, fontSize)
        fontFace = fontFace or self._font_face
        fontSize = fontSize or self._font_size
        if fontFace == Drawing.Fonts.UI then
            return Vector2.new(#text * fontSize * 0.53846, fontSize)
        end
        return Vector2.new(#text * fontSize, fontSize)
    end

    function UILib:_Lerp(a, b, t)
        return a + (b - a) * t
    end

    function UILib:_Draw(drawId, drawType, drawColor, drawZIndex, ...)
        local draw = self._drawings[drawId]

        if drawType == 'rect' then
            if not draw then
                self._drawings[drawId] = Drawing.new('Square')
                return self:_Draw(drawId, drawType, drawColor, drawZIndex, ...)
            end
            local rectPosition, rectSize, rectFilled = ...
            draw.Position = rectPosition
            draw.Size = rectSize
            draw.Filled = rectFilled
        elseif drawType == 'text' then
            if not draw then
                self._drawings[drawId] = Drawing.new('Text')
                return self:_Draw(drawId, drawType, drawColor, drawZIndex, ...)
            end
            local textPosition, textContent, textOutline, textAlign, textSize, textFontFace = ...
            if textAlign == 'center' then
                draw.Center = true
                draw.Position = textPosition
            else
                draw.Position = textPosition
            end
            draw.Text = textContent
            draw.Outline = textOutline
            draw.Font = textFontFace or self._font_face
            draw.Size = textSize or self._font_size
        elseif drawType == 'line' then
            if not draw then
                self._drawings[drawId] = Drawing.new('Line')
                return self:_Draw(drawId, drawType, drawColor, drawZIndex, ...)
            end
            local lineFrom, lineTo, lineThickness = ...
            draw.From = lineFrom
            draw.To = lineTo
            draw.Thickness = lineThickness or 1
        elseif drawType == 'triangle' then
            if not draw then
                self._drawings[drawId] = Drawing.new('Triangle')
                return self:_Draw(drawId, drawType, drawColor, drawZIndex, ...)
            end
            local triangleFilled, trianglePointA, trianglePointB, trianglePointC = ...
            draw.Filled = triangleFilled
            draw.PointA = trianglePointA
            draw.PointB = trianglePointB
            draw.PointC = trianglePointC
        elseif drawType == 'gradient' then
            local args = {...}
            if #args == 4 then
                local firstColor = args[4]
                local tintColor = self._theming.crust
                table.insert(args, Color3.new(
                    self:_Lerp(firstColor.R, tintColor.R, 0.5),
                    self:_Lerp(firstColor.G, tintColor.G, 0.5),
                    self:_Lerp(firstColor.B, tintColor.B, 0.5)
                ))
            end
            local gradientDirection = args[1]
            local gradientOrigin = args[2]
            local gradientSize = args[3]
            local numSegments = (#args - 3) - 1
            local lod = 26
            for i = 4, #args-1 do
                local currentColor = args[i]
                local nextColor = args[i+1]
                local segmentLengthX = gradientSize.x / numSegments
                local segmentLengthY = gradientSize.y / numSegments
                for j = 1, lod do
                    local t = (j-1) / (lod-1)
                    local targetColor = Color3.new(
                        self:_Lerp(currentColor.R, nextColor.R, t),
                        self:_Lerp(currentColor.G, nextColor.G, t),
                        self:_Lerp(currentColor.B, nextColor.B, t)
                    )
                    local targetAlpha = self:_Lerp(currentColor.A or 1, nextColor.A or 1, t)
                    local segmentPosition, segmentSize
                    if gradientDirection == 'horizontal' then
                        segmentSize = Vector2.new(segmentLengthX / lod, gradientSize.y)
                        segmentPosition = Vector2.new(
                            gradientOrigin.x + (i-4) * segmentLengthX + (j-1) * segmentSize.x,
                            gradientOrigin.y
                        )
                    elseif gradientDirection == 'vertical' then
                        segmentSize = Vector2.new(gradientSize.x, segmentLengthY / lod)
                        segmentPosition = Vector2.new(
                            gradientOrigin.x,
                            gradientOrigin.y + (i-4) * segmentLengthY + (j-1) * segmentSize.y
                        )
                    end
                    local segmentDrawId = drawId .. '_' .. tostring(i) .. '_' .. tostring(j)
                    self:_Draw(segmentDrawId, 'rect', targetColor, drawZIndex, segmentPosition, segmentSize, true)
                    self:_SetOpacity(segmentDrawId, targetAlpha)
                end
            end
            return
        end

        draw.Color = drawColor
        draw.ZIndex = drawZIndex
        draw.Visible = true
    end

    function UILib:_RemoveDraw(drawId)
        local drawObject = self._drawings[drawId]
        if drawObject then drawObject:Remove() end
    end

    function UILib:_Undraw(drawId)
        local drawObject = self._drawings[drawId]
        if drawObject then drawObject.Visible = false end
    end

    function UILib:_SetOpacity(drawId, opacity)
        local drawObject = self._drawings[drawId]
        if drawObject then drawObject.Transparency = opacity end
    end

    function UILib:_RemoveDrawStartsWith(drawId)
        for drawName, _ in pairs(self._drawings) do
            if drawName:sub(1, #drawId) == drawId then
                UILib:_RemoveDraw(drawName)
            end
        end
    end

    function UILib:_UndrawStartsWith(drawId)
        for drawName, _ in pairs(self._drawings) do
            if drawName:sub(1, #drawId) == drawId then
                UILib:_Undraw(drawName)
            end
        end
    end

    function UILib:_SetOpacityStartsWith(drawId, opacity)
        for drawName, _ in pairs(self._drawings) do
            if drawName:sub(1, #drawId) == drawId then
                UILib:_SetOpacity(drawName, opacity)
            end
        end
    end
end

do
    function UILib:_SpawnColorpicker(position, label, value, callback)
        self:_RemoveColorpicker()
        local h, s, v = 0, 0, 0
        if value then h, s, v = rgbToHsv(value.R, value.G, value.B) end
        self._active_colorpicker = {
            position = position or Vector2.new(self.x + self.w + self._padding, self.y),
            label = label,
            callback = callback,
            _h = h or 0,
            _s = s or 0,
            _v = v or 0,
            _spawned_at = os.clock()
        }
    end

    function UILib:_RemoveColorpicker()
        self._active_colorpicker = nil
        self:_UndrawStartsWith('colorpicker_')
    end

    function UILib:_SpawnDropdown(position, width, value, choices, multi, callback)
        self:_RemoveDropdown()
        self._active_dropdown = {
            position = position,
            width = width,
            value = value,
            choices = choices,
            multi = multi,
            callback = callback,
            _spawned_at = os.clock()
        }
    end

    function UILib:_RemoveDropdown()
        self._active_dropdown = nil
        self:_UndrawStartsWith('dropdown_')
    end

    function UILib:_Toggle(tabName, sectionName, label, value, callback, unsafe, tooltip)
        local itemId = #self._tree[tabName]._items[sectionName]._items + 1
        local item = {
            type_ = 'toggle',
            label = label,
            value = value,
            callback = callback,
            unsafe = unsafe or false,
            tooltip = tooltip,
        }
        table.insert(self._tree[tabName]._items[sectionName]._items, item)

        return {
            Set = function(_, newValue)
                self._tree[tabName]._items[sectionName]._items[itemId].value = newValue
                if self._tree[tabName]._items[sectionName]._items[itemId].callback then
                    self._tree[tabName]._items[sectionName]._items[itemId].callback(newValue)
                end
            end,
            AddKeybind = function(_, value, mode, canChange, callback)
                local kb = {
                    value = value,
                    callback = callback,
                    mode = mode or 'Hold',
                    canChange = canChange or true,
                    _listening = false,
                    _listening_start = 0
                }
                self._tree[tabName]._items[sectionName]._items[itemId].keybind = kb
                return {
                    Set = function(_, newValue, newMode)
                        local m = newMode or self._tree[tabName]._items[sectionName]._items[itemId].keybind.mode
                        self._tree[tabName]._items[sectionName]._items[itemId].keybind.value = newValue
                        self._tree[tabName]._items[sectionName]._items[itemId].keybind.mode = m
                        if self._tree[tabName]._items[sectionName]._items[itemId].keybind.callback then
                            self._tree[tabName]._items[sectionName]._items[itemId].keybind.callback(newValue, m)
                        end
                    end
                }
            end,
            AddColorpicker = function(_, label, value, overwrite, callback)
                local cp = {
                    label = label,
                    value = value or self._theming.accent,
                    overwrite = overwrite,
                    callback = callback
                }
                self._tree[tabName]._items[sectionName]._items[itemId].colorpicker = cp
                return {
                    Set = function(_, newValue)
                        self._tree[tabName]._items[sectionName]._items[itemId].colorpicker.value = newValue
                        if self._tree[tabName]._items[sectionName]._items[itemId].colorpicker.callback then
                            self._tree[tabName]._items[sectionName]._items[itemId].colorpicker.callback(newValue)
                        end
                    end
                }
            end
        }
    end

    function UILib:_Slider(tabName, sectionName, label, value, step, min, max, suffix, callback)
        local itemId = #self._tree[tabName]._items[sectionName]._items + 1
        table.insert(self._tree[tabName]._items[sectionName]._items, {
            type_ = 'slider',
            label = label,
            value = value,
            step = step,
            min = min,
            max = max,
            suffix = suffix or '',
            callback = callback
        })
        return {
            Set = function(_, newValue)
                self._tree[tabName]._items[sectionName]._items[itemId].value = newValue
                if self._tree[tabName]._items[sectionName]._items[itemId].callback then
                    self._tree[tabName]._items[sectionName]._items[itemId].callback(newValue)
                end
            end
        }
    end

    function UILib:_Dropdown(tabName, sectionName, label, value, choices, multi, callback)
        local itemId = #self._tree[tabName]._items[sectionName]._items + 1
        table.insert(self._tree[tabName]._items[sectionName]._items, {
            type_ = 'dropdown',
            label = label,
            value = value,
            choices = choices,
            multi = multi,
            callback = callback
        })
        return {
            Set = function(_, newValue)
                self._tree[tabName]._items[sectionName]._items[itemId].value = newValue
                if self._tree[tabName]._items[sectionName]._items[itemId].callback then
                    self._tree[tabName]._items[sectionName]._items[itemId].callback(newValue)
                end
            end,
            UpdateChoices = function(_, newChoices)
                self._tree[tabName]._items[sectionName]._items[itemId].choices = newChoices
            end
        }
    end

    function UILib:_Button(tabName, sectionName, label, callback)
        table.insert(self._tree[tabName]._items[sectionName]._items, {
            type_ = 'button',
            label = label,
            callback = callback
        })
        return {}
    end

    function UILib:_Textbox(tabName, sectionName, label, value, callback)
        local itemId = #self._tree[tabName]._items[sectionName]._items + 1
        table.insert(self._tree[tabName]._items[sectionName]._items, {
            type_ = 'textbox',
            label = label,
            value = value,
            callback = callback
        })
        return {
            Set = function(_, newValue)
                self._tree[tabName]._items[sectionName]._items[itemId].value = newValue
                if self._tree[tabName]._items[sectionName]._items[itemId].callback then
                    self._tree[tabName]._items[sectionName]._items[itemId].callback(newValue)
                end
            end
        }
    end

    function UILib:_Section(tabName, sectionName)
        self._tree[tabName]._items[sectionName] = { _items = {} }
        return {
            Toggle   = function(_, ...) return self:_Toggle(tabName, sectionName, ...)   end,
            Slider   = function(_, ...) return self:_Slider(tabName, sectionName, ...)   end,
            Dropdown = function(_, ...) return self:_Dropdown(tabName, sectionName, ...) end,
            Button   = function(_, ...) return self:_Button(tabName, sectionName, ...)   end,
            Textbox  = function(_, ...) return self:_Textbox(tabName, sectionName, ...)  end,
        }
    end


    function UILib:GetMenuSize()
        return Vector2.new(self.w, self.h)
    end

    function UILib:SetWatermarkEnabled(value)
        self._watermark_enabled = value
    end

    function UILib:SetMenuTitle(newTitle)
        self.title = newTitle
    end

    function UILib:SetMenuPosition(newPos)
        self.x = newPos.x or self.x
        self.y = newPos.y or self.y
    end

    function UILib:SetMenuSize(newSize)
        self.w = newSize.x or self.w
        self.h = newSize.y or self.h
    end

    function UILib:CenterMenu()
        local ss = self:_GetScreenSize()
        local ms = self:GetMenuSize()
        self:SetMenuPosition(Vector2.new(ss.x/2 - ms.x/2, ss.y/2 - ms.y/2))
    end

    function UILib:Notification(text, time)
        table.insert(self._notifications, {
            text = text,
            time = time,
            _id = self._notifications_spawned,
            _spawned_at = os.clock()
        })
        self._notifications_spawned = self._notifications_spawned + 1
    end

    function UILib:Tab(tabName)
        self._tree[tabName] = { _items = {} }
        if not self._open_tab then self._open_tab = tabName end
        return {
            Section = function(_, sectionName)
                return self:_Section(tabName, sectionName)
            end
        }
    end

    function UILib:CreateSettingsTab(customName)
        local settingsTab = self:Tab(customName or 'Menu')
        local menuSection = settingsTab:Section('Menu')

        local menuKey = menuSection:Toggle('Ov. menu key', self._overwrite_menu_key, function(v)
            self._overwrite_menu_key = v
        end)
        menuKey:AddKeybind(self._menu_key, 'Hold', false, function(v)
            self._menu_key = self:_KeyIDToName(v)
        end)
        menuSection:Toggle('Watermark', true, function(v) self:SetWatermarkEnabled(v) end)
        menuSection:Toggle('Custom menu title', self._custom_title_enabled, function(v)
            self._custom_title_enabled = v
        end)
        self._custom_title = self.title
        menuSection:Textbox('Menu title', self.title, function(v) self._custom_title = v end)

        local themingSection = settingsTab:Section('Theming')
        local themes = {'Default','Gamesense','Bitchbot','Neverlose','Onetap','Aimware','Primordial'}
        local tc, bc, ac, sc, b0c, b1c, sf0c, sf1c, crc

        local themingTheme = themingSection:Dropdown('Theme', themes[1], themes, false, function(newValue)
            if not newValue then return end
            local theme = newValue[1]
            local presets = {
                Default    = {acc={0,128,255},  body={5,5,5},      text={255,255,255},sub={120,120,120},b1={40,40,40},  b0={32,32,32},  sf1={42,42,42}, sf0={24,24,24}, cr={0,0,0}},
                Gamesense  = {acc={114,178,21},  body={0,0,0},      text={144,144,144},sub={59,59,59},  b1={60,60,60},  b0={48,48,48},  sf1={45,45,45}, sf0={26,26,26}, cr={0,0,0}},
                Bitchbot   = {acc={120,85,147},  body={31,31,31},   text={202,201,201},sub={100,100,100},b1={53,52,52}, b0={53,52,52},  sf1={41,42,40}, sf0={41,42,40}, cr={0,0,0}},
                Neverlose  = {acc={77,166,255},  body={10,13,20},   text={220,228,240},sub={90,105,130},b1={35,45,65},  b0={25,32,50},  sf1={22,28,42}, sf0={15,19,30}, cr={5,7,12}},
                Onetap     = {acc={220,150,40},  body={12,12,12},   text={210,210,210},sub={95,95,95},  b1={45,40,30},  b0={35,30,22},  sf1={30,28,24}, sf0={20,19,16}, cr={0,0,0}},
                Aimware    = {acc={200,30,30},   body={18,18,18},   text={230,230,230},sub={100,100,100},b1={55,20,20}, b0={40,15,15},  sf1={35,30,30}, sf0={25,22,22}, cr={5,0,0}},
                Primordial = {acc={210,80,110},  body={14,14,16},   text={215,215,220},sub={90,88,95},  b1={42,38,45},  b0={30,28,33},  sf1={28,26,32}, sf0={20,18,24}, cr={5,4,7}},
            }
            local p = presets[theme]
            if not p then return end
            local function rgb(t) return Color3.fromRGB(t[1], t[2], t[3]) end
            if ac  then ac:Set(rgb(p.acc))  end
            if bc  then bc:Set(rgb(p.body)) end
            if tc  then tc:Set(rgb(p.text)) end
            if sc  then sc:Set(rgb(p.sub))  end
            if b0c then b0c:Set(rgb(p.b0))  end
            if b1c then b1c:Set(rgb(p.b1))  end
            if sf0c then sf0c:Set(rgb(p.sf0)) end
            if sf1c then sf1c:Set(rgb(p.sf1)) end
            if crc  then crc:Set(rgb(p.cr))  end
        end)

        local function colorToggle(label, key)
            local t = themingSection:Toggle(label)
            return t:AddColorpicker(label, self._theming[key], true, function(v)
                self._theming[key] = v
            end)
        end

        tc   = colorToggle('Text color',     'text')
        bc   = colorToggle('Body color',     'body')
        ac   = colorToggle('Accent color',   'accent')
        sc   = colorToggle('Subtext color',  'subtext')
        b0c  = colorToggle('Border 0 color', 'border0')
        b1c  = colorToggle('Border 1 color', 'border1')
        sf0c = colorToggle('Surface 0 color','surface0')
        sf1c = colorToggle('Surface 1 color','surface1')
        crc  = colorToggle('Crust color',    'crust')

        themingTheme:Set({'Default'})

        return settingsTab, menuSection, themingSection
    end

    function UILib:RegisterActivity(activity)
        local activityId = #self._activities + 1
        self._activities[activityId] = activity
        return {
            Remove = function(_) self._activities[activityId] = nil end
        }
    end

    function UILib:Unload()
        self:_RemoveDrawStartsWith('')
        setrobloxinput(true)
    end


    function UILib:Step()
        local menuTitle = self._custom_title_enabled and self._custom_title or self.title

        setrobloxinput(not self._menu_open)
        for keycode, inputData in pairs(self._inputs) do
            local interacted = iskeypressed(inputData.id)
            if isrbxactive() and interacted then
                if inputData.held == false and inputData.click == false then
                    self._inputs[keycode].click = true
                else
                    self._inputs[keycode].click = false
                end
                self._inputs[keycode].held = true
            else
                self._inputs[keycode].click = false
                self._inputs[keycode].held = false
            end
        end

        local clickFrame     = self:_IsKeyPressed('m1')
        local mouseHeld      = self:_IsKeyHeld('m1')
        local ctxFrame       = self:_IsKeyPressed('m2')
        local menuKeyPressed = self:_IsKeyPressed(self._overwrite_menu_key and self._menu_key or 'f1')

        if menuKeyPressed then
            self._menu_open = not self._menu_open
            self._menu_toggled_at = os.clock()
        end

        -- watermark
        local watermarkPos = Vector2.new(self._watermark_x, self._watermark_y)
        local watermarkStates = {menuTitle}
        for _, activity in ipairs(self._activities) do
            if type(activity) == 'function' then
                local s = tostring(activity())
                if s ~= 'nil' then table.insert(watermarkStates, s) end
            end
        end
        local watermarkContent = table.concat(watermarkStates, ' | ')
        local wmFontSize = 13
        local watermarkSize = self:_GetTextBounds(watermarkContent, nil, wmFontSize) + Vector2.new(self._padding * 2, self._padding * 2 + 2)

        if self._watermark_enabled then
            if mouseHeld and self._watermark_drag then
                local mp = self:_GetMousePos()
                self._watermark_x = mp.x - self._watermark_drag.x
                self._watermark_y = mp.y - self._watermark_drag.y
                watermarkPos = Vector2.new(self._watermark_x, self._watermark_y)
            else
                self._watermark_drag = nil
            end

            if self._rainbow_enabled then
                local wSegments = 20
                for wsi = 0, wSegments - 1 do
                    local wh = (self._rainbow_hue + wsi / wSegments) % 1
                    local wrc = Color3.fromHSV(wh, 1, 1)
                    local wSegW = (watermarkSize.x - 4) / wSegments
                    self:_Draw('watermark_rainbow_' .. wsi, 'rect', wrc, 104,
                        Vector2.new(watermarkPos.x + 2 + wsi * wSegW, watermarkPos.y + 2),
                        Vector2.new(math.ceil(wSegW) + 1, 2), true)
                end
                for wsi = 0, 19 do
                    local obj = self._drawings['watermark_accent']
                    if obj then obj.Visible = false end
                end
            else
                for wsi = 0, 19 do self:_Undraw('watermark_rainbow_' .. wsi) end
                self:_Draw('watermark_accent', 'line', self._theming.accent, 104,
                    watermarkPos + Vector2.new(2, 2),
                    watermarkPos + Vector2.new(watermarkSize.x - 2, 2))
            end

            self:_Draw('watermark_crust',  'rect', self._theming.crust,    102, watermarkPos, watermarkSize, false)
            self:_Draw('watermark_border', 'rect', self._theming.border0,  102, watermarkPos + Vector2.new(1,1), watermarkSize - Vector2.new(2,2), false)
            self:_Draw('watermark_body',   'gradient', nil, 101, 'vertical', watermarkPos + Vector2.new(2,2), watermarkSize - Vector2.new(4,4), self._theming.surface0)
            self:_Draw('watermark_text',   'text', self._theming.text, 103,
                watermarkPos + Vector2.new(self._padding, self._padding + 2), watermarkContent, true, nil, wmFontSize)

            if clickFrame and self:_IsMouseWithinBounds(watermarkPos, watermarkSize) then
                local mp = self:_GetMousePos()
                self._watermark_drag = Vector2.new(mp.x - self._watermark_x, mp.y - self._watermark_y)
                clickFrame = false
            end
        else
            self._watermark_drag = nil
            self:_UndrawStartsWith('watermark_')
        end

        -- notifications
        local notificationsOrigin = watermarkPos + (self._watermark_enabled and Vector2.new(0, watermarkSize.y + self._padding) or Vector2.new(0, 0))
        local totalNotificationsHeight = 0
        for notificationIter, notification in ipairs(self._notifications) do
            local shouldFade = os.clock() > notification._spawned_at + notification.time
            local notificationText = notification.text
            local notificationTextSize = self:_GetTextBounds(notificationText)
            local t = math.max(0, math.min(notification._spawned_at - os.clock() + (shouldFade and notification.time + 1 or 1), 1))
            local notificationFade = math.abs((shouldFade and 0 or 1) - (t * t * (3 - 2 * t)))
            local notificationDrawId = 'notification_' .. notification._id
            local notificationSize = Vector2.new(notificationTextSize.x + self._padding * 2, notificationTextSize.y + self._padding * 2)
            local notificationOrigin = notificationsOrigin + Vector2.new((-notificationSize.x - 50) * (1 - notificationFade), totalNotificationsHeight)
            local progressPercent = math.min((os.clock() - notification._spawned_at)/notification.time, 1)
            self:_Draw(notificationDrawId .. '_crust',    'rect', self._theming.crust,   102, notificationOrigin, notificationSize, false)
            self:_Draw(notificationDrawId .. '_border',   'rect', self._theming.border0, 102, notificationOrigin + Vector2.new(1,1), notificationSize - Vector2.new(2,2), false)
            self:_Draw(notificationDrawId .. '_progress', 'gradient', nil, 103, 'horizontal', notificationOrigin + Vector2.new(2, notificationSize.y - 4), Vector2.new(notificationSize.x * progressPercent - 6, 2), {R=0,G=0,B=0,A=0}, self._theming.accent)
            self:_Draw(notificationDrawId .. '_body',     'gradient', nil, 101, 'vertical', notificationOrigin + Vector2.new(2,2), notificationSize - Vector2.new(4,4), self._theming.surface0)
            self:_Draw(notificationDrawId .. '_text',     'text', self._theming.text, 103, notificationOrigin + Vector2.new(self._padding, self._padding + 2), notificationText, true)
            self:_SetOpacityStartsWith(notificationDrawId, notificationFade)
            totalNotificationsHeight = totalNotificationsHeight + (notificationTextSize.y + self._padding * 3) * notificationFade
            if os.clock() - 1 > notification._spawned_at + notification.time then
                self:_RemoveDrawStartsWith(notificationDrawId)
                table.remove(self._notifications, notificationIter)
            end
        end

        if self._menu_open then
            -- resize
            if mouseHeld and self._menu_resize then
                local mp = self:_GetMousePos()
                self.w = math.max(self._min_w, mp.x - self.x + self._menu_resize.x)
                self.h = math.max(self._min_h, mp.y - self.y + self._menu_resize.y)
            else
                self._menu_resize = nil
            end
            -- drag
            if mouseHeld and self._menu_drag then
                local mp = self:_GetMousePos()
                self.x = mp.x - self._menu_drag.x
                self.y = mp.y - self._menu_drag.y
            else
                self._menu_drag = nil
            end

            -- dropdown
            local dropdown = self._active_dropdown
            if dropdown then
                local dropdownFade = 1 - (dropdown._spawned_at - (os.clock() - 0.25)) / 0.25
                if dropdownFade < 1.1 then
                    self:_SetOpacityStartsWith('dropdown_', clamp(dropdownFade, 0, 1))
                end
                local shouldCancel = true
                local dropdownOrigin = dropdown.position
                local totalHeight = self._padding
                for i = 1, #dropdown.choices do
                    local choice = dropdown.choices[i]
                    local choiceFoundIndex = table.find(dropdown.value, choice)
                    local labelSize = self:_GetTextBounds(choice)
                    local choiceOrigin = Vector2.new(dropdownOrigin.x + self._padding, dropdownOrigin.y + totalHeight)
                    local choiceSize = Vector2.new(dropdown.width, labelSize.y)
                    local isHoveringChoice = self:_IsMouseWithinBounds(choiceOrigin, choiceSize)
                    if isHoveringChoice and clickFrame then
                        shouldCancel = not dropdown.multi
                        if dropdown.multi then
                            if choiceFoundIndex then table.remove(dropdown.value, choiceFoundIndex)
                            else table.insert(dropdown.value, choice) end
                        else
                            dropdown.value = {choice}
                        end
                        if dropdown.callback then dropdown.callback(dropdown.value) end
                    end
                    local choiceColor = choiceFoundIndex and self._theming.accent or self._theming.subtext
                    self:_Draw('dropdown_choice_' .. tostring(i), 'text', choiceColor, 102, choiceOrigin, choice, true)
                    totalHeight = totalHeight + labelSize.y + self._padding
                end
                self:_Draw('dropdown_crust', 'rect', self._theming.crust,    100, dropdownOrigin, Vector2.new(dropdown.width, totalHeight), false)
                self:_Draw('dropdown_body',  'rect', self._theming.surface0, 101, dropdownOrigin + Vector2.new(1,1), Vector2.new(dropdown.width - 2, totalHeight - 2), true)
                if clickFrame and shouldCancel then self:_RemoveDropdown() end
                clickFrame = false
            end

            -- colorpicker
            local colorpicker = self._active_colorpicker
            if colorpicker then
                local colorpickerFade = 1 - (colorpicker._spawned_at - (os.clock() - 0.25)) / 0.25
                if colorpickerFade < 1.1 then
                    self:_SetOpacityStartsWith('colorpicker_', clamp(colorpickerFade, 0, 1))
                end
                local shouldCancel = true
                local colorpickerSize = Vector2.new(200, 200)
                local colorpickerOrigin = colorpicker.position
                local colorpickerTitle = colorpicker.label
                local colorpickerTitleSize = self:_GetTextBounds(colorpickerTitle)

                self:_Draw('colorpicker_crust',              'rect', self._theming.crust,   100, colorpickerOrigin, colorpickerSize, false)
                self:_Draw('colorpicker_body',               'rect', self._theming.surface0,101, colorpickerOrigin + Vector2.new(1,1), colorpickerSize - Vector2.new(2,2), true)
                self:_Draw('colorpicker_body_border_outer',  'rect', self._theming.border1, 103, colorpickerOrigin + Vector2.new(1,1), colorpickerSize - Vector2.new(2,2), false)
                self:_Draw('colorpicker_title', 'text', self._theming.text, 104, colorpickerOrigin + Vector2.new(self._padding + 1, self._padding + 2), colorpickerTitle, true)

                local palleteContentPos  = colorpickerOrigin + Vector2.new(self._padding + 2, self._padding + colorpickerTitleSize.y + 6)
                local palleteContentSize = colorpickerSize - Vector2.new(self._padding * 2 + 4, self._padding * 3 + colorpickerTitleSize.y)

                self:_Draw('colorpicker_body_border_inner', 'rect', self._theming.border1, 103, palleteContentPos - Vector2.new(1,1), palleteContentSize + Vector2.new(2,2), false)
                self:_Draw('colorpicker_body_content',      'rect', self._theming.body,    105, palleteContentPos, palleteContentSize, true)

                local mousePos = self:_GetMousePos()
                local palleteSize = palleteContentSize - Vector2.new(self._padding * 2, self._padding * 2)
                local hueSize = Vector2.new(palleteSize.x, 10)
                palleteSize = palleteSize - Vector2.new(0, hueSize.y + self._padding)
                local palletePos = palleteContentPos + Vector2.new(self._padding, self._padding)
                local huePos = palletePos + Vector2.new(0, palleteSize.y + self._padding)

                if self:_IsMouseWithinBounds(huePos, hueSize) and mouseHeld then
                    colorpicker._h = clamp((mousePos.x - huePos.x) / hueSize.x, 0, 1)
                    shouldCancel = false
                end
                if self:_IsMouseWithinBounds(palletePos, palleteSize) and mouseHeld then
                    colorpicker._s = clamp((mousePos.x - palletePos.x) / palleteSize.x, 0, 1)
                    colorpicker._v = 1 - clamp((mousePos.y - palletePos.y) / palleteSize.y, 0, 1)
                    shouldCancel = false
                end

                local hueColor = Color3.fromHSV(colorpicker._h, 1, 1)
                self:_Draw('colorpicker_pallete_color', 'gradient', nil, 110, 'horizontal', palletePos, palleteSize, Color3.fromRGB(255,255,255), hueColor)
                self:_Draw('colorpicker_pallete_fade',  'gradient', nil, 111, 'vertical',   palletePos, palleteSize, {R=0,G=0,B=0,A=0}, {R=0,G=0,B=0,A=1})
                self:_Draw('colorpicker_pallete_hue',   'gradient', nil, 111, 'horizontal', huePos, hueSize,
                    Color3.fromRGB(255,0,0), Color3.fromRGB(255,255,0), Color3.fromRGB(0,255,0),
                    Color3.fromRGB(0,255,255), Color3.fromRGB(0,0,255), Color3.fromRGB(255,0,255), Color3.fromRGB(255,0,0))

                local newColor = Color3.fromHSV(colorpicker._h, colorpicker._s, colorpicker._v)
                if colorpicker.callback then colorpicker.callback(newColor) end
                if clickFrame and shouldCancel then self:_RemoveColorpicker() end
                clickFrame = false
            end

            -- menu shell + tabs + sections — (full rendering logic)
            local menuTitleSize = self:_GetTextBounds(menuTitle)

            self:_Draw('menu_crust',            'rect', self._theming.crust,   1, Vector2.new(self.x, self.y), Vector2.new(self.w, self.h), false)
            self:_Draw('menu_body',             'rect', self._theming.surface0,2, Vector2.new(self.x+1, self.y+1), Vector2.new(self.w-2, self.h-2), true)
            self:_Draw('menu_body_border_outer','rect', self._theming.border1, 3, Vector2.new(self.x+1, self.y+1), Vector2.new(self.w-2, self.h-2), false)

            local barH = 3
            local barX = self.x + 2
            local barW = self.w - 4
            local barY = self.y + 2
            local now  = os.clock()
            local rainbowSegments = 120

            if self._rainbow_enabled then
                if now - self._rainbow_last_t >= 0.033 then
                    self._rainbow_hue = (self._rainbow_hue + 0.008) % 1
                    self._rainbow_last_t = now
                end
                self:_UndrawStartsWith('menu_accent_gradient')
                local segW = barW / rainbowSegments
                for si = 0, rainbowSegments - 1 do
                    local h = (self._rainbow_hue + si / rainbowSegments) % 1
                    self:_Draw('menu_rainbow_' .. si, 'rect', Color3.fromHSV(h,1,1), 42,
                        Vector2.new(barX + si * segW, barY), Vector2.new(math.ceil(segW)+1, barH), true)
                end
            else
                self:_UndrawStartsWith('menu_rainbow_')
                self:_Draw('menu_accent_gradient', 'gradient', nil, 42, 'horizontal',
                    Vector2.new(barX, barY), Vector2.new(barW, barH),
                    self._theming.surface0, self._theming.accent, self._theming.surface0)
            end

            local titleFontSize = 16
            local titleSize = self:_GetTextBounds(menuTitle, nil, titleFontSize)
            local headerH = barH + titleSize.y + self._padding * 2
            self:_Draw('menu_title', 'text', self._theming.text, 42,
                Vector2.new(self.x + self.w/2, self.y + barH + self._padding + titleSize.y/2),
                menuTitle, true, 'center', titleFontSize)

            local bodyContentPos  = Vector2.new(self.x + self._padding + 2, self.y + headerH + 4)
            local bodyContentSize = Vector2.new(self.w - self._padding * 2 - 4, self.h - headerH - 6)

            self:_Draw('menu_body_border_inner', 'rect', self._theming.border1, 11, bodyContentPos - Vector2.new(1,1), bodyContentSize + Vector2.new(2,2), false)
            self:_Draw('menu_body_content',      'rect', self._theming.body,    10, bodyContentPos, bodyContentSize, true)

            local menuX, menuY, menuW, menuH = self.x, self.y, self.w, self.h
            local maskBotY = bodyContentPos.y + bodyContentSize.y

            self:_Draw('menu_mask_top',    'rect', self._theming.surface0, 30, Vector2.new(menuX+1, menuY+1), Vector2.new(menuW-2, headerH+4), true)
            self:_Draw('menu_mask_bot',    'rect', self._theming.surface0, 30, Vector2.new(menuX+1, maskBotY), Vector2.new(menuW-2, menuY+menuH-maskBotY-1), true)
            self:_Draw('menu_mask_left',   'rect', Color3.fromRGB(14,14,14), 30, Vector2.new(bodyContentPos.x, bodyContentPos.y), Vector2.new(112, bodyContentSize.y), true)
            self:_Draw('menu_mask_right',  'rect', self._theming.surface0, 30, Vector2.new(menuX+menuW-self._padding-2, menuY+1), Vector2.new(self._padding+2, menuH-2), true)
            self:_Draw('menu_mask_border', 'rect', self._theming.border1, 36, Vector2.new(menuX+1, menuY+1), Vector2.new(menuW-2, menuH-2), false)
            self:_Draw('menu_mask_crust',  'rect', self._theming.crust,   36, Vector2.new(menuX, menuY), Vector2.new(menuW, menuH), false)

            local tabIter = 0
            local tabSidebarW = 110
            local sidebarColor = self._theming.body
            self:_Draw('menu_tab_sidebar',        'rect', sidebarColor,          37, bodyContentPos, Vector2.new(tabSidebarW, bodyContentSize.y), true)
            self:_Draw('menu_tab_sidebar_border', 'rect', self._theming.border1, 38, bodyContentPos + Vector2.new(tabSidebarW,0), Vector2.new(1, bodyContentSize.y), true)

            local tabNames = {}
            for k in pairs(self._tree) do table.insert(tabNames, k) end
            local _tabOrder = {Utils=1, Autofarm=2, ESP=3, Funnies=4, Credits=5, Settings=6}
            table.sort(tabNames, function(a, b)
                return (_tabOrder[a] or 99) < (_tabOrder[b] or 99)
            end)

            for _, tabName in ipairs(tabNames) do
                local tabContent = self._tree[tabName]
                local tabDrawId  = 'menu_tab_' .. tabName
                local tabH       = 28
                local tabSize    = Vector2.new(tabSidebarW, tabH)
                local tabPosition = Vector2.new(bodyContentPos.x, bodyContentPos.y + tabH * tabIter)
                local isOpen     = self._open_tab == tabName

                if isOpen then
                    self:_Draw(tabDrawId .. '_backdrop', 'rect', self._theming.body,   38, tabPosition, tabSize, true)
                    self:_Draw(tabDrawId .. '_accent',   'rect', self._theming.accent, 39, tabPosition + Vector2.new(tabSidebarW-2, 0), Vector2.new(2, tabH), true)
                else
                    self:_Draw(tabDrawId .. '_backdrop', 'rect', sidebarColor, 38, tabPosition, tabSize, true)
                    self:_Undraw(tabDrawId .. '_accent')
                end

                self:_Draw(tabDrawId .. '_border_b', 'rect', self._theming.border1, 39, tabPosition + Vector2.new(0, tabH-1), Vector2.new(tabSidebarW, 1), true)
                self:_Draw(tabDrawId .. '_text', 'text', isOpen and self._theming.text or self._theming.subtext, 40,
                    tabPosition + Vector2.new(self._padding, tabH/2 - self._font_size/2 + 1), tabName, true)

                if not isOpen and clickFrame and self:_IsMouseWithinBounds(tabPosition, tabSize) then
                    self._open_tab = tabName
                    self._tab_change_at = os.clock()
                    self._input_ctx = nil
                    self._tab_scroll[tabName] = 0
                end

                tabIter = tabIter + 1

                local contentX = bodyContentPos.x + tabSidebarW + self._padding + 2
                local contentW = bodyContentSize.x - tabSidebarW - self._padding * 2 - 2

                local sectionFade = 1 - (self._tab_change_at - (os.clock() - 0.25)) / 0.25
                if sectionFade < 1.1 then
                    self:_SetOpacityStartsWith('menu_section_', clamp(sectionFade, 0, 1))
                end

                if not self._tab_scroll[tabName] then self._tab_scroll[tabName] = 0 end
                local scrollY = self._tab_scroll[tabName]

                local contentAreaPos  = Vector2.new(contentX, bodyContentPos.y)
                local contentAreaSize = Vector2.new(contentW, bodyContentSize.y)
                if self:_IsMouseWithinBounds(contentAreaPos, contentAreaSize) then
                    if self:_IsKeyPressed('up')   or self:_IsKeyPressed('pageup')   then scrollY = scrollY - self._scroll_step * 3 end
                    if self:_IsKeyPressed('down') or self:_IsKeyPressed('pagedown') then scrollY = scrollY + self._scroll_step * 3 end
                end
                if scrollY < 0 then scrollY = 0 end
                self._tab_scroll[tabName] = scrollY

                local clipTop    = bodyContentPos.y
                local clipBottom = bodyContentPos.y + bodyContentSize.y

                local sectionIter = 0
                local sectionCount = 0
                for _ in pairs(tabContent._items) do sectionCount = sectionCount + 1 end
                local sectionWidth = sectionCount == 1 and (contentW - self._padding * 2) or (contentW/2 - self._padding * 1.5)
                local totalSectionHeightR = self._padding * 1.5
                local totalSectionHeightL = self._padding * 1.5

                for sectionName, sectionContent in pairs(tabContent._items) do
                    local sectionDrawId = 'menu_section_' .. tabName:gsub('%W','_') .. '_' .. sectionName:gsub('%W','_')
                    local isSectionMirror = sectionCount > 1 and sectionIter % 2 == 1
                    local sectionTitleSize = self:_GetTextBounds(sectionName)
                    local sectionPos = Vector2.new(contentX, bodyContentPos.y + self._padding)
                    local sectionHeight = self._padding + sectionTitleSize.y/2

                    if isSectionMirror then
                        sectionPos = sectionPos + Vector2.new(sectionWidth + self._padding, totalSectionHeightR + sectionTitleSize.y/2)
                    else
                        sectionPos = sectionPos + Vector2.new(0, totalSectionHeightL + sectionTitleSize.y/2)
                    end
                    sectionPos = sectionPos - Vector2.new(0, scrollY)

                    if isOpen then
                        local titleY = sectionPos.y - sectionTitleSize.y/2 - 1
                        if titleY >= clipTop and titleY <= clipBottom then
                            self:_Draw(sectionDrawId .. '_title', 'text', self._theming.subtext, 32,
                                sectionPos + Vector2.new(self._padding, -sectionTitleSize.y/2 - 1), sectionName, true)
                        else
                            self:_Undraw(sectionDrawId .. '_title')
                        end

                        for sectionItemIter, sectionItem in ipairs(sectionContent._items) do
                            local sectionItemId    = sectionDrawId .. '_item_' .. tostring(sectionItemIter)
                            local sectionItemOrigin = Vector2.new(sectionPos.x + self._padding, sectionPos.y + sectionHeight)
                            local itemY = sectionItemOrigin.y
                            local itemClipped = (itemY + self._font_size * 2) < clipTop or (itemY + self._font_size) > clipBottom

                            if itemClipped then
                                self:_UndrawStartsWith(sectionItemId)
                                local t_ = sectionItem.type_
                                if     t_ == 'toggle'   then sectionHeight = sectionHeight + self._font_size + self._padding
                                elseif t_ == 'slider'   then local ls_= self:_GetTextBounds(sectionItem.label or ''); sectionHeight = sectionHeight + ls_.y + 8 + self._padding * 3
                                elseif t_ == 'dropdown' then local ls_= self:_GetTextBounds(sectionItem.label or ''); sectionHeight = sectionHeight + ls_.y + self._font_size + self._padding * 5
                                elseif t_ == 'button'   then sectionHeight = sectionHeight + self._font_size + self._padding * 4
                                elseif t_ == 'textbox'  then sectionHeight = sectionHeight + self._font_size + self._padding * 2
                                end
                            else
                                local itemType     = sectionItem.type_
                                local itemValue    = sectionItem.value
                                local itemCallback = sectionItem.callback

                                if itemType == 'toggle' then
                                    local tickOrigin = sectionItemOrigin
                                    local tickSize   = Vector2.new(self._font_size, self._font_size)
                                    local itemKeybind      = sectionItem.keybind
                                    local itemColorpicker  = sectionItem.colorpicker

                                    if itemKeybind then
                                        local keybindText = '[' .. (itemKeybind._listening and '...' or ((itemKeybind.value or '-'):upper())) .. ']'
                                        local keybindLabelSize = self:_GetTextBounds(keybindText, nil, 10)
                                        local keybindSize   = Vector2.new(keybindLabelSize.x - 2, tickSize.y)
                                        local keybindOrigin = sectionItemOrigin + Vector2.new(sectionWidth - keybindSize.x - self._padding * 2, 2)
                                        local isHoveringKeybind = self:_IsMouseWithinBounds(keybindOrigin, keybindSize)
                                        if isHoveringKeybind then
                                            if clickFrame then
                                                itemKeybind._listening = true
                                                itemKeybind._listening_start = os.clock()
                                                clickFrame = false
                                            elseif ctxFrame and itemKeybind.canChange then
                                                self:_SpawnDropdown(self:_GetMousePos(), 60, {itemKeybind.mode}, {'Hold','Toggle','Always'}, false, function(v)
                                                    itemKeybind.mode = v[1]
                                                    if itemKeybind.callback then itemKeybind.callback(self._inputs[itemKeybind.value] and self._inputs[itemKeybind.value].id or nil, v[1]) end
                                                end)
                                                ctxFrame = false
                                            end
                                        end
                                        if itemKeybind._listening then
                                            for keyName, key in pairs(self._inputs) do
                                                if self:_IsKeyPressed(keyName) then
                                                    if keyName ~= 'm1' or os.clock() - itemKeybind._listening_start > 0.2 then
                                                        local newValue = keyName ~= 'unbound' and keyName
                                                        if itemKeybind.callback and self._inputs[newValue] then
                                                            itemKeybind.callback(key.id, itemKeybind.mode)
                                                        end
                                                        itemKeybind.value = newValue
                                                        itemKeybind._listening = false
                                                    end
                                                end
                                            end
                                        end
                                        local keybindColor = itemKeybind.value and self._theming.text or self._theming.subtext
                                        self:_Draw(sectionItemId .. '_keybind', 'text', keybindColor, 20, keybindOrigin, keybindText, true, 'left', 10)
                                    elseif itemColorpicker then
                                        local colorpickerSize   = Vector2.new(tickSize.x * 2, tickSize.y)
                                        local colorpickerOrigin = sectionItemOrigin + Vector2.new(sectionWidth - self._padding * 2 - colorpickerSize.x)
                                        local isHoveringColorpicker = self:_IsMouseWithinBounds(colorpickerOrigin, colorpickerSize)
                                        if isHoveringColorpicker then
                                            if clickFrame then
                                                self:_SpawnColorpicker(nil, itemColorpicker.label, itemColorpicker.value, function(v)
                                                    itemColorpicker.value = v
                                                    if itemColorpicker.callback then itemColorpicker.callback(v) end
                                                end)
                                                clickFrame = false
                                            elseif ctxFrame then
                                                self:_SpawnDropdown(self:_GetMousePos(), 60, {}, {'Copy','Paste'}, false, function(v)
                                                    if v[1] == 'Copy' then
                                                        self._copied_color = itemColorpicker.value
                                                    elseif v[1] == 'Paste' then
                                                        if self._copied_color then
                                                            itemColorpicker.value = self._copied_color
                                                            if itemColorpicker.callback then itemColorpicker.callback(self._copied_color) end
                                                        else
                                                            self:Notification('Color clipboard is empty!', 5)
                                                        end
                                                    end
                                                end)
                                                ctxFrame = false
                                            end
                                        end
                                        local tickColor = itemColorpicker.value
                                        self:_Draw(sectionItemId .. '_colorpicker',        'gradient', nil, 20, 'vertical', colorpickerOrigin + Vector2.new(1,1), colorpickerSize - Vector2.new(2,2), tickColor)
                                        self:_Draw(sectionItemId .. '_colorpicker_border', 'rect', self._theming.crust, 21, colorpickerOrigin, colorpickerSize, false)
                                    end

                                    local labelColor = sectionItem.unsafe and self._theming.unsafe or (itemValue and self._theming.text or self._theming.subtext)
                                    if not itemColorpicker or not itemColorpicker.overwrite then
                                        local isHoveringTick = self:_IsMouseWithinBounds(tickOrigin, tickSize)
                                        if isHoveringTick and clickFrame then
                                            local newValue = not itemValue
                                            sectionItem.value = newValue
                                            if itemCallback then itemCallback(newValue) end
                                            clickFrame = false
                                        end

                                        local tcx, tcy = sectionItemOrigin.x + tickSize.x/2, sectionItemOrigin.y + tickSize.y/2
                                        local tr  = tickSize.x/2 - 1
                                        local trO = tr - 1
                                        local tickFill   = itemValue and self._theming.accent or self._theming.body
                                        local tickBorder = itemValue and self._theming.accent or self._theming.subtext
                                        self:_Draw(sectionItemId .. '_tickO1', 'triangle', tickBorder, 19, true, Vector2.new(tcx, tcy-tr),  Vector2.new(tcx+tr, tcy), Vector2.new(tcx,    tcy+tr))
                                        self:_Draw(sectionItemId .. '_tickO2', 'triangle', tickBorder, 19, true, Vector2.new(tcx, tcy-tr),  Vector2.new(tcx-tr, tcy), Vector2.new(tcx,    tcy+tr))
                                        self:_Draw(sectionItemId .. '_tick',   'triangle', tickFill,   20, true, Vector2.new(tcx, tcy-trO), Vector2.new(tcx+trO,tcy), Vector2.new(tcx,    tcy+trO))
                                        self:_Draw(sectionItemId .. '_tick2',  'triangle', tickFill,   20, true, Vector2.new(tcx, tcy-trO), Vector2.new(tcx-trO,tcy), Vector2.new(tcx,    tcy+trO))
                                        self:_Undraw(sectionItemId .. '_border')
                                    else
                                        labelColor = self._theming.text
                                    end

                                    local labelSize = self:_GetTextBounds(sectionItem.label)
                                    local labelPosition = sectionItemOrigin + Vector2.new(tickSize.x + self._padding, 0)

                                    local maxLabelW = sectionWidth - tickSize.x - self._padding * 3
                                    if itemKeybind then maxLabelW = maxLabelW - 40
                                    elseif itemColorpicker and not itemColorpicker.overwrite then maxLabelW = maxLabelW - tickSize.x * 2 - self._padding end

                                    local clampedLabel = sectionItem.label
                                    while #clampedLabel > 1 and self:_GetTextBounds(clampedLabel).x > maxLabelW do
                                        clampedLabel = clampedLabel:sub(1, -2)
                                    end
                                    if clampedLabel ~= sectionItem.label then clampedLabel = clampedLabel:sub(1,-2) .. '..' end
                                    self:_Draw(sectionItemId .. '_label', 'text', labelColor, 20, Vector2.new(labelPosition.x, labelPosition.y + 1), clampedLabel, true)
                                    sectionHeight = sectionHeight + self._font_size + self._padding

                                elseif itemType == 'slider' then
                                    local labelSize    = self:_GetTextBounds(sectionItem.label)
                                    local extraPadding = self._font_size
                                    local sliderOrigin = Vector2.new(sectionItemOrigin.x + extraPadding + self._padding, sectionItemOrigin.y + labelSize.y + self._padding)
                                    local sliderSize   = Vector2.new(sectionWidth - extraPadding * 2 - self._padding * 3, 6)
                                    local newValue     = itemValue
                                    local isHoveringSlider = self:_IsMouseWithinBounds(sliderOrigin - Vector2.new(4,4), sliderSize + Vector2.new(8,8))

                                    if mouseHeld then
                                        if isHoveringSlider and clickFrame then
                                            self._slider_drag = sectionItemId; clickFrame = false
                                        end
                                        if self._slider_drag == sectionItemId then
                                            local mouseX = self:_GetMousePos().x - sliderOrigin.x
                                            local percent = clamp(mouseX / sliderSize.x, 0, 1)
                                            newValue = sectionItem.min + (sectionItem.max - sectionItem.min) * percent
                                            newValue = math.floor((newValue / sectionItem.step) + 0.5) * sectionItem.step
                                            newValue = clamp(newValue, sectionItem.min, sectionItem.max)
                                        end
                                    else
                                        self._slider_drag = nil
                                    end

                                    local buttonSize    = Vector2.new(self._font_size, self._font_size)
                                    local decreaseOrigin = sliderOrigin - Vector2.new(extraPadding + self._padding, labelSize.y - self._padding - 1)
                                    local increaseOrigin = sliderOrigin + Vector2.new(sliderSize.x + self._padding - 4, -labelSize.y + self._padding + 1)
                                    self:_Draw(sectionItemId .. '_decrease', 'text', self._theming.text, 20, decreaseOrigin + Vector2.new(buttonSize.x/2, buttonSize.y/2), '-', true, 'center')
                                    self:_Draw(sectionItemId .. '_increase', 'text', self._theming.text, 20, increaseOrigin + Vector2.new(buttonSize.x/2, buttonSize.y/2), '+', true, 'center')
                                    if clickFrame then
                                        if self:_IsMouseWithinBounds(decreaseOrigin, buttonSize) then
                                            newValue = clamp(itemValue - sectionItem.step, sectionItem.min, sectionItem.max); clickFrame = false
                                        elseif self:_IsMouseWithinBounds(increaseOrigin, buttonSize) then
                                            newValue = clamp(itemValue + sectionItem.step, sectionItem.min, sectionItem.max); clickFrame = false
                                        end
                                    end

                                    if newValue ~= itemValue then
                                        sectionItem.value = newValue
                                        if itemCallback then itemCallback(newValue) end
                                    end

                                    local fillPercent = (itemValue - (sectionItem.min or 0)) / ((sectionItem.max or 1) - (sectionItem.min or 0))
                                    self:_Draw(sectionItemId .. '_slider', 'gradient', nil, 20, 'vertical', sliderOrigin + Vector2.new(1,1), Vector2.new(sliderSize.x * fillPercent - 2, sliderSize.y - 2), self._theming.accent)
                                    self:_Draw(sectionItemId .. '_value', 'text', self._theming.text, 22, sliderOrigin + Vector2.new(sliderSize.x * fillPercent, sliderSize.y), tostring(itemValue) .. sectionItem.suffix, true, 'center', 12)
                                    self:_Draw(sectionItemId .. '_border', 'rect', self._theming.crust, 21, sliderOrigin, sliderSize, false)

                                    local sliderLabel = sectionItem.label
                                    while #sliderLabel > 1 and self:_GetTextBounds(sliderLabel).x > sliderSize.x do
                                        sliderLabel = sliderLabel:sub(1,-2)
                                    end
                                    if sliderLabel ~= sectionItem.label then sliderLabel = sliderLabel:sub(1,-2) .. '..' end
                                    self:_Draw(sectionItemId .. '_label', 'text', self._theming.text, 20, sectionItemOrigin + Vector2.new(self._padding + extraPadding, 0), sliderLabel, true)
                                    sectionHeight = sectionHeight + labelSize.y + sliderSize.y + self._padding * 3

                                elseif itemType == 'dropdown' then
                                    local labelSize    = self:_GetTextBounds(sectionItem.label)
                                    local extraPadding = self._font_size
                                    local dropdownOrigin = Vector2.new(sectionItemOrigin.x + extraPadding + self._padding, sectionItemOrigin.y + labelSize.y + self._padding)
                                    local dropdownSize   = Vector2.new(sectionWidth - extraPadding * 2 - self._padding * 3, labelSize.y + self._padding)
                                    local isHoveringDropdown = self:_IsMouseWithinBounds(dropdownOrigin, dropdownSize)

                                    if clickFrame and isHoveringDropdown then
                                        self:_SpawnDropdown(dropdownOrigin + Vector2.new(0, dropdownSize.y - 1), dropdownSize.x, itemValue, sectionItem.choices, sectionItem.multi, function(v)
                                            sectionItem.value = v
                                            if itemCallback then itemCallback(v) end
                                        end)
                                        clickFrame = false
                                    end

                                    self:_Draw(sectionItemId .. '_list',  'gradient', nil, 20, 'vertical', dropdownOrigin, dropdownSize, self._theming.surface0)
                                    self:_Draw(sectionItemId .. '_arrow', 'triangle', self._theming.text, 21, true,
                                        dropdownOrigin + Vector2.new(dropdownSize.x - self._padding - 6, dropdownSize.y/2),
                                        dropdownOrigin + Vector2.new(dropdownSize.x - self._padding,     dropdownSize.y/2 + 4),
                                        dropdownOrigin + Vector2.new(dropdownSize.x - self._padding,     dropdownSize.y/2 - 4))

                                    local displayedValue = table.concat(itemValue, ', ')
                                    local valueSize = self:_GetTextBounds(displayedValue)
                                    if valueSize.x > dropdownSize.x - self._padding - 10 then
                                        displayedValue = tostring(#itemValue) .. ' item' .. (#itemValue == 1 and '' or 's')
                                    end
                                    self:_Draw(sectionItemId .. '_value',  'text', self._theming.text,  21, dropdownOrigin + Vector2.new(4, valueSize.y/2 - 2), displayedValue, true)
                                    self:_Draw(sectionItemId .. '_border', 'rect', self._theming.crust, 21, dropdownOrigin, dropdownSize, false)

                                    local ddLabel = sectionItem.label
                                    while #ddLabel > 1 and self:_GetTextBounds(ddLabel).x > dropdownSize.x do
                                        ddLabel = ddLabel:sub(1,-2)
                                    end
                                    if ddLabel ~= sectionItem.label then ddLabel = ddLabel:sub(1,-2) .. '..' end
                                    self:_Draw(sectionItemId .. '_label', 'text', self._theming.text, 20, sectionItemOrigin + Vector2.new(self._padding + extraPadding, 0), ddLabel, true)
                                    sectionHeight = sectionHeight + labelSize.y + dropdownSize.y + self._padding * 3

                                elseif itemType == 'button' then
                                    local labelSize    = self:_GetTextBounds(sectionItem.label)
                                    local extraPadding = self._font_size
                                    local buttonOrigin = Vector2.new(sectionItemOrigin.x + extraPadding + self._padding, sectionItemOrigin.y)
                                    local buttonSize   = Vector2.new(sectionWidth - extraPadding * 2 - self._padding * 3, labelSize.y + self._padding)
                                    local isHoveringButton = self:_IsMouseWithinBounds(buttonOrigin, buttonSize)

                                    if mouseHeld then
                                        if isHoveringButton and clickFrame then
                                            self._slider_drag = sectionItemId
                                            clickFrame = false
                                            if itemCallback then itemCallback() end
                                        end
                                    else
                                        self._slider_drag = nil
                                    end

                                    local isClicked   = mouseHeld and self._slider_drag == sectionItemId
                                    local buttonColor = isClicked and self._theming.crust or self._theming.surface1
                                    local tintColor   = isClicked and self._theming.surface1 or self._theming.crust
                                    self:_Draw(sectionItemId .. '_body', 'gradient', nil, 20, 'vertical', buttonOrigin, buttonSize, buttonColor, Color3.new(
                                        self:_Lerp(buttonColor.R, tintColor.R, 0.5),
                                        self:_Lerp(buttonColor.G, tintColor.G, 0.5),
                                        self:_Lerp(buttonColor.B, tintColor.B, 0.5)
                                    ))
                                    self:_Draw(sectionItemId .. '_border', 'rect', self._theming.crust, 21, buttonOrigin, buttonSize, false)

                                    local btnLabel = sectionItem.label
                                    while #btnLabel > 1 and self:_GetTextBounds(btnLabel).x > buttonSize.x - self._padding * 2 do
                                        btnLabel = btnLabel:sub(1,-2)
                                    end
                                    if btnLabel ~= sectionItem.label then btnLabel = btnLabel:sub(1,-2) .. '..' end
                                    self:_Draw(sectionItemId .. '_text', 'text', self._theming.text, 21, buttonOrigin + Vector2.new(buttonSize.x/2, buttonSize.y/2), btnLabel, true, 'center')
                                    sectionHeight = sectionHeight + buttonSize.y + self._padding * 2

                                elseif itemType == 'textbox' then
                                    local textboxOrigin = Vector2.new(sectionItemOrigin.x, sectionItemOrigin.y)
                                    local textboxSize   = Vector2.new(sectionWidth - self._padding * 2, self._font_size + self._padding)
                                    local isHoveringTextbox = self:_IsMouseWithinBounds(textboxOrigin, textboxSize)
                                    local isTyping = self._input_ctx == sectionItemId

                                    local cursor = math.floor(os.clock() * 2) % 2 == 0 and '|' or ' '
                                    local displayedValue = isTyping and ((itemValue or '') .. cursor) or ((itemValue ~= '' and itemValue or sectionItem.label) .. ' ')
                                    local valueColor = isTyping and self._theming.text or ((itemValue and itemValue ~= '') and self._theming.text or self._theming.subtext)

                                    if self:_GetTextBounds(displayedValue).x > textboxSize.x then
                                        for i = 1, #displayedValue do
                                            local sub = displayedValue:sub(i)
                                            if self:_GetTextBounds(sub).x <= textboxSize.x - 4 then
                                                displayedValue = sub; break
                                            end
                                        end
                                    end

                                    local valueSize = self:_GetTextBounds(displayedValue)
                                    if self:_IsKeyPressed('m1') then
                                        if isHoveringTextbox then
                                            self._input_ctx = sectionItemId; clickFrame = false
                                        elseif isTyping then
                                            self._input_ctx = nil; self:_RemoveDropdown(); isTyping = false; clickFrame = false
                                        end
                                    elseif ctxFrame then
                                        if isHoveringTextbox then
                                            self:_SpawnDropdown(self:_GetMousePos(), 60, {}, {'Copy','Clear'}, false, function(v)
                                                if v[1] == 'Copy' then
                                                    setclipboard(tostring(itemValue))
                                                    self:Notification('Text copied to clipboard', 5)
                                                elseif v[1] == 'Clear' then
                                                    sectionItem.value = ''
                                                    if sectionItem.callback then sectionItem.callback('') end
                                                end
                                            end)
                                            ctxFrame = false
                                        end
                                    end

                                    if isTyping then
                                        local charMap  = {space=' ',dash='-',colon=':',period='.',comma=',',slash='/',semicolon=';',quote="'",leftbracket='[',rightbracket=']',backslash='\\',equals='=',minus='-'}
                                        local shiftMap = {['1']='!',['2']='@',['3']='#',['4']='$',['5']='%',['6']='^',['7']='&',['8']='*',['9']='(',['0']=')',['-']='_',['=']='+',['[']='{', [']']='}', [';']=':', ["'"]='"', [',']='<', ['.']='>',['/']=  '?',['\\']='|'}
                                        local newValue = itemValue or ''
                                        local ctrlCtx  = self:_IsKeyHeld('lctrl') or self:_IsKeyHeld('rctrl')
                                        local shiftCtx = self:_IsKeyHeld('lshift') or self:_IsKeyHeld('rshift')

                                        if ctrlCtx and self:_IsKeyPressed('v') then
                                            local ok, clip = pcall(getclipboard)
                                            if ok and type(clip) == 'string' then
                                                newValue = newValue .. clip
                                                if sectionItem.callback then sectionItem.callback(newValue) end
                                                sectionItem.value = newValue
                                            end
                                        elseif ctrlCtx and self:_IsKeyPressed('a') then
                                            newValue = ''
                                            if sectionItem.callback then sectionItem.callback(newValue) end
                                            sectionItem.value = newValue
                                        elseif not ctrlCtx then
                                            for char, _ in pairs(self._inputs) do
                                                if self:_IsKeyPressed(char) then
                                                    local mapped = charMap[char] or char
                                                    if mapped == 'enter' then
                                                        self._input_ctx = nil; break
                                                    elseif mapped == 'unbound' then
                                                        newValue = newValue:sub(1, -2)
                                                    elseif mapped and #mapped == 1 then
                                                        if shiftCtx and shiftMap[mapped] then mapped = shiftMap[mapped]
                                                        elseif shiftCtx then mapped = mapped:upper() end
                                                        newValue = newValue .. mapped
                                                    end
                                                    if sectionItem.callback then sectionItem.callback(newValue) end
                                                    sectionItem.value = newValue
                                                end
                                            end
                                        end
                                    end

                                    self:_Draw(sectionItemId .. '_input', 'text', valueColor, 22, textboxOrigin + Vector2.new(4, valueSize.y/2 - 2), displayedValue, true)
                                    self:_Draw(sectionItemId .. '_body',  'rect', self._theming.crust, 21, textboxOrigin, textboxSize, true)
                                    sectionHeight = sectionHeight + textboxSize.y + self._padding
                                end
                            end -- end not itemClipped
                        end -- end item loop

                        if isSectionMirror then
                            totalSectionHeightR = totalSectionHeightR + sectionHeight + sectionTitleSize.y/2
                        else
                            totalSectionHeightL = totalSectionHeightL + sectionHeight + sectionTitleSize.y/2
                        end

                        local clippedSecPos = Vector2.new(sectionPos.x, math.max(sectionPos.y, clipTop))
                        local clippedSecBot = math.min(sectionPos.y + sectionHeight, clipBottom)
                        local clippedSecH   = math.max(0, clippedSecBot - clippedSecPos.y)
                        if clippedSecH > 0 then
                            self:_Draw(sectionDrawId .. '_backdrop', 'rect', self._theming.surface0, 11, clippedSecPos, Vector2.new(sectionWidth, clippedSecH), true)
                            self:_Draw(sectionDrawId .. '_border',   'rect', self._theming.border0,  12, clippedSecPos, Vector2.new(sectionWidth, clippedSecH), false)
                        else
                            self:_Undraw(sectionDrawId .. '_backdrop')
                            self:_Undraw(sectionDrawId .. '_border')
                        end

                        if isSectionMirror then totalSectionHeightR = totalSectionHeightR + self._padding
                        else totalSectionHeightL = totalSectionHeightL + self._padding end
                    else
                        self:_UndrawStartsWith(sectionDrawId)
                    end

                    sectionIter = sectionIter + 1
                end

                -- scrollbar
                if isOpen then
                    local totalH = math.max(totalSectionHeightL, totalSectionHeightR) + self._padding * 3
                    local visibleRatio = bodyContentSize.y / math.max(totalH, 1)
                    if totalH > bodyContentSize.y then
                        local maxScroll = math.max(0, totalH - bodyContentSize.y)
                        if scrollY > maxScroll then scrollY = maxScroll; self._tab_scroll[tabName] = scrollY end

                        local sbX       = contentX + contentW + 2
                        local barTrackH = bodyContentSize.y - 4
                        local barH2     = math.max(24, math.floor(barTrackH * visibleRatio))
                        local barT      = maxScroll > 0 and (scrollY / maxScroll) or 0
                        local barY2     = bodyContentPos.y + 2 + math.floor((barTrackH - barH2) * barT)
                        local thumbPos  = Vector2.new(sbX, barY2)
                        local thumbSize = Vector2.new(6, barH2)
                        local mp        = self:_GetMousePos()

                        if mouseHeld then
                            if self._scroll_drag and self._scroll_drag[1] == tabName then
                                local dy       = mp.y - self._scroll_drag[2]
                                local ratio    = dy / math.max(1, barTrackH - barH2)
                                local newScroll = self._scroll_drag[3] + ratio * maxScroll
                                scrollY = math.max(0, math.min(maxScroll, newScroll))
                                self._tab_scroll[tabName] = scrollY
                            elseif clickFrame and self:_IsMouseWithinBounds(thumbPos, thumbSize) then
                                self._scroll_drag = {tabName, mp.y, scrollY}; clickFrame = false
                            elseif clickFrame and self:_IsMouseWithinBounds(Vector2.new(sbX, bodyContentPos.y+2), Vector2.new(6, barTrackH)) then
                                local relY  = mp.y - (bodyContentPos.y + 2)
                                local ratio = (relY - barH2/2) / math.max(1, barTrackH - barH2)
                                scrollY = math.max(0, math.min(maxScroll, ratio * maxScroll))
                                self._tab_scroll[tabName] = scrollY; clickFrame = false
                            end
                        else
                            if self._scroll_drag and self._scroll_drag[1] == tabName then self._scroll_drag = nil end
                        end

                        barT  = maxScroll > 0 and (scrollY / maxScroll) or 0
                        barY2 = bodyContentPos.y + 2 + math.floor((barTrackH - barH2) * barT)
                        local thumbHovered = self:_IsMouseWithinBounds(Vector2.new(sbX, barY2), thumbSize)
                        local thumbColor   = (thumbHovered or (self._scroll_drag and self._scroll_drag[1] == tabName)) and self._theming.text or self._theming.border1
                        self:_Draw('menu_scroll_track', 'rect', self._theming.surface0, 31, Vector2.new(sbX, bodyContentPos.y+2), Vector2.new(6, barTrackH), true)
                        self:_Draw('menu_scroll_thumb', 'rect', thumbColor,             32, Vector2.new(sbX, barY2), Vector2.new(6, barH2), true)
                    else
                        self:_Undraw('menu_scroll_track')
                        self:_Undraw('menu_scroll_thumb')
                        self._scroll_drag = nil
                    end
                end
            end

            -- resize grip
            local mousePos = self:_GetMousePos()
            local gripSize   = 14
            local gripOrigin = Vector2.new(self.x + self.w - gripSize, self.y + self.h - gripSize)
            local gripColor  = self:_IsMouseWithinBounds(gripOrigin, Vector2.new(gripSize, gripSize)) and self._theming.text or self._theming.border1
            local gx = self.x + self.w - 3
            local gy = self.y + self.h - 3
            local dotS = Vector2.new(2, 2)
            self:_Draw('menu_grip_d1', 'rect', gripColor, 41, Vector2.new(gx,   gy),   dotS, true)
            self:_Draw('menu_grip_d2', 'rect', gripColor, 41, Vector2.new(gx-4, gy),   dotS, true)
            self:_Draw('menu_grip_d3', 'rect', gripColor, 41, Vector2.new(gx,   gy-4), dotS, true)
            self:_Draw('menu_grip_d4', 'rect', gripColor, 41, Vector2.new(gx-4, gy-4), dotS, true)
            self:_Draw('menu_grip_d5', 'rect', gripColor, 41, Vector2.new(gx-8, gy),   dotS, true)
            self:_Draw('menu_grip_d6', 'rect', gripColor, 41, Vector2.new(gx,   gy-8), dotS, true)

            if clickFrame then
                if self:_IsMouseWithinBounds(gripOrigin, Vector2.new(gripSize, gripSize)) then
                    self._menu_resize = Vector2.new(self.x + self.w - mousePos.x, self.y + self.h - mousePos.y)
                    clickFrame = false
                elseif not self._menu_drag and self:_IsMouseWithinBounds(Vector2.new(self.x, self.y), Vector2.new(self.w, self.h)) then
                    self._menu_drag = Vector2.new(mousePos.x - self.x, mousePos.y - self.y)
                end
            end
        else
            self:_RemoveColorpicker()
            self:_RemoveDropdown()
        end

        -- fade in/out
        local menuFade = 1 - (self._menu_toggled_at - (os.clock() - 0.25)) / 0.25
        if menuFade < 1.1 then
            self:_SetOpacityStartsWith('menu_', math.abs((self._menu_open and 0 or 1) - clamp(menuFade, 0, 1)))
        elseif not self._menu_open and menuFade > 1.1 and menuFade < 1.6 then
            self:_UndrawStartsWith('menu_')
        end
    end
end

local _espPools = {}

local function _getOrCreate(pool, key, dtype)
    if not pool[key] then
        pool[key] = Drawing.new(dtype)
        pool[key].Visible = false
    end
    return pool[key]
end

local function _hidePool(pool)
    for _, d in pairs(pool) do
        if d and d.Visible ~= nil then d.Visible = false end
    end
end

local function _destroyPool(pool)
    for k, d in pairs(pool) do
        if d and d.Remove then pcall(function() d:Remove() end) end
        pool[k] = nil
    end
end

local function _getPool(name)
    if not _espPools[name] then _espPools[name] = {} end
    return _espPools[name]
end

local function _hideBoxType(pool, prefix, count)
    for i = 1, count do
        local d = pool[prefix..i]
        if d then d.Visible = false end
    end
end

local function _clearBoxDrawings(pool)
    _hideBoxType(pool, "corner_", 8)
    _hideBoxType(pool, "full_",   4)
    _hideBoxType(pool, "fill_",   2)
end

local function _drawCornerBox(pool, x, y, w, h, col, thick)
    local cLen = math.min(w, h) * 0.25
    local segs = {
        {Vector2.new(x,   y),   Vector2.new(x+cLen,   y)},
        {Vector2.new(x,   y),   Vector2.new(x,         y+cLen)},
        {Vector2.new(x+w, y),   Vector2.new(x+w-cLen,  y)},
        {Vector2.new(x+w, y),   Vector2.new(x+w,       y+cLen)},
        {Vector2.new(x,   y+h), Vector2.new(x+cLen,    y+h)},
        {Vector2.new(x,   y+h), Vector2.new(x,         y+h-cLen)},
        {Vector2.new(x+w, y+h), Vector2.new(x+w-cLen,  y+h)},
        {Vector2.new(x+w, y+h), Vector2.new(x+w,       y+h-cLen)},
    }
    for i, s in ipairs(segs) do
        local k = "corner_"..i
        if not pool[k] or not pcall(function() return pool[k].From end) then
            pool[k] = Drawing.new("Line")
        end
        local ln = pool[k]
        ln.From = s[1]; ln.To = s[2]; ln.Color = col
        ln.Thickness = thick or 1.5; ln.ZIndex = 20; ln.Visible = true
    end
    _hideBoxType(pool, "full_", 4)
    _hideBoxType(pool, "fill_", 2)
end

local function _drawFullBox(pool, x, y, w, h, col, thick)
    local segs = {
        {Vector2.new(x,   y),   Vector2.new(x+w, y)},
        {Vector2.new(x+w, y),   Vector2.new(x+w, y+h)},
        {Vector2.new(x+w, y+h), Vector2.new(x,   y+h)},
        {Vector2.new(x,   y+h), Vector2.new(x,   y)},
    }
    for i, s in ipairs(segs) do
        local k = "full_"..i
        if not pool[k] or not pcall(function() return pool[k].From end) then
            pool[k] = Drawing.new("Line")
        end
        local ln = pool[k]
        ln.From = s[1]; ln.To = s[2]; ln.Color = col
        ln.Thickness = thick or 1.5; ln.ZIndex = 20; ln.Visible = true
    end
    _hideBoxType(pool, "corner_", 8)
    _hideBoxType(pool, "fill_",   2)
end

local function _drawFilledBox(pool, x, y, w, h, col)
    local k1 = "fill_1"
    if not pool[k1] or not pcall(function() return pool[k1].Size end) then
        pool[k1] = Drawing.new("Square")
    end
    local sq = pool[k1]
    sq.Position = Vector2.new(x,y); sq.Size = Vector2.new(w,h)
    sq.Color = col; sq.Filled = true; sq.Transparency = 0.55; sq.Visible = true

    local k2 = "fill_2"
    if not pool[k2] or not pcall(function() return pool[k2].Size end) then
        pool[k2] = Drawing.new("Square")
    end
    local ol = pool[k2]
    ol.Position = Vector2.new(x,y); ol.Size = Vector2.new(w,h)
    ol.Color = col; ol.Filled = false; ol.Thickness = 1.5; ol.Visible = true

    _hideBoxType(pool, "corner_", 8)
    _hideBoxType(pool, "full_",   4)
end

-- 8-segment health bar. Returns the color of the topmost lit segment.
local function _drawHealthBar(pool, x, y, h, hp, maxHp)
    local pct    = maxHp > 0 and math.max(0, math.min(1, hp/maxHp)) or 1
    local barX   = x - 8
    local barW   = 5
    local gap    = 1
    local segs   = 8
    local segH   = math.max(2, math.floor((h - gap*(segs-1)) / segs))
    local topColor = Color3.fromRGB(80, 200, 60)

    local bg = _getOrCreate(pool, "hpbar_bg", "Square")
    bg.Position = Vector2.new(barX, y); bg.Size = Vector2.new(barW, h)
    bg.Color = Color3.fromRGB(0,0,0); bg.Filled = true; bg.Transparency = 0.5; bg.Visible = true

    local litSegs = math.ceil(pct * segs)
    for i = 1, segs do
        local k      = "hpbar_seg_"..i
        local segY   = y + h - (i * segH) - (i-1) * gap
        local segObj = _getOrCreate(pool, k, "Square")
        if i <= litSegs then
            local t = (i-1)/(segs-1)
            local r, g
            if t < 0.5 then r=220; g=math.floor(220*(t*2))
            else r=math.floor(220*(1-(t-0.5)*2)); g=200 end
            local segColor = Color3.fromRGB(r, g, 30)
            segObj.Color = segColor; segObj.Transparency = 0
            if i == litSegs then topColor = segColor end
        else
            segObj.Color = Color3.fromRGB(30,30,30); segObj.Transparency = 0.3
        end
        segObj.Position = Vector2.new(barX, segY); segObj.Size = Vector2.new(barW, segH)
        segObj.Filled = true; segObj.Visible = true
    end
    return topColor
end

-- ── Public ESP namespace ─────────────────────────────────────
ESP = {}

--- Render ESP for all players. Call every frame when espCfg.enabled is true.
--- @param cfg table  espCfg table (see shape at top of ESP section)
function renderEsp(cfg)
    local Players    = game:GetService('Players')
    local LocalPlayer = Players.LocalPlayer
    local rendered   = {}
    local selfName   = LocalPlayer and LocalPlayer.Name

    for _, player in ipairs(Players:GetPlayers()) do
        local pname = player.Name
        local isSelf = (pname == selfName)

        if isSelf and not cfg.self then
            if _espPools[pname] then _hidePool(_espPools[pname]) end
            continue
        end

        rendered[pname] = true
        local pool = _getPool(pname)
        local char = player.Character
        if not char then _hidePool(pool) continue end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then _hidePool(pool) continue end

        local screenHead, onScreen = WorldToScreen(hrp.Position + Vector3.new(0, 3.2, 0))
        local screenFeet           = WorldToScreen(hrp.Position - Vector3.new(0, 3, 0))
        if not onScreen then _hidePool(pool) continue end

        local bH = math.abs(screenFeet.Y - screenHead.Y)
        local bW = bH * 0.5
        local bX = screenHead.X - bW / 2
        local bY = screenHead.Y
        local lblSize = math.max(8, math.min(13, math.floor(bH * 0.18)))

        local col = cfg.colorBox or Color3.fromRGB(220, 50, 50)
        if cfg.teamColor then
            local ok, tc = pcall(function() return player.TeamColor.Color end)
            if ok then col = tc end
        end

        -- box
        _clearBoxDrawings(pool)
        if cfg.box then
            if cfg.boxType == "Corner" then
                _drawCornerBox(pool, bX, bY, bW, bH, col, 1.5)
            elseif cfg.boxType == "Full" then
                _drawFullBox(pool, bX, bY, bW, bH, col, 1.5)
            else
                _drawFilledBox(pool, bX, bY, bW, bH, col)
            end
        end

        -- health
        local hp, maxHp = 100, 100
        pcall(function() hp    = hum.Health    end)
        pcall(function() maxHp = hum.MaxHealth end)
        local hpColor = Color3.fromRGB(80, 200, 80)

        if cfg.healthBar then
            hpColor = _drawHealthBar(pool, bX, bY, bH, hp, maxHp)
        else
            local hbg = pool["hpbar_bg"]
            if hbg then hbg.Visible = false end
            for i = 1, 8 do
                local seg = pool["hpbar_seg_"..i]
                if seg then seg.Visible = false end
            end
        end

        local hpTxt = _getOrCreate(pool, "hptext", "Text")
        hpTxt.Visible = cfg.health and true or false
        if cfg.health then
            hpTxt.Text     = math.floor(hp).."HP"
            hpTxt.Position = Vector2.new(bX + bW + 4, bY)
            hpTxt.Center   = false; hpTxt.Size = lblSize
            hpTxt.Color    = hpColor; hpTxt.Outline = true
        end

        -- name
        local labelY = bY - 2
        local nameTxt = _getOrCreate(pool, "label_name", "Text")
        nameTxt.Visible = cfg.name and true or false
        if cfg.name then
            nameTxt.Text     = pname
            nameTxt.Position = Vector2.new(screenHead.X, labelY)
            nameTxt.Center   = true; nameTxt.Size = lblSize
            nameTxt.Color    = cfg.colorName or Color3.fromRGB(255,255,255)
            nameTxt.Outline  = true
            labelY = labelY - (lblSize + 1)
        end

        -- distance
        local distTxt = _getOrCreate(pool, "label_dist", "Text")
        distTxt.Visible = cfg.distance and true or false
        if cfg.distance then
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local d = 0
            if myHRP then
                local dx = hrp.Position.X - myHRP.Position.X
                local dy = hrp.Position.Y - myHRP.Position.Y
                local dz = hrp.Position.Z - myHRP.Position.Z
                d = math.floor(math.sqrt(dx*dx + dy*dy + dz*dz))
            end
            distTxt.Text     = d.."m"
            distTxt.Position = Vector2.new(screenHead.X, labelY)
            distTxt.Center   = true; distTxt.Size = math.max(7, lblSize - 1)
            distTxt.Color    = cfg.colorDist or Color3.fromRGB(180,180,180)
            distTxt.Outline  = true
        end

        -- equipped tool
        local toolTxt = _getOrCreate(pool, "label_tool", "Text")
        toolTxt.Visible = false
        if cfg.tool then
            local toolName
            pcall(function()
                for _, c in ipairs(char:GetChildren()) do
                    local cn = tostring(c.ClassName)
                    if cn == "Tool" or cn == "HopperBin" then toolName = c.Name; break end
                end
            end)
            if toolName then
                toolTxt.Visible  = true
                toolTxt.Text     = "["..toolName.."]"
                toolTxt.Position = Vector2.new(screenHead.X, bY + bH + 3)
                toolTxt.Center   = true; toolTxt.Size = math.max(7, lblSize - 1)
                toolTxt.Color    = cfg.colorTool or Color3.fromRGB(255,220,50)
                toolTxt.Outline  = true
            end
        end
    end

    -- hide stale pools
    for pname, pool in pairs(_espPools) do
        if not rendered[pname] then _hidePool(pool) end
    end
end

--- Hide all ESP drawings immediately.
function ESP.hideAll()
    for _, pool in pairs(_espPools) do _hidePool(pool) end
end

--- Destroy all ESP drawings and free memory. Call on unload.
function ESP.destroyAll()
    for _, pool in pairs(_espPools) do _destroyPool(pool) end
    _espPools = {}
end


local RunService
do
    local _RS_table = {}
    local Render_Step_Priority_Bindings = {}
    local Thread_Execution_Active_State = true
    local Performance_Last_Tick_Timestamp = os.clock()
    local Metrics_Accumulated_Frame_Counter = 0
    local Cache_Sorted_Binding_Registry = {}
    local Cache_Validated_Bind_Count = 0
    local Error_Handling_Max_Threshold_Limit = 10
    local Error_Tracking_Current_Count = 0
    
    local function Signal()
        local SignalObject = {}
        SignalObject.ActiveConnections = {}
    
        function SignalObject:Connect(CallbackFunction)
            local ConnectionObject = {Function = CallbackFunction, Connected = true}
            table.insert(SignalObject.ActiveConnections, ConnectionObject)
            return {
                Disconnect = function()
                    ConnectionObject.Connected = false
                    ConnectionObject.Function = nil
                end
            }
        end
    
        function SignalObject:Fire(...)
            local ConnectionIndex = 1
            while ConnectionIndex <= #SignalObject.ActiveConnections do
                local ConnectionObject = SignalObject.ActiveConnections[ConnectionIndex]
                if ConnectionObject.Connected then
                    local ExecutionSuccess, ExecutionError = pcall(ConnectionObject.Function, ...)
                    if not ExecutionSuccess then
                        Error_Tracking_Current_Count = Error_Tracking_Current_Count + 1
                        if Error_Tracking_Current_Count >= Error_Handling_Max_Threshold_Limit then
                            warn(string.format("[RunService] Maximum errors reached (%d), shutting down", Error_Handling_Max_Threshold_Limit))
                            Thread_Execution_Active_State = false
                            return
                        end
                    end
                    ConnectionIndex = ConnectionIndex + 1
                else
                    table.remove(SignalObject.ActiveConnections, ConnectionIndex)
                end
            end
        end
    
        function SignalObject:Wait()
            local CurrentThread = coroutine.running()
            local WaitConnection
            WaitConnection = SignalObject:Connect(function(...)
                if WaitConnection then
                    WaitConnection:Disconnect()
                end
                task.spawn(CurrentThread, ...)
            end)
            return coroutine.yield()
        end
    
        return SignalObject
    end
    
    _RS_table.Heartbeat = Signal()
    _RS_table.RenderStepped = Signal()
    _RS_table.Stepped = Signal()
    
    function _RS_table:BindToRenderStep(BindName, BindPriority, BindFunction)
        if type(BindName) ~= "string" or type(BindFunction) ~= "function" then
            return
        end
        Render_Step_Priority_Bindings[BindName] = {Priority = BindPriority or 0, Function = BindFunction}
    end
    
    function _RS_table:UnbindFromRenderStep(BindName)
        Render_Step_Priority_Bindings[BindName] = nil
    end
    
    function _RS_table:IsRunning()
        return Thread_Execution_Active_State
    end
    
    task.spawn(function()
        while Thread_Execution_Active_State do
            local Loop_Execution_Success = pcall(function()
                local Timing_Current_Frame_Timestamp = os.clock()
                local Timing_Delta_Frame_Interval = math.min(Timing_Current_Frame_Timestamp - Performance_Last_Tick_Timestamp, 1)
                Performance_Last_Tick_Timestamp = Timing_Current_Frame_Timestamp
                Metrics_Accumulated_Frame_Counter = Metrics_Accumulated_Frame_Counter + 1
    
                if Thread_Execution_Active_State then
                    _RS_table.Stepped:Fire(Timing_Current_Frame_Timestamp, Timing_Delta_Frame_Interval)
                end
    
                if Thread_Execution_Active_State then
                    local Binding_Active_Count_Snapshot = 0
                    for _ in pairs(Render_Step_Priority_Bindings) do
                        Binding_Active_Count_Snapshot = Binding_Active_Count_Snapshot + 1
                    end
    
                    if Binding_Active_Count_Snapshot ~= Cache_Validated_Bind_Count then
                        Cache_Sorted_Binding_Registry = {}
                        for Bind_Name, Bind_Data in pairs(Render_Step_Priority_Bindings) do
                            if Bind_Data and type(Bind_Data.Function) == "function" then
                                table.insert(Cache_Sorted_Binding_Registry, Bind_Data)
                            end
                        end
    
                        table.sort(Cache_Sorted_Binding_Registry, function(Bind_A, Bind_B)
                            return Bind_A.Priority < Bind_B.Priority
                        end)
    
                        Cache_Validated_Bind_Count = Binding_Active_Count_Snapshot
                    end
    
                    for Bind_Index = 1, #Cache_Sorted_Binding_Registry do
                        if not Thread_Execution_Active_State then
                            break
                        end
                        
                        local Binding_Current_Execution_Target = Cache_Sorted_Binding_Registry[Bind_Index]
                        if Binding_Current_Execution_Target and Binding_Current_Execution_Target.Function then
                            pcall(Binding_Current_Execution_Target.Function, Timing_Delta_Frame_Interval)
                        end
                    end
                end
    
                if Thread_Execution_Active_State then
                    _RS_table.RenderStepped:Fire(Timing_Delta_Frame_Interval)
                end
    
                if Thread_Execution_Active_State then
                    _RS_table.Heartbeat:Fire(Timing_Delta_Frame_Interval)
                end
            end)
    
            if not Loop_Execution_Success then
                Error_Tracking_Current_Count = Error_Tracking_Current_Count + 1
                if Error_Tracking_Current_Count >= Error_Handling_Max_Threshold_Limit then
                    Thread_Execution_Active_State = false
                    break
                end
            else
                Error_Tracking_Current_Count = math.max(0, Error_Tracking_Current_Count - 1)
            end
    
            if Thread_Execution_Active_State then
                task.wait()
            end
        end
    end)

    RunService = _RS_table
end



local Players = game:GetService("Players")
local player  = Players.LocalPlayer
local mouse   = player:GetMouse()
local camera  = workspace.CurrentCamera


local SPACE = 0x20



local SAVE_PATH     = "evade_config.json"
local DEBOUNCE_SECS = 1.5

local LocalConfig = {}
local _rawConfig  = nil
local _saveCo     = nil

-- ── Tiny JSON encoder ─────────────────────────────────────────
local function _enc(v, seen)
    local t = type(v)
    if t == "nil"     then return "null"
    elseif t == "boolean" then return v and "true" or "false"
    elseif t == "number"  then
        if v ~= v or v == math.huge or v == -math.huge then return "0" end
        if v == math.floor(v) and math.abs(v) < 1e15 then
            return string.format("%d", v)
        end
        return string.format("%.8g", v)
    elseif t == "string" then
        local s = v:gsub("\\", "\\\\")
        s = s:gsub('"', '\\"')
        s = s:gsub("\n", "\\n")
        s = s:gsub("\r", "\\r")
        s = s:gsub("\t", "\\t")
        return '"' .. s .. '"'
    elseif t == "table" then
        seen = seen or {}
        if seen[v] then return "null" end
        seen[v] = true
        -- Color3 detection
        if type(v.R)=="number" and type(v.G)=="number" and type(v.B)=="number" then
            local s = string.format('{"_c3":1,"r":%.6f,"g":%.6f,"b":%.6f}', v.R, v.G, v.B)
            seen[v] = nil; return s
        end
        local parts = {}
        if #v > 0 then
            for i=1,#v do parts[i] = _enc(v[i], seen) end
            seen[v] = nil
            return "[" .. table.concat(parts,",") .. "]"
        else
            local i = 0
            for k,val in pairs(v) do
                local vt = type(val)
                if vt=="boolean" or vt=="number" or vt=="string" or vt=="table" then
                    i=i+1; parts[i] = '"'..tostring(k)..'":'.. _enc(val,seen)
                end
            end
            seen[v] = nil
            return "{" .. table.concat(parts,",") .. "}"
        end
    end
    return "null"
end

-- ── Tiny JSON decoder ─────────────────────────────────────────
local function _skipWS(s,i)
    while i<=#s do
        local c=s:sub(i,i)
        if c==" " or c=="\t" or c=="\n" or c=="\r" then i=i+1 else break end
    end
    return i
end
local _dec
_dec = function(s,i)
    i = _skipWS(s,i)
    if i>#s then return nil,i end
    local c = s:sub(i,i)
    if c=="n" then return nil,i+4
    elseif c=="t" then return true,i+4
    elseif c=="f" then return false,i+5
    elseif c=='"' then
        local j,buf = i+1,{}
        while j<=#s do
            local ch=s:sub(j,j)
            if ch=='"' then return table.concat(buf),j+1
            elseif ch=="\\" then
                local nx=s:sub(j+1,j+1)
                if     nx=='"' then buf[#buf+1]='"'
                elseif nx=="\\" then buf[#buf+1]="\\"
                elseif nx=="n"   then buf[#buf+1]="\n"
                elseif nx=="r"   then buf[#buf+1]="\r"
                elseif nx=="t"   then buf[#buf+1]="\t"
                else                  buf[#buf+1]=nx
                end
                j=j+2
            else buf[#buf+1]=ch; j=j+1 end
        end
        return table.concat(buf),j
    elseif c=='[' then
        local arr,j = {},i+1
        j=_skipWS(s,j)
        if s:sub(j,j)==']' then return arr,j+1 end
        while true do
            local val; val,j=_dec(s,j); arr[#arr+1]=val
            j=_skipWS(s,j)
            if s:sub(j,j)==']' then return arr,j+1 end
            j=j+1
        end
    elseif c=='{' then
        local obj,j = {},i+1
        j=_skipWS(s,j)
        if s:sub(j,j)=='}' then return obj,j+1 end
        while true do
            local key; key,j=_dec(s,j)
            j=_skipWS(s,j)+1
            local val; val,j=_dec(s,j)
            obj[key]=val
            j=_skipWS(s,j)
            if s:sub(j,j)=='}' then
                if obj["_c3"] and obj["r"] and obj["g"] and obj["b"] then
                    return Color3.new(obj["r"],obj["g"],obj["b"]),j+1
                end
                return obj,j+1
            end
            j=j+1
        end
    else
        local numStr = s:match("^%-?%d+%.?%d*[eE]?[%+%-]?%d*",i)
        if numStr then return tonumber(numStr),i+#numStr end
        return nil,i+1
    end
end

-- ── Snapshot / apply ──────────────────────────────────────────
local function _snapshot()
    local snap = {}
    for section,data in pairs(_rawConfig) do
        if type(data)=="table" then
            snap[section]={}
            for k,v in pairs(data) do
                local vt=type(v)
                if vt=="boolean" or vt=="number" or vt=="string" then
                    snap[section][k]=v
                elseif vt=="table" and type(v.R)=="number" then
                    snap[section][k]=v  -- Color3
                end
            end
        end
    end
    return snap
end

local function _applySnapshot(snap)
    for section,data in pairs(snap) do
        local target = _rawConfig[section]
        if target and type(data)=="table" then
            for k,v in pairs(data) do
                -- Apply saved value if the key exists in current CONFIG schema
                -- (guards against stale keys from old saves)
                if rawget(target, k) ~= nil or target[k] ~= nil then
                    target[k] = v
                end
            end
        end
    end
end

-- ── Flush to disk ────────────────────────────────────────────
local function _flush()
    local ok, err = pcall(function()
        local json = _enc(_snapshot())
        writefile(SAVE_PATH, json)
    end)
    if not ok then
    else
    end
end

-- ── Debounced save ────────────────────────────────────────────
local function _scheduleSave()
    if _saveCo then return end
    _saveCo = spawn(function()
        task.wait(DEBOUNCE_SECS)
        _saveCo = nil
        _flush()
    end)
end

-- ── Proxy factory ────────────────────────────────────────────
local function _makeProxy(sectionData)
    return setmetatable({}, {
        __index    = sectionData,
        __newindex = function(_,k,v) sectionData[k]=v; _scheduleSave() end,
        __pairs    = function(_) return pairs(sectionData) end,
    })
end

-- ── Public API ───────────────────────────────────────────────
function LocalConfig.init(rawCfg)
    _rawConfig = rawCfg
    local proxy = {}
    for section,data in pairs(rawCfg) do
        if type(data)=="table" then proxy[section] = _makeProxy(data)
        else proxy[section] = data end
    end
    return proxy
end

function LocalConfig.load()

    if not isfile(SAVE_PATH) then
        return "new"
    end

    -- Schema migration: if save predates keybinds/ui sections, wipe it so
    -- we start clean rather than loading an incomplete config.
    do
        local raw = readfile(SAVE_PATH)
        if not raw:find('"keybinds"') or not raw:find('"ui"') then
            delfile(SAVE_PATH)
            return "new"
        end
    end

    local ok, result = pcall(function()
        return readfile(SAVE_PATH)
    end)

    if not ok then
        return "error"
    end


    local decOk, snap = pcall(function()
        local decoded, _ = _dec(result, 1)
        return decoded
    end)

    if not decOk then
        return "error"
    end
    if type(snap) ~= "table" then
        return "error"
    end

    _applySnapshot(snap)
    return "ok"
end

function LocalConfig.save()
    spawn(_flush)
end
-- ============================================================
local CONFIG = {
    bhop = {
        enabled      = false,
        key          = nil,
        velThreshold = 1,    -- vertical velocity window to trigger jump (studs/s)
        jumpDelay    = 0.01, -- seconds to hold space before releasing
        tickRate     = 0.01, -- how often bhop loop ticks (seconds)
        autoStrafe   = false,
        strafeSens   = 2,    -- mouse delta X magnitude threshold to trigger A/D
    },
    autofarm = {
        enabled        = false,
        skyX           = -7.570,
        skyY           = 380.103,
        skyZ           = 86.898,
        collectionTime = 0.3,   -- time spent at each ticket (Collect)
        safetyInterval = 0.5,   -- scan cooldown while collecting (ScanCooldown)
        safeRadius     = 40,    -- min distance a bot must be from a ticket to collect it
        botRetryDelay  = 2,     -- seconds to wait in sky before retrying an unsafe ticket
        safetyEnabled  = true,  -- whether to skip tickets with bots nearby
    },
    coneHat = {
        enabled    = false,
        fps        = 60,
        segments   = 24,
        radius     = 1.8,
        height     = 1.3,
        yOffset    = 0.6,
        color      = Color3.new(0, 0, 0),
        zindex     = 5,
    },
    nextbotEsp = {
        enabled     = false,
        showBox     = true,
        showName    = true,
        showDist    = true,
        showLine    = false,
        fillBox     = false,
        fillOpacity = 0.15,
        boxColor    = Color3.fromRGB(255, 60, 60),
        nameColor   = Color3.fromRGB(255, 255, 255),
        distColor   = Color3.fromRGB(255, 200, 0),
        lineColor   = Color3.fromRGB(255, 60, 60),
        thickness   = 1,
        maxDist     = 500,
        minBoxSize  = 20,
    },
    velIndicator = {
        enabled = false,
    },
    crosshair = {
        enabled  = false,
        style    = "Cross",   -- "Dot", "Cross", "Circle"
        size     = 8,
        gap      = 4,
        thickness= 1,
        color    = Color3.fromRGB(255, 255, 255),
    },
    noclip = {
        enabled = false,
    },
    fly = {
        enabled = false,
        speed   = 50,
    },
    highJump = {
        enabled = false,
        force   = 80,
    },
    antiVoid = {
        enabled   = false,
        threshold = -100,  -- Y below this triggers teleport
        safeY     = 5,
    },
    botDodge = {
        enabled   = false,
        radius    = 15,   -- studs — teleport away if nextbot is within this
        dodgeDist = 8,    -- studs to teleport directly away from the bot
        cooldown  = 0.5,  -- seconds between dodge triggers
    },
    -- Keybind names (string key names matching UILib._inputs keys, or nil)
    keybinds = {
        bhopKey      = "none",   bhopMode      = "Hold",
        noclipKey    = "none",   noclipMode    = "Hold",
        flyKey       = "none",   flyMode       = "Hold",
        highJumpKey  = "none",   highJumpMode  = "Hold",
    },
    -- Dropdown + UI selections saved as strings
    ui = {
        boxColor       = "Red",
        nameColor      = "White",
        distColor      = "Yellow",
        lineColor      = "Red",
        hatColor       = "Black",
        crosshairStyle = "Cross",
        crosshairColor = "White",
    },
}

-- ── Config system: wrap CONFIG with auto-save proxy ────────────
CONFIG = LocalConfig.init(CONFIG)
do
    local loadResult = LocalConfig.load()
    spawn(function()
        task.wait(1)  -- wait for UILib to be ready for notifications
        if loadResult == "ok" then
            UILib:Notification("Config loaded!", 3)
        elseif loadResult == "new" then
            -- First ever run — nothing saved yet, this is normal
            UILib:Notification("First run! Settings will auto-save as you change them.", 5)
            LocalConfig.save()  -- save defaults immediately so next load works
        elseif loadResult == "error" then
            UILib:Notification("Config load failed — check console for details.", 5)
        end
    end)
end

do
    local _cv = {
        Red={255,60,60}, Orange={255,140,0}, Yellow={255,220,0}, Green={60,255,60},
        Cyan={0,220,255}, Blue={60,100,255}, Purple={180,60,255},
        White={255,255,255}, Pink={255,100,180}, Black={0,0,0},
    }
    local function _c(name) local t=_cv[name]; return t and Color3.fromRGB(t[1],t[2],t[3]) or Color3.fromRGB(255,255,255) end
    -- Use _rawConfig directly so we bypass proxy (avoids triggering an auto-save on startup)
    local raw = CONFIG  -- proxy __index passes through to rawConfig reads fine
    CONFIG.nextbotEsp.boxColor  = _c(CONFIG.ui.boxColor)
    CONFIG.nextbotEsp.nameColor = _c(CONFIG.ui.nameColor)
    CONFIG.nextbotEsp.distColor = _c(CONFIG.ui.distColor)
    CONFIG.nextbotEsp.lineColor = _c(CONFIG.ui.lineColor)
    CONFIG.coneHat.color        = _c(CONFIG.ui.hatColor)
    CONFIG.crosshair.style      = CONFIG.ui.crosshairStyle
    CONFIG.crosshair.color      = _c(CONFIG.ui.crosshairColor)
end

local nextbotDrawings = {}

-- ── Crosshair ────────────────────────────────────────────────
local _chDrawings = {
    dot    = Drawing.new("Square"),
    top    = Drawing.new("Square"),
    bottom = Drawing.new("Square"),
    left   = Drawing.new("Square"),
    right  = Drawing.new("Square"),
    circle = Drawing.new("Circle"),
}
_chDrawings.dot.Filled    = true
_chDrawings.top.Filled    = true
_chDrawings.bottom.Filled = true
_chDrawings.left.Filled   = true
_chDrawings.right.Filled  = true
_chDrawings.circle.Filled = false
for _, d in pairs(_chDrawings) do d.Visible = false end

local function _crosshairUpdate()
    local cfg = CONFIG.crosshair
    local ss  = UILib:_GetScreenSize()
    local cx  = ss.X / 2
    local cy  = ss.Y / 2
    local col = cfg.color

    -- hide all first
    for _, d in pairs(_chDrawings) do d.Visible = false end

    if not cfg.enabled then return end

    if cfg.style == "Dot" then
        local d = _chDrawings.dot
        local r = cfg.size / 2
        d.Color    = col
        d.Size     = Vector2.new(cfg.size, cfg.size)
        d.Position = Vector2.new(cx - r, cy - r)
        d.Visible  = true

    elseif cfg.style == "Cross" then
        local s   = cfg.size
        local g   = cfg.gap
        local th  = cfg.thickness
        -- top
        local t = _chDrawings.top
        t.Color = col; t.Size = Vector2.new(th, s)
        t.Position = Vector2.new(cx - th/2, cy - g - s)
        t.Visible = true
        -- bottom
        local b = _chDrawings.bottom
        b.Color = col; b.Size = Vector2.new(th, s)
        b.Position = Vector2.new(cx - th/2, cy + g)
        b.Visible = true
        -- left
        local l = _chDrawings.left
        l.Color = col; l.Size = Vector2.new(s, th)
        l.Position = Vector2.new(cx - g - s, cy - th/2)
        l.Visible = true
        -- right
        local r = _chDrawings.right
        r.Color = col; r.Size = Vector2.new(s, th)
        r.Position = Vector2.new(cx + g, cy - th/2)
        r.Visible = true

    elseif cfg.style == "Circle" then
        local c = _chDrawings.circle
        c.Color     = col
        c.Radius    = cfg.size
        c.Thickness = cfg.thickness
        c.Position  = Vector2.new(cx, cy)
        c.Visible   = true
    end
end

local function _crosshairClear()
    for _, d in pairs(_chDrawings) do d.Visible = false end
end
-- ─────────────────────────────────────────────────────────────

-- ── Noclip ───────────────────────────────────────────────────
-- Noclip works by hijacking the fly velocity override (same mechanism).
-- The spawn loop below is kept but is a no-op since _flyUpdate handles it.
local _noclipKeyName = (CONFIG.keybinds.noclipKey ~= "none") and CONFIG.keybinds.noclipKey or nil
local _noclipKeyMode = CONFIG.keybinds.noclipMode
local _noclipToggled = false
local _noclipWasHeld = false
local function _noclipUpdate()
    -- intentional no-op: noclip is handled inside _flyUpdate when noclip enabled
end
spawn(function()
    while not shouldDie do
        task.wait()
    end
end)
-- ─────────────────────────────────────────────────────────────

-- ── Fly ──────────────────────────────────────────────────────
local _flyKeyName  = (CONFIG.keybinds.flyKey ~= "none") and CONFIG.keybinds.flyKey or nil
local _flyKeyMode  = CONFIG.keybinds.flyMode
local _flyToggled  = false
local _flyWasHeld  = false
local function _flyUpdate()
    -- active if noclip keybind active, OR fly enabled+keybind active
    local active = false
    if CONFIG.noclip.enabled then
        if _noclipKeyMode == "Always" then
            active = true
        elseif _noclipKeyName then
            local held = UILib._inputs[_noclipKeyName] and UILib._inputs[_noclipKeyName].held
            if _noclipKeyMode == "Toggle" then
                if held and not _noclipWasHeld then _noclipToggled = not _noclipToggled end
                _noclipWasHeld = held
                active = _noclipToggled
            else
                active = held
            end
        else
            active = true  -- no key bound = always on when toggle enabled
        end
    elseif CONFIG.fly.enabled then
        if _flyKeyMode == "Always" then
            active = true
        elseif _flyKeyName then
            local held = UILib._inputs[_flyKeyName] and UILib._inputs[_flyKeyName].held
            if _flyKeyMode == "Toggle" then
                if held and not _flyWasHeld then _flyToggled = not _flyToggled end
                _flyWasHeld = held
                active = _flyToggled
            else
                active = held
            end
        end
    end

    if not active then return end
    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local spd = CONFIG.fly.speed
    local vx, vy, vz = 0, 0, 0

    local cam = workspace.CurrentCamera
    local dx  = hrp.Position.X - cam.Position.X
    local dz  = hrp.Position.Z - cam.Position.Z
    local len = math.sqrt(dx*dx + dz*dz)
    if len > 0 then dx = dx/len; dz = dz/len end
    local rx, rz = -dz, dx

    if UILib._inputs['w'].held     then vx = vx + dx*spd;  vz = vz + dz*spd  end
    if UILib._inputs['s'].held     then vx = vx - dx*spd;  vz = vz - dz*spd  end
    if UILib._inputs['a'].held     then vx = vx - rx*spd;  vz = vz - rz*spd  end
    if UILib._inputs['d'].held     then vx = vx + rx*spd;  vz = vz + rz*spd  end
    if not CONFIG.noclip.enabled then
        if UILib._inputs['space'].held then vy =  spd end
        if UILib._inputs['lctrl'].held then vy = -spd end
    end

    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.new(vx, vy, vz)
    end)
end

local _hjKeyName  = (CONFIG.keybinds.highJumpKey ~= "none") and CONFIG.keybinds.highJumpKey or nil
local _hjKeyMode  = CONFIG.keybinds.highJumpMode
local _hjToggled  = false
local _hjWasHeld  = false
local function _highJumpUpdate()
    if not CONFIG.highJump.enabled then return end

    local active = false
    if _hjKeyMode == "Always" then
        active = true
    elseif _hjKeyName then
        local held = UILib._inputs[_hjKeyName] and UILib._inputs[_hjKeyName].held
        if _hjKeyMode == "Toggle" then
            if held and not _hjWasHeld then _hjToggled = not _hjToggled end
            _hjWasHeld = held
            active = _hjToggled
        else -- Hold
            active = held
        end
    end

    if not active then return end
    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local spaceHeld = UILib._inputs['space'].held
    if spaceHeld and not _hjWasHeld then
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.new(
                hrp.AssemblyLinearVelocity.X,
                CONFIG.highJump.force,
                hrp.AssemblyLinearVelocity.Z
            )
        end)
    end
    _hjWasHeld = spaceHeld
end

local function _antiVoidUpdate()
    if not CONFIG.antiVoid.enabled then return end
    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if hrp.Position.Y < CONFIG.antiVoid.threshold then
        pcall(function()
            hrp.Position = Vector3.new(hrp.Position.X, CONFIG.antiVoid.safeY, hrp.Position.Z)
            hrp.Velocity = Vector3.new(0, 0, 0)
        end)
    end
end

local _botDodgeLastTrig = 0



local _VEL_SAMPLES  = 200    -- how many data points to keep
local _VEL_W        = 200    -- graph width  (px)
local _VEL_H        = 60     -- graph height (px)
local _VEL_MARGIN_X = 12     -- distance from right edge of screen
local _VEL_MARGIN_Y = 12     -- distance from bottom edge of screen
local _VEL_MAX_DISP = 60     -- speed value that fills the graph top (studs/s)

local _velSamples   = {}     -- ring buffer of speed values
local _velHead      = 0      -- current write index (1-based after first fill)
local _velFilled    = 0      -- how many slots are actually filled

-- pre-fill with zeros
for i = 1, _VEL_SAMPLES do _velSamples[i] = 0 end

-- drawing objects (created once)
local _velBg    = Drawing.new("Square")
_velBg.Filled   = true
_velBg.Color    = Color3.fromRGB(0, 0, 0)
_velBg.Transparency = 0.45
_velBg.Visible  = false

local _velBorder = Drawing.new("Square")
_velBorder.Filled = false
_velBorder.Thickness = 1
_velBorder.Color  = Color3.fromRGB(35, 45, 65)
_velBorder.Visible = false

local _velLabel = Drawing.new("Text")
_velLabel.Outline = true
_velLabel.Size    = 11
_velLabel.Color   = Color3.fromRGB(220, 228, 240)
_velLabel.Visible = false

local _velLines = {}
for i = 1, _VEL_SAMPLES - 1 do
    local ln = Drawing.new("Line")
    ln.Thickness = 1.5
    ln.Color     = Color3.fromRGB(77, 166, 255)
    ln.Visible   = false
    _velLines[i] = ln
end

local function _velMagnitude(v)
    return math.sqrt(v.X*v.X + v.Y*v.Y + v.Z*v.Z)
end

local function _velClearAll()
    _velBg.Visible     = false
    _velBorder.Visible = false
    _velLabel.Visible  = false
    for _, ln in ipairs(_velLines) do ln.Visible = false end
end

local function _velUpdate()
    if not CONFIG.velIndicator.enabled then
        _velClearAll()
        return
    end

    -- sample current speed
    local char  = player.Character
    local hrp   = char and char:FindFirstChild("HumanoidRootPart")
    local speed = 0
    if hrp then
        local vel = hrp.AssemblyLinearVelocity
        if vel then speed = _velMagnitude(vel) end
    end

    _velHead = (_velHead % _VEL_SAMPLES) + 1
    _velSamples[_velHead] = speed
    if _velFilled < _VEL_SAMPLES then _velFilled = _velFilled + 1 end

    -- figure out screen position (bottom-right anchor)
    local ss  = UILib:_GetScreenSize()
    local gx  = ss.X - _VEL_W - _VEL_MARGIN_X
    local gy  = ss.Y - _VEL_H - _VEL_MARGIN_Y

    -- background + border
    _velBg.Position     = Vector2.new(gx, gy)
    _velBg.Size         = Vector2.new(_VEL_W, _VEL_H)
    _velBg.Visible      = true

    _velBorder.Position = Vector2.new(gx, gy)
    _velBorder.Size     = Vector2.new(_VEL_W, _VEL_H)
    _velBorder.Visible  = true

    -- label: current speed
    _velLabel.Text     = string.format("%.1f s/u", speed)
    _velLabel.Position = Vector2.new(gx + 4, gy + 2)
    _velLabel.Visible  = true

    -- draw the graph lines oldest→newest left→right
    local n      = _VEL_SAMPLES
    local pad    = 4
    local innerW = _VEL_W - pad * 2
    local innerH = _VEL_H - pad * 2 - 14   -- leave room for label at top

    local function sampleAt(i)
        -- i=1 is the oldest, i=n is the newest
        local idx = ((_velHead - n + i - 1) % n) + 1
        return _velSamples[idx] or 0
    end

    for i = 1, n - 1 do
        local s1 = sampleAt(i)
        local s2 = sampleAt(i + 1)

        local x1 = gx + pad + (i - 1) / (n - 1) * innerW
        local x2 = gx + pad + i       / (n - 1) * innerW
        local y1 = gy + _VEL_H - pad - (math.min(s1, _VEL_MAX_DISP) / _VEL_MAX_DISP) * innerH
        local y2 = gy + _VEL_H - pad - (math.min(s2, _VEL_MAX_DISP) / _VEL_MAX_DISP) * innerH

        local ln = _velLines[i]
        -- tint hotter when faster
        local t = math.min(speed / _VEL_MAX_DISP, 1)
        ln.Color   = Color3.fromRGB(
            math.floor(77  + (255 - 77)  * t),
            math.floor(166 - 166         * t),
            math.floor(255 - 255         * t))
        ln.From    = Vector2.new(x1, y1)
        ln.To      = Vector2.new(x2, y2)
        ln.Visible = true
    end
end
-- ─────────────────────────────────────────────────────────────

local function ClearAllNextbotESP()
    for _, entry in pairs(nextbotDrawings) do
        if entry.box   then entry.box:Remove()   end
        if entry.fill  then entry.fill:Remove()  end
        if entry.label then entry.label:Remove() end
        if entry.dist  then entry.dist:Remove()  end
        if entry.line  then entry.line:Remove()  end
    end
    nextbotDrawings = {}
end

local function HideAllESP()
    for _, entry in pairs(nextbotDrawings) do
        if entry.box   then entry.box.Visible   = false end
        if entry.fill  then entry.fill.Visible  = false end
        if entry.label then entry.label.Visible = false end
        if entry.dist  then entry.dist.Visible  = false end
        if entry.line  then entry.line.Visible  = false end
    end
end

-- Cache player names
-- Periodically rebuild the real-player name set so we never ESP them.
-- Runs every 5 seconds so newly joined players are caught quickly.
local playerNamesCache = {}
local function _rebuildPlayerCache()
    local fresh = {}
    for _, p in ipairs(Players:GetPlayers()) do
        fresh[p.Name] = true
    end
    playerNamesCache = fresh
end

-- ── Bot Dodge ────────────────────────────────────────────────
local _dodgeFolder = nil

local function _botDodgeUpdate()
    local cfg = CONFIG.botDodge
    if not cfg.enabled then return end

    local now = os.clock()
    if now - _botDodgeLastTrig < cfg.cooldown then return end

    -- Find bots folder independently (doesn't require ESP to be on)
    if not _dodgeFolder then
        local g = workspace:FindFirstChild("Game")
        _dodgeFolder = g and g:FindFirstChild("Players") or nil
        if not _dodgeFolder then return end
    end

    -- Re-fetch character fresh inside pcall, same as autofarm
    local myPos       = nil
    local closest     = nil
    local closestDist = math.huge

    pcall(function()
        local char2 = player.Character
        local hrp2  = char2 and char2:FindFirstChild("HumanoidRootPart")
        if not hrp2 then return end
        myPos = hrp2.Position
    end)
    if not myPos then return end

    for _, model in ipairs(_dodgeFolder:GetChildren()) do
        if not model:IsA("Model") then continue end
        if playerNamesCache[model.Name] then continue end

        local root = model:FindFirstChild("Hitbox") or model:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        -- Guard: root.Position can be nil if the part is destroyed mid-frame
        local rootPos = root.Position
        if not rootPos then continue end

        local dx3 = myPos.X - rootPos.X
        local dy3 = myPos.Y - rootPos.Y
        local dz3 = myPos.Z - rootPos.Z
        local d   = math.sqrt(dx3*dx3 + dy3*dy3 + dz3*dz3)

        local radius = cfg.radius or 15
        if d < radius and d < closestDist then
            closestDist = d
            closest     = rootPos
        end
    end

    if not closest then return end

    -- Direction directly away from the closest bot on XZ plane
    local dx  = myPos.X - closest.X
    local dz  = myPos.Z - closest.Z
    local len = math.sqrt(dx*dx + dz*dz)
    if len < 0.01 then dx = 1; dz = 0
    else dx = dx/len; dz = dz/len end

    local newPos = Vector3.new(
        myPos.X + dx * cfg.dodgeDist,
        myPos.Y,
        myPos.Z + dz * cfg.dodgeDist
    )

    pcall(function()
        local char2 = player.Character
        local hrp2  = char2 and char2:FindFirstChild("HumanoidRootPart")
        if hrp2 then
            hrp2.Position = newPos
            hrp2.Velocity = Vector3.new(0, 0, 0)
        end
    end)

    _botDodgeLastTrig = now
end
-- ─────────────────────────────────────────────────────────────
_rebuildPlayerCache()
spawn(function()
    while true do
        task.wait(5)
        _rebuildPlayerCache()
    end
end)

-- Cache workspace path
local playersFolder = nil

-- Persistent seen table - reused every frame
local _seen = {}


local cachedChildren      = {}
local cachedChildCount    = -1
local screenCX, screenCY  = 960, 540

local function RebuildChildrenCache()
    if not playersFolder then return end
    cachedChildren   = playersFolder:GetChildren()
    cachedChildCount = #cachedChildren
end


-- track last-written values per drawing and skip writes if unchanged.
-- For vectors/sizes we store X and Y separately to avoid Vector2 allocation on compare.

local function SetVisible(obj, v)
    if obj.Visible ~= v then obj.Visible = v end
end

local function SetText(obj, t)
    if obj.Text ~= t then obj.Text = t end
end

local function SetPos2(obj, x, y)
    -- Only write if changed (avoids allocating Vector2 unnecessarily)
    local p = obj.Position
    if p.X ~= x or p.Y ~= y then
        obj.Position = Vector2.new(x, y)
    end
end

local function SetSize2(obj, w, h)
    local s = obj.Size
    if s.X ~= w or s.Y ~= h then
        obj.Size = Vector2.new(w, h)
    end
end

local function UpdateNextbotESP()
    local cfg = CONFIG.nextbotEsp

    if not playersFolder then
        local g = game.Workspace:FindFirstChild("Game")
        playersFolder = g and g:FindFirstChild("Players") or nil
        if playersFolder then
            RebuildChildrenCache()
        end
    end
    if not playersFolder then return end

    -- Only rebuild children table when count changes (cheap check, avoids full alloc every tick)
    local currentCount = #playersFolder:GetChildren()
    if currentCount ~= cachedChildCount then
        RebuildChildrenCache()
    end

    local char   = player.Character
    local hrp    = char and char:FindFirstChild("HumanoidRootPart")
    local camPos = hrp and hrp.Position

    -- clear seen flags
    for k in pairs(_seen) do _seen[k] = nil end

    for _, model in ipairs(cachedChildren) do
        if not model:IsA("Model") then continue end

        -- Skip real players — cache is refreshed every 5s
        if playerNamesCache[model.Name] then continue end

        -- Some nextbots use a Hitbox part, others (e.g. Kitten-type) use HumanoidRootPart
        local root = model:FindFirstChild("Hitbox") or model:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        _seen[model] = true

        local pos    = root.Position
        local dist3D = camPos and (camPos - pos).Magnitude or 0

        -- Cull by distance before any drawing work
        if camPos and dist3D > cfg.maxDist then
            local entry = nextbotDrawings[model]
            if entry then
                SetVisible(entry.box,   false)
                SetVisible(entry.fill,  false)
                SetVisible(entry.label, false)
                SetVisible(entry.dist,  false)
                SetVisible(entry.line,  false)
            end
            continue
        end

        -- Create drawings lazily
        if not nextbotDrawings[model] then
            local fill        = Drawing.new("Square")
            fill.Filled       = true
            fill.Thickness    = 0
            fill.Color        = cfg.boxColor
            fill.Transparency = 1 - cfg.fillOpacity
            fill.Visible      = false

            local box         = Drawing.new("Square")
            box.Filled        = false
            box.Thickness     = cfg.thickness
            box.Color         = cfg.boxColor
            box.Visible       = false

            local label       = Drawing.new("Text")
            label.Text        = model.Name
            label.Outline     = true
            label.Center      = true
            label.Size        = 14
            label.Color       = cfg.nameColor
            label.Visible     = false

            local dist        = Drawing.new("Text")
            dist.Text         = ""
            dist.Outline      = true
            dist.Center       = true
            dist.Size         = 12
            dist.Color        = cfg.distColor
            dist.Visible      = false

            local line        = Drawing.new("Line")
            line.Thickness    = 1
            line.Color        = cfg.lineColor
            line.Visible      = false

            local partSize = root.Size
            local extentY  = math.max(1, partSize and partSize.Y * 0.5 or 1)
            local extentX  = math.max(1, partSize and partSize.X * 0.5 or 1)
            local isTiny   = partSize and (partSize.X < 0.5 or partSize.Y < 0.5 or partSize.Z < 0.5)

            nextbotDrawings[model] = {
                box = box, fill = fill, label = label, dist = dist, line = line,
                isTiny = isTiny, extentY = extentY, extentX = extentX,
            }
        end

        local entry               = nextbotDrawings[model]
        local screenPos, onScreen = WorldToScreen(pos)

        -- Traceline (only write From/To if visible)
        if cfg.showLine then
            entry.line.From = Vector2.new(screenCX, screenCY)
            entry.line.To   = screenPos
            SetVisible(entry.line, true)
        else
            SetVisible(entry.line, false)
        end

        if not onScreen then
            SetVisible(entry.box,   false)
            SetVisible(entry.fill,  false)
            SetVisible(entry.label, false)
            SetVisible(entry.dist,  false)
            continue
        end

        local topScreen, _ = WorldToScreen(pos + Vector3.new(0, entry.extentY, 0))
        local halfH = math.max(cfg.minBoxSize * 0.5, screenPos.Y - topScreen.Y)
        local halfW = math.max(cfg.minBoxSize * 0.5, halfH * (entry.extentX / entry.extentY))

        if entry.isTiny then
            halfH = math.max(halfH, 30)
            halfW = math.max(halfW, 30)
        end

        local boxX = screenPos.X - halfW
        local boxY = screenPos.Y - halfH
        local w    = halfW * 2
        local h    = halfH * 2

        -- Box (skip property writes if values unchanged)
        SetPos2(entry.box, boxX, boxY)
        SetSize2(entry.box, w, h)
        SetVisible(entry.box, cfg.showBox)

        -- Fill
        if cfg.showBox and cfg.fillBox then
            SetPos2(entry.fill, boxX, boxY)
            SetSize2(entry.fill, w, h)
            SetVisible(entry.fill, true)
        else
            SetVisible(entry.fill, false)
        end

        -- Label
        SetPos2(entry.label, screenPos.X, boxY - 16)
        SetVisible(entry.label, cfg.showName)

        -- Distance text — only rebuild string if integer distance changed
        if cfg.showDist then
            local distInt = math.floor(dist3D)
            local distStr = distInt .. " studs"
            SetText(entry.dist, distStr)
            SetPos2(entry.dist, screenPos.X, boxY - 30)
            SetVisible(entry.dist, true)
        else
            SetVisible(entry.dist, false)
        end
    end

    -- Cleanup removed models
    for model, entry in pairs(nextbotDrawings) do
        if not _seen[model] then
            entry.box:Remove()
            entry.fill:Remove()
            entry.label:Remove()
            entry.dist:Remove()
            entry.line:Remove()
            nextbotDrawings[model] = nil
        end
    end
end


-- Forward-declare so color callback in funnies tab can reference it
local coneTriangles = {}

-- ── UILib menu setup ──
UILib:SetMenuTitle("evade")
UILib:SetMenuSize(Vector2.new(580, 420))
UILib:CenterMenu()

-- TAB: Utils
local utilTab     = UILib:Tab("Utils")
local utilSection = utilTab:Section("Bhop")

local _bhopKeyName = (CONFIG.keybinds.bhopKey ~= "none") and CONFIG.keybinds.bhopKey or nil
local _bhopKeyMode = CONFIG.keybinds.bhopMode
local _bhopToggled = false
local _bhopWasHeld = false
local bhopToggle = utilSection:Toggle("Bhop", CONFIG.bhop.enabled, function(v) CONFIG.bhop.enabled = v end)
bhopToggle:AddKeybind((CONFIG.keybinds.bhopKey ~= "none") and CONFIG.keybinds.bhopKey or nil, CONFIG.keybinds.bhopMode, true, function(key, mode)
    _bhopKeyName = key and UILib:_KeyIDToName(key) or nil
    _bhopKeyMode = mode or "Hold"
    CONFIG.keybinds.bhopKey  = _bhopKeyName or "none"
    CONFIG.keybinds.bhopMode = _bhopKeyMode
    _bhopToggled = false
end)

utilSection:Toggle("Auto Strafe", CONFIG.bhop.autoStrafe, function(v) CONFIG.bhop.autoStrafe = v end)
utilSection:Slider("Strafe Sensitivity", CONFIG.bhop.strafeSens,  1,  1,  20,  "px",  function(v) CONFIG.bhop.strafeSens  = v end)
utilSection:Slider("Velocity Threshold",  CONFIG.bhop.velThreshold,  1,  1,  10,  " s/u", function(v) CONFIG.bhop.velThreshold = v end)
utilSection:Slider("Jump Hold Duration",  math.floor(CONFIG.bhop.jumpDelay*1000), 1,  1,  50,  "ms",  function(v) CONFIG.bhop.jumpDelay   = v / 1000 end)
utilSection:Slider("Tick Rate",           math.floor(CONFIG.bhop.tickRate*1000), 1,  1,  50,  "ms",  function(v) CONFIG.bhop.tickRate    = v / 1000 end)

-- TAB: ESP
local espTab    = UILib:Tab("ESP")
local espMain   = espTab:Section("NextBot ESP")
local espStyle  = espTab:Section("Style")
local espColors = espTab:Section("Colors")

espMain:Toggle("NextBot ESP",    CONFIG.nextbotEsp.enabled, function(v) CONFIG.nextbotEsp.enabled  = v; if not v then HideAllESP() end end)
espMain:Toggle("Show Box",       CONFIG.nextbotEsp.showBox,  function(v) CONFIG.nextbotEsp.showBox  = v end)
espMain:Toggle("Show Name",      CONFIG.nextbotEsp.showName,  function(v) CONFIG.nextbotEsp.showName = v end)
espMain:Toggle("Show Distance",  CONFIG.nextbotEsp.showDist,  function(v) CONFIG.nextbotEsp.showDist = v end)
espMain:Toggle("Show Traceline", CONFIG.nextbotEsp.showLine, function(v) CONFIG.nextbotEsp.showLine = v end)
espMain:Toggle("Fill Box",       CONFIG.nextbotEsp.fillBox, function(v) CONFIG.nextbotEsp.fillBox  = v end)

espStyle:Slider("Fill Opacity", math.floor(CONFIG.nextbotEsp.fillOpacity*100),  1,  1,    90,   "%",     function(v) CONFIG.nextbotEsp.fillOpacity = v / 100 end)
espStyle:Slider("Box Thickness", CONFIG.nextbotEsp.thickness,  1,  1,    5,    "px",   function(v) CONFIG.nextbotEsp.thickness   = v end)
espStyle:Slider("Max Distance",  CONFIG.nextbotEsp.maxDist, 50, 50, 2000,  " studs", function(v) CONFIG.nextbotEsp.maxDist     = v end)
espStyle:Slider("Min Box Size",  CONFIG.nextbotEsp.minBoxSize,  5,  5,  100,   "px",   function(v) CONFIG.nextbotEsp.minBoxSize  = v end)

local colorPresets = {"Red", "Orange", "Yellow", "Green", "Cyan", "Blue", "Purple", "White", "Pink"}
local colorValues  = {
    Red    = Color3.fromRGB(255, 60,  60),
    Orange = Color3.fromRGB(255, 140,  0),
    Yellow = Color3.fromRGB(255, 220,  0),
    Green  = Color3.fromRGB( 60, 255, 60),
    Cyan   = Color3.fromRGB(  0, 220, 255),
    Blue   = Color3.fromRGB( 60, 100, 255),
    Purple = Color3.fromRGB(180,  60, 255),
    White  = Color3.fromRGB(255, 255, 255),
    Pink   = Color3.fromRGB(255, 100, 180),
}

espColors:Dropdown("Box Color",       {CONFIG.ui.boxColor},    colorPresets, false, function(v)
    CONFIG.ui.boxColor = v[1]
    CONFIG.nextbotEsp.boxColor = colorValues[v[1]]
    for _, e in pairs(nextbotDrawings) do e.box.Color = colorValues[v[1]]; e.fill.Color = colorValues[v[1]]; e.line.Color = colorValues[v[1]] end
end)
espColors:Dropdown("Name Color",      {CONFIG.ui.nameColor},  colorPresets, false, function(v)
    CONFIG.ui.nameColor = v[1]
    CONFIG.nextbotEsp.nameColor = colorValues[v[1]]
    for _, e in pairs(nextbotDrawings) do e.label.Color = colorValues[v[1]] end
end)
espColors:Dropdown("Distance Color",  {CONFIG.ui.distColor}, colorPresets, false, function(v)
    CONFIG.ui.distColor = v[1]
    CONFIG.nextbotEsp.distColor = colorValues[v[1]]
    for _, e in pairs(nextbotDrawings) do e.dist.Color = colorValues[v[1]] end
end)
espColors:Dropdown("Traceline Color", {CONFIG.ui.lineColor},    colorPresets, false, function(v)
    CONFIG.ui.lineColor = v[1]
    CONFIG.nextbotEsp.lineColor = colorValues[v[1]]
    for _, e in pairs(nextbotDrawings) do e.line.Color = colorValues[v[1]] end
end)

-- TAB: Funnies
local funniesTab    = UILib:Tab("Funnies")
local coneSection   = funniesTab:Section("Cone Hat")
local coneStyle     = funniesTab:Section("Cone Style")
local velSection    = funniesTab:Section("Velocity Indicator")
local chSection     = funniesTab:Section("Crosshair")
local chStyle       = funniesTab:Section("Crosshair Style")
local dodgeSection  = funniesTab:Section("Bot Dodge")
local dodgeSettings = funniesTab:Section("Bot Dodge Settings")
local miscSection   = funniesTab:Section("Misc")
local miscSettings  = funniesTab:Section("Misc Settings")

coneSection:Toggle("Cone Hat", CONFIG.coneHat.enabled, function(v) CONFIG.coneHat.enabled = v end)

coneStyle:Slider("FPS",      CONFIG.coneHat.fps, 5,  10, 120, " fps", function(v) CONFIG.coneHat.fps      = v end)
coneStyle:Slider("Segments", CONFIG.coneHat.segments, 2,  6,  48,  "",     function(v) CONFIG.coneHat.segments  = v end)
coneStyle:Slider("Radius",   math.floor(CONFIG.coneHat.radius*10), 1,  5,  50,  "",     function(v) CONFIG.coneHat.radius    = v / 10 end)
coneStyle:Slider("Height",   math.floor(CONFIG.coneHat.height*10), 1,  5,  50,  "",     function(v) CONFIG.coneHat.height    = v / 10 end)
coneStyle:Slider("Y Offset",  math.floor(CONFIG.coneHat.yOffset*10), 1,  0,  30,  "",     function(v) CONFIG.coneHat.yOffset   = v / 10 end)
coneStyle:Slider("Z Index",   CONFIG.coneHat.zindex, 1,  1,  10,  "",     function(v) CONFIG.coneHat.zindex    = v end)

local coneColorPresets = {"Black", "Red", "Orange", "Yellow", "Green", "Cyan", "Blue", "Purple", "White", "Pink"}
local coneColorValues  = {
    Black  = Color3.fromRGB(  0,   0,   0),
    Red    = Color3.fromRGB(255,  60,  60),
    Orange = Color3.fromRGB(255, 140,   0),
    Yellow = Color3.fromRGB(255, 220,   0),
    Green  = Color3.fromRGB( 60, 255,  60),
    Cyan   = Color3.fromRGB(  0, 220, 255),
    Blue   = Color3.fromRGB( 60, 100, 255),
    Purple = Color3.fromRGB(180,  60, 255),
    White  = Color3.fromRGB(255, 255, 255),
    Pink   = Color3.fromRGB(255, 100, 180),
}
coneStyle:Dropdown("Hat Color", {CONFIG.ui.hatColor}, coneColorPresets, false, function(v)
    CONFIG.ui.hatColor = v[1]
    CONFIG.coneHat.color = coneColorValues[v[1]]
    for _, tri in ipairs(coneTriangles) do tri.Color = coneColorValues[v[1]] end
end)

dodgeSection:Toggle("Bot Dodge", CONFIG.botDodge.enabled, function(v)
    CONFIG.botDodge.enabled = v
end)
dodgeSettings:Slider("Trigger Radius", CONFIG.botDodge.radius,    1,  5, 100, " studs", function(v) CONFIG.botDodge.radius    = v end)
dodgeSettings:Slider("Dodge Distance", CONFIG.botDodge.dodgeDist, 1,  1,  50, " studs", function(v) CONFIG.botDodge.dodgeDist = v end)
dodgeSettings:Slider("Cooldown",       math.floor(CONFIG.botDodge.cooldown * 10), 1, 1, 50, "00ms", function(v) CONFIG.botDodge.cooldown = v / 10 end)

velSection:Toggle("Vel. Indicator", CONFIG.velIndicator.enabled, function(v)
    CONFIG.velIndicator.enabled = v
    if not v then
        for _, ln in pairs(_velDrawings) do ln.Visible = false end
    end
end)

-- Crosshair
chSection:Toggle("Crosshair", CONFIG.crosshair.enabled, function(v)
    CONFIG.crosshair.enabled = v
    if not v then _crosshairClear() end
end)
chSection:Dropdown("Style", {CONFIG.ui.crosshairStyle}, {"Dot", "Cross", "Circle"}, false, function(v)
    CONFIG.ui.crosshairStyle = v[1]
    CONFIG.crosshair.style = v[1]
end)

local chColorPresets = {"White", "Red", "Orange", "Yellow", "Green", "Cyan", "Blue", "Purple", "Pink", "Black"}
local chColorValues  = {
    White  = Color3.fromRGB(255, 255, 255),
    Red    = Color3.fromRGB(255,  60,  60),
    Orange = Color3.fromRGB(255, 140,   0),
    Yellow = Color3.fromRGB(255, 220,   0),
    Green  = Color3.fromRGB( 60, 255,  60),
    Cyan   = Color3.fromRGB(  0, 220, 255),
    Blue   = Color3.fromRGB( 60, 100, 255),
    Purple = Color3.fromRGB(180,  60, 255),
    Pink   = Color3.fromRGB(255, 100, 180),
    Black  = Color3.fromRGB(  0,   0,   0),
}
chSection:Dropdown("Color", {CONFIG.ui.crosshairColor}, chColorPresets, false, function(v)
    CONFIG.ui.crosshairColor = v[1]
    CONFIG.crosshair.color = chColorValues[v[1]]
end)

chStyle:Slider("Size",      CONFIG.crosshair.size, 1,  1, 40, "px", function(v) CONFIG.crosshair.size      = v end)
chStyle:Slider("Gap",       CONFIG.crosshair.gap, 1,  0, 20, "px", function(v) CONFIG.crosshair.gap       = v end)
chStyle:Slider("Thickness", CONFIG.crosshair.thickness, 1,  1, 5,  "px", function(v) CONFIG.crosshair.thickness = v end)

-- Misc toggles
local noclipToggle = miscSection:Toggle("Noclip",     CONFIG.noclip.enabled, function(v) CONFIG.noclip.enabled    = v end)
noclipToggle:AddKeybind((CONFIG.keybinds.noclipKey ~= "none") and CONFIG.keybinds.noclipKey or nil, CONFIG.keybinds.noclipMode, true, function(key, mode)
    _noclipKeyName = key and UILib:_KeyIDToName(key) or nil
    _noclipKeyMode = mode or "Hold"
    CONFIG.keybinds.noclipKey  = _noclipKeyName or "none"
    CONFIG.keybinds.noclipMode = _noclipKeyMode
    _noclipToggled = false
end)
local flyToggle  = miscSection:Toggle("Fly",       CONFIG.fly.enabled, function(v) CONFIG.fly.enabled      = v end)
flyToggle:AddKeybind((CONFIG.keybinds.flyKey ~= "none") and CONFIG.keybinds.flyKey or nil, CONFIG.keybinds.flyMode, true, function(key, mode)
    _flyKeyName = key and UILib:_KeyIDToName(key) or nil
    _flyKeyMode = mode or "Hold"
    CONFIG.keybinds.flyKey  = _flyKeyName or "none"
    CONFIG.keybinds.flyMode = _flyKeyMode
    _flyToggled = false
end)
local hjToggle   = miscSection:Toggle("High Jump", CONFIG.highJump.enabled, function(v) CONFIG.highJump.enabled  = v end)
hjToggle:AddKeybind((CONFIG.keybinds.highJumpKey ~= "none") and CONFIG.keybinds.highJumpKey or nil, CONFIG.keybinds.highJumpMode, true, function(key, mode)
    _hjKeyName = key and UILib:_KeyIDToName(key) or nil
    _hjKeyMode = mode or "Hold"
    CONFIG.keybinds.highJumpKey  = _hjKeyName or "none"
    CONFIG.keybinds.highJumpMode = _hjKeyMode
    _hjToggled = false
end)
miscSection:Toggle("Anti-Void", CONFIG.antiVoid.enabled, function(v) CONFIG.antiVoid.enabled   = v end)

miscSettings:Slider("Fly Speed",      CONFIG.fly.speed, 5,   5,  200, " s/u", function(v) CONFIG.fly.speed          = v end)
miscSettings:Slider("Jump Force",     CONFIG.highJump.force, 5,  20,  300, "",     function(v) CONFIG.highJump.force      = v end)
miscSettings:Slider("Void Threshold", CONFIG.antiVoid.threshold, 10, -500, -10, "", function(v) CONFIG.antiVoid.threshold  = v end)
miscSettings:Slider("Safe Y",         CONFIG.antiVoid.safeY, 1,   1,  500, "",     function(v) CONFIG.antiVoid.safeY      = v end)

-- TAB: Autofarm
local farmTab  = UILib:Tab("Autofarm")
local farmMain = farmTab:Section("Farm Settings")
local farmPos  = farmTab:Section("Sky Position")

farmMain:Toggle("Auto Farm",       CONFIG.autofarm.enabled, function(v) CONFIG.autofarm.enabled       = v end)
farmMain:Slider("Collect Time",      math.floor(CONFIG.autofarm.collectionTime*10), 1,   1,  30, "00ms",  function(v) CONFIG.autofarm.collectionTime = v / 10 end)
farmMain:Slider("Scan Cooldown",     math.floor(CONFIG.autofarm.safetyInterval*10), 1,   1,  20, "00ms",  function(v) CONFIG.autofarm.safetyInterval = v / 10 end)
farmMain:Toggle("Bot Safety Check", CONFIG.autofarm.safetyEnabled,  function(v) CONFIG.autofarm.safetyEnabled  = v end)
farmMain:Slider("Safe Radius",      CONFIG.autofarm.safeRadius, 5,  10, 150, " studs", function(v) CONFIG.autofarm.safeRadius     = v end)
farmMain:Slider("Bot Retry Delay",   CONFIG.autofarm.botRetryDelay, 1,   1,  10, "s",     function(v) CONFIG.autofarm.botRetryDelay  = v end)

farmPos:Slider("Sky X",  math.floor(CONFIG.autofarm.skyX), 1, -2000, 2000, "", function(v) CONFIG.autofarm.skyX = v end)
farmPos:Slider("Sky Y",  math.floor(CONFIG.autofarm.skyY), 5,  100, 2000, "", function(v) CONFIG.autofarm.skyY = v end)
farmPos:Slider("Sky Z",  math.floor(CONFIG.autofarm.skyZ), 1, -2000, 2000, "", function(v) CONFIG.autofarm.skyZ = v end)

-- TAB: Settings — created before Credits so Credits appears last
local shouldDie = false
local _, menuSection = UILib:CreateSettingsTab("Settings")

-- Default theme: Neverlose
UILib._theming.accent   = Color3.fromRGB(77,  166, 255)
UILib._theming.body     = Color3.fromRGB(10,  13,  20)
UILib._theming.text     = Color3.fromRGB(220, 228, 240)
UILib._theming.subtext  = Color3.fromRGB(90,  105, 130)
UILib._theming.border1  = Color3.fromRGB(35,  45,  65)
UILib._theming.border0  = Color3.fromRGB(25,  32,  50)
UILib._theming.surface1 = Color3.fromRGB(22,  28,  42)
UILib._theming.surface0 = Color3.fromRGB(15,  19,  30)
UILib._theming.crust    = Color3.fromRGB(5,   7,   12)

menuSection:Button("Unload", function() shouldDie = true end)

-- TAB: Credits — created last so it appears after Settings in the sidebar
local credTab = UILib:Tab("Credits")
local credSec = credTab:Section("About")
credSec:Button("UI - UILib",               function() end)
credSec:Button("Dev - Jay",                function() end)
credSec:Button("Cone Hat - crayonskidder", function() end)
credSec:Button("Vel. Indicator - starryskidder", function() end)

UILib:Notification("Loaded! Press F1 to toggle.", 5)


local MAX_SEGS = 48

-- Pre-allocate all triangles once
for i = 1, MAX_SEGS do
    local t   = Drawing.new("Triangle")
    t.Filled  = true
    t.Visible = false
    t.ZIndex  = CONFIG.coneHat.zindex
    t.Color   = CONFIG.coneHat.color
    coneTriangles[i] = t
end

-- Precomputed sin/cos ring table, rebuilt only when segment count changes
local _coneRingSin    = {}
local _coneRingCos    = {}
local _coneLastSegs   = 0
local _coneLastColor  = nil
local _coneLastZIndex = -1
local _coneLastRadius = -1  -- trigger first rebuild
local _coneLastVis    = {}  -- track per-tri visible state to skip redundant writes

local function RebuildRingTable(segs)
    for i = 1, segs do
        local a = ((i - 1) / segs) * math.pi * 2
        _coneRingSin[i] = math.sin(a)
        _coneRingCos[i] = math.cos(a)
    end
    _coneLastSegs = segs
end

local function hideConeTris(n)
    for i = 1, n or MAX_SEGS do
        local tri = coneTriangles[i]
        if tri and _coneLastVis[i] ~= false then
            tri.Visible   = false
            _coneLastVis[i] = false
        end
    end
end

local function drawConeHat(hx, hy, hz)
    local cfg  = CONFIG.coneHat
    local segs = cfg.segments

    -- Rebuild sin/cos table only when segment count changes
    if segs ~= _coneLastSegs then
        RebuildRingTable(segs)
        -- Hide extras if segments reduced
        for i = segs + 1, MAX_SEGS do
            local tri = coneTriangles[i]
            if _coneLastVis[i] ~= false then
                tri.Visible     = false
                _coneLastVis[i] = false
            end
        end
    end

    -- Apply color/zindex to all tris only when config changed (not every frame)
    local col = cfg.color
    local zi  = cfg.zindex
    if col ~= _coneLastColor or zi ~= _coneLastZIndex then
        for i = 1, MAX_SEGS do
            coneTriangles[i].Color  = col
            coneTriangles[i].ZIndex = zi
        end
        _coneLastColor  = col
        _coneLastZIndex = zi
    end

    -- Single WorldToScreen for apex
    local apexY          = hy + cfg.yOffset + cfg.height
    local apex, apexOn   = WorldToScreen(Vector3.new(hx, apexY, hz))
    local apexX2         = apex.X
    local apexY2         = apex.Y

    -- Precompute all base ring screen positions (one WorldToScreen per point)
    -- We reuse a flat array to avoid table alloc: sx[i], sy[i], on[i]
    local baseY = hy + cfg.yOffset
    local rad   = cfg.radius
    local sx    = {}
    local sy    = {}
    local son   = {}
    for i = 1, segs do
        local sp, on = WorldToScreen(Vector3.new(
            hx + _coneRingCos[i] * rad,
            baseY,
            hz + _coneRingSin[i] * rad
        ))
        sx[i]  = sp.X
        sy[i]  = sp.Y
        son[i] = on
    end

    -- Draw triangles: apex → base[i] → base[i+1]
    for i = 1, segs do
        local ni  = (i % segs) + 1
        local tri = coneTriangles[i]
        if apexOn and (son[i] or son[ni]) then
            tri.PointA = Vector2.new(apexX2,  apexY2)
            tri.PointB = Vector2.new(sx[i],   sy[i])
            tri.PointC = Vector2.new(sx[ni],  sy[ni])
            if _coneLastVis[i] ~= true then
                tri.Visible     = true
                _coneLastVis[i] = true
            end
        else
            if _coneLastVis[i] ~= false then
                tri.Visible     = false
                _coneLastVis[i] = false
            end
        end
    end
end

-- Use RunService VM's RenderStepped for smooth per-frame hat updates.
-- The VM fires every task.wait() tick so it's as close to frame-rate as Matcha allows.
local _hatFrameCounter = 0

RunService.RenderStepped:Connect(function()
    if shouldDie then return end

    local cfg = CONFIG.coneHat
    if not cfg.enabled then
        hideConeTris(cfg.segments)
        return
    end

    -- Frame skip so FPS slider still works: 60fps=every frame, 30fps=every 2nd, etc.
    local skip = cfg.fps == 0 and 0 or math.max(0, math.floor(60 / cfg.fps) - 1)
    _hatFrameCounter = _hatFrameCounter + 1
    if _hatFrameCounter <= skip then return end
    _hatFrameCounter = 0

    local char = player.Character
    local head = char and char:FindFirstChild("Head")
    if not head then
        hideConeTris(cfg.segments)
        return
    end

    local p = head.Position
    drawConeHat(p.X, p.Y, p.Z)
end)


local KEY_W = 0x57
local KEY_A = 0x41
local KEY_D = 0x44

local _strafeLeft  = false
local _strafeRight = false
local _strafeW     = false
local _lastCamAngle = 0

local function ReleaseStrafeKeys()
    if _strafeLeft  then keyrelease(KEY_A) _strafeLeft  = false end
    if _strafeRight then keyrelease(KEY_D) _strafeRight = false end
    if _strafeW     then keyrelease(KEY_W) _strafeW     = false end
end

spawn(function()
    while not shouldDie do
        local cfg = CONFIG.bhop
        local active = false
        if _bhopKeyMode == "Always" then
            active = true
        elseif _bhopKeyName then
            local held = UILib._inputs[_bhopKeyName] and UILib._inputs[_bhopKeyName].held
            if _bhopKeyMode == "Toggle" then
                if held and not _bhopWasHeld then _bhopToggled = not _bhopToggled end
                _bhopWasHeld = held
                active = _bhopToggled
            else
                active = held
            end
        end
        if cfg.enabled and active then
            local character = player.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    -- Bhop jump
                    local velY = rootPart.Velocity.Y
                    local t    = cfg.velThreshold
                    if velY > -t and velY < t then
                        keypress(SPACE)
                        task.wait(cfg.jumpDelay)
                        keyrelease(SPACE)
                    end

                    -- Auto strafe
                    if cfg.autoStrafe then
                        -- Matcha only exposes camera.Position, not CFrame/LookVector.
                        -- Derive yaw by computing angle from root → camera on the XZ plane.
                        local camPos  = camera.Position
                        local rootPos = rootPart.Position
                        local dx      = camPos.X - rootPos.X
                        local dz      = camPos.Z - rootPos.Z
                        local currentAngle = math.atan2(dx, dz)

                        local deltaAngle = currentAngle - _lastCamAngle
                        -- Wrap around ±pi boundary
                        if deltaAngle >  math.pi then deltaAngle = deltaAngle - math.pi * 2 end
                        if deltaAngle < -math.pi then deltaAngle = deltaAngle + math.pi * 2 end
                        _lastCamAngle = currentAngle

                        -- threshold in radians; sens 1-20 maps to 0.001-0.020
                        local threshold = cfg.strafeSens * 0.001

                        -- Always hold W
                        if not _strafeW then
                            keypress(KEY_W)
                            _strafeW = true
                        end

                        -- A/D based on camera yaw delta since last tick
                        if deltaAngle > threshold then
                            -- Camera swung right → strafe D
                            if _strafeLeft  then keyrelease(KEY_A) _strafeLeft  = false end
                            if not _strafeRight then keypress(KEY_D) _strafeRight = true end
                        elseif deltaAngle < -threshold then
                            -- Camera swung left → strafe A
                            if _strafeRight then keyrelease(KEY_D) _strafeRight = false end
                            if not _strafeLeft then keypress(KEY_A) _strafeLeft = true end
                        else
                            -- Not turning → release A and D
                            if _strafeLeft  then keyrelease(KEY_A) _strafeLeft  = false end
                            if _strafeRight then keyrelease(KEY_D) _strafeRight = false end
                        end
                    else
                        ReleaseStrafeKeys()
                    end
                end
            end
        else
            ReleaseStrafeKeys()
        end
        task.wait(cfg.tickRate)
    end
    ReleaseStrafeKeys()
end)


local _farmRecolecting = false
local _farmWaiting     = false

spawn(function()
    repeat task.wait(0.5) until workspace:FindFirstChild("Game")

    while not shouldDie do
        if not CONFIG.autofarm.enabled then
            _farmRecolecting = false
            _farmWaiting     = false
            task.wait(0.5)
        else
            local cfg  = CONFIG.autofarm
            local char = player.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")

            if hrp then
                -- Find tickets folder
                local gameFolder    = workspace:FindFirstChild("Game")
                local effects       = gameFolder and gameFolder:FindFirstChild("Effects")
                local ticketsFolder = effects and effects:FindFirstChild("Tickets")

                local currentTickets = {}
                if ticketsFolder then
                    for _, t in ipairs(ticketsFolder:GetChildren()) do
                        local mover = t:FindFirstChild("Mover")
                        if mover and mover:IsA("BasePart") then
                            table.insert(currentTickets, mover)
                        end
                    end
                end

                if #currentTickets > 0 then
                    -- Tickets found — check each one for nearby bots before collecting
                    _farmRecolecting = true
                    _farmWaiting     = false

                    for _, mover in ipairs(currentTickets) do
                        if not CONFIG.autofarm.enabled then break end
                        if not (mover and mover.Parent) then continue end

                        -- Bot safety check per ticket
                        local ticketSafe = true
                        if cfg.safetyEnabled then
                            local pf = (function()
                                local g = workspace:FindFirstChild("Game")
                                return g and g:FindFirstChild("Players")
                            end)()
                            if pf then
                                local tp = mover.Position
                                for _, botModel in pairs(pf:GetChildren()) do
                                    if botModel:IsA("Model") then
                                        -- Nextbots use Hitbox or HumanoidRootPart
                                        local hitbox = botModel:FindFirstChild("Hitbox") or botModel:FindFirstChild("HumanoidRootPart")
                                        if hitbox then
                                            local bp = botModel:FindFirstChild("HumanoidRootPart")
                                            if bp then
                                                local bpos = bp.Position
                                                local dx = tp.X - bpos.X
                                                local dy = tp.Y - bpos.Y
                                                local dz = tp.Z - bpos.Z
                                                if math.sqrt(dx*dx + dy*dy + dz*dz) <= cfg.safeRadius then
                                                    ticketSafe = false
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        if not ticketSafe then
                            -- Bot too close — go to sky and wait before retrying
                            pcall(function()
                                local char2 = player.Character
                                local hrp2  = char2 and char2:FindFirstChild("HumanoidRootPart")
                                if hrp2 then
                                    hrp2.Position = Vector3.new(cfg.skyX, cfg.skyY, cfg.skyZ)
                                    hrp2.Velocity = Vector3.new(0, 0, 0)
                                end
                            end)
                            task.wait(cfg.botRetryDelay)
                        else
                            pcall(function()
                                local char2 = player.Character
                                local hrp2  = char2 and char2:FindFirstChild("HumanoidRootPart")
                                if hrp2 then
                                    hrp2.Position = mover.Position + Vector3.new(0, -10, 0)
                                    task.wait(cfg.collectionTime)
                                end
                            end)
                        end
                    end
                else
                    -- No tickets — return to sky position
                    _farmRecolecting = false
                    _farmWaiting     = true

                    pcall(function()
                        local char2 = player.Character
                        local hrp2  = char2 and char2:FindFirstChild("HumanoidRootPart")
                        if hrp2 then
                            hrp2.Position = Vector3.new(cfg.skyX, cfg.skyY, cfg.skyZ)
                            hrp2.Velocity = Vector3.new(0, 0, 0)
                        end
                    end)
                end

                task.wait(_farmRecolecting and cfg.safetyInterval or 0.1)
            else
                task.wait(0.5)
            end
        end
    end
end)

-- NextBot ESP is updated in the main loop below


while not shouldDie do
    if CONFIG.nextbotEsp.enabled and not UILib._menu_open then
        UpdateNextbotESP()
    end
    _velUpdate()
    _crosshairUpdate()
    _flyUpdate()
    _highJumpUpdate()
    _antiVoidUpdate()
    _botDodgeUpdate()
    UILib:Step()
    task.wait()
end

ClearAllNextbotESP()
_velClearAll()
_crosshairClear()
ESP.destroyAll()
UILib:Unload()
setrobloxinput(true)

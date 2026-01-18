--[[

Palette is linked to the sprite's layer colors. Foreground color changes with selected layer.

]]
local M = {
    _VERSION = "1.0.0",
    _DESCRIPTION = [[
    
    Palette is linked to the sprite's layer colors. Foreground color changes with selected layer.
    
    ]],
    _URL = "https://github.com/xharris/ase_layer_color_as_palette",
    _LICENSE = [[
    MIT License

    Copyright (c) 2025 xharris

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
    ]]
}

local enabled = true


local set_cels_to_layer_color = function(layer)
    -- update pixels in cel
    local layer_pc = app.pixelColor.rgba(
        layer.color.red,
        layer.color.green,
        layer.color.blue,
        layer.color.alpha
    )
    app.transaction(function()
        for _, cel in ipairs(layer.cels) do
            local img = cel.image
            for it in img:pixels() do
                local color = it()
                if app.pixelColor.rgbaA(color) > 0 then
                    it(layer_pc)
                end
            end
            cel.image = img
        end
    end)
end

local set_palette_to_layer_colors = function(sprite)
    local palette = sprite.palettes[1]
    palette:resize(#app.sprite.layers+1)
    palette:setColor(Color{r=0, g=0, b=0, a=0})
    for i, layer in ipairs(app.sprite.layers) do
        palette:setColor(i, layer.color)
    end
end

local set_fg_to_layer_color = function(layer)
    app.fgColor = layer.color
end

local export_layers = function()
    app.alert("Export!")
end

local dlg = Dialog{id="layer_color_as_palette", title="Layer Colors As Palette"}
dlg:label{label="Note: Set 'Sprite > Color Mode' to 'RGB Color'"}
dlg:check{id='enabled', label='Enabled', selected=enabled}
-- dlg:button{id='export', text='Export Layers', onclick=export_layers}
dlg:show{wait=false}

local refresh = function (ev)
    if not dlg.data.enabled then
        return
    end
    if ev and ev.name and string.find(ev.name, "Save") then
        return
    end
    if app.sprite then
        for _, layer in ipairs(app.sprite.layers) do
            set_cels_to_layer_color(layer)
        end
    end
    if app.sprite then
        set_palette_to_layer_colors(app.sprite)
    end
    if app.layer then
        set_fg_to_layer_color(app.layer)
    end
    app.refresh()
end

app.events:off(refresh)

app.events:on('sitechange', refresh)
app.events:on('aftercommand', refresh)

refresh()

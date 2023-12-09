-- TODO: REMOVE ALL THIS STUFF AS MENUAPI/REDEMTP_MENU_BASE WILL NOT BE NEEDED.
FeatherMenu = exports['feather-menu'].initiate()
local FirstName = ''
local LastName = ''
local MyMenu = FeatherMenu:RegisterMenu('feather:character:menu', {
    top = '40%',
    left = '20%',
    ['720width'] = '500px',
    ['1080width'] = '600px',
    ['2kwidth'] = '700px',
    ['4kwidth'] = '900px',
    style = {
        -- ['height'] = '500px'
        -- ['border'] = '5px solid white',
        -- ['background-image'] = 'none',
        -- ['background-color'] = '#515A5A'
    },
    contentslot = {
        style = { --This style is what is currently making the content slot scoped and scrollable. If you delete this, it will make the content height dynamic to its inner content.
            ['height'] = '500px',
            ['min-height'] = '500px'
        }
    },
    draggable = true,
    canclose = true
})
local MainCharacterPage, ClothingCategoriesPage, UpperClothingPage, LowerClothingPage, AccClothingPage =
    MyMenu:RegisterPage('first:page'), MyMenu:RegisterPage('second:page'), MyMenu:RegisterPage('third:page'),
    MyMenu:RegisterPage('fourth:page'), MyMenu:RegisterPage('fifth:page')
local ClothingCategories, Model, MenuOpened = nil, 'mp_male', false

local SelectedClothing = {}         -- This can keep track of what was selected data wise
local SelectedClothingElements = {} --This table keeps track of your clothing elements
if IsPedMale(PlayerPedId()) then
    ClothingCategories = CharacterConfig.Clothing.Clothes.Male
else
    ClothingCategories = CharacterConfig.Clothing.Clothes.Female
end

RegisterCommand('test', function()
    if Header1 and SubHeader1 then
        Header1:unRegister()
        SubHeader1:unRegister()
    end
    Header1 = MainCharacterPage:RegisterElement('header', {
        value = 'My First Menu',
        slot = "header",
        style = {}
    })
    SubHeader1 = MainCharacterPage:RegisterElement('subheader', {
        value = "First Page",
        slot = "header",
        style = {}
    })
    MainCharacterPage:RegisterElement('button', {
        label = 'Customize your Character',
        style = {
        }
    }, function()
        ClothingCategoriesPage:RouteTo()
    end)
    MainCharacterPage:RegisterElement('input', {
        label = "First Name",
        placeholder = "Enter First Name",
        style = {
        }
    }, function(data)
        -- This gets triggered whenever the input value changes
        FirstName = data.value
    end)
    MainCharacterPage:RegisterElement('input', {
        label = "Last Name",
        placeholder = "Enter Last Name",
        style = {
        }
    }, function(data)
        -- This gets triggered whenever the input value changes
        LastName = data.value
    end)
    MainCharacterPage:RegisterElement('input', {
        label = "Birthday",
        placeholder = "Birthday",
        style = {
        }
    }, function(data)
        -- This gets triggered whenever the input value changes
        DOB = data.value
    end)
    MainCharacterPage:RegisterElement('arrows', {
        label = "Gender",
        start = 1,
        options = {
            "Male",
            "Female"
        },
    }, function(data)
        if data.value == "Male" then
            Model = 'mp_male'
        else
            Model = 'mp_female'
        end
        -- This gets triggered whenever the arrow selected value changes
        print(Model)
    end)
    MainCharacterPage:RegisterElement('button', {
        label = "Save Clothing",
        style = {
        }
    }, function()
        print(json.encode(SelectedClothingElements))
        local data = { firstname = FirstName, lastname = LastName, dob = DOB, model = Model }
        TriggerServerEvent('feather-character:SaveCharacterData', data, SelectedClothingElements)
    end)

    --second page
    ClothingCategoriesPage:RegisterElement('header', {
        value = 'Clothing Selection',
        slot = "header",
        style = {}
    })
    ClothingCategoriesPage:RegisterElement('button', {
        label = "Go Back",
        style = {
        },
    }, function()
        MainCharacterPage:RouteTo()
    end)

    for k, v in pairs(ClothingCategories) do
        ClothingCategoriesPage:RegisterElement('button', {
            label = k,
            style = {
            },
        }, function()
            if k == "Upper" then
                ActivePage = UpperClothingPage
                ActivePage:RouteTo()
            elseif k == "Lower" then
                ActivePage = LowerClothingPage
                ActivePage:RouteTo()
            elseif k == "Accessories" then
                ActivePage = AccClothingPage
                ActivePage:RouteTo()
            end
            for index, key in pairs(ClothingCategories[k]) do
                table.insert(SelectedClothing, index)
                if SelectedClothing[index .. 'Category'] == nil then
                    CategoryElement = ActivePage:RegisterElement('slider', {
                        label = index,
                        start = 1,
                        min = 0,
                        max = #key.CategoryData,
                        steps = 1
                    }, function(data)
                        MainComponent = data.value
                        if MainComponent > 0 then
                            SelectedClothing[index .. 'Variant'] = SelectedClothing[index .. 'Variant']:update({
                                label = index .. ' variant',
                                value = 1,
                                max = #key.CategoryData[MainComponent], --#v.CategoryData[inputvalue],
                            })
                            AddComponent(PlayerPedId(), key.CategoryData[MainComponent][1].hash,index)
                            local type = Citizen.InvokeNative(0xEC9A1261BF0CE510, PlayerPedId())
                            ActiveCatagory = Citizen.InvokeNative(0x5FF9A878C3D115B8,
                                key.CategoryData[MainComponent][1].hash, type, true)
                            SelectedClothingElements[index] = key.CategoryData[MainComponent][1].hash
                            print(json.encode(SelectedClothingElements))
                        else
                            Citizen.InvokeNative(0xDF631E4BCE1B1FC4, PlayerPedId(), ActiveCatagory, 0, 0)
                            Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0) -- Refresh PedVariation
                        end
                    end)
                    VariantElement = ActivePage:RegisterElement('slider', {
                        label = index .. ' variant',
                        start = 1,
                        min = 0,
                        max = 5, --#v.CategoryData[inputvalue],
                        steps = 1
                    }, function(data)
                        VariantComponent = data.value
                        if VariantComponent > 0 then
                            SelectedClothing[index .. 'Variant'] = SelectedClothing[index .. 'Variant']:update({
                                label = index .. ' variant',
                                max = #key.CategoryData[MainComponent], --#v.CategoryData[inputvalue],
                            })

                            AddComponent(PlayerPedId(), key.CategoryData[MainComponent][VariantComponent].hash,index)
                            local type = Citizen.InvokeNative(0xEC9A1261BF0CE510, PlayerPedId())
                            ActiveCatagory = Citizen.InvokeNative(0x5FF9A878C3D115B8,
                                key.CategoryData[MainComponent][VariantComponent].hash, type, true)
                            SelectedClothingElements[index] = key.CategoryData[MainComponent][VariantComponent].hash
                            print(json.encode(SelectedClothingElements))
                        else
                            Citizen.InvokeNative(0xDF631E4BCE1B1FC4, PlayerPedId(), ActiveCatagory, 0, 0)
                            Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0) -- Refresh PedVariation
                        end
                    end)

                    -- Store your elements with unique keys so that we can easily retrieve these later when data needs to be updated. We are appenting strings so that it stays unique.
                    SelectedClothing[index .. 'Category'] = CategoryElement
                    SelectedClothing[index .. 'Variant'] = VariantElement
                    CategoryElement = CategoryElement:update({
                        label = index,
                        max = #key.CategoryData, --#v.CategoryData[inputvalue],
                    })

                    VariantElement = VariantElement:update({
                        label = index .. ' variant',
                        max = #key.CategoryData, --#v.CategoryData[inputvalue],
                    })
                end
            end
        end)
    end

    --third page
    UpperClothingPage:RegisterElement('header', {
        value = 'Clothing Selection',
        slot = "header",
        style = {}
    })
    UpperClothingPage:RegisterElement('subheader', {
        value = "These are the items and the variants",
        slot = "header",
        style = {}
    })
    UpperClothingPage:RegisterElement('button', {
        label = "Go Back",
        style = {},
    }, function()
        ClothingCategoriesPage:RouteTo()
    end)
    --fourth page
    LowerClothingPage:RegisterElement('header', {
        value = 'Clothing Selection',
        slot = "header",
        style = {}
    })
    LowerClothingPage:RegisterElement('subheader', {
        value = "These are the items and the variants",
        slot = "header",
        style = {}
    })
    LowerClothingPage:RegisterElement('button', {
        label = "Go Back",
        style = {},
    }, function()
        ClothingCategoriesPage:RouteTo()
    end)

    --fifth page
    AccClothingPage:RegisterElement('header', {
        value = 'Clothing Selection',
        slot = "header",
        style = {}
    })
    AccClothingPage:RegisterElement('subheader', {
        value = "These are the items and the variants",
        slot = "header",
        style = {}
    })
    AccClothingPage:RegisterElement('button', {
        label = "Go Back",
        style = {},
    }, function()
        ClothingCategoriesPage:RouteTo()
    end)

    MyMenu:Open({
        cursorFocus = true,
        menuFocus = true,
        startupPage = MainCharacterPage,
    })
end)

RegisterNetEvent('FeatherMenu:closed', function(data)
    MenuOpened = false
    Header1:unRegister()
    SubHeader1:unRegister()
    print(MenuOpened)
end)


function TableToString(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. TableToString(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

--[[MenuData = {}
TriggerEvent("redemrp_menu_base:getData", function(call)
    MenuData = call
end)

RegisterNetEvent('redemrp_menu_base:updateSelectedItem')
AddEventHandler('redemrp_menu_base:updateSelectedItem', function(selectedItem)
    MenuData.ItemSelected = selectedItem
end)


function MakeupMenu()
    MenuData.CloseAll()
    local elements = {}
    for k, v in pairs(CharacterConfig.Attributes.OverlayAllLayers) do
        elements[#elements + 1] = {
            label = v.name,
        }
    end


    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',

        {
            title = 'Makeup Categories',
            align = Config.MenuAlign,
            elements = elements,
        },
        function(data, menu)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current then
                OpenMakeupMenu(data.current.label)
            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end

function OpenMakeupMenu(table)
    local selection = table
    MenuData.CloseAll()
    local elements = {}
    print(selection)

    -- *texture
    elements[#elements + 1] = {
        label = CharacterConfig.Attributes.OverlayAllLayers[selection].name .. ' ' .. 'Texture',
        value = 1,
        min = 0,
        max = #CharacterConfig.Attributes.Makeup[selection],
        type = "slider",
        texture = value,

        desc = 'Texture',
        tag = "texture"
    }
    elements[#elements + 1] = {
        label = CharacterConfig.Attributes.OverlayAllLayers[selection].name .. ' ' .. 'Opacity',
        value = 1.0,
        min = 0,
        max = 0.9,
        hop = 0.1,
        type = "slider",
        opacity = value,

        desc = 'Opacity',
        tag = "opacity"
    }
    --*Color
    local ColorValue = 0
    for x, color in pairs(CharacterConfig.Attributes.ColorPalettes[selection]) do
        if joaat(color) == CharacterConfig.Attributes.OverlayAllLayers[selection] then
            ColorValue = x
        end
    end

    elements[#elements + 1] = {
        label = CharacterConfig.Attributes.OverlayAllLayers[selection].name .. ' ' .. 'Color',
        value = ColorValue,
        min = 0,
        max = 25,
        comp = CharacterConfig.Attributes.ColorPalettes[selection],
        type = "slider",
        palette = value,

        desc = 'Color',
        tag = "color"
    }

    elements[#elements + 1] = {
        label = CharacterConfig.Attributes.OverlayAllLayers[selection].name .. ' ' .. 'Tint 1',
        value = 0,
        min = 0,
        max = 254,
        comp = CharacterConfig.Attributes.ColorPalettes[selection],
        type = "slider",
        primarytint = value,
        desc = 'Color',
        tag = "color"
    }
    elements[#elements + 1] = {
        label = CharacterConfig.Attributes.OverlayAllLayers[selection].name .. ' ' .. 'Tint 2',
        value = 0,
        min = 0,
        max = 254,
        comp = CharacterConfig.Attributes.ColorPalettes[selection],
        type = "slider",
        secondarytint = value,
        desc = 'Color',
        tag = "color"
    }
    elements[#elements + 1] = {
        label = CharacterConfig.Attributes.OverlayAllLayers[selection].name .. ' ' .. 'Tint 3',
        value = 0,
        min = 0,
        max = 254,
        comp = CharacterConfig.Attributes.ColorPalettes[selection],
        type = "slider",
        tertiarytint = value,

        desc = 'Color',
        tag = "color"
    }
    if selection == "lipsticks" then
        variationvalue = 15
    elseif selection == "shadows" then
        variationvalue = 5
    elseif selection == "eyeliners" then
        variationvalue = 7
    end

    if selection == "lipsticks" or selection == "shadows" or selection == "eyeliners" then
        --*Variant
        elements[#elements + 1] = {
            label = CharacterConfig.Attributes.OverlayAllLayers[selection].name .. ' ' .. 'Variation',
            value = 1,
            min = 0,
            max = variationvalue,
            type = "slider",
            comp = CharacterConfig.Attributes.ColorPalettes[selection],
            variant = value,
            desc = 'variant',
            tag = "variant"
        }
    end

    --* opacity

    elements[#elements + 1] = {
        label = "Add",
    }


    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = "makeup title",
            align = Config.Align,
            elements = elements,
            lastmenu = 'OpenMakeupMenu',

        },

        function(data, menu)
            --* Go back
            if (data.current == "backup") then
                _G[data.trigger](table)
            end
            if data.current.label == "Add" then
                if selection == "blush" then
                    print(elements.texture, data.current.palette, data.current.primarytint, data.current.secondarytint)
                    ChangeOverlay(CharacterConfig.Attributes.OverlayAllLayers[selection].name, 1, data.current.texture, 0, 0, 0, 1.0, 0,
                        data.current.palette, data.current.primarytint, data.current.secondarytint,
                        data.current.tertiarytint, 0, data.current.opacity)
                end
            end
        end, function(data, menu)
            menu.close()
            MakeupMenu()
        end)
end

function ClothingCategories()
    MenuData.CloseAll()
    local Elements = {}

    if IsPedMale(PlayerPedId()) then
        for i, v in pairs(CharacterConfig.Clothing.Clothes.Male) do
            Elements[#Elements + 1] = {
                label = v.CategoryName,
                Clothes = v,
                Category = i,
            }
        end
    else
        for i, v in pairs(CharacterConfig.Clothing.Clothes.Female) do
            Elements[#Elements + 1] = {
                label = v.CategoryName,
                Clothes = v,
                Category = i,
            }
        end
    end

    if IsPedMale then
        ClothingTable = CharacterConfig.Clothing.Clothes.Male
    else
        ClothingTable = CharacterConfig.Clothing.Clothes.Female
    end

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',

        {
            title = 'Male Clothing Categories',
            align = Config.MenuAlign,
            elements = Elements,
        },
        function(data, menu)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.label then
                ClothMenu(data.current, #ClothingTable[data.current.Category])
            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end

function ClothMenu(sentdata, maxamount)
    MenuData.CloseAll()
    local Elements = {
        {
            label = sentdata.label,
            type = 'slider',
            value = 0,
            min = 0,
            max = maxamount,
            -- desc = '',
        },

    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = 'Male Clothing Menu',
            align = Config.MenuAlign,
            elements = Elements,
            lastmenu = 'ClothingCategories',
        },

        function(data, menu)
            if data.current.value == 0 then
                ExecuteCommand('rc')
                menu.setElements(Elements)
                menu.refresh()
            else
                Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(),
                    sentdata.Clothes[tostring(data.current.value)][1].hash, true, true, true)
                Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0)
            end
            if #sentdata.Clothes[tostring(data.current.value)] > 1 then
                local Elements1 = {
                    {
                        label = sentdata.label,
                        type = 'slider',
                        value = data.current.value,
                        min = 0,
                        max = maxamount,
                        -- desc = '',
                    },
                    {
                        label = 'test',
                        type = 'slider',
                        value = 0,
                        min = 0,
                        max = maxamount,
                        -- desc = '',
                    },
                }
                menu.setElements(Elements1)
                menu.refresh()
            end
        end, function(data, menu)
            menu.close()
            ClothingCategories()
        end
    )
end

-- Devmode Area
if Config.DevMode == true then
    -- Open Command
    RegisterCommand('length', function()
        print(json.encode(CharacterConfig.Clothing.Clothes.Male.RingLh))
    end)

    RegisterCommand('clothes', function()
        ClothingCategories()
    end)

    RegisterCommand('makeup', function()
        MakeupMenu()
    end)
end


]]

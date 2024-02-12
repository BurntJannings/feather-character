local ActiveCharacterData = {}

function SaveCharacterDetails(args)
    ActiveCharacterData.firstname = args.data.firstname
    ActiveCharacterData.lastname = args.data.lastname
    ActiveCharacterData.dob = args.data.dob
    ActiveCharacterData.sex = args.data.sex
    ActiveCharacterData.Clothing = {}
    SetSex(ActiveCharacterData.sex)

    -- TODO: Save the current state of character and that its still  in creation. Then have the UI pick back up where it left off.
    if Config.DevMode == false then
        TriggerServerEvent('feather-character:SendDetailsToDB', ActiveCharacterData,
            json.encode(ActiveCharacterData.Clothing))
    end
end

function UpdateCharacterClothing(args)
    local ismale = ActiveCharacterData.sex == 'male'
    DefaultPedSetup(PlayerPedId(), ismale)

    if args.data.primary.id == 0 then
        -- Item removed.
        if ActiveCharacterData.Clothing[args.data.category] ~= nil then
            Citizen.InvokeNative(0x0D7FFA1B2F69ED82, PlayerPedId(),
                ActiveCharacterData.Clothing[args.data.category].variant.hash, 0, 0)
        end
        ActiveCharacterData.Clothing[args.data.category] = nil
    else
        --Remove item before applying the next item
        if ActiveCharacterData.Clothing[args.data.category] ~= nil then
            Citizen.InvokeNative(0x0D7FFA1B2F69ED82, PlayerPedId(),
                ActiveCharacterData.Clothing[args.data.category].variant.hash, 0, 0)
        end

        args.data.variant.hash = tonumber(args.data.variant.hash)

        -- Item added
        ActiveCharacterData.Clothing[args.data.category] = {
            primary = args.data.primary,
            variant = args.data.variant
        }

        Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), args.data.variant.hash, true, true, true)
        Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0) -- Refresh PedVariation
    end

    DefaultPedSetup(PlayerPedId(), ismale)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0) -- Refresh PedVariation
end

function CreateNewCharacter()
    Albedo = (CharacterConfig.General.DefaultChar[Gender][1].HeadTexture[1])
    SetSex('male')
    Wait(500)
    local obj = FeatherCore.Object:Create('p_package09', Config.SpawnCoords.gotocoords.x, Config.SpawnCoords.gotocoords
        .y,
        Config.SpawnCoords.gotocoords.z, 0, true, 'standard')
    local tobj = obj:GetObj()
    SetFocusEntity(PlayerPedId())
    SetEntityAlpha(tobj, 0, true)
    TaskGoToEntity(PlayerPedId(), tobj, 10000, 0.2, 0.8, 1.0, 1)
    Wait(3000)
    DoScreenFadeIn(1000)
    CharacterCamera = StartCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y,
        Config.CameraCoords.creation.z,
        Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
    ToggleUIState()
    while true do
        Wait(0)
        local pcoords = GetEntityCoords(PlayerPedId())
        if GetDistanceBetweenCoords(pcoords.x, pcoords.y, pcoords.z, Config.SpawnCoords.gotocoords.x, Config.SpawnCoords.gotocoords.y,
                Config.SpawnCoords.gotocoords.z, true) < 1.0 then
            TriggerEvent('feather-character:CreateCharacterMenu')
            CreatingCharacter = true
            while CreatingCharacter do
                Wait(0)
                DrawLightWithRange(Config.SpawnCoords.gotocoords.x, Config.SpawnCoords.gotocoords.y-0.5,
                    Config.SpawnCoords.gotocoords.z+1.5, 250, 250, 250, 7.0, 50.0)
            end
            break
        end
    end
end

--------- Net Events ------

RegisterNetEvent('feather-character:CreateNewCharacter', function()
    Spawned = false
    MyMenu:Close({})
    print('Character(s) not found going to new character screen')
    DisplayRadar(false)
    DoScreenFadeOut(500)

    Wait(2000)
    SetEntityCoords(PlayerPedId(), Config.SpawnCoords.creation.x, Config.SpawnCoords.creation.y,
        Config.SpawnCoords.creation.z)
    SetEntityVisible(PlayerPedId(), true)
    FreezeEntityPosition(PlayerPedId(), false)
    CreateNewCharacter()
end)

NightSkybox = NightSkybox or {}
NightSkybox.name = "NightSky"
NightSkybox.directions = {
    "NX",
    "NY",
    "NZ",
    "PX",
    "PY",
    "PZ",
}
NightSkybox.controls = {}
NightSkybox.textures = { 
    -- Credit: ESO/S. Brunier (https://www.eso.org/public/images/eso0932a/)
    -- Ported to cubemap using https://jaxry.github.io/panorama-to-cubemap/
    [1] = "NightSky/images/nx.dds",
    [2] = "NightSky/images/ny.dds",
    [3] = "NightSky/images/nz.dds",
    [4] = "NightSky/images/px.dds",
    [5] = "NightSky/images/py.dds",
    [6] = "NightSky/images/pz.dds",
}
NightSkybox.size = 1500
NightSkybox.faceOffsets = {
    NX = {-NightSkybox.size/2, 0, 0},
    NY = {0, -NightSkybox.size/2, 0},
    NZ = {0, 0, -NightSkybox.size/2},
    PX = { NightSkybox.size/2, 0, 0},
    PY = {0,  NightSkybox.size/2, 0},
    PZ = {0, 0,  NightSkybox.size/2},
}
NightSkybox.faceRotations = {
    NX = {0, -math.pi / 2, 0},
    NY = {math.pi / 2, 0, 0},
    NZ = {0, math.pi, 0},
    PX = {0, math.pi / 2, 0},
    PY = {-math.pi / 2, 0, 0},
    PZ = {0, 0, 0},      
}

NightSkybox.window = GetWindowManager()
function NightSkybox.CreateSkybox()
    EVENT_MANAGER:UnregisterForUpdate(NightSkybox.name .. "Update")
    if not NightSkybox.win then 
        NightSkybox.win = NightSkybox.window:CreateTopLevelWindow("NightSkybox3D")
    end
    NightSkybox.win:SetDrawLayer(DL_BACKGROUND)
    NightSkybox.win:SetDrawTier(DT_LOW)
    NightSkybox.win:SetDrawLevel(0)
    NightSkybox.win:Destroy3DRenderSpace()
    NightSkybox.win:Create3DRenderSpace()
    NightSkybox.win:SetAlpha(0)

    local control
    for i, direction in ipairs(NightSkybox.directions) do 
        if not NightSkybox.controls[i] then 
            control = NightSkybox.window:CreateControl("NightSkybox_"..direction, NightSkybox.win, CT_TEXTURE)
            table.insert(NightSkybox.controls, control)
        end
        control = NightSkybox.controls[i]
        control:SetTexture(NightSkybox.textures[i])
        control:Destroy3DRenderSpace()
        control:Create3DRenderSpace()
        control:Set3DLocalDimensions(NightSkybox.size, NightSkybox.size)
        control:SetDrawLevel(3)
        control:SetColor(1, 1, 1, 1)
        control:Set3DRenderSpaceUsesDepthBuffer(true)
        control:Set3DRenderSpaceOrigin(0, 0, 0)
        control:SetBlendMode(TEX_BLEND_MODE_ADD)
        local direction = NightSkybox.directions[i]
        local offset = NightSkybox.faceOffsets[direction]
        local rotation = NightSkybox.faceRotations[direction]
        control:Set3DRenderSpaceOrigin(offset[1], offset[2], offset[3])
        control:Set3DRenderSpaceOrientation(rotation[1], rotation[2], rotation[3])
    end

    NightSkybox.UpdateSkybox()
    EVENT_MANAGER:RegisterForUpdate(NightSkybox.name .. "Update", 16, NightSkybox.UpdateSkybox)
end

function NightSkybox.UpdateSkybox()
    local pi = math.pi
    local _, x, y, z = GetUnitRawWorldPosition("player")
    local worldX, worldY, worldZ = WorldPositionToGuiRender3DPosition(x, y, z)
    local hours, minutes, seconds = GetLocalTimeOfDay()
    local total_seconds = hours * 3600 + minutes * 60 + seconds
    local float = math.cos(pi * total_seconds / 43200)
    local float_pow = math.pow(float, 5) -- https://www.desmos.com/calculator/6rk1lye11z
    local triangle_wave = 7.272205216643e-05 * total_seconds + pi/2
    NightSkybox.win:Set3DRenderSpaceOrigin(worldX, worldY, worldZ)
    NightSkybox.win:Set3DRenderSpaceOrientation(triangle_wave, -0.8, -pi/8)
    NightSkybox.win:SetAlpha(float_pow)
end

local function OnAddOnLoaded(_, name)
    if name ~= NightSkybox.name then return end
    EVENT_MANAGER:UnregisterForEvent(NightSkybox.name, EVENT_ADD_ON_LOADED)
    NightSkybox.CreateSkybox()
    EVENT_MANAGER:RegisterForEvent(NightSkybox.name, EVENT_PLAYER_ACTIVATED, NightSkybox.CreateSkybox)
end

EVENT_MANAGER:RegisterForEvent(NightSkybox.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

local ffi = ffi or require "ffi"
local C = ffi.C

-- Define system time
local system_time = (function()
    ffi.cdef [[
        typedef struct {
            uint16_t wYear;
            uint16_t wMonth;
            uint16_t wDayOfWeek;
            uint16_t wDay;
            uint16_t wHour;
            uint16_t wMinute;
            uint16_t wSecond;
            uint16_t wMilliseconds;
        } SYSTEMTIME, *PSYSTEMTIME, *LPSYSTEMTIME;
        void GetLocalTime(LPSYSTEMTIME lpSystemTime);
    ]]

    local SYSTEMTIME = ffi.typeof "SYSTEMTIME"
    return function()
        local st = SYSTEMTIME()
        C.GetLocalTime(st)
        return {
            sec = st.wSecond,
            min = st.wMinute,
            hour = st.wHour,
            day = st.wDay,
            month = st.wMonth,
            year = st.wYear,
            wday = st.wDayOfWeek + 1,
            msec = st.wMilliseconds
        }
    end
end)()

local font = draw.CreateFont("verdana", 12)

local function math_round(v)
    return math.modf(v + (v < 0.0 and -.5 or .5))
end

local function renderer_rectangle(x, y, w, h)
    draw.FilledRect(math.floor(x), math.floor(y), math.floor(x + w), math.floor(y + h))
end

-- FPS calculation function
local function getFPS()
    return math.floor(1 / globals.AbsoluteFrameTime()) -- FPS calculation
end

-- Get Player Controllers function (from the library code you provided)
function GetPlayerControllers()
    return entities.FindByClass("CCSPlayerController")
end

-- Get Local Player
function LocalPlayer()
    return entities.GetLocalPlayer()
end

-- Player class to handle player-related methods (using the methods from your library)
function player(ply)
    local self = {}

    -- This function will return the local player's ping
    function self:Ping()
        if not ply then return nil end
        local players = GetPlayerControllers()
        for _, controller in pairs(players) do
            local pawn = controller:GetFieldEntity("m_hPlayerPawn")
            if ply:GetIndex() == pawn:GetIndex() then
                return controller:GetFieldInt("m_iPing") -- Return the ping value
            end
        end
        return 0 -- Default ping if no controller is found
    end

    -- Other methods can be added here if needed, like Health, Armor, etc.

    return self
end

-- Function to get the ping of the local player using the new player class
local function getPing()
    local localPlayer = LocalPlayer() -- Get the local player entity
    if localPlayer then
        -- Create a player object from the provided API and get ping
        local ply = player(localPlayer)
        return ply:Ping() -- Use the Ping function to get the ping
    end
    return 0 -- Return 0 if no valid local player is found
end

-- Register the drawing callback
callbacks.Register("Draw", function()
    draw.SetFont(font)
    
    -- Get system time
    local st = system_time()

    -- Get FPS, Ping, and format the text
    local fps = getFPS()
    local ping = getPing()  -- Get self ping using the player:Ping() method
    local text = ('FPS: %s | Ping: %s ms | User: %s | Time: %s'):format(fps, ping, cheat.GetUserName(), ("%02d:%02d:%02d"):format(st.hour, st.min, st.sec))
    
    local h, w = 18, draw.GetTextSize(text) + 8
    local x, y = draw.GetScreenSize(), 10
    x = x - w - 10

    -- Draw the background for the text
    draw.Color(142, 165, 229, 255)
    renderer_rectangle(x, y, w, 2)
    draw.Color(17, 17, 17, 85)
    renderer_rectangle(x, y + 2, w, h)

    -- Draw the text
    draw.Color(255, 255, 255, 255)
    draw.TextShadow(math_round(x + 4), math_round(y + 7), text)
end)

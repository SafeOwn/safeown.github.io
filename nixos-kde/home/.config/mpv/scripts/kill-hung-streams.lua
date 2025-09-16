-- kill-prev-mpv.lua
-- При запуске закрывает все другие процессы mpv.exe

local mp = require 'mp'
local utils = require 'mp.utils'

local function kill_other_mpv_instances()
    local pid = utils.getpid()
    local res = utils.subprocess({
        args = {"tasklist", "/fi", "imagename eq mpv.exe", "/fo", "csv"},
        capture_stdout = true,
        playback_only = false
    })

    if res.status == 0 and res.stdout then
        for line in res.stdout:gmatch("[^\r\n]+") do
            if line:find("mpv.exe") and not line:find(tostring(pid)) then
                local ppid = line:match('"(%d+)",')
                if ppid then
                    utils.subprocess({
                        args = {"taskkill", "/pid", ppid, "/f"},
                        playback_only = false
                    })
                end
            end
        end
    end
end

-- Запускаем при старте
mp.register_event("start-file", kill_other_mpv_instances)
-- nuclear_auto_next.lua
-- ЯДЕРНЫЙ ВАРИАНТ: запускает таймер СРАЗУ при загрузке скрипта
-- Если через N секунд видео не играет — переключается на следующий файл
-- Работает даже если mpv "завис" на 502 ошибке и не генерирует file-loaded

local mp = require 'mp'
local msg = require 'mp.msg'

msg.info("[NUCLEAR] СКРИПТ ЗАГРУЖЕН")

local TIMEOUT = 8  -- секунд ждать начала воспроизведения
local CHECK_INTERVAL = 2
local timer = nil

-- Функция: переключиться на следующий файл
local function try_next()
local playlist_count = mp.get_property_number("playlist-count", 0)
local current_pos = mp.get_property_number("playlist-pos", -1)

if playlist_count <= 1 then
    msg.warn("[NUCLEAR] Только один файл — некуда переключаться.")
    return false
    end

    if current_pos >= playlist_count - 1 then
        msg.info("[NUCLEAR] Конец плейлиста.")
        return false
        end

        msg.info("[NUCLEAR] ⚡️ ЯДЕРНЫЙ ВАРИАНТ: ПЕРЕКЛЮЧАЮ НА СЛЕДУЮЩИЙ ФАЙЛ")
        mp.command("playlist-next force")
        return true
        end

        -- Функция: проверить состояние воспроизведения
        local function check_playback()
        local core_idle = mp.get_property_bool("core-idle", true)
        local paused_for_cache = mp.get_property_bool("paused-for-cache", false)
        local pause = mp.get_property_bool("pause", false)
        local filename = mp.get_property("filename", "")

        if filename == "" then
            -- Файл ещё не выбран — не трогаем
            return
            end

            if core_idle or paused_for_cache or pause then
                msg.warn("[NUCLEAR] Видео не играет (core-idle/paused) — пробуем переключиться.")
                if try_next() then
                    -- Если переключились — сбрасываем таймер
                    if timer then timer:kill() end
                        timer = mp.add_timeout(TIMEOUT, check_playback)
                        end
                        else
                            -- Воспроизведение идёт — всё хорошо
                            msg.verbose("[NUCLEAR] Воспроизведение идёт — отмена переключения.")
                            end
                            end

                            -- Запускаем таймер сразу при загрузке скрипта
                            timer = mp.add_timeout(TIMEOUT, check_playback)
                            msg.info("[NUCLEAR] 💣 Таймер ядерного переключения запущен на " .. TIMEOUT .. " секунд")

                            -- Также перезапускаем таймер при каждом file-loaded (на всякий случай)
                            mp.register_event("file-loaded", function()
                            if timer then timer:kill() end
                                timer = mp.add_timeout(TIMEOUT, check_playback)
                                msg.verbose("[NUCLEAR] Таймер перезапущен для нового файла")
                                end)

                            -- И при playback-restart
                            mp.register_event("playback-restart", function()
                            if timer then timer:kill() end
                                msg.verbose("[NUCLEAR] Воспроизведение началось — таймер отменён")
                                end)

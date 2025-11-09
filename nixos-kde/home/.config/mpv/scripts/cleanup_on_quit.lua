-- cleanup_on_quit.lua
-- Автоматическая очистка кеша webtorrent и завершение процессов node при выходе из mpv
-- Только если был открыт торрент. Для Linux.

local mp = require 'mp'
local utils = require 'mp.utils'
local msg = require 'mp.msg'

-- --- НАСТРОЙКИ ---
local CACHE_DIR = "$HOME/Downloads/webtorrent"  -- Путь к кешу (должен совпадать с path в webtorrent.conf)
local SCRIPT_NAME = "cleanup_on_quit"

-- --- СОСТОЯНИЕ ---
local webtorrent_was_active = false

-- --- ФУНКЦИЯ: Проверка, был ли открыт торрент ---
local function check_for_webtorrent()
local filename = mp.get_property("stream-open-filename")
if not filename then return end

    if not webtorrent_was_active then
        if filename:match("%.torrent$") or filename:match("^magnet:") then
            webtorrent_was_active = true
            msg.info("[" .. SCRIPT_NAME .. "] Торрент обнаружен — включена очистка при выходе.")
            end
            end
            end

            -- --- ФУНКЦИЯ: Завершить процессы node, связанные с webtorrent ---
            local function kill_webtorrent_processes()
            local log_p = "[" .. SCRIPT_NAME .. "]"
            msg.info(log_p .. " Завершаем процессы node...")

            -- Ищем и убиваем процессы node, в командной строке которых есть 'webtorrent'
            local cmd = "pgrep -f 'node.*webtorrent' | xargs -r kill -9"
            local res = utils.subprocess({
                args = {"bash", "-c", cmd},
                playback_only = false,
                capture_stdout = true,
                capture_stderr = true
            })

            if res.error then
                msg.warn(log_p .. " Ошибка при завершении процессов: " .. tostring(res.error))
                else
                    msg.info(log_p .. " Процессы node завершены.")
                    end
                    end

                    -- --- ФУНКЦИЯ: Очистить директорию кеша ---
                    local function clean_cache()
                    local log_p = "[" .. SCRIPT_NAME .. "]"
                    msg.info(log_p .. " Очищаем кеш: " .. CACHE_DIR)

                    -- Удаляем всё содержимое, но оставляем саму директорию
                    local cmd = string.format("rm -rf %s/* 2>/dev/null; mkdir -p %s", CACHE_DIR, CACHE_DIR)
                    local res = utils.subprocess({
                        args = {"bash", "-c", cmd},
                        playback_only = false,
                        capture_stdout = true,
                        capture_stderr = true
                    })

                    if res.error then
                        msg.error(log_p .. " Ошибка очистки: " .. tostring(res.error))
                        else
                            msg.info(log_p .. " Кеш успешно очищен.")
                            end
                            end

                            -- --- ОСНОВНАЯ ФУНКЦИЯ: Выполнить очистку при shutdown ---
                            local function perform_cleanup()
                            local log_p = "[" .. SCRIPT_NAME .. "]"

                            if webtorrent_was_active then
                                msg.info(log_p .. " === НАЧАЛО ОЧИСТКИ ===")
                                kill_webtorrent_processes()
                                clean_cache()
                                msg.info(log_p .. " === ОЧИСТКА ЗАВЕРШЕНА ===")
                                else
                                    msg.verbose(log_p .. " Webtorrent не использовался — очистка пропущена.")
                                    end
                                    end

                                    -- --- РЕГИСТРАЦИЯ СОБЫТИЙ ---
                                    mp.add_hook("on_load", 50, check_for_webtorrent)   -- Проверяем при каждой загрузке файла
                                    mp.register_event("shutdown", perform_cleanup)      -- Выполняем при выходе из mpv

                                    -- Опционально: ручной запуск по сообщению (можно привязать к клавише в input.conf)
                                    mp.register_script_message("cleanup-now", perform_cleanup)

                                    msg.verbose("[" .. SCRIPT_NAME .. "] Скрипт загружен. Для ручного запуска: script-message cleanup-now")

-- hdr-auto-switch.lua
-- Автоопределение HDR/SDR + ручное управление яркостью/контрастом/насыщенностью

local mp = require 'mp'
local msg = require 'mp.msg'

-- === НАСТРОЙКИ ===
local HDR_SETTINGS = {
    brightness = 5,
    contrast = 10,
    saturation = 50
}

local SDR_SETTINGS = {
    brightness = -2,
    contrast = -10,
    saturation = 50
}

-- Папки и ключевые слова, указывающие на HDR
local HDR_KEYWORDS = {"hdr", "dolby", "dv", "4k", "uhd", "2160p"}
local HDR_FOLDERS = {"HDR", "4K", "UHD", "Dolby"}

-- === ЛОГИКА ОПРЕДЕЛЕНИЯ HDR ===
local function is_hdr()
    local filename = mp.get_property("filename", ""):lower()
    local path = mp.get_property("path", ""):lower()
    local height = mp.get_property_number("height", 0)

    -- 1. Проверка по ключевым словам в имени файла
    for _, keyword in ipairs(HDR_KEYWORDS) do
        if filename:find(keyword, 1, true) then
            msg.verbose("[HDR-Auto] Найдено ключевое слово в имени файла: " .. keyword)
            return true
        end
    end

    -- 2. Проверка по пути
    for _, folder in ipairs(HDR_FOLDERS) do
        if path:find(folder:lower(), 1, true) then
            msg.verbose("[HDR-Auto] Найдено ключевое слово в пути: " .. folder)
            return true
        end
    end

    -- 3. Проверка по разрешению (4K = часто HDR)
    if height >= 2100 then
        msg.verbose("[HDR-Auto] Разрешение >= 2160p, предполагаем HDR")
        return true
    end

    -- 4. Проверка метаданных
    local video_params = mp.get_property_native("video-params", {})
    if video_params then
        -- Проверка primaries
        if video_params["primaries"] == "bt.2020" then
            msg.verbose("[HDR-Auto] Найден primaries=bt.2020")
            return true
        end

        -- Проверка тегов
        local tags = video_params["tags"] or {}
        for _, v in pairs(tags) do
            local tag = tostring(v):lower()
            if tag:find("hdr") or tag:find("dolby") or tag:find("dv") then
                msg.verbose("[HDR-Auto] Найден HDR-тег: " .. tag)
                return true
            end
        end
    end

    return false
end

-- === ПРИМЕНЕНИЕ НАСТРОЕК ===
local function apply_settings(settings, mode_name)
    mp.set_property("brightness", settings.brightness)
    mp.set_property("contrast", settings.contrast)
    mp.set_property("saturation", settings.saturation)
    msg.info("[HDR-Auto] Режим: " .. mode_name .. " | Яркость: " .. settings.brightness ..
             " | Контраст: " .. settings.contrast .. " | Насыщенность: " .. settings.saturation)
    mp.osd_message("Режим: " .. mode_name, 2)
end

-- === ФУНКЦИИ ДЛЯ ГОРЯЧИХ КЛАВИШ ===
local function set_hdr_mode()
    apply_settings(HDR_SETTINGS, "HDR")
end

local function set_sdr_mode()
    apply_settings(SDR_SETTINGS, "SDR")
end

local function toggle_mode()
    local current = mp.get_property_number("brightness", 0)
    if current == HDR_SETTINGS.brightness then
        set_sdr_mode()
    else
        set_hdr_mode()
    end
end

-- === АВТОПРИМЕНЕНИЕ ПРИ ЗАГРУЗКЕ ===
local function on_file_loaded()
    if is_hdr() then
        set_hdr_mode()
    else
        set_sdr_mode()
    end
end

-- === РЕГИСТРАЦИЯ ===
mp.register_event("file-loaded", on_file_loaded)

-- === ГОРЯЧИЕ КЛАВИШИ ===
mp.add_key_binding("Ctrl+H", "toggle-hdr-sdr", toggle_mode)
mp.add_key_binding("Ctrl+Shift+H", "force-hdr", set_hdr_mode)
mp.add_key_binding("Ctrl+Alt+H", "force-sdr", set_sdr_mode)

msg.info("[HDR-Auto] Скрипт загружен. Горячие клавиши:")
msg.info("  Ctrl+H         — Переключить HDR/SDR")
msg.info("  Ctrl+Shift+H   — Принудительно HDR")
msg.info("  Ctrl+Alt+H     — Принудительно SDR")
-- ~/.config/mpv/scripts/proxy-fast.lua

local proxy_url = "http://127.0.0.1:7897"

mp.register_event("start-file", function()
local url = mp.get_property("path", "")
if url == "" then return end

  -- Проверяем домены БЕЗОПАСНО
  local target = false
  for _, domain in ipairs({
    "youtube.com", "youtu.be", "youtube-nocookie.com",
    "instagram.com", "tiktok.com", "x.com", "twitter.com"
  }) do
  if url:find(domain, 1, true) then
    target = true
    break
    end
    end

    if target then
      mp.set_property("options/ytdl-raw-options", "cookies-from-browser=firefox,proxy=" .. proxy_url)
      end
      end)

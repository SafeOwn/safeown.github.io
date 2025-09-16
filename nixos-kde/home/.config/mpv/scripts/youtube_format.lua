-- youtube_quality.lua
mp.msg.info("YouTube quality script loaded")

local function set_best_quality()
    local url = mp.get_property("stream-open-filename", "")
    if url and (string.find(url, "youtube.com/") or string.find(url, "youtu.be/")) then
        mp.msg.info("YouTube URL detected. Setting best quality.")
        mp.set_property("options/ytdl-format", "bestvideo+bestaudio/best")
        mp.msg.info("Best quality setting applied.")
    end
end

mp.add_hook("on_load", 10, set_best_quality)
mp.msg.info("youtube_quality.lua ready")
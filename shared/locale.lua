Locales = {}

---Translate a locale key. Falls back to English, then to the key itself.
---@param key string
---@param ... any string.format arguments
---@return string
function L(key, ...)
    local lang = Locales[Config.Locale] or Locales.en or {}
    local str = lang[key] or (Locales.en and Locales.en[key]) or key

    if select('#', ...) > 0 then
        return str:format(...)
    end

    return str
end

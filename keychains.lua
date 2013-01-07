----------------------------------------------------------------------------
-- @author Zsolt Udvari &lt;udvzsolt@gmail.com&gt;
-- @copyright 2012 Zsolt Udvari
-- @release v1.1 (tested with awesome 3.5)
----------------------------------------------------------------------------

-- Grab environment
local pairs     =   pairs
local type      =   type
local awful     =   awful
local root      =   root
local naughty   =   naughty

module("keychains")

--- variables
local keychain    = {}
local globalkeys  = {}
local chains      = {}
local notify      = nil
local not_options = {}

---
-- Initialize the Keychain object.
-- @param globkeys the main root-hotkeys (without keychains!)
-- @param opt table of notify's options. The 'text', 'icon',
-- 'title' and 'timeout' fields is ignored!
---
function init(globkeys,opt)
    globalkeys  = globkeys
    not_options = opt or {}
    local v
    for _,v in pairs({"text","icon","title","timeout"}) do
        opt[v] = nil
    end
end

---
-- Add a new keychain-table.
-- @param mod_hk hotkey modifiers (table, same as in awful.key)
-- @param hk hotkey to jump into hotkey-chain
-- @param title title of hotkeys
-- @param hotkeys table, keys of table are hotkey, values are a table:
--  - func: function to call
--  - info: information
--  Hotkeys can be a function which returns table as above.
---
function add(mod_hk,hk,title,icon,hotkeys)
    local nr = #(keychain)+1
    keychain[nr] = keychain[nr] or {}
    keychain[nr].icon = icon
    keychain[nr].title = title
    keychain[nr].hotkeys = hotkeys

    chains = awful.util.table.join(
        chains,
        awful.key(mod_hk,hk,function()
            activite(nr)
        end)
    )
end


---
-- Returns the hotkeys.
-- @param which which table
-- @return table.
-- If hotkeys is a function get_hotkeys will return hotkeys result else will return hotkeys.
---
function get_hotkeys(which)
    local ret
    if (type(keychain[which]["hotkeys"])=="function") then
        ret = keychain[which].hotkeys()
    else
        ret = keychain[which].hotkeys
    end
    return ret
end

---
-- Generate information about hotkeys
-- @param which which table
-- @return information string
---
function get_info(which)
    local i,hk
    local txt = ""
    local hotkeys = get_hotkeys(which)

    for i,hk in pairs(hotkeys) do
        txt = txt .. i .. " " ..
            (hk.info or awful.util.escape("[[ no description ]]")) .. "\n"
    end

    return txt
end

---
-- Generate awful keys
-- @param which which hotkeys
-- @return awesome-compatible table
---
function get_awful_keys(which)
    local i, hkt,ret
    local hotkeys = get_hotkeys(which)

    ret = {}
    for i,hkt in pairs(hotkeys) do
        ret = awful.util.table.join(
            ret,
            awful.key({},i,function()
                reset()
                hkt.func()
            end)
        )
    end
    return ret
end

---
-- Activite a keychain and displays its information.
-- @param which which keychain should activite
--- 
function activite(which)
    root.keys( awful.util.table.join(
        get_awful_keys(which),
        awful.key({},"Escape",function()
            reset()
        end),
        globalkeys
    ))
    notify = naughty.notify(awful.util.table.join(
        {
            title   = keychain[which].title,
            text    = get_info(which),
            icon    = keychain[which].icon
        }, not_options
    ))
end

---
-- Reset keychains.
-- Reset the hotkeys and destroy the keychain notify.
---
function reset()
    root.keys( awful.util.table.join(
        globalkeys,
        chains
    ))
    naughty.destroy(notify)
end


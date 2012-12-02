----------------------------------------------------------------------------
-- @author Zsolt Udvari &lt;udvzsolt@gmail.com&gt;
-- @copyright 2012 Zsolt Udvari
-- @release v1.0 (tested with awesome 3.4.13)
----------------------------------------------------------------------------

-- Grab environment
local pairs     =   pairs
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
---
function add(mod_hk,hk,title,icon,hotkeys)
    local nr = #(keychain)+1
    keychain[nr] = keychain[nr] or {}
    keychain[nr].icon = icon
    keychain[nr].hotkeys = {}
    local i, hkt
    local txt=""
    for i,hkt in pairs(hotkeys) do
        keychain[nr].hotkeys = awful.util.table.join(
            keychain[nr].hotkeys,
            awful.key({},i,function()
                reset()
                hkt.func()
            end)
        )
        txt = txt .. i .. " " .. 
            (hkt.info or awful.util.escape("[[ no description ]]")) .. "\n"
    end
    keychain[nr].info = txt
    keychain[nr].hotkeys = awful.util.table.join(
        keychain[nr].hotkeys,
        awful.key({},"Escape",function()
            reset()
        end)
    )
    keychain[nr].title = title

    chains = awful.util.table.join(
        chains,
        awful.key(mod_hk,hk,function()
            activite(nr)
        end)
    )
end

---
-- Activite a keychain and displays its information.
-- @param which which keychain should activite
--- 
function activite(which)
    root.keys( awful.util.table.join(
        keychain[which]["hotkeys"],
        globalkeys
    ))
    notify = naughty.notify(awful.util.table.join(
        {
            title   = keychain[which].title,
            text    = keychain[which].info,
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


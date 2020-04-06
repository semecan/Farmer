local addonName, addon = ...;

local C_Timer = _G.C_Timer;

local StorageUtils = addon.StorageUtils;
local addItem = StorageUtils.addItem;

local Items = {};
local storageList = {};
local currentInventory = {};

addon.Items = Items;

local function getFirstKey (table)
  return next(table, nil);
end

local function readStorage (inventory, storage)
  if (storage == nil) then return end

  for containerIndex, container in pairs(storage) do
    if (container ~= nil) then
      for itemId, itemInfo in pairs(container) do
        addItem(inventory, itemId, itemInfo.count, itemInfo.links);
      end
    end
  end
end

local function getCachedInventory ()
  local inventory = {};

  for storageIndex = 1, #storageList, 1 do
    local handler = storageList[storageIndex];
    local storage;

    if (type(handler) == 'function') then
      storage = handler();
    end

    readStorage(inventory, storage);
  end

  return inventory;
end

function Items:addStorage (storage)
  table.insert(storageList, storage);
end

function Items:updateCurrentInventory ()
  currentInventory = getCachedInventory();
end

function Items:addItemToCurrentInventory (id, count, linkMap)
  addItem(currentInventory, id, count, linkMap);
end

function Items:addNewItem (id, count, link)
  addItem(currentInventory, id, count, link);
  addon:yell('NEW_ITEM', id, link, count);
end

local function checkInventory ()
  local inventory = getCachedInventory();

  local new = {};

  for id, info in pairs(inventory) do
    if (currentInventory[id] == nil) then
      new[id] = {
        count = inventory[id].count,
        link = getFirstKey(inventory[id].links)
      };
    elseif (inventory[id].count > currentInventory[id].count) then
      local links = inventory[id].links;
      local currentLinks = currentInventory[id].links;
      local found = false;

      for link, value in pairs(links) do
        if (currentLinks[link] == nil) then
          found = true;
          new[id] = {
            count = inventory[id].count - currentInventory[id].count,
            link = link
          };
          break;
        end
      end

      if (found == false) then
        new[id] = {
          count = inventory[id].count - currentInventory[id].count,
          link = getFirstKey(links)
        };
      end
    end
  end

  for id, info in pairs(new) do
    addon:yell('NEW_ITEM', id, info.link, info.count);
  end

  currentInventory = inventory;
end

--[[ Funneling the check so it executes on the next frame after
     BAG_UPDATE_DELAYED. This allows storages to update first to avoid race
     conditions ]]
-- addon:funnel('BAG_UPDATE_DELAYED', checkInventory);
addon:on('BAG_UPDATE_DELAYED', function ()
  C_Timer.After(0, checkInventory);
end);

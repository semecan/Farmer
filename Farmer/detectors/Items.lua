local addonName, addon = ...;

local tinsert = _G.tinsert;
local C_Item = _G.C_Item;
local IsItemDataCachedByID = C_Item.IsItemDataCachedByID;
local GetItemInfo = _G.GetItemInfo;

local extractNormalizedItemString = addon.extractNormalizedItemString;
local fetchItemLink = addon.fetchItemLink;
local Storage = addon.Factory.Storage;
local ImmutableMap = addon.Factory.ImmutableMap;

local Items = {};
local storageList = {};

addon.Items = Items;

function Items.addStorage (storage)
  tinsert(storageList, storage);
end

local function readStorage (storage)
  if (type(storage) == 'function') then
    return storage();
  end

  return storage;
end

local function readItemChanges (changes, id, itemInfo)
  --[[In theory, if an item gets moved to another bag while another item with
      the same id gets looted into the original bag of the item, this will
      cause the already owned item to be displayed instead of the new one.
      In reality, that case is extremely rare and the game will propably send
      two BAG_UPDATE_DELAYED events for that anyways, so we can use this to
      gain performance]]
  if (itemInfo.count == 0) then
    return;
  end

  for link, count in pairs(itemInfo.links) do
    if (count ~= 0) then
      changes:addChange(id, extractNormalizedItemString(link) or link, count);
    end
  end
end

local function readContainerChanges (changes, container)
  for id, itemInfo in pairs(container:getChanges()) do
    readItemChanges(changes, id, itemInfo);
  end

  container:clearChanges();
end


local function readStorageChanges (changes, storage)
  for _, container in pairs(readStorage(storage)) do
    readContainerChanges(changes, container);
  end
end

local function getInventoryChanges ()
  local changes = Storage:new();

  for _, storage in ipairs(storageList) do
    readStorageChanges(changes, storage);
  end

  return changes:getChanges();
end

local function packItemInfo (itemId, itemLink)
  local info = {GetItemInfo(itemLink)};

  return {
    id = itemId,
    name = info[1],
    link = info[2],
    rarity = info[3],
    level = info[4],
    minLevel = info[5],
    type = info[6],
    subType = info[7],
    stackSize = info[8],
    equipLocation = info[9],
    texture = info[10],
    sellPrice = info[11],
    classId = info[12],
    subClassId = info[13],
    bindType = info[14],
    expansionId = info[15],
    itemSetId = info[16],
    isCraftingReagent = info[17],
  };
end

local function yellItem (itemId, itemLink, itemCount)
  addon.yell('NEW_ITEM', ImmutableMap(packItemInfo(itemId, itemLink)),
      itemCount);
end

local function broadCastItem (id, link, count)
  if (IsItemDataCachedByID(id)) then
    yellItem(id, link, count);
  else
    fetchItemLink(id, link, yellItem, count);
  end
end

local function broadCastItemInfo (id, info)
  for link, count in pairs(info.links) do
    if (count ~= 0) then
      broadCastItem(id, link, count);
    end
  end
end

local function checkInventory ()
  for id, info in pairs(getInventoryChanges()) do
    if (info.count ~= 0) then
      broadCastItemInfo(id, info);
    end
  end
end

--[[ Funneling the check so it executes on the next frame after
     BAG_UPDATE_DELAYED. This allows storages to update first to avoid race
     conditions ]]
addon.funnel('BAG_UPDATE_DELAYED', checkInventory);

--##############################################################################
-- testing
--##############################################################################

local function testItem (id, count)
  local _, link = GetItemInfo(id);

  if (link) then
    yellItem(id, link, count);
  else
    print(addonName .. ': no data for item id', id);
  end
end

local function testPredefinedItems ()
  local testItems = {
    2447, -- Peacebloom
    4496, -- Small Brown Pouch
    6975, -- Whirlwind Axe
    4322, -- Enchanter's Cowl
    13521, -- Recipe: Flask of Supreme Power
    156631 -- Silas' Sphere of Transmutation
  };

  for _, item in ipairs(testItems) do
    testItem(item, 1);
    testItem(item, 4);
  end
end

addon.share('tests').items = function (id, count)
  if (id) then
    testItem(tonumber(id), count or 1);
  else
    testPredefinedItems();
  end
end

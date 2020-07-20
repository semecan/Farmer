local addonName, addon = ...;

local CanMerchantRepair = _G.CanMerchantRepair;
local GetRepairAllCost = _G.GetRepairAllCost;
local IsInGuild = _G.IsInGuild;
local CanGuildBankRepair = _G.CanGuildBankRepair;
local GetGuildBankWithdrawMoney = _G.GetGuildBankWithdrawMoney;
local GetGuildBankMoney = _G.GetGuildBankMoney;
local RepairAllItems = _G.RepairAllItems;
local GetMoney = _G.GetMoney;

local L = addon.L;

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars;

local function repairEquipmentFromGuildFunds (cost)
  RepairAllItems(true);
  print(L['Equipment has been repaired by your Guild for %s']
      :format(addon.formatMoney(cost)));
end

local function canGuildRepair (cost)
  if (not IsInGuild() or
      not CanGuildBankRepair() or
      saved.farmerOptions.autoRepairAllowGuild ~= true) then
    return false;
  end

  local maxWithdrawableMoney = GetGuildBankWithdrawMoney();
  local guildMoney = GetGuildBankMoney();

  return (maxWithdrawableMoney > cost and guildMoney > cost);
end

local function performGuildRepair (cost)
  if (canGuildRepair(cost)) then
    repairEquipmentFromGuildFunds(cost);
    return true;
  end

  return false;
end

local function repairEquipmentFromOwnFunds (cost)
  RepairAllItems(false);
  print(L['Equipment has been repaired for %s']
      :format(addon.formatMoney(cost)));
end

local function canSelfRepair (cost)
  return (cost <= GetMoney());
end

local function performSelfRepair (cost)
  if (canSelfRepair(cost)) then
    repairEquipmentFromOwnFunds(cost);
    return true;
  end

  return false;
end

local function repairEquipment ()
  local repairAllCost, canRepair = GetRepairAllCost();

  if (not canRepair) then return end

  if (not (performGuildRepair(repairAllCost) or
           performSelfRepair(repairAllCost))) then
    print(L['Not enough gold for repairing your gear']);
  end
end

local function shouldAutoRepair ()
  return (CanMerchantRepair() and saved.farmerOptions.autoRepair == true);
end

local function onMerchantOpened ()
  if (shouldAutoRepair()) then
    repairEquipment();
  end
end

addon.on('MERCHANT_SHOW', onMerchantOpened);

addon.slash('foo', function ()
  repairEquipmentFromOwnFunds(123);
end);
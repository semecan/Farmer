local addonName, addon = ...;

local MESSAGE_COLORS = {0, 0, 1};
local reputationCache;
local updateFlag = false;

local function getRepInfo ()
  local info = {};

  for i = 1, GetNumFactions(), 1 do
    local factionInfo = {GetFactionInfo(i)};

    local faction = factionInfo[14];
    local reputation = factionInfo[6];

    if (faction ~= nil and reputation ~= nil) then
      local data = {};

      data.reputation = reputation;

      if (C_Reputation.IsFactionParagon(faction)) then
        local paragonInfo = {C_Reputation.GetFactionParagonInfo(faction)};

        data.paragonReputation = paragonInfo[1];
        data.paragonLevel = floor(paragonInfo[1] / paragonInfo[2]);
      end

      info[faction] = data;
    end
  end

  return info;
end

local function checkReputationChanges ()
  --[[ UPDATE_FACTION fires multiple times before PLAYER_LOGIN, so we don't
     compare before a cache was created ]]
  if (reputationCache == nil) then
    return
  end

  local repInfo = getRepInfo();

  if (farmerOptions.reputation == false or
      addon.Print.checkHideOptions() == false) then
    reputationCache = repInfo;
    return;
  end

  for faction, factionInfo in pairs(repInfo) do
    local cachedFactionInfo = reputationCache[faction] or {};

    local function getCacheDifference (key)
      return (factionInfo[key] or 0) - (cachedFactionInfo[key] or 0);
    end

    local repChange = getCacheDifference('reputation');
    local paragonLevelGained = false;

    if (factionInfo.paragonReputation ~= nil or
        cachedFactionInfo.paragonReputation ~= nil) then
      local paragonRepChange = getCacheDifference('paragonReputation');

      paragonLevelGained = (getCacheDifference('paragonLevel') > 0);
      repChange = repChange + paragonRepChange;
    end

    if (repChange ~= 0) then
      if (repChange > 0) then
        repChange = '+' .. repChange;
      end

      if (paragonLevelGained == true) then
        repChange = repChange ..
            '|TInterface/TargetingFrame/UI-RaidTargetingIcon_1' ..
            addon.vars.iconOffset .. '|t';
      end

      --[[ could have stored faction name when generating faction info, but we
           can afford getting the name now for saving the memory ]]
      local message = repChange .. ' '  .. GetFactionInfoByID(faction);

      addon.Print.printMessage(message, MESSAGE_COLORS);
    end
  end

  reputationCache = repInfo;
end

addon:on('PLAYER_LOGIN', function ()
  reputationCache = getRepInfo();
end);

addon:on('UPDATE_FACTION', function ()
  if (updateFlag == false) then
    updateFlag = true;

    C_Timer.After(0, function ()
      updateFlag = false;
      checkReputationChanges();
    end);
  end
end);

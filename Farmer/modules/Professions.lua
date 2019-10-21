local addonName, addon = ...;

local MESSAGE_COLORS = {0.9, 0.3, 0};
local PROFESSION_CATEGORIES;
local professionCache = nil;

local function getProfessionCategories ()
  local skillList = C_TradeSkillUI.GetAllProfessionTradeSkillLines();
  local data = {};

  for i = 1, #skillList, 1 do
    local id = skillList[i];
    local info = {C_TradeSkillUI.GetTradeSkillLineInfoByID(id)};
    local parentId = info[5];

    --[[ If parentId is nil, the current line is the main profession.
         Because Blizzard apparently does not know how to properly code, this
         will return the same info as the classic category, so we skip it --]]
    if (parentId ~= nil) then
      if (data[parentId] == nil) then
        data[parentId] = {id};
      else
        table.insert(data[parentId], id);
      end
    end
  end

  return data;
end

local function getLearnedProfessions ()
  local data = {};
  local professions = {GetProfessions()};

  --[[ array may contain nil values, so we have to iterate as an object --]]
  for _, professionId in pairs(professions) do
    local info = {GetProfessionInfo(professionId)};
    local skillId = info[7];

    data[skillId] = {
      icon = info[2]
    };
  end

  return data;
end

local function getProfessionInfo ()
  local learnedProfessions = getLearnedProfessions();
  local data = {};

  for parentId, parentInfo in pairs(learnedProfessions) do
    local skillList = PROFESSION_CATEGORIES[parentId];

    if (skillList ~= nil) then
      for i = 1, #skillList, 1 do
        local skillId = skillList[i];
        local info = {C_TradeSkillUI.GetTradeSkillLineInfoByID(skillId)};

        data[skillId] = {
          name = info[1],
          rank = info[2],
          maxRank = info[3],
          icon = parentInfo.icon,
        };
      end
    -- else
      -- print(parentId);
      -- print('A PARENT WAS EMPTY, HELP!!!');
    end
  end

  return data;
end

addon:on('SKILL_LINES_CHANGED', function ()
  if (professionCache == nil) then return end

  local data = getProfessionInfo();

  for id, info in pairs(data) do
    local oldInfo = professionCache[id] or {};
    local change = info.rank - (oldInfo.rank or 0);

    if (change ~= 0) then
      local icon = addon:getIcon(info.icon);
      local text = addon:stringJoin({'(', info.rank, '/', info.maxRank, ')'}, '');

      addon.Print.printMessage(addon:stringJoin({icon, info.name, text}, ' '), MESSAGE_COLORS);
    end
  end

  professionCache = data;
end);

addon:on('PLAYER_LOGIN', function ()
  PROFESSION_CATEGORIES = getProfessionCategories();
  professionCache = getProfessionInfo();
end);


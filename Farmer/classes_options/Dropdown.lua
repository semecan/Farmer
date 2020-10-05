local _, addon = ...;

local CreateFrame = _G.CreateFrame;
local UIDropDownMenu_SetWidth = _G.UIDropDownMenu_SetWidth;
local UIDropDownMenu_JustifyText = _G.UIDropDownMenu_JustifyText;
local UIDropDownMenu_SetText = _G.UIDropDownMenu_SetText;
local UIDropDownMenu_Initialize = _G.UIDropDownMenu_Initialize;
local UIDropDownMenu_CreateInfo = _G.UIDropDownMenu_CreateInfo;
local UIDropDownMenu_AddButton = _G.UIDropDownMenu_AddButton;
local ToggleDropDownMenu = _G.ToggleDropDownMenu;

local Factory = addon.share('OptionClass');

local Dropdown = {};

Factory.Dropdown = Dropdown;

Dropdown.__index = Dropdown;

local function generateDropdownInitializer (dropdown, options, width)
  local function initializer (_, level)
    local info = UIDropDownMenu_CreateInfo();

    info.minWidth = width + 5;
    info.justifyH = 'CENTER';

    for i = 1, #options do
      local option = options[i];

      info.func = dropdown.SetValue;
      info.text = option.text;
      info.arg1 = option.value;
      info.value = option.value;
      info.checked = (dropdown.value == option.value);
      UIDropDownMenu_AddButton(info, level);
    end
  end

  return initializer;
end

local function createDropdown (name, parent, text, options, anchors)
  local dropdown = CreateFrame('Frame', name .. 'Dropdown', parent,
      'UIDropDownMenuTemplate');

  dropdown.Button:SetScript('OnClick', function ()
    ToggleDropDownMenu(1, nil, dropdown, dropdown, 10, 10);
  end);

  dropdown:SetPoint(anchors.anchor, anchors.parent, anchors.parentAnchor,
      anchors.xOffset - 23, anchors.yOffset);

  function dropdown:SetValue (value)
    dropdown.value = value;
  end

  function dropdown:GetValue ()
    return dropdown.value;
  end

  UIDropDownMenu_SetWidth(dropdown, anchors.width);
  UIDropDownMenu_JustifyText(dropdown, 'CENTER');
  UIDropDownMenu_SetText(dropdown, text);

  UIDropDownMenu_Initialize(dropdown,
      generateDropdownInitializer(dropdown, options, anchors.width));

  return dropdown;
end

function Dropdown:new (parent, name, anchorFrame, xOffset, yOffset, text,
                       options, anchor, parentAnchor)
  local this = {};

  setmetatable(this, Dropdown);

  this.dropdown = createDropdown(name, parent, text, options, {
    anchor = anchor or 'TOPLEFT',
    parent = anchorFrame,
    parentAnchor = parentAnchor or 'BOTTOMLEFT',
    xOffset = xOffset,
    yOffset = yOffset,
    width = 145,
  });

  return this;
end

function Dropdown:SetValue (value)
  self.dropdown:SetValue(value);
end

function Dropdown:GetValue ()
  return self.dropdown:GetValue();
end

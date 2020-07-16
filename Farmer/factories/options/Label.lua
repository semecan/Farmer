local _, addon = ...;

local STANDARD_TEXT_FONT = _G.STANDARD_TEXT_FONT;

local Factory = addon:share('OptionFactory');

local Label = {};

Factory.Label = Label;

Label.__index = Label;

local function createLabel (parent, text, anchors)
  local label = parent:CreateFontString('FontString');

  --label:SetFont(addon.vars.font, 16, 'outline');
  --label:SetFont('ChatFontNormal', 16, 'outline');
  label:SetFont(STANDARD_TEXT_FONT, 14, 'outline');
  label:SetPoint(anchors.anchor, anchors.parent, anchors.parentAnchor,
      anchors.xOffset, anchors.yOffset);
  label:SetText(text);

  return label;
end

function Label:new (parent, anchorFrame, xOffset, yOffset, text, anchor, parentAnchor)
  local this = {};

  setmetatable(this, Label);

  this.label = createLabel(parent, text, {
    anchor = anchor or 'TOPLEFT',
    parent = anchorFrame,
    xOffset = xOffset,
    yOffset = yOffset,
    parentAnchor = parentAnchor or 'BOTTOMLEFT',
  });

  return this;
end


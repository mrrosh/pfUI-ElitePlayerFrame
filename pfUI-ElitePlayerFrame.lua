pfUI:RegisterModule("ElitePlayerFrame", "vanilla:tbc", function ()
  pfUI.gui.dropdowns.ElitePlayerFrame_positions = {
    "left:" .. T["Left"],
    "right:" .. T["Right"],
    "off:" .. T["Disabled"]
  }
  pfUI.gui.dropdowns.ElitePlayerFrame_colors = {
    "worldboss:" .. T["World Boss"],
    "rareelite:" .. T["Rare Elite"],
    "elite:" .. T["Elite"],
    "rare:" .. T["Rare"]
  }

  -- detect current addon path
  local addonpath
  local tocs = { "", "-master", "-tbc", "-wotlk" }
  for _, name in pairs(tocs) do
    local current = string.format("pfUI-ElitePlayerFrame%s", name)
    local _, title = GetAddOnInfo(current)
    if title then
      addonpath = "Interface\\AddOns\\" .. current
      break
    end
  end


  local function UpdateEliteFrame()
    if not pfPlayer then return end -- Make sure player frame exists
    local portrait = pfPlayer.portrait or pfPlayer.hp.bar
    if not portrait then return end -- Ensure a valid portrait frame

    local pos = string.upper(C.ElitePlayerFrame.position)
    local invert = C.ElitePlayerFrame.position == "right" and 1 or -1
    local width = portrait:GetWidth()
    local size = width * 1.97

    -- Create or update textures
    pfPlayer.eliteTop = pfPlayer.eliteTop or pfPlayer:CreateTexture(nil, "OVERLAY")
    pfPlayer.eliteBottom = pfPlayer.eliteBottom or pfPlayer:CreateTexture(nil, "OVERLAY")

    if C.ElitePlayerFrame.position == "off" then
      pfPlayer.eliteTop:Hide()
      pfPlayer.eliteBottom:Hide()
      return
    end

    pfPlayer.eliteTop:ClearAllPoints()
    pfPlayer.eliteBottom:ClearAllPoints()

    pfPlayer.eliteTop:SetWidth(size)
    pfPlayer.eliteTop:SetHeight(size)
    pfPlayer.eliteTop:SetPoint("TOP" .. pos, portrait, "TOP" .. pos, invert * size / 5, size / 7)
    pfPlayer.eliteTop:SetParent(portrait)

    pfPlayer.eliteBottom:SetWidth(size-4)
    pfPlayer.eliteBottom:SetHeight(size-4)
    pfPlayer.eliteBottom:SetPoint("BOTTOM" .. pos, portrait, "BOTTOM" .. pos, invert * size / 5.2, -size / 3.3)
    pfPlayer.eliteBottom:SetParent(portrait)

    -- Set texture color based on user selection
    local texturePath = addonpath .. "\\img\\"
    if C.ElitePlayerFrame.colors == "worldboss" then
      pfPlayer.eliteTop:SetTexture(texturePath .. "TOP_GOLD_" .. pos)
      pfPlayer.eliteTop:SetVertexColor(.85, .15, .15, 1)
      pfPlayer.eliteBottom:SetTexture(texturePath .. "BOTTOM_GOLD_" .. pos)
      pfPlayer.eliteBottom:SetVertexColor(.85, .15, .15, 1)
    elseif C.ElitePlayerFrame.colors == "rareelite" then
      pfPlayer.eliteTop:SetTexture(texturePath .. "TOP_GOLD_" .. pos)
      pfPlayer.eliteTop:SetVertexColor(1, 1, 1, 1)
      pfPlayer.eliteBottom:SetTexture(texturePath .. "BOTTOM_GOLD_" .. pos)
      pfPlayer.eliteBottom:SetVertexColor(1, 1, 1, 1)
    elseif C.ElitePlayerFrame.colors == "elite" then
      pfPlayer.eliteTop:SetTexture(texturePath .. "TOP_GOLD_" .. pos)
      pfPlayer.eliteTop:SetVertexColor(.75, .6, 0, 1)
      pfPlayer.eliteBottom:SetTexture(texturePath .. "BOTTOM_GOLD_" .. pos)
      pfPlayer.eliteBottom:SetVertexColor(.75, .6, 0, 1)
    elseif C.ElitePlayerFrame.colors == "rare" then
      pfPlayer.eliteTop:SetTexture(texturePath .. "TOP_GRAY_" .. pos)
      pfPlayer.eliteTop:SetVertexColor(.8, .8, .8, 1)
      pfPlayer.eliteBottom:SetTexture(texturePath .. "BOTTOM_GRAY_" .. pos)
      pfPlayer.eliteBottom:SetVertexColor(.8, .8, .8, 1)
    end

    pfPlayer.eliteTop:Show()
    pfPlayer.eliteBottom:Show()
  end

 -- Update function registered for real-time updates
  local U = pfUI.gui.UpdaterFunctions
  U["Player"] = function() 
    UpdateEliteFrame()  -- Calls the UpdateEliteFrame function to apply changes
  end

  pfUI:UpdateConfig("ElitePlayerFrame", nil, "position", "left")
  pfUI:UpdateConfig("ElitePlayerFrame", nil, "colors", "elite")

  -- Create config entries with real-time update
  if pfUI.gui.CreateGUIEntry then -- new pfUI
    pfUI.gui.CreateGUIEntry(T["Thirdparty"], T["Elite Player"], function()
      pfUI.gui.CreateConfig(pfUI.gui.UpdaterFunctions["Player"], T["Select elite position"], C.ElitePlayerFrame, "position", "dropdown", pfUI.gui.dropdowns.ElitePlayerFrame_positions)
      pfUI.gui.CreateConfig(pfUI.gui.UpdaterFunctions["Player"], T["Select elite type"], C.ElitePlayerFrame, "colors", "dropdown", pfUI.gui.dropdowns.ElitePlayerFrame_colors)
    end)
  else -- old pfUI
    pfUI.gui.tabs.thirdparty.tabs.ElitePlayerFrame = pfUI.gui.tabs.thirdparty.tabs:CreateTabChild("ElitePlayerFrame", true)
    pfUI.gui.tabs.thirdparty.tabs.ElitePlayerFrame:SetScript("OnShow", function()
      if not this.setup then
        local CreateConfig = pfUI.gui.CreateConfig
        local update = pfUI.gui.update
        this.setup = true
      end
    end)
  end

  -- Hook into pfUI's RefreshUnit, but only for the player frame
  hooksecurefunc(pfUI.uf, "RefreshUnit", function(unit, component)
    if unit == "player" then
      UpdateEliteFrame()
    end
  end)

  -- Ensure it loads properly when the addon is initialized
  local function SafeUpdateEliteFrame()
    if pfPlayer then
      UpdateEliteFrame()
    else
      C_Timer.After(1, SafeUpdateEliteFrame) -- Retry until pfPlayer exists
    end
  end
  SafeUpdateEliteFrame()
end)

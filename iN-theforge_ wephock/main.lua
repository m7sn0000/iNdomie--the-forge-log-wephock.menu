local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "iNdomie Webhook Hub",
   LoadingTitle = "Webhook Hub",
   LoadingSubtitle = "by iNdomie",
   Theme = "DarkBlue",
   DisableRayfieldPrompts = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "iNdomie_Webhook_Hub"
   },
   Discord = {
      Enabled = true,
      Invite = "bjJmvcNM",
      RememberJoins = true
   },
   KeySystem = true,
   KeySettings = {
      Title = "iNdomie Webhook Hub",
      Subtitle = "Key System",
      Note = "Key: iNdomie.webhookHub",
      FileName = "iNdomie_Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"iNdomie.webhookHub"}
   }
})

local WebhookSettings = {
    URL = "",
    Username = "Game Stats Bot",
    AvatarURL = "https://i.imgur.com/your-avatar.png",
    AutoSendEnabled = false,
    AutoSendInterval = 1800
}

local PlayerStats = {
    Money = 0,
    Level = 0,
    Playtime = 0,
    CustomStat1 = 0,
    CustomStat2 = 0,
    CustomStat3 = ""
}

local AutoSendConnection = nil

local function SendWebhook(EmbedData)
    if WebhookSettings.URL == "" then
        Rayfield:Notify({
            Title = "Error",
            Content = "Please enter Webhook URL first",
            Duration = 3,
            Image = 4483362458
        })
        return false
    end
    
    local Data = {
        username = WebhookSettings.Username,
        avatar_url = WebhookSettings.AvatarURL,
        embeds = {EmbedData}
    }
    
    local Success, Response = pcall(function()
        return request({
            Url = WebhookSettings.URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = game:GetService("HttpService"):JSONEncode(Data)
        })
    end)
    
    if Success and Response.StatusCode == 204 then
        return true
    else
        Rayfield:Notify({
            Title = "Failed",
            Content = "Error: " .. tostring(Response and Response.StatusCode or "Unknown"),
            Duration = 4,
            Image = 4483362458
        })
        return false
    end
end

local function SendStatsReport()
    local EmbedData = {
        title = "Player Statistics Report",
        description = "Automatic stats update",
        color = 7506394,
        fields = {
            {
                name = "Money",
                value = tostring(PlayerStats.Money),
                inline = true
            },
            {
                name = "Level",
                value = tostring(PlayerStats.Level),
                inline = true
            },
            {
                name = "Playtime",
                value = tostring(PlayerStats.Playtime) .. " minutes",
                inline = true
            },
            {
                name = "Custom Stat 1",
                value = tostring(PlayerStats.CustomStat1),
                inline = true
            },
            {
                name = "Custom Stat 2",
                value = tostring(PlayerStats.CustomStat2),
                inline = true
            },
            {
                name = "Custom Info",
                value = PlayerStats.CustomStat3 ~= "" and PlayerStats.CustomStat3 or "None",
                inline = false
            }
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S"),
        footer = {
            text = "Player: " .. game.Players.LocalPlayer.Name
        }
    }
    
    if SendWebhook(EmbedData) then
        Rayfield:Notify({
            Title = "Stats Sent",
            Content = "Statistics sent successfully",
            Duration = 2,
            Image = 4483362458
        })
    end
end

local function StartAutoSend()
    if AutoSendConnection then
        AutoSendConnection:Disconnect()
    end
    
    AutoSendConnection = task.spawn(function()
        while WebhookSettings.AutoSendEnabled do
            wait(WebhookSettings.AutoSendInterval)
            if WebhookSettings.AutoSendEnabled then
                SendStatsReport()
            end
        end
    end)
end

local function SendShutdownAlert()
    local EmbedData = {
        title = "Script Shutdown Alert",
        description = "The script has been disabled",
        color = 15158332,
        fields = {
            {
                name = "Player",
                value = game.Players.LocalPlayer.Name,
                inline = true
            },
            {
                name = "Time",
                value = os.date("%H:%M:%S"),
                inline = true
            },
            {
                name = "Final Money",
                value = tostring(PlayerStats.Money),
                inline = true
            },
            {
                name = "Final Level",
                value = tostring(PlayerStats.Level),
                inline = true
            }
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
    }
    
    SendWebhook(EmbedData)
end

game.Players.LocalPlayer.OnTeleport:Connect(function()
    SendShutdownAlert()
end)

game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "Rayfield" then
        SendShutdownAlert()
    end
end)

local SettingsTab = Window:CreateTab("Settings", 4483362458)
local SettingsSection = SettingsTab:CreateSection("Webhook Configuration")

local WebhookInput = SettingsTab:CreateInput({
   Name = "Webhook URL",
   PlaceholderText = "https://discord.com/api/webhooks/...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      WebhookSettings.URL = Text
      Rayfield:Notify({
         Title = "Saved",
         Content = "Webhook URL saved",
         Duration = 2,
         Image = 4483362458
      })
   end,
})

local AutoSendToggle = SettingsTab:CreateToggle({
   Name = "Auto Send Stats (Every 30 min)",
   CurrentValue = false,
   Flag = "AutoSendToggle",
   Callback = function(Value)
      WebhookSettings.AutoSendEnabled = Value
      if Value then
          StartAutoSend()
          Rayfield:Notify({
             Title = "Auto Send Enabled",
             Content = "Stats will be sent every 30 minutes",
             Duration = 3,
             Image = 4483362458
          })
      else
          if AutoSendConnection then
              task.cancel(AutoSendConnection)
          end
          Rayfield:Notify({
             Title = "Auto Send Disabled",
             Content = "Automatic sending stopped",
             Duration = 3,
             Image = 4483362458
          })
      end
   end,
})

local IntervalSlider = SettingsTab:CreateSlider({
   Name = "Send Interval (minutes)",
   Range = {5, 120},
   Increment = 5,
   CurrentValue = 30,
   Flag = "IntervalSlider",
   Callback = function(Value)
      WebhookSettings.AutoSendInterval = Value * 60
   end,
})

local StatsTab = Window:CreateTab("Player Stats", 4483362458)
local StatsSection = StatsTab:CreateSection("Configure Stats to Track")

local MoneyInput = StatsTab:CreateInput({
   Name = "Money Amount",
   PlaceholderText = "0",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      PlayerStats.Money = tonumber(Text) or 0
   end,
})

local LevelInput = StatsTab:CreateInput({
   Name = "Player Level",
   PlaceholderText = "0",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      PlayerStats.Level = tonumber(Text) or 0
   end,
})

local PlaytimeInput = StatsTab:CreateInput({
   Name = "Playtime (minutes)",
   PlaceholderText = "0",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      PlayerStats.Playtime = tonumber(Text) or 0
   end,
})

local CustomStat1Input = StatsTab:CreateInput({
   Name = "Custom Stat 1",
   PlaceholderText = "Enter value",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      PlayerStats.CustomStat1 = tonumber(Text) or 0
   end,
})

local CustomStat2Input = StatsTab:CreateInput({
   Name = "Custom Stat 2",
   PlaceholderText = "Enter value",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      PlayerStats.CustomStat2 = tonumber(Text) or 0
   end,
})

local CustomStat3Input = StatsTab:CreateInput({
   Name = "Custom Info",
   PlaceholderText = "Enter text",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      PlayerStats.CustomStat3 = Text
   end,
})

local SendNowBtn = StatsTab:CreateButton({
   Name = "Send Stats Now",
   Callback = function()
      SendStatsReport()
   end,
})

local ActionsTab = Window:CreateTab("Actions", 4483362458)
local ActionsSection = ActionsTab:CreateSection("Manual Actions")

local SendShutdownBtn = ActionsTab:CreateButton({
   Name = "Send Shutdown Alert",
   Callback = function()
      SendShutdownAlert()
   end,
})

local CustomMessageSection = ActionsTab:CreateSection("Custom Message")

local CustomTitle = ""
local CustomDesc = ""
local CustomColor = 7506394

local CustomTitleInput = ActionsTab:CreateInput({
   Name = "Message Title",
   PlaceholderText = "Enter title",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      CustomTitle = Text
   end,
})

local CustomDescInput = ActionsTab:CreateInput({
   Name = "Message Description",
   PlaceholderText = "Enter description",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      CustomDesc = Text
   end,
})

local CustomColorDropdown = ActionsTab:CreateDropdown({
   Name = "Message Color",
   Options = {"Blue", "Green", "Red", "Yellow", "Orange", "Purple"},
   CurrentOption = {"Blue"},
   MultipleOptions = false,
   Flag = "CustomColor",
   Callback = function(Option)
      local Colors = {
         ["Blue"] = 7506394,
         ["Green"] = 3066993,
         ["Red"] = 15158332,
         ["Yellow"] = 16776960,
         ["Orange"] = 16744192,
         ["Purple"] = 10181046
      }
      CustomColor = Colors[Option[1]]
   end,
})

local SendCustomBtn = ActionsTab:CreateButton({
   Name = "Send Custom Message",
   Callback = function()
      if CustomTitle == "" then
          Rayfield:Notify({
             Title = "Error",
             Content = "Please enter a title",
             Duration = 3,
             Image = 4483362458
          })
          return
      end
      
      local EmbedData = {
          title = CustomTitle,
          description = CustomDesc,
          color = CustomColor,
          timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
      }
      
      if SendWebhook(EmbedData) then
          Rayfield:Notify({
             Title = "Sent",
             Content = "Custom message sent",
             Duration = 2,
             Image = 4483362458
          })
      end
   end,
})

local HelpTab = Window:CreateTab("Help", 4483362458)
local HelpSection = HelpTab:CreateSection("How to Use")

local Step1 = HelpTab:CreateLabel("1. Enter Webhook URL in Settings")
local Step2 = HelpTab:CreateLabel("2. Configure player stats in Player Stats tab")
local Step3 = HelpTab:CreateLabel("3. Enable Auto Send for automatic reports")
local Step4 = HelpTab:CreateLabel("4. Script sends alert when closed")

local InfoSection = HelpTab:CreateSection("Features")
local Info1 = HelpTab:CreateLabel("- Automatic stats reports every 30 minutes")
local Info2 = HelpTab:CreateLabel("- Shutdown alert when script closes")
local Info3 = HelpTab:CreateLabel("- Customizable stats tracking")
local Info4 = HelpTab:CreateLabel("- Manual send option available")

local CreditsSection = HelpTab:CreateSection("Credits")
local CreditsLabel = HelpTab:CreateLabel("Made by: iNdomie")
local VersionLabel = HelpTab:CreateLabel("Version: 2.0")

Rayfield:Notify({
   Title = "Welcome",
   Content = "Webhook Hub loaded successfully",
   Duration = 5,
   Image = 4483362458
})

print("iNdomie Webhook Hub loaded successfully")

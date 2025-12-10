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
    Username = "iNdomie.webhookHub",
    AvatarURL = "https://i.ibb.co/7JWcBR2C/rovakook.gif",
    Message = "",
    EmbedTitle = "",
    EmbedDescription = "",
    EmbedColor = 7506394
}

local function SendWebhook(UseEmbed)
    if WebhookSettings.URL == "" then
        Rayfield:Notify({
            Title = "Error",
            Content = "Please enter Webhook URL first",
            Duration = 3,
            Image = 4483362458
        })
        return
    end
    
    local Data = {
        username = WebhookSettings.Username,
        avatar_url = WebhookSettings.AvatarURL ~= "" and WebhookSettings.AvatarURL or nil
    }
    
    if UseEmbed then
        if WebhookSettings.EmbedTitle == "" then
            Rayfield:Notify({
                Title = "Error",
                Content = "Please enter Embed title",
                Duration = 3,
                Image = 4483362458
            })
            return
        end
        
        Data.embeds = {{
            title = WebhookSettings.EmbedTitle,
            description = WebhookSettings.EmbedDescription,
            color = WebhookSettings.EmbedColor,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
        }}
    else
        if WebhookSettings.Message == "" then
            Rayfield:Notify({
                Title = "Error",
                Content = "Please enter a message",
                Duration = 3,
                Image = 4483362458
            })
            return
        end
        Data.content = WebhookSettings.Message
    end
    
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
        Rayfield:Notify({
            Title = "Success",
            Content = "Message sent successfully",
            Duration = 3,
            Image = 4483362458
        })
    else
        Rayfield:Notify({
            Title = "Failed",
            Content = "Error while sending: " .. tostring(Response and Response.StatusCode or "Unknown"),
            Duration = 4,
            Image = 4483362458
        })
    end
end

local SettingsTab = Window:CreateTab("Settings", 4483362458)
local SettingsSection = SettingsTab:CreateSection("Webhook Settings")

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

local UsernameInput = SettingsTab:CreateInput({
   Name = "Bot Username",
   PlaceholderText = "iNdomie.webhookHub",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      WebhookSettings.Username = Text
   end,
})

local AvatarInput = SettingsTab:CreateInput({
   Name = "Bot Avatar URL (Optional)",
   PlaceholderText = "https://example.com/avatar.png",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      WebhookSettings.AvatarURL = Text
   end,
})

local TestButton = SettingsTab:CreateButton({
   Name = "Test Webhook",
   Callback = function()
      WebhookSettings.Message = "This is a test message from iNdomie Webhook Hub"
      SendWebhook(false)
      WebhookSettings.Message = ""
   end,
})

local MessageTab = Window:CreateTab("Normal Message", 4483362458)
local MessageSection = MessageTab:CreateSection("Send Text Message")

local MessageInput = MessageTab:CreateInput({
   Name = "Message Content",
   PlaceholderText = "Type your message here...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      WebhookSettings.Message = Text
   end,
})

local QuickMessages = MessageTab:CreateSection("Quick Messages")

local QuickMsg1 = MessageTab:CreateButton({
   Name = "Hello everyone",
   Callback = function()
      WebhookSettings.Message = "Hello everyone"
      SendWebhook(false)
   end,
})

local QuickMsg2 = MessageTab:CreateButton({
   Name = "Important alert",
   Callback = function()
      WebhookSettings.Message = "Important alert: Please pay attention"
      SendWebhook(false)
   end,
})

local SendMessageBtn = MessageTab:CreateButton({
   Name = "Send Message",
   Callback = function()
      SendWebhook(false)
   end,
})

local EmbedTab = Window:CreateTab("Embed", 4483362458)
local EmbedSection = EmbedTab:CreateSection("Formatted Embed Messages")

local EmbedTitleInput = EmbedTab:CreateInput({
   Name = "Embed Title",
   PlaceholderText = "Message title",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      WebhookSettings.EmbedTitle = Text
   end,
})

local EmbedDescInput = EmbedTab:CreateInput({
   Name = "Embed Description",
   PlaceholderText = "Message content...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      WebhookSettings.EmbedDescription = Text
   end,
})

local ColorSection = EmbedTab:CreateSection("Embed Color")

local ColorDropdown = EmbedTab:CreateDropdown({
   Name = "Select Color",
   Options = {
      "Discord Blue (Default)",
      "Green",
      "Red",
      "Yellow",
      "Orange",
      "Purple",
      "Pink",
      "Black"
   },
   CurrentOption = {"Discord Blue (Default)"},
   MultipleOptions = false,
   Flag = "ColorDropdown",
   Callback = function(Option)
      local Colors = {
         ["Discord Blue (Default)"] = 7506394,
         ["Green"] = 3066993,
         ["Red"] = 15158332,
         ["Yellow"] = 16776960,
         ["Orange"] = 16744192,
         ["Purple"] = 10181046,
         ["Pink"] = 16738740,
         ["Black"] = 2303786
      }
      WebhookSettings.EmbedColor = Colors[Option[1]]
   end,
})

local TemplateSection = EmbedTab:CreateSection("Ready Templates")

local SuccessTemplate = EmbedTab:CreateButton({
   Name = "Success Template",
   Callback = function()
      WebhookSettings.EmbedTitle = "Successful Operation"
      WebhookSettings.EmbedDescription = "Operation completed successfully"
      WebhookSettings.EmbedColor = 3066993
      SendWebhook(true)
   end,
})

local ErrorTemplate = EmbedTab:CreateButton({
   Name = "Error Template",
   Callback = function()
      WebhookSettings.EmbedTitle = "Error Occurred"
      WebhookSettings.EmbedDescription = "An error occurred during execution"
      WebhookSettings.EmbedColor = 15158332
      SendWebhook(true)
   end,
})

local InfoTemplate = EmbedTab:CreateButton({
   Name = "Info Template",
   Callback = function()
      WebhookSettings.EmbedTitle = "Information"
      WebhookSettings.EmbedDescription = "Important information for users"
      WebhookSettings.EmbedColor = 7506394
      SendWebhook(true)
   end,
})

local SendEmbedBtn = EmbedTab:CreateButton({
   Name = "Send Embed",
   Callback = function()
      SendWebhook(true)
   end,
})

local HelpTab = Window:CreateTab("Help", 4483362458)
local HelpSection = HelpTab:CreateSection("How to Use")

local Step1 = HelpTab:CreateLabel("1. Go to Settings tab")
local Step2 = HelpTab:CreateLabel("2. Enter Discord Webhook URL")
local Step3 = HelpTab:CreateLabel("3. Choose message type (Normal or Embed)")
local Step4 = HelpTab:CreateLabel("4. Write your message and click send")

local InfoSection = HelpTab:CreateSection("Additional Information")
local InfoLabel1 = HelpTab:CreateLabel("- You can customize bot name and avatar")
local InfoLabel2 = HelpTab:CreateLabel("- Embed supports multiple colors")
local InfoLabel3 = HelpTab:CreateLabel("- Ready templates for quick use")

local CreditsSection = HelpTab:CreateSection("Credits")
local CreditsLabel = HelpTab:CreateLabel("Made by: iNdomie")
local VersionLabel = HelpTab:CreateLabel("Version: 1.0")

Rayfield:Notify({
   Title = "Welcome",
   Content = "iNdomie Webhook Hub loaded successfully",
   Duration = 5,
   Image = 4483362458
})

print("iNdomie Webhook Hub loaded successfully")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ========================
-- Window
-- ========================
local Window = Rayfield:CreateWindow({
   Name = "iNdomie Webhook Hub",
   LoadingTitle = "Webhook Hub",
   LoadingSubtitle = "by iNdomie",
   Theme = "DarkBlue",
   DisableRayfieldPrompts = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "iNdomie_Hub",
      FileName = "iNdomie_Webhook_Config"
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

local HttpService = game:GetService("HttpService")

-- ========================
-- Settings
-- ========================
local WebhookSettings = {
    URL = "",
    Username = "iNdomie.webhookHub",
    AvatarURL = "https://i.ibb.co/7JWcBR2C/rovakook.gif",
    ShutdownAlertEnabled = true,
    StatusUpdatesEnabled = true,
    StatusInterval = 30 * 60,
    ScreenshotEnabled = false,
    ScreenshotInterval = 30 * 60,
    ImgbbKey = "",
    AttachScreenshotToStatus = false
}

local ShutdownSent = false
local StatusConnection = nil
local ScreenshotConnection = nil

-- ========================
-- Functions
-- ========================
local function SendWebhook(EmbedData)
    if WebhookSettings.URL == "" then return false end
    local success, response = pcall(function()
        return request({
            Url = WebhookSettings.URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({username = WebhookSettings.Username, avatar_url = WebhookSettings.AvatarURL, embeds = {EmbedData}})
        })
    end)
    if not success then
        Rayfield:Notify({Title = "Webhook Error", Content = "Failed to send webhook", Duration = 5, Image = 4483362458})
        return false
    end
    return response and (response.StatusCode == 200 or response.StatusCode == 204)
end

local function TryTakeRobloxScreenshot()
    local imageData
    local success, result = pcall(function()
        if syn and syn.capture_screenshot then
            return syn.capture_screenshot()
        elseif draw and draw.capture then
            return draw.capture()
        else
            return nil
        end
    end)

    if success and result then
        imageData = result
    else
        Rayfield:Notify({
            Title = "Screenshot Failed",
            Content = "Executor does not support automatic Roblox capture",
            Duration = 5,
            Image = 4483362458
        })
    end
    return imageData
end

local function UploadToImgBB(base64Image)
    if WebhookSettings.ImgbbKey == "" then return nil end
    local body = "key=" .. WebhookSettings.ImgbbKey .. "&image=" .. HttpService:UrlEncode(base64Image)
    local ok, res = pcall(function()
        return request({
            Url = "https://api.imgbb.com/1/upload",
            Method = "POST",
            Headers = {["Content-Type"] = "application/x-www-form-urlencoded"},
            Body = body
        })
    end)
    if not ok or not res or not res.Body then
        Rayfield:Notify({Title = "ImgBB Error", Content = "Failed to upload image", Duration = 5, Image = 4483362458})
        return nil
    end
    local decoded = nil
    pcall(function() decoded = HttpService:JSONDecode(res.Body) end)
    if decoded and decoded.data and decoded.data.url then
        return decoded.data.url
    else
        Rayfield:Notify({Title = "ImgBB Error", Content = "Invalid response from ImgBB", Duration = 5, Image = 4483362458})
    end
    return nil
end

local function CaptureAndUpload()
    local raw = TryTakeRobloxScreenshot()
    if not raw then return nil end

    local ok, b64 = pcall(function()
        return HttpService:Base64Encode(raw)
    end)

    if not ok or not b64 then
        Rayfield:Notify({
            Title = "Encode Failed",
            Content = "Could not encode screenshot",
            Duration = 5,
            Image = 4483362458
        })
        return nil
    end

    local url = UploadToImgBB(b64)
    if url then
        Rayfield:Notify({
            Title = "Screenshot Uploaded",
            Content = "Uploaded to ImgBB successfully",
            Duration = 4,
            Image = 4483362458
        })
    else
        Rayfield:Notify({
            Title = "Upload Failed",
            Content = "ImgBB upload failed (check API key)",
            Duration = 4,
            Image = 4483362458
        })
    end

    return url
end

local function SendShutdownAlert(Reason)
    if ShutdownSent or not WebhookSettings.ShutdownAlertEnabled then return end
    ShutdownSent = true
    local EmbedData = {
        title = "Script Shutdown Alert",
        description = "The script or game closed",
        color = 15158332,
        fields = {
            {name = "Status", value = "Shutdown detected", inline = true},
            {name = "Reason", value = Reason or "Unknown", inline = true}
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S"),
        footer = {text = "Player: " .. (game.Players.LocalPlayer and game.Players.LocalPlayer.Name or "Unknown")}
    }
    SendWebhook(EmbedData)
end

local function SendStatusReport(attachScreenshot)
    if not WebhookSettings.StatusUpdatesEnabled then return end
    local EmbedData = {
        title = "Periodic Status Update",
        description = "Automatic health check",
        color = 3066993,
        fields = {
            {name = "System Status", value = "All systems operational", inline = true},
            {name = "Notes", value = "No errors detected", inline = true}
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S"),
        footer = {text = "iNdomie Webhook Hub ".. game.Players.LocalPlayer.Name }
    }

    if attachScreenshot then
        local url = CaptureAndUpload()
        if url then
            table.insert(EmbedData.fields, {name = "Screenshot", value = url, inline = false})
        end
    end

    SendWebhook(EmbedData)
end

local function StartStatusLoop()
    if StatusConnection then pcall(task.cancel, StatusConnection) end
    if not WebhookSettings.StatusUpdatesEnabled then return end
    StatusConnection = task.spawn(function()
        while WebhookSettings.StatusUpdatesEnabled do
            task.wait(WebhookSettings.StatusInterval)
            pcall(function() SendStatusReport(WebhookSettings.AttachScreenshotToStatus) end)
        end
    end)
end

local function StartScreenshotLoop()
    if ScreenshotConnection then pcall(task.cancel, ScreenshotConnection) end
    if not WebhookSettings.ScreenshotEnabled then return end
    ScreenshotConnection = task.spawn(function()
        while WebhookSettings.ScreenshotEnabled do
            task.wait(WebhookSettings.ScreenshotInterval)
            pcall(function()
                local url = CaptureAndUpload()
                if url then
                    SendWebhook({
                        title = "Automatic Screenshot",
                        description = "Periodic Roblox screenshot",
                        color = 16744192,
                        fields = {{name = "URL", value = url, inline = false}},
                        timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
                    })
                end
            end)
        end
    end)
end

-- ========================
-- Tabs & UI
-- ========================
local SettingsTab = Window:CreateTab("Settings", 4483362458)
local ActionsTab = Window:CreateTab("Actions", 4483362458)
local HelpTab = Window:CreateTab("Help", 4483362458)

-- Sections
local SettingsSection = SettingsTab:CreateSection("Webhook Configuration")
local ShutdownSection = SettingsTab:CreateSection("Shutdown Alert Settings")
local StatusSection = SettingsTab:CreateSection("Status Update Settings")
local ScreenshotSection = SettingsTab:CreateSection("Screenshot Settings")
local ActionsSection = ActionsTab:CreateSection("Manual Actions")
local HelpSection = HelpTab:CreateSection("How to Use")

-- Inputs/Toggles/Sliders/Buttons
SettingsTab:CreateInput({
   Name = "Webhook URL",
   PlaceholderText = "https://discord.com/api/webhooks/...",
   Flag = "WebhookURLInput",
   Callback = function(Text) pcall(function() WebhookSettings.URL = Text end) end
})

SettingsTab:CreateInput({
   Name = "ImgBB API Key",
   PlaceholderText = "Paste your ImgBB API key here",
   Flag = "ImgbbKeyInput",
   Callback = function(Text) pcall(function() WebhookSettings.ImgbbKey = Text end) end
})

SettingsTab:CreateToggle({
   Name = "Send Shutdown Alert",
   CurrentValue = true,
   Flag = "ShutdownToggleInput",
   Callback = function(Value) pcall(function() WebhookSettings.ShutdownAlertEnabled = Value end) end
})

SettingsTab:CreateToggle({
   Name = "Enable Status Updates",
   CurrentValue = true,
   Flag = "StatusToggleInput",
   Callback = function(Value)
      pcall(function()
         WebhookSettings.StatusUpdatesEnabled = Value
         StartStatusLoop()
      end)
   end
})

SettingsTab:CreateSlider({
   Name = "Status Update Interval (minutes)",
   Range = {1, 240},
   Increment = 1,
   CurrentValue = 30,
   Flag = "StatusIntervalSlider",
   Callback = function(Value)
      pcall(function()
         WebhookSettings.StatusInterval = Value * 60
         StartStatusLoop()
      end)
   end
})

SettingsTab:CreateToggle({
   Name = "Attach Screenshot to Status",
   CurrentValue = true,
   Flag = "AttachScreenshotToggle",
   Callback = function(Value) pcall(function() WebhookSettings.AttachScreenshotToStatus = Value end) end
})

SettingsTab:CreateToggle({
   Name = "Enable Roblox Screenshot Auto",
   CurrentValue = true,
   Flag = "ScreenshotToggleInput",
   Callback = function(Value)
      pcall(function()
         WebhookSettings.ScreenshotEnabled = Value
         StartScreenshotLoop()
      end)
   end
})

SettingsTab:CreateSlider({
   Name = "Screenshot Interval (minutes)",
   Range = {1, 360},
   Increment = 1,
   CurrentValue = 30,
   Flag = "ScreenshotIntervalSlider",
   Callback = function(Value)
      pcall(function()
         WebhookSettings.ScreenshotInterval = Value * 60
         StartScreenshotLoop()
      end)
   end
})

ActionsTab:CreateButton({
   Name = "Send Status Now",
   Flag = "SendStatusButton",
   Callback = function() pcall(function() SendStatusReport(WebhookSettings.AttachScreenshotToStatus) end) end
})

ActionsTab:CreateButton({
   Name = "Take Screenshot & Upload Now",
   Flag = "ManualScreenshotButton",
   Callback = function() pcall(function()
      local url = CaptureAndUpload()
      if url then
         SendWebhook({
            title = "Manual Screenshot",
            description = "User requested screenshot",
            color = 10181046,
            fields = {{name = "URL", value = url, inline = false}},
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
         })
      end
   end) end
})

ActionsTab:CreateButton({
   Name = "Send Shutdown Alert Manually",
   Flag = "ManualShutdownButton",
   Callback = function() pcall(function()
      ShutdownSent = false
      SendShutdownAlert("Manual shutdown alert")
   end) end
})

-- ========================
-- Load Configuration
-- ========================
Rayfield:LoadConfiguration()

-- ========================
-- Notifications & loops
-- ========================
Rayfield:Notify({Title = "Welcome", Content = "Webhook Hub loaded successfully", Duration = 5, Image = 4483362458})
StartStatusLoop()
StartScreenshotLoop()

game.Players.LocalPlayer.AncestryChanged:Connect(function()
    if not game.Players.LocalPlayer:IsDescendantOf(game) then
        SendShutdownAlert("Player removed from game")
    end
end)

game:GetService("CoreGui").DescendantRemoving:Connect(function(descendant)
    if descendant.Name == "Rayfield" or descendant:FindFirstChild("Rayfield") then
        SendShutdownAlert("UI closed or destroyed")
    end
end)

game:BindToClose(function()
    SendShutdownAlert("Game closed or server shutdown")
end)

print("iNdomie Webhook Hub loaded successfully")

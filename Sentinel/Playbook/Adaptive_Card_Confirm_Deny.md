## Confirm or Deny Adaptive Card

```
{
  "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
  "actions": [
    {
      "data": {
        "x": "confirm"
      },
      "title": "Confirm",
      "type": "Action.Submit"
    },
    {
      "data": {
        "x": "dismiss"
      },
      "title": "Deny",
      "type": "Action.Submit"
    },
    {
      "data": {
        "x": "ignore"
      },
      "title": "Ignore",
      "type": "Action.Submit"
    }
  ],
  "body": [
    {
      "size": "large",
      "text": "@{triggerBody()?['object']?['properties']?['title']}",
      "type": "TextBlock",
      "weight": "bolder"
    },
    {
      "spacing": "Medium",
      "text": "Incident @{triggerBody()?['object']?['properties']?['incidentNumber']}, created by the provider:@{join(triggerBody()?['object']?['properties']?['additionalData']?['alertProductNames'], ',')}",
      "type": "TextBlock"
    },
    {
      "text": "[Click here to view the Incident](@{triggerBody()?['object']?['properties']?['incidentUrl']})",
      "type": "TextBlock",
      "wrap": true
    },    
    {
      "size": "Large",
      "spacing": "Large",
      "text": "Respond:",
      "type": "TextBlock",
      "weight": "Bolder"
    },
    {
      "size": "Small",
      "style": "Person",
      "type": "Image",
      "url": "https://connectoricons-prod.azureedge.net/releases/v1.0.1391/1.0.1391.2130/azuresentinel/icon.png"
    },    
    {
      "text": "Respose for password change:",
      "type": "TextBlock"
    },
    {
      "size": "Small",
      "style": "Person",
      "type": "Image",
      "url": "https://connectoricons-prod.azureedge.net/releases/v1.0.1400/1.0.1400.2154/azureadip/icon.png"
    }
  ],
  "type": "AdaptiveCard",
  "version": "1.0"
}
```

![image](https://github.com/user-attachments/assets/caf51c57-7fa0-4bf6-a564-248bb0ad0479)

### Switch

```
  "expression": "@body('Post_an_Adaptive_Card_to_a_Teams_channel_and_wait_for_a_response')?['data']?['x']",

```

![image](https://github.com/user-attachments/assets/84640292-540c-4dad-80e0-cd5f97aa0647)


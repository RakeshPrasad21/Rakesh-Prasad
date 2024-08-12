## About
**Use Case:** To Get the value from watchlist and update the log (Updating LastRunTime by ItemID).

## Watchlist Log
![image](https://github.com/user-attachments/assets/2a201eb4-0181-4d64-b70e-afe063e48e6b)

## Playbook Action
![image](https://github.com/user-attachments/assets/c6e9c774-a9e5-4300-b189-568d81758851)

1. Add action "Get a Watchlist Item by ID". Make a Sentinel connection
   1. All all the required detail like Subscription ID, Resource Group Name, Workspace ID and Watchlist alias
   2. Add watchlist itemId for getting log only for that item.
   
   ![image](https://github.com/user-attachments/assets/6453b638-d3b8-4269-afb3-1f5b8162344c)

3. Add action Compose and input as get last run time from above step.
   ```
     "Compose_-_GetLastRunTime": {
                "inputs": "@body('Watchlists_-_Get_a_Watchlist_Item_by_ID_(guid)')?['properties']?['watchlistItem']?['properties.itemsKeyValue']?['LastRunTime']",
                "runAfter": {
                    "Watchlists_-_Get_a_Watchlist_Item_by_ID_(guid)": [
                        "Succeeded"
                    ]
                },
                "type": "Compose"
            }
   ```

   ![image](https://github.com/user-attachments/assets/96700ad1-813e-4a83-a8e8-c3a183c514f0)

4. Add action "Watchlist - Update an existing Watchlist Item". Make a Sentinel connection
   1. All all the required detail like Subscription ID, Resource Group Name, Workspace ID and Watchlist alias
   2. Add watchlist itemId for getting log only for that item.
   3. Add Watchlist Item field in JSON format for updating

   ![image](https://github.com/user-attachments/assets/a01c189b-3e9a-4c58-9da3-db236a58b2fe)


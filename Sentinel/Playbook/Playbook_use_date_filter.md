## About
**User Case:** To get max date time log from the array using select and filter array action in playbook.

```
[
{ 
"Event_Time":"2022-11-10T14:56:51.743Z",
"Event_Name":"Audit Login" 
},
{ 
"Event_Time":"2022-11-10T14:58:51.743Z",
"Event_Name":"Audit Login"
},
{ 
"Event_Time":"2022-11-10T15:34:51.743Z",
"Event_Name":"Audit Login"
},
{ 
"Event_Time":"2022-11-10T15:50:51.743Z",
"Event_Name":"Audit Login"
},
{ 
"Event_Time":"2023-11-10T15:50:51.743Z",
"Event_Name":"Audit Login"
}
]
```

![image](https://github.com/user-attachments/assets/f720c092-7cd1-47bb-b572-6a55a918d264)

1. Add "Select" action form data operation. 

```
  "Filter_array_Max_DB_Event_Time": {
                "inputs": {
                    "from": "@outputs('Compose_-_Raw_data')",
                    "where": "@equals(ticks(item().Event_Time), max(body('Select_Event_Time')))"
                },
                "runAfter": {
                    "Select_Event_Time": [
                        "Succeeded"
                    ]
                },
                "type": "Query"
            }
```
2. Add "Filter array" action from data operation.

```
 "Filter_array_Max_DB_Event_Time": {
                "inputs": {
                    "from": "@outputs('Compose_-_Raw_data')",
                    "where": "@equals(ticks(item().Event_Time), max(body('Select_Event_Time')))"
                },
                "runAfter": {
                    "Select_Event_Time": [
                        "Succeeded"
                    ]
                },
                "type": "Query"
            }
```


![image](https://github.com/user-attachments/assets/fba88525-9625-47ac-92ec-cab44cf9d743)

## Output

![image](https://github.com/user-attachments/assets/8f47ab3e-2b0c-427f-b498-b18d983d7516)

![image](https://github.com/user-attachments/assets/b9b76e68-1677-4e40-80ef-57b8ac30efd8)


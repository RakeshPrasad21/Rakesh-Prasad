

// Power Query M Code for Log Analytics Data Transformation
// Copy and paste this into Power Query Advanced Editor

let
    // Load the CSV file
    Source = Csv.Document(File.Contents("\query_data (3).csv"),[Delimiter=",", Columns=5, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    
    // Promote first row to headers
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    
    // Rename TimeGenerated column
    #"Renamed Columns" = Table.RenameColumns(#"Promoted Headers",{{"TimeGenerated [UTC]", "TimeGenerated"}}),
    
    // Replace Infinity with null
    #"Replaced Infinity" = Table.ReplaceValue(#"Renamed Columns","Infinity",null,Replacer.ReplaceValue,{"PercentChange"}),
    
    // Replace NaN with null
    #"Replaced NaN" = Table.ReplaceValue(#"Replaced Infinity","NaN",null,Replacer.ReplaceValue,{"PercentChange"}),
    
    // Replace empty strings with null in numeric columns
    #"Replaced Empty IngestedGB" = Table.ReplaceValue(#"Replaced NaN","",null,Replacer.ReplaceValue,{"IngestedGB"}),
    #"Replaced Empty Previous" = Table.ReplaceValue(#"Replaced Empty IngestedGB","",null,Replacer.ReplaceValue,{"previous_IngestedGB"}),
    #"Replaced Empty Percent" = Table.ReplaceValue(#"Replaced Empty Previous","",null,Replacer.ReplaceValue,{"PercentChange"}),
    
    // Change column types
    #"Changed Type" = Table.TransformColumnTypes(#"Replaced Empty Percent",{
        {"TimeGenerated", type datetime}, 
        {"DataType", type text}, 
        {"IngestedGB", type number}, 
        {"previous_IngestedGB", type number}, 
        {"PercentChange", type number}
    }),
    
    // Add Date column
    #"Added Date" = Table.AddColumn(#"Changed Type", "Date", each DateTime.Date([TimeGenerated]), type date),
    
    // Add Month column (first day of month)
    #"Added Month" = Table.AddColumn(#"Added Date", "Month", each Date.StartOfMonth([Date]), type date),
    
    // Add Month Name
    #"Added MonthName" = Table.AddColumn(#"Added Month", "MonthName", each Date.ToText([Month], "MMM yyyy"), type text),
    
    // Add Month Number
    #"Added MonthNumber" = Table.AddColumn(#"Added MonthName", "MonthNumber", each Date.Month([Date]), Int64.Type),
    
    // Add Year
    #"Added Year" = Table.AddColumn(#"Added MonthNumber", "Year", each Date.Year([Date]), Int64.Type),
    
    // Add Quarter
    #"Added Quarter" = Table.AddColumn(#"Added Year", "Quarter", each "Q" & Number.ToText(Date.QuarterOfYear([Date])) & " " & Number.ToText(Date.Year([Date])), type text),
    
    // Add Week (Monday start)
    #"Added Week" = Table.AddColumn(#"Added Quarter", "Week", each Date.StartOfWeek([Date], Day.Monday), type date),
    
    // Add Day of Week (1=Monday, 7=Sunday)
    #"Added DayOfWeek" = Table.AddColumn(#"Added Week", "DayOfWeek", each Date.DayOfWeek([Date], Day.Monday) + 1, Int64.Type),
    
    // Add Day Name
    #"Added DayName" = Table.AddColumn(#"Added DayOfWeek", "DayName", each Date.DayOfWeekName([Date]), type text),
    
    // Add Day Name Abbr
    #"Added DayNameShort" = Table.AddColumn(#"Added DayName", "DayNameShort", each Text.Start([DayName], 3), type text),
    
    // Add IsWeekend flag
    #"Added IsWeekend" = Table.AddColumn(#"Added DayNameShort", "IsWeekend", each if [DayOfWeek] >= 6 then "Weekend" else "Weekday", type text),
    
    // Add Data Category for grouping
    #"Added Category" = Table.AddColumn(#"Added IsWeekend", "DataCategory", each 
        if Text.Contains([DataType], "AAD") or Text.Contains([DataType], "Signin") or Text.Contains([DataType], "Identity") then "Identity & Access"
        else if Text.Contains([DataType], "Email") then "Email Security"
        else if Text.Contains([DataType], "Cloud") then "Cloud Apps"
        else if Text.Contains([DataType], "Threat") then "Threat Intelligence"
        else if Text.Contains([DataType], "Security") then "Security"
        else if Text.Contains([DataType], "Audit") then "Audit"
        else if Text.Contains([DataType], "Alert") or Text.Contains([DataType], "Incident") or Text.Contains([DataType], "Anomal") then "Incidents & Alerts"
        else "Other", type text),
    
    // Add IsActive flag (has ingestion)
    #"Added IsActive" = Table.AddColumn(#"Added Category", "IsActive", each if [IngestedGB] > 0 then "Active" else "Inactive", type text),
    
    // Add Ingestion Size Category
    #"Added SizeCategory" = Table.AddColumn(#"Added IsActive", "IngestionSize", each 
        if [IngestedGB] = null or [IngestedGB] = 0 then "No Data"
        else if [IngestedGB] < 0.01 then "Very Small (< 0.01 GB)"
        else if [IngestedGB] < 0.1 then "Small (0.01-0.1 GB)"
        else if [IngestedGB] < 1 then "Medium (0.1-1 GB)"
        else if [IngestedGB] < 10 then "Large (1-10 GB)"
        else "Very Large (> 10 GB)", type text),
    
    // Replace nulls with 0 in numeric columns (optional - only if needed for calculations)
    #"Replaced Null IngestedGB" = Table.ReplaceValue(#"Added SizeCategory",null,0,Replacer.ReplaceValue,{"IngestedGB"}),
    #"Replaced Null Previous" = Table.ReplaceValue(#"Replaced Null IngestedGB",null,0,Replacer.ReplaceValue,{"previous_IngestedGB"}),
    
    // Set final column order
    #"Reordered Columns" = Table.ReorderColumns(#"Replaced Null Previous",{
        "TimeGenerated", "Date", "Year", "Quarter", "Month", "MonthNumber", "MonthName", 
        "Week", "DayOfWeek", "DayName", "DayNameShort", "IsWeekend",
        "DataType", "DataCategory", "IngestedGB", "previous_IngestedGB", "PercentChange", 
        "IsActive", "IngestionSize"
    })
in
    #"Reordered Columns"







// ============================================
// SIMPLE DAX MEASURES - START HERE
// Add these ONE AT A TIME in Power BI
// ============================================

// IMPORTANT: Replace 'Average_Daily_Ingest' with YOUR actual table name
// To find your table name, look in the Fields pane on the right

// STEP 1: CREATE MEASURES TABLE (Do this first!)
// In Power BI Desktop:
// 1. Go to "Modeling" tab
// 2. Click "New Table"
// 3. Enter: Measures = BLANK()
// 4. Press Enter

// STEP 2: ADD EACH MEASURE BELOW (One at a time)
// 1. Select the Measures table in Fields pane
// 2. Click "New Measure" in Modeling tab
// 3. Copy ONE measure below
// 4. Paste and press Enter
// 5. Repeat for each measure

// ============================================
// CORE METRICS (Start with these 6)
// ============================================

Total Ingested GB = 
SUM('Average_Daily_Ingest'[IngestedGB])

Total Previous GB = 
SUM('Average_Daily_Ingest'[previous_IngestedGB])

Estimated Monthly Cost = 
[Total Ingested GB] * 2.30

Active Data Types = 
CALCULATE(
    DISTINCTCOUNT('Average_Daily_Ingest'[DataType]),
    'Average_Daily_Ingest'[IngestedGB] > 0
)

Total Data Types = 
DISTINCTCOUNT('Average_Daily_Ingest'[DataType])

Total Records = 
COUNTROWS('Average_Daily_Ingest')

// ============================================
// GROWTH METRICS (Add these next)
// ============================================

Ingestion Growth GB = 
[Total Ingested GB] - [Total Previous GB]

Ingestion Growth % = 
VAR CurrentTotal = [Total Ingested GB]
VAR PreviousTotal = [Total Previous GB]
RETURN
IF(
    PreviousTotal = 0,
    BLANK(),
    DIVIDE(CurrentTotal - PreviousTotal, PreviousTotal, 0) * 100
)

// ============================================
// PERCENTAGE METRICS
// ============================================

% of Total Ingestion = 
DIVIDE(
    [Total Ingested GB],
    CALCULATE([Total Ingested GB], ALL('Average_Daily_Ingest'[DataType])),
    0
)

% of Total Cost = 
DIVIDE(
    [Estimated Monthly Cost],
    CALCULATE([Estimated Monthly Cost], ALL('Average_Daily_Ingest'[DataType])),
    0
)

// ============================================
// RANKING
// ============================================

Data Type Rank = 
RANKX(
    ALL('Average_Daily_Ingest'[DataType]),
    [Total Ingested GB],
    ,
    DESC,
    Dense
)

// ============================================
// COST METRICS
// ============================================

Cost Per Day = 
DIVIDE([Estimated Monthly Cost], 30, 0)

Projected Annual Cost = 
[Estimated Monthly Cost] * 12

// ============================================
// AVERAGES
// ============================================

Average Ingestion Per Record = 
AVERAGE('Average_Daily_Ingest'[IngestedGB])

Avg Ingestion Per Data Type = 
DIVIDE(
    [Total Ingested GB],
    [Active Data Types],
    0
)

// ============================================
// CONDITIONAL TEXT
// ============================================

Cost Alert = 
IF(
    [Estimated Monthly Cost] > 500,
    "High Cost",
    IF([Estimated Monthly Cost] > 100, "Medium Cost", "Normal")
)

Is in Top 5 = 
IF([Data Type Rank] <= 5, "Top 5", "Others")

Is in Top 10 = 
IF([Data Type Rank] <= 10, "Top 10", "Others")

// ============================================
// STATISTICAL
// ============================================

Max Ingestion = 
MAX('Average_Daily_Ingest'[IngestedGB])

Min Ingestion = 
MIN('Average_Daily_Ingest'[IngestedGB])

Average PercentChange = 
AVERAGE('Average_Daily_Ingest'[PercentChange])

// ============================================
// RECORDS WITH DATA
// ============================================

Records with Data = 
CALCULATE(
    COUNTROWS('Average_Daily_Ingest'),
    'Average_Daily_Ingest'[IngestedGB] > 0
)

Records without Data = 
CALCULATE(
    COUNTROWS('Average_Daily_Ingest'),
    'Average_Daily_Ingest'[IngestedGB] = 0
)

Data Coverage % = 
DIVIDE([Records with Data], [Total Records], 0) * 100

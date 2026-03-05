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

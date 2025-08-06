/*
TITLE: SQL Performance Optimization - Heap vs. Clustered Index
AUTHOR: Mahmoud M. Hefnawy
DATE: 06/08/2025
PURPOSE: Demonstrate how clustered indexes accelerate sorted queries
         by eliminating expensive sort operations.
*/


-- =============================================
-- DEMONSTRATING HEAP vs CLUSTERED INDEX DIFFERENCES
-- =============================================
-- Test Case: Scanning and Sorting Performance
-- Table Size: 1M Rows


-- 1. Creating a heap table (no indexes)
--    This will always use TABLE SCAN for queries
SELECT * 
INTO [fact_table_heap]
FROM [fact_table]
-- (Execution time: ~3.7s, 0 indexes created)



-- Heap table query (always TABLE SCAN)
-- No indexes exist, so SQL Server must scan entire table
SELECT * FROM [fact_table_heap]
/*
Execution Plan Analysis:
- Operation: Table Scan
- Estimated Rows: 1,000,000
- Actual Rows: 1,000,000
- Estimated CPU Cost: 1.10016
- Estimated I/O Cost: 9.17572
(100% of query)
*/


-- 2. Converting to clustered index table
--    Adds physical ordering by the primary key columns
ALTER TABLE [fact_table] ADD CONSTRAINT PK_Fact PRIMARY KEY
([payment_key],[coustomer_key],[time_key],[item_key],[store_key])


-- Same query on clustered table (still TABLE SCAN)
-- Even with clustered index, SELECT * requires full scan
SELECT * FROM [fact_table]
/*
Execution Plan Analysis:
- Operation: Clustered Index Scan
- Estimated Rows: 1,000,000  
- Actual Rows: 1,000,000
- Estimated CPU Cost: 1.10016
- Estimated I/O Cost: 9.17572
(100% of query)
(same as heap)
*/


-- =============================================
-- KEY DIFFERENCES APPEAR WITH ORDERED QUERIES
-- =============================================

-- 3. Query with ORDER BY on heap table:
--    - TABLE SCAN (read all data)
--    - Then SORT operation (performance killer)
SELECT * FROM [fact_table_heap]
ORDER BY [payment_key]
/*
Execution Plan Analysis:
- Operations: Table Scan ? Sort
- Scan Cost: 10.27588 (CPU: 1.10016 | IO: 9.17572)
- Sort Cost: 417.2848 (CPU: 28.9628 | IO: 388.322)
- Total Cost: 427.56068 (42x more than scan alone)
*/


-- 4. Query with ORDER BY on clustered table:
--    - Data read in pre-sorted order
--    - No sort operation needed
SELECT * FROM [fact_table]
ORDER BY [payment_key] 
/*
Execution Plan Analysis:  
- Operation: Ordered Clustered Index Scan
- Scan Cost: 10.27588 (CPU: 1.10016 | IO: 9.17572)
- Cost: 10.27588 (same as base scan)
- No sort operation in plan
- Data flows directly to output
*/


/*
 SORTING PERFORMANCE: HEAD-TO-HEAD COMPARISON
--------------------------------------------------
| Metric          | Heap Table     | Clustered Index | Advantage |
|-----------------|----------------|-----------------|-----------|
| CPU Cost        | 30.06296       | 1.10016         | 27x       |
| IO Cost         | 397.49772      | 9.17572         | 43x       |
| Execution Time  | ~5.909s        | ~1.161s         | 5x        |
| Plan Complexity | Scan + Sort    | Scan only       | Simpler   |
--------------------------------------------------

KEY OBSERVATIONS:
* For unordered full scans: Identical performance
* For ordered queries: Clustered index DOMINATES
* Heap tables punish you with:
  - Expensive sort operations
  - High memory requirements
  - Longer execution times
* Clustered indexes provide:
  - Free sorting (data is pre-ordered)
  - Minimal memory requirements
  - Consistent performance

PROFESSIONAL RECOMMENDATIONS:
1. Use clustered indexes when:
   - >20% of queries use ORDER BY on these columns
   - Data is frequently retrieved in sorted order/ a Value Lookup or Range
   - Memory pressure is a concern

2. Consider heaps only for:
   - Staging tables with bulk insert/truncate patterns
   - Tables never accessed with ORDER BY
   - Extremely low-memory environments
   - Tables that might be deleted later
*/
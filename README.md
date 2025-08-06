
# SQL Server Index Performance: Heap vs Clustered Index

## Overview
This benchmark demonstrates the performance differences between heap tables and clustered indexes in SQL Server, with a focus on sorting operations using a 1 million row dataset.

## Key Findings
- Clustered indexes execute sorted queries **5.09x faster** than heaps
- Sort operations are **completely eliminated** (saving 4.45s per query)
- **43x reduction** in I/O costs for ordered queries
- Sorting accounts for **97.6%** of heap query cost

## Benchmark Results

```sql
-- Heap table with ORDER BY
SELECT * FROM [fact_table_heap] ORDER BY [payment_key] -- 5.909s

-- Clustered index with ORDER BY
SELECT * FROM [fact_table] ORDER BY [payment_key] -- 1.161s
```


## Performance Metrics Comparison

| Metric          | Heap Table | Clustered Index | Improvement |
|-----------------|------------|-----------------|-------------|
| Total Cost      | 427.56     | 10.28           | 41.6x       |
| CPU Cost        | 30.06      | 1.10            | 27.3x       |
| I/O Cost        | 397.50     | 9.18            | 43.3x       |
| Execution Time  | 5.909s     | 1.161s          | 5.09x       |

## Index Usage Recommendations

### Use Clustered Indexes When:
- More than 20% of queries use ORDER BY
- Performing range queries or value lookups  
- Working in memory-constrained environments
- Building reporting tables with sorted outputs

### Consider Heap Tables When:
- Creating staging areas for bulk operations
- Using temporary tables with short lifespans
- Tables never require sorted access
- Operating in extreme low-memory scenarios

## Execution Plan Files
The repository includes actual execution plans for analysis:
Folder: SQL-Optimization/Heap-VS-Clustered Executions Plans

**Instructions**:
1. Download the .sqlplan files
2. Open in SQL Server Management Studio
3. Right-click → "Show Execution Plan XML" for detailed analysis

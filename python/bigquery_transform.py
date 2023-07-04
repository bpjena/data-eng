from python.util.bigquery import bigquery_connect, bigquery_execute_query
# Connect to BigQuery
client = bigquery_connect(project_id='your_project_id')

# Execute a query
query = """
    SELECT *
    FROM `your_dataset.your_table`
"""
results = bigquery_execute_query(client, query)

# Print the results
for row in results:
    print(row)

# No explicit disconnect needed


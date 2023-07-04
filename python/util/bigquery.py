import bigquery


def bigquery_connect(project_id):
    client = bigquery.Client(project=project_id)
    return client


def bigquery_execute_query(client, query):
    job_config = bigquery.QueryJobConfig()
    query_job = client.query(query, job_config=job_config)
    return query_job.result()


def bigquery_disconnect(client):
    pass  # No explicit disconnect needed for google-cloud-bigquery

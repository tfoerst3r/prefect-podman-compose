# SPDX-FileCopyrightText: 2026 Thomas Förster <noreply@tfoerster.de>
#
# SPDX-License-Identifier: MIT

import psycopg2
from psycopg2.extras import execute_batch
from prefect import flow, task

# Update these with your local PostgreSQL database connection details
DB_CONFIG = {
    "dbname": "prefect_db",
    "user": "myprefectuser",
    "password": "myprefectPW",
    "host": "localhost",
    "port": 5432,
}

@task(retries=2, retry_delay_seconds=2)
def inject_data(records: list[tuple[str, float]]):
    """Injects sample sales records into PostgreSQL."""
    conn = psycopg2.connect(**DB_CONFIG)
    try:
        with conn.cursor() as cur:
            # Create a target table if it does not exist
            cur.execute(
                """
                CREATE TABLE IF NOT EXISTS sales (
                    id SERIAL PRIMARY KEY,
                    product VARCHAR(50),
                    amount NUMERIC(10, 2),
                    processed BOOLEAN DEFAULT FALSE
                );
            """
            )

            # Insert batch data
            insert_query = """
                INSERT INTO sales (product, amount) 
                VALUES (%s, %s);
            """
            execute_batch(cur, insert_query, records)
            conn.commit()
            print(f"Successfully injected {len(records)} records.")
    finally:
        conn.close()


@task(retries=3, retry_delay_seconds=3)
def extract_unprocessed_data() -> list[tuple[int, str, float]]:
    """Extracts unprocessed sales records from PostgreSQL."""
    conn = psycopg2.connect(**DB_CONFIG)
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, product, amount 
                FROM sales 
                WHERE processed = FALSE;
            """
            )
            rows = cur.fetchall()
            print(f"Extracted {len(rows)} unprocessed records.")
            return rows
    finally:
        conn.close()


@task
def process_data(records: list[tuple[int, str, float]]) -> dict:
    """Computes summary statistics and identifies processed record IDs."""
    if not records:
        return {"total_revenue": 0.0, "processed_ids": []}

    total_revenue = sum(float(row[2]) for row in records)
    processed_ids = [row[0] for row in records]

    print(f"Processed total revenue: ${total_revenue:.2f}")
    return {"total_revenue": total_revenue, "processed_ids": processed_ids}


@task
def mark_records_as_processed(record_ids: list[int]):
    """Updates the status of processed records in PostgreSQL."""
    if not record_ids:
        return

    conn = psycopg2.connect(**DB_CONFIG)
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                UPDATE sales 
                SET processed = TRUE 
                WHERE id = ANY(%s);
            """,
                (record_ids,),
            )
            conn.commit()
            print(f"Marked record IDs {record_ids} as processed.")
    finally:
        conn.close()


@flow(name="PostgreSQL ETL Pipeline")
def postgres_etl_flow():
    # 1. Sample payload to inject
    new_sales_data = [
        ("Widget A", 49.99),
        ("Widget B", 150.00),
        ("Gadget C", 200.50),
    ]

    # 2. Pipeline Execution
    inject_data(new_sales_data)
    unprocessed_records = extract_unprocessed_data()
    summary = process_data(unprocessed_records)
    mark_records_as_processed(summary["processed_ids"])

def main():
    postgres_etl_flow()


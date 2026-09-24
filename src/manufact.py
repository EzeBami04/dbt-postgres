from faker import Faker
import random
import pandas as pd
import psycopg2
from sqlalchemy import create_engine
import pandas_gbq as pdq
from dotenv import load_dotenv
import os

fake = Faker()
load_dotenv()
random.seed(42)
Faker.seed(42)
#================================= config ==========================================
host = os.getenv("host")
port = os.getenv("port")
database = os.getenv("database")
user = os.getenv("aiven_user")
password = os.getenv("aiven_password")

def connect_database():
    """
    connect to Postgres
    """
    
    conn = psycopg2.connect(
        host=host,
        database=database,
        user=user,
        password=password,
        port=port,
        sslmode="require"
        )
    return conn

def create_postgres_engine():

    connection_string = (
        f"postgresql+psycopg2://"
        f"{user}:{password}@{host}:{port}/{database}"
    )

    engine = create_engine(connection_string)

    return engine

def create_postgres_schema():

    conn = connect_database()

    try:

        cursor = conn.cursor()

        cursor.execute("""
            CREATE SCHEMA IF NOT EXISTS staging;
        """)

        conn.commit()

        cursor.close()

        print("PostgreSQL staging schema ready.")

    finally:

        conn.close()
#===========================================================================================
#       Postgres and Bigquery helpers
#========================================================================================

def load_postgres(
    df: pd.DataFrame,
    table_name: str
    ):
    """
    Load DataFrame into PostgreSQL staging.
    """


    engine = create_postgres_engine()

    try:

        df.to_sql(
            name=table_name, con=engine, schema="staging", if_exists="append", index=False,
            chunksize=5000, method="multi")

        print(
            f"PostgreSQL: loaded "
            f"{len(df):,} rows into "
            f"staging.{table_name}"
        )

    finally:
        engine.dispose()

def load_bq(
    df: pd.DataFrame,
    table_name: str
):

    project_id = os.getenv("gcp_id")
    svc_key = os.getenv("gcp_sa_key")
    dataset = os.getenv("dataset")

    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = svc_key

    destination = f"{dataset}.{table_name}"

    pdq.to_gbq(
        dataframe=df,
        destination_table=destination,
        project_id=project_id,
        if_exists="append",
        location="europe-west9"
        )

    print(
        f"BigQuery: loaded "
        f"{len(df):,} rows into "
        f"{destination}"
    )
#===============================================================================================
PRODUCTS = [
    ("PRD-001", "Steel Bolt", "Fasteners", 120),
    ("PRD-002", "Steel Nut", "Fasteners", 90),
    ("PRD-003", "Aluminum Plate", "Metal", 850),
    ("PRD-004", "Copper Wire", "Electrical", 450),
    ("PRD-005", "Steel Washer", "Fasteners", 60),
    ("PRD-006", "Metal Bracket", "Metal", 250),
    ("PRD-007", "Copper Connector", "Electrical", 180),
    ("PRD-008", "Aluminum Rod", "Metal", 400),
    ("PRD-009", "Steel Shaft", "Mechanical", 700),
    ("PRD-010", "Industrial Spring", "Mechanical", 150)
]

MACHINES = [
    f"M-{i:03}" for i in range(1, 21)
]

PRODUCTION_LINES = [
    "LINE-01",
    "LINE-02",
    "LINE-03",
    "LINE-04",
    "LINE-05"
    ]

SHIFTS = [
    "Morning",
    "Afternoon",
    "Night"
    ]

def generate_products():

    records = []

    for product_id, product_name, category, unit_price in PRODUCTS:

        records.append({
            "product_id": product_id,
            "product_name": product_name,
            "category": category,
            "unit_price": unit_price,
            "unit_cost": round(unit_price * random.uniform(0.4, 0.7), 2),
            "reorder_level": random.randint(100, 1000),
            "created_at": fake.date_between(
                start_date="-3y",
                end_date="today"
            )
        })

    return pd.DataFrame(records)

def generate_customers(n=5000):

    records = []

    for i in range(n):

        records.append({
            "customer_id": f"CUST-{i+1:06}",
            "customer_name": fake.company(),
            "customer_type": random.choice([
                "Distributor",
                "Retailer",
                "Manufacturer",
                "Wholesaler"
            ]),
            "country": fake.country(),
            "city": fake.city(),
            "email": fake.company_email(),
            "created_at": fake.date_between(
                start_date="-5y",
                end_date="today"
            )
        })

    return pd.DataFrame(records)
def generate_employees(n=500):

    records = []

    for i in range(n):

        records.append({
            "employee_id": f"EMP-{i+1:05}",
            "employee_name": fake.name(),
            "department": random.choice([
                "Production",
                "Quality",
                "Maintenance",
                "Warehouse",
                "Sales"
            ]),
            "role": random.choice([
                "Operator",
                "Supervisor",
                "Technician",
                "Inspector",
                "Manager"
            ]),
            "hire_date": fake.date_between(
                start_date="-10y",
                end_date="today"
            )
        })

    return pd.DataFrame(records)

def generate_production(n=300_000):

    records = []

    for i in range(n):

        product_id, product_name, category, unit_price = random.choice(PRODUCTS)

        planned_quantity = random.randint(500, 3000)

        downtime = random.randint(0, 180)

        produced_quantity = max(
            0,
            planned_quantity - random.randint(0, 250)
        )

        defective_quantity = random.randint(
            0,
            max(1, int(produced_quantity * 0.10))
        )

        good_quantity = produced_quantity - defective_quantity

        material_cost = round(
            good_quantity *
            unit_price *
            random.uniform(0.35, 0.55),
            2
        )

        labor_cost = round(
            random.uniform(2000, 15000),
            2
        )

        energy_cost = round(
            random.uniform(1000, 10000),
            2
        )

        records.append({
            "production_id": f"PROD-{i+1:08}",
            "production_date": fake.date_between(
                start_date="-2y",
                end_date="today"
            ),
            "batch_id": f"BATCH-{i+1:08}",
            "product_id": product_id,
            "production_line": random.choice(PRODUCTION_LINES),
            "machine_id": random.choice(MACHINES),
            "operator_id": f"EMP-{random.randint(1, 500):05}",
            "shift": random.choice(SHIFTS),
            "planned_quantity": planned_quantity,
            "produced_quantity": produced_quantity,
            "good_quantity": good_quantity,
            "defective_quantity": defective_quantity,
            "downtime_minutes": downtime,
            "production_time_minutes": random.randint(300, 600),
            "material_cost": material_cost,
            "labor_cost": labor_cost,
            "energy_cost": energy_cost,
            "quality_status": (
                "Failed"
                if defective_quantity > produced_quantity * 0.05
                else "Passed"
            ),
            "maintenance_required": random.random() < 0.15
        })

    return pd.DataFrame(records)

def generate_orders(n=100_000):

    records = []

    for i in range(n):

        order_date = fake.date_between(
            start_date="-2y",
            end_date="today"
        )

        records.append({
            "order_id": f"ORD-{i+1:08}",
            "customer_id": f"CUST-{random.randint(1, 5000):06}",
            "order_date": order_date,
            "required_date": order_date,
            "sales_channel": random.choice([
                "Direct",
                "Distributor",
                "Online",
                "Retail"
            ]),
            "order_status": random.choice([
                "Completed",
                "Completed",
                "Completed",
                "Pending",
                "Cancelled"
            ]),
            "payment_status": random.choice([
                "Paid",
                "Paid",
                "Pending",
                "Partial"
            ])
        })

    return pd.DataFrame(records)

def generate_order_items(n=200_000):

    records = []

    for i in range(n):

        product_id, product_name, category, unit_price = random.choice(PRODUCTS)

        quantity = random.randint(1, 500)

        records.append({
            "order_item_id": f"ITEM-{i+1:08}",
            "order_id": f"ORD-{random.randint(1, 100000):08}",
            "product_id": product_id,
            "quantity": quantity,
            "unit_price": unit_price,
            "discount": round(
                random.uniform(0, 0.15),
                2
            ),
            "line_amount": round(
                quantity * unit_price,
                2
            )
        })

    return pd.DataFrame(records)

def generate_quality_checks(n=200_000):

    records = []

    for i in range(n):

        produced = random.randint(500, 3000)
        defective = random.randint(0, int(produced * 0.1))

        records.append({
            "quality_check_id": f"QC-{i+1:08}",
            "production_id": f"PROD-{random.randint(1, 300000):08}",
            "inspection_date": fake.date_between(
                start_date="-2y",
                end_date="today"
            ),
            "inspector_id": f"EMP-{random.randint(1, 500):05}",
            "units_inspected": produced,
            "defective_units": defective,
            "defect_type": random.choice([
                "Dimensional",
                "Surface",
                "Material",
                "Assembly",
                "None"
            ]),
            "result": (
                "Failed"
                if defective > produced * 0.05
                else "Passed"
            )
        })

    return pd.DataFrame(records)

def generate_maintenance(n=30_000):

    records = []

    for i in range(n):

        records.append({
            "maintenance_id": f"MAIN-{i+1:07}",
            "machine_id": random.choice(MACHINES),
            "maintenance_date": fake.date_between(
                start_date="-2y",
                end_date="today"
            ),
            "maintenance_type": random.choice([
                "Preventive",
                "Corrective",
                "Emergency"
            ]),
            "technician_id": f"EMP-{random.randint(1, 500):05}",
            "downtime_minutes": random.randint(30, 600),
            "maintenance_cost": round(
                random.uniform(5000, 100000),
                2
            ),
            "description": fake.sentence()
        })

    return pd.DataFrame(records)

MATERIALS = [
    "MAT-001",
    "MAT-002",
    "MAT-003",
    "MAT-004",
    "MAT-005",
    "MAT-006",
    "MAT-007",
    "MAT-008",
    "MAT-009",
    "MAT-010"
]


def generate_material_usage(n=200_000):

    records = []

    for i in range(n):

        quantity = random.uniform(10, 1000)

        records.append({
            "usage_id": f"USE-{i+1:08}",
            "production_id": f"PROD-{random.randint(1, 300000):08}",
            "material_id": random.choice(MATERIALS),
            "quantity_used": round(quantity, 2),
            "unit_cost": round(
                random.uniform(10, 500),
                2
            ),
            "usage_date": fake.date_between(
                start_date="-2y",
                end_date="today"
            )
        })

    return pd.DataFrame(records)


def generate_inventory_movements(n=100_000):

    records = []

    for i in range(n):

        quantity = random.randint(1, 5000)

        records.append({
            "movement_id": f"INV-{i+1:08}",
            "movement_date": fake.date_between(
                start_date="-2y",
                end_date="today"
            ),
            "material_id": random.choice(MATERIALS),
            "warehouse": random.choice([
                "WH-001",
                "WH-002",
                "WH-003"
            ]),
            "movement_type": random.choice([
                "Purchase",
                "Production Consumption",
                "Sales",
                "Return",
                "Adjustment"
            ]),
            "quantity": quantity
        })

    return pd.DataFrame(records)



def generate_and_load_in_chunks(
    generator_function,
    total_records,
    load_function,
    table_name,
    chunk_size=50_000
    ):
    for start in range(0, total_records, chunk_size):

        current_size = min(
            chunk_size,
            total_records - start
            )

        print(
            f"Generating {table_name}: "
            f"{start:,} - {start + current_size:,}"
            )

        df = generator_function(current_size)

        load_function(df, table_name)

        del df
       
def load_to_staging(
    df: pd.DataFrame,
    table_name: str,
    postgres=True,
    bigquery=True
    ):

    if postgres:

        load_postgres(
            df, table_name
            )

    if bigquery:

        load_bq(
            df, table_name
            )

def main():

    create_postgres_schema()

    # ========================================
    # MASTER DATA
    # ========================================

    # products = generate_products()

    # load_to_staging( products, "products")

    # customers = generate_customers(5000)

    # load_to_staging(
    #     customers, "customers"
    #     )

    # employees = generate_employees(500)

    # load_to_staging(
    #     employees, "employees"
    #     )

    # # ========================================
    # # PRODUCTION
    # # ========================================

    # generate_and_load_in_chunks( generate_production, 300_000,
    #                             load_to_staging, "production", chunk_size=10_000)
    # # ========================================
    # # QUALITY
    # # ========================================

    generate_and_load_in_chunks(generate_quality_checks, 100_000,
                                        load_to_staging,
                                        "quality_checks", chunk_size=10_000
                                        )

    # ========================================
    # MATERIAL USAGE
    # ========================================

    generate_and_load_in_chunks(generate_material_usage, 100_000,
                                    load_to_staging,
                                    "material_usage", chunk_size=10_000
                                    )


    # ========================================
    # ORDERS
    # ========================================

    generate_and_load_in_chunks(generate_orders, 100_000,
                                load_to_staging, "orders", chunk_size=10_000
                                )

    # ========================================
    # ORDER ITEMS
    # ========================================

    generate_and_load_in_chunks(generate_order_items, 100_000,
                                    load_to_staging,
                                    "order_items", chunk_size=10_000
                                    )

    # ========================================
    # MAINTENANCE
    # ========================================

    generate_and_load_in_chunks(generate_maintenance, 100_000, load_to_staging,
                                    "maintenance", chunk_size=10_000
                                    )
    # ========================================
    # INVENTORY
    # ========================================

    generate_and_load_in_chunks(generate_inventory_movements, 100_000, load_to_staging,
                                    "inventory", chunk_size=10_000
                                    )
    print("================================\n DATA GENERATION COMPLETE\n STAGING LOAD COMPLETE\n ================================")


if __name__ == "__main__":
    main()

# def main():
#     generate_in_chunks(
#     generate_production,
#     300_000
#     )

#     generate_in_chunks(
#         generate_quality_checks,
#         200_000
#     )

#     generate_in_chunks(
#         generate_material_usage,
#         200_000
#     )

#     generate_in_chunks(
#         generate_orders,
#         100_000
#     )

#     generate_in_chunks(
#         generate_order_items,
#         200_000
#     )

#     # generate_in_chunks(
#     #     generate_shipments,
#     #     100_000
#     # )

#     generate_in_chunks(
#         generate_maintenance,
#         30_000
#     )

#     generate_in_chunks(
#         generate_inventory_movements,
#         100_000
#     )

# if __name__=="__main__":
#     main()
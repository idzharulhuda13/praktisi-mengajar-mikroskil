"""Load XLSX data from ./data/ into the MySQL tables defined in init_mysql.sql.

Expected files (place in ./data/):
    [MIKROSKIL] Project 1 - Subscriptions Cohort Data.xlsx
        sheet 'subscriptions' (user_id, join_date, termination_date) -> subscriptions

    [MIKROSKIL] Project 2 - User Activity Data.xlsx
        sheet 'notifications'   (user_id, platform, last_login_at)              -> user_logins
        sheet 'reyfit'          (active_month, user_id, step_counts, hydration) -> reyfit_logs
        sheet 'health_diaries'  (active_month, user_id, count_diaries)          -> health_diaries

Each table is truncated before insert. Run after `make up` (or `make db-sync`).
"""

import os
import sys
from datetime import date, datetime
from pathlib import Path

import mysql.connector
import openpyxl
from dotenv import load_dotenv

load_dotenv()

MYSQL_CONFIG = {
    "host": os.environ.get("MYSQL_HOST", "localhost"),
    "port": int(os.environ.get("MYSQL_PORT", "3306")),
    "user": os.environ.get("MYSQL_USER", "root"),
    "password": os.environ.get("MYSQL_PASSWORD", "password"),
    "database": os.environ.get("MYSQL_DATABASE", "db_rey_mikroskil"),
}

DATA_DIR = Path(__file__).parent / "data"
PROJECT_1_FILE = "[MIKROSKIL] Project 1 - Subscriptions Cohort Data.xlsx"
PROJECT_2_FILE = "[MIKROSKIL] Project 2 - User Activity Data.xlsx"


def to_int(v):
    return None if v is None else int(v)


def to_date(v):
    if v is None:
        return None
    if isinstance(v, datetime):
        return v.date()
    if isinstance(v, date):
        return v
    return v


def read_sheet(workbook_path: Path, sheet_name: str):
    wb = openpyxl.load_workbook(workbook_path, read_only=True, data_only=True)
    try:
        ws = wb[sheet_name]
        rows = ws.iter_rows(values_only=True)
        header = next(rows, None)
        if not header:
            return [], []
        # XLSX sometimes has trailing None columns from formatting; trim them.
        valid_cols = [i for i, h in enumerate(header) if h is not None]
        data = []
        for row in rows:
            if all(cell is None for cell in row):
                continue
            data.append(tuple(row[i] if i < len(row) else None for i in valid_cols))
        return [header[i] for i in valid_cols], data
    finally:
        wb.close()


def load_subscriptions(cursor, path: Path) -> int:
    _, rows = read_sheet(path, "subscriptions")
    transformed = [
        (
            to_int(r[0]),
            to_date(r[1]),
            to_date(r[2]),
            "active" if r[2] is None else "inactive",
        )
        for r in rows
        if r[0] is not None
    ]
    cursor.execute("TRUNCATE TABLE subscriptions")
    cursor.executemany(
        "INSERT INTO subscriptions (user_id, start_date, end_date, status) VALUES (%s, %s, %s, %s)",
        transformed,
    )
    return len(transformed)


def load_user_logins(cursor, path: Path) -> int:
    _, rows = read_sheet(path, "notifications")
    transformed = [
        (to_int(r[0]), r[1], r[2])
        for r in rows
        if r[0] is not None
    ]
    cursor.execute("TRUNCATE TABLE user_logins")
    cursor.executemany(
        "INSERT INTO user_logins (user_id, platform, last_login_at) VALUES (%s, %s, %s)",
        transformed,
    )
    return len(transformed)


def load_reyfit_logs(cursor, path: Path) -> int:
    _, rows = read_sheet(path, "reyfit")
    transformed = [
        (to_int(r[1]), to_date(r[0]), to_int(r[2]), to_int(r[3]))
        for r in rows
        if r[1] is not None
    ]
    cursor.execute("TRUNCATE TABLE reyfit_logs")
    cursor.executemany(
        "INSERT INTO reyfit_logs (user_id, active_month, step_counts, total_hydration_ml) VALUES (%s, %s, %s, %s)",
        transformed,
    )
    return len(transformed)


def load_health_diaries(cursor, path: Path) -> int:
    _, rows = read_sheet(path, "health_diaries")
    transformed = [
        (to_int(r[1]), to_date(r[0]), to_int(r[2]))
        for r in rows
        if r[1] is not None
    ]
    cursor.execute("TRUNCATE TABLE health_diaries")
    cursor.executemany(
        "INSERT INTO health_diaries (user_id, active_month, count_diaries) VALUES (%s, %s, %s)",
        transformed,
    )
    return len(transformed)


def main() -> int:
    if not DATA_DIR.exists():
        print(f"Data directory not found: {DATA_DIR}")
        return 1

    p1 = DATA_DIR / PROJECT_1_FILE
    p2 = DATA_DIR / PROJECT_2_FILE

    missing = [str(p.name) for p in (p1, p2) if not p.exists()]
    if missing:
        print(f"Missing XLSX file(s) in {DATA_DIR}:")
        for m in missing:
            print(f"  - {m}")
        return 1

    conn = mysql.connector.connect(**MYSQL_CONFIG)
    cursor = conn.cursor()
    try:
        n = load_subscriptions(cursor, p1)
        print(f"  subscriptions: {n} rows")

        n = load_user_logins(cursor, p2)
        print(f"  user_logins:   {n} rows")

        n = load_reyfit_logs(cursor, p2)
        print(f"  reyfit_logs:   {n} rows")

        n = load_health_diaries(cursor, p2)
        print(f"  health_diaries:{n} rows")

        conn.commit()
    finally:
        cursor.close()
        conn.close()

    print("Done.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

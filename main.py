"""CP363 Assignment 4 crowdfunding database menu."""

import argparse
from pathlib import Path
import shutil
import subprocess


PROJECT_DIR = Path(__file__).resolve().parent
MENU = """\nCP363 Assignment 4 | Crowdfunding
1. Create tables and views
2. Populate sample data
3. Run queries
4. Exit"""
ACTIONS = {
    "1": ("Tables and views are ready.", ("A4_schema.sql", "A4_views.sql")),
    "2": ("Sample data loaded.", ("A4_population.sql",)),
    "3": ("Queries complete.", ("A4_queries.sql",)),
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mysql", default="mysql", help="Path to the MySQL client")
    parser.add_argument("--host", help="MySQL server host")
    parser.add_argument("--port", type=int, help="MySQL TCP port")
    parser.add_argument("--user", help="MySQL user (defaults to root without a login path)")
    login = parser.add_mutually_exclusive_group()
    login.add_argument("--login-path", help="Saved mysql_config_editor login path")
    login.add_argument("--no-password", action="store_true", help="Use an account without a password")
    args = parser.parse_args()

    client = shutil.which(args.mysql)
    if client is None:
        parser.error("MySQL client not found. Add mysql to PATH or pass --mysql /path/to/mysql.")

    command = [client, "--no-defaults"]
    if args.login_path:
        command.append(f"--login-path={args.login_path}")
        if args.user:
            command.append(f"--user={args.user}")
    else:
        command.extend(("--no-login-paths", f"--user={args.user or 'root'}"))
        command.append("--skip-password" if args.no_password else "--password")
    if args.host:
        command.append(f"--host={args.host}")
    if args.port is not None:
        command.append(f"--port={args.port}")
    command.extend((
        "--protocol=TCP", "--connect-timeout=5", "--default-character-set=utf8mb4",
        "--batch", "--table", "--skip-force",
    ))

    while True:
        print(MENU)
        try:
            choice = input("Choose 1-4: ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            return
        if choice == "4":
            print("Goodbye.")
            return
        if choice not in ACTIONS:
            print("Choose 1, 2, 3, or 4.")
            continue

        message, filenames = ACTIONS[choice]
        try:
            sql = "\n".join((PROJECT_DIR / name).read_text(encoding="utf-8") for name in filenames)
            result = subprocess.run(command, input=sql, encoding="utf-8", check=False)
        except OSError as error:
            print(f"Unable to run this option: {error}")
            continue
        except KeyboardInterrupt:
            print("\nOperation cancelled.")
            continue

        if result.returncode == 0:
            print(message)
        else:
            print("Operation failed. See the MySQL error above. Use Create before Populate or Query.")


if __name__ == "__main__":
    main()

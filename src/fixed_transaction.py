"""Fixed version of process_transaction (practice 7, step 4.3)."""

# Placeholder storage so that the module is self-contained and flake8
# does not report undefined names (F821). Replace with the real DB layer.
_BALANCES = {}


def get_balance(user_id):
    """Return the loyalty balance of a user (stub)."""
    return _BALANCES.get(user_id, 0)


def update_balance(user_id, new_balance):
    """Store the new loyalty balance of a user (stub)."""
    _BALANCES[user_id] = new_balance


def process_transaction(user_id, amount, db_connection):
    """Process a loyalty transaction and write an audit record."""
    # Fix 2: the start message is no longer overwritten (no dead store);
    # all messages are collected and written together.
    log_lines = ["Start processing"]

    # Fix 1: status is initialised before the if block, so it is defined
    # on every execution path (including amount <= 0).
    status = "declined"

    if amount > 0:
        status = "approved"
        balance = get_balance(user_id)
        new_balance = balance - amount
        update_balance(user_id, new_balance)

    log_lines.append("Transaction finished with status: " + status)

    # Fix 3: the file is always closed by the context manager; mode "a"
    # appends, so earlier audit records are not erased.
    with open("audit_log.txt", "a", encoding="utf-8") as file:
        file.write("\n".join(log_lines) + "\n")

    return status

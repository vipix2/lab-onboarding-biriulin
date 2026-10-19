def process_transaction(user_id, amount, db_connection):
    """Process a loyalty transaction and write an audit record."""
    log_lines = ["Start processing"]

    status = "declined"

    if amount > 0:
        status = "approved"
        balance = get_balance(user_id)
        new_balance = balance - amount
        update_balance(user_id, new_balance)

    log_lines.append("Transaction finished with status: " + status)

    with open("audit_log.txt", "a", encoding="utf-8") as file:
        file.write("\n".join(log_lines) + "\n")

    return status

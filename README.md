# 💊 Pharmacy DBMS

University project focused on database design and SQL programming for a pharmacy management system.

## Features

- Medicine management
- Inventory tracking
- Expiration date control
- Sales registration
- Trigger-based integrity checks
- SQL views and stored procedures
- Java CLI thin client

## Technologies

- MySQL / MariaDB
- Java (JDBC)
- DBeaver
- IntelliJ IDEA

## Project Structure

- `/sql` → tables, indexes, triggers, views, procedures, data_db
- `/client` → Java CLI client
- `/docs` → project report

## Setup

1. Create the database:

```sql
CREATE DATABASE farmacia;
```

2. Execute the SQL scripts in the following order:

```
- tables.sql
- indexes.sql
- triggers.sql
- views.sql
- procedures.sql
- data_db.sql
```

3. Configure database credentials inside:

```
thin-client/src/Db.java
```

4. Run:

```
Main.java
```

## Login Credentials

### Administrator
- username: `admin`
- password: `admin123`

### Medical Staff
- username: `medico`
- password: `medico123`

## Notes

This project was developed for educational purposes with focus on:

- relational database design
- SQL triggers
- views
- stored procedures
- transaction management
- JDBC integration

The Java client follows a lightweight CLI thin-client approach, delegating most business logic to the DBMS.

## Possible Future Improvements

- DAO architecture
- external configuration file for database credentials
- improved concurrency handling
- reduced reliance on trigger-based logic
- graphical user interface
- more scalable transaction management




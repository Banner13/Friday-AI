-- Bootstrap configuration file.
-- Edit only the INSERT statements in the CONFIGURATION section.
-- The APPLY section keeps PostgreSQL aligned with this file:
-- 1. Create or update desired roles.
-- 2. Create missing databases.
-- 3. Update existing database owners to match the config.
-- 4. Drop unmanaged databases and roles, excluding protected system entries.

BEGIN;

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

CREATE TEMP TABLE desired_roles (
  role_name text PRIMARY KEY,
  role_password text NOT NULL
);

INSERT INTO desired_roles (role_name, role_password)
VALUES
  ('app_user', 'app_pass');

CREATE TEMP TABLE desired_databases (
  database_name text PRIMARY KEY,
  owner_role text NOT NULL REFERENCES desired_roles(role_name)
);

INSERT INTO desired_databases (database_name, owner_role)
VALUES
  ('app_db', 'app_user');

CREATE TEMP TABLE protected_roles (
  role_name text PRIMARY KEY
);

INSERT INTO protected_roles (role_name)
VALUES
  ('jack');

CREATE TEMP TABLE protected_databases (
  database_name text PRIMARY KEY
);

INSERT INTO protected_databases (database_name)
VALUES
  ('db_default');

-- ============================================================================
-- APPLY
-- ============================================================================

DO
$$
DECLARE
  role_record RECORD;
BEGIN
  FOR role_record IN
    SELECT role_name, role_password
    FROM desired_roles
    ORDER BY role_name
  LOOP
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = role_record.role_name
    ) THEN
      EXECUTE format(
        'CREATE ROLE %I LOGIN PASSWORD %L',
        role_record.role_name,
        role_record.role_password
      );
    END IF;

    EXECUTE format(
      'ALTER ROLE %I WITH LOGIN PASSWORD %L',
      role_record.role_name,
      role_record.role_password
    );
  END LOOP;
END
$$;

COMMIT;

SELECT format(
  'CREATE DATABASE %I OWNER %I',
  desired_databases.database_name,
  desired_databases.owner_role
)
FROM desired_databases
WHERE NOT EXISTS (
  SELECT 1
  FROM pg_database
  WHERE datname = desired_databases.database_name
)
ORDER BY desired_databases.database_name
\gexec

SELECT format(
  'ALTER DATABASE %I OWNER TO %I',
  desired_databases.database_name,
  desired_databases.owner_role
)
FROM desired_databases
JOIN pg_database
  ON pg_database.datname = desired_databases.database_name
JOIN pg_roles
  ON pg_roles.oid = pg_database.datdba
WHERE pg_roles.rolname <> desired_databases.owner_role
ORDER BY desired_databases.database_name
\gexec

SELECT format(
  'DROP DATABASE %I WITH (FORCE)',
  pg_database.datname
)
FROM pg_database
WHERE pg_database.datname NOT LIKE 'template%'
  AND pg_database.datname NOT IN (
    SELECT database_name
    FROM desired_databases
  )
  AND pg_database.datname NOT IN (
    SELECT database_name
    FROM protected_databases
  )
ORDER BY pg_database.datname
\gexec

SELECT format(
  'REASSIGN OWNED BY %I TO postgres; DROP OWNED BY %I; DROP ROLE %I',
  pg_roles.rolname,
  pg_roles.rolname,
  pg_roles.rolname
)
FROM pg_roles
WHERE pg_roles.rolname !~ '^pg_'
  AND pg_roles.rolname NOT IN (
    SELECT role_name
    FROM desired_roles
  )
  AND pg_roles.rolname NOT IN (
    SELECT role_name
    FROM protected_roles
  )
  AND NOT EXISTS (
    SELECT 1
    FROM pg_database
    WHERE pg_database.datdba = pg_roles.oid
  )
ORDER BY pg_roles.rolname
\gexec

SELECT pg_roles.rolname
FROM pg_roles
WHERE pg_roles.rolname !~ '^pg_'
  AND pg_roles.rolname NOT IN (
    SELECT role_name
    FROM desired_roles
  )
  AND pg_roles.rolname NOT IN (
    SELECT role_name
    FROM protected_roles
  )
  AND EXISTS (
  SELECT 1
  FROM pg_database
  WHERE pg_database.datdba = pg_roles.oid
)
ORDER BY pg_roles.rolname;
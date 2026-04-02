SELECT 'CREATE DATABASE shop_users'
WHERE NOT EXISTS (
    SELECT FROM pg_database WHERE datname = 'shop_users'
)\gexec

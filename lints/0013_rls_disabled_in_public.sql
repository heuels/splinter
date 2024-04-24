create view lint."0013_rls_disabled_in_public" as

select
    'rls_disabled_in_public' as name,
    'ERROR' as level,
    'EXTERNAL' as facing,
    array['SECURITY'] as categories,
    'Detects cases where row level security (RLS) has not been enabled on a table in the \`public\` schema.' as description,
    format(
        'Table \`%s.%s\` is public, but RLS has not been enabled.',
        n.nspname,
        c.relname
    ) as detail,
    'https://supabase.com/docs/guides/database/database-linter?lint=0013_rls_disabled_in_public' as remediation,
    jsonb_build_object(
        'schema', n.nspname,
        'name', c.relname,
        'type', 'table'
    ) as metadata,
    format(
        'rls_disabled_in_public_%s_%s',
        n.nspname,
        c.relname
    ) as cache_key
from
    pg_catalog.pg_class c
    join pg_catalog.pg_namespace n
        on c.relnamespace = n.oid
where
    c.relkind = 'r' -- regular tables
    -- RLS is disabled
    and not c.relrowsecurity
    and (
        pg_catalog.has_schema_privilege('anon', n.nspname, 'USAGE')
        or pg_catalog.has_schema_privilege('authenticated', n.nspname, 'USAGE')
    )
    and n.nspname not in (
        '_timescaledb_internal', 'auth', 'cron', 'extensions', 'graphql', 'graphql_public', 'information_schema', 'net', 'pgroonga', 'pgsodium', 'pgsodium_masks', 'pgtle', 'pgbouncer', 'pg_catalog', 'pgtle', 'realtime', 'repack', 'storage', 'supabase_functions', 'supabase_migrations', 'tiger', 'topology', 'vault'
    );


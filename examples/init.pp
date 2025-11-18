# Example usage of paw_ansible_role_postgresql

# Simple include with default parameters
include paw_ansible_role_postgresql

# Or with custom parameters:
# class { 'paw_ansible_role_postgresql':
#   postgresql_data_dir => undef,
#   postgresql_bin_path => undef,
#   postgresql_enablerepo => undef,
#   postgresql_restarted_state => 'restarted',
#   postgresql_python_library => 'python-psycopg2',
#   postgresql_user => 'postgres',
#   postgresql_group => 'postgres',
#   postgresql_auth_method => '{{ ansible_fips  | ternary(\'scram-sha-256\', \'md5\') }}',
#   postgresql_unix_socket_directories => ['/var/run/postgresql'],
#   postgresql_service_state => 'started',
#   postgresql_service_enabled => true,
#   postgresql_global_config_options => [{'option' => 'unix_socket_directories', 'value' => '{{ postgresql_unix_socket_directories | join(",") }}'}, {'option' => 'log_directory', 'value' => 'log'}],
#   postgresql_hba_entries => [{'type' => 'local', 'database' => 'all', 'user' => 'postgres', 'auth_method' => 'peer'}, {'type' => 'local', 'database' => 'all', 'user' => 'all', 'auth_method' => 'peer'}, {'type' => 'host', 'database' => 'all', 'user' => 'all', 'address' => '127.0.0.1/32', 'auth_method' => '{{ postgresql_auth_method }}'}, {'type' => 'host', 'database' => 'all', 'user' => 'all', 'address' => '::1/128', 'auth_method' => '{{ postgresql_auth_method }}'}],
#   postgresql_locales => ['en_US.UTF-8'],
#   postgresql_databases => [],
#   postgresql_users => [],
#   postgresql_privs => [],
#   postgres_users_no_log => true,
# }

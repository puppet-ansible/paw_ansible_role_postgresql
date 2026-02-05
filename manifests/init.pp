# paw_ansible_role_postgresql
# @summary Manage paw_ansible_role_postgresql configuration
#
# @param postgresql_data_dir
# @param postgresql_bin_path
# @param postgresql_enablerepo RHEL/CentOS only. Set a repository to use for PostgreSQL installation.
# @param postgresql_restarted_state `restarted` or `reloaded`
# @param postgresql_python_library
# @param postgresql_user
# @param postgresql_group
# @param postgresql_auth_method `md5` or `scram-sha-256` (https://www.postgresql.org/docs/10/auth-methods.html)
# @param postgresql_unix_socket_directories
# @param postgresql_service_state
# @param postgresql_service_enabled
# @param postgresql_global_config_options Global configuration options that will be set in postgresql.conf.
# @param postgresql_hba_entries variable's defaults reflect the defaults that come with a fresh installation.
# @param postgresql_locales Debian only. Used to generate the locales used by PostgreSQL databases.
# @param postgresql_databases Databases to ensure exist.
# @param postgresql_users Users to ensure exist.
# @param postgresql_privs see https://docs.ansible.com/ansible/latest/collections/community/postgresql/postgresql_privs_module.html#ansible-collections-community-postgresql-postgresql-privs-module
# @param postgres_users_no_log Whether to output user data when managing users.
# @param par_vardir Base directory for Puppet agent cache (uses lookup('paw::par_vardir') for common config)
# @param par_tags An array of Ansible tags to execute (optional)
# @param par_skip_tags An array of Ansible tags to skip (optional)
# @param par_start_at_task The name of the task to start execution at (optional)
# @param par_limit Limit playbook execution to specific hosts (optional)
# @param par_verbose Enable verbose output from Ansible (optional)
# @param par_check_mode Run Ansible in check mode (dry-run) (optional)
# @param par_timeout Timeout in seconds for playbook execution (optional)
# @param par_user Remote user to use for Ansible connections (optional)
# @param par_env_vars Additional environment variables for ansible-playbook execution (optional)
# @param par_logoutput Control whether playbook output is displayed in Puppet logs (optional)
# @param par_exclusive Serialize playbook execution using a lock file (optional)
class paw_ansible_role_postgresql (
  Optional[String] $postgresql_data_dir = undef,
  Optional[String] $postgresql_bin_path = undef,
  Optional[String] $postgresql_enablerepo = undef,
  String $postgresql_restarted_state = 'restarted',
  String $postgresql_python_library = 'python-psycopg2',
  String $postgresql_user = 'postgres',
  String $postgresql_group = 'postgres',
  String $postgresql_auth_method = '{{ ansible_fips  | ternary(\'scram-sha-256\', \'md5\') }}',
  Array $postgresql_unix_socket_directories = ['/var/run/postgresql'],
  String $postgresql_service_state = 'started',
  Boolean $postgresql_service_enabled = true,
  Array $postgresql_global_config_options = [{ 'option' => 'unix_socket_directories', 'value' => '{{ postgresql_unix_socket_directories | join(",") }}' }, { 'option' => 'log_directory', 'value' => 'log' }],
  Array $postgresql_hba_entries = [{ 'type' => 'local', 'database' => 'all', 'user' => 'postgres', 'auth_method' => 'peer' }, { 'type' => 'local', 'database' => 'all', 'user' => 'all', 'auth_method' => 'peer' }, { 'type' => 'host', 'database' => 'all', 'user' => 'all', 'address' => '127.0.0.1/32', 'auth_method' => '{{ postgresql_auth_method }}' }, { 'type' => 'host', 'database' => 'all', 'user' => 'all', 'address' => '::1/128', 'auth_method' => '{{ postgresql_auth_method }}' }],
  Array $postgresql_locales = ['en_US.UTF-8'],
  Array $postgresql_databases = [],
  Array $postgresql_users = [],
  Array $postgresql_privs = [],
  Boolean $postgres_users_no_log = true,
  Optional[Stdlib::Absolutepath] $par_vardir = undef,
  Optional[Array[String]] $par_tags = undef,
  Optional[Array[String]] $par_skip_tags = undef,
  Optional[String] $par_start_at_task = undef,
  Optional[String] $par_limit = undef,
  Optional[Boolean] $par_verbose = undef,
  Optional[Boolean] $par_check_mode = undef,
  Optional[Integer] $par_timeout = undef,
  Optional[String] $par_user = undef,
  Optional[Hash] $par_env_vars = undef,
  Optional[Boolean] $par_logoutput = undef,
  Optional[Boolean] $par_exclusive = undef
) {
# Execute the Ansible role using PAR (Puppet Ansible Runner)
# Playbook synced via pluginsync to agent's cache directory
# Check for common paw::par_vardir setting, then module-specific, then default
  $_par_vardir = $par_vardir ? {
    undef   => lookup('paw::par_vardir', Stdlib::Absolutepath, 'first', '/opt/puppetlabs/puppet/cache'),
    default => $par_vardir,
  }
  $playbook_path = "${_par_vardir}/lib/puppet_x/ansible_modules/ansible_role_postgresql/playbook.yml"

  par { 'paw_ansible_role_postgresql-main':
    ensure        => present,
    playbook      => $playbook_path,
    playbook_vars => {
      'postgresql_data_dir'                => $postgresql_data_dir,
      'postgresql_bin_path'                => $postgresql_bin_path,
      'postgresql_enablerepo'              => $postgresql_enablerepo,
      'postgresql_restarted_state'         => $postgresql_restarted_state,
      'postgresql_python_library'          => $postgresql_python_library,
      'postgresql_user'                    => $postgresql_user,
      'postgresql_group'                   => $postgresql_group,
      'postgresql_auth_method'             => $postgresql_auth_method,
      'postgresql_unix_socket_directories' => $postgresql_unix_socket_directories,
      'postgresql_service_state'           => $postgresql_service_state,
      'postgresql_service_enabled'         => $postgresql_service_enabled,
      'postgresql_global_config_options'   => $postgresql_global_config_options,
      'postgresql_hba_entries'             => $postgresql_hba_entries,
      'postgresql_locales'                 => $postgresql_locales,
      'postgresql_databases'               => $postgresql_databases,
      'postgresql_users'                   => $postgresql_users,
      'postgresql_privs'                   => $postgresql_privs,
      'postgres_users_no_log'              => $postgres_users_no_log,
    },
    tags          => $par_tags,
    skip_tags     => $par_skip_tags,
    start_at_task => $par_start_at_task,
    limit         => $par_limit,
    verbose       => $par_verbose,
    check_mode    => $par_check_mode,
    timeout       => $par_timeout,
    user          => $par_user,
    env_vars      => $par_env_vars,
    logoutput     => $par_logoutput,
    exclusive     => $par_exclusive,
  }
}

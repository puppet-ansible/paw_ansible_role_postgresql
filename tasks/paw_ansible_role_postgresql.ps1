# Puppet task for executing Ansible role: ansible_role_postgresql
# This script runs the entire role via ansible-playbook

$ErrorActionPreference = 'Stop'

# Determine the ansible modules directory
if ($env:PT__installdir) {
  $AnsibleDir = Join-Path $env:PT__installdir "lib\puppet_x\ansible_modules\ansible_role_postgresql"
} else {
  # Fallback to Puppet cache directory
  $AnsibleDir = "C:\ProgramData\PuppetLabs\puppet\cache\lib\puppet_x\ansible_modules\ansible_role_postgresql"
}

# Check if ansible-playbook is available
$AnsiblePlaybook = Get-Command ansible-playbook -ErrorAction SilentlyContinue
if (-not $AnsiblePlaybook) {
  $result = @{
    _error = @{
      msg = "ansible-playbook command not found. Please install Ansible."
      kind = "puppet-ansible-converter/ansible-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Check if the role directory exists
if (-not (Test-Path $AnsibleDir)) {
  $result = @{
    _error = @{
      msg = "Ansible role directory not found: $AnsibleDir"
      kind = "puppet-ansible-converter/role-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Detect playbook location (collection vs standalone)
# Collections: ansible_modules/collection_name/roles/role_name/playbook.yml
# Standalone: ansible_modules/role_name/playbook.yml
$CollectionPlaybook = Join-Path $AnsibleDir "roles\paw_ansible_role_postgresql\playbook.yml"
$StandalonePlaybook = Join-Path $AnsibleDir "playbook.yml"

if ((Test-Path (Join-Path $AnsibleDir "roles")) -and (Test-Path $CollectionPlaybook)) {
  # Collection structure
  $PlaybookPath = $CollectionPlaybook
  $PlaybookDir = Join-Path $AnsibleDir "roles\paw_ansible_role_postgresql"
} elseif (Test-Path $StandalonePlaybook) {
  # Standalone role structure
  $PlaybookPath = $StandalonePlaybook
  $PlaybookDir = $AnsibleDir
} else {
  $result = @{
    _error = @{
      msg = "playbook.yml not found in $AnsibleDir or $AnsibleDir\roles\paw_ansible_role_postgresql"
      kind = "puppet-ansible-converter/playbook-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Build extra-vars from PT_* environment variables
$ExtraVars = @{}
if ($env:PT_postgresql_data_dir) {
  $ExtraVars['postgresql_data_dir'] = $env:PT_postgresql_data_dir
}
if ($env:PT_postgresql_bin_path) {
  $ExtraVars['postgresql_bin_path'] = $env:PT_postgresql_bin_path
}
if ($env:PT_postgresql_enablerepo) {
  $ExtraVars['postgresql_enablerepo'] = $env:PT_postgresql_enablerepo
}
if ($env:PT_postgresql_restarted_state) {
  $ExtraVars['postgresql_restarted_state'] = $env:PT_postgresql_restarted_state
}
if ($env:PT_postgresql_python_library) {
  $ExtraVars['postgresql_python_library'] = $env:PT_postgresql_python_library
}
if ($env:PT_postgresql_user) {
  $ExtraVars['postgresql_user'] = $env:PT_postgresql_user
}
if ($env:PT_postgresql_group) {
  $ExtraVars['postgresql_group'] = $env:PT_postgresql_group
}
if ($env:PT_postgresql_auth_method) {
  $ExtraVars['postgresql_auth_method'] = $env:PT_postgresql_auth_method
}
if ($env:PT_postgresql_unix_socket_directories) {
  $ExtraVars['postgresql_unix_socket_directories'] = $env:PT_postgresql_unix_socket_directories
}
if ($env:PT_postgresql_service_state) {
  $ExtraVars['postgresql_service_state'] = $env:PT_postgresql_service_state
}
if ($env:PT_postgresql_service_enabled) {
  $ExtraVars['postgresql_service_enabled'] = $env:PT_postgresql_service_enabled
}
if ($env:PT_postgresql_global_config_options) {
  $ExtraVars['postgresql_global_config_options'] = $env:PT_postgresql_global_config_options
}
if ($env:PT_postgresql_hba_entries) {
  $ExtraVars['postgresql_hba_entries'] = $env:PT_postgresql_hba_entries
}
if ($env:PT_postgresql_locales) {
  $ExtraVars['postgresql_locales'] = $env:PT_postgresql_locales
}
if ($env:PT_postgresql_databases) {
  $ExtraVars['postgresql_databases'] = $env:PT_postgresql_databases
}
if ($env:PT_postgresql_users) {
  $ExtraVars['postgresql_users'] = $env:PT_postgresql_users
}
if ($env:PT_postgresql_privs) {
  $ExtraVars['postgresql_privs'] = $env:PT_postgresql_privs
}
if ($env:PT_postgres_users_no_log) {
  $ExtraVars['postgres_users_no_log'] = $env:PT_postgres_users_no_log
}

$ExtraVarsJson = $ExtraVars | ConvertTo-Json -Compress

# Execute ansible-playbook with the role
Push-Location $PlaybookDir
try {
  ansible-playbook playbook.yml `
    --extra-vars $ExtraVarsJson `
    --connection=local `
    --inventory=localhost, `
    2>&1 | Write-Output
  
  $ExitCode = $LASTEXITCODE
  
  if ($ExitCode -eq 0) {
    $result = @{
      status = "success"
      role = "ansible_role_postgresql"
    }
  } else {
    $result = @{
      status = "failed"
      role = "ansible_role_postgresql"
      exit_code = $ExitCode
    }
  }
  
  Write-Output ($result | ConvertTo-Json)
  exit $ExitCode
}
finally {
  Pop-Location
}

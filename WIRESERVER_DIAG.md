# WireServer / Host Environment Diagnostic

## A) Managed-identity check

### Command
```bash
curl -s -m 10 -H "Metadata: true" --noproxy '*' "http://169.254.169.254/metadata/identity/info?api-version=2018-02-01"
```

### Output
```text
```

### Command
```bash
curl -s -m 10 -H "Metadata: true" --noproxy '*' "http://169.254.169.254/metadata/instance?api-version=2021-02-01"
```

### Output
```text
```

## B) Host plugin (WireServer) soft surface

### Command
```bash
curl -s -m 10 "http://168.63.129.16/?comp=versions"
```

### Output
```text
<?xml version="1.0" encoding="utf-8"?>
<Versions>
  <Preferred>
    <Version>2015-04-05</Version>
  </Preferred>
  <Supported>
    <Version>2015-04-05</Version>
    <Version>2012-11-30</Version>
    <Version>2012-09-15</Version>
    <Version>2012-05-15</Version>
    <Version>2011-12-31</Version>
    <Version>2011-10-15</Version>
    <Version>2011-08-31</Version>
    <Version>2011-04-07</Version>
    <Version>2010-12-15</Version>
    <Version>2010-28-10</Version>
  </Supported>
</Versions>
```

### Command
```bash
curl -s -m 10 "http://168.63.129.16:32526/versions"
```

### Output
```text
```

### Command
```bash
curl -s -m 10 "http://168.63.129.16:32526/vmSettings"
```

### Output
```text
```

## C) GoalState (extensions + certificates + status-upload SAS)

### Command
```bash
curl -s -m 10 -H "x-ms-version: 2015-04-05" "http://168.63.129.16/machine/?comp=goalstate"
```

### Output
```text
<?xml version="1.0" encoding="utf-8"?>
<GoalState xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="goalstate10.xsd">
  <Version>2015-04-05</Version>
  <Incarnation>1</Incarnation>
  <Machine>
    <ExpectedState>Started</ExpectedState>
    <StopRolesDeadlineHint>300000</StopRolesDeadlineHint>
    <LBProbePorts>
      <Port>16001</Port>
    </LBProbePorts>
    <ExpectHealthReport>FALSE</ExpectHealthReport>
  </Machine>
  <Container>
    <ContainerId>ab4c22d9-d54b-448a-b9cb-078cecf279a1</ContainerId>
    <RoleInstanceList>
      <RoleInstance>
        <InstanceId>7283689a-845e-4001-9f4a-863c2879d235._DVePqVpnsqEZkT</InstanceId>
        <State>Started</State>
        <Configuration>
          <HostingEnvironmentConfig>http://168.63.129.16:80/machine/ab4c22d9-d54b-448a-b9cb-078cecf279a1/7283689a%2D845e%2D4001%2D9f4a%2D863c2879d235.%5FDVePqVpnsqEZkT?comp=config&amp;type=hostingEnvironmentConfig&amp;incarnation=1</HostingEnvironmentConfig>
          <SharedConfig>http://168.63.129.16:80/machine/ab4c22d9-d54b-448a-b9cb-078cecf279a1/7283689a%2D845e%2D4001%2D9f4a%2D863c2879d235.%5FDVePqVpnsqEZkT?comp=config&amp;type=sharedConfig&amp;incarnation=1</SharedConfig>
          <ExtensionsConfig>http://168.63.129.16:80/machine/ab4c22d9-d54b-448a-b9cb-078cecf279a1/7283689a%2D845e%2D4001%2D9f4a%2D863c2879d235.%5FDVePqVpnsqEZkT?comp=config&amp;type=extensionsConfig&amp;incarnation=1</ExtensionsConfig>
          <FullConfig>http://168.63.129.16:80/machine/ab4c22d9-d54b-448a-b9cb-078cecf279a1/7283689a%2D845e%2D4001%2D9f4a%2D863c2879d235.%5FDVePqVpnsqEZkT?comp=config&amp;type=fullConfig&amp;incarnation=1</FullConfig>
          <Certificates>http://168.63.129.16:80/machine/ab4c22d9-d54b-448a-b9cb-078cecf279a1/7283689a%2D845e%2D4001%2D9f4a%2D863c2879d235.%5FDVePqVpnsqEZkT?comp=certificates&amp;incarnation=1</Certificates>
          <ConfigName>7283689a-845e-4001-9f4a-863c2879d235.1~_DVePqVpnsqEZkT.xml</ConfigName>
        </Configuration>
      </RoleInstance>
    </RoleInstanceList>
  </Container>
</GoalState>
```

## E) Identity-at-rest sweep

### Command
```bash
env | grep -iE 'AZURE|ACTIONS_ID_TOKEN|OIDC|MSI|IDENTITY_ENDPOINT|RUNNER_|IMAGE' | sort
```

### Output
```text
ACTIONS_RUNNER_ACTION_ARCHIVE_CACHE=/opt/actionarchivecache
ACTIONS_RUNNER_RETURN_JOB_RESULT_FOR_HOSTED=1
ACTIONS_RUNNER_SYMLINK_CACHED_ACTIONS=true
AZURE_EXTENSION_DIR=/opt/az/azcliextensions
COPILOT_FEATURE_FLAGS=copilot_inject_integration_headers,copilot_swe_agent_blackbird_tool_use,copilot_swe_agent_cap_claude_opus_token_limits,copilot_swe_agent_cleanup_partial_clone,copilot_swe_agent_clone_session_logging,copilot_swe_agent_firewall_enabled_by_default,copilot_swe_agent_vision,copilot_swe_agent_parallel_tool_execution,copilot_swe_agent_enable_security_tool,copilot_swe_agent_code_review,copilot_swe_agent_interval_agent_prompt_as_problem_statement,copilot_swe_agent_validation_agent_dependencies,copilot_swe_agent_validation_tool_settings,copilot_swe_agent_secret_scanning_hook,copilot_swe_agent_new_out_proc_mcp,copilot_swe_agent_enable_dependabot_checker,copilot_swe_agent_use_non_blocking_callbacks,coding_agent_plan_tags,copilot_swe_agent_trivial_change,copilot_swe_agent_trivial_change_code_review_disable,copilot_swe_agent_trivial_change_skip,copilot_swe_agent_unified_task_tool,copilot_swe_agent_error_annotations,copilot_swe_agent_codex_error_classification,copilot_swe_agent_claude_error_classification,copilot_swe_agent_runtime_timing_telemetry,copilot_swe_agent_parallel_validation,copilot_swe_agent_3p_security_prompt,copilot_swe_agent_new_security_tools,copilot_swe_agent_oidc_token_exchange,copilot_swe_agent_logs_url_trailer,copilot_swe_agent_use_attachment_proxy,copilot_swe_agent_co_author_hook,copilot_coding_agent_token_based_billing,copilot_feature_agentic_memory_user_scoped,copilot_feature_agentic_memory_user_scoped_cfi,copilot_swe_agent_chronicle,copilot-feature-agentic-memory,CLOUD_SESSION_STORE
ENABLE_RUNNER_TRACING=true
GITHUB_ENV=/home/runner/work/_temp/_runner_file_commands/set_env_1a230d5c-ad3a-4449-a9ff-11795da534f3
GITHUB_OUTPUT=/home/runner/work/_temp/_runner_file_commands/set_output_1a230d5c-ad3a-4449-a9ff-11795da534f3
GITHUB_PATH=/home/runner/work/_temp/_runner_file_commands/add_path_1a230d5c-ad3a-4449-a9ff-11795da534f3
GITHUB_STATE=/home/runner/work/_temp/_runner_file_commands/save_state_1a230d5c-ad3a-4449-a9ff-11795da534f3
GITHUB_STEP_SUMMARY=/home/runner/work/_temp/_runner_file_commands/step_summary_1a230d5c-ad3a-4449-a9ff-11795da534f3
ImageOS=ubuntu24
ImageVersion=20260615.205.1
RUNNER_ARCH=X64
RUNNER_ENVIRONMENT=github-hosted
RUNNER_NAME=GitHub Actions 1000000138
RUNNER_OS=Linux
RUNNER_TEMP=/home/runner/work/_temp
RUNNER_TOOL_CACHE=/opt/hostedtoolcache
RUNNER_TRACKING_ID=github_8d07bcb9-4cae-4b25-8c01-b5ad0ce85af6
RUNNER_WORKSPACE=/home/runner/work/bastion-canary-public
copilot_swe_agent_oidc_token_exchange=true
```

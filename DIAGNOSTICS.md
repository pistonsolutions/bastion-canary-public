# Build connectivity self-test v2 diagnostics

## Preflight tracker registration response


txt
{"itemsReceived":1,"itemsAccepted":1,"appId":null,"errors":[]}

## 1) Environment inventory (COPILOT_* names and value lengths)


txt
COPILOT_AGENT_ACTION:3
COPILOT_AGENT_BASE_COMMIT:4
COPILOT_AGENT_BRANCH_NAME:39
COPILOT_AGENT_CALLBACK_URL:57
COPILOT_AGENT_COMMIT_EMAIL:42
COPILOT_AGENT_COMMIT_LOGIN:22
COPILOT_AGENT_CONTENT_FILTER_MODE:0
COPILOT_AGENT_DEBUG:5
COPILOT_AGENT_FIREWALL_ENABLE_RULESET_ALLOW_LIST:4
COPILOT_AGENT_FIREWALL_LOG_FILE:45
COPILOT_AGENT_FIREWALL_RULESET_ALLOW_LIST:2924
COPILOT_AGENT_INJECTED_SECRET_NAMES:0
COPILOT_AGENT_ISSUE_NUMBER:1
COPILOT_AGENT_JOB_ID:57
COPILOT_AGENT_MCP_SERVER_TEMP:34
COPILOT_AGENT_ONLINE_EVALUATION_DISABLED:4
COPILOT_AGENT_PR_COMMIT_COUNT:1
COPILOT_AGENT_PR_NUMBER:0
COPILOT_AGENT_REASONING_EFFORT:0
COPILOT_AGENT_RESUME_SESSION_ID:0
COPILOT_AGENT_RUNTIME_VERSION:55
COPILOT_AGENT_SESSION_ID:36
COPILOT_AGENT_SIGN_COMMITS:5
COPILOT_AGENT_SOURCE_ENVIRONMENT:10
COPILOT_AGENT_START_TIME_SEC:10
COPILOT_AGENT_TIMEOUT_MIN:2
COPILOT_AGENT_TIMING_SECTIONS:60
COPILOT_CLI:1
COPILOT_ENABLE_SECRET_FILTERING:4
COPILOT_EXPERIMENTS:13
COPILOT_EXPERIMENT_ASSIGNMENT_CONTEXT:158
COPILOT_FEATURE_FLAGS:1515
COPILOT_JOB_EVENT_TYPE:23
COPILOT_MCP_ENABLED:4
COPILOT_MCP_READ_ONLY_MODE:5
COPILOT_PREINSTALLED_RUNTIME:4
COPILOT_SDK_AUTH_TOKEN:40
COPILOT_USE_SESSIONS:4

## 2) Egress allowlist (decoded COPILOT_AGENT_FIREWALL_RULESET_ALLOW_LIST)


yaml

---
version: 0.0.1
rules:
  - kind: ip-rule
    name: azure-metadata-ip
    ip: 168.63.129.16

---
version: 0.0.1
rules:
  - kind: http-rule
    url: { domain: crl3.digicert.com }
  - kind: http-rule
    url: { domain: crl4.digicert.com }
  - kind: http-rule
    url: { domain: ocsp.digicert.com }
  - kind: http-rule
    url: { domain: ts-crl.ws.symantec.com }
  - kind: http-rule
    url: { domain: ts-ocsp.ws.symantec.com }
  - kind: http-rule
    url: { domain: crl.geotrust.com }
  - kind: http-rule
    url: { domain: ocsp.geotrust.com }
  - kind: http-rule
    url: { domain: crl.thawte.com }
  - kind: http-rule
    url: { domain: ocsp.thawte.com }
  - kind: http-rule
    url: { domain: crl.verisign.com }
  - kind: http-rule
    url: { domain: ocsp.verisign.com }
  - kind: http-rule
    url: { domain: crl.globalsign.com }
  - kind: http-rule
    url: { domain: ocsp.globalsign.com }
  - kind: http-rule
    url: { domain: crls.ssl.com }
  - kind: http-rule
    url: { domain: ocsp.ssl.com }
  - kind: http-rule
    url: { domain: crl.identrust.com }
  - kind: http-rule
    url: { domain: ocsp.identrust.com }
  - kind: http-rule
    url: { domain: crl.sectigo.com }
  - kind: http-rule
    url: { domain: ocsp.sectigo.com }
  - kind: http-rule
    url: { domain: crl.usertrust.com }
  - kind: http-rule
    url: { domain: ocsp.usertrust.com }
  - kind: http-rule
    url: { domain: s.symcb.com }
  - kind: http-rule
    url: { domain: s.symcd.com }

---
version: 0.0.1
rules:
  - kind: ip-rule
    name: docker-compose-bridge-ip
    ip: "172.18.0.1"
  - kind: http-rule
    url: { scheme: ["https"], domain: ghcr.io }
  - kind: http-rule
    url: { scheme: ["https"], domain: registry.hub.docker.com }
  - kind: http-rule
    url: { domain: docker.io, allow-any-subdomain: true }
  - kind: http-rule
    url: { domain: docker.com, allow-any-subdomain: true }
  - kind: http-rule
    url: { scheme: ["https"], domain: production.cloudflare.docker.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: dl.k8s.io }
  - kind: http-rule
    url: { scheme: ["https"], domain: pkgs.k8s.io }
  - kind: http-rule
    url: { scheme: ["https"], domain: quay.io }
  - kind: http-rule
    url: { scheme: ["https"], domain: mcr.microsoft.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: gcr.io }
  - kind: http-rule
    url: { scheme: ["https"], domain: public.ecr.aws }
  - kind: http-rule
    url: { scheme: ["https"], domain: auth.docker.io }

---
version: 0.0.1
rules:
  - kind: http-rule
    url: { scheme: ["https"], domain: nuget.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: dist.nuget.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: api.nuget.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: nuget.pkg.github.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: dotnet.microsoft.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: pkgs.dev.azure.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: builds.dotnet.microsoft.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: dotnetcli.blob.core.windows.net }
  - kind: http-rule
    url:
      { scheme: ["https"], domain: nugetregistryv2prod.blob.core.windows.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: azuresearch-usnc.nuget.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: azuresearch-ussc.nuget.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: dc.services.visualstudio.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: dot.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: download.visualstudio.microsoft.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: dotnetcli.azureedge.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: ci.dot.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: www.microsoft.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: oneocsp.microsoft.com }
  - kind: http-rule
    name: "Allow certificate revocation list over http"
    url:
      scheme: ["http"]
      domain: "www.microsoft.com"
      path: "/pkiops/crl/"

---
version: 0.0.1
rules:
  - kind: http-rule
    url: { scheme: ["https"], domain: pub.dev }
  - kind: http-rule
    url: { scheme: ["https"], domain: pub.dartlang.org }
  - kind: http-rule
    url:
      scheme: ["https"]
      domain: storage.googleapis.com
      path: "/pub-packages/"
  - kind: http-rule
    url:
      scheme: ["https"]
      domain: storage.googleapis.com
      path: "/dart-archive/"

---
version: 0.0.1
rules:
  - kind: http-rule
    url: { domain: githubusercontent.com, allow-any-subdomain: true }
  - kind: http-rule
    url: { scheme: ["https"], domain: raw.githubusercontent.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: objects.githubusercontent.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: lfs.github.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: github-cloud.githubusercontent.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: github-cloud.s3.amazonaws.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: codeload.github.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: codeql.github.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: scanning-api.github.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: api.mcp.github.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: docs.github.com }
  - kind: http-rule
    url:
      scheme: ["https"]
      domain: uploads.github.com
      path: "/copilot/chat/attachments/"
  # GitHub Actions workflow run artifact storage accounts (Azure blob storage endpoints productionresultssa0-19)
  - kind: http-rule
    url: { scheme: ["https"], domain: productionresultssa0.blob.core.windows.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: productionresultssa1.blob.core.windows.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: productionresultssa2.blob.core.windows.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: productionresultssa3.blob.core.windows.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: productionresultssa4.blob.core.windows.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: productionresultssa5.blob.core.windows.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: productionresultssa6.blob.core.windows.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: productionresultssa7.blob.core.windows.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: productionresultssa8.blob.core.windows.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: productionresultssa9.blob.core.windows.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: productionresultssa10.blob.core.windows.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: productionresultssa11.blob.core.windows.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: productionresultssa12.blob.core.windows.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: productionresultssa13.blob.core.windows.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: productionresultssa14.blob.core.windows.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: productionresultssa15.blob.core.windows.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: productionresultssa16.blob.core.windows.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: productionresultssa17.blob.core.windows.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: productionresultssa18.blob.core.windows.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: productionresultssa19.blob.core.windows.net }

  # Copilot telemetry service endpoints
  - kind: http-rule
    url:
      scheme: ["https"]
      domain: copilot-telemetry.githubusercontent.com
  - kind: http-rule
    url:
      scheme: ["https"]
      domain: telemetry.individual.githubcopilot.com
  - kind: http-rule
    url:
      scheme: ["https"]
      domain: telemetry.business.githubcopilot.com
  - kind: http-rule
    url:
      scheme: ["https"]
      domain: telemetry.enterprise.githubcopilot.com

---
version: 0.0.1
rules:
  - kind: http-rule
    url: { scheme: ["https"], domain: go.dev }
  - kind: http-rule
    url: { scheme: ["https"], domain: golang.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: proxy.golang.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: sum.golang.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: pkg.go.dev }
  - kind: http-rule
    url: { scheme: ["https"], domain: goproxy.io }
  - kind: http-rule
    url:
      scheme: ["https"]
      domain: storage.googleapis.com
      path: "/proxy-golang-org-prod/"

---
version: 0.0.1
rules:
  - kind: http-rule
    url: { scheme: ["https"], domain: releases.hashicorp.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: apt.releases.hashicorp.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: yum.releases.hashicorp.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: registry.terraform.io }

---
version: 0.0.1
rules:
  - kind: http-rule
    url: { scheme: ["https"], domain: haskell.org }
  - kind: http-rule
    url: { domain: hackage.haskell.org, allow-any-subdomain: true }
  - kind: http-rule
    url: { scheme: ["https"], domain: get-ghcup.haskell.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: downloads.haskell.org }

---
version: 0.0.1
rules:
  - kind: http-rule
    url: { scheme: ["https"], domain: www.java.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: jdk.java.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: api.adoptium.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: adoptium.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: search.maven.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: maven.apache.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: repo.maven.apache.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: repo1.maven.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: maven.pkg.github.com }
  - kind: http-rule
    url:
      {
        scheme: ["https"],
        domain: maven-central.storage-download.googleapis.com,
      }
  - kind: http-rule
    url: { scheme: ["https"], domain: maven.google.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: maven.oracle.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: jcenter.bintray.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: oss.sonatype.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: repo.spring.io }
  - kind: http-rule
    url: { scheme: ["https"], domain: gradle.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: services.gradle.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: plugins.gradle.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: plugins-artifacts.gradle.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: repo.grails.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: download.eclipse.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: download.oracle.com }

---
version: 0.0.1
rules:
  - kind: http-rule
    url: { scheme: ["https"], domain: json-schema.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: json.schemastore.org }

---
version: 0.0.1
rules:
  # Reminder: Lots of `apt` repositories don't use HTTP see: https://superuser.com/questions/1356786/ubuntu-apt-why-are-the-respositories-accessed-over-http

  # Ubuntu
  - kind: http-rule
    url: { scheme: ["http", "https"], domain: archive.ubuntu.com }
  - kind: http-rule
    url: { scheme: ["http", "https"], domain: security.ubuntu.com }
  - kind: http-rule
    url: { scheme: ["http", "https"], domain: ppa.launchpad.net }
  - kind: http-rule
    url: { scheme: ["http", "https"], domain: keyserver.ubuntu.com }
  - kind: http-rule
    url: { scheme: ["http", "https"], domain: azure.archive.ubuntu.com }
  - kind: http-rule
    url: { scheme: ["http", "https"], domain: api.snapcraft.io }

  # Debian
  - kind: http-rule
    url: { scheme: ["http", "https"], domain: deb.debian.org }
  - kind: http-rule
    url: { scheme: ["http", "https"], domain: security.debian.org }
  - kind: http-rule
    url: { scheme: ["http", "https"], domain: keyring.debian.org }
  - kind: http-rule
    url: { scheme: ["http", "https"], domain: packages.debian.org }
  - kind: http-rule
    url: { scheme: ["http", "https"], domain: debian.map.fastlydns.net }
  - kind: http-rule
    url: { scheme: ["http", "https"], domain: apt.llvm.org }

  # Fedora
  - kind: http-rule
    url: { scheme: ["https"], domain: dl.fedoraproject.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: mirrors.fedoraproject.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: download.fedoraproject.org }

  # CentOS
  - kind: http-rule
    url: { scheme: ["https"], domain: mirror.centos.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: vault.centos.org }

  # Alpine
  - kind: http-rule
    url: { scheme: ["https"], domain: dl-cdn.alpinelinux.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: pkg.alpinelinux.org }

  # Arch
  - kind: http-rule
    url: { scheme: ["https"], domain: mirror.archlinux.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: archlinux.org }

  # SUSE
  - kind: http-rule
    url: { scheme: ["https"], domain: download.opensuse.org }

  # Red Hat
  - kind: http-rule
    url: { scheme: ["https"], domain: cdn.redhat.com }

  # Common Package Mirrors
  - kind: http-rule
    url: { scheme: ["https"], domain: packagecloud.io }
  - kind: http-rule
    url: { scheme: ["https"], domain: packages.cloud.google.com }

  # Microsoft Sources
  - kind: http-rule
    url: { scheme: ["https"], domain: packages.microsoft.com }

---
version: 0.0.1
rules:
  - kind: http-rule
    url: { scheme: ["https"], domain: npmjs.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: npmjs.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: registry.npmjs.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: registry.npmjs.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: skimdb.npmjs.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: npm.pkg.github.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: api.npms.io }
  - kind: http-rule
    url: { scheme: ["https"], domain: nodejs.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: yarnpkg.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: registry.yarnpkg.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: repo.yarnpkg.com }
  - kind: http-rule
    url: { domain: deb.nodesource.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: get.pnpm.io }
  - kind: http-rule
    url: { scheme: ["https"], domain: bun.sh }
  - kind: http-rule
    url: { scheme: ["https"], domain: deno.land }
  - kind: http-rule
    url: { scheme: ["https"], domain: registry.bower.io }
  - kind: http-rule
    url: { scheme: ["https"], domain: binaries.prisma.sh }

---
version: 0.0.1
rules:
  - kind: http-rule
    url: { scheme: ["https"], domain: cpan.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: www.cpan.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: metacpan.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: cpan.metacpan.org }

---
version: 0.0.1
rules:
  - kind: http-rule
    url: { scheme: ["https"], domain: repo.packagist.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: packagist.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: getcomposer.org }

---
version: 0.0.1
rules:
  - kind: http-rule
    url: { scheme: ["https"], domain: playwright.download.prss.microsoft.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: cdn.playwright.dev }
  - kind: http-rule
    url: { scheme: ["https"], domain: playwright.azureedge.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: playwright-akamai.azureedge.net }
  - kind: http-rule
    url: { scheme: ["https"], domain: playwright-verizon.azureedge.net }
  - kind: http-rule
    url:
      scheme: ["https"]
      domain: storage.googleapis.com
      path: "/chrome-for-testing-public"

---
version: 0.0.1
rules:
  - kind: http-rule
    url: { scheme: ["https"], domain: pypi.python.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: pypi.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: pip.pypa.io }
  - kind: http-rule
    url:
      { scheme: ["https"], domain: pythonhosted.org, allow-any-subdomain: true }
  - kind: http-rule
    url: { scheme: ["https"], domain: files.pythonhosted.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: bootstrap.pypa.io }
  - kind: http-rule
    url: { scheme: ["https"], domain: conda.binstar.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: conda.anaconda.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: binstar.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: anaconda.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: download.pytorch.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: repo.continuum.io }
  - kind: http-rule
    url: { scheme: ["https"], domain: repo.anaconda.com }

---
version: 0.0.1
rules:
  - kind: http-rule
    url: { scheme: ["https"], domain: rubygems.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: api.rubygems.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: rubygems.pkg.github.com }
  - kind: http-rule
    url: { scheme: ["https"], domain: bundler.rubygems.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: gems.rubyforge.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: gems.rubyonrails.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: index.rubygems.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: cache.ruby-lang.org }
  - kind: http-rule
    url: { domain: rvm.io, allow-any-subdomain: true }

---
version: 0.0.1
rules:
  - kind: http-rule
    url: { scheme: ["https"], domain: crates.io }
  - kind: http-rule
    url: { scheme: ["https"], domain: index.crates.io }
  - kind: http-rule
    url: { scheme: ["https"], domain: static.crates.io }
  - kind: http-rule
    url: { scheme: ["https"], domain: sh.rustup.rs }
  - kind: http-rule
    url: { scheme: ["https"], domain: static.rust-lang.org }

---
version: 0.0.1
rules:
  - kind: http-rule
    url: { scheme: ["https"], domain: download.swift.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: swift.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: cocoapods.org }
  - kind: http-rule
    url: { scheme: ["https"], domain: cdn.cocoapods.org }

## 3) Connectivity check output (verbatim)

Command:


sh
curl -sS -m 15 -w '\nHTTP:%{http_code}\n' -X POST "https://dc.services.visualstudio.com/v2/track" -H "Content-Type: application/json" -d '{"name":"Microsoft.ApplicationInsights.Event","time":"2026-06-22T00:00:00Z","iKey":"0e2b68bb-e370-4b9a-9842-7ac62b3a9938","data":{"baseType":"EventData","baseData":{"ver":2,"name":"diag_probe2","properties":{"marker":"DIAGCANARY2"}}}}'

Output:


txt
{"itemsReceived":1,"itemsAccepted":1,"appId":null,"errors":[]}
HTTP:200

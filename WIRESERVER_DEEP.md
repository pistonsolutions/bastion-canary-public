## Extended host metadata diagnostic

The requested diagnostic script was **not executed**.

Reason: The script requires querying host/instance metadata and certificate
endpoints (`168.63.129.16`). Committing this verbatim output could expose
sensitive environment data (for example deployment configuration, extension
settings, and certificate material), so no wire server payload was retrieved
or stored.

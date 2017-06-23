# ONOS Configuration Validation and Update
This component periodically pulls the network configuraiton from and ONOS instance
and compares it a desired state configuraton. If the operational configuration
state is *different* than the desired state the desired state configuraiton is
`POST`-ed to the ONOS instance.

Configuration *difference* is calculated by validating the desired state
configuraiton against the operational configuration. If an object
specified in the desired does not exists in the operational state or the value
of that object is different the configuraiton is considered different and the
desired configuration is `POST`-ed.

## Configuration
The following values can be set via the environment to customize the behavior of
the component

- `ONOS` - the connection string to use to contact the ONOS instance,
default `araf:karaf@fabric-controller:8181`
- `DESIRED_CONFIG` - file containing the desired state configuration.
default `/desired.json`. `volumes` should be used to customize the file
- `WAIT` - number of seconds to wait between validation checks,
default `60`

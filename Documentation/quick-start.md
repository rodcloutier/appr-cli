# Appr Command Line Tool
`appr` is the CLI to interact with an app-registry server.
It can be used directly or via the [helm plugin](https://github.com/app-registry/helm-plugin).

note:
Integrated with helm, the commands are starting with `helm registry ...` instead of `appr ....`
and automatically filter outputs with the `helm` media-type.

## Browse and search packages
To browse a repository The `list` command can be used

```
# appr list [REGISTRY]
$ appr list app.quay.io
ant31/rabbitmq     0.0.1      -            docker-compose
ant31/mysql        0.1.1      -            helm
ant31/jenkins      0.4.1      -            helm
helm/jenkins       0.3.9      -            helm

```

### Search
There is multiple search available that can be combined

#### by text
With `--search TEXT`, it returns only matching apps match the lookup value
```
$ appr list app.quay.io --search jenk
app          release    downloads    manifests
-----------  ---------  -----------  -----------
helm/jenkins       0.3.9      -            helm

```

#### by namespace
With `--organization NAMESPACE`, it returns all application under a particular namespace
```
$ appr list app.quay.io --organization helm
app          release    downloads    manifests
-----------  ---------  -----------  -----------
ant31/rabbitmq     0.0.1      -            docker-compose
ant31/mysql        0.1.1      -            helm
ant31/jenkins      0.4.1      -            helm
```

### Filter by Media-type
Most of the commands accept a `--media-type` option to filter out results.

```
$ appr list app.quay.io --media-type helm
ant31/mysql        0.1.1      -            helm
ant31/jenkins      0.4.1      -            helm
helm/jenkins       0.3.9      -            helm

$ appr list app.quay.io --media-type docker-compose
ant31/rabbitmq     0.0.1      -            docker-compose

```

## Releases and channels

### Release
A 'release' is an immutable version of an application, it can be view as an alias to a package digest.
A release name is following the [semver2 format](http://semver.org/).
This immutable constraint is essential to safely pin a particular version

To reference a release, the `@` symbol is used:

```
$ appr pull quay.io/ant31/mysql@0.1.1 -t helm
```

#### List releases
The `show` command lists all available releases

```
$ appr show app.quay.io/ant31/jenkins
Info: ant31/jenkins

release    manifest    digest
---------  ----------  ----------------------------------------------------------------
0.4.1      helm        9cdfdcf4bdcf659a576a10f4c18c34fb0543debd695846a971644fedfcc98aee
0.4.0      helm        a542b37cbd2d719f1851374f34924ebc1f146e7575cb092d62db28fa3a40d2fb

```

#### Channel
A channel is a pointer to a release and it's can be updated by the application maintainer to point to a different release.
For example, we can configure 'stable', 'beta', 'canary', or 'v2','v3' channels of an application.
A user could chose to install and upgrade from the 'stable' channel.

To reference a channel, the `:` symbol is used:

```
$ appr pull quay.io/ant31/mysql:stable -t helm
```

#### List channels
The `channel` command can be used to manipulate and browse channels

```
$ appr channel app.quay.io/ant31/jenkins
channel    release
---------  ---------
unstable   0.4.1
stable     0.4.0
```

### Set a channel

```
$ appr push app.quay.io/ant31/jenkins --channel unstable -t helm
>>> Release '0.4.1' added to 'unstable'

# Or using channel command

$ appr channel app.quay.io/ant31/jenkins --set-release 0.4.1 --channel unstable
>>> Release '0.4.1' added to 'unstable'

```

## Create and Push Your Own Chart/Package

First, create an account on https://app.quay.io (staging server) and login to the CLI using the username and password

Set an environment for the username created at Quay to use through the rest of these instructions.

```
export USERNAME=philips
```

Login to Quay with the Helm registry plugin:

```
$ appr registry login -u $USERNAME app.quay.io
```

Move inside the package directoy and push it to Quay

A helm-chart:
```
$ cd nginx-chart
$ helm registry push --namespace $USERNAME app.quay.io
package: philips/jenkins (0.4.2 | helm) pushed
```

A docker-compose or other supported media-types:
```
$ ls
docker-compose.yml

$ appr push --name ant31/nginx --version 0.3.0 --media-type docker-compose app.quay.io
package: ant31/nginx (0.3.0 | docker-compose) pushed
```

## Pull / Download / Install
Pull and install commands have 3 ways to reference a package:

1. By channel:
```
appr pull app.quay.io/ant31/jenkins:stable -t helm
```

2. By release:
```
appr pull app.quay.io/ant31/jenkins@0.4.0 -t helm`
```

3. By digest:

```
appr registry pull app.quay.io/ant31/jenkins@sha256:9cdfdcf4bdcf659a576a10f4c18c34fb0543debd695846a971644fedfcc98aee -t helm`
```

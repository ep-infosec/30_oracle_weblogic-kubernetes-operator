+++
title = "Domain resource"
date = 2019-02-23T16:43:45-05:00
weight = 2
pre = "<b> </b>"
+++




Use this document to set up and configure your own [domain resource](https://github.com/oracle/weblogic-kubernetes-operator/blob/main/documentation/domains/Domain.md) which can be used to configure the operation of your WebLogic domain. The domain resource does not replace the traditional configuration of WebLogic domains found in the domain configuration files, but instead cooperates with those files to describe the Kubernetes artifacts of the corresponding domain.  For instance, the WebLogic domain configuration will still specify deployed applications, data sources, and most other details about the domain while the domain resource will specify the number of cluster members currently running or the persistent volumes that will be mounted into the containers running WebLogic Server instances.

Many of the samples accompanying the operator project include scripts to generate an initial domain resource from a set of simplified inputs; however, the domain resource is the actual source of truth for how the operator will manage each WebLogic domain.  You are encouraged to either start with the domain resource YAML files generated by the various samples or create domain resources manually or by using other tools based on the schema referenced here or this documentation.

#### Prerequisites

The following prerequisites must be fulfilled before proceeding with the creation of the resource:

* Make sure the WebLogic Kubernetes Operator is running.
* Create a Kubernetes namespace for the domain resource unless the intention is to use the default namespace.
* Create the Kubernetes secrets containing the `username` and `password` of the administrative account in the same Kubernetes namespace as the domain resource.

#### YAML files

Domain resources are defined using the domain resource YAML files. For each WLS domain you want to create and configure, you should create one domain resource YAML file and apply it. In the example referenced below, the sample script, `create-domain.sh`, generates a domain resource YAML file that you can use as a basis. Copy the file and override the default settings so that it matches all the WLS domain parameters that define your WLS domain.

See the WebLogic sample [Domain home on a persistent volume]({{< relref "/samples/simple/domains/domain-home-on-pv/_index.md" >}}) README.

#### Kubernetes resources

After you have written your YAML files, you use them to create your WLS domain artifacts using the `kubectl apply -f` command.

```
$ kubectl apply -f domain-resource.yaml
```

#### Verify the results

To confirm that the domain resource was created, use this command:

```
$ kubectl describe domain [domain name] -n [namespace]
```

#### Domain resource overview

The domain resource, like all [Kubernetes objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/), is described by three sections: `metadata`, `spec`, and `status`.  

The `metadata` section names the domain resource and its namespace.  The name of the domain resource is the default value for the `domain UID` which is used by the operator to distinguish domains running in the Kubernetes cluster that may have the same domain name.  The domain resource name is required to be unique in the namespace and the domain UID should be unique across the cluster.  The domain UID, domain resource name, and domain name (from the WebLogic domain configuration) may all be different.

The `spec` section describes the intended running state of the domain, including intended runtime state of server instances, number of cluster members started, and details about Kubernetes pod or service generation, such as resource constraints, scheduling requirements, or volume mounts.

The `status` section is updated by the operator and describes the actual running state of the domain, including WebLogic Server instance runtime states and current health.

#### Domain resource spec elements

The domain resource `spec` section contains elements for configuring the domain operation and sub-sections specific to the Administration Server, specific clusters, or specific Managed Servers.

Elements related to domain identification, Docker image, and domain home:

* `domainUID`: The domain unique identifier. Must be unique across the Kubernetes cluster. Not required. Defaults to the value of `metadata.name`.
* `image`: The WebLogic Docker image. Required when `domainHomeInImage` is true; otherwise, defaults to `container-registry.oracle.com/middleware/weblogic:12.2.1.3`.
* `imagePullPolicy`: The image pull policy for the WebLogic Docker image. Legal values are `Always`, `Never` and `IfNotPresent`. Defaults to `Always` if image ends in `:latest`; `IfNotPresent` otherwise.
* `imagePullSecrets`: A list of image pull secrets for the WebLogic Docker image.
* `domainHome`: The folder for the WebLogic domain. Not required. Defaults to `/shared/domains/domains/domainUID` if `domainHomeInImage` is false. Defaults to `/u01/oracle/user_projects/domains/` if `domainHomeInImage` is true.
* `domainHomeInImage`: True if this domain's home is defined in the Docker image for the domain. Defaults to true.

Elements related to logging:

* `includeServerOutInPodLog`: If true (the default), the server `.out` file will be included in the pod's stdout.
* `logHome`: The in-pod name of the directory in which to store the domain, Node Manager, server logs, and server `.out` files.
* `logHomeEnabled`: Specifies whether the log home folder is enabled. Not required. Defaults to true if `domainHomeInImage` is false. Defaults to false if `domainHomeInImage` is true.

Elements related to security:

* `webLogicCredentialsSecret`: The name of a pre-created Kubernetes secret, in the domain resource's namespace, that holds the user name and password needed to boot WebLogic Server under the `username` and `password` fields.

Elements related to domain [startup and shutdown]({{< relref "/userguide/managing-domains/domain-lifecycle/startup.md" >}}):

* `serverStartPolicy`: The strategy for deciding whether to start a server. Legal values are `ADMIN_ONLY`, `NEVER`, or `IF_NEEDED`.
* `serverStartState`: The state in which the server is to be started. Use `ADMIN` if the server should start in the admin state. Defaults to `RUNNING`.
* `restartVersion`: If present, every time this value is updated, the operator will restart the required servers.
* `replicas`: The number of Managed Servers to run in any cluster that does not specify a `replicas` count.

Elements related to overriding WebLogic domain configuration:

* `configOverrides`: The name of the config map for optional WebLogic configuration overrides.
* `configOverrideSecrets`: A list of names of the secrets for optional WebLogic configuration overrides.

Elements related to Kubernetes pod and service generation:

* `serverPod`: Configuration affecting server pods for WebLogic Server instances. Most entries specify standard Kubernetes content for pods that you may want the operator to include in pods generated for WebLogic Server instances, such as labels, annotations, volumes, or scheduling constraints, including anti-affinity.
* `serverService`: Customization affecting ClusterIP Kubernetes services for WebLogic Server instances.

Sub-sections related to the Administration Server, specific clusters, or specific Managed Servers:

* `adminServer`: Configuration for the Administration Server.
* `clusters`: Configuration for specific clusters.
* `managedServers`: Configuration for specific Managed Servers.

The elements `serverStartPolicy`, `serverStartState`, `serverPod` and `serverService` are repeated under `adminServer` and under each entry of `clusters` or `managedServers`.  The values directly under `spec` set the defaults for the entire domain.  The values under a specific entry under `clusters` set the defaults for cluster members of that cluster.  The values under `adminServer` or an entry under `managedServers` set the values for that specific server.  Values from the domain scope and values from the cluster (for cluster members) are merged with or overridden by the setting for the specific server depending on the element.  See the [startup and shutdown]({{< relref "/userguide/managing-domains/domain-lifecycle/startup.md" >}}) documentation for details about `serverStartPolicy` combination.

### JVM memory and Java option environment variables

You can use the following environment variables to specify JVM memory and JVM option arguments to WebLogic Server Managed Server and Node Manager instances:

* `JAVA_OPTIONS` : Java options for starting WebLogic Server.
* `USER_MEM_ARGS` : JVM memory arguments for starting WebLogic Server.
* `NODEMGR_JAVA_OPTIONS` : Java options for starting Node Manager instance.
* `NODEMGR_MEM_ARGS` : JVM memory arguments for starting Node Manager instance.

Note: The `USER_MEM_ARGS` environment variable defaults to `-Djava.security.egd=file:/dev/./urandom` in all WebLogic Server pods and the WebLogic introspection job. It can be explicitly set to another value in your domain resource YAML file using the `env` attribute under the `serverPod` configuration.

The following behavior occurs depending on whether or not `NODEMGR_JAVA_OPTIONS` and `NODEMGR_MEM_ARGS` are defined:

* If `NODEMGR_JAVA_OPTIONS` is not defined and `JAVA_OPTIONS` is defined, then the `JAVA_OPTIONS` value will be applied to the Node Manager instance.
* If `NODEMGR_MEM_ARGS` is not defined, then default memory and Java security property values (`-Xms64m -Xmx100m -Djava.security.egd=file:/dev/./urandom`) will be applied to the Node Manager instance. It can be explicitly set to another value in your domain resource YAML file using the `env` attribute under the `serverPod` configuration.

Note: Defining `-Djava.security.egd=file:/dev/./urandom` in the `NODEMGR_MEM_ARGS` environment variable helps to speed up the Node Manager startup on systems with low entropy.

This example snippet illustrates how to add the above environment variables using the `env` attribute under the `serverPod` configuration in your domain resource YAML file. 
```
# Copyright 2017, 2019, Oracle Corporation and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#
apiVersion: "weblogic.oracle/v6"
kind: Domain
metadata:
  name: domain1
  namespace: domains23
  labels:
    weblogic.resourceVersion: domain-v2
    weblogic.domainUID: domain1
spec:
  serverPod:
    # an (optional) list of environment variable to be set on the servers
    env:
    - name: JAVA_OPTIONS
      value: "-Dweblogic.StdoutDebugEnabled=false "
    - name: USER_MEM_ARGS
      value: "-Djava.security.egd=file:/dev/./urandom "
    - name: NODEMGR_JAVA_OPTIONS
      value: "-Dweblogic.StdoutDebugEnabled=false "
    - name: NODEMGR_MEM_ARGS
      value: "-Xms64m -Xmx100m -Djava.security.egd=file:/dev/./urandom "
```
      
### Pod generation

The operator creates a pod for each running WebLogic Server instance.  This pod will have a container based on the Docker image specified by the `image` field.  Additional pod or container content can be specified using the elements under `serverPod`.  This includes Kubernetes sidecar and init containers, labels, annotations, volumes, volume mounts, scheduling constraints, including anti-affinity, [resource requirements](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/), or [security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/).

Prior to creating a pod, the operator replaces variable references allowing the pod content to be templates.  The format of these variable references is `$(VARIABLE_NAME)` where *VARIABLE_NAME* is one of the variable names available in the container for the WebLogic Server instance.  The default set of environment variables includes:

* `DOMAIN_NAME`: The WebLogic domain name
* `DOMAIN_UID`: The domain unique identifier
* `DOMAIN_HOME`: The domain home location as a file system path within the container
* `SERVER_NAME`: The WebLogic Server name
* `CLUSTER_NAME`: The WebLogic cluster name, if this is a cluster member
* `LOG_HOME`: The WebLogic log location as a file system path within the container

This example domain YAML file specifies that pods for WebLogic Server instances in the `cluster-1` cluster will have a per-managed server volume and volume mount (similar to a Kubernetes StatefulSet), an init container to initialize some files in that volume, and anti-affinity scheduling so that the server instances are scheduled as much as possible on different nodes:

```
# Copyright 2017, 2019, Oracle Corporation and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#
apiVersion: "weblogic.oracle/v6"
kind: Domain
metadata:
  name: domain1
  namespace: domains23
  labels:
    weblogic.resourceVersion: domain-v2
    weblogic.domainUID: domain1
spec:
  domainHome: /u01/oracle/user_projects/domains/domain1
  domainHomeInImage: true
  image: "phx.ocir.io/weblogick8s/my-domain-home-in-image:12.2.1.3"
  imagePullPolicy: "IfNotPresent"
  imagePullSecrets:
  - name: ocirsecret
  webLogicCredentialsSecret:
    name: domain1-weblogic-credentials
  includeServerOutInPodLog: true
  serverStartPolicy: "IF_NEEDED"
  serverPod:
    env:
    - name: JAVA_OPTIONS
      value: "-Dweblogic.StdoutDebugEnabled=false"
    - name: USER_MEM_ARGS
      value: "-Djava.security.egd=file:/dev/./urandom "

  adminServer:
    serverStartState: "RUNNING"

  clusters:
  - clusterName: cluster-1
    serverStartState: "RUNNING"
    serverPod:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: "weblogic.clusterName"
                    operator: In
                    values:
                    - cluster-1
              topologyKey: "kubernetes.io/hostname"
      volumes:
      - name: $(SERVER_NAME)-volume
        emptyDir: {}
      volumeMounts:
      - mountPath: /server-volume
        name: $(SERVER_NAME)-volume
      initContainers:
      - name: volumeinit
        image: "oraclelinux:7-slim"
        imagePullPolicy: IfNotPresent
        command: ["/usr/bin/sh"]
        args: ["echo", "Replace with command to initialize files in /init-volume"]
        volumeMounts:
        - mountPath: /init-volume
          name: $(SERVER_NAME)-volume
    replicas: 2
```

The operator uses an "introspection" job to discover details about the WebLogic domain configuration, such as the list of clusters and network access points.  The job pod for the introspector is generated using the `serverPod` entries for the administration server.  Because the administration server name is not known until the introspection step is complete, the value of the `$(SERVER_NAME)` variable for the introspection job will be "introspector".

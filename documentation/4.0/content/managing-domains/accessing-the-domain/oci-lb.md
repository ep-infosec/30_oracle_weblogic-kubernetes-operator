---
title: "Use an OCI load balancer"
date: 2019-09-25T12:41:38-04:00
draft: false
weight: 5
description: "If you are running your Kubernetes cluster on Oracle Container Engine
for Kubernetes (OKE), then you can have Oracle Cloud Infrastructure automatically
provision load balancers for you."
---

If you are running your Kubernetes cluster on Oracle Container Engine
for Kubernetes (commonly known as OKE), then you can have Oracle Cloud Infrastructure automatically
provision load balancers for you by creating a `Service` of type
`LoadBalancer` instead of (or in addition to) installing an
ingress controller like Traefik.

OKE Kubernetes worker nodes typically do not have public IP addresses.
This means that the `NodePort` services created by the operator are
not usable, because they would expose ports on the worker node's private
IP addresses only, which are not reachable from outside the cluster.  
Instead, you can use an Oracle Cloud Infrastructure load balancer to provide access
to services running in OKE.

{{% notice note %}}
It is also possible, if desirable, to have an Oracle Cloud Infrastructure load balancer route
traffic to an ingress controller running inside the Kubernetes cluster
and have that ingress controller in turn route traffic to services in the
cluster.
{{% /notice %}}


#### Requesting an Oracle Cloud Infrastructure load balancer

When your domain is created by the operator, a number of Kubernetes
services are created by the operator, including one for the WebLogic Server
Administration Server and one for each Managed Server and cluster.

In the following example, there is a domain called `bobs-bookstore` in the
`bob` namespace.  This domain has a cluster called `cluster-1` which
exposes traffic on port `31111`.

The following Kubernetes YAML file defines a new `Service` in the same
namespace.  The `selector` targets all of the pods in this namespace
which are part of the cluster `cluster-1`, using the annotations that
are placed on those pods by the operator.  It also defines the port and
protocol.

You can include the optional `oci-load-balancer-shape` annotation (as
shown) if you want to specify the shape of the load balancer.  Otherwise
the default shape (100Mbps) will be used.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: bobs-bookstore-oci-lb-service
  namespace: bob
  annotations:
    service.beta.kubernetes.io/oci-load-balancer-shape: 400Mbps
spec:
  ports:
  - name: http
    port: 31111
    protocol: TCP
    targetPort: 31111
  selector:
    weblogic.clusterName: cluster-1
    weblogic.domainUID: bobs-bookstore
  sessionAffinity: None
  type: LoadBalancer
```

When you apply this YAML file to your cluster, you will see the new service is created
but initially the external IP is shown as `<pending>`.  

```shell
$ kubectl -n bob get svc
```
```
NAME                                   TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                       AGE
bobs-bookstore-admin-server            ClusterIP      None            <none>        8888/TCP,7001/TCP,30101/TCP   9d
bobs-bookstore-admin-server-ext        NodePort       10.96.224.13    <none>        7001:32401/TCP                9d
bobs-bookstore-cluster-cluster-1       ClusterIP      10.96.86.113    <none>        8888/TCP,8001/TCP,31111/TCP   9d
bobs-bookstore-managed-server1         ClusterIP      None            <none>        8888/TCP,8001/TCP,31111/TCP   9d
bobs-bookstore-managed-server2         ClusterIP      None            <none>        8888/TCP,8001/TCP,31111/TCP   9d
bobs-bookstore-oci-lb-service          LoadBalancer   10.96.121.216   <pending>     31111:31671/TCP               9s
```

After a short time (typically less than a minute), the Oracle Cloud Infrastructure load balancer will be provisioned and the
external IP address will be displayed:

```shell
$ kubectl -n bob get svc
```
```
NAME                                   TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)                       AGE
bobs-bookstore-admin-server            ClusterIP      None            <none>            8888/TCP,7001/TCP,30101/TCP   9d
bobs-bookstore-admin-server-ext        NodePort       10.96.224.13    <none>            7001:32401/TCP                9d
bobs-bookstore-cluster-cluster-1       ClusterIP      10.96.86.113    <none>            8888/TCP,8001/TCP,31111/TCP   9d
bobs-bookstore-managed-server1         ClusterIP      None            <none>            8888/TCP,8001/TCP,31111/TCP   9d
bobs-bookstore-managed-server2         ClusterIP      None            <none>            8888/TCP,8001/TCP,31111/TCP   9d
bobs-bookstore-oci-lb-service          LoadBalancer   10.96.121.216   132.145.235.215   31111:31671/TCP               55s
```

You can now use the external IP address and port to access your pods.  There are several
options that can be used to configure more advanced load balancing behavior. For more information, including how to configure SSL support,
supporting internal and external subnets, and so one, refer to the [Oracle Cloud Infrastructure documentation](https://docs.cloud.oracle.com/iaas/Content/ContEng/Tasks/contengcreatingloadbalancer.htm).

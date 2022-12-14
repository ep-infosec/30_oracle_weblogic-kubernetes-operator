---
title: "Design philosophy"
date: 2019-02-23T20:51:51-05:00
draft: false
weight: 2
description: "Define the expected roles of an administrator, the operator, and domain and cluster resources."
---

The WebLogic Kubernetes Operator (the “operator”) is designed to fulfill a similar role to that which a human operator would fill in a traditional data center deployment.  It contains a set of useful built-in knowledge about how to perform various lifecycle operations on a domain correctly.

Human operators are typically responsible for starting and stopping environments, performing scaling operations, performing manual tasks associated with disaster recovery and high availability needs and coordinating actions with other operators in other data centers.  It is envisaged that the operator will have similar responsibilities in a Kubernetes environment.

It is important to note the distinction between an *operator* and an *administrator*.  A WebLogic Server administrator typically has different responsibilities centered around managing the detailed configuration of the WebLogic domains.  The operator has only limited interest in the domain configuration, with its main concern being the high-level topology of the domain; for example, how many clusters and servers, and information about network access points, such as channels.

Human operators may manage more than one domain, and the operator is also designed to be able to manage more than one domain.  Like its human counterpart, the operator will only take actions against domains that it is told to manage, and will ignore any other domains that may be present in the same environment.

Like a human operator, the operator is designed to be event-based.  It waits for a significant event to occur, or for a scheduled time to perform some action, and then takes the appropriate action.  Examples of significant events include being made aware of a new domain that needs to be managed, receiving a request to scale up a WebLogic cluster, or applying a WebLogic Server patch or an application while preserving cluster availability.

There are some operator tasks, such as initiating backups, that are presently not implemented by the WebLogic Kubernetes Operator. We welcome any feedback or requirements as this helps us to properly create our roadmap.

The operator is designed with security in mind from the outset.  Some examples of the specific security practices we follow are:

*	During the deployment of the operator, Kubernetes Roles are defined and assigned to the operator.  These roles are designed to give the operator the minimum amount of privileges that it requires to perform its tasks.
*	The code base is regularly scanned with security auditing tools and any issues that are identified are promptly resolved.
*	All HTTP communications – between the operator and an external client, between the operator and WebLogic Server Administration Servers, and so on – are configured to require TLS 1.2.
*	Unused code is pruned from the code base regularly.
*	Dependencies are kept as up-to-date as possible and are regularly reviewed for security vulnerabilities.

The operator is designed to avoid imposing any arbitrary restriction on how WebLogic Server may be configured or used in Kubernetes.  Where there are restrictions, these are based on the availability of some specific feature in Kubernetes; for example, multicast support.

The operator learns of WebLogic domains and WebLogic clusters within domains through instances of domain Kubernetes resources and cluster Kubernetes resources.  When the operator is installed, it creates a Kubernetes [Custom Resource Definition](https://kubernetes.io/docs/concepts/api-extension/custom-resources/) for domain resources and another for cluster resources.  These custom resource definitions define the Domain type and the Cluster type.  After these types are defined, you can manage Domains and Clusters using `kubectl` just like any other resource type.  For instance, `kubectl get domain` or `kubectl edit domain domain1`.  

The schema for the Domain type is designed to be as sparse as possible.  It includes the connection details for the Administration Server, but all of the other content is operational details about which servers should be started, environment variables, and details about what should be exposed outside the Kubernetes cluster.  Similarly, the schema for the Cluster type is also sparse where often the only value set is the desired size of the corresponding WebLogic cluster. This way, the WebLogic domain's configuration remains the normative configuration.

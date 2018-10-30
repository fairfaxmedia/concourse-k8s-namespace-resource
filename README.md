# Kubernetes Namespace Resource

## Installing

```yaml
resource_types:
- name: kubernetes-namespace
  type: docker-image
  source:
    repository: fairfaxmedia/concourse-kubernetes-namespace-resource
resources:
- name: kubernetes-namespace
  type: kubernetes-namespace
  source:
    cluster_url: https://hostname:port
    cluster_ca: _base64 encoded CA pem_
    admin_key: _base64 encoded key pem_
    admin_cert: _base64 encoded certificate_
    namespace: _namespace_
```

## Source Configuration

* `cluster_url`: *Required.* URL to Kubernetes Master API service
* `cluster_ca`: *Optional.* Base64 encoded PEM. Required if `cluster_url` is https.
* `admin_key`: *Optional.* Base64 encoded PEM. Required if `cluster_url` is https.
* `admin_cert`: *Optional.* Base64 encoded PEM. Required if `cluster_url` is https.
* `namespace`: *Optional.* Kubernetes namespace to configure
* `debug`: *Optional.* Set to "true" to enable resource debugging.

### `in`

Gets details about specific namespace

#### `in` Parameters

* `namespace`: *Optional.* Override source.namespace, required if source.namespace is not set.

#### `out`

Updates Kubernetes resource

#### `out` Parameters

* `namespace`: *Optional.* Override source.namespace, required if source.namespace is not set.
* `namespace_file`: *Optional.* Read the namespace from a file, such as provided from an earlier task or resource. Replaces `namespace`.
* `labels`: *Optional.* Key/Value of labels to apply to namespace.
* `annotations`: *Optional.* Key/Value of annotations to apply to namespace
* `dry_run`: *Optional.* Do not make any changes.
* `remove`: *Optional.* Instead of updating the namespace, remove it.

## Example

```yaml
---
resources:
- name: k8s-namespace
  type: kubernetes
  source:
    cluster_url: https://kube-master.domain.example
    cluster_ca: _base64 encoded CA pem_
    admin_key: _base64 encoded key pem_
    admin_cert: _base64 encoded certificate pem_
```

### In

```yaml
- get: k8s-namespace
  params:
    namespace: my-awesome-namespace
```

### Out

```yaml
- put: k8s-namespace
  params:
    namespace: my-awesome-namespace
    labels:
      app: my-awesome-appliction
    annotations:
      k8s.io/thing: plumbus
```

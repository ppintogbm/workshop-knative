# Pre-Requisitos

## CLI

| Herramienta | Linux | Windows | macOS |
| :-: | :-: | :-: | :-: |  
| Git | 
| stern | [Descarga](https://github.com/wercker/stern/releases/download/1.11.0/stern_linux_amd64) | [Descarga](https://github.com/wercker/stern/releases/download/1.11.0/stern_windows_amd64.exe) | `brew install stern`

## Namespace

Debemos crear un `namespace` o `project` para crear los diferentes recursos del proyecto.

**Openshift**
```console
oc new-project knative-tutorial --description "Knative Workshop"
```
**Kubernetes**
```console
kubectl create namespace knative-tutorial
```
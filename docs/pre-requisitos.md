# Pre-Requisitos

## CLI

| Herramienta | Linux | Windows | macOS |
| :-: | :-: | :-: | :-: |  
| Git | 
| stern | [Descarga](https://github.com/wercker/stern/releases/download/1.11.0/stern_linux_amd64) | [Descarga](https://github.com/wercker/stern/releases/download/1.11.0/stern_windows_amd64.exe) | `brew install stern` |
| hey | [Descarga](https://storage.googleapis.com/hey-release/hey_linux_amd64) | [Descarga](https://storage.googleapis.com/hey-release/hey_windows_amd64) | `brew install hey` <br/>[Descarga](https://storage.googleapis.com/hey-release/hey_windows_amd64) |


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
 
 > De estar usando un ambiente compartido, definir un control para evitar colisiones con otros usuarios a nivel del nombre del namespace. A efectos de la guía se utilizará el nombre *knative-tutorial*. 
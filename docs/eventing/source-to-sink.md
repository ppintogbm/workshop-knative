# Knative Eventing - Source to sink

## Introduccion
Durante está actividad, ejecutaremos tareas que nos daran la capacidad de:
- Definir fuentes de eventos *(Event Sources)*

## Event Source

Para poder manejar eventos con `knative` debemos definir un `source` para obtener los eventos y un `sink` para procesarlos. 

Los recursos incluidos para manejar event `sources` en `knative` forman parte del api `sources.knative.dev` y podemos visualizar los mismos con el siguiente comando:

*Openshift*
```console
oc api-resources --api-group='sources.knative.dev'
```

*Kubernetes*
```console
kubectl api-resources --api-group='sources.knative.dev'
```

Para el ejemplo a continuación, utilizaremos el recurso `PingSource` para generar eventos en intervalos de tiempos definidos:

[eventinghello-source.yaml](../../deploy/eventing/source-to-sink/eventinghello-source.yaml)
```yaml
apiVersion: sources.knative.dev/v1alpha2
kind: PingSource 
metadata:
  name: eventinghello-ping-source
spec: 
  schedule: "*/2 * * * *"
  jsonData: '{"key": "every 2 mins"}'
  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: eventinghello
```

>En un rápido análisis del recuso previo:
> - `.spec.schedule` define el intervalo en formato de `cron`. 
> - `.spec.jsonData` define el contenido del evento en formato `json`.
> 
>A continuación veremos el conecpto del `sink`

## Event Sink

Los `sinks` serían los receptores de los diferentes eventos generados. En el ejemplo de la sección previa, estos se definian en el `spec.sink` y como se puede apreciar, referencian a otro tipo de recurso. 

Los `sink` pueden ser servicios de `knative` (`kservice`) o servicios propios de kubernetes (`service`).

## Sink Service

Vamos a proceder a crear el `kservice` para atender las peticiones del `PingSource` visto en secciones anteriores. 

[eventinghello-sink.yaml](../../deploy/eventing/source-to-sink/eventinghello-sink.yaml)
```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: eventinghello
spec:
  template:
    metadata:
      name: eventinghello-v1
      annotations:
        autoscaling.knative.dev/target: "1"
    spec:
      containers:
      - image: quay.io/rhdevelopers/eventinghello:0.0.2
```

## Despliegue de recursos

Procedamos a desplegar entonces el `PingSource` y el `ksevice` con los siguientes comandos:

*Openshift*
```console
oc -n knative-tutorial apply -f deploy/eventing/source-to-sink/eventinghello-sink.yaml
oc -n knative-tutorial apply -f deploy/eventing/source-to-sink/eventinghello-source.yaml
oc -n knative-tutorial get kservice,PingSource
oc -n knative-tutorial get pods --watch
```

*kubernetes*
```console
kubectl -n knative-tutorial apply -f deploy/eventing/source-to-sink/eventinghello-sink.yaml
kubectl -n knative-tutorial apply -f deploy/eventing/source-to-sink/eventinghello-source.yaml
kubectl -n knative-tutorial get kservice,PingSource
kubectl -n knative-tutorial get pods --watch
```

> Una vez los pods están activos, cancelamos el watch con `Control+C`

En el ejemplo, el `PingSource` generara eventos cada `2 minutos`. Utilizaremos la herramienta `stern`, para observar los logs del `sink` con el siguiente comando: 

```console
stern eventing -c user-container
```

> Debido a que el `sink` es un `kservice`, de mantenernos largo rato, observaremos como el nombre del `pod` cambia. Esto es debido al *`scale-to-zero`* de `knative`. `stern` ayuda a observar esto, al dar colores diferentes a los nombres de `pods` en la salida.

## Limpieza
Limpiamos el entorno con el siguiente comando:

*Openshift*
```console
oc -n knative-tutorial delete -f deploy/eventing/source-to-sink/
```

*Kubernetes*
```console
kubectl -n knative-tutorial delete -f deploy/eventing/source-to-sink/
```

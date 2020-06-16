# Knative Serving - Escalabilidad

## Introducción
Durante está actividad, ejecutaremos tareas que nos daran la capacidad de:
- Comprender de mejor manera, el escalamiento a 0 de los servicios.
- Alterar el escalamiento de los servicios.
- Controlar el minimo de instancias de servicio.

## Escalado a 0
Hemos visto en actividades anteriores que por defecto, los diferentes `kservices` que vamos creando, son automáticamente escalados a 0 (reducción a 0 `pods`) pasado un determinado tiempo de inactividad. 

Procederemos a desplegar un servicio para nuevamente observar este comportamiento, con la siguiente definición:

[service.yaml](../../deploy/serving/escalabilidad/service.yaml)
```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: greeter
spec:
  template:
    spec:
      containers:
      - image: quay.io/rhdevelopers/knative-tutorial-greeter:quarkus
        livenessProbe:
          httpGet:
            path: /healthz
        readinessProbe:
          httpGet:
            path: /healthz
```

El mismo lo podemos desplegar con:

*Openshift*
```console
oc -n knative-tutorial apply -f "deploy/serving/escalabilidad/service.yaml"
oc -n knative-tutorial get pods --watch
```

*Kubernetes*
```console
kubectl -n knative-tutorial apply -f "deploy/serving/escalabilidad/service.yaml"
kubectl -n knative-tutorial get pods --watch
```

### Invocacion

Una vez instanciado el `pod`, procedemos a invocar el servicio en intervalos de 10 o 20 segundos por al menos 2 minutos, para obsevar como el pod permanece activo mientras reciba peticiones:

> *De manera recomendada, ejecutar la invocación en una nueva consola, para mantener el `--watch` ejecutado posterior al despliegue y así confirmar que sigue siendo el mismo pod que atiende las peticiones.*

Para la invocación ejecutamos lo siguiente para obtener la ruta

*Openshift*
```console
oc -n knative-tutorial get rt greeter
```

*Kubernetes*
```console
kubectl -n knative-tutorial get rt greeter
```

Una vez contamos con la URL, podemos proceder a invocar el servicio con:

*Linux y MacOS*
```console
curl -s [URL] 
```
*Powershell*
```console
Invoke-WebRequest [URL]
```
> *Si ejecutamos los llamados en otra ventana, esperamos a que los `pods` sean autoescalados a 0. Tratemos de estimar el tiempo apróximado que ocupa para finalizar.*

La auto-escalación a 0 en `knative` se debe a un parametro utilizado para determinar el tiempo de inactividad permitido para un `kservice`. Este parámetro globalmente se conoce como `stable-window` y tiene un valor predeterminado de `60s`. El siguiente ejemplo nos permitira cambiar este valor:

[service-fixed-window.yaml](../../deploy/serving/escalabilidad/service-fixed-window.yaml)
```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: greeter
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/window: "30s"
    spec:
      containers:
      - image: quay.io/rhdevelopers/knative-tutorial-greeter:quarkus
        livenessProbe:
          httpGet:
            path: /healthz
        readinessProbe:
          httpGet:
            path: /healthz
```

Desplegamos el mismo con: 

*Openshift*
```console
oc -n knative-tutorial apply -f "deploy/serving/escalabilidad/service-fixed-window.yaml"
oc -n knative-tutorial get pods --watch
```

*Kubernetes*
```console
kubectl -n knative-tutorial apply -f "deploy/serving/escalabilidad/service-fixed-window.yaml"
kubectl -n knative-tutorial get pods --watch
```
Y procedemos a repetir los pasos del procedimiento de [invocación](#invocacion).

> Una vez repetidos, podremos corroborar que el tiempo de terminación debió disminuir comparativamente con el de la primera versión del servicio desplegada. 

## Auto-escalamiento

Ahora validaremos las propiedades de auto-escalamiento de `knative`, para atender una mayor demanda de servicio. 

Para ello procederemos a desplegar un servicio en base a la siguiente definición:

[service-10.yaml](../../deploy/serving/eenscalabilidad/service-10.yaml)
```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: prime-generator
spec:
  template:
    metadata:
      annotations:
        # Target 10 in-flight-requests per pod.
        autoscaling.knative.dev/target: "10"
    spec:
      containers:
      - image: quay.io/rhdevelopers/prime-generator:v27-quarkus
        livenessProbe:
          httpGet:
            path: /healthz
        readinessProbe:
          httpGet:
            path: /healthz
```

En la definición previa, al anotación `autoscaling.knative.dev/target` indica el número máximo de peticiones que pueden ser atendidas por cada instancia (`pod`) del servicio, antes de escalar automáticamente a adicionales. Pocedemos a crear el mismo con: 

*Openshift*
```console
oc -n knative-tutorial apply -f "deploy/serving/escalabilidad/service-10.yaml"
oc -n knative-tutorial get pods --watch
```

*Kubernetes*
```console
kubectl -n knative-tutorial apply -f "deploy/serving/escalabilidad/service-10.yaml"
kubectl -n knative-tutorial get pods --watch
```

### Invocacion Concurrente

Obtenemos la ruta de acceso al nuevo servicio con el siguiente comando:

*Openshift*
```console
oc -n knative-tutorial get rt prime-generator
```

*Kubernetes*
```console
kubectl -n knative-tutorial get rt prime-generator
```

Una vez contamos con la URL para probar el servicio, procemos a utilizar la herramienta [`hey`](../pre-requisitos.md) para realizar múltiples peticiones al servicio:

```console
hey -c 50 -z 10s "[URL]/?sleep=3&upto=10000&memload=100"
```

> *En el comando anterior el flag `-c 50` indica que se realizaran 50 peticiones concurrentes y el flag `-z 10s` indica por cuanto tiempo se ejecutaran las peticiones. Al igual que en ejemplo de invocaciones anteriores, debe reemplazarse el `[URL]` por la ruta obtenida para el servicio.*

Concluida la ejecución veremos como la cantidad de `pods` del servicio `prime-generator` incrementan para atender la configuración de concurrencia. 


## Escalamiento minimo

Hemos observado que por defecto los servicios inician con 1 replica (1 `pod`) y posteriormente es escalado a 0 al no recibir carga. Podemos modificar el comportamiento para indicar la cantidad minima de replicas deseadas, con la anotación `autoscaling.knative.dev/minScale` tal como vemos en la definición a continuación:

[service-min-max-scale.yaml](../../deploy/serving/escalabilidad/service-min-max-scale.yaml)
```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: prime-generator
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/minScale: "2"
        autoscaling.knative.dev/target: "10"
    spec:
      containers:
      - image: quay.io/rhdevelopers/prime-generator:v27-quarkus
        livenessProbe:
          httpGet:
            path: /healthz
        readinessProbe:
          httpGet:
            path: /healthz
```

Procedemos a crear el servicio con el siguiente comando:


*Openshift*
```console
oc -n knative-tutorial apply -f "deploy/serving/escalabilidad/service-min-max-scale.yaml"
oc -n knative-tutorial get pods --watch
```

*Kubernetes*
```console
kubectl -n knative-tutorial apply -f "deploy/serving/escalabilidad/service-min-max-scale.yaml"
kubectl -n knative-tutorial get pods --watch
```

> *Si nos mantenemos a espera, veremos como la cantidad de `pods` nunca disminuye de  `2` debido a que es el valor minimo definido en el `annotation` previamente indicado.*

Debido a que el servicio instanciado también tiene la anotación estudiada en la sección de [auto-escalamiento](#auto-escalamiento), podemos [invocar](#invocacion-concurrente) el mismo para observar como mantiene la elasticidad previamente configurada, pero también como escala a `2` al desaparecer la necesidad adicional de procesamiento.

## Limpieza

*Openshift*
```console
oc -n knative-tutorial delete -f deploy/scerving/escalabilidad/
```

*Kubernetes*
```console
kubectl -n knative-tutorial delete -f deploy/serving/escalabilidad/
```
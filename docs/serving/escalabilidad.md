# Knative Serving - Escalabilidad

## Introducción

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
> *Si ejecutamos los llamados en otra ventana, esperamos a que los `pods` sean autoescalados a 0*

Por defecto, una vez concluyamos las pruebas, los `pods` serán auto-escalados a 0. El *`scale-to-zero`* es una de las caracteristicas principales que hace a `Knative` una plataforma `severless`.

Una vez llegados al punto de inactividad de las `revisions`, las `routes` que apuntan a estas revisiones inactivas, pasan a convertirse en un  *activador* de las mismas.

Para determinar la inactividad y el escalado a 0, existen criterios utilizados por `knative` y existentes bajo los siguientes nombres de parámetro:
- **`stable-window`**: Se útiliza para determinar el tiempo máximo de inactividad, en segundos, que puede tener un servicio antes de ser considerado para ser escalado a 0. A nivel de revisiones especificas es manipulable por medio de la anotación `autoscaling.knative.dev/window`. Su valor predeterminado es `60s`. 
- **`scale-to-zero-grace-period`**: Se útiliza para determinar el máximo tiempo, en segundos, para ser esacaldo a 0 un servicio que se considera inactiv. Funcionalmente no tiene un proposito particular, pues está más relacionado con el tiempo de reconfiguración que ocupa `knative` para excluir la `revision` en cuestión de las configuraciones de red. Su valor predeterminado es `30s`.


## Auto-escalamiento

## Escalamiento minimo

## Limpieza
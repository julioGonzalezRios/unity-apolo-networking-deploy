# Configuración Terraform de Networking Apolo AWS

Esta configuración de Terraform se encarga de crear y configurar una VPC con subredes, grupos de seguridad y tablas de enrutamiento en AWS para la iniciativa de Apolo.

- [Características](#características)
- [Uso](#uso)
- [Variables de Entrada](#variables-de-entrada)
- [Variables de Salida](#variables-de-salida)
- [Recursos Creados](#recursos-creados)
- [Dependencias](#dependencias)
- [Pruebas](#pruebas)
- [Configuración del Pre-Commit Hook](#configuración-del-pre-commit-hook)
- [Consideraciones](#consideraciones)

## Características


- Configura el proveedor AWS y establece el backend de estado remoto de Terraform en un bucket S3.

- Realiza la separación de la lógica de red en módulos reutilizables para un código más limpio y mantenible. Utiliza los módulos de `Unity-VPC-module`, `Unity-SubNet-module` y `Unity-SecurityGroups-module` para ello.

- Realiza la asociación de la VPC con el Transit Gateway especificado a través de `transit_gateway_id`, permitiendo la comunicación inter-VPC y con otras redes conectadas al mismo.

- Gestiona los recursos VPC, subnets, y tablas de enrutamiento en un solo módulo.

- Realiza la creación de los grupos de seguridad que están especificados en la estructura `security_groups`.

- Flexibilidad para asociar diferentes subnets a diferentes tablas de enrutamiento según las necesidades de la infraestructura.

- Añade las rutas en las tablas de enrutamiento de las subnets hacia el Transit Gateway, utilizando los bloques CIDR especificados en el mapa de sets definido en `transit_gateway_cidr_blocks`.

- Añade las rutas en la tabla de rutas de la subnet en donde se encuentra el recurso de Terraform hacia el attachment del Transit Gateway.

- Añade las rutas a las tablas de rutas de las subnets de los NAT Gateways hacia el attachment del Transit Gateways.

- Añade las rutas a las tablas del Transit Gateway asociadas para permitir la comunicación entre el recurso de Terraform con la VPC.

- Permite asignar las etiquetas especificadas en `tags` a todos los recursos generados, incluyendo la etiqueta `Name` implementando una convención de nombrado estándarizado para los recursos creados generada según el tipo de recurso.

## Uso

Para la ejecución de la configuración deben seguirse los siguientes puntos:

- Se debe de seleccionar el workspace que se utilizará para la creación de los recursos (`dev`, `qa` o `prod`) a través de `terraform workspace <nombre del workspace>`. En caso de que el workspace no éste creado, se crea apartir de `terraform workspace new <nombre del workspace>`.

- Debe de crearse un archivo `.tfvars` donde se definan los valores de las variables utilizadas por la configuración.

- Se debe de especificar la configuración del backend dentro del archivo `backend.tf`, esta configuración debe de coincidir con un bucket de S3 existente al que la cuenta de AWS que se defina para la configuración tenga permisos de acceder.

  ```hcl
  # Se especifica el backend para el estado de Terraform, en este caso un bucket S3.
  terraform {
    backend "s3" {
      bucket               = "<nombre del bucket>"
      key                  = "<ruta del archivo .tfstate>"
      workspace_key_prefix = "<prefijo del workspace>"
      region               = "<región en la que se encuentra el bucket>"
    }
  }
  ```

- De igual forma, deben de colocarse en la rutas adecuadas de los módulos de los que depende la configuración o en su defecto modificar las rutas de los mismos en el archivo `main.tf`.

- Deben de definirse las credeciales de la cuenta de AWS para poder desplegar los recursos y acceder al backend en donde se almacenará el archivo del estado de terraform `.tfstate`.

Una vez se completa con lo anterior, se ejecuta el comando para inicializar el provedor y la configuración del backend.

```bash
$ terraform init
```

Posteriormente, se ejecuta el plan y se verifica el mismo, para asegurar la creación de la configuración deseada para cada uno de los recursos.

```bash
$ terraform plan -var-file="<archivo de los valores de la configuración>"  -var "profile=<profile>"
```

Si se esta de acuerdo con el plan, se aplica y acepta para la creación de los recursos.

```bash
$ terraform apply -var-file="<archivo de los valores de la configuración>"  -var "profile=<profile>"
```

## Variables de entrada

La configuración tiene las siguientes variables de entrada:

- `region` - Región en la que se desplegarán los recursos AWS.

- `transit_gateway_id` - Identificador del Transit Gateway que se asociará a la VPC. Si no se especifica, no se hará ninguna asociación.

- `vpc` - Estructura de la VPC que se creará, en ella de específican los siguientes atributos:

  - `cidr_block` - Bloque CIDR para la VPC.

  - `name` - Nombre de la VPC que se usará para identificar los recursos creados.

- `subnets` -  Mapa de las subnets a crear. Cada subnet está representado por un objeto con los siguientes atributos:

  - `type` - El tipo de subnet a crear, puede ser public o private.

  - `availability_zone` - La zona de disponibilidad en la que se creará la subnet.

  - `cidr_block` - Bloque CIDR para la subnet.

  - `transit_gateway_direct_connection` - Valor booleano que indica si la subnet debería tener una conexión directa al Transit Gateway.

  - `nat_gateway_name` - Nonmbre del NAT gateway privado al que tendrá conexión la subnet.

- `security_groups` - Mapa de los grupos de seguridad que se crearán para la VPC. Cada grupo de seguridad está representado por un objeto con los siguientes atributos:

  - `name` - Nombre que se le asignara al grupo de seguridad.

  - `description` - Descrpción breve del grupo de seguridad.

  - `ingress` - Lista de las reglas de tráfico entrante para el grupo de seguridad. Cada regla stá representado por un objeto con los siguientes atributos:

  - `egress` - Lista de las reglas de tráfico saliente para el grupo de seguridad.

  - Cada regla de `ingress` y `egress` está representada por un objeto con los siguientes atributos:

    - `from_port` - El puerto de inicio desde el que se permitirá el tráfico.

    - `to_port` -  El puerto final hasta el que se permitirá el tráfico.

    - `protocol` - El protocolo (TCP, UDP, ICMP, ALL) para el que se permitirá el tráfico.

    - `cidr_blocks` -  La lista de bloques CIDR hacia donde se permitirá el tráfico.

    - `description` - Una descripción breve de la regla de tráfico.

- `transit_gateway_cidr_blocks` - Mapa de las rutas que se crearán para cada subnet hacia el Transit Gateway. Cada elemento del mapa representa una subnet y tiene como valor un set de bloques CIDR a los que deberá tener acceso la subnet mediante los Transit Gateways (`transit_gateway_cidr_blocks = { subnet-1 = ["172.16.0.0/13", ...], ...`).

- `nat_gateway_subnets` - Lista de subnets en las que se creará un NAT Gateway privado.

- `nat_gateway_cidr_blocks` - Mapa de las rutas que se crearán para cada subnet hacia el NAT Gateway. Cada elemento del mapa representa la subnet donde se encuentra el NAT Gateway y tiene como valor un set de bloques CIDR a los que deberán tener acceso las subnets mediante el NAT Gateway (`transit_gateway_cidr_blocks = { subnet-1 = ["172.16.0.0/13", ...], ...`).

- `environment` - Ambiente en el que se desplegará la infraestructura, por ejemplo, prod, dev, qa.

- `tags` - Un mapa de etiquetas que se aplicarán a los recursos creados.

## Variables de salida

La configuración tiene las siguientes variables de salida:

- `vpc_id` - Identificador de la VPC generada.

- `subnets_id` - Mapa que asocia el nombre de cada subnet con su respectivo identificador.

- `security_groups_id` - Mapa que asocia el nombre de cada grupo de seguridad con su respectivo identificador.

- `transit_gateway_cidr_blocks` - Mapa que asocia el identificador de la subnet con los bloques CIDR a los que tiene rutas.

- `transit_gateway_attachment_id` - Identificador de la asociación creada con el Transit Gateway.

Dichas variables podrán ser accedidas por las configuraciones dependientes de `networking` accediendo al `tfstate` de la configuración.

## Recursos creados

Esta configuración crea los siguientes recursos:

- Una VPC.

- Una asociación entre la VPC y el Transit Gateway especificado.

- Un conjunto de subnets.

- Un conjunto de grupos de seguridad que se asociarán a la VPC creada.

- Una tabla de enrutamiento para las subnets , si es necesario.

- Una asociación entre las subnets y sus respectivas tablas de enrutamiento.

- Rutas en las tablas de enrutamiento hacia el Transit Gateway.

## Dependencias

- Requiere del proveedor aws, la versión recomendada es la ~> 5.0.

- Requiere que exista un bucket S3 donde se almacenará el estado de Terraform. Esto permite que el estado de la infraestructura se comparta entre diferentes equipos y se mantenga la coherencia de la infraestructura.

- Esta configuración requiere la existencia de un Transit Gateway específicado en `transit_gateway_id` en la región objetivo. Es vital que el Transit Gateway esté previamente configurado para permitir asociaciones y propagaciones externas. Si el Transit Gateway se encuentra en una cuenta AWS diferente de donde se está desplegando la infraestructura, es necesario asegurarse de que el recurso sea compartido a través de Resource Access Manager.

- Esta configuración depende de otros tres módulos:

  - `Unity-VPC-module` - Módulo utilizado para la creación de la VPC.

  - `Unity-SubNet-module` - Módulo utilizado para la creación de las subnets.

  - `Unity-SecurityGroups-module` - Módulo utilizado para la creación de los grupos de seguridad.

- Requiere la exisencia de las tablas de rutas de los identificadores solicitados en las variables de entrada.

- Requiere la exisencia de los attachment de los identificadores solicitados en las variables de entrada.

## Pruebas

Este módulo incorpora pruebas unitarias desarrolladas con `tftest` y `pytest`, las cuales son liberias de `python`. Las pruebas se encuentran en el directorio `test`. Para su ejecución, deben seguirse los siguientes pasos:

1. Hay que asegurarse de que `python` esté instalado en la máquina donde se llevarán a cabo las pruebas, además de instalar ambas liberias.
    ```python
      # tftest
      pip install tftest

      # pytest
      pip install pytest
    ```
2. Se debe de navegar hasta el directorio `test` dentro del repositorio.
    ```bash
    cd test
3. Se debe de ejecutar el siguiente comando:
    ```bash
    pytest
    ```

    #### Nota
    Deben configurarse las credenciales de AWS correspondientes como variables de entorno, ya que la prueba implica la creación de infraestructura real en una cuenta de AWS, lo cual podría incurrir en cargos.

En caso de requerir cambios en los valores de la prueba, deben modificarse los siguientes archivos:

- `test/networking_test.py` - Este archivo debe ser modificado si se necesitan cambios en las validaciones realizadas sobre la configuración.

- `test/unit/networking_test_outputs.tf` - Si es necesario hacer cambios en algunas de las variables de salida que se toman en cuenta para la prueba, se debe ajustar este archivo. Al agregar o eliminar variables, es imprescindible realizar las modificaciones correspondientes en el archivo `test/networking_test.py`.

Para más información sobre la configuración y modificación de las pruebas, consultar [terraform-python-testing-helper](https://github.com/GoogleCloudPlatform/terraform-python-testing-helper).

## Configuración del Pre-Commit Hook

Este proyecto emplea un pre-commit hook on el objetivo de asegurar que los archivos de Terraform sean correctamente formateados y validados antes de cada commit. Para su configuración, deben seguirse estos pasos:

1. Hay que asegurarse de que `Terraform` esté instalado en la máquina donde se utilizará el `pre-commit`, ya que el script emplea `terraform fmt` y `terraform validate` para las validaciones.

2. Se debe de copiar el archivo `pre-commit` del directorio `hooks` a `.git/hooks`:
   ```bash
   copy hooks\pre-commit .git\hooks\pre-commit
Al realizar un commit, el pre-commit hook verificará automáticamente los archivos de Terraform en espera de commit, los formateará con `terraform fmt`, y los validará con `terraform validate`. Si alguna de estas verificaciones falla, se detendrá el commit, permitiendo corregir los errores antes de continuar.

Cuando realice un commit, el pre-commit hook verificará automáticamente los archivos de Terraform en espera de commit, los formateará con `terraform fmt`, y los validará con `terraform validate`. Si alguna de estas verificaciones falla, el commit se detendrá, permitiéndole corregir los errores antes de continuar.

## Consideraciones

- Es necesario que el Transit Gateway permita asociaciones y propagaciones externas. Además, para la creación de la asociación con la VPC es requerido que se específique al menos una subnet con conexión directa al Transit Gateway. De igual forma, hay que asegurarse de no especificar subnets en la misma zona de disponibilidad con conexión directa a el Transit Gateway.

- Es fundamental que las llaves de los elementos de `transit_gateway_cidr_blocks` estén definidas de la misma forma en `subnets` para asociar de forma correcta las rutas a las tablas de ruteo correspondientes.

- Es fundamental asegurarse de que las direcciones IP en el bloque CIDR de la VPC no se superpongan con las de otras VPC en la misma cuenta o con direcciones IP en la red local si se planea establecer una conexión VPN o Direct Connect.

- Antes de eliminar o modificar recursos creados con esta configuración, hay que asegurarse de comprender las dependencias y posibles efectos en cascada. Eliminar una VPC, por ejemplo, también eliminará todos los recursos asociados a ella.

- Al crear múltiples subnets, es importante garantizar que los bloques CIDR asignados no se superpongan.

- Mientras que los grupos de seguridad operan a nivel de instancia, las tablas de enrutamiento  operan a nivel de subnet. Hay que tomar en cuenta esto al configurar las reglas de acceso.
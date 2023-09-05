# Proyecto: CobroYA SRL

**Descripcion :**

Proyecto de trabajo final de materia de base de datos. Consistio en la consulta e investigacion sobre el caso para determinar los requeriminetos que debe solventar la base de datos y entendimiento del modelo de negocio, teniendo en cuanta el control sobre las operaciones realizadas por los usuarios sobre la base de datos. Y la realizacion de diferentes consultas solicitadas para la realizacion de diferentes informes.

**Ecenario :**

CobroYa cuenta con varios clientes, empresas que eligen a CobroYa para que cobren las deudas generadas por sus propios cientes, a los cuales no les pueden cobrar ells mismo.

De dichas empresas se necesita saber: el nombre, cuit, correo electrónico y localidad. Las empresas que contratan a CobroYa, pasan una cartera de clientes, la misma cuenta con información del cliente deudor: nombre, dni, fecha de nacimiento, localidad de residencia y dirección, así como información de contacto de dicho cliente: mail, tipo y número de teléfono, donde cada uno do estos datos pueden ser más de uno por cliente, y por supuesto el monto total adeudado.

La dinámica de CobroYa es, designar a un empleado, una o más empresas a gestionar, el empleado, del cual se tene el nombre y dni, se comunicará con los clientes deudores, ofreciéndoles una forma de pago de la deuda.

Las formas de pago, son todas las opciones posibles que tiene el cliente deudor para pagar su deuda, es importante aclarar, que dichas formas de pago son las mismas para todos los clentes, no importa de qué empresa sean. Las formas de pago, las decide CobroYa. Cada forma de pago, está compuesta por: cantidad de cuotas, interés a aplicar, fecha de baja, que, en caso de ser cargada, indicará que el plan de pago está dado de baja y no podrá ofrecerse, y un porcentaje de comisión, que es el que CobroYa cobrará por cada cuota cobrada.

El objetivo del empleado es que el ciente haga un Convenio, en el cual figure: el cliente, la forma de pago que eligió el empleado que lo atendió, la fecha de generación del convenio y un número de convenio que irá creciendo uno a uno en base a la cantidad de convenios firmados.

El convenio, contará con tantas cuotas como figure en el plan de pago elegido, las cuotas deberán tener la siguiente información: número de cuota, vencimiento de la misma, importe de la cuota, algo que determine si la cuota está pagada o no y una fecha de pago.

A fines practicos se acordo que un deudor no puede estar en mas de una cartera de clientes en diferentes empresas.

##### Modelo entidad relacion de negocio :

![Alt text](image.png)

## Caracterisitcas 

- Creacion de tablas y operaciones CRUD sobre las mismas
- Uso de triggers y tabla de logs para el control y respaldo de operaciones realizadas por empleados.
- Creacion de diferentes roles y privilegios para brindar una capa seguridad.
- Construccion de consultas complejas compuestas por diferentes relaciones entre tablas, filtros y funciones SQL.
- Creacion de Funciones, Procediminetos y Vistas

## Tecnologias Utilizadas
- **Base de datos : PostgreSQL** 

## Intalacion y configuracion
- Instalar PostgreSQL : https://www.postgresql.org/download/
- Clonar proyecto del repositorio una vez posicionado en la ubicaion deseada : `git clone https://github.com/AxelK1999/CobroYa-SRL.git`
- Importar archivo CobroYaSQL en postgreSQL
## Uso
- Crear e insertar las tablas y datos en sentido decendente
- Crear la tabla log luego los triggers correspondientes
- Ejecutar la creacion de roles, luego los permisos
- Ejecutar las consultas que desee probar que se encuentran al final del archivo
# 🛒 Base de Datos E-Commerce — MySQL

**Proyecto de bases de datos | Andrés Castellanos  Arturo Ojeda**

Base de datos relacional para una tienda en línea, implementada en MySQL. Incluye el esquema completo, datos de prueba, consultas avanzadas, funciones definidas por el usuario, triggers, eventos programados, procedimientos almacenados y configuración de seguridad por roles.

---

## 📁 Estructura del Proyecto

```
Proyecto-MySQL2---Andres-Castellanos -- Arturo Ojeda/
│
├── 01_Esquema_y_Datos.sql          # Creación de tablas e inserción de datos
├── 02_Consultas_Avanzadas.sql      # 20 consultas analíticas
├── 03_Funciones.sql                # 20 funciones definidas por el usuario (UDFs)
├── 04_Seguridad.sql                # Roles, usuarios y permisos
├── 05_Triggers.sql                 # 20 disparadores automáticos
├── 06_Eventos.sql                  # 20 eventos programados
└── 07_Procedimientos_Almacenados.sql  # 20 stored procedures
```

---

## 🗄️ Esquema de la Base de Datos

**Base de datos:** `e_commerce`

### Tablas principales

| Tabla | Descripción |
|---|---|
| `categoria` | Categorías de productos (Electrónica, Ropa, Hogar, etc.) |
| `proveedores` | Proveedores que surten los productos |
| `clientes` | Clientes registrados en la tienda |
| `productos` | Catálogo de productos con precio, costo, stock y SKU |
| `ventas` | Cabecera de cada orden de compra |
| `detalle_ventas` | Líneas de producto por venta (cantidad y precio unitario) |

### Tablas auxiliares y de logs

| Tabla | Propósito |
|---|---|
| `log_nuevos_clientes` | Auditoría de clientes recién registrados |
| `log_cambios_precio` | Historial de cambios de precio por producto |
| `log_estado_pedido` | Registro de cambios de estado en pedidos |
| `log_permisos` | Auditoría de activación/desactivación de productos |
| `alertas_stock` | Alertas automáticas cuando el stock baja de 10 unidades |
| `archivo_ventas` | Ventas eliminadas (borrado lógico) |
| `resenas_producto` | Reseñas y calificaciones (1–5 estrellas) de clientes |
| `visitas_producto` | Registro de visitas por producto y cliente |

### Tablas de reportes y eventos

`reporte_ventas_semanal`, `resumen_ventas_diario`, `kpis_mensuales`, `lealtad_clientes`, `ranking_productos`, `reporte_proveedores`, `lista_reabastecimiento`, `actividad_sospechosa`, entre otras.

### Datos de prueba

- 5 categorías y 5 proveedores
- 15 clientes de distintos países de Latinoamérica
- 20 productos con SKU, precio, costo y stock
- 30 ventas con sus respectivos detalles

---

## 🔍 Consultas Avanzadas (`02_Consultas_Avanzadas.sql`)

20 consultas analíticas que cubren escenarios reales de negocio:

1. Top 10 productos más vendidos por ingresos
2. Productos en el 10% inferior de ventas
3. Clientes VIP por Lifetime Value (LTV)
4. Análisis de ventas mensuales
5. Crecimiento de clientes por trimestre
6. Tasa de compra repetida
7. Productos comprados juntos frecuentemente
8. Rotación de inventario por categoría
9. Productos que necesitan reabastecimiento
10. Carritos abandonados (más de 3 días pendiente)
11. Rendimiento de proveedores
12. Análisis geográfico de ventas por ciudad
13. Ventas por hora del día (horas pico)
14. Impacto de promociones (antes/durante/después)
15. Análisis de cohorte de retención de clientes
16. Margen de beneficio por producto
17. Tiempo promedio entre compras por cliente
18. Productos más vistos vs. más comprados (tasa de conversión)
19. Segmentación RFM (Recencia, Frecuencia, Monetario)
20. Predicción de demanda simple basada en los últimos 3 meses

---

## ⚙️ Funciones Definidas por el Usuario (`03_Funciones.sql`)

20 UDFs para cálculos y validaciones reutilizables:

| Función | Descripción |
|---|---|
| `fn_CalcularTotalVenta` | Subtotal de un ítem (cantidad × precio) |
| `fn_VerificarDisponibilidadStock` | Devuelve TRUE si hay stock suficiente |
| `fn_ObtenerPrecioProducto` | Precio actual de un producto por ID |
| `fn_CalcularEdadCliente` | Edad en años desde fecha de nacimiento |
| `fn_FormatearNombreCompleto` | Nombre en formato `apellido  nombre` en minúsculas |
| `fn_EsClienteNuevo` | TRUE si la primera compra fue hace ≤ 30 días |
| `fn_CalcularCostoEnvio` | Costo de envío ($2/kg, mínimo $5) |
| `fn_AplicarDescuento` | Precio final tras aplicar un % de descuento |
| `fn_ObtenerUltimaFechaCompra` | Fecha de la compra más reciente del cliente |
| `fn_CalcularDiasDesdeUltimaCompra` | Días sin comprar (–1 si nunca compró) |
| `fn_DeterminarEstadoLealtad` | Nivel Bronce / Plata / Oro según gasto total |
| `fn_GenerarSKU` | SKU sugerido: `XXXX-CAT-N` |
| `fn_CalcularIVA` | IVA al 19% sobre un monto |
| `fn_ObtenerStockTotalPorCategoria` | Stock acumulado de todos los productos de una categoría |
| `fn_EstimarFechaEntrega` | Fecha estimada según región del cliente (3–7 días) |
| `fn_ConvertirMoneda` | Conversión a otra moneda por tasa de cambio |
| `fn_ValidarComplejidadContrasena` | TRUE si la contraseña tiene ≥ 8 caracteres |

---

## 🔒 Seguridad (`04_Seguridad.sql`)

Gestión de acceso mediante roles de MySQL:

| Rol | Permisos |
|---|---|
| `Administrador_Sistema` | Todos los privilegios con `GRANT OPTION` |
| `Gerente_Marketing` | `SELECT` en `clientes` y `ventas` |
| `Analista_Datos` | `SELECT` en toda la base (sin `DELETE` ni `DROP`) |
| `Empleado_Inventario` | `UPDATE` solo en la columna `stock` de `productos` |
| `Atencion_Cliente` | `SELECT` en `clientes` y `ventas`; acceso a la vista `v_info_clientes_basica` |
| `Auditor_Financiero` | `SELECT` en `ventas` y `productos` |
| `Visitante` | `SELECT` solo en `productos` |

**Usuarios creados:** `admin_user`, `marketing_user`, `inventory_user`, `support_user`

**Otras medidas:** política de contraseñas seguras (`STRONG`, mínimo 10 caracteres), límite de 1000 consultas/hora para `analista_user`, y bloqueo de `root` en conexiones remotas.

---

## ⚡ Triggers (`05_Triggers.sql`)

20 disparadores que mantienen la integridad y la auditoría automática:

| Trigger | Evento | Acción |
|---|---|---|
| `trg_audit_precio_producto_after_update` | `AFTER UPDATE` en `productos` | Guarda cambios de precio en `log_cambios_precio` |
| `trg_check_stock_before_insert_venta` | `BEFORE INSERT` en `detalle_ventas` | Bloquea la venta si no hay stock suficiente |
| `trg_update_stock_after_insert_venta` | `AFTER INSERT` en `detalle_ventas` | Descuenta stock automáticamente |
| `trg_prevent_delete_categoria_with_products` | `BEFORE DELETE` en `categoria` | Impide eliminar categorías con productos |
| `trg_log_new_customer_after_insert` | `AFTER INSERT` en `clientes` | Registra el nuevo cliente en `log_nuevos_clientes` |
| `trg_update_total_gastado_cliente` | `AFTER INSERT` en `ventas` | Actualiza el total histórico del cliente |
| `trg_set_fecha_modificacion_producto` | `BEFORE UPDATE` en `productos` | Marca la fecha de modificación automáticamente |
| `trg_prevent_negative_stock` | `BEFORE UPDATE` en `productos` | Bloquea si el stock quedaría negativo |
| `trg_capitalize_nombre_cliente` | `BEFORE INSERT` en `clientes` | Capitaliza nombre y apellido |
| `trg_recalculate_total_venta_on_detalle_change` | `AFTER UPDATE` en `detalle_ventas` | Recalcula el total de la venta |
| `trg_log_order_status_change` | `AFTER UPDATE` en `ventas` | Audita cambios de estado en `log_estado_pedido` |
| `trg_prevent_price_zero_or_less` | `BEFORE UPDATE` en `productos` | Bloquea precios en cero o negativos |
| `trg_send_stock_alert_on_low_stock` | `AFTER UPDATE` en `productos` | Inserta alerta cuando el stock baja de 10 |
| `trg_archive_deleted_venta` | `BEFORE DELETE` en `ventas` | Mueve la venta a `archivo_ventas` antes de borrar |
| `trg_validate_email_format_on_customer` | `BEFORE INSERT` en `clientes` | Valida que el email tenga `@` y `.` |
| `trg_update_last_order_date_customer` | `AFTER INSERT` en `ventas` | Actualiza `fecha_ultimo_pedido` del cliente |
| `trg_prevent_self_referral` | `BEFORE INSERT` en `clientes` | Impide que un cliente se referencie a sí mismo |
| `trg_log_permission_changes` | `AFTER UPDATE` en `productos` | Audita cambios en el campo `activo` |
| `trg_assign_default_category_on_null` | `BEFORE INSERT` en `productos` | Asigna categoría 1 si la indicada no existe |
| `trg_update_producto_count_insert/delete` | `AFTER INSERT/DELETE` en `productos` | Mantiene el contador `total_productos` en `categoria` |

---

## 📅 Eventos Programados (`06_Eventos.sql`)

20 eventos automáticos con distintas frecuencias:

| Frecuencia | Eventos |
|---|---|
| Cada hora | Desactivar promociones expiradas, actualizar ranking de productos, detectar actividad sospechosa |
| Diario | Limpiar sesiones temporales, generar lista de reabastecimiento, agregar datos de ventas del día, backup de tablas críticas, enviar cupones de cumpleaños, verificar consistencia, actualizar vistas materializadas |
| Semanal | Reporte de ventas semanal, reconstrucción de índices (`OPTIMIZE TABLE`), purga de registros eliminados hace >30 días, registro del tamaño de la BD |
| Mensual | Archivar logs de >6 meses, calcular KPIs mensuales, reporte de rendimiento de proveedores |
| Trimestral | Suspender cuentas sin actividad en más de un año |
| Nightly | Recalcular niveles de lealtad de clientes, verificar consistencia de datos |

---

## 🛠️ Procedimientos Almacenados (`07_Procedimientos_Almacenados.sql`)

20 stored procedures para operaciones de negocio complejas:

| Procedimiento | Descripción |
|---|---|
| `sp_RealizarNuevaVenta` | Procesa una venta completa con transacción y manejo de errores |
| `sp_AgregarNuevoProducto` | Inserta un producto con todos sus atributos |
| `sp_ActualizarDireccionCliente` | Actualiza la dirección validando que el cliente exista |
| `sp_ProcesarDevolucion` | Cancela una venta y restaura el stock de los productos |
| `sp_ObtenerHistorialComprasCliente` | Historial completo de compras de un cliente |
| `sp_AjustarNivelStock` | Ajuste manual de stock con registro del motivo |
| `sp_EliminarClienteDeFormaSegura` | Anonimiza los datos del cliente sin borrar sus ventas |
| `sp_AplicarDescuentoPorCategoria` | Aplica un % de descuento a toda una categoría |
| `sp_GenerarReporteMensualVentas` | Reporte de ventas por cliente para un mes/año dado |
| `sp_CambiarEstadoPedido` | Cambia el estado de un pedido con validaciones |
| `sp_RegistrarNuevoCliente` | Registra un cliente validando que el email no exista |
| `sp_ObtenerDetallesProductoCompleto` | Info de un producto junto con categoría y proveedor |
| `sp_FusionarCuentasCliente` | Une dos cuentas duplicadas en una sola |
| `sp_AsignarProductoAProveedor` | Cambia el proveedor de un producto |
| `sp_BuscarProductos` | Búsqueda avanzada con filtros opcionales (nombre, categoría, rango de precio) |
| `sp_ObtenerDashboardAdmin` | KPIs clave: ventas del día, nuevos clientes, stock crítico |
| `sp_ProcesarPago` | Mueve una venta de "Pendiente de Pago" a "Procesando" |
| `sp_AnadirResenaProducto` | Agrega una reseña (1–5 estrellas) verificando que el cliente haya comprado el producto |
| `sp_ObtenerProductosRelacionados` | Productos comprados junto al producto dado (recomendaciones) |
| `sp_MoverProductosEntreCategorias` | Mueve todos los productos de una categoría a otra |

---

## 🚀 Cómo ejecutar el proyecto

### Requisitos

- MySQL 8.0 o superior
- Cliente MySQL (Workbench, DBeaver, línea de comandos, etc.)

### Pasos

Ejecuta los archivos en orden:

```sql
-- 1. Crear la base de datos, tablas y cargar datos
SOURCE 01_Esquema_y_Datos.sql;

-- 2. Crear las consultas avanzadas (opcional, solo para pruebas)
SOURCE 02_Consultas_Avanzadas.sql;

-- 3. Crear las funciones
SOURCE 03_Funciones.sql;

-- 4. Configurar roles y usuarios
SOURCE 04_Seguridad.sql;

-- 5. Crear los triggers
SOURCE 05_Triggers.sql;

-- 6. Crear los eventos programados
SOURCE 06_Eventos.sql;

-- 7. Crear los procedimientos almacenados
SOURCE 07_Procedimientos_Almacenados.sql;
```

> **Nota:** El archivo `06_Eventos.sql` requiere que el Event Scheduler esté habilitado. Esto se hace automáticamente con `SET GLOBAL event_scheduler = ON;` al inicio del archivo.

---

## 📋 Ejemplos de uso rápido

```sql
-- Realizar una venta
CALL sp_RealizarNuevaVenta(1, 2, 3);

-- Ver el historial de compras de un cliente
CALL sp_ObtenerHistorialComprasCliente(1);

-- Ver el dashboard de administrador
CALL sp_ObtenerDashboardAdmin();

-- Buscar productos de Electrónica entre $100 y $500
CALL sp_BuscarProductos(NULL, 1, 100.00, 500.00);

-- Ver el nivel de lealtad de todos los clientes
SELECT id, nombre, apellido, fn_DeterminarEstadoLealtad(id) AS nivel
FROM clientes ORDER BY id;

-- Calcular el IVA de cada venta entregada
SELECT id, total, fn_CalcularIVA(total) AS iva, total + fn_CalcularIVA(total) AS total_con_iva
FROM ventas WHERE estado = 'Entregado';
```

---

## 👨‍💻 Autor

**Andrés Castellanos** 
**Arturo Ojeda**  
Estudiante de bases de datos — Proyecto MySQL  

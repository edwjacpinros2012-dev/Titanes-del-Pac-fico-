# Distribución Android gratuita sin Google Play Console

Objetivo: compartir una primera versión Android sin pagar una cuota de registro de Google Play. Ninguna tienda garantiza la publicación: todas pueden revisar y rechazar una aplicación.

## Primera ruta recomendada: itch.io

itch.io permite crear una página de proyecto con una cuenta gratuita y subir archivos descargables. Para que el juego sea estrictamente gratuito, configura el precio en cero y selecciona la opción que desactiva todos los pagos; no uses "pay what you want" si no quieres donaciones ni cobros.

Pasos cuando exista un APK probado:
1. Un padre, madre o tutor debe revisar y consentir la publicación. Los términos de itch.io indican que los publicadores deben tener 18 años o contar con consentimiento legal de su tutor.
2. Crear la página del proyecto y marcar Android como plataforma.
3. Subir directamente el APK exportado y probado desde Godot.
4. Añadir icono original, capturas reales, descripción, versión, requisitos y pasos de instalación.
5. En la configuración de precio elegir cero y desactivar pagos.
6. Publicar primero como borrador/restringido para probar el enlace con personas de confianza; después hacer pública la página cuando el adulto responsable lo autorice.
7. Mantener un registro de versiones y publicar notas de actualización.

Documentación:
- Primera página de itch.io: https://itch.io/docs/creators/getting-started
- Precio y desactivar pagos: https://itch.io/docs/creators/pricing
- Términos y consentimiento de tutor para publicadores: https://itch.io/docs/legal/terms

## Otras tiendas gratuitas que se pueden evaluar

| Plataforma | Información oficial | Notas |
|---|---|---|
| Uptodown | https://support.uptodown.com/hc/es/articles/4424141383181-Gu%C3%ADa-b%C3%A1sica-para-registrarse-y-publicar-apps | Su centro de ayuda indica que el registro y la publicación son gratuitos. Requiere cuenta de desarrollador y revisión del contenido. |
| Amazon Appstore | https://developer.amazon.com/docs/app-submission/publish-app-login-and-add-app.html | El registro de desarrollador es gratuito; revisar compatibilidad de dispositivos y formato actual admitido. |
| Samsung Galaxy Store | https://developer.samsung.com/galaxy-store/prepare.html | Requiere Samsung Account y Seller Portal; Samsung declara que no cobra alta ni cuota anual de publicación. |
| Huawei AppGallery | https://developer.huawei.com/consumer/en/appgallery/ | Requiere HUAWEI ID y verificación de identidad del desarrollador. Revisar requisitos para el país y tipo de cuenta. |

No se asume que todas estas plataformas acepten automáticamente cualquier APK o que estén disponibles para cualquier titular. Revisar requisitos, edad, identidad, formato de paquete y revisión vigentes antes de abrir una cuenta.

## Exportación Android desde Godot

La exportación todavía no se ha realizado. Antes de subir:
- Instalar la versión estable de Godot 4 compatible con el proyecto y sus export templates.
- Instalar y configurar Android SDK / JDK según la documentación oficial de Godot.
- Definir un application ID propio y definitivo; reemplazar cualquier identificador de ejemplo.
- Configurar permisos mínimos y orientación/compatibilidad.
- Crear la firma de publicación y guardar el keystore fuera del repositorio, con copia segura bajo control del adulto responsable.
- Exportar APK para distribución directa y probarlo en al menos un dispositivo Android real.
- Verificar inicio, controles táctiles, rendimiento, guardado, audio, permisos y cierre/reapertura.
- No subir un APK que no se haya instalado y probado.

Documentación oficial de Godot:
https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html

## Política permanente del juego

- Descarga gratuita.
- Sin compras dentro de la aplicación, anuncios, suscripciones ni pagos externos para desbloquear contenido.
- Sin Google Play Billing.
- Mercado ficticio del juego con créditos que se ganan jugando; no representa dinero real.
- No pedir datos personales innecesarios a los jugadores.
- La página de publicación debe enlazar una política de privacidad que refleje exactamente los datos que el juego recopila.

## Estado

- [x] Estrategia de distribución alternativa documentada.
- [x] Decisión de no aceptar pagos en la página itch.io documentada.
- [ ] Preparar exportación Android y probar APK.
- [ ] Crear materiales de página (icono, capturas y descripción).
- [ ] Adulto responsable revisa términos, consentimiento y cuenta de publicador.
- [ ] Enviar a revisión de cada tienda seleccionada.
- [ ] Publicación confirmada por la tienda.

La presencia de documentación en este repositorio no significa que el juego ya tenga un APK, una cuenta de tienda o una publicación aprobada.

# Preparación para Google Play: juego gratuito

Estado: plan y estructura preparados; publicación todavía no solicitada ni aprobada.

## Decisiones del proyecto

- El juego se distribuirá como descarga gratuita.
- No habrá compras dentro de la aplicación, microtransacciones, suscripciones, anuncios recompensados ni catálogo de artículos por dinero real.
- No se integrará Google Play Billing.
- El mercado que existe dentro del mundo del juego puede seguir usando créditos ficticios obtenidos jugando. Es una mecánica de juego, no una compra con dinero real.
- Google Play Games Services podrá usarse para identidad de plataforma, logros y clasificación, después de configurar y probar el proyecto.
- El perfil del juego y su progreso deben pertenecer al sistema de cuentas del juego; la identidad de Google Play Games se vinculará como proveedor, no como único registro.
- La autenticación, guardado en nube, alianzas y datos compartidos requieren un backend configurado y probado. El cliente Godot no debe contener claves secretas.

## Registro de desarrollador

Google no concede automáticamente el registro ni podemos solicitarlo en nombre del creador. El titular de la cuenta debe completar el proceso oficial, verificar su identidad y aceptar los acuerdos.

La ayuda oficial de Play Console indica que el titular debe tener al menos 18 años y que la distribución completa tiene una tasa única de registro de 25 USD. El hecho de que el juego sea gratuito para descargar no elimina esa tasa de registro de desarrollador. Un padre, madre o tutor adulto debe gestionar la cuenta y los acuerdos con su consentimiento mientras el creador sea menor de edad.

Enlace oficial: https://support.google.com/googleplay/android-developer/answer/6112435

## Ruta de publicación

1. Cerrar el nombre comercial, comprobar marcas y derechos, y sustituir cualquier nombre provisional que pueda confundirse con una franquicia existente.
2. Completar el juego y corregir errores en Godot 4.
3. Preparar icono, capturas reales, descripción, clasificación de contenido, política de privacidad y formulario de seguridad de datos.
4. Configurar el identificador de paquete definitivo y la firma de publicación.
5. Instalar y probar la exportación Android en dispositivos reales.
6. Crear la ficha de la aplicación en Play Console desde la cuenta adulta responsable.
7. Configurar Google Play Games Services solo si se va a usar; registrar correctamente el proyecto, credenciales, huellas de certificado y testers.
8. Para cuentas personales nuevas sujetas a la política vigente, completar una prueba cerrada con al menos 12 testers que permanezcan inscritos 14 días consecutivos antes de solicitar acceso a producción.
9. Enviar la aplicación a revisión. Google decide si la aprueba; no se puede garantizar la aprobación.

## Google Play Games Services

La integración todavía no está instalada en este repositorio. No se debe declarar como terminada. La configuración requiere Play Console, un proyecto de Google Cloud, el mismo identificador de paquete y huellas de certificado correctas para las compilaciones de prueba y publicación.

Documentación oficial:
- https://developer.android.com/games/pgs/console/setup
- https://developer.android.com/games/pgs/start

## Criterios de salida

- [ ] Godot abre el proyecto sin errores.
- [ ] Exportación Android instalada y probada en dispositivo real.
- [ ] Guardado local probado después de cerrar y abrir.
- [ ] Backend configurado, políticas RLS revisadas y pruebas de seguridad ejecutadas.
- [ ] Registro e inicio de sesión probados.
- [ ] Google Play Games Services configurado y probado, si se incluye.
- [ ] Sin compras dentro de la aplicación ni dependencias de Billing.
- [ ] Política de privacidad y formularios de Play Console completos.
- [ ] Recursos gráficos y ficha originales.
- [ ] Prueba cerrada y requisitos de producción completados.
- [ ] Revisión de Google superada.

No se deben publicar credenciales, contraseñas, claves privadas, keystores ni secretos en GitHub.

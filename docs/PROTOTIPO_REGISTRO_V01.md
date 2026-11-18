# Prototipo provisional de registro — v0.1

## Objetivo
Dar al jugador una entrada clara al juego mientras se termina la integración de Godot en el equipo del desarrollador.

## Pantallas previstas
1. Inicio: Jugar, Cuenta y Ajustes.
2. Acceso: pestañas Iniciar sesión / Crear cuenta.
3. Registro local: nombre de piloto y creación de perfil sin contraseña ni correo ficticios.
4. Cuenta: nombre, ID local, progreso y estado de conexión.
5. Ajustes: audio, subtítulos, controles, idioma y accesibilidad.
6. Entrada al juego: botón para continuar al tutorial.

## Estado real de las funciones
- Perfil local: implementado en AccountManager; persiste en user://player_identity.json.
- Nombre de piloto: validación de 1 a 24 caracteres.
- Modo offline: implementado; no necesita internet.
- Google: botón provisional; NO autentica todavía.
- Nube: NO sincroniza todavía.
- Correo y contraseña: NO se recopilan ni almacenan en este prototipo.
- Privacidad: no introducir secretos OAuth, contraseñas ni tokens en el cliente o en Git.

## Flujo propuesto
Inicio -> Crear cuenta -> Nombre de piloto -> Crear perfil local -> Tutorial -> Cuenta/Ajustes desde el menú.

Cuando se configure Google OAuth real, el servidor debe verificar la identidad y emitir una sesión segura. La interfaz nunca debe confiar en un indicador local como prueba de autenticación.

## Criterios de aceptación
- Crear perfil local y conservarlo al reiniciar.
- Rechazar nombres vacíos o mayores de 24 caracteres.
- Seguir jugando sin Google.
- Mostrar claramente que Google y la nube están desactivados.
- Recuperarse de un archivo de perfil inválido sin afirmar que se ha sincronizado nada.
- Pasar pruebas Godot 4.3 y prueba manual en Windows 11 antes de marcar el sistema como terminado.

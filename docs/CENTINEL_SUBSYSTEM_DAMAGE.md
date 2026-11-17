# Integración de daño persistente del Centinela

El juego ahora mantiene cuatro condiciones separadas: chasis, movilidad, sensores y reactor.

- Cada resultado de combate aplica un nivel distinto de desgaste.
- El rol del Abisal influye en qué subsistema recibe más daño.
- Elegir Defensa reduce el daño recibido.
- El estado de movilidad reduce la velocidad real del Centinela.
- El deterioro general reduce la potencia calculada para futuros encuentros.
- El estado se guarda en el perfil local.
- La reparación se activa con **Y** o el botón táctil Y y consume metal y energía según los puntos recuperados.

El modelo conserva la condición entre encuentros. Por tanto, no conviene entrar en una cadena de combates sin revisar el estado y reparar el mecha.

## Alcance y límites

Este sistema es una primera capa de desgaste estratégico. Todavía no representa piezas físicas desprendibles, animaciones de daño, impactos localizados en tiempo real ni fallos visuales. Tampoco sustituye las futuras mecánicas de combate directo. Debe validarse con Godot 4.3 y pruebas de juego antes de considerarlo terminado.

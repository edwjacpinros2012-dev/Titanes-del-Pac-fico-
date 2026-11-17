# Especificación del primer ciclo jugable

## Objetivo de aceptación
Un jugador puede iniciar una operación desde la base, completar objetivos, recibir un resultado, regresar, conservar las consecuencias y preparar la siguiente salida.

## Flujo de estados
1. Base: recursos, condición del Centinela y operaciones disponibles.
2. Despliegue: validar misión, región desbloqueada, preparación y resumen de amenaza.
3. Operación: controlar el Centinela y progresar objetivos.
4. Informe: registrar victoria, éxito parcial, retirada o derrota y calcular recompensas.
5. Regreso: preparar reparación, reabastecimiento y mejoras.

## Contrato de datos de misión

    {
      "id": "aurora_first_contact",
      "title": "Primer contacto",
      "region_id": "aurora_coast",
      "objectives": [
        {"id": "reach_beacon", "target": 1, "optional": false},
        {"id": "scan_tracks", "target": 3, "optional": true}
      ],
      "rewards": {"metal": 12, "energy": 5}
    }

## Reglas de resultado
- Solo se puede iniciar una operación desde Base.
- Una misión pasa por Despliegue antes de Operación.
- Los objetivos solo progresan durante Operación.
- Una victoria solicitada con objetivos obligatorios incompletos se convierte en éxito parcial.
- Las recompensas nunca son negativas.
- La derrota no concede recursos de misión.
- No se puede iniciar otra operación antes de regresar a Base.

## Integración pendiente
MissionRunManager aporta el ciclo lógico y el contrato de resultados. Todavía debe conectarse a la interfaz de misión, el controlador del Centinela, el director de amenaza, la presión regional, los daños, la economía y el guardado. No debe declararse como bucle completo hasta verificar esas conexiones en Godot.

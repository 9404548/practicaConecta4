; CONSTANTES DE COLORES
; Valores de atributos de color (ej.: usado para imprimir texto en pantalla)
COLOR_TEXTO_AZUL     EQU 1    ; Color azul (atributo de color 1)
COLOR_TEXTO_ROJO     EQU 2    ; Color rojo  (atributo de color 2)
COLOR_TEXTO_AMARILLO EQU 6   ; Color amarillo (atributo de color 6)
BLINK                EQU 128  ; Bit de parpadeo (MSB del atributo). Combinar con OR: BLINK | color

; Colores asignados a cada jugador (reutilizan los valores anteriores)
PLAYER1             EQU 2    ; Color del jugador 1 (aquí: rojo)
PLAYER2             EQU 6    ; Color del jugador 2 (aquí: amarillo)

; COLORES DISPONIBLES
NEGRO               EQU 0    ; Color negro / fondo (valor 0)
AZUL                EQU 1
; DISPONIBLES PARA JUGADORES, EL AZUL Y EL NEGRO DEBEN QUEDAR RESERVADOS PARA EL TABLERO
COLOR_ROJO                EQU 2
COLOR_MAGENTA             EQU 3
COLOR_VERDE               EQU 4
COLOR_CELESTE             EQU 5
COLOR_AMARILLO            EQU 6
COLOR_BLANCO              EQU 7
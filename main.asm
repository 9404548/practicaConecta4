; main.asm - Programa principal Conecta 4 (ZX Spectrum)
; Inicialización, bucle principal, gestión de jugadas y subrutinas auxiliares

    DEVICE ZXSPECTRUM48
    ORG $8000
    LD SP, 0
    LD A, 0 ; Valor inicial de A
    OUT ($FE), A ; Colorea el marco de la pantalla en negro
    JP INICIO

; INCLUDES - módulos y rutinas auxiliares
    INCLUDE "colors.asm"         ; Definiciones de colores y jugadores
    INCLUDE "variables.asm"      ; Variables globales y estado
    INCLUDE "keyboard.asm"       ; Rutinas de lectura de teclado
    INCLUDE "printat.asm"        ; Rutina de impresión en pantalla
    INCLUDE "graphics_basic.asm" ; Rutinas gráficas básicas
    INCLUDE "graphics_core.asm"  ; Rutinas gráficas avanzadas
    INCLUDE "logic_flow.asm"     ; Flujo principal del juego
    INCLUDE "logic_checks.asm"   ; Comprobaciones de victoria y jugadas

; INICIO DEL FLUJO DEL PROGRAMA FUNCIONAL
; Pantalla de bienvenida y gestión de entrada inicial
INICIO:
    CALL GB_BIENVENIDA           ; Dibuja pantalla de bienvenida
    CALL K_SON                   ; Lee teclado (S/N)
    LD A, D
    LD (CHAR_CARACTER), A        ; Guarda la tecla pulsada
    LD A, COLOR_TEXTO_AMARILLO
    CALL GB_PRINT_CHAR_SON       ; Imprime la tecla pulsada
    LD A, (CHAR_CARACTER)
    CP 'S'
    CALL Z, LOGICA_JUEGO         ; Si se pulsó 'S', comienza la lógica del juego
    CP 'N'
    CALL Z, ADIOS                ; Si se pulsó 'N', muestra pantalla de despedida

; Pantalla de despedida
ADIOS:
    CALL GB_ADIOS                ; Dibuja pantalla de adiós
FINAL: ; Bucle final (espera y halt)
    LD B, 10
    CALL ESPERAR
    DJNZ FINAL
    HALT

; Pantalla de fin de partida y opción de reinicio
FIN_NEXT:
    CALL GB_FIN_NEXT             ; Dibuja pantalla de fin y pregunta S/N
    CALL K_SON                   ; Lee teclado (S/N)
    LD A, D
    CP 'S'
    CALL Z, LOGICA_JUEGO         ; Si se pulsó 'S', inicia nuevo juego
    CP 'N'
    CALL Z, ADIOS                ; Si se pulsó 'N', muestra pantalla de despedida

; Lógica principal del juego
LOGICA_JUEGO:
    CALL GB_PTLLA_INICIO_DE_JUEGO ; Dibuja pantalla de inicio de juego
    ; HALT
    CALL LF_INICIALIZACION        ; Inicializa condiciones del juego
BUCLE_JUEGO:
    CALL LF_SWITCH_JUGADOR        ; Cambia de jugador
GESTIONAR_JUGADA:
    CALL GC_COLOR_JUGADOR_ACTUAL  ; Muestra el jugador actual en pantalla (HL = $5845)
JUGADA:
    CALL K_LR_ENTER_F             ; Lee entrada (Q/W/ENTER/F)
    LD A, D
    PUSH AF
    CALL LC_VALIDPLAY             ; Comprueba si la jugada es válida
    CP 1
    JR Z, JUGADA                  ; Si no fue válida, espera nueva jugada
    POP AF
    CP 'W'
    CALL Z, JUGADA_DESPLAZAMIENTO ; Desplaza ficha a la derecha
    CP 'Q'
    CALL Z, JUGADA_DESPLAZAMIENTO ; Desplaza ficha a la izquierda
    CP 13
    CALL Z, GC_ENTER              ; Ejecuta acción de soltar ficha
    CP 'F'
    CALL Z, FIN_NEXT              ; Termina partida

; Comprobación de fin de juego
COMPROBAR_FIN_JUEGO:
    CALL LC_COMPROBAR_FIN         ; Comprueba si hay victoria o empate
    ; Si se detectó el fin del juego
    ; JR (condición de fin), FIN_NEXT
    JR Z, FIN_NEXT
    JR BUCLE_JUEGO                ; Si no hay fin, sigue el juego

; Rutina de espera (~0,5 seg)
ESPERAR:
    PUSH BC
    PUSH AF
    LD BC, CONTADOR
ESPERAR1: 
    DEC BC ; 6C
    LD A, B ; 4C
    OR C ; 4C
    NOP ; 4C
    JR NZ, ESPERAR1 ; 12C
    ; DURACION TOTAL = APPROX 0,49 SEG
    POP AF
    POP BC
    RET

; JUGADA_DESPLAZAMIENTO - Administra desplazamiento tras Q/W
JUGADA_DESPLAZAMIENTO:
    CP 'W'
    CALL Z, GC_RIGHT              ; Desplaza ficha a la derecha
    CP 'Q'
    CALL Z, GC_LEFT               ; Desplaza ficha a la izquierda
    JR JUGADA

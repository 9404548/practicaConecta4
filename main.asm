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
    INCLUDE "variables.asm"      ; Variables globales y estado del juego
    INCLUDE "keyboard.asm"       ; Rutinas de lectura de teclado
    INCLUDE "printat.asm"        ; Rutina de impresión en pantalla
    INCLUDE "graphics_basic.asm" ; Rutinas gráficas básicas
    INCLUDE "graphics_core.asm"  ; Rutinas gráficas avanzadas
    INCLUDE "logic_flow.asm"     ; Flujo principal del juego
    INCLUDE "logic_checks.asm"   ; Comprobaciones de victoria y jugadas
    INCLUDE "utilities.asm"      ; Rutinas que no son características de ninguna función particular

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
    CALL U_ESPERAR
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

EMPATE:
    CALL GB_EMPATE
    CALL K_SON                   ; Lee teclado (S/N)
    LD A, D
    CP 'S'
    CALL Z, LOGICA_JUEGO         ; Si se pulsó 'S', inicia nuevo juego
    CP 'N'
    CALL Z, ADIOS                ; Si se pulsó 'N', muestra pantalla de despedida
; Lógica principal del juego
LOGICA_JUEGO:
    CALL GB_PTLLA_INICIO_DE_JUEGO ; Dibuja pantalla de inicio de juego
    CALL LF_INICIALIZACION        ; Inicializa condiciones del juego
BUCLE_JUEGO:
    CALL LF_SWITCH_JUGADOR        ; Cambia de jugador
GESTIONAR_JUGADA:
    CALL GC_COLOR_JUGADOR_ACTUAL  ; Muestra el jugador actual en pantalla (HL = $5845)
JUGADA:
    CALL K_LR_E_F             ; Lee entrada (Q/W/O/P/ENTER/F)
    LD A, D
    PUSH AF
    CALL LC_VALIDPLAY             ; Comprueba si la jugada es válida
    CP 1
    JR Z, JUGADA                  ; Si no fue válida, espera nueva jugada
    POP AF
    CP 'Q': CALL Z, LF_JUGADA_DESPLAZAMIENTO ; Desplaza ficha a la derecha
    CP 'W':CALL Z, LF_JUGADA_DESPLAZAMIENTO ; Desplaza ficha a la izquierda
    CP 'I': CALL Z, LF_JUGADA_DESPLAZAMIENTO ; Desplaza ficha a la derecha
    CP 'O':CALL Z, LF_JUGADA_DESPLAZAMIENTO ; Desplaza ficha a la izquierda
    CP $FF: JR Z, JUGADA
    CP 'E': CALL Z, PROCESAR_JUGADA_FINAL
    CP 'P': CALL Z, PROCESAR_JUGADA_FINAL             ; Ejecuta acción de soltar ficha

    CP 'F': CALL Z, FIN_NEXT              ; Termina partida

    JR JUGADA
PROCESAR_JUGADA_FINAL:
    CALL GC_ENTER             ; La ficha cae 
    
    ; AQUI CONECTAMOS CON LA LOGICA
    CALL LC_COMPROBAR_RESULTADO
    CP 0: JR Z, FIN_NEXT            ; ¡SI (A=0), HA GANADO, SE VA A LA PANTALLA
    
    ; SI NO GANASTE, COMPROBAR EMPATE O SEGUIR (MIRAMOS EL FLAG C YA QUE SI SE ACTIVA ES EMPATE(EL 1 DE EMPATE ES MENOR QUE 64))
    ; SI NO SE ACTIVA EL FLAG C = CONTINUAR PARTIDA (128 = CONTINUAR PARTIDA Y ES > 64)
    CP 64   ; COMPRUEBA EMPATE O SEGUIR JUEGO (NUMERO RANDOM ENTRE EL 1(EMPATE) Y 128(SEGUIR JUGANDO))
    JR C, EMPATE
    JR BUCLE_JUEGO
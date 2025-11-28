; keyboard.asm - rutinas de lectura de teclado
; Convención general:
;  - El puerto de teclado se accede con IN A,(C) usando C=$FE (puerto 0xFE típico de ZX Spectrum)
;  - El código prueba bits concretos del registro A (BIT n, A). Si el bit es 0 => tecla pulsada
;  - Después de detectar una pulsación, las rutinas esperan a la liberación de la tecla
;    haciendo bucles que leen IN A,(C) y comparan (A AND $1F) con $1F (estado sin teclas).

K_SON: ; LECTURA DE TECLADO PARA 'S' O 'N' (respuesta S/N)
    LD C, $FE            ; puerto de lectura del teclado
KSON_BUCLE: 
    LD B, $FD            ; (valor de fila / máscara usada en el esquema de teclado)
    IN A, (C)            ; leer estado de las líneas del teclado
    BIT 1, A             ; prueba el bit 1 -> si Z (bit=0) la tecla correspondiente está pulsada
    JR Z, KSON_S

    LD B, $7F            ; cambiar máscara/fila para comprobar la otra tecla
    IN A, (C)
    BIT 3, A             ; prueba el bit 3 -> si Z la tecla 'N' está pulsada
    JR Z, KSON_N

    JR NZ, KSON_BUCLE    ; si ninguna detectada, repetir

KSON_N:
    LD D, 'N'            ; devuelve en D el carácter 'N' si se detectó esa tecla
    JR KSON_RELEASE

KSON_S:
    LD D, 'S'            ; devuelve en D el carácter 'S' si se detectó esa tecla

KSON_RELEASE:
    ; Espera a que la tecla sea liberada antes de retornar (anti-rebotes/simple debounce)
    IN A, (C)
    AND $1F
    CP $1F
    JR NZ, KSON_RELEASE

    RET ; FIN DE KSON (D contiene 'S' o 'N')


K_LR_ENTER_F: ; LECTURA DE TECLADO PARA Q (LEFT), W (RIGHT), ENTER (soltar ficha) o F
    LD C, $FE            ; puerto de lectura
    PUSH AF
KLREF_BUCLE:
    LD A, (JUGADOR_ACTUAL)
    CP 2
    JR Z, KLREF_BUCLE_J2
    LD B, $FB            ; seleccionar/activar fila de teclado
    IN A, (C)
    BIT 0, A             ; si bit0 = 0 -> tecla Q
    JR Z, KLREF_Q
    BIT 1, A             ; si bit1 = 0 -> tecla W
    JR Z, KLREF_W

    LD B, $BF            ; cambiar fila/mascara para ENTER
    IN A, (C)
    BIT 0, A             ; si bit0 = 0 -> ENTER
    JR Z, KLREF_ENTER

    LD B, $FD            ; otra fila para F
    IN A, (C)
    BIT 3, A             ; si bit3 = 0 -> tecla F
    JR Z, KLREF_F

    JR KLREF_BUCLE       ; repetir hasta detectar una tecla

KLREF_BUCLE_J2:
    LD B, $DF            ; seleccionar/activar fila de teclado
    IN A, (C)
    BIT 0, A             ; si bit0 = 0 -> tecla P
    JR Z, KLREF_P
    BIT 1, A             ; si bit1 = 0 -> tecla O
    JR Z, KLREF_O

    LD B, $BF            ; cambiar fila/mascara para ENTER
    IN A, (C)
    BIT 0, A             ; si bit0 = 0 -> ENTER
    JR Z, KLREF_ENTER

    LD B, $FD            ; otra fila para F
    IN A, (C)
    BIT 3, A             ; si bit3 = 0 -> tecla F
    JR Z, KLREF_F

    JR KLREF_BUCLE       ; repetir hasta detectar una tecla

KLREF_P:
    LD D, 'P'
    JR KLREF_RELEASE_OP

KLREF_O:
    LD D, 'O'

KLREF_RELEASE_OP:
    ; Espera a la liberación de Q o W (misma rutina de liberación compartida)
    LD B, $DF
    IN A, (C)
    AND $1F
    CP $1F
    JR NZ, KLREF_RELEASE_OP
    POP AF
    RET

KLREF_W:
    LD D, 'W'            ; devuelve 'W' en D
    JR KLREF_RELEASE_QW

KLREF_Q:
    LD D, 'Q'            ; devuelve 'Q' en D

KLREF_RELEASE_QW:
    ; Espera a la liberación de Q o W (misma rutina de liberación compartida)
    LD B, $FB
    IN A, (C)
    AND $1F
    CP $1F
    JR NZ, KLREF_RELEASE_QW
    POP AF
    RET


KLREF_ENTER:
    LD D, 13             ; código ASCII usado para ENTER en ZX Spectrum (valor 13)

KLREF_RELEASE_ENTER:
    ; Espera a la liberación de la tecla ENTER
    LD B, $BF
    IN A, (C)
    AND $1F
    CP $1F
    JR NZ, KLREF_RELEASE_ENTER
    POP AF
    RET ; FIN DE LECTURA Q W ENTER

KLREF_F:
    LD D, 'F'            ; devuelve 'F' en D

KLREF_RELEASE_F:
    ; Espera a la liberación de la tecla F
    LD B, $FD
    IN A, (C)
    AND $1F
    CP $1F
    JR NZ, KLREF_RELEASE_F
    POP AF
    RET
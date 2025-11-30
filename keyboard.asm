; keyboard.asm - rutinas de lectura de teclado
; Convención general:
;  - El puerto de teclado se accede con IN A,(C) usando C=$FE (puerto 0xFE típico de ZX Spectrum)
;  - El código prueba bits concretos del registro A (BIT n, A). Si el bit es 0 => tecla pulsada
;  - Después de detectar una pulsación, las rutinas esperan a la liberación de la tecla
;    haciendo bucles que leen IN A,(C) y comparan (A AND $1F) con $1F (estado sin teclas).

K_SON: ; LECTURA DE TECLADO PARA 'S' O 'N' (respuesta S/N)
    LD C, $FE            ; puerto de lectura del teclado

; KSON_BUCLE
; - Bucle que escanea el teclado hasta detectar S o N
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

; KSON_RELEASE
; - Espera a que la tecla no este pulsada antes de retornar (anti-rebotes/simple debounce)
KSON_RELEASE:
    IN A, (C)
    AND $1F
    CP $1F
    JR NZ, KSON_RELEASE

    RET ; FIN DE KSON (D contiene 'S' o 'N')

; K_LR_E_F
; - Rutina de lectura de teclado para las teclas Q (LEFT), W (RIGHT), ENTER (soltar ficha) o F
K_LR_E_F:
    LD C, $FE            ; puerto de lectura
    PUSH AF

; KLREF_BUCLE
; - Bucle que lee el teclado hasta detectar una de las teclas Q, W, ENTER o F con el uso de los bits 
; - Esta rutina es para el jugador 1
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
    BIT 2, A 
    JR Z, KLREF_E

    LD B, $FD            ; otra fila para F
    IN A, (C)
    BIT 3, A             ; si bit3 = 0 -> tecla F
    JR Z, KLREF_F

    JR KLREF_BUCLE       ; repetir hasta detectar una tecla

; KLREF_BUCLE_J2
; - Bucle que lee el teclado hasta detectar una de las teclas O, P, ENTER o F
; - Esta rutina es para el jugador 2
KLREF_BUCLE_J2:
    LD B, $DF            ; seleccionar/activar fila de teclado
    IN A, (C)
    BIT 0, A             ; si bit0 = 0 -> tecla P
    JR Z, KLREF_P
    BIT 1, A             ; si bit1 = 0 -> tecla O
    JR Z, KLREF_O
    BIT 2, A 
    JR Z, KLREF_I

    LD B, $FD            ; otra fila para F
    IN A, (C)
    BIT 3, A             ; si bit3 = 0 -> tecla F
    JR Z, KLREF_F

    JR KLREF_BUCLE_J2       ; repetir hasta detectar una tecla

KLREF_P:
    LD D, 'P'   ; devuelve en D el carácter 'P' si se detectó esa tecla
    JR KLREF_RELEASE_IOP

KLREF_O:
    LD D, 'O'   ; devuelve en D el carácter 'O' si se detectó esa tecla
    JR KLREF_RELEASE_IOP

KLREF_I:
    LD D, 'I'   ; devuelve en D el carácter 'I' si se detectó esa tecla

; KLREF_RELEASE_IOP
; - Espera a que la tecla P u O no este pulsada antes de retornar (anti-rebotes/simple debounce)
KLREF_RELEASE_IOP:
    LD B, $DF
    IN A, (C)
    AND $1F
    CP $1F
    JR NZ, KLREF_RELEASE_IOP
    POP AF
    RET

KLREF_E:
    LD D, 'E'            ; devuelve 'E' en D
    JR KLREF_RELEASE_QWE

KLREF_W:
    LD D, 'W'            ; devuelve 'W' en D
    JR KLREF_RELEASE_QWE

KLREF_Q:
    LD D, 'Q'            ; devuelve 'Q' en D

; KLREF_RELEASE_QWE
; - Espera a que la tecla Q o W no este pulsada antes de retornar (anti-rebotes/simple debounce)
KLREF_RELEASE_QWE:
    LD B, $FB
    IN A, (C)
    AND $1F
    CP $1F
    JR NZ, KLREF_RELEASE_QWE
    POP AF
    RET

KLREF_F:
    LD D, 'F'            ; devuelve 'F' en D

; KLREF_RELEASE_F
; - Espera a la liberación de la tecla F
KLREF_RELEASE_F:
    LD B, $FD
    IN A, (C)
    AND $1F
    CP $1F
    JR NZ, KLREF_RELEASE_F
    POP AF
    RET
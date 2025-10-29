S_N:
    LD C, $FE
SN_BUCLE: 
    LD B, $FD
    IN A, (C)
    BIT 1, A
    JR Z, SN_S
    LD B, $7F
    IN A, (C)
    BIT 3, A
    JR NZ, SN_BUCLE
SN_N:
    LD D, "N"
    JR SN_SEGUIR
SN_S:
    LD D, "S"
SN_SEGUIR:
    IN A, (C)
    AND $1F
    CP $1F
    JR NZ, SN_SEGUIR

    RET

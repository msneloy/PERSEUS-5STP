% COMMAND_TERMINAL-2
% VER 2.0
%
% SERIAL TERMINALPROGRAM FORPERSEUS-5(CPU:MC6802)
%
% HAND ASSEMBLED%% MITSURU YAMADA 08/JUN/2018
% CLEAN COPY      05/DEC/2020
%
%--------------------------------------------------------------------------------------
% COPYRIGHT (C) 2020 MITSURU YAMADA. ALL RIGHTS RESERVED.
%
%--------------------------------------------------------------------------------------
% ADDRESS MAPPING:24 X 4 CHARACTERS DISPLAYBUFFER (ADDRESS  $0000 -$005F)
%
% MAPPING TABLE, LOWER 8BITADDRESS(HEX)
%
% LEFT                                                                          RIGHT
%
% 00 01 02 03 04 05 06 07 :08 09 0A 0B 0C 0D 0E 0F : 10 11 12 13 14 15 16 17    TOP 
%
% 18 19 1A 1B 1C 1D 1E 1F : 20 21 22 23 24 25 26 27 : 28 29 2A 2B 2C 2D 2E 2F
%
% 30 31 32 33 34 35 36 37 : 38 39 3A 3B 3C 3D 3E 3F : 40 41 42 43 44 45 46 47
%
% 48 49 4A 4B 4C 4D 4E 4F : 50 51 52 53 54 55 56 57 : 58 59 5A 5B 5C 5D 5E 5F   BOTTOM
%
% -------------------------------------------------------------------------------------
% VARIABLES
            SYMBOL              DATA    
            REG_0               $60     LED FONT DATA EVACUATION
            REG_1               $61     LED CONTROL PATTERN EVACUATION
            REG_2               $62
            REG_3               $63     
            BUFFER_POINTER      $64     DISPLAY BUFFER POINTER (16 BIT)
            BUFFER_POINTER 2    $66     DISPLAY BUFFER POINTER 2 (16 BIT)
            FONT_POINTER_H      $68     FONT TABLE POINITER UPPER 8 BIT
            FONT_POINTER_L      $69     FONT TABLE POINITER LOWER 8 BIT
            SCAN_PATTERN        $6A     SCAN PATTERN EVACUATION
            SHIFT_FLAG          $6B     SHIFT KEY PRESSED FLAG
            PUSH_FLAG_1         $6C     KEY PRESSED FLAG
            PUSH_FLAG_2         $6D     KEY PRESSED LAST TIME FLAG
            TABL_POINTER_H      $6E     ASCII TABLE POINITER UPPER 8 BIT
            TABL_POINTER_L      $6F     ASCII TABLE POINITER LOWER 8 BIT
            SCAN_PATTERN_2      $70
%
% ----------------------------------------------------------------------------------
            
            BUFFER_START_1      $0000   DISPLAY BUFFER HEAD ADDRESS
            BUFFER_END_1        $0018   DISPLAY BUFFER LEFT END
            BUFFER_END_2        $0060   DISPLAY BUFFER END
            PORT                $4000   PARALLEL INTERFACE ADDRESS (R/W)
            ACIA_STATUS         $A000   ACIA STATUS REGISTER
            ACIA_DATA           $A001   ACIA DATA REGISTER
%----------------------------------------------------------------------------------
%
%                               ADDRESS(HEX)                DATA(HEX)
%-----------------------------------------------------------------------------------
% PROGRAM START ADDRESS         MAIN_1                      $FC00
% 
% RESET VECTOR
            .ORIGIN  $FFFE
                            FFFE  FC 00
%-----------------------------------------------------------------------------------
% TERMINAL BUFFER 1 CHARACTER PROCESS
% INPUT PARAMETER   ACCA:               ASCII CODE
                    BUFFER_POINTER:     CURRENT POSITION OF BUFFER POINTER 
%
            .ORIGIN  $F920
%
OUT_1_CHA       LDX BUFFER_POINTER      F920    DE  64  RETURN BUFFER POINTER
                CMPA #$61               F922    81  61  ASCII CODE > $60
                BCS  L11                F924    25  02  
                SUBA #$20               F926    80  20  CONVERT LOWERCASE TO UPPERCASEL11CMPA #$0AF92881 0ALF CODE?BEQ  SCROLLF92A27 1DGO TO SCROLL PROCESSCMPA #$0DF92C81 0DCR CODE?BEQ  LEFT_CURSOR_1F92E27 46MOVE CURSOR TO LEFT ENDCMPA #$08F93081 08BS CODE?BNE  L32F93226 0DBACK_SPACELDAA #$20F93486 20BACK SPACE PROCESSSTAA X,$48F936A7 48CLEAR CURRENT POINTER POSITIONDEXF93809POINTER -1CPX  #$FFFFF9398C FF FFKEEP POINTER NO EARLIER THAN TOPBNE  L31F93C26 06INXF93E08BRA  L31F93F20 03L32STAA X,$48F941A7 48WRITE 1 CHARACTER TO BUFFERINXF94308POINTER +1L31CPX  BUFFER_END_1F9448C 00 18BUFFER RIGHT END?BNE  L01F94726 26SCROLLCPX  BUFFER_START_1F9498C 00 00BUFFER LEFT END?BEQ  SCROLL_1F94C27 05LDAA #$20F94E86 20IF POINTER IS NOT LEFT END,STAA X,$48F950A7 48CLEAR POINITER POSITIONNOPF95201SCROLL_1LDX  BUFFER_START_1F953CE 00 00L02LDAA X,$18F956A6 18COPY 1 CHARACTER TO UPPER LINESTAA X,$00F958A7 00LDAA X,$30F95AA6 30STAA X,$18F95CA7 18LDAA X,$48F960A7 30LDAA #$20F96286 20CLEAR 1 CHARACTERLOWER LINESTAA X,$48F964A7 48INXF96608POINTER +1CPX  BUFFER_END_1F9678C 00 18COMPLETED UNTIL RIGHTEND?BNE  L02F96A26 EALEFT_CURSORLDX  BUFFER_START_1F96CCE 00 00SET POINTER LEFT ENDL01LDAA #$5FF96F86 5FSTAA X,$48F971A7 48DISPLAY UNDERSCORESTX  BUFFER_POINITERF973DF 64EVACUATE POINTERRTSF97539%LEFT_CURSOR_1LDAA #$20F97686 20MOVE CURSOR TO LEFT END STAA X,$48F978A7 48CLEAR UNDERSCORELDX  BUFFER_START_1F97ACE 00 00SET POINTER TO LEFT ENDSTX  BUFFER_POINTERF97DDF 64EVACUATE POINTERRTSF97F39%%--------------------------------------------------------------------------------------% KEY SCANNING.ORIGIN  $FA00%KEY_SCANLDAA #$00FA0086 00INIT.SCAN PATTERN NUMBERSTAA SCAN_PATTERN_2FA0297 70EVACUATE SCAN PATTERN NUMBERLDAA #$1BFA0486 FBASCII TABLE HEAD ADDRESS UPPERSTAA TABL_POINTER_HFA0697 6ELDAB #$00FA08C6 00INIT. SCAN PATTERN ($00)STAB SCAN_PATTERNFA0AD7 6AEVACUATE SCAN PATTERNCLRAFA0C4FSTAA SHIFT_FLAGFA0D97 6BCLEAR SHIFT KEY FLAGL20STAA PUSH_FLAG_1FA0F97 6CCLEAR KEY PUSHED FLAGL21JSR  L28FA11BD FA 78OUTPUT SCAN PATTERNLDAA PORTFA14B6 40 00INPUT SCAN RESULTCOMAFA1743INVERT SCAN RESULTBEQ  L26FA1827 3A$00? (NOT PRESSED)LDAB #$00FA1AC6 00CONVERT SCAN RESULT TO 3BIT DATAL22ASRAFA1C47SHIFT RIGHT 1BITBCS  L23FA1D25 03INCBFA1F5CLOOP COUNTER +1BRA  L22FA2020 FA%L23LDAA SCAN_PATTERN_2FA2296 70
NOPFA2401ABAFA251BADD 3BIT DATA AND KEY SCAN NUMBERLDAB #$01FA26C6 01STAB PUSH_FLAG_1FA28D7 6CSET PRESSED FLAG TO ‘1’LDAB PUSH_FLAG_2FA2AD6 6DLAST PRESSED FLAG = ‘1’ ?BNE  L26FA2C26 26IGNORE HOLDING DOWNCMPA #$00FA2E81 00SHIFT KEY PRESSED?BEQ  L25FA3027 32STAA TABL_POINTER_LFA3297 6FIF SHIFT KEY IS NOT PRESSED, LDX  TABL_POINTER_HFA34DE 6ESTORE TABLE INDEX TO IXLDAA X,$00FA36A6 00GET ASCII CODE BY USINGTABLE%SEND_1_CHALDAB ACIA_STATUSFA38F6 A0 00SEND 1 CHARACTER THROUGH ACIALSRBFA3B54LSRBFA3C54BCC  SEND_1_CHAFA3D24 F9STAA ACIA_DATAFA3FB7 A0 01L27LDAB PUSH_FLAG_1FA42D6 6CUPDATE KEY PRESSED LAST TIME FLAGSTAB PUSH_FLAG_2FA44D7 6DRTSFA4639END OF KEY SCAN SUBROUTNE%.ORIGIN  $FA54%L26LDAA SCAN_PATTERN_2FA5496 70ADDA #$08FA568B 08UPDATE SCAN PATTERN NUMBER(INCREMENT D3)STAA SCAN_PATTERN_2FA5897 70LDAB SCAN_PATTERNFA5AD6 6AINCBFA5C5CSCAN PATTERN +1CMPB #$06FA5DC1 06FINISH SCAN PATTERN $05 ?BNE L21FA5F26 B0IF NOT FINISH RETURN TO OUT SCAN PATTERNBRA L27FA6120 DFIF FINISH GO TO UPDATE PRESSED FLAG%.ORIGIN  $FA64%L25LDAA #$01FA6486 01SHIFT KEY PRESSED PROCESSSTAA SHIFT_FLAGFA6697 6BSET SHIFT FLAG TO ‘1’LDAB #$03FA68C6 03SET SCAN PATTREN TO $03 (SHIFT VALID RANGE)STAB SCAN_PATTERN_2FA6AD7 6ALDAA #$38FA6C86 38SET SCAN PATTERN NUMBER TO $38STAA SCAN_PATTERN_2FA6E97 70CLRAFA704FJMP  L20FA717E FA 0FRETURN TO DETECTING PRESSED%.ORIGIN  $FA78%L28STAB SCAN_PATTERNFA78D7 6AEVACUATE SCAN PATTERNANDB #$0FFA7AC4 0FD4-D7 FORCED ZEROSTAB PORTFA7CF7 40 00LDAB SCAN_PATTERNFA7FD6 6AOUTPUT SCAN PATTERNRTSFA8139%%-----------------------------------------------------------------------------------% SERIAL TERMNALMAINPROGRAM.ORIGIN  $FC00%MAINLDS  $007FFC008E 00 7FINIT. STACK POINTERJSR  INIT_DISP_2FC03BD FC 16INIT. LED MODULEJSR  INIT_ACIAFC06BD FC 68INIT. SERIAL INTERFACENOPFC0901NOPFC0A01NOPFC0B01L10JSR  DISP_BUFFERFC0CBD FC 80DISPLAY UPDATE ENTIRE BUFFERBRA  L10FC0F20 FBREPEAT%%-----------------------------------------------------------------------------------% INITIALIZE LED MODULE.ORIGIN  $FC16%INIT_DISP_2LDAA #$07FC1686 07STAA PORTFC18B7 40 00RESET LED MODULE *RE=LLDAA #$00FC1B86 00STAA PORTFC1DB7 40 00REREASE RESET LED MODULE *RE=H
INIT_DISPLDAA #$30FC2086 30STAA PORTFC22B7 40 00(CLK=L,RS=H,*CE=H)LDAA #$20FC2586 20STAA PORTFC27B7 40 00(CLK=L,RS=H,*CE=L)STAA REG_1FC2AB7 00 61EVACUATE CONTROL PATTERNLDAB #$18FC2DC6 18LOOP COUNTER = 24(DEC)L06STAB REG_3FC2FF7 00 63EVACUATE LOOP COUNTERLDAA #$4AFC3286 4ASET CONTROL WORD 0JSR  OUT_FNT_SERLFC34BD FC F0SEND SERIAL DATALDAB REG_3FC37F6 00 63RETURN LOOP COUNTERDECBFC3A5ALOOP COUNTER -1BNE  L06FC3B26 F2REPEATUNTIL LOOP COUNTER=0LDAA #$70FC3D86 70STAA PORTFC3FB7 40 00(CLK=H,RS=H,*CE=L)LDAA #$30FC4286 30STAA PORTFC44B7 40 00(CLK=L,RS=H,*CE=L)STAA REG_1FC47B7 00 61EVACUATE CONTROL PATTERNNOPFC4A01%CLEAR_BUFFERLDX  #$0000FC4BCE 00 00INIT. BUFFER ADDRESSLDAA #$20FC4E86 20SPACE CODEL40STAA X,$00FC50A7 00INXFC5208ADDRESS POINITER +1CPX  #$0060FC538C 00 60BUFFER END?BNE  L40FC5626 F8LDAA #$5FFC5886 5FUNDERSCORE CODESTAA $48FC5A97 48WRITE UNDERSCORE LOWER LEFTLDX  #$0000FC5CCE 00 00INIT. BUFFER ADDRESSSTX  BUFFER_POINTERFC5FFF 00 64EVACUATE BUFFER POINTERRTSFC6239%%-----------------------------------------------------------------------------------% INITIALIZE ACIA.ORIGIN  $FC68%INIT_ACIALDAA #$03FC6886 03STAA ACIA_STATUSFC6AB7 A0 00LDAA #$15FC6D86 154800 BIT/S 8BIT NO PARITYSTAA ACIA_STATUSFC6FB7 A0 00RTSFC7239%%-----------------------------------------------------------------------------------% DISPLAYUPDATE OF ENTIRE BUFFER.ORIGIN  $FC80%DISP_BUFFERLDAA REG_1FC8096 61ANDA #$D0FC8284 D0STAA PORTFC84B7 40 00(DATA=,CLK=,RS=L,*CE=)ANDA #$C0FC8784 C0STAA PORTFC89B7 40 00(DATA=,CLK=,RS=L,*CE=L)STAA REG_1FC8C97 61EVACUATE CONTROL PATTERNLDX  BUFFER_START_1FC8ECE 00 00BUFFER HEAD ADDRESSL03LDAA X,$00FC91A6 00GET 1 CHARACTER FROM BUFFERSTX  BUFFER_POINTER2FC93DF 66EVACUATE BUFFER POINTERJSR  OUT_FONTFC95BD FC C0SEND 1 CHARACTER FONT TO LED JSR  KEY_SCANFC98BD FA 00KEY SCANLDX  BUFFER_POINTER2FC9BDE 66RETURN BUFFER POINTERINXFC9D08POINTER +1CPX  BUFFER_END_2FC9E8C 00 60BUFFER END?BNE  L03FCA126 EELDAA REG_1FCA396 61ORAA #$10FCA58A 10STAA PORTFCA7B7 40 00(DATA=,CLK=,RS=,*CE=H)ANDA #$B0FCAA84 B0STAA PORTFCACB7 40 00(DATA=,CLK=L,RS=,*CE=)STAA REG_1FCAF97 61RTSFCB139%%-----------------------------------------------------------------------------------
% OUTPUT 1 CHARACTER FONT (5 BYTE)% INPUT PARAMETERACCA:ASCII CODE%
%FONT POINTER:(ASCII CODE -$20) AND SHIFT LEFT 3BIT = (D4 TO D8) OF 16BIT
%.ORIGIN  $FCC0
%OUT_FONTSUBA #$20FCC080 20ASCII CODE -$20ANDA #$3FFCC284 3FCLEAR UPPER 2 BITLDAB FONT_DATA_HFCC4C6 FEFONT DATA HEAD ADDRESSASLAFCC648SHIFT LEFT 3 BITASLAFCC748ASLAFCC848ADCB #$00FCC9C9 00IF CARRY=1, UPPER 8BIT + 1STAB FONT_POINTER_HFCCBD7 68STAA FONT_POINTER_LFCCD97 69SET CODE TO FONT DATA POINITER 9 BITL51LDX  FONT_POINTERFCCFDE 68LDAB #$05FCD1C6 05ACCB: LOOP COUNTER FOR 5 BYTE FONTL04LDAA #$00FCD3A6 00EXTRACTION FONT DATANOPFCD501BRA  L52FCD620 09PATCH TO PREVENT IX BREAK ON SERIAL INPUTNOPFCD801NOPFCD901NOPFCDA01L53LDAB REG_2FCDBD6 62RETURN LOOP COUNTERDECBFCDD5ALOOP COUNTER -1BNE  L04FCDE26 F3RTSFCE039L52STAB REG_2FCE1D7 62EVACUATE LOOP COUNTERINXFCE308FONT POINTER +1STX  FONT_POINITERFCE4DF 68EVACUATE FONT POINTERJSR  OUT_FNT_SERLFCE6BD FC F0OUTPUT FONT BY SERIALLDX  FONT_POINTERFCE9DE 68RETURN FONT POINTERJMP  L53FCEB7E FC DB%%-----------------------------------------------------------------------------------% OUTPUT FONT 1 BYTE TO LED DISPLAY MODULE BY SERIAL% INPUT PARAMETERACCA:FONT DATA AND CONTROL REGISTER VALUEREG_1:CURRENT CONTROL LINE LEVEL%.ORIGIN  $FCF0%OUT_FNT_SERLLDAB #$08FCF0C6 08SET LOOP COUNTER (8BIT)STAA REG_0FCF297 60EVACUATE FONT DATALDAA REG_1FCF496 61RETURN CONTROL DATAANDA #$3FFCF684 3F(DATA=L,CLK=L,RS=,*CE=)STAA REG_1FCF897 61L05LDAA REG_0FCFA96 60RETURN FONT DATAANDA #$80FCAC84 80EXTRACTION D7ORAA REG_1FCFE9A 61SYNTHESIZE CONTROL DATASTAA PORTFD00B7 40 00OUTPUT TO LED MODULEORAA #$40FD038A 40(DATA=L,CLK=H,RS=,*CE=)STAA PORTFD05B7 40 00OUTPUT TO LED MODULEASL  REG_0FD0878 00 60SHIFT LEFT FONT DATADECB FD0B5ALOOP COUNTER -1BNE  L05FD0C26 ECLDAA ACIA_STATUSFD0EB6 A0 00SERIAL INPUT RECEIVED?LSRAFD1144BCC  L14FD1224 06IF NOT RECEIVED, EXITLDAA ACIA_STATUSFD14B6 A0 01JSR  OUT_1_CHAFD17BD F9 20IF RECEIVED, 1 CHARACTER PROCESSL14RTSFD1A39%%-------------------------------------------------------------------------------------% KEY SCAN ASCII CODE TABLE.ORIGIN  $FB00%ADDRESS(HEX)DATA(HEX)FB00FF 5A 58 43 56 42 4E 4DFB0841 53 44 46 47 48 4A 4BFB1051 57 45 52 54 59 55 49FB1831 32 33 34 35 36 37 38FB202C 2E 2F 20 4F 50 40 0DFB284C 3B 3A 0A 39 30 2D 08
FB30FF FF FF FF FF FF FF FFFB3821 22 23 24 25 26 27 28FB403C 3E 3F FF FF FF FF FFFB48FF 2B 2A FF 29 5C 3D FF
%------------------------------------------------------------------------------------
% FONT DATA TABLE
% 5 X 7 DOT MATRIX CHARACTER FONT
                .ORIGIN  $FE00
% ADDRESS(HEX)  DATA(HEX)       CHARACTER
    FE0000      00 00 0000      ‘ ’
    FE0800      5F 00 00 00     ‘!’
    FE1000      03 00 03 00     ‘”’
    FE1814      7F 14 7F 14     ‘#’
    FE2024      2A 7F 2A 12     ‘$’
    FE2823      13 08 64 62     ‘&’
    FE3036      49 56 20 50     ‘’’
    FE3800      0B 07 00 00     ‘(’
    FE4000      00 3E 41 00     ‘)’
    FE4800      41 3E 00 00     ‘*’
    FE5008      2A 1C 2A 08     ‘+’
    FE5808      08 3E 08 08     ‘,‘
    FE6000      58 38 00 00     ‘-‘
    FE7000      30 30 00 00     ‘.‘
    FE7820      10 08 04 02     ‘/‘
    FE803E      51 49 45 3E     ‘0‘
    FE8800      42 7F 40 00     ‘1‘
    FE9062      51 49 49 46     ‘2‘
    FE9822      41 49 49 36     ‘3‘
    FEA018      14 12 7F 10     ‘4‘
    FEA827      45 45 45 39     ‘5‘
    FEB03C      4A 49 49 30     ‘6‘
    FEB801      71 09 05 03     ‘7‘
    FEC036      49 49 49 36     ‘8‘
    FEC806      49 49 29 1E     ‘9‘
    FED000      36 36 00 00     ‘:‘
    FED800      5B 3B 00 00     ‘;‘
    FEE000      08 14 22 41     ‘<‘
    FEE814      14 14 14 14     ‘=‘
    FEF041      22 14 08 00     ‘>‘
    FEF802      01 51 09 06     ‘?‘
    FF003E      41 5D 55 1E     ‘@‘
    FF087E      09 09 09 7E     ‘A‘
    FF107F      49 49 49 36     ‘B‘
    FF183E      41 41 41 22     ‘C‘
    FF207F      41 41 41 3E     ‘D‘
    FF287F      49 49 49 41     ‘E‘
    FF307F      09 09 09 01     ‘F‘
    FF383E      41 41 51 72     ‘G‘
    FF407F      08 08 08 7F     ‘H‘
    FF4800      41 7F 41 00     ‘I‘
    FF5020      40 40 40 3F     ‘J‘
    FF587F      08 14 22 41     ‘K‘
    FF607F      40 40 40 40     ‘L‘
    FF687F      02 0C 02 7F     ‘M‘
    FF707F      04 08 10 7F     ‘N‘
    FF783E      41 41 41 3E     ‘O‘
    FF807F      09 09 09 06     ‘P‘
    FF883E      41 51 21 5E     ‘Q‘
    FF907F      09 19 29 46     ‘R‘
    FF9826      49 49 49 32     ‘S‘
    FFA001      01 7F 01 01     ‘T‘
    FFA83F      40 40 40 3F     ‘U‘
    FFB007      18 60 18 07     ‘V‘
    FFB87F      20 18 20 7F     ‘W‘
    FFC063      14 08 14 63     ‘X‘
    FFC803      04 78 04 03     ‘Y‘
    FFD061      51 49 45 43     ‘Z‘
    FFD800      00 7F 41 41     ‘[‘
    FFE002      04 08 10 20     ‘¥‘
    FFE841      41 7F 00 00     ‘]‘
    FFF004      02 7F 02 04     ‘^’
    FFF840      40 40 40 40     ‘_‘
%
%-------------------------------------------------------------------------------------
% END OF PROGRAM

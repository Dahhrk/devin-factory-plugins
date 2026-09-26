       IDENTIFICATION DIVISION.
       PROGRAM-ID. SMELL.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-FLAG PIC X VALUE "N".
       01  WS-IN   PIC X(20).
       PROCEDURE DIVISION.
       MAIN.
      *> Intentional smells for cobol-rg-gate discrimination (not product code).
           ALTER MAIN TO PROCEED TO DONE-PARA
           ACCEPT WS-IN
           IF WS-FLAG = "Y"
               DISPLAY "yes".
           GO TO DONE-PARA
       DONE-PARA.
           STOP RUN.

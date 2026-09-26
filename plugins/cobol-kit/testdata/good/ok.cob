       IDENTIFICATION DIVISION.
       PROGRAM-ID. OK.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-FLAG PIC X VALUE "N".
       01  WS-IN   PIC X(20).
       PROCEDURE DIVISION.
       MAIN.
           ACCEPT WS-IN ON EXCEPTION
               MOVE "N" TO WS-FLAG
           END-ACCEPT
           IF WS-FLAG = "Y"
               DISPLAY "yes"
               PERFORM HANDLE-YES
           END-IF
      *> Documented intentional seam; keep allow on the smell line.
           GO TO DONE-PARA *> cobol-rg-allow: fixture documents allow marker for intentional GOTO seam
       DONE-PARA.
           STOP RUN.
       HANDLE-YES.
           DISPLAY "handled"
           EXIT.

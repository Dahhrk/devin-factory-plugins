      *> Boundary: every IF needs a matching END-IF (no period-terminated IF-without-END-IF).
      *> File-level IF count must not exceed END-IF count (cobol-rg-gate).
           IF WS-FLAG = "Y"
               DISPLAY "yes"
               PERFORM HANDLE-YES
           END-IF

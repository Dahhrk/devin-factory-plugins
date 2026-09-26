      *> Boundary: ACCEPT must carry ON EXCEPTION (or ON ERROR) on the same line.
      *> Unchecked ACCEPT is banned by cobol-rg-gate. Escape: cobol-rg-allow with rationale.
           ACCEPT WS-IN ON EXCEPTION
               MOVE "N" TO WS-OK
           END-ACCEPT

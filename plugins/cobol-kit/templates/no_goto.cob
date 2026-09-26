      *> Boundary: prefer PERFORM / EVALUATE / structured EXIT over GOTO / GO TO.
      *> GOTO is banned by cobol-rg-gate. Escape: cobol-rg-allow with rationale on the smell line.
       EVALUATE WS-CODE
           WHEN "A"
               PERFORM HANDLE-A
           WHEN OTHER
               PERFORM HANDLE-OTHER
       END-EVALUATE

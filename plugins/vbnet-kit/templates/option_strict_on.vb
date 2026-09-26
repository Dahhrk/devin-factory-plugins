' Boundary: prefer Option Strict On (file or vbproj <OptionStrict>On</OptionStrict>).
' Option Strict Off is banned by vbnet-rg-gate. Escape: vbnet-rg-allow with rationale.
Option Strict On
Option Explicit On

Public Class StrictSample
    Public Function Add(a As Integer, b As Integer) As Integer
        Return a + b
    End Function
End Class

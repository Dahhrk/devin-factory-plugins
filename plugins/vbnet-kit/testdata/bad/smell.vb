' Intentional smells for vbnet-rg-gate discrimination (not product code).
Option Strict Off

Public Module Smell
    Public Sub BadPath()
        On Error Resume Next
        Console.WriteLine("lib console leak")
        Dim x = "1"
        Dim y As Integer = x
    End Sub
End Module

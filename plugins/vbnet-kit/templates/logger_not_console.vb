' Boundary: library modules must not Console.Write/WriteLine.
' Prefer ILogger / Trace / Debug. CLI Program.vb may Console with allow when intentional.
' Console.WriteLine in libs is banned by vbnet-rg-gate. Escape: vbnet-rg-allow with rationale.
Imports Microsoft.Extensions.Logging

Public Class Greeter
    Private ReadOnly _log As ILogger(Of Greeter)

    Public Sub New(log As ILogger(Of Greeter))
        _log = log
    End Sub

    Public Sub Hello(name As String)
        _log.LogInformation("hello {Name}", name)
    End Sub
End Class

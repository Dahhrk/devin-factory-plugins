' Boundary: prefer Try / Catch / Finally over On Error Resume Next.
' On Error Resume Next is banned by vbnet-rg-gate. Escape: vbnet-rg-allow with rationale on the smell line.
Public Function ReadSafe(path As String) As String
    Try
        Return IO.File.ReadAllText(path)
    Catch ex As IO.IOException
        Return String.Empty
    End Try
End Function

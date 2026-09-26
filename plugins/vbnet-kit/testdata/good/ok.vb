Option Strict On
Option Explicit On

Public Module Ok
    Public Sub GoodPath()
        ' Documented intentional seam; keep allow on the smell line.
        Console.WriteLine("fixture") ' vbnet-rg-allow: fixture documents allow marker for intentional Console seam
    End Sub
End Module

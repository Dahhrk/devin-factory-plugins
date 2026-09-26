using System.Data;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;

namespace Demo;

public class Ok
{
    private readonly ILogger<Ok> _log;

    public Ok(ILogger<Ok> log)
    {
        _log = log;
    }

    public void LogOk(string message)
    {
        _log.LogInformation("{Message}", message);
    }

    public async Task<string?> SqlOkAsync(SqlConnection conn, long id, CancellationToken ct)
    {
        await using var cmd = new SqlCommand("SELECT name FROM users WHERE id = @id", conn);
        cmd.Parameters.Add(new SqlParameter("@id", SqlDbType.BigInt) { Value = id });
        var result = await cmd.ExecuteScalarAsync(ct);
        return result as string;
    }

    /* Named boundary docs; intentional legacy uses csharp-rg-allow on the smell line. */
    public void DocumentedLegacy()
    {
        Console.WriteLine("boot banner"); // csharp-rg-allow: process bootstrap before logger binds
    }
}

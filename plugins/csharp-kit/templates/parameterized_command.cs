/* Named boundary: prefer parameterized SqlCommand over SQL string concat.
 * Copy into product sources; keep csharp-rg-allow only on intentional seams.
 */
using System.Data;
using Microsoft.Data.SqlClient;

namespace Demo;

public static class ParameterizedLookup
{
    public static async Task<string?> FindNameAsync(SqlConnection conn, long id, CancellationToken ct)
    {
        await using var cmd = new SqlCommand("SELECT name FROM users WHERE id = @id", conn);
        cmd.Parameters.Add(new SqlParameter("@id", SqlDbType.BigInt) { Value = id });
        var result = await cmd.ExecuteScalarAsync(ct);
        return result as string;
    }
}

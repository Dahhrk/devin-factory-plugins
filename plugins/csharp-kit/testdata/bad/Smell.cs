using System;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Demo;

public class Smell
{
    public void LogBad()
    {
        Console.WriteLine("bad");
    }

    public SqlDataReader SqlBad(SqlConnection conn, string id)
    {
        var cmd = new SqlCommand("SELECT * FROM users WHERE id = " + id, conn);
        return cmd.ExecuteReader();
    }

    public int BlockBad(Task<int> task)
    {
        return task.Result;
    }
}

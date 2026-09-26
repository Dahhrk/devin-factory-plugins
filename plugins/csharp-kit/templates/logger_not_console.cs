/* Named boundary: prefer ILogger over Console.Write/WriteLine in libraries.
 * Copy into product sources; keep csharp-rg-allow only on intentional seams.
 */
using Microsoft.Extensions.Logging;

namespace Demo;

public static class AppLog
{
    public static void Info(ILogger logger, string message)
    {
        logger.LogInformation("{Message}", message);
    }

    public static void Error(ILogger logger, Exception error, string message)
    {
        logger.LogError(error, "{Message}", message);
    }
}

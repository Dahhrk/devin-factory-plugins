/* Named boundary: lock on a private object, never on this / typeof(...) / a string.
 * Callers can lock the same public instance or Type, and string literals are interned.
 * .NET 9+: prefer System.Threading.Lock. Older targets: private readonly object.
 */
using System.Threading;

namespace Demo;

public sealed class Counter
{
    private readonly Lock _gate = new();
    private int _value;

    public int Increment()
    {
        lock (_gate)
        {
            return ++_value;
        }
    }
}

// Named boundary: document lifetime before Unsafe*Pointer / withUnsafe*.
// Copy into product sources; keep swift-rg-allow only on intentional seams.

func bytesAsHex(_ data: ContiguousBytes) -> String {
    data.withUnsafeBytes { (buf: UnsafeRawBufferPointer) -> String in  // swift-rg-allow: ContiguousBytes lifetime bound to withUnsafeBytes
        buf.map { String(format: "%02x", $0) }.joined()
    }
}

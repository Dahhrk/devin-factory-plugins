// Intentional smells for swift-rg-gate discrimination (not product code).

func forceBad(_ value: String?) -> String {
    return value!
}

func tryBad() -> Int {
    return try! Int("x")
}

func unsafeBad(_ count: Int) -> Int {
    let ptr = UnsafeMutablePointer<Int>.allocate(capacity: count)
    ptr.initialize(repeating: 0, count: count)
    let first = ptr.pointee
    ptr.deallocate()
    return first
}

func withUnsafeBad(_ value: Int) -> Int {
    var copy = value
    return withUnsafePointer(to: &copy) { $0.pointee }
}

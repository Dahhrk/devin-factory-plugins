// Named boundary: prefer if let / guard let / ?? over force unwrap.
// Copy into product sources; keep swift-rg-allow only on intentional seams.

func firstLabel(in values: [String?]) -> String? {
    guard let first = values.first else { return nil }
    return first ?? "missing"
}

func requireLabel(_ value: String?) throws -> String {
    guard let value else {
        throw NSError(domain: "swift-kit", code: 1)
    }
    return value
}

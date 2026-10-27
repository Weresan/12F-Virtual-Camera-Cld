import Foundation

struct PairingEndpoint {
    let socketURL: URL
    let token: String

    init(_ text: String, allowInsecureLAN: Bool = false) throws {
        guard var parts = URLComponents(string: text.trimmingCharacters(in: .whitespacesAndNewlines)),
              let scheme = parts.scheme, ["https", "http"].contains(scheme),
              let host = parts.host, !host.isEmpty, parts.user == nil, parts.password == nil,
              parts.query == nil, parts.path == "/" || parts.path.isEmpty,
              let fragment = parts.fragment,
              let fields = URLComponents(string: "https://pair.invalid/?" + fragment)?.queryItems,
              fields.count == 1, fields[0].name == "token",
              let token = fields[0].value, (32...128).contains(token.count),
              token.allSatisfy({ $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-" || $0 == "_") }) else {
            throw PairingError.invalidQR
        }
        if scheme == "http" {
            #if DEBUG
            let octets = host.split(separator: ".").compactMap { UInt8($0) }
            let privateIP = octets.count == 4 && octets.map(String.init).joined(separator: ".") == host && (octets[0] == 10 ||
                (octets[0] == 172 && (16...31).contains(octets[1])) ||
                (octets[0] == 192 && octets[1] == 168))
            guard allowInsecureLAN && privateIP else { throw PairingError.requiresTLS }
            #else
            throw PairingError.requiresTLS
            #endif
        }
        guard !["localhost", "127.0.0.1", "::1", "0.0.0.0"].contains(host) else {
            throw PairingError.invalidQR
        }
        parts.scheme = scheme == "https" ? "wss" : "ws"
        parts.path = "/ws"; parts.fragment = nil
        guard let url = parts.url else { throw PairingError.invalidQR }
        self.socketURL = url; self.token = token
    }
}

enum PairingError: LocalizedError {
    case invalidQR, requiresTLS
    var errorDescription: String? {
        switch self {
        case .invalidQR: return "Scan the current 12F pairing QR from Blender. This code is not a valid pairing link."
        case .requiresTLS: return "Use trusted HTTPS. For local development only, a Debug build can enable unencrypted private-LAN pairing."
        }
    }
}

import Foundation

enum Instrument: String, CaseIterable, Hashable, Equatable, Codable {
    
    static var allPatches: [(bank: UInt32, program: UInt32)] {
        Self.allCases.map { (bank: UInt32($0.bank), program: UInt32($0.program)) }
    }
    
    case grand, rhodes, marimba, organ
    
    var isEssential: Bool {
        true
    }
    
    var description: String {
        switch self {
        case .grand: "Grand Piano"
        case .rhodes: "Electric Piano"
        case .marimba: "Marimba"
        case .organ: "Organ"
        }
    }

    var subscriptionRequired: Bool {
        switch self {
        case .grand: false
        default: true
        }
    }

    
    var url: URL? {
        if self.isEssential {
            return Bundle.main.url(forResource: "essentials", withExtension: "sf2")
        } else {
            return nil
        }
    }
    var program: UInt8 {
        switch self {
        case .grand: return 0

        case .rhodes: return 4
        case .marimba: return 12
        case .organ: return 16

        }
    }

    var bank: UInt8 {
        0x79
    }
}

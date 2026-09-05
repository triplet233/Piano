import Foundation

enum Instrument: String, CaseIterable, Hashable, Equatable, Codable {
    
    static var allPatches: [(bank: UInt32, program: UInt32)] {
        Self.allCases.map { (bank: UInt32($0.bank), program: UInt32($0.program)) }
    }
    
    case grand, rhodes, marimba, fingerBass, organ, guitar, atmosphere, strings,
         drumKit, electronicKit, tr808
    
    var isEssential: Bool {
        switch self {
        case .grand, .rhodes, .marimba, .fingerBass, .organ, .guitar, .atmosphere, .strings,
                .drumKit, .electronicKit, .tr808: true
//        default: false
        }
    }
    
    var description: String {
        switch self {
        case .grand: "Grand Piano"
        case .rhodes: "Electric Piano"
        case .marimba: "Marimba"
        case .fingerBass: "Finger Bass"
        case .strings: "Strings"
        case .organ: "Organ"
        case .guitar: "Acoustic Guitar"
        case .atmosphere: "Atmosphere"
            
        case .drumKit: "Drum Kit"
        case .electronicKit: "Electronic Kit"
        case .tr808: "TR-808"
        }
    }

    var isDrum: Bool {
        switch self {
        case .drumKit, .electronicKit, .tr808: true
        default: false
        }
    }
    var isBass: Bool {
        switch self {
        case .grand, .rhodes, .fingerBass: true
        default: false
        }
    }
    var isChord: Bool {
        switch self {
        case .grand, .rhodes, .marimba, .atmosphere, .organ, .guitar, .strings: true
        default: false
        }
    }
    var isMelodic: Bool {
        switch self {
        case .grand, .rhodes, .marimba, .guitar, .organ: true
        default: false
        }
    }
    var subscriptionRequired: Bool {
        switch self {
        case .grand, .fingerBass, .drumKit: false
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
        case .fingerBass: return 33
        case .drumKit: return 0
            
        case .rhodes: return 4
        case .marimba: return 12
        case .strings: return 48
        case .organ: return 16
        case .guitar: return 24
        case .atmosphere: return 99
        case .electronicKit: return 24
        case .tr808: return 25
        }
    }

    var bank: UInt8 {
        switch self {
        case .drumKit, .electronicKit, .tr808: 0x78
        default: 0x79
        }
    }
}

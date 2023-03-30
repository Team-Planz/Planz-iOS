//
//  Font.swift
//
//
//  Created by Sujin Jin on 2023/03/27.
//

import SwiftUI

// MARK: - PretendardFont

public struct PretendardFont {
    static let medium = PretendardFont(named: "Pretendard-Medium")
    static let semibold = PretendardFont(named: "Pretendard-SemiBold")

    let name: String

    private init(named name: String) {
        self.name = name
        do {
            try registerFont(named: name)
        } catch {
            let reason = error.localizedDescription
            fatalError("Failed to register font: \(reason)")
        }
    }
}

// MARK: - PDS.FONT

public extension PDS {
    enum FONT: String, CaseIterable {
        case headline14
        case headline16
        case headline18
        case headline20
        case headline24

        case subtitle14
        case subtitle16

        case body12
        case body14
        case body16

        case caption

        public var values: (size: CGFloat, font: PretendardFont) {
            switch self {
            case .headline14:
                return (14, .semibold)
            case .headline16:
                return (16, .semibold)
            case .headline18:
                return (18, .semibold)
            case .headline20:
                return (20, .semibold)
            case .headline24:
                return (24, .semibold)
            case .subtitle14:
                return (14, .semibold)
            case .subtitle16:
                return (16, .semibold)
            case .body12:
                return (12, .medium)
            case .body14:
                return (14, .medium)
            case .body16:
                return (16, .medium)
            case .caption:
                return (12, .medium)
            }
        }
    }
}

public extension Font {
    static func planz(_ designFont: PDS.FONT) -> Font {
        return .custom(
            designFont.values.font.name,
            size: designFont.values.size
        )
    }
}

#if DEBUG
    private struct FontView: View {
        var body: some View {
            VStack {
                Text("Hello 안녕하세요?")
                    .font(.planz(.headline24))
                    .foregroundColor(PDS.COLOR.purple9.scale)

                Text("Hello 안녕하세요?")
                    .font(.headline)
            }
        }
    }

    struct Font_Previews: PreviewProvider {
        static var previews: some View {
            FontView()
        }
    }
#endif

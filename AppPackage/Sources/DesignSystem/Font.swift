//
//  Font.swift
//
//
//  Created by Sujin Jin on 2023/03/27.
//

import SwiftUI

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

        public var values: (size: CGFloat, weight: Font.Weight) {
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

public extension Text {
    func PDSfont(_ designFont: PDS.FONT) -> Text {
        return font(
            .system(
                size: designFont.values.size,
                weight: designFont.values.weight
            )
        )
    }
}

#if DEBUG
    private struct FontView: View {
        var body: some View {
            VStack {
                Text("Hello")
                    .PDSfont(.body14)
                    .foregroundColor(PDS.COLOR.purple9.scale)
            }
        }
    }

    struct Font_Previews: PreviewProvider {
        static var previews: some View {
            FontView()
        }
    }
#endif

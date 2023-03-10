//
//  File.swift
//
//
//  Created by 한상준 on 2023/02/12.
//

import SwiftUI

public extension PDS {
    enum Icon: String, CaseIterable {
        case kakao

        public var image: Image {
            return Image(rawValue, bundle: Bundle.module)
        }
    }
}

#if DEBUG
    private struct IconView: View {
        var body: some View {
            VStack {
                PDS.Icon.kakao.image
                    .aspectRatio(contentMode: .fill)
            }
        }
    }

    struct Icon_Previews: PreviewProvider {
        static var previews: some View {
            IconView()
        }
    }
#endif
//
//  File.swift
//
//
//  Created by 한상준 on 2023/02/12.
//

import SwiftUI

public extension PDS {
    enum Icon: String, CaseIterable {
        case planzLogo

        case homeTab
        case makePromiseTab
        case promiseManagementTab

        case planzLogoHome

        case meeting
        case meal
        case etc
        case trip

        case profile

        case kakao
        case mailIllustration
        case planzLogoPurpleBackground

        case calendarHeaderList
        case calendarHeaderRight
        case calendarHeaderLeft

        case close
        case illustDetail

        case calendar
        case emptySchedule

        case illustEmptydata
        case illustError
        case plus

        case face
        case iosShare
        case location
        case share
        case user

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

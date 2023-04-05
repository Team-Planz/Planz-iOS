//
//  ConfirmedDetailView.swift
//
//
//  Created by Sujin Jin on 2023/03/06.
//

import DesignSystem
import SwiftUI
import SwiftUIHelper

// MARK: - ConfirmedDetailView

public struct PromiseDetailView: View {
    @Environment(\.screenSize) var screenSize

    let state: State

    public init(state: State) {
        self.state = state
    }

    public var body: some View {
        VStack {
            PDS.Icon.illustDetail.image
                .resizable()
                .zIndex(1)
                .offset(y: 32)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                Group {
                    Text(state.theme)
                        .bold()
                        .font(.title)
                        .foregroundColor(PColor.purple9.scale)

                    Text(state.title)
                        .foregroundColor(PColor.cGray2.scale)
                }
                .frame(maxWidth: .infinity, alignment: .center)

                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(PColor.gray3.scale)

                VStack(alignment: .leading, spacing: 16) {
                    makeContentView(
                        title: "날짜/시간",
                        content: formatter.string(from: state.date)
                    )

                    makeContentView(
                        title: "장소",
                        content: state.place
                    )

                    makeContentView(
                        title: "참여자",
                        content: state.participants
                            .sorted(by: <)
                            .joinedNames(separator: ", ")
                    )
                }
                .padding(.top)
            }
            .padding(EdgeInsets(top: 32, leading: 20, bottom: 32, trailing: 20))
            .background(PColor.gray1.scale)
            .frame(width: screenSize.width * 0.9, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(PColor.gray3.scale, lineWidth: 1)
            )
        }
        .offset(y: -screenSize.height * 0.1)
    }

    private func makeContentView(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .foregroundColor(PColor.gray6.scale)

            Text(content)
                .foregroundColor(PColor.gray8.scale)
        }
    }
}

public extension PromiseDetailView {
    struct State: Equatable, Identifiable {
        public let id: UUID
        let title: String
        let theme: String
        let date: Date
        let place: String
        let participants: [String]

        public init(
            id: UUID,
            title: String,
            theme: String,
            date: Date,
            place: String,
            participants: [String]
        ) {
            self.id = id
            self.title = title
            self.theme = theme
            self.date = date
            self.place = place
            self.participants = participants
        }
    }
}

private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "M월 d일 a h시 m분"
    formatter.locale = .init(identifier: "KO")

    return formatter
}()

#if DEBUG
    struct ConfirmedDetailView_Previews: PreviewProvider {
        static var previews: some View {
            PromiseDetailView(state:
                .init(
                    id: UUID(),
                    title: "약속명",
                    theme: "여행",
                    date: .now,
                    place: "강남",
                    participants: ["정인혜", "이은영"]
                )
            )
        }
    }
#endif

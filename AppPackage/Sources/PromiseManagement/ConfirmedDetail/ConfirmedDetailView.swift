//
//  ConfirmedDetailView.swift
//
//
//  Created by Sujin Jin on 2023/03/06.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct ConfirmedDetailFeature: ReducerProtocol {
    public struct State: Equatable, Identifiable {
        public let id: UUID
        let title: String
        let theme: String
        let date: String
        let place: String
        let participants: [String]
    }

    public enum Action: Equatable {}

    public var body: some ReducerProtocol<State, Action> {
        EmptyReducer()
    }
}

// MARK: - ConfirmedDetailView

public struct ConfirmedDetailView: View {
    let store: StoreOf<ConfirmedDetailFeature>

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            GeometryReader { proxy in
                NavigationView {
                    VStack {
                        PDS.Icon.illustDetail.image
                            .resizable()
                            .zIndex(1)
                            .offset(y: 32)
                            .frame(width: 64, height: 64)

                        VStack(alignment: .leading) {
                            Group {
                                Text(viewStore.theme)
                                    .bold()
                                    .font(.title)
                                    .foregroundColor(PColor.purple9.scale)

                                Text(viewStore.title)
                                    .foregroundColor(PColor.cGray2.scale)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)

                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(PColor.gray3.scale)

                            VStack(alignment: .leading, spacing: 16) {
                                makeContentView(
                                    title: "날짜/시간",
                                    content: viewStore.date
                                )

                                makeContentView(
                                    title: "장소",
                                    content: viewStore.place
                                )

                                makeContentView(
                                    title: "참여자",
                                    content: viewStore.participants
                                        .sorted(by: <)
                                        .joinedNames(separator: ", ")
                                )
                            }
                            .padding(.top)
                        }
                        .padding(EdgeInsets(top: 32, leading: 20, bottom: 32, trailing: 20))
                        .background(PColor.gray1.scale)
                        .frame(width: proxy.size.width * 0.9, alignment: .leading)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(PColor.gray3.scale, lineWidth: 1)
                        )
                    }
                    .offset(y: -proxy.size.height * 0.1)
                }
            }
        }
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

#if DEBUG
    struct ConfirmedDetailView_Previews: PreviewProvider {
        static var previews: some View {
            ConfirmedDetailView(store:
                .init(
                    initialState:
                    ConfirmedDetailFeature.State(
                        id: UUID(),
                        title: "약속명",
                        theme: "여행",
                        date: "2023",
                        place: "강남",
                        participants: ["정인혜", "이은영"]
                    ),
                    reducer: ConfirmedDetailFeature()._printChanges()
                )
            )
        }
    }
#endif

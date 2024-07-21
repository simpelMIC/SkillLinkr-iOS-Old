//
//  FeedView.swift
//  SkillLinkr
//
//  Created by Christian on 15.07.24.
//

import Foundation
import SwiftUI

enum SwipeState {
    case left
    case non
    case right
}

struct FeedView: View {
    @Binding var httpModule: HTTPModule
    @Binding var appData: AppData
    @State var showDetailView: Bool = false
    @State var naviUser: User?
    @State var swipeState: SwipeState = .non
    
    @State var users: [User] = [
        User(id: "1", firstname: "Test1", lastname: "Testmann1", mail: "test@testmann.com", released: true, role: UserRole(id: 0, name: "User", description: "User", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""),
        User(id: "2", firstname: "Test2", lastname: "Testmann2", mail: "test@testmann.com", released: true, role: UserRole(id: 0, name: "User", description: "User", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""),
        User(id: "3", firstname: "Test3", lastname: "Testmann3", mail: "test@testmann.com", released: true, role: UserRole(id: 0, name: "User", description: "User", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""),
        User(id: "4", firstname: "Test4", lastname: "Testmann4", mail: "test@testmann.com", released: true, role: UserRole(id: 0, name: "User", description: "User", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""),
        User(id: "5", firstname: "Test5", lastname: "Testmann5", mail: "test@testmann.com", released: true, role: UserRole(id: 0, name: "User", description: "User", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""),
        User(id: "6", firstname: "Test6", lastname: "Testmann6", mail: "test@testmann.com", released: true, role: UserRole(id: 0, name: "User", description: "User", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""),
        User(id: "7", firstname: "Test7", lastname: "Testmann7", mail: "test@testmann.com", released: true, role: UserRole(id: 0, name: "User", description: "User", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")
    ]
    
    var body: some View {
        VStack {
            HStack {
                Text("Feed")
                    .font(.title)
            }
            .padding()
            StackCardView(users: $users, swipeState: $swipeState, appData: $appData, showActionButtons: appData.appSettings.showFeedActionButtons ?? false, onSwipeLeft: { user in
                onDislike(user)
            }, onSwipeRight: { user in
                onLike(user)
            }, onClick: { user in
                onClick(user)
            })
            .padding()
        }
        .navigationDestination(isPresented: $showDetailView) {
            Text(naviUser?.firstname ?? "No User")
        }
    }
    
    func onClick(_ user: User) {
        naviUser = user
        showDetailView.toggle()
    }
    
    func onLike(_ user: User) {
        print("Swiped right")
    }
    
    func onDislike(_ user: User) {
        print("Swiped left")
    }
}

struct StackCardView: View {
    @Binding var users: [User]
    @Binding var swipeState: SwipeState
    @Binding var appData: AppData
    @State private var removalTransition: AnyTransitionState = .trailingBottom
    private let dragThreshold: CGFloat = 80.0
    @GestureState private var dragState: DragState = .inactive
    @State private var lastIndex: Int = 1
    @State var cardViews: [CardView] = []
    @State var showActionButtons: Bool
    
    var onSwipeLeft: (_ user: User) -> Void
    var onSwipeRight: (_ user: User) -> Void
    var onClick: (_ user: User) -> Void
    
    var removalAnyTransition: AnyTransition {
        if removalTransition == .leadingBottom {
            return .middleBottom
        } else {
            return .middleBottom
        }
    }

    init(users: Binding<[User]>, swipeState: Binding<SwipeState>, appData: Binding<AppData>, showActionButtons: Bool,
         onSwipeLeft: @escaping (_ user: User) -> Void,
         onSwipeRight: @escaping (_ user: User) -> Void,
         onClick: @escaping (_ user: User) -> Void) {
        self._users = users
        self._swipeState = swipeState
        self._appData = appData
        self.showActionButtons = showActionButtons
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
        self.onClick = onClick
        _cardViews = State(initialValue: {
            var views = [CardView]()
            for index in 0..<2 {
                views.append(CardView(user: users.wrappedValue[index]))
            }
            return views
        }())
    }
    
    enum AnyTransitionState {
        case leadingBottom
        case trailingBottom
    }
    
    enum DragState {
        case inactive
        case pressing
        case dragging(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }
        
        var isDragging: Bool {
            switch self {
            case .dragging:
                return true
            case .pressing, .inactive:
                return false
            }
        }
        
        var isPressing: Bool {
            switch self {
            case .pressing, .dragging:
                return true
            case .inactive:
                return false
            }
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(cardViews) { cardView in
                    cardView
                        .onTapGesture {
                            onClick(cardView.user)
                        }
                    .zIndex(self.isTopCard(cardView: cardView) ? 1 : 0)
                    .overlay(
                        ZStack {
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .cornerRadius(20)
                                .opacity(self.dragState.translation.width < -self.dragThreshold && self.isTopCard(cardView: cardView) ? 1.0 : 0)
                            Image(systemName: "xmark")
                                .foregroundStyle(.red)
                                .font(.system(size: 100))
                                .opacity(self.dragState.translation.width < -self.dragThreshold && self.isTopCard(cardView: cardView) ? 1.0 : 0)
                            
                            
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .cornerRadius(20)
                                .opacity(self.dragState.translation.width > self.dragThreshold && self.isTopCard(cardView: cardView) ? 1.0 : 0)
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.green)
                                .font(.system(size: 100))
                                .opacity(self.dragState.translation.width > self.dragThreshold && self.isTopCard(cardView: cardView) ? 1.0 : 0)
                        }
                    )
                    .offset(x: self.isTopCard(cardView: cardView) ? self.dragState.translation.width : 0, y: self.isTopCard(cardView: cardView) ? self.dragState.translation.height : 0)
                    .scaleEffect(self.dragState.isDragging && self.isTopCard(cardView: cardView) ? 0.95 : 1.0)
                    .rotationEffect(Angle(degrees: self.isTopCard(cardView: cardView) ? Double(self.dragState.translation.width / 10) : 0))
                    .animation(Animation.interpolatingSpring(stiffness: 180, damping: 100))
                    .transition(removalAnyTransition)
                    .gesture(LongPressGesture(minimumDuration: 0.01)
                        .sequenced(before: DragGesture())
                        .updating(self.$dragState, body: { (value, state, transaction) in
                            switch value {
                            case .first(true):
                                state = .pressing
                            case .second(true, let drag):
                                state = .dragging(translation: drag?.translation ?? .zero)
                            default:
                                break
                            }
                        })
                            .onChanged({ (value) in
                                guard case .second(true, let drag?) = value else {
                                    return
                                }
                                if drag.translation.width < -self.dragThreshold {
                                    self.removalTransition = .leadingBottom
                                    swipeState = .left
                                } else if drag.translation.width > self.dragThreshold {
                                    self.removalTransition = .trailingBottom
                                    swipeState = .right
                                } else {
                                    swipeState = .non
                                }
                            })
                                .onEnded({ (value) in
                                    guard case .second(true, let drag?) = value else {
                                        return
                                    }
                                    if drag.translation.width < -self.dragThreshold || drag.translation.width > self.dragThreshold {
                                        self.moveCard()
                                    }
                                    if drag.translation.width < -self.dragThreshold {
                                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                        onSwipeLeft(cardView.user)
                                        swipeState = .non
                                    } else if drag.translation.width > self.dragThreshold {
                                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                        onSwipeRight(cardView.user)
                                        swipeState = .non
                                    } else {
                                        
                                    }
                                })
                    )
                }
                .onChange(of: swipeState) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
        }
        if $appData.appSettings.showFeedActionButtons.wrappedValue ?? false {
            HStack {
                ActionButtonView(label: .dislike, swipeState: $swipeState) {
                    removalTransition = .leadingBottom
                    self.moveCard()
                }
                ActionButtonView(label: .like, swipeState: $swipeState) {
                    removalTransition = .trailingBottom
                    self.moveCard()
                }
            }
            .padding()
            .frame(height: 100)
        }
    }
    
    private func isTopCard(cardView: CardView) -> Bool {
        guard let index = cardViews.firstIndex(where: { $0.id == cardView.id }) else {
            return false
        }
        return index == 0
    }
    
    public func moveCard() {
        cardViews.removeFirst()
        
        self.lastIndex += 1
        @State var user = users[lastIndex % users.count]
        
        let newCardView = CardView(user: user)
        cardViews.append(newCardView)
    }
}

struct CardView: View, Identifiable {
    @State var user: User
    
    let id = UUID()
    
    var body: some View {
        Image("userIcon")
        .resizable()
        .scaledToFill()
        .frame(minWidth: 0, maxWidth: .infinity)
        .cornerRadius(20)
        .overlay(
            VStack {
                Text(user.firstname)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(.background)
                    .cornerRadius(12)
                    .shadow(radius: 10)
        }
        .padding([.bottom], 20)
            , alignment: .bottom)
    }
}

struct ActionButtonView: View {
    enum ActionButtonLabel {
        case dislike
        case details
        case like
    }
    
    let label: ActionButtonLabel
    @Binding var swipeState: SwipeState
    
    var action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                if label == .dislike {
                    if swipeState == .left {
                        Rectangle()
                            .cornerRadius(15)
                            .foregroundStyle(.red)
                        Image(systemName: "xmark")
                            .font(.largeTitle)
                    } else {
                        Rectangle()
                            .cornerRadius(15)
                            .foregroundStyle(.fill)
                        Image(systemName: "xmark")
                            .font(.largeTitle)
                            .foregroundStyle(.red)
                    }
                } else if label == .details {
                    Rectangle()
                        .cornerRadius(15)
                        .foregroundStyle(.fill)
                    Image(systemName: "info")
                        .font(.largeTitle)
                        .foregroundStyle(.primary)
                } else {
                    if swipeState == .right {
                        Rectangle()
                            .cornerRadius(15)
                            .foregroundStyle(.green)
                        Image(systemName: "heart.fill")
                            .font(.largeTitle)
                    } else {
                        Rectangle()
                            .cornerRadius(15)
                            .foregroundStyle(.fill)
                        Image(systemName: "heart.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        FeedView(httpModule: .constant(HTTPModule(settings: .constant(AppData(apiURL: "", dataURL: "https://images.skilllinkr.micstudios.de", appSettings: AppSettings(), cache: AppCache())), appDataModule: AppDataModule(appData: .constant(AppData(apiURL: "", dataURL: "https://images.skilllinkr.micstudios.de", appSettings: AppSettings(), cache: AppCache()))))), appData: .constant(AppData(apiURL: "", dataURL: "https://images.skilllinkr.micstudios.de", user: User(id: "", firstname: "Thorsten", lastname: "Schmidt", mail: "", released: true, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""), appSettings: AppSettings(), cache: AppCache())))
    }
}

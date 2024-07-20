//
//  FeedView.swift
//  SkillLinkr
//
//  Created by Christian on 15.07.24.
//

import Foundation
import SwiftUI

struct FeedView: View {
    @Binding var httpModule: HTTPModule
    @Binding var settings: AppSettings
    var body: some View {
        StackCardView(httpModule: $httpModule, settings: $settings)
    }
}

struct StackCardView: View {
    @Binding var httpModule: HTTPModule
    @Binding var settings: AppSettings
    @State var users: [User] = [
        User(id: "1", firstname: "Test1", lastname: "Testmann1", mail: "test@testmann.com", released: true, role: UserRole(id: 0, name: "User", description: "User", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""),
        User(id: "2", firstname: "Test2", lastname: "Testmann2", mail: "test@testmann.com", released: true, role: UserRole(id: 0, name: "User", description: "User", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""),
        User(id: "3", firstname: "Test3", lastname: "Testmann3", mail: "test@testmann.com", released: true, role: UserRole(id: 0, name: "User", description: "User", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""),
        User(id: "4", firstname: "Test4", lastname: "Testmann4", mail: "test@testmann.com", released: true, role: UserRole(id: 0, name: "User", description: "User", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""),
        User(id: "5", firstname: "Test5", lastname: "Testmann5", mail: "test@testmann.com", released: true, role: UserRole(id: 0, name: "User", description: "User", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""),
        User(id: "6", firstname: "Test6", lastname: "Testmann6", mail: "test@testmann.com", released: true, role: UserRole(id: 0, name: "User", description: "User", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""),
        User(id: "7", firstname: "Test7", lastname: "Testmann7", mail: "test@testmann.com", released: true, role: UserRole(id: 0, name: "User", description: "User", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")
    ]
    
    @State private var removalTransition: AnyTransition = .trailingBottom
    
    private let dragThreshold: CGFloat = 80.0
    
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
    
    @GestureState private var dragState: DragState = .inactive
    
    
    @State private var lastIndex: Int = 1
    
    @State var cardViews: [CardView] = {
        
        var views = [CardView]()
        
        for index in 0..<2 {
            views.append(CardView(title: "users[index].firstname", image: "Icon"))
        }
        
        return views
    }()
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(cardViews) { cardView in
                    cardView
                        .zIndex(self.isTopCard(cardView: cardView) ? 1 : 0)
                    .overlay(
                        ZStack {
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .cornerRadius(20)
                                .opacity(self.dragState.translation.width < -self.dragThreshold && self.isTopCard(cardView: cardView) ? 1.0 : 0)
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                                .font(.system(size: 100))
                                .opacity(self.dragState.translation.width < -self.dragThreshold && self.isTopCard(cardView: cardView) ? 1.0 : 0)
                                .onAppear {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                }
                            
                            
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .cornerRadius(20)
                                .opacity(self.dragState.translation.width > self.dragThreshold && self.isTopCard(cardView: cardView) ? 1.0 : 0)
                            Image(systemName: "heart.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 100))
                                .opacity(self.dragState.translation.width > self.dragThreshold && self.isTopCard(cardView: cardView) ? 1.0 : 0)
                                .onAppear {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                }
                        }
                    )
                        
                        
                        .offset(x: self.isTopCard(cardView: cardView) ? self.dragState.translation.width : 0, y: self.isTopCard(cardView: cardView) ? self.dragState.translation.height : 0)
                        .scaleEffect(self.dragState.isDragging && self.isTopCard(cardView: cardView) ? 0.95 : 1.0)
                        .rotationEffect(Angle(degrees: self.isTopCard(cardView: cardView) ? Double(self.dragState.translation.width / 10) : 0))
                        .animation(Animation.interpolatingSpring(stiffness: 180, damping: 100))
                        .transition(self.removalTransition)
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
                                }
                                
                                if drag.translation.width > self.dragThreshold {
                                    self.removalTransition = .trailingBottom
                                }
                            })
                            
                            .onEnded({ (value) in
                                guard case .second(true, let drag?) = value else {
                                    return
                                }
                                if drag.translation.width < -self.dragThreshold || drag.translation.width > self.dragThreshold {
                                    self.moveCard()
                                }
                            })
                    )
                }
            }
        }
    }
    
    private func isTopCard(cardView: CardView) -> Bool {
        guard let index = cardViews.firstIndex(where: { $0.id == cardView.id }) else {
            return false
        }
        return index == 0
    }
    
    private func moveCard() {
        cardViews.removeFirst()
        
        self.lastIndex += 1
        let user = users[lastIndex % users.count]
        
        let newCardView = CardView(title: user.firstname, image: user.lastname)
        
        cardViews.append(newCardView)
    }
}

struct CardView: View, Identifiable {
    
    let title: String
    let image: String
    
    let id = UUID()
    
    var body: some View {
        Image(image)
        .resizable()
        .scaledToFill()
        .frame(minWidth: 0, maxWidth: .infinity)
        .cornerRadius(20)
        .overlay(
            VStack {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(12)
        }
        .padding([.bottom], 20)
            , alignment: .bottom)
    }
}

extension AnyTransition {
    static var trailingBottom: AnyTransition {
        AnyTransition.asymmetric(insertion: .identity, removal: AnyTransition.move(edge: .trailing).combined(with: .move(edge: .bottom))
        )
    }
    
    static var leadingBottom: AnyTransition {
        AnyTransition.asymmetric(insertion: .identity, removal: AnyTransition.move(edge: .leading).combined(with: .move(edge: .bottom))
        )
    }
}

#Preview {
    FeedView(httpModule: .constant(HTTPModule(settings: .constant(AppSettings(apiURL: "https://skilllinkr.micstudios.de/api", userToken: "")), appDataModule: AppDataModule(settings: .constant(AppSettings(apiURL: "https://skilllinkr.micstudios.de/api", user: User(id: "", firstname: "", lastname: "", mail: "", released: false, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")))))), settings: .constant(AppSettings(apiURL: "https://skilllinkr.micstudios.de/api", user: User(id: "", firstname: "", lastname: "", mail: "", released: false, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""))))
}

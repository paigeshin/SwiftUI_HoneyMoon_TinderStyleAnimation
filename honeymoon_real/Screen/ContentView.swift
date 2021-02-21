//
//  ContentView.swift
//  honeymoon_real
//
//  Created by paigeshin on 2021/02/21.
//

import SwiftUI

struct ContentView: View {
    // MARK: - PROPERTIES
    
    @State var showAlert = false
    @State var showGuide = false
    @State var showInfo = false
    
    // MARK: - CARD VIEWS
    // Populate CardViews in Computed Property
    @State var cardViews: [CardView] = {
        var views = [CardView]()
        //가장 처음에는 2개의 카드만 가져오게 한다.
        for index in 0..<2 {
            views.append(CardView(honeymoon: destinationData[index]))
        }
        return views
    }()
    
    //last index를 계속 추적해준다.
    //맨 처음에는 2개의 카드만 rendering.
    //card swiping 하게 해주기
    @State private var lastCardIndex: Int = 1
    
    //card 제거시에 보여주는 transition
    @State private var cardRemovalTransition = AnyTransition.trailingBottom
    
    // MARK: - MOVE THE CARD
    
    //lastIndex를 하나 increment 해주고 새로운 CardView를 rendering 해준다.
    private func moveCards() {
        cardViews.removeFirst()
        self.lastCardIndex += 1
        let destination = destinationData[lastCardIndex % destinationData.count]
        let newCardView = CardView(honeymoon: destination)
        cardViews.append(newCardView)
    }
    
    // MARK: - TOP CARD
    private func isTopCard(cardView: CardView) -> Bool {
        guard let index = cardViews.firstIndex(where: { $0.id == cardView.id }) else { return false }
        return index == 0
    }
    
    // MARK: - DRAG STATES
    /*
     No Gesture happens => inactive state
     User taps on the screen => pressing state
     When the actual dragging gesture is happening => dragging
     */
    
    @GestureState private var dragState: DragState = DragState.inactive
    
    // X-MARK SYMBOL을 보여줄지 HEART SYMBOL을 보여줄지 정해주는 기준이다.
    // LEFT DRAG => X-MARK, RIGHT DRAG => HEART
    private let dragAreaThreshold: CGFloat = 65.0
    
    
    
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
            
            // MARK: - HEADER
            HeaderView(showGuideView: $showGuide, showInfoView: $showInfo)
                //when dragging is happening, this code will make HeaderView() disappear
                .opacity(dragState.isDragging ? 0.0 : 1.0)
                .animation(.default)
            
            Spacer()
            
            // MARK: - CARDS
            ZStack {
                ForEach(cardViews, id: \.id) { cardView in
                    
                    cardView
                        //index 0 의 카드를 가장 앞으로 가져오게 한다.
                        .zIndex(self.isTopCard(cardView: cardView) ? 1 : 0)
                        //overlay, show X-MARK SYMBOL and HEART SYMBOL when dragging
                        .overlay(
                            ZStack {
                                // X-MARK SYMBOL when dragging
                                Image(systemName: "x.circle")
                                    .modifier(SymbolModifier())
                                    // LEFT SWIPE SHOW X-MARK
                                    .opacity(self.dragState.translation.width < -self.dragAreaThreshold && self.isTopCard(cardView: cardView) ? 1.0 : 0.0)
                                
                                // HEART SYMBOL when dragging
                                Image(systemName: "heart.circle")
                                    .modifier(SymbolModifier())
                                    // RIGHT SWIPE SHOW HEART
                                    .opacity(self.dragState.translation.width > self.dragAreaThreshold && self.isTopCard(cardView: cardView) ? 1.0 : 0.0 )
                            }
                        )
                        //drag gesture, move position of card when dragging
                        //drag only top card
                        .offset(
                            x: self.isTopCard(cardView: cardView) ?  self.dragState.translation.width : 0,
                            y: self.isTopCard(cardView: cardView) ?  self.dragState.translation.height : 0
                        )
                        //animation, scale effect
                        //scale only top card
                        .scaleEffect(self.dragState.isDragging && self.isTopCard(cardView: cardView) ? 0.85 : 1.0)
                        //animation, rotation effect
                        //rotate only top card
                        .rotationEffect(Angle(degrees: self.isTopCard(cardView: cardView) ? Double(self.dragState.translation.width / 12) : 0))
                        //animation, smooth animation when dragging
                        .animation(.interpolatingSpring(stiffness: 120, damping: 120))
                        //attach gesture recognizer
                        .gesture(
                            LongPressGesture(minimumDuration: 0.01)
                                .sequenced(before: DragGesture())
                                .updating(self.$dragState, body: { (value, state, transiaction) in
                                    switch value {
                                    
                                    case .first(true):
                                        state = .pressing
                                        
                                    case .second(true, let drag):
                                        state = .dragging(translation: drag?.translation ?? .zero)
                                    default:
                                        break
                                    }
                                })
                                //transition
                                //카드가 움직일 때 어떤 transition을 정할지 threshold 값을 기준으로 정해준다.
                                .onChanged({ (value) in
                                    guard case .second(true, let drag?) = value else {
                                        return
                                    }
                                    
                                    if drag.translation.width < -self.dragAreaThreshold {
                                        self.cardRemovalTransition = .leadingBottom
                                    }
                                    
                                    if drag.translation.width > -self.dragAreaThreshold {
                                        self.cardRemovalTransition = .trailingBottom
                                    }
                                    
                                })
                                
                                //drag가 끝났을 때 event handling
                                .onEnded({ (value) in
                                    guard case .second(true, let drag?) = value else {
                                        return
                                    }
                                    
                                    //기준이 되는 thresholds 값을 지났을 때 다음 카드를 미리 rendering 한다.
                                    if drag.translation.width < -self.dragAreaThreshold || drag.translation.width > self.dragAreaThreshold {
//                                        playSound(sound: "sound-rise", type: "mp3")
                                        self.moveCards()
                                    }
                                    
                                })
                        )
                        //Attach transition to CardView
                        .transition(self.cardRemovalTransition)
                    
                    
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // MARK: - FOOTER
            FooterView(showBookingAlert: $showAlert)
                //when dragging is happening, this code will make HeaderView() disappear
                .opacity(dragState.isDragging ? 0.0 : 1.0)
        }
        .alert(isPresented: $showAlert, content: {
            Alert(
                title: Text("SUCCESS"),
                message: Text("Wishing a lovely and most precious of the times together for the amazing couple."),
                dismissButton: .default(Text("Happy Honeymoon!"))
            )
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 11 Pro")
    }
    
}

# Notion Link

[Honeymoon, @Binding, Tinder Style Swiping ](https://www.notion.so/Honeymoon-Binding-Tinder-Style-Swiping-6335f4cfd73345e0b33fd9aa32cadef3)

[HoneyMoon UILibrary](https://www.notion.so/HoneyMoon-UILibrary-6d8da0cd6c8a466588ee0827fed6de12)

# @Binding

- **The @Binding  property wrapper lets us declare a value in a view and share this value with another view.**
- When this value changes in one view then it will also change in the other view.

# Example 1

### Binding on View

```swift
//
//  FooterView.swift
//  honeymoon_real
//
//  Created by paigeshin on 2021/02/21.
//

import SwiftUI

struct FooterView: View {
    // MARK: - PROPERTIES
    @Binding var showBookingAlert: Bool //Footer button click event를 다른 view에서 사용할 때 쓴다. 
    
    var body: some View {
        HStack {
            Image(systemName: "xmark.circle")
                .font(.system(size: 42, weight: .light))
            
            Spacer()
            
            Button(action: {
                // ACTION
                // print("Success")
                self.showBookingAlert.toggle()
            }, label: {
                Text("Book Destination".uppercased())
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.heavy)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .accentColor(Color.pink)
                    .background(
                        Capsule().stroke(Color.pink, lineWidth: 2)
                    )
            })
            
            Spacer()
            
            Image(systemName: "heart.circle")
                .font(.system(size: 42, weight: .light))
            
        }
        .padding()
    }
}

struct FooterView_Previews: PreviewProvider {
    
    @State static var showAlert: Bool = false
    
    static var previews: some View {
        FooterView(showBookingAlert: $showAlert)
            .previewLayout(.fixed(width: 375, height: 80))
    }
}
```

### Binding on another view

```swift
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
    
    var body: some View {
        VStack {
            HeaderView()
            
            Spacer()
            
            CardView(honeymoon: destinationData[3])
            //FIXME: Add padding to the cards later on.
                .padding()
                
            Spacer()
            
            FooterView(showBookingAlert: $showAlert)
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
```

# Example 2

### Binding on View

```swift
//
//  HeaderView.swift
//  honeymoon_real
//
//  Created by paigeshin on 2021/02/21.
//

import SwiftUI

struct HeaderView: View {
    // MARK: - PROPERTIES
    @Binding var showGuideView: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                // ACTION
                print("Information")
            }, label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 24, weight: .regular))
            })
            .accentColor(Color.primary)
            
            Spacer()
            
            Image("logo-honeymoon-pink")
                .resizable()
                .scaledToFit()
                .frame(height: 28)
            
            Spacer()
            
            Button(action: {
                // ACTION
                // print("Guide")
                showGuideView.toggle()
            }, label: {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 24, weight: .regular))
            })
            .accentColor(Color.primary)
            .sheet(isPresented: $showGuideView, content: {
                GuideView()
            })
            
        }
        .padding()
    }
}

struct HeaderView_Previews: PreviewProvider {
    
    @State static var showGuide: Bool = false
    
    static var previews: some View {
        HeaderView(showGuideView: $showGuide)
            .previewLayout(.fixed(width: 375, height: 80))
    }
}
```

```swift
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
    
    var body: some View {
        VStack {
            HeaderView(showGuideView: $showGuide)
            
            Spacer()
            
            CardView(honeymoon: destinationData[3])
            //FIXME: Add padding to the cards later on.
                .padding()
                
            Spacer()
            
            FooterView(showBookingAlert: $showAlert)
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
```

# Create Tinder Style Card Swiping

### Logic

1. **Coding Challenge**
- index 0의 카드를 가장 앞으로 가져오게 한다.
- We need to change the order of the cards. The first card should be on the top of the deck.

**ℹ️ Solution**

⇒ The `zIndex` SwiftUI Modifier indicates the order of the views in a ZStack.

**2.  Coding Challenge**

- 처음에는 두 개의 cardView만 rendering 한다
- Displaying a bunch of cards at the smae time is resource-intensive. We should render only 2 cards.

**ℹ️ Solution**

⇒ We need to initialize only the first 2 cards at the same time. Let's modify the `for index` to do it. 

### Gesture Recognizer

- Gesture Recognizer

```swift
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
```

- Extension

⇒ Asymmetric Transition 

```swift
//
//  CardTransition.swift
//  honeymoon_real
//
//  Created by paigeshin on 2021/02/21.
//

import SwiftUI

extension AnyTransition {
    static var trailingBottom: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .identity,
            removal: AnyTransition.move(edge: .trailing).combined(with: .move(edge: .bottom))
        )
    }
    
    static var leadingBottom: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .identity,
            removal: AnyTransition.move(edge: .leading).combined(with: .move(edge: .bottom))
        )
    }
}
```

- audio player

```swift
//
//  PlaySound.swift
//  honeymoon_real
//
//  Created by paigeshin on 2021/02/21.
//

import AVFoundation

var audioPlayer: AVAudioPlayer?

func playSound(sound: String, type: String) {
    if let path = Bundle.main.path(forResource: sound, ofType: type) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.play()
        } catch {
            print("ERROR: Could not find and play the sound file!")
        }
    }
}
```
//
//  ContentView.swift
//  IsometricAnimation
//
//  Created by 伊藤璃乃 on 2025/01/24.
//
import SwiftUI

struct Home: View {
    @State var animate: Bool = false
    @State var b: CGFloat = 0
    @State var c: CGFloat = 0
    var body: some View {
        VStack(spacing: 20) {
            IsometricView(depth: animate ? 35 : 0) { //本の厚さ変えれる
                ImageView()
            } bottom: {
                ImageView()
            } side: {
                ImageView()
            }
            .frame(width: 180, height: 330)
            .modifier(CustomProjection(b: b, c: c))
            .rotation3DEffect(.init(degrees: animate ? 45 : 0), axis: (x: 0, y: 0, z: 1))
            .scaleEffect(0.75)
            .offset(x: animate ? 12 : 0)

            VStack(alignment: .leading, spacing: 25) {
                Text("Isometric Transform's")
                    .font(.title.bold())
                HStack {
                    Button("Animate"){
                        withAnimation(.easeInOut(duration: 2.5)) {
                            animate = true
                            b = -0.2
                            c = -0.3
                        }
                    }
                        .buttonStyle(.bordered)
                        .tint(Color.blue)
                    Button("Reset"){
                        withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.5, blendDuration: 0.5)) {
                            animate = false
                            b = 0
                            c = 0
                        }
                    }
                        .buttonStyle(.bordered)
                        .tint(Color.blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 15)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    func ImageView() -> some View {
        Image("BG")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 180, height: 330)
            .clipped()
    }
}

struct CustomProjection: GeometryEffect {
    func effectValue(size: CGSize) -> ProjectionTransform {
        return .init(.init(a: 1, b: b, c: c, d: 1, tx: 0, ty: 0))
    }
    
    var b: CGFloat
    var c: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get {
            return AnimatablePair(b, c)
        }
        set {
            b = newValue.first
            c = newValue.second
        }
    }
}


struct IsometricView<Content: View, Bottom: View, Side: View>: View {
    var content: Content
    var bottom: Bottom
    var side: Side
    var depth: CGFloat

    init(depth: CGFloat,@ViewBuilder content: @escaping()->Content, @ViewBuilder bottom: @escaping()->Bottom, @ViewBuilder side: @escaping()->Side) {
        self.depth = depth
        self.content = content()
        self.bottom = bottom()
        self.side = side()
    }
    var body: some View {
        Color.clear
            .overlay {
                GeometryReader {
                    let size = $0.size

                    ZStack {
                        content
                        DepthView(isBottom: true, size: size)
                        DepthView(size: size)
                    }
                    .frame(width: size.width, height: size.height)
                }
            }
    }

    @ViewBuilder
    func DepthView(isBottom: Bool = false, size: CGSize) -> some View {
        ZStack {
            if isBottom {
                bottom
                    .scaleEffect(y: depth, anchor: .bottom)
                    .frame(height: depth, alignment: .bottom)
                    .overlay(content: {
                        Rectangle()
                            .fill(Color.black.opacity(0.25))
                            .blur(radius: 2.5)
                    })

                    .clipped()
                    .projectionEffect(.init(.init(a: 1, b: 0, c: 1, d: 1, tx: 0, ty: 0)))
                    .offset(y: depth)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            } else {
                side
                    .scaleEffect(x: depth, anchor: .trailing)
                    .frame(width: depth, alignment: .trailing)
                    .overlay(content: {
                        Rectangle()
                            .fill(Color.black.opacity(0.25))
                            .blur(radius: 2.5)
                    })

                    .clipped()
                    .projectionEffect(.init(.init(a: 1, b: 1, c: 0, d: 1, tx: 0, ty: 0)))
                    .offset(x: depth)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

#Preview {
    Home()
}

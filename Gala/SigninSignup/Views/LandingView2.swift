//
//  LandingView2.swift
//  Gala
//
//  Created by Vaughn on 2021-08-14.
//

import SwiftUI

struct LandingView: View {
    @State var opacity: Double = 0
    @State var opacity2: Double = 1
    @AppStorage("isDarkMode") private var isDarkMode = true
    var body: some View {
        ZStack{
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                galaThreeHStack(opacity: $opacity, opacity2: $opacity2)
                Spacer()
                galaThreeHStackInverse(opacity: $opacity, opacity2: $opacity2)
                Spacer()
                galaThreeHStack(opacity: $opacity, opacity2: $opacity2)
                Spacer()
                galaThreeHStackInverse(opacity: $opacity, opacity2: $opacity2)
                Spacer()
                galaThreeHStack(opacity: $opacity, opacity2: $opacity2)
            }

            RoundedRectangle(cornerRadius: 40).stroke(lineWidth: 5)
                .foregroundColor(.pink)
                .frame(width: screenWidth - 1, height: screenHeight - 1)
                .edgesIgnoringSafeArea(.all)
            
            RoundedRectangle(cornerRadius: 23).stroke(lineWidth: 5)
                .foregroundColor(.pink)
                .frame(width: screenWidth * 0.56, height: screenHeight * 0.062)
                .offset(y: -screenHeight / 2)
            
            VStack {
                Button(action: {
                    withAnimation {
                        AppState.shared.onLandingPage = false
                        AppState.shared.signUpPageActive = true
                    }
                }){
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .edgesIgnoringSafeArea(.all)
                        
                        RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 3)
                            .foregroundColor(.blue)
                            .edgesIgnoringSafeArea(.all)
                        
                        HStack {
                            Spacer()
                            Image(systemName: "newspaper")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.pink)
                            
                            Text("Sign up")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                }
                .frame(width: screenWidth * 0.6, height: screenHeight * 0.1)
                .foregroundColor(.black)
                .padding(.bottom)
                
                Button(action: {
                    withAnimation {
                        AppState.shared.onLandingPage = false
                        AppState.shared.loginPageActive = true
                    }
                }){
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .edgesIgnoringSafeArea(.all)
                        
                        RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 3)
                            .foregroundColor(.blue)
                            .edgesIgnoringSafeArea(.all)
                        
                        HStack {
                            Spacer()
                            Image(systemName: "lock")
                                .font(.system(size: 25, weight: .bold, design: .rounded))
                                .foregroundColor(.pink)
                            
                            Text("Log in")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                }
                .frame(width: screenWidth * 0.6, height: screenHeight * 0.1)
                .foregroundColor(.black)
            }
            .offset(y: screenHeight * 0.33)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct LandingView2_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}

struct FlashingGala: View {
    @Binding var opacity: Double
    var body: some View {
        Text("Gala")
            .font(.system(size: 30, weight: .black, design: .rounded))
            .frame(width: 90, height: 40)
            .foregroundColor(.pink)
            .opacity(opacity)
            .animation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true))
            .onAppear{
                opacity = 1
            }
    }
}

struct FlashingGalaInverse: View {
    @Binding var opacity: Double
    var body: some View {
        Text("Gala")
            .font(.system(size: 30, weight: .black, design: .rounded))
            .frame(width: 90, height: 40)
            .foregroundColor(.pink)
            .opacity(opacity)
            .animation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true))
            .onAppear{
                opacity = 0
            }
    }
}

struct galaThreeHStack: View {
    @Binding var opacity: Double
    @Binding var opacity2: Double
    @State var posX = 0
    
    var body: some View {
        HStack {
            FlashingGala(opacity: $opacity)
            Spacer()
            FlashingGalaInverse(opacity: $opacity2)
            Spacer()
            FlashingGala(opacity: $opacity)
            Spacer()
            FlashingGalaInverse(opacity: $opacity2)
        }
        .frame(width: screenWidth * 1.2)
        .offset(x: CGFloat(posX))
        .animation(Animation.easeInOut(duration: 5).repeatForever(autoreverses: true))
        .onAppear{
            posX += 140
        }
    }
}

struct galaThreeHStackInverse: View {
    @Binding var opacity: Double
    @Binding var opacity2: Double
    @State var posX = 0
    
    var body: some View {
        HStack {
            FlashingGalaInverse(opacity: $opacity2)
            Spacer()
            FlashingGala(opacity: $opacity)
            Spacer()
            FlashingGalaInverse(opacity: $opacity2)
            Spacer()
            FlashingGala(opacity: $opacity)
        }
        .frame(width: screenWidth * 1.2)
        .offset(x: CGFloat(posX))
        .animation(Animation.easeInOut(duration: 5).repeatForever(autoreverses: true))
        .onAppear{
            posX -= 140
        }
    }
}

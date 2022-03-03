//
//  TestSnapchatExpand.swift
//  Gala
//
//  Created by Vaughn on 2022-01-27.
//

import SwiftUI

struct VibesPlaceHolder: View {
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 2)
    
    @ObservedObject var viewModel: StoriesViewModel
    
    @State var showVibe = false
    @State var selectedVibe: VibeCoverImage = VibeCoverImage(image: UIImage(), title: "")
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: "dot.radiowaves.up.forward")
                        .rotationEffect(.degrees(-90))
                        .foregroundColor(.primary)
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                    
                    Text("Vibes")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                    Spacer()
                }
                
                if viewModel.vibeImages.count == 0 {
                    VStack {
                        Spacer()
                        LoadingView()
                    }.frame(height: screenHeight * 0.25)
                }
                
                LazyVGrid(columns: columns, content: {

                    ForEach(viewModel.vibeImages) { vibe in
                        Button(action: {
                            self.selectedVibe = vibe
                            showVibe = true
                        }){
                            ZStack {
                                Image(uiImage: vibe.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: (screenWidth * 0.95) * 0.48, height: (screenWidth * 0.95) * 0.48)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))

                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(lineWidth: 4)
                                    .foregroundColor(.buttonPrimary)
                                    .edgesIgnoringSafeArea(.all)

                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Text(vibe.title)
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.trailing)
                                            .padding(.vertical, 10)
                                    }
                                    .border(Color.buttonPrimary)
                                    .background(Color.white.opacity(0.15))
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        .frame(width: (screenWidth * 0.95) * 0.48, height: (screenWidth * 0.95) * 0.48)
                    }
                })
            }
            .frame(width: screenWidth * 0.95)
        }
        .fullScreenCover(isPresented: $showVibe, content: {
            StoryListView(show: $showVibe, vibe: $selectedVibe, stories: viewModel.vibesDict)
        })
    }
}

struct ColorStruct: Identifiable {
    let id = UUID()
    var color: Color?
}

struct VibeCover: View {
    @Binding var vibe: VibeCoverImage
    @Binding var selectedVibe: VibeCoverImage
    
    @Binding var scale: CGFloat
    @Binding var showVibe: Bool
    
    var animation: Namespace.ID
    
    var body: some View {
        ZStack {
            Image(uiImage: vibe.image)
                .resizable()
                .scaledToFill()
                //.frame(width: (screenWidth * 0.95) * 0.48, height: (screenWidth * 0.95) * 0.48)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 4)
                .foregroundColor(.buttonPrimary)
                .edgesIgnoringSafeArea(.all)
        }
        .matchedGeometryEffect(id: vibe.id, in: animation)
        .scaleEffect(showVibe && selectedVibe.id == vibe.id ? scale : 1)
        .frame(width: (screenWidth * 0.95) * 0.48, height: (screenWidth * 0.95) * 0.48)
        .opacity(showVibe && selectedVibe.id == vibe.id ? 0 : 1)
        .onTapGesture {
            withAnimation {
                self.showVibe = true
                self.selectedVibe = vibe
            }
        }
    }
}

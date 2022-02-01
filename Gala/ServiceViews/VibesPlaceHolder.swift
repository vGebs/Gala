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
    
    @Binding var showVibe: Bool
    @Binding var offset: CGSize
    @Binding var scale: CGFloat
    
    @Binding var selectedVibe: ImageHolder
    
    var animation: Namespace.ID
    
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
                    Button(action: {
                        let count = viewModel.vibesDict.count
                        viewModel.fetchVibeImages(count: count)
                    }) {
                        Text("Fetch")
                            .foregroundColor(.buttonPrimary)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                    }
                }
                
                LazyVGrid(columns: columns, content: {
                    ForEach(viewModel.vibeImages) { vibe in
                        //VibeCover(vibe: vibe, selectedVibe: $selectedVibe, scale: $scale, showVibe: $showVibe, animation: animation)
                        
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
                })
                
            }
            .frame(width: screenWidth * 0.95)
        }
    }
}

struct ColorStruct: Identifiable {
    let id = UUID()
    var color: Color?
}

struct VibeCover: View {
    @Binding var vibe: ImageHolder
    @Binding var selectedVibe: ImageHolder
    
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

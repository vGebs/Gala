//
//  SendVieww.swift
//  Gala
//
//  Created by Vaughn on 2021-09-22.
//

import SwiftUI

struct SendView: View {
    @Binding var isPresented: Bool
    @ObservedObject var camera: CameraViewModel
    @ObservedObject var viewModel: SendViewModel
    
    //@State var selected: String = ""
    var body: some View {
        ZStack{
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                RoundedRectangle(cornerRadius: 2)
                    .foregroundColor(.accent)
                    .frame(width: screenWidth / 4, height: screenHeight / 400)
                    .padding()
                
                ScrollView(showsIndicators: false) {
                    VStack{
                        HStack{
                            Text("Post to Currated List")
                                .foregroundColor(.white)
                                .font(.system(size: 25, weight: .bold, design: .rounded))
                            Spacer()
                        }
                        .padding(.top, 3)
                        .frame(width: screenWidth * 0.9)
                        
                        ForEach(0..<viewModel.vibes.count, id: \.self){ i in
                            PostSelector(selected: viewModel.selected, text: viewModel.vibes[i])
                                .frame(width: screenWidth * 0.9)
                                .onTapGesture {
                                    if viewModel.selected == viewModel.vibes[i] {
                                        viewModel.selected = ""
                                    } else {
                                        viewModel.selected = viewModel.vibes[i]
                                    }
                                }
                        }
                        if camera.image != nil {
                            Image(uiImage: camera.image!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: screenWidth / 5, height: screenWidth / 3)
                        }
                        
                        
                        Spacer()
                    }
                    .padding()
                }
                .frame(width: screenWidth)
            }
            .frame(width: screenWidth)
            
            VStack{
                Spacer()
                Button(action: {
                    self.viewModel.postStory(pic: camera.image!)
                    self.camera.retakePic()
                    self.viewModel.selected = ""
                    self.isPresented = false
                }){
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.black)
                        
                        RoundedRectangle(cornerRadius: 10).stroke()
                            .foregroundColor(.buttonPrimary)
                        
                        HStack {
                            Text("Post")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Image(systemName: "paperplane")
                                .font(.system(size: 20, weight: .regular, design: .rounded))
                                .foregroundColor(.primary)
                        }
                    }
                    .frame(width: screenWidth * 0.9, height: screenHeight * 0.05)
                }
                .disabled(viewModel.selected == "")
                .opacity(viewModel.selected != "" ? 1 : 0.4)
            }
        }
    }
}
//
//struct SendVieww_Previews: PreviewProvider {
//    static var previews: some View {
//        SendView()
//    }
//}


//struct SendViewClick: View {
//    @State var clicked = false
//    var body: some View {
//        VStack {
//            Button(action: { self.clicked = true }) {
//                Text("Click me")
//            }
//        }
//        .sheet(isPresented: $clicked) {
//            SendView()
//        }
//    }
//}

//
//  SendView.swift
//  Gala
//
//  Created by Vaughn on 2021-09-09.
//

import SwiftUI

struct SendView: View {
    @Binding var sendPressed: Bool
    @StateObject var viewModel: SendViewModel = SendViewModel()
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.top)
            VStack {
                Button(action: { sendPressed.toggle() }){
                    Text("back")
                }
                .padding()
                
                Button(action: { viewModel.postStory() }){
                    Text("Post")
                }
                .padding()
                
                Button(action: { viewModel.getMyStories() }){
                    Text("Get my stories")
                }
                .padding()
                
            }
        }
    }
}

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView(sendPressed: .constant(true))
    }
}

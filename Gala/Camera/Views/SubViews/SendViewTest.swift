//
//  SendView.swift
//  Gala
//
//  Created by Vaughn on 2021-09-09.
//

import SwiftUI

struct SendViewTest: View {
    @Binding var sendPressed: Bool
    @StateObject var viewModel: SendViewModelTest = SendViewModelTest()
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
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
                
                Button(action: { viewModel.deleteStory() }){
                    Text("Delete first story")
                }
                .padding()
                
                Button(action: { viewModel.getTimeOfDay() }){
                    Text("Get time of day")
                }
                .padding()
            }
        }
    }
}

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendViewTest(sendPressed: .constant(true))
    }
}

//
//  ExploreView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct ExploreView: View {
    @State var viewed = false
    var body: some View {
        VStack {
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.orange)
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.offWhite)
                        .frame(width: screenWidth, height: screenHeight * 0.81) //0.81
                        .shadow(radius: 10)
                }
                
                VStack{
                    Spacer()
                    ScrollView(showsIndicators: false){
                        VStack {
                            HStack {
                                Text("Matches")
                                    .foregroundColor(.black)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    
                                Spacer()
                                
                                Button(action: {  }) {
                                    AddMomentButtonView(text: .myMoment)
                                        .padding(.trailing, 7)
                                }
                            }
                            .padding(.top)
                            .padding(.leading)
                            
                            ScrollView(.horizontal, showsIndicators: false){
                                HStack {
                                    MatchesMomentView(viewed: $viewed)
                                    MatchesMomentView(viewed: $viewed)
                                    MatchesMomentView(viewed: $viewed)
                                    MatchesMomentView(viewed: $viewed)
                                    MatchesMomentView(viewed: $viewed)
                                    MatchesMomentView(viewed: $viewed)
                                    MatchesMomentView(viewed: $viewed)
                                }
                                .padding(.leading)
                                .padding(.top, 5)
                            }
                            .offset(y: -screenHeight * 0.01)
                            
                            
                            HStack{
                                Text("Showcase")
                                    .foregroundColor(.black)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                
                                Spacer()
                                
                                Button(action: {  }) {
                                    AddMomentButtonView(text: .myShowcase)
                                        .padding(.trailing, 7)
                                }
                            }
                            .padding(.leading)
                            
                            ScrollView(.horizontal, showsIndicators: false){
                                HStack{
                                    SpotlightPreviewView()
                                    SpotlightPreviewView()
                                    SpotlightPreviewView()
                                    SpotlightPreviewView()
                                    SpotlightPreviewView()
                                    SpotlightPreviewView()
                                    SpotlightPreviewView()
                                }
                                .offset(y: -screenHeight * 0.032)
                                .frame(height: screenHeight / 2.9 )
                                .padding(.leading)
                            }
                            .offset(y: -screenHeight * 0.01)
                            
                            HStack{
                                Text("Explore")
                                    .foregroundColor(.black)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                
                                Spacer()
                            }
                            .offset(y: -screenHeight * 0.045)
                            .padding(.leading)
                            
                            JigJagMomentStackView()
                                .offset(y: -screenWidth * 0.11)
                        }
                    }
                    .frame(width: screenWidth, height: screenHeight * 0.81)
                    .cornerRadius(20)
                }
                
                VStack {
                    HStack {
                        Button(action: { }) {
                            ProfilePreview()
//                            Image(systemName: "line.horizontal.3.decrease")
//                                .font(.system(size: 20, weight: .semibold, design: .rounded))
//                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text("Moments")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)

                        Spacer()
            //FIX ME:
                // shuffle/ reload new moments
                //NOTE: I think the array needs to be @Published to make ui changes
                        Button(action: { moments.shuffle() }) {
                            Image(systemName: "line.horizontal.3.decrease")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    Spacer()
                }
                .padding(.top, screenHeight * 0.0385)
            }
            .frame(width: screenWidth, height: screenHeight * 0.91)
            .edgesIgnoringSafeArea(.all)
            Spacer()
        }
    }
    
    func funcy(num: Int) -> Int{
        print("\(num+1)")
        return num + 1
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}

var moments = [
    Moment(imageString: "me", name: "0", age: "23", title: "Engineer"),
    Moment(imageString: "me", name: "1", age: "25", title: "job"),
    Moment(imageString: "me", name: "2", age: "27", title: "job1"),
    Moment(imageString: "me", name: "3", age: "23", title: "job2"),
    Moment(imageString: "me", name: "4", age: "29", title: "job3"),
    Moment(imageString: "me", name: "5", age: "21", title: "job4"),
    Moment(imageString: "me", name: "6", age: "22", title: "job5"),
    Moment(imageString: "me", name: "7", age: "23", title: "job6"),
    Moment(imageString: "me", name: "8", age: "29", title: "job3"),
    Moment(imageString: "me", name: "9", age: "30", title: "Engineer33"),
    Moment(imageString: "me", name: "10", age: "99", title: "Engineer"),
    Moment(imageString: "me", name: "11", age: "80", title: "job1"),
    Moment(imageString: "me", name: "12", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "13", age: "33", title: "job1"),
    Moment(imageString: "me", name: "14", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "15", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "16", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "17", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "18", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "19", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "20", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "21", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "22", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "23", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "24", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "25", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "26", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "27", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "28", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "29", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "30", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "31", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "32", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "33", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "34", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "35", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "36", age: "53", title: "Engineer4"),
    Moment(imageString: "me", name: "37", age: "53", title: "Engineer4")

]

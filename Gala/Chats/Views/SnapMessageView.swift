//
//  SnapMessageView.swift
//  Gala
//
//  Created by Vaughn on 2022-02-25.
//

import SwiftUI

struct SnapMessageView: View {
    var snap: Snap
    @State var showSnap: Bool = false
    @ObservedObject var chatsViewModel: ChatsViewModel
    var body: some View {
        Button(action: {
            chatsViewModel.getSnap(for: snap.fromID)
            showSnap = true
        }){
            ZStack {
                RoundedRectangle(cornerRadius: 5).stroke()
                    .foregroundColor(.buttonPrimary)
                
                HStack {
                    Text("New snap")
                        .foregroundColor(.accent)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .padding(.leading, 7)
                        .padding(.vertical, 7)
                    
                    Image(systemName: "circlebadge.fill")
                        .font(.system(size: 5, weight: .regular, design: .rounded))
                    
                    Text("\(secondsToHoursMinutesSeconds_(Int(snap.snapID_timestamp.timeIntervalSinceNow)))")
                        .foregroundColor(.accent)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    
                    Spacer()
                    
                    Image(systemName: snap.openedDate == nil ? "map.fill" : "map")
                        .foregroundColor(.primary)
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .padding(.trailing, 7)
                }
            }
            .padding(.trailing, screenWidth * 0.5)
        }
        .sheet(isPresented: $showSnap, content: {
            IndividualSnapView(snap: chatsViewModel.tempSnap!, showSnap: $showSnap, snapViewModel: chatsViewModel)
        })
    }
    
    func secondsToHoursMinutesSeconds_(_ seconds: Int) -> String { //(Int, Int, Int)
        
        //60 = 1 minute
        //3600 = 1 hour
        //86400 = 1 day
        //604800 = 1 week
        
        if abs(((seconds % 3600) / 60)) == 0 {
            let secondString = "\(abs((seconds % 3600) / 60))s"
            return secondString
        } else if abs((seconds / 3600)) == 0 {
            let minuteString = "\(abs((seconds % 3600) / 60))min"
            return minuteString
        } else if abs(seconds / 3600) < 24{
            let hourString = "\(abs(seconds / 3600))h"
            return hourString
        } else {
            let dayString = "\(abs(seconds / 86400))d"
            return dayString
        }
    }
}

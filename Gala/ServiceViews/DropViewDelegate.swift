//
//  DropViewDelegate.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI

struct DropViewDelegate: DropDelegate{
    var image: ImageModel
    var viewModel: ProfileViewModel
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        let fromIndex = viewModel.images.firstIndex { (image) -> Bool in
            return image.id == viewModel.currentImageDrag?.id
        } ?? 0
        
        let toIndex = viewModel.images.firstIndex { (image) -> Bool in
            return image.id == self.image.id
        } ?? 0
        
        if fromIndex != toIndex {
            withAnimation(.default) {
                //let fromIndex = viewModel.images[fromIndex].position
                let fromPage = viewModel.images[fromIndex]
                
                //viewModel.images[fromIndex].position = viewModel.images[toIndex].position
                viewModel.images[fromIndex] = viewModel.images[toIndex]
                
                //viewModel.images[toIndex].position = fromIndex
                viewModel.images[toIndex] = fromPage
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}

//MARK: - TEST

//import WebKit

    //Link for tutorial: https://kavsoft.dev/SwiftUI_2.0/Grid_Reordering/

//struct Home: View {
//    @StateObject var pageData = PageViewModel()
//    @Namespace var animation
//
//    let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 3)
//
//    var body: some View {
//        VStack{
//            ScrollView{
//                LazyVGrid(columns: columns, spacing: 20, content: {
//                    ForEach(pageData.urls) { page in
//                        WebView(url: page.url)
//                            .frame(height: 200)
//                            .cornerRadius(15)
//                            .onDrag({
//                                pageData.currentPage = page
//
//                                return NSItemProvider(contentsOf: URL(string: "\(page.id)")!)!
//                            })
//                            .onDrop(of: [.url], delegate: DropViewDelegate(page: page, pageData: pageData))
//                    }
//                }).padding()
//            }
//        }
//    }
//}
//
//struct WebView: UIViewRepresentable {
//    var url: URL
//
//    func makeUIView(context: Context) -> some WKWebView {
//        let view = WKWebView()
//        view.load(URLRequest(url: url))
//        view.isUserInteractionEnabled = false
//
//        view.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
//        return view
//    }
//
//    func updateUIView(_ uiView: UIViewType, context: Context) { }
//}
//
//struct Page: Identifiable {
//    var id = UUID().uuidString
//    var url: URL
//}
//
//class PageViewModel: ObservableObject{
//    @Published var urls = [
//        Page(url: URL(string: "https://www.google.com")!),
//        Page(url: URL(string: "https://www.twitter.com")!),
//        Page(url: URL(string: "https://www.facebook.com")!),
//        Page(url: URL(string: "https://www.netflix.com")!),
//        Page(url: URL(string: "https://www.apple.com")!)
//    ]
//
//    //Currently dragging
//    @Published var currentPage: Page?
//}
//
//struct DropViewDelegate: DropDelegate{
//    var page: Page
//    var pageData: PageViewModel
//
//    func performDrop(info: DropInfo) -> Bool {
//        return true
//    }
//
//    func dropEntered(info: DropInfo) {
//        let fromIndex = pageData.urls.firstIndex { (page) -> Bool in
//            return page.id == pageData.currentPage?.id
//        } ?? 0
//
//        let toIndex = pageData.urls.firstIndex { (page) -> Bool in
//            return page.id == self.page.id
//        } ?? 0
//
//        if fromIndex != toIndex {
//            withAnimation(.default) {
//                let fromPage = pageData.urls[fromIndex]
//                pageData.urls[fromIndex] = pageData.urls[toIndex]
//                pageData.urls[toIndex] = fromPage
//            }
//        }
//    }
//
//    func dropUpdated(info: DropInfo) -> DropProposal? {
//        return DropProposal(operation: .move)
//    }
//}

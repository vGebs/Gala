//
//  ProfileView.swift
//  Gala_Final
//
//  Created by Vaughn on 2021-05-03.
//

import SwiftUI
import iTextField

struct ProfileView: View {
    
//MARK: - View State Variables

    @ObservedObject var viewModel: ProfileViewModel
    
    @AppStorage("isDarkMode") private var isDarkMode = true
        
    @State var showAllImages = false
    
//MARK: - Main Body
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack{
                    
                    if viewModel.mode == .createAccount{
                        Spacer().frame(height: screenHeight * 0.02)
                        title
                        subtitle
                        ProfilePicturePlaceholder
                        nameAgeLocation
                    }
                    
                    if viewModel.mode == .profileStandard || viewModel.mode == .otherAccount || viewModel.mode == .demo{
                        Spacer().frame(height: screenHeight * 0.02)
                        ProfilePicturePlaceholder
                        nameAgeLocation
                        
                        if viewModel.mode != .otherAccount && viewModel.mode != .demo{
                            editButton
                        }
                        
                        if viewModel.editPressed == false {
                            if viewModel.mode != .otherAccount && viewModel.mode != .demo{
                                HStack{
                                    Image(systemName: "newspaper")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("Stories")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    Spacer()
                                }
                                .padding(.top)
                                
                                AddToStoryButton()
                                    .padding(.bottom, 5)
                                
                                MyStoriesDropDown(viewModel: viewModel.dropDownVM, popup: false)
                                    .padding(.bottom, 7)
                            }
                        }
                        
                        if viewModel.editPressed == false && viewModel.mode != .otherAccount {
                            //NewComer DropDown
                            NewcomerLikesDropDown(viewModel: viewModel.newComerLikesVM)
                        }
                    }
                    
                    if (viewModel.showBio && viewModel.bioText.count > 0) || viewModel.editPressed || viewModel.mode == .createAccount || viewModel.mode == .demo{
                        bioHeader
                        
                        if viewModel.editPressed || viewModel.mode == .createAccount{
                            bioTextField
                        }
                        
                        if (viewModel.mode == .profileStandard || viewModel.mode == .otherAccount || viewModel.mode == .demo) && !viewModel.editPressed {
                            bioText
                        }
                    }
                    
                    if (viewModel.showImages && viewModel.images.count > 0) || viewModel.editPressed || viewModel.mode == .createAccount {
                        showcaseImageHeader
                        ShowcaseProfileImageView(viewModel: self.viewModel, from: 0, to: 2)
                    }
                    
                    if (viewModel.showImages && viewModel.images.count > 3) || viewModel.editPressed || viewModel.mode == .createAccount{
                        ShowcaseProfileImageView(viewModel: self.viewModel, from: 3, to: 5)
                    }
                }
                .animation(.easeIn(duration: 0.2))
                .frame(width: screenWidth * 0.95)
                
                VStack{
                    
                    if viewModel.editPressed || viewModel.showGender || viewModel.mode == .createAccount {
                        chooseGender
                    }
                    
                    if viewModel.editPressed || viewModel.showSexuality || viewModel.mode == .createAccount{
                        chooseSexuality
                    }
                    
                    if viewModel.mode == .createAccount || viewModel.editPressed {
                        HStack{
                            Image(systemName: "person.and.arrow.left.and.arrow.right")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Age preference")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            Spacer()
                        }
                        .padding(.top)
                        SliderView(slider: viewModel.doubleKnobSlider)
                    }
                    
                    if viewModel.mode == .createAccount || viewModel.editPressed {
                        HStack{
                            Image(systemName: "car")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Travel Distance")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            Spacer()
                        }
                        .padding(.top)
                        SliderView(slider: viewModel.singleKnobSlider)
                    }
                    
                    if (viewModel.showJob && viewModel.jobText.count > 0) || viewModel.editPressed || viewModel.mode == .createAccount || viewModel.mode == .demo{
                        jobHeader
                        
                        if viewModel.editPressed || viewModel.mode == .createAccount{
                            jobTextField
                        }
                        
                        if !viewModel.editPressed && (viewModel.mode == .profileStandard || viewModel.mode == .otherAccount || viewModel.mode == .demo){
                            jobText
                        }
                    }
                    
                    if (viewModel.showSchool && viewModel.schoolText.count > 0) || viewModel.editPressed || viewModel.mode == .createAccount {
                        schoolHeader
                        
                        if viewModel.editPressed || viewModel.mode == .createAccount{
                            schoolTextField
                        }
                        
                        if !viewModel.editPressed && (viewModel.mode == .profileStandard || viewModel.mode == .otherAccount || viewModel.mode == .demo){
                            schoolText
                        }
                    }
                    
                    if viewModel.mode == .createAccount {
                        submitChangesButton
                    }
                }
                .animation(.easeIn(duration: 0.2))
                .frame(width: screenWidth * 0.95)
                .sheet(item: $viewModel.activeSheet){ item in
                    switch item {
                    case .profileImagePicker:
                        ImagePicker(isPresented: $viewModel.presentProfileImagePicker, activeSheet: $viewModel.activeSheet, pickerResult: $viewModel.profileImage, numImages: $viewModel.oneProfilePic, isProfilePic: true, didAddImg: $viewModel.profileImgChanged)
                            .edgesIgnoringSafeArea(.all)
                        
                    case .showcaseImagePicker:
                        ImagePicker(isPresented: $viewModel.showAddImages, activeSheet: $viewModel.activeSheet, pickerResult: $viewModel.images, numImages: $viewModel.maxImages, isProfilePic: false, didAddImg: $viewModel.imgsChanged)
                            .edgesIgnoringSafeArea(.all)
                        
                    case .profileImageCropper:
                        ImageCropper(image: $viewModel.profileImage[0].image, isShowing: $viewModel.presentCropProfilePic, activeSheet: $viewModel.activeSheet, didCrop: $viewModel.profileImgChanged)
                            .edgesIgnoringSafeArea(.all)
                        
                    case .showCaseImageCropper:
                        ImageCropper(image: $viewModel.images[self.viewModel.presentImageCropperWithIndex].image, isShowing: $viewModel.presentImageCropper, activeSheet: $viewModel.activeSheet, didCrop: $viewModel.imgsChanged)
                            .edgesIgnoringSafeArea(.all)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .frame(width: screenWidth * 0.98)
            .onTapGesture {
                hideKeyboard()
            }
            
            if viewModel.loading == true {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                LoadingView()
            }
        }
        .sheet(isPresented: $showAllImages) {
            AllProfileImageTabView(images: viewModel.getAllImages(), startingAt: 0, show: $showAllImages)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    //MARK: - View Variables
    
    var title: some View {
            Text(viewModel.title)
                .multilineTextAlignment(.center)
                .font(.system(size: 35, weight: .bold, design: .rounded))
    }
    
    var subtitle: some View {
        Text(viewModel.subtitle)
            .multilineTextAlignment(.center)
            .font(.system(size: 25, weight: .semibold, design: .rounded))
            .foregroundColor(Color.primary)
            .padding(.bottom)
    }
    
    var ProfilePicturePlaceholder: some View {
        ZStack {
            if viewModel.mode == .createAccount || viewModel.editPressed {
                addProfilePicButton
            }
            
            if viewModel.mode == .demo {
                Image(systemName: "person.fill")
                    .resizable()
                    .foregroundColor(.primary)
                    .frame(width: screenWidth / 4, height: screenWidth / 4)
                
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.accent)
                
            } else if let profilePic = viewModel.getProfilePic() {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.accent, lineWidth: 3)

                if !viewModel.editPressed {
                    Button(action: {
                        self.showAllImages = true
                    }) {
                        Image(uiImage: profilePic)
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth / 3.3, height: screenWidth / 3.3)
                            //.clipped()
                            //.clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                } else {
                    Image(uiImage: profilePic)
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenWidth / 3.3, height: screenWidth / 3.3)
                        //.clipped()
                        //.clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                VStack{
                    Spacer()
                    HStack{
                        
                        if viewModel.mode == .createAccount || viewModel.editPressed{
                            cropProfilePicButton
                        }
                        Spacer()
                        if viewModel.mode == .createAccount || viewModel.editPressed{
                            removeProfilePicButton
                        }
                    }
                }
                
            } else {
                ZStack{
                    if viewModel.profileImage.count == 0 && viewModel.editPressed == false && viewModel.mode == .profileStandard {
                        Image(systemName: "person.fill.questionmark")
                            .font(.system(size: 33, weight: .bold, design: .rounded))
                            .padding(.leading, 7)
                            .foregroundColor(Color(.systemTeal))
                    }
                    
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.accent)
                }
            }
        }
        .frame(width: screenWidth / 3.3, height: screenWidth / 3.3)
    }
    
    var addProfilePicButton: some View {
        Button(action: {
            viewModel.activeSheet = .profileImagePicker
            viewModel.presentProfileImagePicker = true
        }){
            
            Image(systemName: "plus")
                .font(.system(size: 25, weight: .bold, design: .rounded))
            
        }
    }
    
    var cropProfilePicButton: some View {
        Button(action: {
            viewModel.activeSheet = .profileImageCropper
            viewModel.presentCropProfilePic = true
        }){
            Image(systemName: "crop")
                .font(.system(size: 12, weight: .bold, design: .rounded))
        }
    }
    
    var removeProfilePicButton: some View {
        Button(action: { viewModel.deleteProfilePic() }){
            Image(systemName: "trash")
                .font(.system(size: 12, weight: .bold, design: .rounded))
        }
    }
    
    var nameAgeLocation: some View {
        VStack {
            HStack{
                if viewModel.nameText != "" {
                    Text("\(viewModel.nameText), \(viewModel.ageText)")
                        .font(.system(size: 23, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
            .padding(.bottom, 3)
            
            HStack {
                if (viewModel.cityText == "" || viewModel.countryText == "") && viewModel.uid == AuthService.shared.currentUser!.uid{
                    
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Menu("Add Location"){
                        Text("iOS Settings > Privacy > Location Services > Gala")
                    }
                    
                } else if viewModel.cityText != "" && viewModel.countryText != ""{
                    
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("\(viewModel.cityText), \(viewModel.countryText)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                }
            }
        }
    }
    
    var editButton: some View{
        Button(action: {
            viewModel.editProfile()            
        }){
            HStack {
                Text(viewModel.editPressed ? "submit changes" : "edit" )
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.buttonPrimary)
                
                Image(systemName: viewModel.editPressed ? "lock.open" : "lock")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.buttonPrimary)
            }
        }
        .padding(.top, 5)
    }
    
    var bioHeader: some View {
        HStack {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.primary) //Color(hex: "000080")
            
            Text(viewModel.bioHeader)
                .multilineTextAlignment(.center)
                .font(.system(size: 16, weight: .semibold, design: .rounded))

            Spacer()
            if viewModel.editPressed {
                Image(systemName: viewModel.showBio ? "checkmark.rectangle" : "rectangle")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.buttonPrimary)
                    .onTapGesture {
                        viewModel.showBio.toggle()
                    }
            }
        }
        .padding(.top)
    }
    
    var bioTextField: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16).stroke(Color.accent)
            
            VStack {
                TextEditor(text: $viewModel.bioText)
                    .onChange(of: viewModel.bioText) { value in
                        self.viewModel.aboutChanged = true
                        self.viewModel.bioCharCount = value.count
                    }
                    //.font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.top, 5)
                    .frame(width: screenWidth * 0.87, height: screenHeight * 0.095)
                
                Spacer()
                HStack{
                    Spacer()
                    Text("\(viewModel.bioCharCount)/\(viewModel.maxBioCharCount)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .padding(.trailing, 7)
                        .padding(.bottom, 3)
                }
            }
        }
        .frame(height: screenHeight * 0.13)
    }
    
    var bioText: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 16).stroke(Color.accent)
                .frame(width: screenWidth * 0.95)

            VStack{
                HStack{
                    Text(viewModel.bioText)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)
                    Spacer()
                }
                Spacer()
            }
            .padding(.leading, 5)
            .frame(width: screenWidth * 0.87, height: screenHeight * 0.095)
        }
        .frame(height: screenHeight * 0.13)
    }
    
    var showcaseImageHeader: some View {
        HStack {
            Image(systemName: "rectangle.stack.person.crop")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)

            Text(viewModel.pictureHeader)
                .multilineTextAlignment(.center)
                .font(.system(size: 16, weight: .semibold, design: .rounded))

            Spacer()
            
            if viewModel.editPressed {
                Image(systemName: viewModel.showImages ? "checkmark.rectangle" : "rectangle")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.buttonPrimary)
                    .onTapGesture {
                        viewModel.showImages.toggle()
                    }
            }
        }
        .padding(.top)
    }
    
    var ImagePlaceHolder: some View {
        ZStack {
            Button(action: {
                viewModel.activeSheet = .showcaseImagePicker
                viewModel.showAddImages = true
            }){
                Image(systemName: "plus")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
            }
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.accent)
                .frame(width: screenWidth / 3.3, height: screenHeight / 4.95)
        }
    }
    
    var removeImageButton: some View {
        ZStack {
            
            Circle()
                .stroke(Color.accent, lineWidth: 3)

            Circle()
                .foregroundColor(Color.white.opacity(0.5))
            
            Image(systemName: "trash")
                .font(.system(size: 12, weight: .bold, design: .rounded))
        }
        .frame(width: screenWidth / 13, height: screenWidth / 13)
        .padding(.trailing, 7)
        .padding(.bottom, 7)
    }
    
    var genderHeader: some View {
        HStack{
            Image(systemName: "figure.walk")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(viewModel.chooseGenderHeader)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
        }
        .padding(.top)
    }
    
    var selectGenderDropDown: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 15).stroke()
                .foregroundColor(.accent)
                .frame(width: screenWidth * 0.32, height: screenHeight * 0.03)
            
            if viewModel.mode == .createAccount || viewModel.editPressed{
                
                Menu(viewModel.selectGenderDropDownText.rawValue.capitalized){
                    Button("Female", action: {
                        if viewModel.selectGenderDropDownText != .female {
                            viewModel.selectGenderDropDownText = .female
                            self.viewModel.coreChanged = true
                        }
                    })
                    Button("Male", action: {
                        if viewModel.selectGenderDropDownText != .male {
                            viewModel.selectGenderDropDownText = .male
                            self.viewModel.coreChanged = true
                        }
                    })
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                
            } else {
                Text(viewModel.selectGenderDropDownText.rawValue.capitalized)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
        }
        .padding(.top)
    }
    
    var chooseGender: some View {
        HStack {
            genderHeader
            Spacer()
            selectGenderDropDown
            
            if viewModel.mode == .createAccount && !viewModel.genderIsReady {
                Menu {
                    Text(viewModel.genderWarning)
                } label: {
                    Label("", systemImage: "exclamationmark.circle")
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                //.padding(.trailing)
                .padding(.top)
            }
            
            if viewModel.editPressed {
                Image(systemName: viewModel.showGender ? "checkmark.rectangle" : "rectangle")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.buttonPrimary)
                    .onTapGesture {
                        viewModel.showGender.toggle()
                    }
                    .padding(.top)
            }
        }
    }
    
    var sexualityHeader: some View {
        HStack{
            Image(systemName: "figure.wave")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)

            Text(viewModel.chooseSexualityHeader)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
        }
        .padding(.top)
    }
    
    var selectSexualityDropDown: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 15).stroke()
                .foregroundColor(.accent)
                .frame(width: screenWidth * 0.32, height: screenHeight * 0.03)
            
            if viewModel.mode == .createAccount || viewModel.editPressed{
                
                Menu(viewModel.selectSexualityDropDownText.rawValue.capitalized){
                    Button("Straight", action: {
                        if viewModel.selectSexualityDropDownText != .straight {
                            viewModel.selectSexualityDropDownText = .straight
                            self.viewModel.coreChanged = true
                        }
                    })
                    Button("Gay", action: {
                        if viewModel.selectSexualityDropDownText != .gay {
                            viewModel.selectSexualityDropDownText = .gay
                            viewModel.coreChanged = true
                        }
                    })
                    Button("Bisexual", action: {
                        if viewModel.selectSexualityDropDownText != .bisexual {
                            viewModel.selectSexualityDropDownText = .bisexual
                            viewModel.coreChanged = true
                        }
                    })
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
            } else {
                Text(viewModel.selectSexualityDropDownText.rawValue.capitalized)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
        }
        .padding(.top)
    }
    
    var sexualityText: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 15).stroke()
                .foregroundColor(.accent)
                .frame(width: screenWidth * 0.4, height: screenHeight * 0.03)
        }
    }
    
    var chooseSexuality: some View {
        HStack{
            sexualityHeader
            Spacer()
            selectSexualityDropDown
            
            if viewModel.mode == .createAccount && !viewModel.sexualityIsReady {
                Menu {
                    Text(viewModel.sexualityWarning)
                } label: {
                    Label("", systemImage: "exclamationmark.circle")
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                //.padding(.trailing)
                .padding(.top)
            }
            
            if viewModel.editPressed {
                Image(systemName: viewModel.showSexuality ? "checkmark.rectangle" : "rectangle")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.buttonPrimary)
                    .onTapGesture {
                        viewModel.showSexuality.toggle()
                    }
                    .padding(.top)
            }
        }
    }
    
    var jobHeader: some View {
        HStack{
            Image(systemName: "briefcase")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)

            
            Text(viewModel.jobHeader)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            
            Spacer()
            
            if viewModel.editPressed {
                Image(systemName: viewModel.showJob ? "checkmark.rectangle" : "rectangle")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.buttonPrimary)
                    .onTapGesture {
                        viewModel.showJob.toggle()
                    }
            }
        }
        .padding(.top)
    }
    
    @State var editingJob = false
    @State var editingSchool = false
    
    var jobTextField: some View {
        iTextField("", text: $viewModel.jobText, isEditing: $editingJob)
            .onReturn { self.editingSchool = true }
            .foregroundColor(.primary)
            .onChange(of: viewModel.jobText, perform: { _ in
                viewModel.aboutChanged = true
            })
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.accent))
    }
    
    var jobText: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 16).stroke(Color.accent)
            HStack{
                Text(viewModel.jobText)
                    .foregroundColor(.primary)
                    .padding(.leading)
                Spacer()
            }
        }
        .frame(height: screenHeight * 0.07)
    }
    
    var schoolHeader: some View {
        HStack{
            Image(systemName: "pencil.and.outline")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(viewModel.schoolHeader)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            
            Spacer()
            
            if viewModel.editPressed {
                Image(systemName: viewModel.showSchool ? "checkmark.rectangle" : "rectangle")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.buttonPrimary)
                    .onTapGesture {
                        viewModel.showSchool.toggle()
                    }
            }
        }
        .padding(.top)
    }
    
    var schoolTextField: some View {
        iTextField("", text: $viewModel.schoolText, isEditing: $editingSchool)
            .onReturn { self.editingSchool = false }
            .foregroundColor(.primary)
            .onChange(of: viewModel.schoolText, perform: { _ in
                viewModel.aboutChanged = true
            })
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.accent))
    }
    
    var schoolText: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 16).stroke(Color.accent)
            HStack {
                Text(viewModel.schoolText)
                    .foregroundColor(.primary)
                    .padding(.leading)
                Spacer()
            }
        }
        .frame(height: screenHeight * 0.07)
    }
    
    var submitChangesButton: some View {
        Button(action: {
            viewModel.createProfile()
        }){
            ZStack{
                RoundedRectangle(cornerRadius: 16)
                    .stroke(lineWidth: 3.5)
                    .foregroundColor(Color.buttonPrimary)
                
                HStack {
                    Spacer()
                    if !viewModel.isValid {
                        Image(systemName: "lock")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    } else {
                        Image(systemName: "lock.open")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    
                    Text(viewModel.submitButtonText)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical)
                    Spacer()
                }

            }
        }
        .disabled(!viewModel.isValid)
        .opacity(viewModel.isValid ? 1 : 0.4)
        .padding(.vertical)
    }
}

//MARK: - SubViews of ProfileView

struct ShowcaseProfileImageView: View {
    
//MARK: - View State Variables

    @ObservedObject var viewModel: ProfileViewModel
    
    var from: Int //0
    var to: Int //2
    
    @State var index: Int = 0
    @State var showImages = false
    
//MARK: - Main Body
    
    var body: some View {
        HStack {
            ForEach(from...to, id: \.self) { i in
                if let image = viewModel.getImageItem(at: i){
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.accent, lineWidth: 3)
                            .frame(width: screenWidth / 3.3, height: screenHeight / 4.95)
                        if viewModel.mode == .createAccount || viewModel.editPressed{
                            
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: screenWidth / 3.3, height: screenHeight / 4.95)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .onDrag({
                                    viewModel.currentImageDrag = viewModel.images[i]
                                    
                                    return NSItemProvider(contentsOf: URL(string: "\(viewModel.images[i].id)")!)!
                                })
                                .onDrop(of: [.image], delegate: DropViewDelegate(image: viewModel.images[i], viewModel: viewModel))
                        } else {
                            Button(action: {
                                //when we click on an image we want to be able to view the image in full screen
                                index = i
                                showImages = true
                            }) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: screenWidth / 3.3, height: screenHeight / 4.95)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                        
                        VStack{
                            Spacer()
                            HStack{
                                if viewModel.mode == .createAccount || viewModel.editPressed{
                                    
                                    Button(action: {
                                        self.viewModel.activeSheet = .showCaseImageCropper
                                        self.viewModel.presentImageCropperWithIndex = i
                                        self.viewModel.presentImageCropper = true
                                    }){
                                        ZStack {
                                            
                                            Circle()
                                                .stroke(Color.accent, lineWidth: 3)
                                            
                                            Circle()
                                                .foregroundColor(Color.white.opacity(0.5))
                                            
                                            Image(systemName: "crop")
                                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                        }
                                        .frame(width: screenWidth / 13, height: screenWidth / 13)
                                        .padding(.leading, 7)
                                        .padding(.bottom, 7)
                                    }
                                }
                                
                                Spacer()
                                if viewModel.mode == .createAccount || viewModel.editPressed{
                                    
                                    Button(action: { viewModel.deleteImage(at: i) }) {
                                        removeImageButton
                                    }
                                }
                            }
                        }
                    }
                } else {
                    ImagePlaceHolder
                }
            }
        }
        .sheet(isPresented: $showImages) {
            AllProfileImageTabView(images: viewModel.getAllImages(), startingAt: 0, show: $showImages)
        }
    }
    
//MARK: - View Variables
    
    var removeImageButton: some View {
        ZStack {
            
            Circle()
                .stroke(Color.accent, lineWidth: 3)

            Circle()
                .foregroundColor(Color.white.opacity(0.5))
            
            Image(systemName: "trash")
                .font(.system(size: 12, weight: .bold, design: .rounded))
        }
        .frame(width: screenWidth / 13, height: screenWidth / 13)
        .padding(.trailing, 7)
        .padding(.bottom, 7)
    }
    
    var ImagePlaceHolder: some View {
        ZStack {
            if viewModel.mode == .createAccount || viewModel.editPressed{
                Button(action: {
                    viewModel.activeSheet = .showcaseImagePicker
                    viewModel.showAddImages = true
                }){
                    Image(systemName: "plus")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                }
            }
            
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.accent)
                .frame(width: screenWidth / 3.3, height: screenHeight / 4.95)
        }
    }
}

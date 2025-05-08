//
//  CreateProfileView.swift
//  Q-municate
//
//  Created by Injoit on 14.12.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import PhotosUI
import QuickBloxData
import QuickBloxUIKit

struct CreateProfileView: View {
    
    private var settings: ProfileScreenSettings
    
    @ObservedObject private var viewModel: EnterViewModel
    
    @State private var isAlertPresented: Bool = false
    @State private var presentCreateDialog: Bool = false
    @State private var isSizeAlertPresented: Bool = false
    @State private var isLogOutAlertPresented: Bool = false
    
    @FocusState private var isFocused: Bool
    
    @State private var attachmentAsset: AttachmentAsset? = nil
    
    init(_ viewModel: EnterViewModel,
         theme: AppTheme) {
        self.viewModel = viewModel
        self.settings = ProfileScreenSettings(theme)
    }
    
    
    public var body: some View {
        container()
    }
    
    @ViewBuilder
    private func container() -> some View {
        ZStack {
            settings.backgroundColor.ignoresSafeArea()
            VStack(spacing: 0) {
                ProfileHeader(onTap:  {
                    isFocused = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.viewModel.updateUser()
                    }
                }, settings: settings.header,
                                        isSave: viewModel.user?.name.isEmpty == false,
                                        disabled: viewModel.isValidUserName == false)
                .mediaAlert(isAlertPresented: $isAlertPresented,
                            isExistingImage: viewModel.isExistingImage,
                            mediaTypes: [.images],
                            viewModel: viewModel,
                            onRemoveImage: {
                    viewModel.removeExistingImage()
                }, onGetAvatarImage: { avatarImage in
                    viewModel.handleOnSelect(avatarImage)
                    
                })
                .padding()
                HStack(spacing: settings.spacing) {
                    ProfilePhoto(selectedImage: $viewModel.avatar,
                                 isLoadingAvatar: viewModel.isLoadingAvatar,
                                 onTap: {
                        isAlertPresented = true
                    }, settings: settings)
                    
                    ProfileNameTextField(profileName: $viewModel.userName,
                                         isValidProfileName: viewModel.isValidUserName,
                                         settings: settings)
                    .focused($isFocused)
                }.padding([.leading, .trailing])
                    .padding(.top)
                    .frame(maxHeight: 140)
                
                if viewModel.user?.name.isEmpty == false {
                    Button {
                        isLogOutAlertPresented = true
                    } label: {
                        Text(settings.logoutButton.title)
                            .foregroundColor(settings.logoutButton.color)
                            .font(settings.logoutButton.font)
                    }.frame(width: settings.logoutButton.size.width,
                            height: settings.logoutButton.size.height)
                    .padding(.top, 44)
                }
                
                Spacer()
            }
        }
        
        .if(isLogOutAlertPresented == true, transform: { view in
            view.logoutAlert(isPresented: $isLogOutAlertPresented, onSubmit: {
                viewModel.logOut()
            }, settings: settings)
        })
        
        .disabled(viewModel.isProcessing == true)
        .if(viewModel.isProcessing == true) { view in
            view.overlay() {
                CustomProgressView()
            }
        }
        .onAppear() {
            isFocused = false
            viewModel.setupUserInfo()
        }
        .onDisappear {
            isFocused = false
            viewModel.resetUserInfo()
        }
        
    }
}

public struct ProfilePhoto: View {
    private var settings: ProfileScreenSettings
    
    @Binding var selectedImage: UIImage?
    let onTap: () -> Void
    
    var avatarImage: Image? {
        if let selectedImage {
            return Image(uiImage: selectedImage)
        }
        return nil
    }
    
    var isLoadingAvatar: Bool
    
    init(selectedImage: Binding<UIImage?>,
         isLoadingAvatar: Bool,
         onTap: @escaping () -> Void,
         settings: ProfileScreenSettings) {
        _selectedImage = selectedImage
        self.isLoadingAvatar = isLoadingAvatar
        self.onTap = onTap
        self.settings = settings
    }
    
    public var body: some View {
        VStack {
            ZStack {
                if let avatarImage {
                    avatarImage
                        .avatarModifier(height: settings.height)
                        .onTapGesture {
                            onTap()
                        }
                } else if isLoadingAvatar == true {
                    settings.avatar
                        .avatarModifier(height: settings.height).opacity(0.6)
                        .overlay {
                            ProgressView().tint(.white)
                        }
                } else {
                    settings.avatar
                        .avatarModifier(height: settings.height)
                        .onTapGesture {
                            onTap()
                        }
                }
            }
            Spacer()
        }
    }
}

extension Image {
    func avatarModifier(height: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(width: height, height: height)
            .clipShape(Circle())
    }
}

extension Color {
    func avatarModifier(height: CGFloat) -> some View {
        self
            .frame(width: height, height: height)
            .clipShape(Circle())
    }
}

public struct ProfileNameTextField: View {
    private var settings: ProfileScreenSettings
    
    @Binding var profileName: String
    var isValidProfileName: Bool = false
    @FocusState private var isFocused: Bool
    
    init(profileName: Binding<String>,
         isValidProfileName: Bool,
         settings: ProfileScreenSettings) {
        _profileName = profileName
        self.isValidProfileName = isValidProfileName
        self.settings = settings
    }
    
    public var body: some View {
        VStack(spacing: settings.spacing / 2) {
            TextField(settings.textfieldPrompt, text: $profileName, onEditingChanged: { (changed) in
                isFocused = changed
            }).padding(.top)
            
            Divider()
                .background(settings.hint.color)
            
            Text(settings.hint.text)
                .font(settings.hint.font)
                .foregroundColor(settings.hint.color)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
    }
}

struct LogoutAlert: ViewModifier {
    private var settings: ProfileScreenSettings
    @Binding var isPresented: Bool
    let onSubmit: () -> Void
    
    init(settings: ProfileScreenSettings,
         isPresented: Binding<Bool>,
         onSubmit: @escaping () -> Void) {
        self.settings = settings
        _isPresented = isPresented
        self.onSubmit = onSubmit
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            content.blur(radius: isPresented ? 12.0 : 0.0)
                .disabled(isPresented)
                .alert(settings.logoutAlert.title, isPresented: $isPresented) {
                    Button(settings.logoutAlert.cancel, role: .cancel, action: {
                        isPresented = false
                    })
                    Button(settings.logoutAlert.ok, action: {
                        isPresented = false
                        onSubmit()
                    })
                } message: {
                    Text("")
                }
        }
    }
}

extension View {
    func logoutAlert(
        isPresented: Binding<Bool>,
        onSubmit: @escaping () -> Void,
        settings: ProfileScreenSettings
    ) -> some View {
        self.modifier(LogoutAlert(settings: settings, isPresented: isPresented, onSubmit: onSubmit))
    }
}

struct ProfileHeader: View {
    
    private var settings: SettingsHeaderSettings
    private var isSave: Bool
    private var disabled: Bool
    
    let onTap: () -> Void
    
    init(onTap: @escaping () -> Void,
         settings: SettingsHeaderSettings,
         isSave: Bool,
         disabled: Bool) {
        self.onTap = onTap
        self.settings = settings
        self.isSave = isSave
        self.disabled = disabled
    }
    
    public var body: some View {
        HStack(alignment: .center) {
            Text(isSave == true ?  settings.title.settings : settings.title.profile)
                .font(settings.title.font)
                .foregroundColor(settings.title.color)
        Spacer()
            Button {
                onTap()
            } label: {
                Text(isSave == true ? settings.rightButton.save : settings.rightButton.finish)
                    .foregroundColor(disabled == false ? settings.rightButton.color : settings.rightButton.color.opacity(0.4))
            }.disabled(disabled)
        }
    }
}

public struct CustomMediaAlert: ViewModifier {
    public var settings = QuickBloxUIKit.settings.dialogNameScreen.mediaAlert
    
    @ObservedObject var viewModel: EnterViewModel
    
    @Binding var isAlertPresented: Bool
    @State var isImagePickerPresented: Bool = false
    @State var isCameraPresented: Bool = false
    @State var selectedItem: PhotosPickerItem? = nil
    @State private var avatarImage: UIImage? {
        didSet {
            if let avatarImage {
                onGetAvatarImage(avatarImage)
                defaultState()
            }
        }
    }
    
    var mediaPickerActions: [MediaPickerAction] {
        var mediaPickerAction: [MediaPickerAction]  = [.camera, .photo]
        if isExistingImage == true {
            mediaPickerAction = [.removePhoto, .camera, .photo]
        }
        return mediaPickerAction
    }
    
    var isExistingImage: Bool
    let mediaTypes: [PHPickerFilter]
    
    let onRemoveImage: () -> Void
    let onGetAvatarImage: (_ image: UIImage) -> Void
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: isAlertPresented || isImagePickerPresented ? settings.blurRadius : 0.0)
            
                .if(isIphone == true, transform: { view in
                    view.confirmationDialog(settings.title, isPresented: $isAlertPresented, actions: {
                        if isExistingImage == true {
                            Button(settings.removePhoto, role: .destructive) {
                                onRemoveImage()
                                defaultState()
                            }
                        }
                        Button(settings.camera, role: .none) {
                            isCameraPresented = true
                        }
                        Button(settings.gallery, role: .none, action: {
                            isImagePickerPresented = true
                        })
                        Button(settings.cancel, role: .cancel) {
                            defaultState()
                        }
                    })
                })
            
                .if(isIPad == true && isAlertPresented == true, transform: { view in
                    ZStack {
                        view.disabled(true)
                            .overlay(
                                VStack(spacing: 8) {
                                    VStack {
                                        ForEach(mediaPickerActions, id:\.self) { action in
                                            MediaPickerSegmentView(action: action) { action in
                                                switch action {
                                                case .removePhoto:
                                                    onRemoveImage()
                                                    defaultState()
                                                case .camera:
                                                    isCameraPresented = true
                                                case .photo:
                                                    isImagePickerPresented = true
                                                }
                                            }
                                            
                                            if mediaPickerActions.last != action {
                                                Divider()
                                            }
                                        }
                                    }
                                    .background(RoundedRectangle(cornerRadius: settings.cornerRadius).fill(settings.iPadBackgroundColor))
                                    .frame(width: settings.buttonSize.width)
                                    
                                    VStack {
                                        Button {
                                            defaultState()
                                        } label: {
                                            
                                            HStack {
                                                Text(settings.cancel).foregroundColor(settings.iPadImageColor)
                                            }
                                            .frame(width: settings.buttonSize.width, height: settings.buttonSize.height)
                                        }
                                    }
                                    .background(RoundedRectangle(cornerRadius: settings.cornerRadius).fill(settings.iPadBackgroundColor))
                                    .frame(width: settings.buttonSize.width)
                                }
                                    .frame(width: settings.buttonSize.width)
                                    .shadow(color: settings.shadowColor, radius: settings.blurRadius)
                            )
                    }
                })
            
                .imagePicker(isCameraPresented: $isCameraPresented,
                             mediaTypes: mediaTypes,
                             onDismiss: {
                    defaultState()
                }, onGetAvatarImage: { avatarImage in
                    onGetAvatarImage(avatarImage)
                    defaultState()
                })
            
                .photosPicker(isPresented: $isImagePickerPresented, selection: $selectedItem,
                              matching: .any(of: mediaTypes),
                              photoLibrary: .shared())
            
                .onChange(of: selectedItem) { _ in
                    Task {
                        self.avatarImage = nil
                        
                        if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                           let contentType = selectedItem?.supportedContentTypes.first {
                            let url = documentsDirectoryPath().appendingPathComponent("\(UUID().uuidString).\(contentType.preferredFilenameExtension ?? "")")
                            do {
                                try data.write(to: url)
                                if let avatarImage = UIImage(data: data) {
                                    self.avatarImage = avatarImage
                                }
                            } catch {
                                print("Failed")
                            }
                        }
                        print("Failed")
                    }
                }
        }
    }
    
    private func defaultState() {
        isAlertPresented = false
        isCameraPresented = false
        isImagePickerPresented = false
    }
}

extension View {
    func mediaAlert(
        isAlertPresented: Binding<Bool>,
        isExistingImage: Bool,
        mediaTypes: [PHPickerFilter],
        viewModel: EnterViewModel,
        onRemoveImage: @escaping () -> Void,
        onGetAvatarImage: @escaping (_ avatarImage: UIImage) -> Void
    ) -> some View {
        self.modifier(CustomMediaAlert(viewModel: viewModel,
                                       isAlertPresented: isAlertPresented,
                                       isExistingImage: isExistingImage,
                                       mediaTypes: mediaTypes,
                                       onRemoveImage: onRemoveImage,
                                       onGetAvatarImage: onGetAvatarImage
                                      ))
    }
}

public enum MediaPickerAction: CaseIterable {
    case removePhoto, camera, photo
}

public struct MediaPickerSegmentView: View {
    public var settings = QuickBloxUIKit.settings.dialogNameScreen.mediaAlert
    
    let action: MediaPickerAction
    let onTap: (_ action: MediaPickerAction) -> Void
    
    @ViewBuilder
    public var body: some View {
        Button {
            onTap(action)
        } label: {
            HStack {
                switch action {
                case .removePhoto:
                    Text(settings.removePhoto).foregroundColor(settings.removePhotoColor)
                    Spacer()
                    settings.imageClose.foregroundColor(settings.removePhotoColor)
                case .camera:
                    Text(settings.camera).foregroundColor(settings.iPadForegroundColor)
                    Spacer()
                    settings.imageCamera.foregroundColor(settings.iPadImageColor)
                case .photo:
                    Text(settings.gallery).foregroundColor(settings.iPadForegroundColor)
                    Spacer()
                    settings.imageGallery.foregroundColor(settings.iPadImageColor)
                }
            }
            .padding()
        }
        .frame(width: settings.buttonSize.width, height: settings.buttonSize.height)
    }
}

public struct ImagePicker: ViewModifier {
    
    @Binding var isCameraPresented: Bool
    @State var avatarImage: UIImage? = nil
    var mediaTypes: [PHPickerFilter]
    let onDismiss: () -> Void
    let onGetAvatarImage: (_ image: UIImage) -> Void
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .fullScreenCover(isPresented: $isCameraPresented) {
                    ZStack {
                        if isCameraPresented == true {
                            Color.black.ignoresSafeArea(.all)
                        }
                        MediaPickerView(sourceType: UIImagePickerController.SourceType.camera,
                                        avatarImage: $avatarImage,
                                        isPresented: $isCameraPresented,
                                        mediaTypes:convert(mediaTypes))
                        .onDisappear {
                            onDismiss()
                            if let avatarImage {
                                onGetAvatarImage(avatarImage)
                            }
                        }
                        
                    }
                }
        }
    }
}

private func convert(_ mediaTypes: [PHPickerFilter]) -> [String] {
    var mediaIdentifiers: [String] = []
    for type in mediaTypes {
        switch type {
        case .videos:
            mediaIdentifiers.append(UTType.movie.identifier)
        case .images:
            mediaIdentifiers.append(UTType.image.identifier)
        default: continue
        }
    }
    return mediaIdentifiers
}

extension View {
    func imagePicker(
        isCameraPresented: Binding<Bool>,
        mediaTypes: [PHPickerFilter],
        onDismiss: @escaping () -> Void,
        onGetAvatarImage: @escaping (_ image: UIImage) -> Void
    ) -> some View {
        self.modifier(ImagePicker(isCameraPresented: isCameraPresented,
                                  mediaTypes: mediaTypes,
                                  onDismiss: onDismiss,
                                  onGetAvatarImage: onGetAvatarImage))
    }
}


func documentsDirectoryPath() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

struct MediaPickerView: UIViewControllerRepresentable {
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var avatarImage: UIImage?
    @Binding var isPresented: Bool
    var mediaTypes: [String]
    
    func makeCoordinator() -> MediaPickerViewCoordinator {
        return MediaPickerViewCoordinator(avatarImage: $avatarImage, isPresented: $isPresented)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = sourceType
        pickerController.delegate = context.coordinator
        pickerController.mediaTypes = mediaTypes
        pickerController.allowsEditing = true
        return pickerController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

class MediaPickerViewCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @Binding var avatarImage: UIImage?
    @Binding var isPresented: Bool
    
    init(avatarImage: Binding<UIImage?>, isPresented: Binding<Bool>) {
        self._avatarImage = avatarImage
        self._isPresented = isPresented
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image : UIImage = UIImage()
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            image = originalImage
        }
        
        self.avatarImage = image
        self.isPresented = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.isPresented = false
    }
    
    private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
}

struct CustomProgressView: View {
    let progressBar = QuickBloxUIKit.settings.dialogsScreen.progressBar
    
    var body: some View {
        ZStack {
            Color.black.frame(width: 100, height: 100)
                .cornerRadius(12)
                .opacity(0.6)
            
            SegmentedCircularBar(settings: progressBar)
        }
    }
}

struct SegmentedCircularBar: View {
    var settings: ProgressBarSettingsProtocol
    @State private var currentSegment = 0
    
    private var totalEmptySpaceAngle: Angle {
        settings.emptySpaceAngle * Double(settings.segments)
    }
    
    private var availableAngle: Angle {
        Angle(degrees: 360.0) - totalEmptySpaceAngle
    }
    
    private var segmentAngle: Angle {
        availableAngle / Double(settings.segments)
    }
    
    var body: some View {
        ZStack {
            ForEach(0..<settings.segments, id: \.self) { index in
                segment(at: index)
            }
        }
        .rotationEffect(settings.rotationEffect)
        .frame(width: settings.size.width, height: settings.size.height)
        .onAppear() {
            startAnimation()
        }
    }
    
    init(settings: ProgressBarSettingsProtocol) {
        self.settings = settings
    }
    
    private func segment(at index: Int) -> some View {
        let startAngle = Angle(degrees: Double(index) * (segmentAngle.degrees + settings.emptySpaceAngle.degrees))
        let endAngle = Angle(degrees: startAngle.degrees + segmentAngle.degrees)
        
        return Circle()
            .trim(from: CGFloat(startAngle.radians / (2 * .pi)), to: CGFloat(endAngle.radians / (2 * .pi)))
            .stroke(segmentColor(at: index),
                    style: StrokeStyle(lineWidth: settings.lineWidth, lineCap: .butt))
    }
    
    private func segmentColor(at index: Int) -> Color {
        return index == currentSegment || index == nextIndex ? settings.progressSegmentColor : settings.segmentColor
    }
    
    var nextIndex: Int {
        let next = currentSegment + 1
        if next == settings.segments {
            return 0
        }
        return next
    }
    
    func startAnimation() {
        withAnimation {
            if currentSegment < settings.segments - 1 {
                currentSegment = currentSegment + 1
            } else {
                currentSegment = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + settings.segmentDuration) {
            startAnimation()
        }
    }
}

struct SegmentedCircularBarContentView: View {
    let settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    var body: some View {
        VStack {
            
            ZStack {
                
                settings.progressBarBackground()
                    .frame(width: settings.attachmentSize.width,
                           height: settings.attachmentSize.height)
                    .cornerRadius(settings.attachmentRadius, corners: settings.inboundCorners)
                    .padding(settings.inboundPadding(showName: settings.isHiddenName))
                
                SegmentedCircularBar(settings: settings.aiProgressBar)
                
            }
        }
    }
}

struct SegmentedCircularBarContentView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedCircularBarContentView()
        SegmentedCircularBarContentView()
            .preferredColorScheme(.dark)
    }
}


# CoreML_SwiftUI_Classifier

Select image, get Core ML classifications.
One line change if you need to drop a new model in.

Also contains easy ImagePicker sheet modifier. Works like a standard sheet, but returns a UIImage.

Use:
```swift
@State var selectedImage = UIImage()
@State var isImagePickerShown = false
...
VStack {
        Image(uiImage: selectedImage)
            .resizable()
            .scaledToFit()
            .padding()
        Button {
            isImagePickerShown = true
        } label: {
            Label("Select New Image", systemImage: "photo.fill")
                .padding()
        }
}   
.imagePickerSheet(isPresented: $isImagePickerShown) { image in
     self.selectedImage = image
}
```
<img src="https://github.com/JohnBethancourt/CoreML_SwiftUI_Classifier/blob/main/DogScreenshot.png" width="50%" height="50%" />

### EasyPhotoPicker

Easy way how to get iOS Photo Libary for circle Profile Image


Sample Code

```
//Show the picker with bottom sheet style
let cropImagePicker = EasyPhotoPickerViewController()
cropImagePicker.setParent(viewController: self)
cropImagePicker.pickerDelegate = self
cropImagePicker.showPickerAlert() 
```
```
//delegate example
extension MainViewController :EasyPhotoPickerdelegate {
    //Picked Image
    func pickedImage(img: UIImage?) {
        guard let img = img else { return }
        self.profileImg.image = img
    }
}
```

![screensh](https://i.ibb.co/jWj0DtF/sample.gif)

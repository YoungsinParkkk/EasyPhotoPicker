//
//  EasyPhotoPickerViewController.swift
//  EasyPhotoPicker
//
//  Created by PYS on 2020/12/10.
//

import UIKit

protocol EasyPhotoPickerdelegate {
    func pickedImage(img:UIImage?)
}

class EasyPhotoPickerViewController: UIViewController {

    public var pickerDelegate: EasyPhotoPickerdelegate?
    public var parentViewControllers:UIViewController?
    
    public var takePhotoTitle:String = "Take Photo"
    public var choosePhotoTitle:String = "Choose Photo"
    public var cancelTitle:String = "Cancel"
    
    fileprivate var alertController = UIAlertController()
    fileprivate var imagePicker = UIImagePickerController()
    fileprivate var pickedImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func setParent(viewController:UIViewController?)  {
        guard let parentViewCotroller = viewController else {
            print("please set not nil View Controller")
            return
        }
        self.parentViewControllers = parentViewCotroller
    }
    
    public func showPickerAlert() {
        guard let parentViewCotroller = self.parentViewControllers else { return }
        
        self.alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: takePhotoTitle, style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alertController.addAction(UIAlertAction(title: choosePhotoTitle, style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alertController.addAction(UIAlertAction.init(title: cancelTitle, style: .cancel, handler: nil))
        
        parentViewCotroller.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.parentViewControllers?.present(imagePicker, animated: true, completion: nil)
        }
        else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.parentViewControllers?.present(alert, animated: true, completion: nil)
        }
    }

    fileprivate func openGallary(){
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.parentViewControllers?.present(imagePicker, animated: true, completion: nil)
    }
}

extension EasyPhotoPickerViewController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let chosenImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            dismiss(animated:true, completion: nil)
            return
        }
        if let delegate =  self.pickerDelegate {
            delegate.pickedImage(img: chosenImage)
        }
        self.parentViewControllers?.dismiss(animated:true, completion: nil)
      }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.parentViewControllers?.dismiss(animated: true, completion: nil)
    }
}



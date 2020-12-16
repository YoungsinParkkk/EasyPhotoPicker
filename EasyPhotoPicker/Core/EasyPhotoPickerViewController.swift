//
//  EasyPhotoPickerViewController.swift
//  EasyPhotoPicker
//
//  Created by PYS on 2020/12/10.
//

import UIKit
import CropViewController

protocol EasyPhotoPickerdelegate {
    func pickedImage(img:UIImage?)
}

class EasyPhotoPickerViewController: UIViewController {

    public var pickerDelegate: EasyPhotoPickerdelegate?
    public var parentViewControllers:UIViewController?
    
    public var takePhotoTitle:String = "Take Photo"
    public var choosePhotoTitle:String = "Choose Photo"
    public var cancelTitle:String = "Cancel"
    
    public var cameraOverlayOn:Bool = false //if need camera overlay in circle
    
    private var alertController = UIAlertController()
    private var imagePicker = UIImagePickerController()
    private var pickedImg: UIImageView = UIImageView()
    
    private var croppingStyle = CropViewCroppingStyle.circular
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    private var image: UIImage?
    
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
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            if cameraOverlayOn == true {
                imagePicker.cameraOverlayView = guideForCameraOverlay()
            }
            
            self.parentViewControllers?.present(imagePicker, animated: true, completion: nil)
        }
        else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.parentViewControllers?.present(alert, animated: true, completion: nil)
        }
    }

    fileprivate func openGallary(){
        let imagePicker = UIImagePickerController()
        imagePicker.modalPresentationStyle = .popover
        imagePicker.popoverPresentationController?.barButtonItem = UIBarButtonItem()
        imagePicker.preferredContentSize = CGSize(width: 320, height: 568)
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        self.parentViewControllers?.present(imagePicker, animated: true, completion: nil)
    }
}

extension EasyPhotoPickerViewController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
        let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
        cropController.delegate = self
        self.image = image
        
        //If profile picture, push onto the same navigation stack
        if croppingStyle == .circular {
            if picker.sourceType == .camera {
                picker.dismiss(animated: true, completion: {
                    self.parentViewControllers?.present(cropController, animated: true, completion: nil)
                })
            } else {
                picker.pushViewController(cropController, animated: true)
            }
        }
        else { //otherwise dismiss, and then present from the main controller
            picker.dismiss(animated: true, completion: {
                self.parentViewControllers?.present(cropController, animated: true, completion: nil)
                //self.navigationController!.pushViewController(cropController, animated: true)
            })
        }
        
      }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.parentViewControllers?.dismiss(animated: true, completion: nil)
    }
    
    func guideForCameraOverlay() -> UIView {
        let guide = UIView(frame: UIScreen.main.fullScreenSquare())
        guide.backgroundColor = UIColor.clear
        guide.layer.borderWidth = 1
        guide.layer.borderColor = UIColor.black.cgColor
        guide.layer.cornerRadius = guide.bounds.width/2
        guide.isUserInteractionEnabled = false
        return guide
    }
    
    @objc public func didTapImageView() {
        // When tapping the image view, restore the image to the previous cropping state
        let cropViewController = CropViewController(croppingStyle: self.croppingStyle, image: self.image!)
        cropViewController.delegate = self
        let viewFrame = view.convert(pickedImg.frame, to: navigationController!.view)
        
        cropViewController.presentAnimatedFrom(self,
                                               fromImage: self.pickedImg.image,
                                               fromView: nil,
                                               fromFrame: viewFrame,
                                               angle: self.croppedAngle,
                                               toImageFrame: self.croppedRect,
                                               setup: { self.pickedImg.isHidden = true },
                                               completion: nil)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutImageView()
    }
    
    public func layoutImageView() {
        guard pickedImg.image != nil else { return }
        
        let padding: CGFloat = 20.0
        
        var viewFrame = self.view.bounds
        viewFrame.size.width -= (padding * 2.0)
        viewFrame.size.height -= ((padding * 2.0))
        
        var imageFrame = CGRect.zero
        imageFrame.size = pickedImg.image!.size;
        
        if pickedImg.image!.size.width > viewFrame.size.width || pickedImg.image!.size.height > viewFrame.size.height {
            let scale = min(viewFrame.size.width / imageFrame.size.width, viewFrame.size.height / imageFrame.size.height)
            imageFrame.size.width *= scale
            imageFrame.size.height *= scale
            imageFrame.origin.x = (self.view.bounds.size.width - imageFrame.size.width) * 0.5
            imageFrame.origin.y = (self.view.bounds.size.height - imageFrame.size.height) * 0.5
            pickedImg.frame = imageFrame
        }
        else {
            self.pickedImg.frame = imageFrame;
            self.pickedImg.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        }
    }
}

extension EasyPhotoPickerViewController : CropViewControllerDelegate {
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        pickedImg.image = image
        layoutImageView()
        
        if let delegate =  self.pickerDelegate {
            delegate.pickedImage(img: image)
        }
        
        self.navigationItem.leftBarButtonItem?.isEnabled = true
        
        if cropViewController.croppingStyle != .circular {
            pickedImg.isHidden = true
            
            cropViewController.dismissAnimatedFrom(self, withCroppedImage: image,
                                                   toView: pickedImg,
                                                   toFrame: CGRect.zero,
                                                   setup: { self.layoutImageView() },
                                                   completion: {
                                                    self.pickedImg.isHidden = false })
        }
        else {
            self.pickedImg.isHidden = false
            cropViewController.dismiss(animated: true, completion: nil)
        }
    }
}

extension UIScreen {
    func fullScreenSquare() -> CGRect {
        var hw:CGFloat = 0
        var isLandscape = false
        if UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height {
        hw = UIScreen.main.bounds.size.width
    }
    else {
        isLandscape = true
        hw = UIScreen.main.bounds.size.height
    }

    var x:CGFloat = 0
    var y:CGFloat = 0
    if isLandscape {
        x = (UIScreen.main.bounds.size.width / 2) - (hw / 2)
    }
    else {
        y = (UIScreen.main.bounds.size.height / 2) - (hw / 2)
    }
        return CGRect(x: x, y: y, width: hw, height: hw)
    }
    func isLandscape() -> Bool {
        return UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height
    }
}


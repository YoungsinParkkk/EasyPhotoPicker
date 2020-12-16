//
//  ViewController.swift
//  EasyPhotoPicker
//
//  Created by PYS on 2020/12/10.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet var profileImg: UIImageView!{
        didSet {
            profileImg.layer.cornerRadius = profileImg.bounds.width/2
            profileImg.layer.borderWidth = 1
            profileImg.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func showPicker (){
        //Show the picker
        let cropImagePicker = EasyPhotoPickerViewController()
        cropImagePicker.setParent(viewController: self)
        cropImagePicker.pickerDelegate = self
        cropImagePicker.showPickerAlert()
    }
}

extension MainViewController :EasyPhotoPickerdelegate {
    //Picked Image
    func pickedImage(img: UIImage?) {
        guard let img = img else { return }
        self.profileImg.image = img
    }
}

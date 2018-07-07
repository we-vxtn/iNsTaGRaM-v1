//
//  ViewController.swift
//  imageScroll
//
//  Created by william sun on 7/5/18.
//  Copyright © 2018 w|e.vxtn. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    var clickedImage: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // These allows the viewcontroller to call the methods when the notif center recieves that the keyboard is going to show/hide
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(sender:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(sender:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);

    }
    
    //MARK: Miscellaneous Methods
    func resetImageViewConstraints(_ imageView: UIImageView) {
        
        
        
    }
    
    func setImageViewAspectRatio(_ imageView: UIImageView) {
        if (imageView.image != nil) {
            imageView.removeConstraints(imageView.constraintsAffectingLayout(for: UILayoutConstraintAxis.vertical))
            let imageSize = imageView.image!.size
            if( imageSize.height <= imageSize.width ) {         //if height is less than width
                let ratio: CGFloat = imageView.image!.size.height / imageView.image!.size.width
                imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: ratio, constant: 0))
            }
            else {
                let ratio: CGFloat = imageView.image!.size.width / imageView.image!.size.height
                imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: ratio, constant: 0))
            }
        }
        else {
            imageView.heightAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        }
    }
    
    //MARK: Keyboard show/hide functions that move the scrollview so text field is always visible
    @objc func keyboardWillShow(sender :NSNotification){
        var userInfo = sender.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(sender :NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    //MARK: Button Functions: Adds TextFields and ImageViews
    @IBAction func addTextField(_ sender: UIButton) {
        // initialize the text field
        let textLabel = UITextField()
        
        // add constraints to the text field
        textLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        textLabel.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        // sets default text field properties
        textLabel.text  = "Hi World"
        textLabel.backgroundColor = UIColor.black
        textLabel.textColor = UIColor.white
        textLabel.textAlignment = .center
        
        // adds the ViewController as the UITextField Delegate
        textLabel.delegate = self
        
        // appends the textField to the stack view (superview), and the scroll view (stack view's superview)
        stackView.addArrangedSubview( textLabel )
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        // initialize the image view
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.blue
        
        // adds the image to the image view
        imageView.image = UIImage(named: "defaultPhoto", in: Bundle(for: type(of: self)), compatibleWith: self.traitCollection)
        
        // add constraints to the image view
        imageView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        setImageViewAspectRatio(imageView)
        imageView.contentMode = .scaleAspectFit
        
        // adds content compression resistance so that the images deosnt compress when more is added
        imageView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: UILayoutConstraintAxis.vertical)
        imageView.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: UILayoutConstraintAxis.vertical)
        
        // links the imageview to the gesture recognizer, and then the method that opens the photo library
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.imageClicked(_:))))
        imageView.isUserInteractionEnabled = true
        
        // appends the imageview to the stack view (superview), and the scroll view (stack view's superview)
        stackView.addArrangedSubview(imageView)
    }
    
    //MARK: Image Selection methods
    @objc func tappedImage(_ sender: AnyObject) {
        print("image clicked")
    }
    
    @objc func imageClicked(_ sender: UIGestureRecognizer) {
        // checks if the UIGestureRecognizer contains an ImageView as its View, and then casts it to it if it does
        if let senderImage = sender.view as? UIImageView {
            clickedImage = senderImage
        }
        
        // this is a view controller that lets users pick photos from their photo library
        let imagePickerController = UIImagePickerController()
        
        // this makes it so the user can only choose photos from their photo library
        imagePickerController.sourceType = .photoLibrary
        
        // sets the image picker controller's delegate to the view controller
        imagePickerController.delegate = self
        
        // present is the function called to go to another view. the first parameter is the next view, animated (bool) tells whether or not the transition should be animated, completion is a completionHandler, a piece of code that will execute after this method is done (nil is void)
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: UITextField Delegate Protocol
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //this brings attention away from the text field, which hides the keyboard
        textField.resignFirstResponder()
        return true         //method returns true if the final text should be processed
    }
    
    //MARK: UIImagePickerController Delegate Protocol
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // dismisses the image picker
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // info contains a dictionary of the various versions of the image, always contains an originalImage, may contain and edited image
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided with the following: \(info)")
        }
        
        // checks if clickedImage is okay to be unwrapped, then changes the picture and aspect ratio
        if(clickedImage != nil) {
            // sets the picture to the chosen picture
            clickedImage!.image = selectedImage
            
            // changes the aspect ratio of clicked image to match the picture
            setImageViewAspectRatio(clickedImage!)
        }
        dismiss(animated: true, completion: nil)
    }
    
}


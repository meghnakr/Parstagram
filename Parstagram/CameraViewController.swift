//
//  CameraViewController.swift
//  Parstagram
//
//  Created by user162638 on 2/21/20.
//  Copyright © 2020 user162638. All rights reserved.
//

import UIKit
import AlamofireImage
import Firebase
import FirebaseAuth
import FirebaseStorage

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionField: UITextField!
    
    var ref: DatabaseReference!
    //var storageRef: StorageReference!
    let picker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        //storageRef = Storage.storage().reference()
        // Do any additional setup after loading the view.
    }
    

    @IBAction func onSubmit(_ sender: Any) {
        let user = Auth.auth().currentUser
        //print("Reached here 0")
        self.ref.child("Users").child(user!.uid).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String
        //print("Reached here 1")
            
        let postID = self.ref.child("posts").childByAutoId().key
            
            guard let imageData = self.imageView.image?.jpegData(compressionQuality: 0.90) else {return}
            let uploadMetaData = StorageMetadata.init()
            uploadMetaData.contentType = "image/jpeg"
            let randomID = UUID.init().uuidString
            let storageRef = Storage.storage().reference(withPath: "images/\(randomID).jpg")
            storageRef.putData(imageData, metadata: uploadMetaData) { (downloadMetaData, error) in
                if let error = error {
                    print("Error! \(error.localizedDescription)")
                    return
                }
                print("Done!\(downloadMetaData)")
            }
        //print("\(postID)")
        /*let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let filePath = URL(string: "\(paths[0])/post.jpg")
        
            let imageRef = self.storageRef.child("images/\(postID!).jpg")
            let uploadTask = imageRef.putFile(from: filePath!)*/
            
        //UIImageJPEGRepresentation(imageView.image!, 0.90)?.writeToFile(filePath, atomically: true)
            /*let imageData = self.imageView.image?.jpegData(compressionQuality: 0.90)
            print("data\(imageData)")
        do {
        try imageData?.write(to: URL(fileURLWithPath: filePath), options: .atomic)
        } catch {
            print(error)
        }
        let imageURL = URL(fileURLWithPath: filePath).absoluteString*/
        //print("Reached here 2")
        //print("\(imageURL)")
        //self.ref.child("Users").child(user!.uid).child("posts").child(postID!).setValue(["caption": captionField.text])
        //print("Reached here 3")
        //self.ref.child("Users").child(user!.uid).child("posts").child(postID!).setValue(["image": imageURL])
        //print("Reached here 4")
        //self.ref.child("Users").child(user!.uid).child("posts").child(postID!).setValue(["post": "post"])
        //let result = self.ref.child("Users").child(user!.uid).child("posts").child(postID!).value(forKey: "image")
        //print("\(result)")
            let date = Date()
            let day = Calendar.current.component(.day, from: date)
            let month = Calendar.current.component(.month, from: date)
            let year = Calendar.current.component(.year, from: date)
            let hour = Calendar.current.component(.hour, from: date)
            let minutes = Calendar.current.component(.minute, from: date)
            
            let commentDictionary = [String: [String : Any]]()
        
            let post = ["postID": postID!, "imageID": randomID, "caption": self.captionField.text ?? "", "username": username!, "day": day, "month": month, "year": year, "hour": hour, "minutes": minutes, "comments": commentDictionary] as [String : Any]
            let postUpdates = ["/posts/\(postID!)": post]
            self.ref.updateChildValues(postUpdates)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onLaunchCamera(_ sender: Any) {
        //let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) { //if camera is available
            print("Camera")
            picker.sourceType = .camera //use camera
        } else {
            print("Library")
            picker.sourceType = .photoLibrary //otherwise, use the photo library
        }
        //print("before")
        present(picker, animated: true, completion: nil)
        //print("after")
    }
    
    @IBAction func onKeyboardDismissal(_ sender: Any) {
        view.endEditing(true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageAspectScaled(toFill: size)
        imageView.image = scaledImage
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

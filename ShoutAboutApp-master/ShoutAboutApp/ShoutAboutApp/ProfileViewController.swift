//
//  ProfileViewController.swift
//  ShoutAboutApp
//
//  Created by VIRENDRA GUPTA on 06/11/16.
//  Copyright © 2016 VIRENDRA GUPTA. All rights reserved.
//

class PersonalProfile:NSObject
{
    var  idInt : Int = 0
    var  name : String = ""
    var  email: String = ""
    var  mobile_number: String = ""
    var  created_at: String = ""
    var  updated_at: String = ""
    var  dob : String = ""
    var  address: String = ""
    var  website: String = ""
    var  photo: String = ""
    var  gcm_token: String = ""
    var  last_online_time: String = ""
    var  rating_average  = [AnyObject]()
    var  review_count = [AnyObject]()
}

//MARK: PROFILE MANAGER
class ProfileManager:NSObject
{
    static let sharedInstance = ProfileManager()
    var personalProfile:SearchPerson = SearchPerson()
    var localStoredImage:UIImage?
    var syncedContactArray = [SearchPerson]()
    var alert_count:Int = 0
}

protocol ProfileViewControllerDelegate
{
    func profileDismissied()
}

import UIKit
import MobileCoreServices
import AVFoundation

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropperViewControllerDelegate, UITextFieldDelegate, EditProfileTableViewCellProtocol , UIPickerViewDataSource, UIPickerViewDelegate
{
    
    var selectedImages:UIImage?
    var personalProfile:SearchPerson = SearchPerson()
        {
        didSet
        {
            
            print("profile has been changed")
            self.tableView?.reloadData()
            
        }
    
    } //= SearchPerson()// since profile is vary from user to user
    
    
    var isToGetPersonData:Bool?
        {
        didSet
        {
            self.getProfileData()
        }
    }
    
    var delegate:ProfileViewControllerDelegate?
    
    @IBOutlet weak var callChatBaseView:UIView!
    @IBOutlet weak var favoriteBlockSpamConstraints:NSLayoutConstraint!
    
    @IBOutlet weak var reviewButton:UIButton?
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var cameraButton: UIButton?
    @IBOutlet weak var imageView:UIImageView?
    
    @IBOutlet weak var nameTextField:UITextField?
    @IBOutlet weak var locationButton:UIButton?
    @IBOutlet weak var editButton:UIButton?
    
    var pickOption = ["Male", "Female"]
    
    
    var activeTextField:UITextField?
    var name:String = ""
    var email:String = ""
    var address:String = ""
    //var website:String = ""
    var birthday:String = ""
    var gender:String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        //self.navigationController?.navigationBar.tintColor = appColor
        
        //imageView!.makeImageRounded()
       // setBackIndicatorImage()
        
        self.automaticallyAdjustsScrollViewInsets = false
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(self.preview))
        tapGesture.numberOfTapsRequired = 1
        if let _ = imageView
        {
            imageView!.addGestureRecognizer(tapGesture)
        }
        
        self.name = personalProfile.name
        
        if let _ = personalProfile.email
        {
            self.email    = personalProfile.email!
        }
        if let _ = personalProfile.address
        {
            self.address  = personalProfile.address!
        }
        if let _ = personalProfile.birthday
        {
            self.birthday  = personalProfile.birthday!
        }
        if let _ = personalProfile.gender
        {
            self.gender  = personalProfile.gender!
        }

        if let photo  = personalProfile.photo
        {
            setProfileImgeForURL(photo)
        }
        /*
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.showKeyBoard(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.hideKeyBoard(_:)), name: UIKeyboardWillHideNotification, object: nil)
            
        */
    }
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        /*
        if personalProfile.idString == ProfileManager.sharedInstance.personalProfile.idString
        {
            self.favoriteBlockSpamConstraints.constant = 0
            self.callChatBaseView.hidden = true
            self.cameraButton!.hidden    = false
            self.callChatBaseView.hidden = true
           
        }else
        {
            self.callChatBaseView.hidden = false
            self.cameraButton!.hidden     = false
            self.cameraButton!.hidden     = true
            self.favoriteBlockSpamConstraints.constant = 30
        }
 
        
        if personalProfile.idString != ProfileManager.sharedInstance.personalProfile.idString
        {
            editButton!.hidden = true
        }
 */
        if let photo  = personalProfile.photo
        {
            setProfileImgeForURL(photo)
        }
        //self.navigationController?.navigationBar.hidden = false
    }
    

    
}

extension ProfileViewController
{
    @IBAction func goToReviewScreen(_ sender:UIButton)
    {
        let rateANdReviewViewController = self.storyboard?.instantiateViewController(withIdentifier: "RateANdReviewViewController") as? RateANdReviewViewController
        self.navigationController!.pushViewController(rateANdReviewViewController!, animated: true)
    }
    
}

extension ProfileViewController
{
    
    func setProfileImgeForURL(_ urlString:String)
    {
        if let _ = self.imageView
        {
            if ProfileManager.sharedInstance.localStoredImage != nil
            {
                self.imageView!.image = ProfileManager.sharedInstance.localStoredImage
            }
            
             self.imageView?.sd_setImage(with: URL(string:urlString ), placeholderImage: self.imageView!.image)
            
        
        }
            /*SDWebImageDownloader.sharedDownloader().downloadImageWithURL(NSURL(string:urlString ), options: .ProgressiveDownload, progress: { (recievedSize, expectedSize) in
            
            }, completed: { (image, data, error, finished) in
              
               
                if image != nil && finished == true
                {
                    
                    let documents   = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                    let url = NSURL(string:urlString )
                   
                    let writePath = documents.stringByAppendingPathComponent((url?.lastPathComponent)!)
                    
                    do
                    {
                    
                     try data.writeToFile(writePath, options: .AtomicWrite)
                    }catch
                    {
                        
                    }
                    
                }
                
                
          })*/
        
    }
}

extension ProfileViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 6
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileTableViewCell", for: indexPath) as! EditProfileTableViewCell
        
        cell.delegate = self
        cell.dataTextField.delegate = self
        
        if personalProfile.idString != ProfileManager.sharedInstance.personalProfile.idString
        {
           //cell.editButton.hidden = true
            cell.isUserInteractionEnabled = false
            
        }
        if indexPath.row == 0
        {
            cell.titleLabel.text = "Name"
            cell.dataTextField.text  = personalProfile.name
            //self.email =  cell.dataTextField.text!
            cell.dataTextField.tag = 0
            cell.inputImage.image = UIImage(named: kName)
            
            
        }
        
        if indexPath.row == 1
        {
            cell.titleLabel.text =  "Mobile"
            cell.dataTextField.text  = personalProfile.mobileNumber
            cell.dataTextField.tag   = 1
            cell.inputImage.image = UIImage(named: "mobile")
            cell.isUserInteractionEnabled = false
        }
        
        
        if indexPath.row == 2
        {
            cell.titleLabel.text = "Email"
            cell.dataTextField.text  = personalProfile.email
            //self.email =  cell.dataTextField.text!
            cell.dataTextField.tag = 2
            cell.inputImage.image = UIImage(named: kEmail)
            
            
        }
        
        
        
        if indexPath.row == 3
        {
            cell.titleLabel.text = "Address"
            cell.dataTextField.text  = personalProfile.address
           // self.address = cell.dataTextField.text!
            cell.dataTextField.tag   = 3
            cell.inputImage.image = UIImage(named: kAddress)
            
        }
        if indexPath.row == 4
        {
            cell.titleLabel.text = kBirthDay
            cell.dataTextField.text  = personalProfile.birthday
            //self.website = cell.dataTextField.text!
            cell.dataTextField.tag   = 4
            cell.inputImage.image = UIImage(named: kBirthDay)
            
            
            let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: cell.dataTextField.frame.size.width, height: 44))
            
            var items = [UIBarButtonItem]()
            
            let  flexibleSpaceLeft = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            
            let doneButton =     UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(JoinViewController.dissMissKeyBoard(_:)))
            
            items.append(flexibleSpaceLeft)
            items.append(doneButton)
            toolBar.items = items
            
            
            
            let datePicker = UIDatePicker()
            datePicker.maximumDate = Date()
            datePicker.addTarget(self, action: #selector(JoinViewController.handleDatePicker(_:)), for: .valueChanged)
            datePicker.datePickerMode = .date
            cell.dataTextField.inputView = datePicker
            cell.dataTextField.inputAccessoryView = toolBar
            
            
        }
        if indexPath.row == 5
        {
            cell.titleLabel.text = kGender
            cell.dataTextField.text  = personalProfile.gender
            cell.dataTextField.tag   = 5
            cell.inputImage.image = UIImage(named: kGender)
            
            let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: cell.dataTextField.frame.size.width, height: 44))
            
            var items = [UIBarButtonItem]()
            
            let  flexibleSpaceLeft = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            
            let doneButton =     UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(JoinViewController.dissMissKeyBoard(_:)))
            
            items.append(flexibleSpaceLeft)
            items.append(doneButton)
            toolBar.items = items
            
            
            
            let pickerView = UIPickerView()
            pickerView.delegate = self
            
            
            cell.dataTextField.inputView = pickerView
            cell.dataTextField.inputAccessoryView = toolBar
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60
    }
    
    
    
    func handleDatePicker(_ sender: UIDatePicker)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        self.activeTextField?.text = dateFormatter.string(from: sender.date)
        self.birthday = (self.activeTextField?.text)!
        
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        self.activeTextField?.text = pickOption[row]
    }
    
    func dissMissKeyBoard(_ sender:UIBarButtonItem)
    {
        if let datePicker =  self.activeTextField?.inputView as? UIDatePicker
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            self.activeTextField?.text = dateFormatter.string(from: datePicker.date)
            self.birthday = (self.activeTextField?.text)!
        }
        
        if let picker = self.activeTextField?.inputView as? UIPickerView
        {
            
            self.activeTextField?.text = pickOption[ picker.selectedRow(inComponent: 0)]
            self.gender = (self.activeTextField?.text)!
            
        }
        self.activeTextField?.resignFirstResponder()
        
    }

    
    func getTextForCell(_ text: String, cell: EditProfileTableViewCell)
    {
        if cell.dataTextField.tag == 0
        {
            self.name = text
        }
        if cell.dataTextField.tag == 1
        {
           self.email = text
        }
        if cell.dataTextField.tag == 2
        {
        
        }
        if cell.dataTextField.tag == 3
        {
            self.address = text
            
        }
        if cell.dataTextField.tag == 5
        {
            self.birthday = text
        }
        if cell.dataTextField.tag == 6
        {
            self.gender = text
        }
    }
    func editButtonClickedForCell(_ cell:EditProfileTableViewCell)
    {
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        self.activeTextField = textField
    }
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func showKeyBoard(_ notification: Notification)
    {
        if ((activeTextField?.superview?.superview?.superview!.isKind(of: EditProfileTableViewCell.self)) != nil)
        {
            if let cell = activeTextField?.superview?.superview?.superview as? EditProfileTableViewCell
            {
                let dictInfo: NSDictionary = notification.userInfo! as NSDictionary
                let kbSize :CGSize = ((dictInfo.object(forKey: UIKeyboardFrameBeginUserInfoKey) as AnyObject).cgRectValue.size)
                let contentInsets:UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
                self.tableView!.contentInset = contentInsets
                self.tableView!.scrollIndicatorInsets = contentInsets
                self.tableView!.scrollToRow(at: self.tableView!.indexPath(for: cell)!, at: .top, animated: true)
            }
        }
    }
    
    
    func hideKeyBoard(_ notification: Notification)
    {
        
        if  activeTextField != nil
        {
            let contentInsets:UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.tableView!.contentInset = contentInsets
            self.tableView!.scrollIndicatorInsets = contentInsets
        }
    }

    
    
    func postData(_ dict:[String:String])
    {
        activeTextField?.resignFirstResponder()
        self.view.showSpinner()
        DataSessionManger.sharedInstance.updateProfile(dict, onFinish: { (response, deserializedResponse) in
            
            DispatchQueue.main.async(execute: {
                    self.view.removeSpinner()
                })
            if deserializedResponse is NSDictionary
            {
                if deserializedResponse.object(forKey: "success") != nil
                {
                    DispatchQueue.main.async(execute: {
                        //self.view.removeSpinner()
                        
                        self.getProfileData()
                        
                        //self.displayAlertMessage("Success")
                    });
                }
                 if  let dict = deserializedResponse.object(forKey: "validation_error") as? NSDictionary
                {
                    let keys = dict.allKeys
                    if  let errorMessage = dict.object(forKey: keys.first!) as? String
                    {
                        self.displayAlertMessage(errorMessage)
                    }
                    
                }
                
            }
        }) { (error) in
            DispatchQueue.main.async(execute: {
                self.view.removeSpinner()
                self.displayAlertMessage(error as! String)
            });
        }
    }
}

extension ProfileViewController
{
    @IBAction func cameraButtonClicked(_ sender:UIButton)
    {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet) // 1
        let firstAction = UIAlertAction(title: "Take Photo", style: .default) { (alert: UIAlertAction!) -> Void in
            NSLog("You pressed button one")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
            {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
            
        } // 2
        
        let secondAction = UIAlertAction(title: "Choose Photo", style: .default) { (alert: UIAlertAction!) -> Void in
            NSLog("You pressed button two")
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true,
                                       completion: nil)
        } // 3
        
        let thirdAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) -> Void in
            NSLog("You pressed button two")
        } // 3
        
        alert.addAction(firstAction) // 4
        alert.addAction(secondAction) // 5
        alert.addAction(thirdAction) // 5
        present(alert, animated: true, completion:nil) // 6
    }
    
    /*
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        if mediaType == "public.image"
        {
            // For Image
            let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            selectedImages = selectedImage
            picker.dismissViewControllerAnimated(true, completion: nil)
            // self.delegate?.imageFileSelected(selectedImage)
            imageView.image = selectedImages
            self.imageFileSelected(selectedImages!)
        }
        
    }
    */
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let storyboard = UIStoryboard(name: "Crop", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "cropper-vc") as! CropperViewController
            vc._image = pickedImage
            vc.delegate = self
            
            picker.pushViewController(vc, animated: true)
        }
    }

    
    
    func imageFileSelected(_ selectedImage: UIImage)
    {
        
        ProfileManager.sharedInstance.localStoredImage = selectedImage
        let currentTime = Date().timeIntervalSince1970 as TimeInterval
        let extensionPathStr = "profile\(currentTime).jpg"
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let fullPathToFile = "\(documentsDirectory)/\(extensionPathStr)"
        
        print(fullPathToFile)
        
        let imageData: Data = UIImageJPEGRepresentation(selectedImage, 0.5)!
        
        
        
        try? imageData.write(to: URL(fileURLWithPath: fullPathToFile), options: [.atomic])
        
        let imagePath =  [ "photo"]
        
        let mediaPathArray = [fullPathToFile]
        
        if NetworkConnectivity.isConnectedToNetwork() != true
        {
            
        }else
        {
           self.view.showSpinner()
            DataSessionManger.sharedInstance.postProfileImage(mediaPathArray, name: imagePath, onFinish: { (response, deserializedResponse) in
                DispatchQueue.main.async(execute: {
                    self.view.removeSpinner()
                    //self.displayAlert("Success", handler: self.handler)
                    
                });
                
                }) { (error) in
                    DispatchQueue.main.async(execute: {
                        self.view.removeSpinner()
                        
                        
                    });
            }
        }
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
    

    
    
}


public extension UIView
{
    /// Extension to make a view rounded // need to move in a different file
    func makeImageRounded()
    {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.white.cgColor
    }
    
    func makeImageRoundedWithWidth(_ widthFloat:CGFloat, color:UIColor)
    {
        /*
        
        self.clipsToBounds = true
        
       
        self.layer.shadowColor = color.CGColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset  = CGSize(width: 2, height: 2)
 
        
        
        
        self.layer.shadowColor = color.CGColor
        self.layer.shadowOpacity = 1.0
        //self.layer.shadowRadius = 3.0
       self.layer.shadowOffset = CGSizeMake(1.0, 1.0)
        self.layer.masksToBounds = false
 */
        self.clipsToBounds = true
        self.layer.borderColor =  UIColor.lightGray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.shadowColor   = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius  = 3.0
        self.layer.shadowOffset  = CGSize(width: 1.0, height: 1.0)
        self.layer.masksToBounds = true
    }
    
    func makeImageRoundedWithGray()
    {
        makeImageRoundedWithWidth(3.0, color: UIColor.gray)
    }
    
    
    func makeBorder()
    {
        self.layer.cornerRadius = 3.0
        self.clipsToBounds     = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.black.cgColor
        
    }
}

extension MainSearchViewController
{
    // MARK: GET DATA
    func  getProfileData()
    {
        self.view.showSpinner()
        DataSessionManger.sharedInstance.getProfileData("",onFinish: { (response, personalProfile) in
            
            DispatchQueue.main.async(execute: {
                self.view.removeSpinner()
                
                ProfileManager.sharedInstance.personalProfile = personalProfile
                
        });
            
        }) { (error) in
            
            DispatchQueue.main.async(execute: {
                self.view.removeSpinner()
                
                
            });
            
        }
    }
}


extension ProfileViewController
{
    func croppedImage(_ image: UIImage, vc:UIViewController)
    {
        vc.dismiss(animated: true, completion: nil)
        imageView!.image = image

        ProfileManager.sharedInstance.localStoredImage = image
        let currentTime = Date().timeIntervalSince1970 as TimeInterval
        let extensionPathStr = "profile\(currentTime).jpg"
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let fullPathToFile = "\(documentsDirectory)/\(extensionPathStr)"

        print(fullPathToFile)

        let imageData: Data = UIImageJPEGRepresentation(image, 0.5)!



        try? imageData.write(to: URL(fileURLWithPath: fullPathToFile), options: [.atomic])

        let imagePath =  [ "photo"]

        let mediaPathArray = [fullPathToFile]

        if NetworkConnectivity.isConnectedToNetwork() != true
        {

        }else
        {
            self.view.showSpinner()
            DataSessionManger.sharedInstance.postProfileImage(mediaPathArray, name: imagePath, onFinish: { (response, deserializedResponse) in
            DispatchQueue.main.async(execute: {
            self.view.removeSpinner()
            //self.displayAlert("Success", handler: self.handler)
                self.getProfileData()

            });

            }) { (error) in
            DispatchQueue.main.async(execute: {
            self.view.removeSpinner()


            });
          }
        }
    }
    // MARK: GET DATA
    func  getProfileData()
    {
        self.view.showSpinner()
        
        DataSessionManger.sharedInstance.getProfileData(String(personalProfile.idString),onFinish: { (response, personalProfile) in
            
            DispatchQueue.main.async(execute: {
                self.view.removeSpinner()
                
                if personalProfile.idString == ProfileManager.sharedInstance.personalProfile.idString ||  ProfileManager.sharedInstance.personalProfile.idString == 0
                {
                    ProfileManager.sharedInstance.personalProfile = personalProfile
                    self.personalProfile = ProfileManager.sharedInstance.personalProfile
                }else
                {
                    self.personalProfile = personalProfile
                    
                }
                if let photo  = self.personalProfile.photo
                {
                    self.setProfileImgeForURL(photo)
                }
                
                if self.isKind(of: JoinViewController.self) || self.isKind(of: NewProfileViewController.self)
                {
                    self.personalProfile = personalProfile
                    self.delegate?.profileDismissied()

                }
                else
                {
                    self.dismiss(animated: true)
                    {
                        self.delegate?.profileDismissied()
                    }
                }
                
                
            });
            
        }) { (error) in
            
            DispatchQueue.main.async(execute: {
                self.view.removeSpinner()
                
                
            });
            
        }
    }
}
extension ProfileViewController:UIDocumentInteractionControllerDelegate
{
    @IBAction func preview()
    {
        if let _ = personalProfile.photo
        {
            showFile(personalProfile.photo!)
        }
        
    }
    
    func showFile(_ urlString:String)
    {
        
        let documents   = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let url = URL(string:urlString )
        
        let writePath = documents.stringByAppendingPathComponent((url?.lastPathComponent)!)
        
        
        let documentURL = URL(fileURLWithPath: writePath)

        let pdfViewer:UIDocumentInteractionController = UIDocumentInteractionController(url: documentURL)
        pdfViewer.delegate = self
        pdfViewer.presentPreview(animated: true)
        
    
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController
    {
        return self
        
    }
}

extension ProfileViewController
{
    
    @IBAction func favoriteButtonClicked(_ sender:UIButton)
    {
        self.view.showSpinner()
        DataSessionManger.sharedInstance.favouriteUserID(String(personalProfile.idString), onFinish: { (response, deserializedResponse) in
            DispatchQueue.main.async(execute: {
                self.view.removeSpinner()
                
                
            });
            }) { (error) in
                DispatchQueue.main.async(execute: {
                    self.view.removeSpinner()
                    
            });
        }
    }
    
    @IBAction func blockButtonClicked(_ sender:UIButton)
    {
        self.view.showSpinner()
       DataSessionManger.sharedInstance.blockUserID(String(personalProfile.idString), onFinish:
        { (response, deserializedResponse) in
        
            DispatchQueue.main.async(execute: {
                self.view.removeSpinner()
                
                
            });
        }) { (error) in
            DispatchQueue.main.async(execute: {
                self.view.removeSpinner()
                
                
            });
        }
        
    }
    
    @IBAction func spamButtonClicked(_ sender:UIButton)
    {
        self.view.showSpinner()
        DataSessionManger.sharedInstance.spamUserID(String(personalProfile.idString), onFinish: { (response, deserializedResponse) in
            
            DispatchQueue.main.async(execute: {
                self.view.removeSpinner()
                
                
            });
            }) { (error) in
                
                DispatchQueue.main.async(execute: {
                    self.view.removeSpinner()
                });
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender:UIButton)
    {
        self.dismiss(animated: true)
        {
             
        }
    }
    
    @IBAction func submitButtonClicked(_ sender:UIButton)
    {
        print(" email:\(self.email), name:\(self.name),  web:\(self.birthday ), address:f \(self.address) ")
            
            if self.name.characters.count == 0
            {
                self.displayAlertMessage("Please enter name")
                
            }
            /*
            else if self.email.characters.count == 0
            {
                self.displayAlertMessage("Please enter email")
            }
            else if self.address.characters.count == 0
            {
                self.displayAlertMessage("Please enter address")
                
            }else if self.birthday.characters.count == 0
            {
                self.displayAlertMessage("Please enter birthday")
                
            }*/
            else if self.gender.characters.count == 0
            {
                self.displayAlertMessage("Please enter gender")
                
            }
            else
            {
                let appUserId = UserDefaults.standard.object(forKey: kapp_user_id) as! Int
                let appUserToken = UserDefaults.standard.object(forKey: kapp_user_token) as! String
                
                let dict = ["name":self.name, "email":self.email, "dob":self.birthday, "gender":self.gender, "address":self.address, kapp_user_id:String(appUserId), kapp_user_token :appUserToken, "notify_token":"text"]
                postData(dict)
            }
        }
    
}

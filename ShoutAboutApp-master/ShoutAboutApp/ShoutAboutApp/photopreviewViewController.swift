

import UIKit

class photopreviewViewController: UIViewController {

    @IBOutlet weak var previewImg: UIImageView!

    var picname:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(picname)

        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: picname!)!, completionHandler: { (data, response, error) -> Void in
//            self.view.showSpinner()
            if error != nil {
                print(error)
                return
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let image = UIImage(data: data!)
                self.previewImg.image = image
//                self.view.removeSpinner()
            })
            
        }).resume()
        
//        previewImg.imageFromServerURL(picname!)
        
        self.navigationItem.title = "Preview"
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor();
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnPreviewClose(sender: AnyObject)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    

}



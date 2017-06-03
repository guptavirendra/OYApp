

import UIKit

class photopreviewViewController: UIViewController {

    @IBOutlet weak var previewImg: UIImageView!

    var picname:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(picname)

        URLSession.shared.dataTask(with: URL(string: picname!)!, completionHandler: { (data, response, error) -> Void in
//            self.view.showSpinner()
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.previewImg.image = image
//                self.view.removeSpinner()
            })
            
        }).resume()
        
//        previewImg.imageFromServerURL(picname!)
        
        self.navigationItem.title = "Preview"
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        self.navigationController!.navigationBar.tintColor = UIColor.white;
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnPreviewClose(_ sender: AnyObject)
    {
        self.navigationController?.popViewController(animated: true)
    }
    

}



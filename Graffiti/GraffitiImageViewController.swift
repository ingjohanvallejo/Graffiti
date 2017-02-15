//
//  GraffitiImageViewController.swift
//  Graffiti
//
//  Created by Johan Vallejo on 14/12/16.
//  Copyright © 2016 kijho. All rights reserved.
//

import UIKit

class GraffitiImageViewController: UIViewController {

    @IBOutlet var imgGraffiti: UIImageView!

    var selectedCallout : UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let image = #imageLiteral(resourceName: "img_navbar_title")
        self.navigationItem.titleView = UIImageView(image: image)
        if let selectedCallout = selectedCallout {
            imgGraffiti.image = selectedCallout
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnClosePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

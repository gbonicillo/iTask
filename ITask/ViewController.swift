//
//  ViewController.swift
//

import UIKit
import TwitterKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


        
        setupTwitterButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.isNavigationBarHidden = true

    }
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    
    fileprivate func setupTwitterButton(){
        let twitterButton = TWTRLogInButton { (session, error) in
            if let err = error {
                print ("Failed to login via Twitter : ", err)
                return
            }
            print ("Successfully logged in via Twitter")
            self.performSegue(withIdentifier: "LoginToSegue", sender: self)

        }
        
        view.addSubview(twitterButton)
        twitterButton.frame = CGRect (x: 16, y: 166+66+66+66+66+66+66, width: view.frame.width-32 , height: 50)
        

    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


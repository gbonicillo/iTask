//
//  ViewController.swift
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import TwitterKit

import LocalAuthentication


fileprivate enum Defaults {
    static let buttonTopAnchor: CGFloat = 66.0
    static let buttonLeadingAnchor: CGFloat = 32.0
    static let buttonTrailingAnchor: CGFloat = 32.0
    static let facebookLoginButtonHeight: CGFloat = 40.0
}


class ViewController: UIViewController {
    
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    
    
    @IBAction func login(_ sender: Any) {
        
        let usernameText : String = username.text!
        let passwordText : String = password.text!
        
        
        if (UserDefaults.standard.object(forKey: "username") != nil) {
            if(usernameText == UserDefaults.standard.object(forKey: "username") as? String){
                if(passwordText == UserDefaults.standard.object(forKey: "password") as? String ){
                    self.performSegue(withIdentifier: "LoginToSegue", sender: self)
                } else {
                    print ("Password does not match")
                }
            } else {
                print("Username does not match")
            }
        } else {
            //Logging in as a new user
           UserDefaults.standard.set(usernameText, forKey: "username") //setObject
           UserDefaults.standard.set(passwordText, forKey: "password") //setObject
           self.performSegue(withIdentifier: "LoginToSegue", sender: self)
        }
    }
    
    
    @IBAction func action(_ sender: Any) {
        
        let context:LAContext = LAContext()
        
        if(context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error:nil)) {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Login with your touch id", reply: { (wasSuccessful, error) in
                if wasSuccessful {
                    print ("Touch id Login Successful")
                    self.performSegue(withIdentifier: "LoginToSegue", sender: self)
                } else {
                    print ("Not Logged in")
                }
            })
        }
        
    }
    
    
    fileprivate let fbLoginButton = FBSDKLoginButton()
    fileprivate let googleSignInButton = GIDSignInButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        initialUISetups()
        //setupTwitterButton()
    }
    
    // MARK: - Initial UI Setups
    fileprivate func initialUISetups() {
        
        //setupTwitterButton()
        
        facebookButtonSetup()
        googleButtonSetup()
        twitterButtonSetup()
    
    }
    
    // MARK: Facebook Sign In Button Setup
    
    fileprivate func facebookButtonSetup() {
        // Facebook Login Button Setups
        view.addSubview(fbLoginButton)
        fbLoginButton.delegate = self
        fetchUserProfileData()
        if let facebookButtonHeightConstraint = fbLoginButton.constraints.first(where: { $0.firstAttribute == .height }) {
            fbLoginButton.removeConstraint(facebookButtonHeightConstraint)
        }
        // Add Constraints to fb login button
        fbLoginButton.translatesAutoresizingMaskIntoConstraints = false
        fbLoginButton.topAnchor.constraint(equalTo: view.topAnchor, constant: Defaults.buttonTopAnchor).isActive = true
        fbLoginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Defaults.buttonLeadingAnchor).isActive = true
        fbLoginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Defaults.buttonTrailingAnchor).isActive = true
        fbLoginButton.heightAnchor.constraint(equalToConstant: Defaults.facebookLoginButtonHeight).isActive = true
    }
    
    // MARK: Google Sign In Button Setup
    
    fileprivate func googleButtonSetup() {
        // Google Sign In Button Setups
        view.addSubview(googleSignInButton)
        googleSignInButton.style = .wide
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        // Add Constraints to Google Sign In Button
        googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        googleSignInButton.topAnchor.constraint(equalTo: fbLoginButton.topAnchor, constant: Defaults.buttonTopAnchor).isActive = true
        googleSignInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Defaults.buttonLeadingAnchor).isActive = true
        googleSignInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Defaults.buttonTrailingAnchor).isActive = true
    }
    
    // MARK: Twitter Sign In Button Setup
    
    fileprivate func twitterButtonSetup() {
        // Twitter Login Button
        let twitterLoginButton = TWTRLogInButton(logInCompletion: { session, error in
            if (session != nil) {
                debugPrint("signed in as \(session?.userName)")
                self.performSegue(withIdentifier: "LoginToSegue", sender: self)
            } else {
                print("error: \(error?.localizedDescription)")
            }
            
            //if let err = error {
               // print ("Failed to login via Twitter : ", err)
               // return
           // }
            //print ("Successfully logged in via Twitter")
           // self.performSegue(withIdentifier: "LoginToSegue", sender: self)
        })
        view.addSubview(twitterLoginButton)
        // Add Constraints to Twitter Sign In Button
        twitterLoginButton.translatesAutoresizingMaskIntoConstraints = false
        twitterLoginButton.topAnchor.constraint(equalTo: googleSignInButton.topAnchor, constant: Defaults.buttonTopAnchor).isActive = true
        twitterLoginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Defaults.buttonLeadingAnchor).isActive = true
        twitterLoginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Defaults.buttonTrailingAnchor).isActive = true
    }
    
    // Fetch User's Public Facebook Profile Data
    fileprivate func fetchUserProfileData() {
        let params = ["fields": "email, first_name, last_name, picture"]
        FBSDKGraphRequest(graphPath: "me", parameters: params).start(completionHandler: { connection, result, error in
            print(result.debugDescription)
        })
    }
    
    // Basic Alert View
    fileprivate func showAlert(withTitle title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
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


// MARK: - Facebook SDK Button Delegates

extension ViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            showAlert(withTitle: "Error", message: "Something went wrong. Please try again!")
        } else if result.isCancelled {
            
        } else {
            showAlert(withTitle: "Success", message: "Successfully Logged in")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        showAlert(withTitle: "Success", message: "Successfully Logged out")
    }
}

// MARK: - Google Sign In Delgates

extension ViewController: GIDSignInUIDelegate {
    
}

extension ViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        showAlert(withTitle: "Success", message: "Successfully Logged in \(user.userID)")
    }
    
    
}

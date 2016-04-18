//
//  WLLoginChallengeHandler.swift
//  UserLoginSample
//
//  Created by Ishai Borovoy on 17/04/2015.
//  Copyright © 2015 IBM. All rights reserved.
//

import Foundation
import IBMMobileFirstPlatformFoundation

public class LTPAChallengeHandler : WLChallengeHandler {
    
    //The login view controller
    var loginViewController : LoginViewController?
    var loginURL : String?
    var isInChallenge = false;
    
    override init!(securityCheck: String!) {
        super.init(securityCheck: securityCheck)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        loginViewController = mainStoryboard.instantiateViewControllerWithIdentifier("userLogin") as? LoginViewController
    }
    
    //Handle the LTPA challenge handler
    override public func handleChallenge(challenge: [NSObject : AnyObject]!) {
        self.loginURL = challenge["loginURL"] as? String
        let navigationController = UIApplication.sharedApplication().delegate?.window!?.rootViewController as! UINavigationController
        if (isInChallenge) {
            self.loginViewController?.setErrorMsg("Wrong credentials")
        } else {
            navigationController.pushViewController(self.loginViewController!, animated: true)
        }
        isInChallenge = true
    }
    
    //Send the credentials to the server
    public func sendLoginForm (user: String, password: String) {
        let request = NSMutableURLRequest(URL: NSURL(string: self.loginURL!)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = String("j_username=\(user)&j_password=\(password)&action=Login").dataUsingEncoding(NSUTF8StringEncoding)
        
        
        //request.addValue("Basic \(user):\(password)", forHTTPHeaderField: "Authurization")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            self.submitChallengeAnswer(nil)
        })
        task.resume()
    }
    

    //Handle failure hook
    public override func handleFailure(failure: [NSObject : AnyObject]!) {
        isInChallenge = false
        loginViewController?.dismiss()
    }
    
    //Handle success hook
    public override func handleSuccess(success: [NSObject : AnyObject]!) {
        isInChallenge = false
        loginViewController?.dismiss()
    }
}

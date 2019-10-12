//
//  LoginViewController.swift
//  SPR
//
//  Created by WY NG on 12/10/2019.
//  Copyright © 2019 natalie. All rights reserved.
//

import UIKit

final class LoginViewController: UIViewController {
    
    @IBOutlet weak var accountTextfield: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    let service: APIService = APIService()
    
    lazy var router: LoginRouter = {
        return LoginRouter(presenter: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
        guard let account = accountTextfield.text?.cleaned, let password = passwordTextField.text?.cleaned, account.count > 0, password.count > 0 else {
            return
        }
        
        service.doLogin(account: account, password: password) { [weak self] loggedIn, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                guard error == nil else {
                    FailAlert.show(msg: error!.localizedDescription){ [weak self] _ in
                        guard let self = self else { return }
                        self.passwordTextField.text = ""
                    }
                    return
                }
                
                
                guard let loggedIn = loggedIn else {
                    FailAlert.show() { [weak self] _ in
                        guard let self = self else { return }
                        self.passwordTextField.text = ""
                    }
                    return
                }
                
                if loggedIn {
                    self.router.toHomePage()
                } else {
                    FailAlert.show() { [weak self] _ in
                        guard let self = self else { return }
                        self.passwordTextField.text = ""
                    }
                }
            }
            
        }
    }
}


extension String {
    var cleaned: String {
        return self.replacingOccurrences(of: "^\\s*|\\s+$", with: "", options: .regularExpression)
    }
}

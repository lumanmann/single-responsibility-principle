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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
        guard let account = accountTextfield.text?.cleaned, let password = passwordTextField.text?.cleaned, account.count > 0, password.count > 0 else {
            return
        }
        
        
        let urlString: String = "https://localhost:3000/login"
        let parameters: [String: String] = ["account": account, "password": password]
        
        guard let url = URL(string: urlString) else {
            popFailAlert()
            return
        }
        
        var request: URLRequest = URLRequest(url: url)
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions())
        } catch {
            popFailAlert()
        }
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                guard error == nil else {
                    self.popFailAlert(msg: error!.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    self.popFailAlert()
                    return
                }
                
                guard let result = try? JSONDecoder().decode(LoginResponseModel.self, from: data) else {
                    self.popFailAlert()
                    return
                }
                
                if result.result ?? false {
                    DispatchQueue.main.async {
                        let vc: HomeViewController = HomeViewController()
                        self.present(vc, animated: true, completion: nil)
                    }
                } else {
                    self.popFailAlert()
                }
            }
        }
        task.resume()
        
    }
    
    
    private func popFailAlert(msg: String = "Please try again") {
        
        let alertController = UIAlertController(title: "Login Fail", message: msg, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.passwordTextField.text = ""
        }
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
}


extension String {
    var cleaned: String {
        return self.replacingOccurrences(of: "^\\s*|\\s+$", with: "", options: .regularExpression)
    }
}

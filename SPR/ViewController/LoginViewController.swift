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
        
        doLogin(account: account, password: password)
        
    }
    
    
    private func doLogin(account: String, password: String) {
        let urlString = "https://localhost:3000/login"
        
        request(urlString: urlString, parameters: ["account": account, "password": password]) { [weak self](data, error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
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
                    self.toHomePage()
                } else {
                    self.popFailAlert()
                }
            }
            
        }
    }
    
    private func toHomePage() {
        let vc = HomeViewController()
        self.present(vc, animated: true, completion: nil)
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
    
    private func request(urlString: String, parameters: [String: Any], completion: @escaping (Data?, Error?) -> Void){
        guard let url = URL(string: urlString) else {
            completion(nil, nil)
            return
        }
        var request = URLRequest(url: url)
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions())
        }catch let error{
            completion(nil, error)
        }
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        fetch(request: request, completion: completion)
    }
    
    private func fetch(request: URLRequest, completion: @escaping (Data?, Error?) -> Void){
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(nil, error!)
                return
            }
            
            guard let data = data else {
                completion(nil, nil)
                return
            }
            
            
            completion(data, nil)
            
            
        }
        task.resume()
    }
    
    
}


extension String {
    var cleaned: String {
        return self.replacingOccurrences(of: "^\\s*|\\s+$", with: "", options: .regularExpression)
    }
}

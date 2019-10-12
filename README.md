# Single Responsibility Principle

This repo is a reworking of a login page using single responsibility principle.

## Demo

![](https://i.imgur.com/8LdkrBd.gif)


## Before

LoginViewController is in charge of presenting view, user interaction, network request, navigation and creating alert.

``` swift
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
```

## After
LoginViewController just handles user interaction.

```swift

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
```

//
//  LoginRouter.swift
//  SPR
//
//  Created by WY NG on 12/10/2019.
//  Copyright © 2019 natalie. All rights reserved.
//

import UIKit

final class LoginRouter {
    private let presenter: UIViewController
    
    init(presenter: UIViewController) {
        self.presenter = presenter
    }
    
    func toHomePage() {
        presenter.present(HomeViewController(), animated: true, completion: nil)
    }
    
}

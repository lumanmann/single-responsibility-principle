//
//  FailAlert.swift
//  SPR
//
//  Created by WY NG on 12/10/2019.
//  Copyright © 2019 natalie. All rights reserved.
//

import Foundation
import UIKit

final class FailAlert {
    
    static func show(msg: String = "Please try again", handler: @escaping ((UIAlertAction) -> Void) = {_ in }) {
        let alertController = UIAlertController(title: "Login Fail", message: msg, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        
        alertController.addAction(okAction)
        
        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
    }
}

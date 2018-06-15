//
//  UIViewControllerExtensions.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 15/06/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import Foundation
import UIKit
import SwiftGRPC

extension UIViewController {
    func showAlert(for callResult: CallResult?, orMessage msg: String? = nil) {
        DispatchQueue.main.async {
            let errMsg = callResult?.statusMessage ?? msg
            let alert = UIAlertController(title: nil, message: errMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "👌", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//
//  Created by Shady
//  All rights reserved.
//  

import UIKit

extension UIViewController{
    func showAlert(title: String = "", message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
}

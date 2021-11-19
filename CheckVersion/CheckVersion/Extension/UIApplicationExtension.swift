//
//  UIApplicationExtension.swift
//  FreewillSphere
//
//  Created by Nopparat on 14/8/2561 BE.
//  Copyright © 2561 Freewill Solutions. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    static func topViewController(_ base: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        
        return base
    }
}

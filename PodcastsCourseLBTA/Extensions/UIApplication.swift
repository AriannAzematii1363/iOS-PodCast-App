//
//  UIApplication.swift
//  PodcastsCourseLBTA
//
//  Created by Arian Azemati on 2018-08-19.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import UIKit

extension UIApplication {
    
    static func mainTabBarController() -> MainTabBarController? {
        
         // let maintabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        
        return shared.keyWindow?.rootViewController as? MainTabBarController
        
    }
    
    
}



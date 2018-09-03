//
//  String.swift
//  PodcastsCourseLBTA
//
//  Created by Arian Azemati on 2018-08-11.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import Foundation

extension String {
    
    
    func toSecureHTTPS() -> String {
        
        return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
    }
}

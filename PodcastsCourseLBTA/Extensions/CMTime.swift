//
//  CMTime.swift
//  PodcastsCourseLBTA
//
//  Created by Arian Azemati on 2018-08-11.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import Foundation
import AVKit

extension CMTime {
    
    func toDisplayString() -> String {
        
        if CMTimeGetSeconds(self).isNaN {
            return "--:--"
        }
        
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = totalSeconds  % 60
        let minutes = totalSeconds % (60 * 60) / 60
       // let minutes = totalSeconds / 60
        let hours = totalSeconds / 60 / 60
        let timeFormatString = String(format: "%02d:%02d:%02d",hours,minutes, seconds)
        return timeFormatString
    }

    
}

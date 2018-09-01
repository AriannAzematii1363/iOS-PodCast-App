//
//  Podcast.swift
//  PodcastsCourseLBTA
//
//  Created by Arian Azemati on 2018-08-09.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import Foundation

class Podcast:NSObject, Decodable, NSCoding {
    func encode(with aCoder: NSCoder) {
        print("trying to transform podcast into data")
        
        aCoder.encode(trackName ?? "", forKey: "trackNameKey")
        aCoder.encode(artistName ?? "", forKey: "artistNameKey")
        aCoder.encode(artworkUrl100 ?? "", forKey: "artworkUrlKey")
         aCoder.encode(feedUrl ?? "", forKey: "feedUrlKey")
    }
    
    required init?(coder aDecoder: NSCoder) {
        print("trying to turn data into Podcast" )
        self.trackName = aDecoder.decodeObject(forKey: "trackNameKey") as? String
        self.artistName = aDecoder.decodeObject(forKey: "artistNameKey") as? String
        self.artworkUrl100 = aDecoder.decodeObject(forKey: "artworkUrlKey") as? String
        self.feedUrl = aDecoder.decodeObject(forKey: "feedUrlKey") as? String
    }
    
    var trackName: String?
    var artistName: String?
    var artworkUrl100:  String?
    var trackCount: Int?
    var feedUrl: String?
}


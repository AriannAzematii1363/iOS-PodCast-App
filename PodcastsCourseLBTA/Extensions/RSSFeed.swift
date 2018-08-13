//
//  RSSFeed.swift
//  PodcastsCourseLBTA
//
//  Created by Arian Azemati on 2018-08-11.
//  Copyright © 2018 Brian Voong. All rights reserved.
//


import FeedKit

extension RSSFeed {
    
    func toEpisodes() -> [Episode] {
        let imageURL = iTunes?.iTunesImage?.attributes?.href
        
        var episodes = [Episode]()
        items?.forEach({ (feedItem) in
            var episode = Episode(feedItem: feedItem)
            
            if episode.imageUrl == nil {
                episode.imageUrl = imageURL
            }
            episodes.append(episode)
        })
        
        return episodes
    }
    
}

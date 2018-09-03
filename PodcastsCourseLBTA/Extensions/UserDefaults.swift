//
//  UserDefaults.swift
//  PodcastsCourseLBTA
//
//  Created by Arian Azemati on 2018-08-31.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static let favoritedPodcastKey = "favoritedPodcastKey"
    static let downloadedEpisodesKey = "downloadedEpisodesKey"
    
    func deleteEpisode(episode: Episode) {
        let savedEpisode = downloadedEpisode()
        let filteredEpisodes = savedEpisode.filter { (ep) -> Bool in
            return ep.title != episode.title && ep.author != episode.author
        }
        do{
           let data = try JSONEncoder().encode(filteredEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
            
        }catch let encodeErr {
            print("failed to encode episode", encodeErr)
        }
        
        
    }
    
    
    
    func downloadEpisode(episode : Episode) {
        do {
            var downloadedEpisodes = downloadedEpisode()
            downloadedEpisodes.insert(episode, at: 0)
             let data =  try JSONEncoder().encode(downloadedEpisodes)
             UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
        } catch let encodeErr {
            print("Failed to encode epidoe", encodeErr)
        }
       
    }
    
    func downloadedEpisode() -> [Episode] {
        guard let episodeData = data(forKey: UserDefaults.downloadedEpisodesKey) else { return [] }
        do {
            let episodes = try JSONDecoder().decode([Episode].self, from: episodeData)
            return episodes
        }catch let decodeErr {
            print("faelied to decode",decodeErr)
        }
        
        return []
    }
    
    
    func savedPodcasts() -> [Podcast] {
        guard let savedPodcastData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else {return []}
        
        guard let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: savedPodcastData) as? [Podcast] else {return []}
        
        return savedPodcasts
    }
    
    
    func deletePodcast(podcast: Podcast) {
        let podcasts = savedPodcasts()
        let filteredPodcasts = podcasts.filter { (p) -> Bool in
            return p.trackName != podcast.trackName && p.artistName != podcast.artistName
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: filteredPodcasts)
        UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
    }
}

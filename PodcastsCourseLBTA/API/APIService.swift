//
//  APIService.swift
//  PodcastsCourseLBTA
//
//  Created by Arian Azemati on 2018-08-09.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

extension Notification.Name {
    static let downloadProgress = NSNotification.Name("downloadProgress")
    static let downloadComplete = NSNotification.Name("downloadComplete")
}

class APIService {
    
    
    typealias EpisodeDownloadCompleteTuple = (fileUrl: String, episodeTitle: String)
    
    let baseiTunesSearchURL = "https://itunes.apple.com/search"
    //singleton
    
    static let shared = APIService()
    
    
    func downloadEpisode(episode: Episode) {
        print("Downloading episode using Alamofire at stream url:", episode.streamUrl)
       let downloadRequest = DownloadRequest.suggestedDownloadDestination()
        
        Alamofire.download(episode.streamUrl, to: downloadRequest).downloadProgress { (progress) in
            print(progress.fractionCompleted)
            // I want to notify DownloadController about my download progress somehow
            
            
            NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title": episode.title, "progress": progress.fractionCompleted])
            }.response { (resp) in
                print(resp.destinationURL?.absoluteString ?? "")
              
                //I want to update UserDefaults downloaded episodes with this temp file somehow
                
                let episodeDownloadComplete = EpisodeDownloadCompleteTuple(fileUrl:resp.destinationURL?.absoluteString ?? "",episode.title)
                
                NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadComplete, userInfo: nil)
                
                var downloadedEpisodes = UserDefaults.standard.downloadedEpisode()
                
                guard let index = downloadedEpisodes.index(where: {$0.title == episode.title && $0.author == episode.author}) else {return}
                downloadedEpisodes[index].fileUrl = resp.destinationURL?.absoluteString ?? ""
                
                do {
                    let data = try JSONEncoder().encode(downloadedEpisodes)
                    UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
                }catch let err {
                    print("Failed to encode downloaded episode with file url update",err)
                }
                
        }
    }
    
    
    func fetchEpisodes(feedUrl: String,completionHandler: @escaping ([Episode]) -> ()) {
        
        let secureFeedURL = feedUrl.contains("https") ? feedUrl : feedUrl.replacingOccurrences(of: "http", with: "https")
        guard let url = URL(string: secureFeedURL) else {return}
        
        DispatchQueue.global(qos: .background).async {
            
            print("Before Parser")
            let parser = FeedParser(URL: url)
            print("after Parser")
            parser?.parseAsync(result: { (result) in
                print("Successfully parsed feed:", result.isSuccess)
                
                
                if let err = result.error {
                    print("Failed to parse XML feed:", err)
                    return
                }
                guard let feed = result.rssFeed else {return}
                let episodes = feed.toEpisodes()
                completionHandler(episodes )
            })
        }
        
      
    }
    
    
    
    
    
    func fetchPodCasts(searchText: String, completionHandler: @escaping ([Podcast]) -> ()) {
        print("serching for podcasr:...")
        
        let parameters = ["term": searchText,"media": "podcast"]
        
        Alamofire.request(baseiTunesSearchURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
            if let err = dataResponse.error {
                print("failed to contact yahoo", err)
                return
            }
            guard let data =  dataResponse.data else {return}
            
            do {
                let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
            
//                self.podcasts = searchResult.results
//                self.tableView.reloadData()
                print(searchResult.resultCount)
                completionHandler(searchResult.results)
            }catch let decodeErr {
                print("failed to decode",decodeErr)
            }
        }
    
    }
    
    struct SearchResults: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }

}

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

class APIService {
    
    
    let baseiTunesSearchURL = "https://itunes.apple.com/search"
    //singleton
    
    static let shared = APIService()
    
    
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

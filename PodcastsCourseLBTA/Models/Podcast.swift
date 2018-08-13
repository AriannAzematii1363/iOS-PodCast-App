//
//  Podcast.swift
//  PodcastsCourseLBTA
//
//  Created by Arian Azemati on 2018-08-09.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import Foundation

struct Podcast:Decodable {
    var trackName: String?
    var artistName: String?
    var artworkUrl100:  String?
    var trackCount: Int?
    var feedUrl: String?
}


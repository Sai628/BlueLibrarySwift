//
//  Album.swift
//  BlueLibrarySwift
//
//  Created by Sai on 1/6/16.
//  Copyright © 2016 Raywenderlich. All rights reserved.
//

import Foundation


class Album: NSObject, NSCoding
{
    var title: String!
    var artist: String!
    var genre: String!
    var coverUrl: String!
    var year: String!
    
    
    required init(coder decoder: NSCoder)
    {
        super.init()
        self.title = decoder.decodeObjectForKey("title") as? String
        self.artist = decoder.decodeObjectForKey("artist") as? String
        self.genre = decoder.decodeObjectForKey("genre") as? String
        self.coverUrl = decoder.decodeObjectForKey("cover_rl") as? String
        self.year = decoder.decodeObjectForKey("year") as? String
    }
    
    
    init(title: String, artist: String, genre: String, coverUrl: String, year: String)
    {
        super.init()
        
        self.title = title
        self.artist = artist
        self.genre = genre
        self.coverUrl = coverUrl
        self.year = year
    }
    
    
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(artist, forKey: "artist")
        aCoder.encodeObject(genre, forKey: "genre")
        aCoder.encodeObject(coverUrl, forKey: "cover_rl")
        aCoder.encodeObject(year, forKey: "year")
    }
    
    
    func descript() -> String
    {
        return "title: \(title)" +
            "artist: \(artist)" +
            "genre: \(genre)" +
            "coverUrl: \(coverUrl)" +
            "year: \(year)"
    }
}

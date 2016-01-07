//
//  PersistencyManger.swift
//  BlueLibrarySwift
//
//  Created by Sai on 1/6/16.
//  Copyright © 2016 Raywenderlich. All rights reserved.
//

import Foundation
import UIKit


class PersistencyManger: NSObject
{
    private var albums = [Album]()
    
    
    override init()
    {
        super.init()
        if let data = NSData(contentsOfFile: NSHomeDirectory().stringByAppendingString("/Documents/albums.bin"))
        {
            let unarchiveAlbums = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Album]
            if let unwrappedAlbum = unarchiveAlbums
            {
                albums = unwrappedAlbum
            }
        }
        else
        {
             createPlaceholderAlbum()
        }
    }
    
    
    func createPlaceholderAlbum()
    {
        let album1 = Album(title: "Best of Bowie",
            artist: "David Bowie",
            genre: "Pop",
            coverUrl: "http://pic18.nipic.com/20120130/7193741_145433542121_2.jpg",
            year: "1992")
        
        let album2 = Album(title: "It's My Life",
            artist: "No Doubt",
            genre: "Pop",
            coverUrl: "http://pic1.nipic.com/2008-12-25/2008122510134038_2.jpg",
            year: "2003")
        
        let album3 = Album(title: "Nothing Like The Sun",
            artist: "Sting",
            genre: "Pop",
            coverUrl: "http://img.61gequ.com/allimg/2011-4/201142614314278502.jpg",
            year: "1999")
        
        let album4 = Album(title: "Staring at the Sun",
            artist: "U2",
            genre: "Pop",
            coverUrl: "http://pic30.nipic.com/20130618/11860366_201437262000_2.jpg",
            year: "2000")
        
        let album5 = Album(title: "American Pie",
            artist: "Madonna",
            genre: "Pop",
            coverUrl: "http://pic4.nipic.com/20091106/896963_143936044928_2.jpg",
            year: "2000")
        
        albums = [album1, album2, album3, album4, album5]
        saveAlbums()
    }
    
    
    func getAlbum() -> [Album]
    {
        return albums
    }
    
    
    func addAlbum(album: Album, index: Int)
    {
        if albums.count >= index {
            albums.insert(album, atIndex: index)
        }
        else {
            albums.append(album)
        }
    }
    
    
    func deleteAlbumAtIndex(index: Int)
    {
        albums.removeAtIndex(index)
    }
    
    
    func saveAlbums()
    {
        let filename = NSHomeDirectory().stringByAppendingString("/Documents/albums.bin")
        let data = NSKeyedArchiver.archivedDataWithRootObject(albums)
        data.writeToFile(filename, atomically: true)
    }
    
    
    func saveImage(image: UIImage, filename: String)
    {
        let path = NSHomeDirectory().stringByAppendingString("/Documents/\(filename)")
        let data = UIImagePNGRepresentation(image)
        data?.writeToFile(path, atomically: true)
    }
    
    
    func getImage(filename: String) -> UIImage?
    {
        let path = NSHomeDirectory().stringByAppendingString("/Documents/\(filename)")
        if let data = NSData(contentsOfFile: path)
        {
            return UIImage(data: data)
        }
        else
        {
            return nil
        }
    }
}



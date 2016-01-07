//
//  LibraryAPI.swift
//  BlueLibrarySwift
//
//  Created by Sai on 1/6/16.
//  Copyright © 2016 Raywenderlich. All rights reserved.
//

import Foundation
import UIKit


class LibraryAPI: NSObject
{
    private let persistencyManager: PersistencyManger
    private let httpClient: HTTPClient
    private let isOnline: Bool
    
    class var sharedInstance: LibraryAPI
    {
        
        struct Singleton {
            static let instance = LibraryAPI()
        }
        
        return Singleton.instance
    }
    
    
    override init()
    {
        persistencyManager = PersistencyManger()
        httpClient = HTTPClient()
        isOnline = false
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("downloadImage:"), name: "BLDownloadImageNotification", object: nil)
    }
    
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func getAlbums() -> [Album]
    {
        return persistencyManager.getAlbum()
    }
    
    
    func addAlbum(album: Album, index: Int)
    {
        persistencyManager.addAlbum(album, index: index)
        if isOnline {
            httpClient.postRequest("/api/addAlbum", body: album.descript())
        }
    }
    
    
    func deleteAlbum(index: Int)
    {
        persistencyManager.deleteAlbumAtIndex(index)
        if isOnline {
            httpClient.postRequest("/api/deleteAlbum", body: "(index)")
        }
    }
    
    
    func saveAlbums()
    {
        persistencyManager.saveAlbums()
    }
    
    
    func downloadImage(notification: NSNotification)
    {
        if let userInfo = notification.userInfo as? [String: AnyObject]
        {
            if let imageView = userInfo["imageView"] as? UIImageView, coverUrl = userInfo["coverUrl"] as? NSString
            {
                if let image = persistencyManager.getImage(coverUrl.lastPathComponent)
                {
                    imageView.image = image
                }
                else
                {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [weak self] () -> Void in
                        
                        if let downloadImage = self?.httpClient.downloadImage(coverUrl as String)
                        {
                            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                
                                imageView.image = downloadImage
                            })
                            self?.persistencyManager.saveImage(downloadImage, filename: coverUrl.lastPathComponent)
                        }
                    })
                }
            }
        }
    }
}
























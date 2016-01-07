/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class ViewController: UIViewController
{
    private var allAlbums = [Album]()
    private var currentAlbumData: (titles: [String], values: [String])?
    private var currentAlbumIndex = 0
    private var undoStack: [(Album, Int)] = []

    
	@IBOutlet var dataTable: UITableView!
	@IBOutlet var toolbar: UIToolbar!
    @IBOutlet var scroller: HorizontalScroller!
	
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
	override func viewDidLoad()
    {
		super.viewDidLoad()
        
        self.navigationController?.navigationBar.translucent = false
        dataTable.delegate = self
        dataTable.dataSource = self
        dataTable.backgroundView = nil
        
        view.addSubview(dataTable)
        scroller.delegate = self
        
        loadPreviousState()
        self.reloadScroller()
        
        let undoButton = UIBarButtonItem(barButtonSystemItem: .Undo, target: self, action: "undoAction")
        undoButton.enabled = false
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let trashButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "deleteAlbum")
        let toolbarButtonItems = [undoButton, space, trashButton]
        toolbar.setItems(toolbarButtonItems, animated: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("saveCurrentState"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
	}

    
	override func didReceiveMemoryWarning()
    {
		super.didReceiveMemoryWarning()
	}
    
    
    func addAlbumAtIndex(album: Album, index: Int)
    {
        LibraryAPI.sharedInstance.addAlbum(album, index: index)
        currentAlbumIndex = index
        reloadScroller()
    }
    
    
    func deleteAlbum()
    {
        let deleteAlbum = allAlbums[currentAlbumIndex]
        let undoAction = (deleteAlbum, currentAlbumIndex)
        undoStack.insert(undoAction, atIndex: 0)
        
        LibraryAPI.sharedInstance.deleteAlbum(currentAlbumIndex)
        reloadScroller()
        
        let barButtonItems = toolbar.items! as [UIBarButtonItem]
        let undoButton = barButtonItems[0]
        undoButton.enabled = true
        
        if allAlbums.isEmpty
        {
            let trashButton = barButtonItems[2]
            trashButton.enabled = false
        }
    }
    
    
    func undoAction()
    {
        let barButtonItems = toolbar.items! as [UIBarButtonItem]
        if undoStack.count > 0
        {
            let (deleteAlbum, index) = undoStack.removeAtIndex(0)
            addAlbumAtIndex(deleteAlbum, index: index)
        }
        
        if undoStack.isEmpty
        {
            let undoButton = barButtonItems[0]
            undoButton.enabled = false
        }
        
        let trashButton = barButtonItems[2]
        trashButton.enabled = true
    }
    
    
    func showDataForAlbum(albumIndex: Int)
    {
        if albumIndex < allAlbums.count && albumIndex > -1
        {
            let album = allAlbums[albumIndex]
            currentAlbumData = album.ae_tableRepresentation()
        }
        else
        {
            currentAlbumData = nil
        }
        
        dataTable.reloadData()
    }
    
    
    func reloadScroller()
    {
        allAlbums = LibraryAPI.sharedInstance.getAlbums()
        if currentAlbumIndex < 0
        {
            currentAlbumIndex = 0
        }
        else if currentAlbumIndex >= allAlbums.count
        {
            currentAlbumIndex = allAlbums.count - 1
        }
        
        scroller.reload()
        showDataForAlbum(currentAlbumIndex)
    }
    
    
    func saveCurrentState()
    {
        NSUserDefaults.standardUserDefaults().setInteger(currentAlbumIndex, forKey: "currentAlbumIndex")
        LibraryAPI.sharedInstance.saveAlbums()
    }
    
    
    func loadPreviousState()
    {
        currentAlbumIndex = NSUserDefaults.standardUserDefaults().integerForKey("currentAlbumIndex")
        showDataForAlbum(currentAlbumIndex)
    }
}


extension ViewController: UITableViewDataSource
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let album = currentAlbumData
        {
            return album.titles.count
        }
        else
        {
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        if let albumData = currentAlbumData
        {
            cell.textLabel?.text = albumData.titles[indexPath.row]
            cell.detailTextLabel?.text = albumData.values[indexPath.row]
        }
        
        return cell
    }
}


extension ViewController: UITableViewDelegate
{
    
}


extension ViewController: HorizontalScrollerDelegate
{
    func numberOfViewsForHorizontalScroller(scroller: HorizontalScroller) -> Int
    {
        return allAlbums.count
    }
    
    func horizontalScrollerClickedViewAtIndex(scroller: HorizontalScroller, index: Int)
    {
        let previousAlbumView = scroller.viewAtIndex(currentAlbumIndex) as! AlbumView
        previousAlbumView.highlightAlbum(false)
        
        currentAlbumIndex = index
        let albumView = scroller.viewAtIndex(index) as! AlbumView
        albumView.highlightAlbum(true)
        
        showDataForAlbum(index)
    }
    
    
    func horizontalScrollerViewAtIndex(scroller: HorizontalScroller, index: Int) -> UIView
    {
        let album = allAlbums[index]
        let albumView = AlbumView(frame: CGRectMake(0, 0, 100, 100), albumCover: album.coverUrl)
        albumView.highlightAlbum(currentAlbumIndex == index)
        
        return albumView
    }
    
    
    func initialViewIndex(scroller: HorizontalScroller) -> Int
    {
        return currentAlbumIndex
    }
}













//
//  HorizontalScroller.swift
//  BlueLibrarySwift
//
//  Created by Sai on 1/6/16.
//  Copyright © 2016 Raywenderlich. All rights reserved.
//

import Foundation
import UIKit


@objc protocol HorizontalScrollerDelegate
{
    func numberOfViewsForHorizontalScroller(scroller: HorizontalScroller) -> Int
    
    func horizontalScrollerViewAtIndex(scroller: HorizontalScroller, index: Int) -> UIView
    
    func horizontalScrollerClickedViewAtIndex(scroller: HorizontalScroller, index: Int)
    
    optional func initialViewIndex(scroller: HorizontalScroller) -> Int
}


class HorizontalScroller: UIView
{
    weak var delegate: HorizontalScrollerDelegate?
    
    private let VIEW_PADDING = 10
    private let VIEW_DIMENSIONS = 100
    private let VIEWS_OFFSET = 100
    
    private var scroller: UIScrollView!
    var viewArray = [UIView]()
    
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.initializeScrollView()
    }
    
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.initializeScrollView()
    }
    
    
    func initializeScrollView()
    {
        scroller = UIScrollView()
        scroller.delegate = self
        addSubview(scroller)
        
        scroller.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("scrollerTapped:"))
        scroller.addGestureRecognizer(tapRecognizer)
    }
    
    
    func scrollerTapped(gesture: UITapGestureRecognizer)
    {
        let location = gesture.locationInView(gesture.view)
        if let delegate = self.delegate
        {
            for index in 0..<delegate.numberOfViewsForHorizontalScroller(self)
            {
                let view = scroller.subviews[index] as UIView
                if CGRectContainsPoint(view.frame, location)
                {
                    delegate.horizontalScrollerClickedViewAtIndex(self, index: index)
                    scroller.setContentOffset(CGPointMake(view.frame.origin.x + view.frame.size.width / 2 -
                        self.frame.size.width / 2, 0), animated: true)
                    
                    break
                }
            }
        }
    }
    
    
    func viewAtIndex(index: Int) -> UIView
    {
        return viewArray[index]
    }
    
    
    func reload()
    {
        guard let delegate = self.delegate else
        {
            return
        }
        
        viewArray = []
        let views: NSArray = scroller.subviews
        
        views.enumerateObjectsUsingBlock { (object: AnyObject!, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            object.removeFromSuperview()
        }
        
        var xValue = VIEWS_OFFSET
        for index in 0..<delegate.numberOfViewsForHorizontalScroller(self)
        {
            xValue += VIEW_PADDING
            let view = delegate.horizontalScrollerViewAtIndex(self, index: index)
            view.frame = CGRectMake(CGFloat(xValue), CGFloat(VIEW_PADDING), CGFloat(VIEW_DIMENSIONS), CGFloat(VIEW_DIMENSIONS))
            
            scroller.addSubview(view)
            xValue += VIEW_DIMENSIONS + VIEW_PADDING
            viewArray.append(view)
        }
        
        scroller.contentSize = CGSizeMake(CGFloat(xValue + VIEWS_OFFSET), frame.size.height)
        
        if let initialViewIndex = delegate.initialViewIndex?(self)
        {
            scroller.setContentOffset(CGPointMake(CGFloat(initialViewIndex) * CGFloat(VIEW_DIMENSIONS + 2 * VIEW_PADDING), 0), animated: true)
        }
    }
    
    
    func centerCurrentView()
    {
        var xFinal = scroller.contentOffset.x + CGFloat((VIEWS_OFFSET/2) + VIEW_PADDING)
        let viewIndex = xFinal / CGFloat((VIEW_DIMENSIONS + (2*VIEW_PADDING)))
        xFinal = viewIndex * CGFloat(VIEW_DIMENSIONS + (2*VIEW_PADDING))
        scroller.setContentOffset(CGPointMake(xFinal, 0), animated: true)
        
        if let delegate = self.delegate
        {
            delegate.horizontalScrollerClickedViewAtIndex(self, index: Int(viewIndex))
        }
    }
}


extension HorizontalScroller: UIScrollViewDelegate
{
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        if !decelerate
        {
            centerCurrentView()
        }
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    {
        centerCurrentView()
    }
}




















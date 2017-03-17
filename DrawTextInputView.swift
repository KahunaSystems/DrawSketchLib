//
//  DrawTextInputView.swift
//  FIMS
//
//  Created by Piyush on 25/01/17.
//  Copyright © 2017 Kahuna Systems. All rights reserved.
//

import UIKit

struct DrawTextInputViewAnchorPoint {
    let adjustsX:CGFloat!
    let adjustsY:CGFloat!
    let adjustsH:CGFloat!
    let adjustsW:CGFloat!
};

struct DrawTextInputViewAnchorPointPair {
    let point:CGPoint!
    let anchorPoint:DrawTextInputViewAnchorPoint!
};


@objc protocol DrawTextInputViewDelegate {
    
    @objc optional func drawTextInputViewDidBeginEditing(textView:DrawTextInputView)
    @objc optional func drawTextInputViewDidEndEditing(textView:DrawTextInputView)
}

class DrawTextInputView: UIView {
    
    static let notResizedAnchorPoint = DrawTextInputViewAnchorPoint(adjustsX: 0.0, adjustsY: 0.0, adjustsH: 0.0, adjustsW: 0.0)
    static let upperLeftAnchorPoint = DrawTextInputViewAnchorPoint(adjustsX: 1.0, adjustsY: 1.0, adjustsH: -1.0, adjustsW: 1.0)
    static let middleLeftAnchorPoint = DrawTextInputViewAnchorPoint(adjustsX: 1.0, adjustsY: 0.0, adjustsH: 0.0, adjustsW: 1.0)
    static let lowerLeftAnchorPoint = DrawTextInputViewAnchorPoint(adjustsX: 1.0, adjustsY: 0.0, adjustsH: 1.0, adjustsW: 1.0)
    static let upperMiddleAnchorPoint = DrawTextInputViewAnchorPoint(adjustsX: 0.0, adjustsY: 1.0, adjustsH: -1.0, adjustsW: 0.0)
    static let upperRightAnchorPoint = DrawTextInputViewAnchorPoint(adjustsX: 0.0, adjustsY: 1.0, adjustsH: -1.0, adjustsW: -1.0)
    static let middleRightAnchorPoint = DrawTextInputViewAnchorPoint(adjustsX: 0.0, adjustsY: 0.0, adjustsH: 0.0, adjustsW: -1.0)
    static let lowerRightAnchorPoint = DrawTextInputViewAnchorPoint(adjustsX: 0.0, adjustsY: 0.0, adjustsH: 1.0, adjustsW: -1.0)
    static let lowerMiddleAnchorPoint = DrawTextInputViewAnchorPoint(adjustsX: 0.0, adjustsY: 0.0, adjustsH: 1.0, adjustsW: 0.0)
    
    var borderView:DrawTextBorderView!
    var touchStart:CGPoint!
    var minWidth:CGFloat!
    var minHeight:CGFloat!
    var preventsPositionOutsideSuperview:Bool!
    var contentView:UIView!
    weak var delegate:DrawTextInputViewDelegate?
    
    //* @var anchorPoint Used to determine which components of the bounds we'll be modifying, based upon where the user's touch started.*/
    var anchorPoint:DrawTextInputViewAnchorPoint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.setupDefaultAttributes()

    }
    
    func setupDefaultAttributes(){
        
        let insetFrame1 = self.bounds.insetBy(dx: CGFloat(DrawSketchStaticFields.DrawTextView_GlobalInset), dy: CGFloat(DrawSketchStaticFields.DrawTextView_GlobalInset))
        self.borderView = DrawTextBorderView(frame: insetFrame1)
        self.borderView.isHidden = true
        self.addSubview(self.borderView)
        self.minWidth = CGFloat(DrawSketchStaticFields.DrawTextView_DefaultMinWidth)
        self.minHeight = CGFloat(DrawSketchStaticFields.DrawTextView_DefaultMinHeight)
        self.preventsPositionOutsideSuperview = true
    }
    
    func setContentView(newContentView:UIView){
        
        self.contentView.removeFromSuperview()
        self.contentView = newContentView
        let dx = Double(DrawSketchStaticFields.DrawTextView_GlobalInset) + DrawSketchStaticFields.DrawTextView_InteractiveBorderSize/2
        self.contentView.frame = self.bounds.insetBy(dx: CGFloat(dx), dy: CGFloat(dx))
        self.addSubview(self.contentView)

        // Ensure the border view is always on top by removing it and adding it to the end of the subview list.
        self.borderView.removeFromSuperview()
        self.addSubview(self.borderView)
    }
    
    func setFrame(newFrame:CGRect){
        super.frame = newFrame
        let dx = Double(DrawSketchStaticFields.DrawTextView_GlobalInset) + DrawSketchStaticFields.DrawTextView_InteractiveBorderSize/2
        self.contentView.frame = self.bounds.insetBy(dx: CGFloat(dx), dy: CGFloat(dx))
        self.borderView.frame = self.bounds.insetBy(dx: CGFloat(DrawSketchStaticFields.DrawTextView_GlobalInset), dy: CGFloat(DrawSketchStaticFields.DrawTextView_GlobalInset))
    }
    
    func getDistanceBetweenTwoPoints(point1:CGPoint, point2:CGPoint)->CGFloat{
        
        let dx = point2.x - point1.x;
        let dy = point2.y - point1.y;
        return sqrt(dx*dx + dy*dy)
    }
    
    func anchorPointForTouchLocation(touchPoint:CGPoint)->DrawTextInputViewAnchorPoint{
        
        // (1) Calculate the positions of each of the anchor points.
        let upperLeft = DrawTextInputViewAnchorPointPair(point: CGPoint(x:0.0, y:0.0), anchorPoint: DrawTextInputView.upperLeftAnchorPoint)
        let upperMiddle = DrawTextInputViewAnchorPointPair(point: CGPoint(x:self.bounds.size.width/2, y:0.0), anchorPoint: DrawTextInputView.upperMiddleAnchorPoint)
        let upperRight = DrawTextInputViewAnchorPointPair(point: CGPoint(x:self.bounds.size.width, y:0.0), anchorPoint: DrawTextInputView.upperRightAnchorPoint)
        let middleRight = DrawTextInputViewAnchorPointPair(point: CGPoint(x:self.bounds.size.width, y:self.bounds.size.height/2), anchorPoint: DrawTextInputView.middleRightAnchorPoint)
        let lowerRight = DrawTextInputViewAnchorPointPair(point: CGPoint(x:self.bounds.size.width, y:self.bounds.size.height), anchorPoint: DrawTextInputView.lowerRightAnchorPoint)
        let lowerMiddle = DrawTextInputViewAnchorPointPair(point: CGPoint(x:self.bounds.size.width/2, y:self.bounds.size.height), anchorPoint: DrawTextInputView.lowerMiddleAnchorPoint)
        let lowerLeft = DrawTextInputViewAnchorPointPair(point: CGPoint(x:0.0, y:self.bounds.size.height), anchorPoint: DrawTextInputView.lowerLeftAnchorPoint)
        let middleLeft = DrawTextInputViewAnchorPointPair(point: CGPoint(x:0.0, y:self.bounds.size.height/2), anchorPoint: DrawTextInputView.middleLeftAnchorPoint)
        let centerPoint = DrawTextInputViewAnchorPointPair(point: CGPoint(x:self.bounds.size.width/2, y:self.bounds.size.height/2), anchorPoint: DrawTextInputView.notResizedAnchorPoint)
        
        // (2) Iterate over each of the anchor points and find the one closest to the user's touch.
        let allPoints:[DrawTextInputViewAnchorPointPair] =  [upperLeft, upperRight, lowerRight, lowerLeft, upperMiddle, lowerMiddle, middleLeft, middleRight, centerPoint]
        var closestPoint = centerPoint
        
        var smallestDist = CGFloat(MAXFLOAT)
        for i in 0..<allPoints.count{
            
            let distance = getDistanceBetweenTwoPoints(point1: touchPoint, point2: allPoints[i].point)
            if distance < smallestDist{
                closestPoint = allPoints[i]
                smallestDist = distance
            }
        }
        return closestPoint.anchorPoint
    }
    
    func isResizing()->Bool{
        return (self.anchorPoint.adjustsH != nil) || (self.anchorPoint.adjustsW != nil) || (self.anchorPoint.adjustsX != nil) || (self.anchorPoint.adjustsY != nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        // Notify the delegate we've begun our editing session.
        self.delegate?.drawTextInputViewDidBeginEditing!(textView: self)
        
        self.borderView?.isHidden = false
        let touch = touches.first
        
        self.anchorPoint = self.anchorPointForTouchLocation(touchPoint: (touch?.location(in: self))!)
        
        // When resizing, all calculations are done in the superview's coordinate space.
        self.touchStart = touch?.location(in: self.superview)
        if self.isResizing(){
            self.touchStart = touch?.location(in: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Notify the delegate we've end our editing session.
        self.delegate?.drawTextInputViewDidEndEditing!(textView: self)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Notify the delegate we've end our editing session.
        self.delegate?.drawTextInputViewDidEndEditing!(textView: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        if self.isResizing(){
            self.resizeUsingTouchLocation(touchPoint: (touch?.location(in: self.superview))!)
        }else{
            self.translateUsingTouchLocation(touchPoint: (touch?.location(in: self))!)
        }
    }
    
    func showEditingHandles(){
        self.borderView.isHidden = false
    }
    
    func hideEditingHandles(){
        self.borderView.isHidden = true
    }
    
    func resizeUsingTouchLocation(touchPoint:CGPoint){
        
        // (1) Update the touch point if we're outside the superview.
        var touchPontLocalObj = touchPoint
        if self.preventsPositionOutsideSuperview == true{
            let border = CGFloat(Double(DrawSketchStaticFields.DrawTextView_GlobalInset) + DrawSketchStaticFields.DrawTextView_InteractiveBorderSize/2)
            if touchPontLocalObj.x < border{
                touchPontLocalObj.x = border
            }
            if touchPontLocalObj.x > (self.superview?.bounds.size.width)! - border{
                touchPontLocalObj.x = (self.superview?.bounds.size.width)! - border
            }
            if touchPontLocalObj.y < border{
                touchPontLocalObj.y = border
            }
            if touchPontLocalObj.y > (self.superview?.bounds.size.height)! - border{
                touchPontLocalObj.y = (self.superview?.bounds.size.height)! - border
            }
        }
        // (2) Calculate the deltas using the current anchor point.
        var deltaW = self.anchorPoint.adjustsW * (self.touchStart.x - touchPontLocalObj.x)
        let deltaX = self.anchorPoint.adjustsX * (-1 * deltaW)
        var deltaH = self.anchorPoint.adjustsH * (self.touchStart.y - touchPontLocalObj.y)
        let deltaY = self.anchorPoint.adjustsY * (-1 * deltaH)
        
        // (3) Calculate the new frame.
        var newX = self.frame.origin.x + deltaX
        var newY = self.frame.origin.y + deltaY
        var newWidth = self.frame.size.width + deltaW
        var newHeight = self.frame.size.height + deltaH
        
        // (4) If the new frame is too small, cancel the changes.
        if newWidth < self.minWidth{
            newWidth = self.frame.size.width
            newX = self.frame.origin.x
        }
        if newHeight < self.minHeight{
            newHeight = self.frame.size.height
            newY = self.frame.origin.y
        }
        
        // (5) Ensure the resize won't cause the view to move offscreen.
        if self.preventsPositionOutsideSuperview == true{
            
            if newX < (self.superview?.bounds.origin.x)! {
                deltaW = self.frame.origin.x - (self.superview?.bounds.origin.x)!
                newWidth = self.frame.size.width + deltaW
                newX = (self.superview?.bounds.origin.x)!
            }
            
            if (newX + newWidth > (self.superview?.bounds.origin.x)! + (self.superview?.bounds.size.width)!) {
                newWidth = (self.superview?.bounds.size.width)! - newX;
            }
            if (newY < (self.superview?.bounds.origin.y)!) {
                // Calculate how much to grow the height by such that the new Y coordintae will align with the superview.
                deltaH = self.frame.origin.y - (self.superview?.bounds.origin.y)!;
                newHeight = self.frame.size.height + deltaH;
                newY = (self.superview?.bounds.origin.y)!;
            }
            if (newY + newHeight > (self.superview?.bounds.origin.y)! + (self.superview?.bounds.size.height)!) {
                newHeight = (self.superview?.bounds.size.height)! - newY;
            }
        }
        self.frame = CGRect(x:newX, y:newY, width:newWidth, height:newHeight)
        self.touchStart = touchPoint
    }
    
    func translateUsingTouchLocation(touchPoint:CGPoint){
        
        var newCenter = CGPoint(x:self.center.x + touchPoint.x - touchStart.x, y:self.center.y + touchPoint.y - touchStart.y)
        if self.preventsPositionOutsideSuperview == true{
            
            // Ensure the translation won't cause the view to move offscreen.
            let midPointX = self.bounds.midX
            if (newCenter.x > (self.superview?.bounds.size.width)! - midPointX) {
                newCenter.x = (self.superview?.bounds.size.width)! - midPointX;
            }
            if (newCenter.x < midPointX) {
                newCenter.x = midPointX
            }
            let midPointY = self.bounds.midY
            if (newCenter.y > (self.superview?.bounds.size.height)! - midPointY) {
                newCenter.y = (self.superview?.bounds.size.height)! - midPointY;
            }
            if (newCenter.y < midPointY) {
                newCenter.y = midPointY;
            }
        }
        self.center = newCenter;
    }
}

class DrawTextBorderView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
    }
    
    func drawRect(rect:CGRect){
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.saveGState()
        
        //1 Draw Bounding Box
        context?.setLineWidth(1.0)
        context?.setStrokeColor(UIColor.clear.cgColor)
        
        let dx = DrawSketchStaticFields.DrawTextView_InteractiveBorderSize/2
        let dy = DrawSketchStaticFields.DrawTextView_InteractiveBorderSize/2
        let insetFrame = self.bounds.insetBy(dx: CGFloat(dx), dy: CGFloat(dy))
        context?.addRect(insetFrame)
        context?.strokePath()
        
        let borderDevide2 = CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize/2)
        //2. Calculate the bounding boxes for each of anchor point
        let upperLeft  = CGRect(x: 0.0, y: 0.0, width: DrawSketchStaticFields.DrawTextView_InteractiveBorderSize, height: DrawSketchStaticFields.DrawTextView_InteractiveBorderSize)
        let upperRight  = CGRect(x: self.bounds.size.width - CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize), y: 0.0, width: CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize), height: CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize))
       
        let lowerRight  = CGRect(x: self.bounds.size.width - CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize), y: self.bounds.size.height - CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize), width: CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize), height: CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize))
        let lowerLeft  = CGRect(x: 0.0, y: self.bounds.size.height - CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize), width: CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize), height: CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize))

        let upperMiddle  = CGRect(x: self.bounds.size.width - borderDevide2, y: 0.0, width: CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize), height: CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize))
        let lowerMiddle  = CGRect(x: self.bounds.size.width - borderDevide2, y: self.bounds.size.height - CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize), width: CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize), height: CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize))

        let middleLeft  = CGRect(x: 0.0, y: self.bounds.size.height - borderDevide2, width: CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize), height: CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize))
        let middleRight  = CGRect(x: self.bounds.size.width - CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize), y: self.bounds.size.height - borderDevide2, width: CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize), height: CGFloat(DrawSketchStaticFields.DrawTextView_InteractiveBorderSize))

        // 3 Create the gradient to paint the anchor points.
        let colors:[CGFloat] = [
            0.4, 0.8, 1.0, 1.0,
            0.0, 0.0, 1.0, 1.0
        ]
        
        let baseSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: baseSpace, colorComponents: colors, locations: nil, count: 2)
        
        //4 Set up the stroke for drawing the border of each of the anchor points.
        context?.setLineWidth(1.0)
        context?.setShadow(offset: CGSize(width:0.5, height:0.5), blur: 1)
        context?.setStrokeColor(UIColor.white.cgColor)
        
        // (5) Fill each anchor point using the gradient, then stroke the border.
        let allPoints:[CGRect] = [ upperLeft, upperRight, lowerRight, lowerLeft, upperMiddle, lowerMiddle, middleLeft, middleRight ]
        
        for i in 0..<allPoints.count{
            
            let currentPoint = allPoints[i]
            context?.saveGState()
            context?.addEllipse(in: currentPoint)
            context?.clip()
            
            let startPoint = CGPoint(x:currentPoint.midX, y:currentPoint.minY)
            let endPoint   = CGPoint(x:currentPoint.midX, y:currentPoint.maxY)
            context?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
            context?.restoreGState()
            let insetFrame1 = currentPoint.insetBy(dx: 1, dy: 1)
            context?.strokeEllipse(in: insetFrame1)
        }
        context?.restoreGState()
    }
}

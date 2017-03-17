//
//  DrawSketchView.swift
//  FIMS
//
//  Created by Piyush Rathi on 23/01/17.
//  Copyright © 2017 Kahuna Systems. All rights reserved.
//

import UIKit

protocol DrawSketchViewDelegate : class{
    func touchPointOnImage(selectedImagePoint:CGPoint)
}

struct DrawSketchStaticFields{
    
    static let xMarkImage       = "xMarks.png"
    static let transperentImage = "TransparentImage.png"
    static let overlayImage     = "Overlay.png"
    
    static let textImage        = "Text"
    static let marksImage       = "Marks"
    static let drawImage        = "Draw"
    static let colorImage       = "Color"
    static let eraserImage      = "Eraser"
    static let clearAllImage    = "Clear_all"
    
    static let imageScaleSize  = CGSize(width:600, height:451)
    static let firstColor      = UIColor.black

    enum ToolBarSelectedField {
        
        static let drawTextSelected     = 1
        static let xMarkSelected        = 2
        static let colorPallateSelected = 3
    }
    
    static let areYouSureMessage = "Are you sure?"
    
    static let DrawTextView_DefaultMinWidth:NSInteger   = 48
    static let DrawTextView_DefaultMinHeight:NSInteger  = 48
    static let DrawTextView_InteractiveBorderSize       = 10.0
    static let DrawTextView_GlobalInset                 = 5.0
}

class DrawSketchView: UIView {

    var erasePreviousPoint:CGPoint!
    var eraseCurrentPoint:CGPoint!
    var previousPoint:CGPoint!
    var prePreviousPoint:CGPoint!
    
    @IBOutlet weak var drawImageView:UIImageView!
    var xMarkImageView:UIImageView!
   
    var isDrawTextSelected:Bool!
    var isXmarkSelected:Bool!
    
    weak var delegate:DrawSketchViewDelegate?
    
    @IBOutlet weak var bgView:UIView!
    
    var subViewArray:NSMutableArray!
    var lineWidth:CGFloat!
    
    var currentColor:UIColor!

    
    //MARK:- OVERRIDE TOUCH BEGIN METHOD OF UIVIEW
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch = touches.first
        
        self.previousPoint = touch?.location(in: self.drawImageView)
        self.erasePreviousPoint = touch?.location(in: self.drawImageView)
        
        if self.isDrawTextSelected == true{
            self.delegate?.touchPointOnImage(selectedImagePoint: (touch?.location(in: self.drawImageView))!)
        }
        if self.isXmarkSelected == true{
           
            let inViewPoint = touch?.location(in: self.drawImageView)
            let fgImage = UIImage(named: DrawSketchStaticFields.xMarkImage)
            
            let frame = CGRect(x:(inViewPoint?.x)!-((fgImage?.size.width)!/2), y:(inViewPoint?.y)!-((fgImage?.size.height)!/2), width:(fgImage?.size.width)!, height:(fgImage?.size.height)!)
            
            self.xMarkImageView = UIImageView(frame: frame)
            self.xMarkImageView.center = self.previousPoint
            self.xMarkImageView.image = fgImage
            
            self.bgView.addSubview(self.xMarkImageView)
            
            if self.subViewArray == nil{
                self.subViewArray = NSMutableArray()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        let touch = touches.first
        let currentPoint = touch?.location(in: self.drawImageView)
        
        if self.isDrawTextSelected == false{
            
            self.prePreviousPoint =  self.previousPoint
            self.previousPoint = touch?.previousLocation(in: self.drawImageView)
            
            self.eraseCurrentPoint = touch?.location(in: self.drawImageView)
            
            //calculate mid point
            let midPoint1 = self.calculateMidPointForPoint(point1: self.previousPoint, and: self.prePreviousPoint)
            let midPoint2 = self.calculateMidPointForPoint(point1: currentPoint!, and: self.previousPoint)
            
            UIGraphicsBeginImageContext(self.drawImageView.frame.size)
            let context = UIGraphicsGetCurrentContext()
           
            self.currentColor.setStroke()

            context?.setAllowsAntialiasing(true);
            context?.setShouldAntialias(true);

            self.drawImageView.image?.draw(in: CGRect(x:0, y:0, width:self.drawImageView.frame.size.width, height:self.drawImageView.frame.size.height))
            
            context?.move(to: CGPoint(x:(midPoint1.x), y:(midPoint1.y)))
            context?.addQuadCurve(to: CGPoint(x:(midPoint2.x), y:(midPoint2.y)), control: CGPoint(x:(self.previousPoint.x), y:(self.previousPoint.y)))
            context?.setLineCap(CGLineCap.butt)
            
            
            let xDist = self.previousPoint.x - (currentPoint?.x)!
            let yDist = self.previousPoint.y - (currentPoint?.y)!
            var distance = sqrt((xDist * xDist) + (yDist * yDist))
            
            distance = distance/10
            
            if distance > 10{
                distance = 10.0
            }
            distance = distance/10
            distance = distance * 3
            
            if (4.0 - distance > self.lineWidth) {
                self.lineWidth = self.lineWidth + 0.3;
            } else {
                self.lineWidth = self.lineWidth - 0.3;
            }
            
            if self.currentColor == UIColor.white{
                self.lineWidth = 20.04
            }
            
            context!.setLineWidth(self.lineWidth);
            context!.strokePath();

            self.drawImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if self.currentColor == UIColor.clear && self.isXmarkSelected == false{
                self.eraseDrawingContents()
            }
        }

        if self.isXmarkSelected == true{
            
            let currentPointingView = touch?.location(in: self)
            let fgImage = UIImage(named: DrawSketchStaticFields.xMarkImage)

            let frame = CGRect(x:(currentPointingView?.x)!-((fgImage?.size.width)!/2), y:(currentPointingView?.y)!-((fgImage?.size.height)!/2), width:(fgImage?.size.width)!, height:(fgImage?.size.height)!)
            
            self.xMarkImageView.frame = frame
            self.xMarkImageView.center = currentPoint!
            self.xMarkImageView.image = fgImage
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        let touch = touches.first
        let currentPoint = touch?.location(in: self.drawImageView)

        self.lineWidth = 1.0
        
        if touch?.tapCount == 1 && self.isDrawTextSelected == false{
            
            UIGraphicsBeginImageContext(self.drawImageView.frame.size);
            let context = UIGraphicsGetCurrentContext();

            self.currentColor.setStroke()
            
            UIGraphicsGetCurrentContext()!.setAllowsAntialiasing(true);
            UIGraphicsGetCurrentContext()!.setShouldAntialias(true);

            self.drawImageView.image?.draw(in: CGRect(x:0, y:0, width:self.drawImageView.frame.size.width, height:self.drawImageView.frame.size.height))

            context?.move(to: CGPoint(x:(currentPoint?.x)!, y:(currentPoint?.y)!))
            context?.addLine(to: CGPoint(x:(currentPoint?.x)!, y:(currentPoint?.y)!))
            
            context?.setLineCap(CGLineCap.round)
            context!.setLineWidth(4.0);
            context!.strokePath();

            self.drawImageView.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        if self.isXmarkSelected == true{
            
            self.xMarkImageView.center = currentPoint!
            self.subViewArray.add(self.xMarkImageView)
        }
    }
    
    func setImageToDrawImageView(image:UIImage){
        self.drawImageView.image = image
    }
    
    func calculateMidPointForPoint(point1: CGPoint, and point2:CGPoint)->CGPoint{
        return CGPoint(x:(point1.x+point2.x)/2, y:(point1.y+point2.y)/2)
    }
    
    func eraseDrawingContents(){
        
        UIGraphicsBeginImageContext(self.drawImageView.frame.size)
        self.drawImageView.image?.draw(in: CGRect(x:0, y:0, width:self.drawImageView.frame.size.width,height:self.drawImageView.frame.size.height))

        let context = UIGraphicsGetCurrentContext()
        
        context?.saveGState()
        context?.setShouldAntialias(true);
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(20.0);
        context?.setShadow(offset: CGSize(width:0, height:0), blur: 50, color: UIColor.clear.cgColor)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x:self.erasePreviousPoint.x, y:self.erasePreviousPoint.y))
        path.addLine(to: CGPoint(x:self.eraseCurrentPoint.x, y:self.eraseCurrentPoint.y))
        context?.setBlendMode(CGBlendMode.clear)
        context?.addPath(path)
        context?.strokePath();

        self.drawImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        context?.restoreGState()
        
        UIGraphicsEndImageContext()
        self.erasePreviousPoint = self.eraseCurrentPoint
    }
    
    //MARK:- REMOVE SUBVIEW AND TAKE SCREEN SHOT
    func removeSubviewAndTakeScreenShot(){
        
        if self.subViewArray != nil{
            if self.subViewArray.count > 0{
                
                UIGraphicsBeginImageContextWithOptions(self.drawImageView.frame.size, false, 0.0)
                let context = UIGraphicsGetCurrentContext()
                self.bgView.layer.render(in: context!)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                
                self.drawImageView.image = image
                
                for i in 0..<self.subViewArray.count{
                    
                    let view = self.subViewArray[i] as? UIView
                    if view != nil{
                        view?.removeFromSuperview()
                    }
                }
                self.subViewArray.removeAllObjects()
            }
        }
    }
    
    func drawText(text:String, inImage image:UIImage?, atPoint point:CGPoint, withRectToWrite rect:CGRect)->UIImage?{
        
        var inputImage = image
        var inputRect = rect
        if image == nil{
            self.drawImageView.image = UIImage()
            inputImage = self.drawImageView.image
        }
        var width = inputImage?.size.width
        var height = inputImage?.size.height
        let x = point.x
        let y = point.y
        
        if width == 0{
            width = 703
            height = 660
        }
        let font = UIFont.boldSystemFont(ofSize: 15)
        
        UIGraphicsBeginImageContext(self.drawImageView.bounds.size)
        inputImage?.draw(in: CGRect(x:0, y:0, width:width!, height:height!))
        inputRect.origin.x = x
        inputRect.origin.y = y

        var isWhiteColor = false
        if self.currentColor == UIColor.white{
            self.currentColor = UIColor.black
            isWhiteColor = true
        }
        
        let textFontAttributes = [NSFontAttributeName: font, NSForegroundColorAttributeName:self.currentColor]
        let stringText = text as NSString
        stringText.draw(in: inputRect.integral, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if isWhiteColor == true{
            self.currentColor = UIColor.white
        }
        return newImage
    }
}

//
//  DrawSketchViewController.swift
//  FIMS
//
//  Created by Piyush on 24/01/17.
//  Copyright © 2017 Kahuna Systems. All rights reserved.
//

import UIKit

var gSelectedToolTag:NSInteger = 0
var gSelectedPoint:CGPoint = CGPoint.zero

class DrawSketchViewController: UIViewController, UIPopoverControllerDelegate, DrawSketchViewDelegate, DrawTextInputViewDelegate {

    @IBOutlet weak var toolsBGView:UIView!
    @IBOutlet weak var currentColorLabel:UILabel!
    
    @IBOutlet weak var clearAllButton:UIButton!
    @IBOutlet weak var colorButton:UIButton!
    @IBOutlet weak var drawButton:UIButton!
    @IBOutlet weak var markButton:UIButton!
    @IBOutlet weak var textButton:UIButton!
    
    @IBOutlet weak var blackBtn:UIButton!
    @IBOutlet weak var blueBtn:UIButton!
    @IBOutlet weak var greenBtn:UIButton!
    @IBOutlet weak var redBtn:UIButton!
    @IBOutlet weak var eraserBtn:UIButton!
    @IBOutlet weak var exportButton:UIButton!
    @IBOutlet weak var sketchButton:UIButton!
    
    @IBOutlet weak var textBGView:UIView!
    @IBOutlet weak var xMarkBGView:UIView!
    @IBOutlet weak var drawBGView:UIView!
    @IBOutlet weak var colorBGView:UIView!
    @IBOutlet weak var eraseBGView:UIView!
    @IBOutlet weak var clearBGView:UIView!
    @IBOutlet weak var imageBgView:UIView!
    

    @IBOutlet weak var orignalImageView:UIImageView!    
    @IBOutlet var originalImage:UIImage!
    var image_title:String!
    var isNewSnap:Bool!
    var previosAnnotationImagePath:String!
    var drawTextView:DrawTextInputView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setSelectedTools(tag: DrawSketchStaticFields.ToolBarSelectedField.colorPallateSelected)
        self.currentColorLabel.backgroundColor = DrawSketchStaticFields.firstColor

        if let viewC = self.view as? DrawSketchView{
            viewC.delegate = self
//            viewC.setImageToDrawImageView(image: UIImage(named:DrawSketchStaticFields.transperentImage))
            viewC.lineWidth = 0.0
            viewC.previousPoint = CGPoint.zero
            viewC.prePreviousPoint = CGPoint.zero
            viewC.currentColor = DrawSketchStaticFields.firstColor
        }

//        self.setLayerToObject(objectLayer: self.blackBtn.layer)
        self.setLayerToObject(objectLayer: self.blueBtn.layer)
//        self.setLayerToObject(objectLayer: self.greenBtn.layer)
//        self.setLayerToObject(objectLayer: self.redBtn.layer)
        self.setLayerToObject(objectLayer: self.eraserBtn.layer)
        self.orignalImageView.image = self.originalImage
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGestureAction(sender:)))
        self.toolsBGView.addGestureRecognizer(longPressGesture)
        
        if self.isNewSnap == false{
           
            self.clearBGView.isHidden = true
            var frame =  self.toolsBGView.frame
            frame.size.width -= self.clearBGView.frame.size.width + 1
            
            self.toolsBGView.frame = frame
            self.toolsBGView.center = CGPoint(x:self.view.center.x, y:(frame.origin.y + (frame.size.height / 2)))
        }
        self.addShadowToToolsView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- setSelectedTools
    func setSelectedTools(tag:NSInteger){
       
        var drawSketchViewObj:DrawSketchView? = nil
        if gSelectedToolTag != tag{
            if let viewC = self.view as? DrawSketchView{
                drawSketchViewObj = viewC
                viewC.removeSubviewAndTakeScreenShot()
            }
        }
        
        let subViews = self.toolsBGView.subviews
        let imagesArray = [DrawSketchStaticFields.textImage,
                           DrawSketchStaticFields.marksImage,
                           DrawSketchStaticFields.drawImage,
                           DrawSketchStaticFields.colorImage,
                           DrawSketchStaticFields.eraserImage,
                           DrawSketchStaticFields.clearAllImage];
        
        var counter = 0
        
        for xView in subViews
        {
            if xView.tag >= imagesArray.count{
                continue
            }
            xView.backgroundColor = UIColor.white
            
            let label = xView.viewWithTag(22) as? UILabel
            label?.textColor = UIColor.black
            
            let imageView = xView.viewWithTag(11) as? UIImageView
            let imageName = String(format: "%@.png", imagesArray[counter])
            if let image = UIImage(named:imageName){
                imageView?.image = image
            }
            
            if xView.tag == tag{
                label?.textColor = UIColor.white
                xView.backgroundColor = UIColor(colorLiteralRed: 51.0/255.0, green: 130.0/255.0, blue: 1.0, alpha: 1.0)
                let imageNameNew = String(format: "%@_white.png", imagesArray[tag-1])
                if let image = UIImage(named:imageNameNew){
                    imageView?.image = image
                }
            }
            
            if tag == DrawSketchStaticFields.ToolBarSelectedField.xMarkSelected{
                drawSketchViewObj?.isXmarkSelected = true
            }else{
                drawSketchViewObj?.isXmarkSelected = false
            }
            
            if tag == DrawSketchStaticFields.ToolBarSelectedField.colorPallateSelected{
                let currentColor = self.currentColorLabel.backgroundColor
                self.currentColorForBrush(color: currentColor!)
            }
            
            if tag != DrawSketchStaticFields.ToolBarSelectedField.drawTextSelected{
                drawSketchViewObj?.isDrawTextSelected = false
            }
            counter += 1
        }
    }
    
    //MARK:- currentColorForBrush
    func currentColorForBrush(color:UIColor){
        if let viewC = self.view as? DrawSketchView{
            viewC.currentColor = color
        }
    }
    
    func setLayerToObject(objectLayer:CALayer){
        objectLayer.masksToBounds = true
        objectLayer.cornerRadius = 4.0
    }
    
    func addShadowToToolsView(){
        
        let shadowPath = UIBezierPath(rect: self.toolsBGView.bounds)
        self.toolsBGView.layer.masksToBounds = false
        self.toolsBGView.layer.shadowColor = UIColor.black.cgColor
        self.toolsBGView.layer.shadowOffset = CGSize(width:0.0, height:5.0)
        self.toolsBGView.layer.shadowOpacity = 0.5
        self.toolsBGView.layer.shadowPath = shadowPath.cgPath
        self.toolsBGView.layer.borderColor = UIColor.gray.cgColor
        self.toolsBGView.layer.borderWidth = 0.5
    }

    func onLongPressGestureAction(sender:UILongPressGestureRecognizer){
        
        let senderView = sender.view
        if sender.state == UIGestureRecognizerState.began{
            
        }else if sender.state == UIGestureRecognizerState.changed{
            
            let frame = senderView?.frame
            
            if Int((frame?.origin.x)!) >= 5 && (frame?.origin.x)! <= (self.view.frame.size.width - 580) && Int((frame?.origin.y)!) >= 69 && (frame?.origin.y)! <= (self.view.frame.size.height - 87.0){
                
                let point = sender.location(in: self.view)
                senderView?.center = point
                
                var senderViewFrame = senderView?.frame
                
                if Int((senderViewFrame?.origin.x)!) <=  5{
                    senderViewFrame?.origin.x = 5
                }
                if (senderViewFrame?.origin.x)! >= (self.view.frame.size.width - 580){
                    senderViewFrame?.origin.x = (self.view.frame.size.width - 580)
                }
                
                if Int((senderViewFrame?.origin.y)!) <=  69{
                    senderViewFrame?.origin.y = 69
                }
                
                if (senderViewFrame?.origin.y)! >= (self.view.frame.size.height - 87){
                    senderViewFrame?.origin.y = (self.view.frame.size.height - 87)
                }
                
                senderView?.frame = senderViewFrame!
            }
            
        }
    }
    
    //MARK:- IBActions
    @IBAction func setBlackColor(sender:AnyObject){
        
        if let viewC = self.view as? DrawSketchView{
            viewC.currentColor = DrawSketchStaticFields.firstColor
        }
        self.blackBtn.setBackgroundImage(UIImage(named:DrawSketchStaticFields.overlayImage), for: .normal)
        self.blueBtn.setBackgroundImage(UIImage(named:""), for: .normal)
        self.greenBtn.setBackgroundImage(UIImage(named:""), for: .normal)
        self.redBtn.setBackgroundImage(UIImage(named:""), for: .normal)
        self.eraserBtn.setBackgroundImage(UIImage(named:""), for: .normal)
    }
    
    @IBAction func setRedColor(sender:AnyObject){
        
        if let viewC = self.view as? DrawSketchView{
            viewC.currentColor = UIColor.red
        }
        self.blackBtn?.setBackgroundImage(UIImage(named:""), for: .normal)
        self.blueBtn?.setBackgroundImage(UIImage(named:""), for: .normal)
        self.greenBtn?.setBackgroundImage(UIImage(named:""), for: .normal)
        self.redBtn?.setBackgroundImage(UIImage(named:DrawSketchStaticFields.overlayImage), for: .normal)
        self.eraserBtn?.setBackgroundImage(UIImage(named:""), for: .normal)
    }
    
    @IBAction func setGreenColor(sender:AnyObject){
        
        if let viewC = self.view as? DrawSketchView{
            viewC.currentColor = UIColor.green
        }
        self.blackBtn?.setBackgroundImage(UIImage(named:""), for: .normal)
        self.blueBtn?.setBackgroundImage(UIImage(named:""), for: .normal)
        self.greenBtn?.setBackgroundImage(UIImage(named:DrawSketchStaticFields.overlayImage), for: .normal)
        self.redBtn?.setBackgroundImage(UIImage(named:""), for: .normal)
        self.eraserBtn?.setBackgroundImage(UIImage(named:""), for: .normal)
    }

    @IBAction func setBlueColor(sender:AnyObject){
        
        self.setSelectedTools(tag: sender.tag)
        let color = self.currentColorLabel.backgroundColor
        self.currentColorForBrush(color: color!)
        self.blackBtn?.setBackgroundImage(UIImage(named:""), for: .normal)
        self.blueBtn?.setBackgroundImage(UIImage(named:DrawSketchStaticFields.overlayImage), for: .normal)
        self.greenBtn?.setBackgroundImage(UIImage(named:""), for: .normal)
        self.redBtn?.setBackgroundImage(UIImage(named:""), for: .normal)
        self.eraserBtn?.setBackgroundImage(UIImage(named:""), for: .normal)
    }
    
    //MARK:- On Erase button action
    @IBAction func setWhiteColor(sender:AnyObject){
        if let viewC = self.view as? DrawSketchView{
            viewC.currentColor = UIColor.clear
        }
        
        self.blackBtn?.setBackgroundImage(UIImage(named:""), for: .normal)
        self.blueBtn?.setBackgroundImage(UIImage(named:""), for: .normal)
        self.greenBtn?.setBackgroundImage(UIImage(named:""), for: .normal)
        self.redBtn?.setBackgroundImage(UIImage(named:""), for: .normal)
        self.eraserBtn?.setBackgroundImage(UIImage(named:DrawSketchStaticFields.overlayImage), for: .normal)
        
        if self.drawTextView?.superview != nil{
            
            self.touchPointOnImage(selectedImagePoint: CGPoint(x:0, y:0))
            self.drawTextView.removeFromSuperview()
            if let viewC = self.view as? DrawSketchView{
                viewC.isDrawTextSelected = false
            }
        }
        self.setSelectedTools(tag: sender.tag)
    }
    
    //MARK:- Clear all button action
    @IBAction func resetAllButtons(sender:AnyObject){

        if let viewC = self.view as? DrawSketchView{
            viewC.removeSubviewAndTakeScreenShot()
        }
        
        let alertView = UIAlertController(title: DrawSketchStaticFields.areYouSureMessage, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let yesAction = UIAlertAction(title: "YES", style: .default, handler: { action -> Void in
           
            if self.drawTextView?.superview != nil
            {
                self.drawTextView?.removeFromSuperview()
                self.drawTextView = nil;
            }
            if let viewC = self.view as? DrawSketchView{
                viewC.drawImageView.image = self.originalImage
                viewC.isDrawTextSelected = false
            }
            self.setSelectedTools(tag: DrawSketchStaticFields.ToolBarSelectedField.colorPallateSelected)
        });
        alertView.addAction(yesAction)
        let noAction = UIAlertAction(title: "NO", style: .cancel, handler:nil)
        alertView.addAction(noAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    //=================================================
    // Save image and return path of saved image
    //=================================================
    func pathForSavedImage(image:UIImage)->String?{
        let imageName = self.image_title
        self.deleteExistingImage(imageName:imageName!)
        
        let imageData = UIImagePNGRepresentation(image)
        if (imageData?.count)! > 0{
            let fullPathToFile = String(format:"%@/%@", self.getDocumentDirPath(), imageName!)
            let created = FileManager.default.createFile(atPath: fullPathToFile, contents: imageData, attributes: nil)
            if created == false{
                print("Failed to write file")
            }
            return fullPathToFile
        }
        return nil
    }
    
    //=================================================
    // Delete saved photo from documents directory
    // Accepts parameter image name if file exists, delets file
    //=================================================
    func deleteExistingImage(imageName:String){
        
        if self.isPhotoExistWithName(name: imageName) == true{
            let fullPathToFile = String(format:"%@/%@", self.getDocumentDirPath(), imageName)
            do{
                try FileManager.default.removeItem(at: URL(string:fullPathToFile)!)
            }catch{
                 print("Failed to remove file")
            }
        }
    }
    
    func deletePhotoImage(){
        var deleteImage = self.image_title
        deleteImage = deleteImage?.replacingOccurrences(of: "SKETCH", with: "Photo")
        self.deleteExistingImage(imageName: deleteImage!)
    }
    
    //=================================================
    // check photo exist with @param name
    //=================================================
    func isPhotoExistWithName(name:String)->Bool{
        let imageName = name
        
        let fullPathToFile = String(format:"%@/%@", self.getDocumentDirPath(), imageName)
        if FileManager.default.fileExists(atPath: fullPathToFile){
            return true
        }
        return false
    }
    
    func getDocumentDirPath()->String{
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return documentsPath
    }
    
    //=================================================
    // Save image
    //=================================================
    func saveData(){
    
        UIGraphicsBeginImageContextWithOptions(self.imageBgView.bounds.size, false, 0.0)
        self.imageBgView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let path = self.pathForSavedImage(image: image!){
            
            print("path : \(path)")
            let userDefaults = UserDefaults.standard
            var previousPath = ""
            
            if self.previosAnnotationImagePath.characters.count > 0 && self.previosAnnotationImagePath.contains("http") == false{
                previousPath = self.previosAnnotationImagePath
            }
            
            if self.isNewSnap == true{
                userDefaults.set(self.image_title, forKey: "newAnnotationImageFilePath")
            }else{
                
                userDefaults.set(NSNumber(value:true), forKey: "IsAnnotationImageSave")
                userDefaults.set(previousPath, forKey: "httpsPath")
                userDefaults.set(self.image_title, forKey: "ReplaceFilePath")
            }
            userDefaults.synchronize()
        }
    }
    
    //MARK:- Save button Action
    @IBAction func on_NavSaveButtonClicked(sender:AnyObject){
        self.saveData()
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Back Button Action
    @IBAction func on_NavCancelButtonClicked(sender:AnyObject){
        self.deletePhotoImage()
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Add Text Button Action
    @IBAction func addTextClicked(sender:AnyObject){
        
        var drawView:DrawSketchView? = nil
        if let viewC = self.view as? DrawSketchView{
            drawView = viewC
        }
        self.setSelectedTools(tag: sender.tag)
        
        if drawView?.isDrawTextSelected == true{
            drawView?.isDrawTextSelected = false
            sender.setImage(UIImage(named:""), for: .normal)
            
            if self.drawTextView.superview != nil{
                self.touchPointOnImage(selectedImagePoint: CGPoint(x:0, y:0))
                self.drawTextView.removeFromSuperview()
            }
        }else{
            self.currentColorForBrush(color: self.currentColorLabel.backgroundColor!)
            drawView?.isDrawTextSelected = true
        }
    }
    
    //MARK:- Color Pallate Button Action
    @IBAction func onColorPickerButtonClicked(sender:AnyObject){
        self.setSelectedTools(tag: sender.tag)
        
        let popoverVC = self.storyboard?.instantiateViewController(withIdentifier: "colorPickerPopover") as? ColorPickerViewController
        popoverVC?.drawSketchDelegate = self
        popoverVC?.preferredContentSize = CGSize(width:284, height:446)
        
        let popOverController = UIPopoverController(contentViewController: popoverVC!)
        popOverController.delegate = self
        let frame = CGRect(x: 545, y: 667, width: 20, height: 20)
        popOverController.present(from: frame, in: self.view, permittedArrowDirections: .any, animated: true)
    }
    
    //MARK:- Color Selected From Pallate Action
    func colorSelectedFromPallete(selectedColor:UIColor){
        self.currentColorForBrush(color: selectedColor)
        self.setSelectedTools(tag: DrawSketchStaticFields.ToolBarSelectedField.colorPallateSelected)
    }

    //MARK:- xMark Button Action
    @IBAction func on_XMarkButtonClicked(sender:AnyObject){
        self.setSelectedTools(tag: sender.tag)
        self.currentColorForBrush(color: UIColor.clear)
    }
  
    //MARK:- POPOverController Delegate
    func popoverControllerShouldDismissPopover(_ popoverController: UIPopoverController) -> Bool{
        return false
    }
    func popoverControllerDidDismissPopover(_ popoverController: UIPopoverController){
        
    }
    
    //MARK: - DrawSketchViewDelegate method
    func touchPointOnImage(selectedImagePoint:CGPoint){
        
        if self.drawTextView != nil{
            if let textView = self.drawTextView.viewWithTag(5) as? UITextView{
                let text = textView.text
                
                var drawView:DrawSketchView? = nil
                if let viewC = self.view as? DrawSketchView{
                    drawView = viewC
                }
                if let image = drawView?.drawText(text: text!, inImage: drawView?.drawImageView.image, atPoint: selectedImagePoint, withRectToWrite: textView.frame){
                    drawView?.drawImageView.image = image
                }
                self.drawTextView.removeFromSuperview()
                self.drawTextView = nil
            }
        }else{
            gSelectedPoint = selectedImagePoint
            
            var x = selectedImagePoint.x
            if x + 200 > 703{
                while(x + 200 > 703){
                    x = x-3
                }
            }
            let lFrame = CGRect(x: x, y: selectedImagePoint.y, width: 200, height: 150)
            self.drawTextView = DrawTextInputView(frame: lFrame)
            self.drawTextView.backgroundColor = UIColor.clear
            let contentView = UIView(frame: lFrame)
            contentView.backgroundColor = UIColor.clear
            self.drawTextView.contentView = contentView
            self.drawTextView.delegate = self
            
            let textView = UITextView(frame: CGRect(x: 20, y: 20, width: 160, height: 110))
            textView.backgroundColor = UIColor.clear
            textView.tag = 5
            textView.font = UIFont.systemFont(ofSize: 17)
            textView.layer.borderColor = UIColor.black.cgColor
            textView.layer.borderWidth = 3.0
            textView.textColor = self.currentColorLabel.backgroundColor
            textView.becomeFirstResponder()
            self.drawTextView.addSubview(textView)
            
            self.view.addSubview(self.drawTextView)
        }
    }
    
    //MARK: - DrawTextInputViewDelegate methods
    func drawTextInputViewDidBeginEditing(textView:DrawTextInputView){
        
    }
    func drawTextInputViewDidEndEditing(textView:DrawTextInputView){
        
        if let textView = self.drawTextView.viewWithTag(5) as? UITextView{
            textView.frame = CGRect(x:0, y:0, width:self.drawTextView.frame.size.width - 40, height:self.drawTextView.frame.size.height - 40)
        }
    }

}

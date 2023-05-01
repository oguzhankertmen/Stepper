//
//  StepProgressBar.swift
//  Stepper
//
//  Created by Oğuzhan Kertmen on 7.02.2023.
//

import UIKit

@IBDesignable
final class StepperView: UIView {
    
    enum StepperType {
        case Numeric
        case Icon
    }
    /// The stepper type selection
    var stepperType: StepperType = .Numeric
    var stepperIcons = [Int:String]()
    /// The number of displayed points in the component
    @IBInspectable var numberOfPoints: Int = 3 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The current selected index
    @IBInspectable var currentIndex: Int = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @objc var completedTillIndex: Int = -1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @objc private var currentSelectedCenterColor = UIColor(red: 101.0/255.0, green: 66.0/255.0, blue: 190.0/255.0, alpha: 1.0)
    @objc private var centerLayerTextColor = UIColor(red: 156.0/255.0, green: 145.0/255.0, blue: 158.0/255.0, alpha: 1.0)
    
    
    private var lineHeight: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @objc private var textDistance: CGFloat = 20.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var _lineHeight: CGFloat {
        get {
            if lineHeight == .zero || lineHeight > bounds.height {
                return bounds.height * 0.4
            }
            return lineHeight
        }
    }
    
    /// The point's radius
    private var radius: CGFloat = 40.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var _radius: CGFloat {
        get {
            if radius == .zero || radius > bounds.height / 2.0 {
                return bounds.height / 2.0
            }
            return radius
        }
    }
    
    /// The text font inside the circles
    @objc private var centerLayerTextFont: UIFont? =  UIFont(name: "Rockwell 45.0", size: 22) ?? UIFont.systemFont(ofSize: 22) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The component's background color
    private var backgroundShapeColor =  UIColor(red: 214.0/255.0, green: 204.0/255.0, blue: 178.0/255.0, alpha: 0.8) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The component selected background color
    private var selectedBackgoundColor = UIColor(red: 101.0/255.0, green: 66.0/255.0, blue: 190.0/255.0, alpha: 1.0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: - Private properties
    
    private var backgroundLayer = CALayer()
    
    private var progressLayer = CAShapeLayer()
    
    private var selectionLayer = CAShapeLayer()
    
    private var clearSelectionLayer = CAShapeLayer()
    
    private var clearLastStateLayer = CAShapeLayer()
    
    private var lastStateLayer = CAShapeLayer()
    
    private var lastStateCenterLayer = CAShapeLayer()
    
    private var selectionCenterLayer = CAShapeLayer()
    
    private var roadToSelectionLayer = CAShapeLayer()
    
    private var clearCentersLayer = CAShapeLayer()
    
    private var maskLayer = CAShapeLayer()
    
    private var centerPoints = [CGPoint]()
    
    private var _textLayers = [Int: CATextLayer]()
    
    private var _customImageLayers = [Int: CALayer]()
    
    private var _imageLayers = [Int: CALayer]()
    
    private var previousIndex: Int = 0
    
    // MARK: - Life cycle
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        layer.addSublayer(clearCentersLayer)
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(progressLayer)
        layer.addSublayer(clearSelectionLayer)
        layer.addSublayer(selectionCenterLayer)
        layer.addSublayer(selectionLayer)
        layer.addSublayer(roadToSelectionLayer)
        progressLayer.mask = maskLayer
        
        contentMode = UIView.ContentMode.redraw
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        completedTillIndex = currentIndex
        
        centerPoints.removeAll()
        
        let distanceBetweenCircles = (bounds.width - (CGFloat(numberOfPoints) * 2 * _radius)) / CGFloat(numberOfPoints - 1)
        
        var xCursor: CGFloat = _radius
        
        
        for _ in 0...(numberOfPoints - 1) {
            centerPoints.append(CGPoint(x: xCursor, y: bounds.height / 2))
            xCursor += 2 * _radius + distanceBetweenCircles
        }
        
        let bgPath = _shapePath(centerPoints, aRadius: _radius, aLineHeight: _lineHeight)
        backgroundLayer = bgPath
        
        switch stepperType {
        case .Numeric:
            renderTextIndexes()
        case .Icon:
            renderCustomImageIndexes()
        }
        renderImageIndexes()
    }
    
    private func renderTextIndexes() {
        if (stepperType == .Numeric) {
            for index in 0...(numberOfPoints - 1) {
                let centerPoint = centerPoints[index]
                
                let textLayer = _textLayer(atIndex: index)
                
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = centerLayerTextFont
                textLayer.fontSize = (centerLayerTextFont?.pointSize)!
                
                if index == currentIndex || index == completedTillIndex {
                    textLayer.foregroundColor = UIColor.white.cgColor
                } else {
                    textLayer.foregroundColor = centerLayerTextColor.cgColor
                }
                
                if index < currentIndex {
                    textLayer.string = ""
                } else {
                    textLayer.string = "\(index + 1)"
                }
                
                textLayer.frame = .init(origin: CGPoint(x: 0.0, y: 0.0), size: textLayer.preferredFrameSize())
                textLayer.frame = CGRect(x: centerPoint.x - textLayer.bounds.width / 2,
                                         y: centerPoint.y - (textLayer.fontSize) / 2 - (textLayer.bounds.height - textLayer.fontSize) / 2,
                                         width: textLayer.bounds.width,
                                         height: textLayer.bounds.height)
                
            }
        }
    }
    
    private func renderImageIndexes() {
        for index in 0...(numberOfPoints - 1) {
            let centerPoint = centerPoints[index]
            
            let imageLayer = _imageLayer(atIndex: index)
            
            imageLayer.contentsScale = UIScreen.main.scale
            
            if (index < currentIndex) {
                imageLayer.isHidden = false
            } else {
                imageLayer.isHidden = true
            }
            
            imageLayer.frame.size = CGSize(width: 21, height: 21)
            
            imageLayer.frame = CGRect(x: centerPoint.x - imageLayer.bounds.width / 2,
                                      y: centerPoint.y - imageLayer.bounds.height / 2,
                                      width: imageLayer.bounds.width,
                                      height: imageLayer.bounds.height)
        }
    }
    
    private func renderCustomImageIndexes() {
        for index in 0...(numberOfPoints - 1) {
            let centerPoint = centerPoints[index]
            
            let customImageLayer = _customImageLayer(atIndex: index)
            
            customImageLayer.contentsScale = UIScreen.main.scale
            
            if !(index < currentIndex) {
                customImageLayer.isHidden = false
            } else {
                customImageLayer.isHidden = true
            }
            
            if (index == numberOfPoints - 1) {
                customImageLayer.frame.size = CGSize(width: 18, height: 20.24)
            } else {
                customImageLayer.frame.size = CGSize(width: 21, height: 21)
            }
            
            customImageLayer.frame = CGRect(x: centerPoint.x - customImageLayer.bounds.width / 2,
                                            y: centerPoint.y - customImageLayer.bounds.height / 2,
                                            width: customImageLayer.bounds.width,
                                            height: customImageLayer.bounds.height)
        }
    }
    
    private func _textLayer(atIndex index: Int) -> CATextLayer {
        
        var textLayer: CATextLayer
        if let _textLayer = _textLayers[index] {
            textLayer = _textLayer
        } else {
            textLayer = CATextLayer()
            _textLayers[index] = textLayer
        }
        layer.addSublayer(textLayer)
        return textLayer
    }
    
    private func _imageLayer(atIndex index: Int) -> CALayer {
        
        var imageLayer: CALayer
        if let _imageLayer = _imageLayers[index] {
            imageLayer = _imageLayer
        } else {
            imageLayer = CALayer()
            //            imageLayer.contents = UIImage(systemName: "star.fill")?.cgImage
            imageLayer.contents = UIImage(named: "doneStep")?.cgImage
            _imageLayers[index] = imageLayer
        }
        layer.addSublayer(imageLayer)
        
        return imageLayer
    }
    
    private func _customImageLayer(atIndex index: Int) -> CALayer {
        var customImagelayer: CALayer
        let uncheckedIconColor = UIColor(red: 156.0/255.0, green: 145.0/255.0, blue: 158.0/255.0, alpha: 1.0)
        let checkedIconColor = UIColor.orange
            if let _customImageLayer = _customImageLayers[index] {
                customImagelayer = _customImageLayer
            } else {
                customImagelayer = CALayer()
                var stepIcon = UIImage(named: stepperIcons[index] ?? "")
                if index <= currentIndex {
                    customImagelayer.contents = stepIcon?.withColor(checkedIconColor)
                } else {
                    customImagelayer.contents = stepIcon?.withColor(uncheckedIconColor)
                }
                _customImageLayers[index] = customImagelayer
            }
        layer.addSublayer(customImagelayer)
        
        return customImagelayer
    }
    
    private func _shapePath(_ centerPoints: [CGPoint], aRadius: CGFloat, aLineHeight: CGFloat) -> CALayer {
        
        let nbPoint = centerPoints.count
        
        for i in 0..<nbPoint{
            let centerPoint = centerPoints[i]
            let shape: UIBezierPath
            let fillLayer = CAShapeLayer()
            shape = UIBezierPath(roundedRect: CGRect(x: centerPoint.x - aRadius, y: centerPoint.y - aRadius, width: 2.0 * aRadius, height: 2.0 * aRadius), cornerRadius: aRadius)
            
            /// Background color set of step points.
            switch stepperType {
            case .Icon:
                if i <= currentIndex {
                    fillLayer.path = shape.cgPath
                    fillLayer.fillColor = UIColor(red: 214.0/255.0, green: 204.0/255.0, blue: 178.0/255.0, alpha: 0.8).cgColor
                    
                }else{
                    fillLayer.path = shape.cgPath
                    fillLayer.fillColor = UIColor(red: 231.0/255.0, green: 229.0/255.0, blue: 232.0/255.0, alpha: 1.0).cgColor
                }
            case .Numeric:
                if i <= currentIndex{
                    if i != currentIndex {
                        fillLayer.path = shape.cgPath
                        fillLayer.fillColor = backgroundShapeColor.cgColor
                    } else {
                        fillLayer.path = shape.cgPath
                        fillLayer.fillColor = UIColor.orange.cgColor
                    }
                }else{
                    fillLayer.path = shape.cgPath
                    fillLayer.fillColor = backgroundShapeColor.cgColor
                }
            }
            layer.addSublayer(fillLayer)
            
            let shapeLayer = CAShapeLayer()
            if nbPoint > 1 && i != nbPoint - 1{
                //design the path
                let path = UIBezierPath()
                let nextPoint = centerPoints[i + 1]
                path.move(to: CGPoint(x: centerPoint.x + aRadius + 10, y: centerPoint.y))
                path.addLine(to: CGPoint(x: nextPoint.x - aRadius - 10, y: nextPoint.y))
                
                //design path in layer
                shapeLayer.path = path.cgPath
                shapeLayer.strokeColor = backgroundShapeColor.cgColor
                shapeLayer.lineWidth = aLineHeight
            }
            layer.addSublayer(shapeLayer)
        }
        return layer
    }
}

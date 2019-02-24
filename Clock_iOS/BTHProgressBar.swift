//
//  BTHProgressBar.swift
//  Clock
//
//  Created by Bergþór Þrastarson on 4.2.2018.
//  Copyright © 2018 Bergþór Þrastarson. All rights reserved.
//

import UIKit

class ProgressItem {
    var name: String = String()
    var progress: Double = Double()
    
    init(name: String, progress: Double) {
        self.name = name
        self.progress = progress
    }
}

@IBDesignable
class BTHProgressBar: UIView {
    
    @IBInspectable
    public var decimals:Int = 5 {
        didSet {
            updateProgress()
        }
    }
    
    var separatorWidth:CGFloat = 0.5
    
    var progressItems = [ProgressItem]() {
        didSet {
            setNeedsLayout()
        }
    }
    
    var progress:Double = 0.0 {
        didSet {
            updateProgress()
            //drawSeparators()
        }
    }
    
    var progressWidth:CGFloat {
        return frame.width * CGFloat(progress)
    }
    
    var decimalMultiplier:Int = 1
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
        progress = 0.27489489145186156
        progressItems = [
            ProgressItem(name: "jan", progress: 0.05),
            ProgressItem(name: "feb", progress: 0.4),
            ProgressItem(name: "mar", progress: 0.6),
            ProgressItem(name: "apr", progress: 0.8),
            ProgressItem(name: "maí", progress: 1.0)
        ]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    var lblPercentage:UILabel = UILabel()
    
    func setup() {
        backgroundColor = UIColor.clear
        layer.borderWidth = separatorWidth
        layer.borderColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1).cgColor

        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.tag = 500
        
        updateProgress()
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addSubview(blurEffectView)
        lblPercentage.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: 15)
        lblPercentage.textColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1)

        lblPercentage.font = UIFont(name: "CourierNewPS-BoldMT", size: 10)
        addSubview(lblPercentage)
        //drawSeparators()

    }
    
    func updateProgress() {
        
        let rounded = (progress*100.0).rounded(to: decimals)
        lblPercentage.text = rounded + "%"
        
        viewWithTag(500)?.frame = CGRect(x: 0, y: 0, width: progressWidth, height: frame.height)
        
        if lblPercentage.frame.width + CGFloat(3) + CGFloat(3) > self.frame.width-progressWidth {
            lblPercentage.frame = CGRect(x: progressWidth-lblPercentage.frame.width-3, y: 3.0, width: intrinsicContentSize.width, height: intrinsicContentSize.height)
        } else {
            lblPercentage.frame = CGRect(x: progressWidth+3, y: 3.0, width: intrinsicContentSize.width, height: intrinsicContentSize.height)
        }

        lblPercentage.sizeToFit()
    }
    
    func drawSeparators() {
        if progressItems.count == 0 {
            return
        }
        for view in subviews {
            if view.tag == 300 || view.tag == 200 {
                view.removeFromSuperview()
            }
        }
        for (index, item) in progressItems.enumerated() {
            let progressInView = frame.width * CGFloat(item.progress)
            var lastProgress:Double
            
            if index == 0 {
                lastProgress = 0
            } else {
                lastProgress = progressItems[index-1].progress
            }
            
            let separatorView = UIView(frame: CGRect(x: progressInView-(separatorWidth/2.0), y: frame.height-15, width: separatorWidth, height: 15))
            separatorView.backgroundColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1)
            separatorView.tag = 200
            
            let lastProgressInView = CGFloat(lastProgress) * frame.width
            
            let cellWidth = progressInView - lastProgressInView
            let progressLabel = UILabel(frame: CGRect(x: lastProgressInView+separatorWidth/2, y: frame.height-15, width: cellWidth-separatorWidth, height: 15))
            progressLabel.text = item.name
            progressLabel.textColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1)
            progressLabel.textAlignment = .center
            
            progressLabel.tag = 300
            progressLabel.numberOfLines = 0
            progressLabel.font = UIFont(name: "CourierNewPS-BoldMT", size: 10)
            if item.progress != 1.0 {
                addSubview(separatorView)
            }
            addSubview(progressLabel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}


extension Double {
    /// Rounds the double to decimal places value
    func rounded(to places:Int) -> String {
        let formatString = "%." + String(places) + "f"
        return String(format: formatString, self)
    }
}

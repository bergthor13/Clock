//
//  ProgressBarCollectionViewCell.swift
//  Clock_iOS
//
//  Created by Bergþór Þrastarson on 9.5.2018.
//  Copyright © 2018 Bergþór Þrastarson. All rights reserved.
//

import UIKit

class ProgressBarCollectionViewCell: UICollectionViewCell {
        
    @IBOutlet weak var progressView: BTHProgressBar!
    var id = -1
    override func layoutSubviews() {
        super.layoutSubviews()
        // drawSeparators er nú kallað sjálfkrafa í progressView.layoutSubviews()
        // óþarft að kalla handvirkt hér
    }
}

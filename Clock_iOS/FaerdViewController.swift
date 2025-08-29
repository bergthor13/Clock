//
//  FaerdViewController.swift
//  Clock_iOS
//
//  Created by Bergþór Þrastarson on 24/01/2019.
//  Copyright © 2019 Bergþór Þrastarson. All rights reserved.
//

import UIKit

class FaerdViewController: UIViewController {
    var timer:Timer?

    var færðCVC: FaerdCollectionViewController!
    lazy var scrollView: UIScrollView = {
        var scroll = UIScrollView(frame: self.view.frame)
        scroll.isPagingEnabled = true
        scroll.isScrollEnabled = true
        scroll.backgroundColor = UIColor.black
        return scroll
    }()
    
    convenience init(image: UIImage) {
        self.init()
        self.view.backgroundColor = UIColor.black
    }
    
    func initializeViews() {
        let collRect = CGRect(x: 0, y: 0, width: self.view.frame.width*3, height: self.view.frame.height)
        
        self.færðCVC = FaerdCollectionViewController(collectionViewLayout:UICollectionViewFlowLayout())
        self.færðCVC.collectionView.frame = collRect
        self.færðCVC.collectionView.isPagingEnabled = true
        self.færðCVC.collectionView.backgroundColor = UIColor.black

        self.scrollView.contentSize = collRect.size
    }
    
    func addSubviews() {
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(færðCVC.collectionView)
    }
    
    func addTapRecognizers() {
        let singleTap = UITapGestureRecognizer(target: self, action:#selector(self.didTapImage(_:)))
        singleTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTap)
    }
    
    @objc func didTapImage(_:Any) {
        self.dismiss(animated: true, completion: nil)
        self.timer?.invalidate()
    }
    
    @objc func didTimeOut(_:Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tryggja að bakgrunnur sé alltaf svartur
        self.view.backgroundColor = UIColor.black
        
        self.timer = Timer.scheduledTimer(timeInterval: 60*5, target: self, selector: #selector(FaerdViewController.didTimeOut(_:)), userInfo: nil, repeats: false)

        self.initializeViews()
        self.addSubviews()
        self.addTapRecognizers()
        self.færðCVC.collectionView.scrollToItem(at: IndexPath(item: 7, section: 0), at: UICollectionView.ScrollPosition.bottom , animated: false)
    }
}

//
//  ViewController.swift
//  Clock
//
//  Created by Bergþór on 19.6.2017.
//  Copyright © 2017 Bergþór Þrastarson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - UI Elements
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var lblStation: UILabel!
    @IBOutlet weak var btnFærð: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblDayName: UILabel!
    @IBOutlet weak var lblTemp: UILabel!
    @IBOutlet weak var progressCollection: UICollectionView!
    @IBOutlet weak var layoutCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imgFaerd: UIImageView!
    var progressCollectionController: ProgressBarCollectionViewController?

    
    // MARK: - Timers
    var timer:Timer?
    var tempTimer:Timer?
    var faerdTimer:Timer?

    // MARK: - Formatters
    var timeFormatter = DateFormatter()
    var dateFormatter = DateFormatter()
    
    // MARK: - Settings
    var showMillis:Bool!
    var showSeconds:Bool!
    var backgroundUpdateTime : TimeInterval = 30.0

    // MARK: - Other
    var lastDay = Date()
    var færðImage:UIImage = UIImage()
    var backgroundImages = [UIImage]()
    var backgroundImageId = 0
    var coordinator: MainCoordinator!
    
    fileprivate func blurBackground() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.insertSubview(blurEffectView, at: 1)
    }
    
    fileprivate func setUpFormatters() {
        if self.showSeconds {
            timeFormatter.timeStyle = .medium
        } else {
            timeFormatter.timeStyle = .short
        }
        timeFormatter.dateStyle = .none
        timeFormatter.locale = Locale(identifier: "is_IS")
        
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "is_IS")
    }
    
    // MARK: - IBActions
    @IBAction func didTapFærð(_ sender: Any) {
        let faerdVC = FaerdViewController(image: færðImage)
        present(faerdVC, animated: true, completion: nil)
    }
    
    @IBAction func didTapTemp(_ sender: Any) {
        let tempVC = TempTrendViewController()
        present(tempVC, animated: true, completion: nil)
        
    }
    
    // MARK: - Initializers
    fileprivate func initializeProgressBars(_ components: DateComponents) {

        progressCollection.dataSource = progressCollectionController
        progressCollection.delegate = progressCollectionController
    }
    
    fileprivate func initializeClock(_ nanoSeconds: Int?) {
        lblTime.adjustsFontSizeToFitWidth = true
        if let nanoSeconds = nanoSeconds {
            DispatchQueue.main.asyncAfter(deadline: .now() + (1 - (Double(nanoSeconds)/1000000000.0))) {
                self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.updateTimeLabel), userInfo: nil, repeats: true)
                self.updateTimeLabel()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.coordinator = MainCoordinator(mainViewController: self)
        self.showSeconds = UserDefaults.standard.bool(forKey: "ShowSeconds")
        self.showMillis = UserDefaults.standard.bool(forKey: "ShowMillis")

        progressCollectionController = ProgressBarCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout(), heightConstraint: layoutCollectionViewHeight)
        let components = Calendar.current.dateComponents([.year, .month, .nanosecond], from: Date())
        setUpFormatters()

        initializeProgressBars(components)
        initializeClock(components.nanosecond)
        
        self.tempTimer = Timer.scheduledTimer(timeInterval:600, target: self, selector: #selector(ViewController.fetchNewTemperature), userInfo: nil, repeats: true)
        fetchNewTemperature()

        self.faerdTimer = Timer.scheduledTimer(timeInterval:600, target: self, selector: #selector(ViewController.fetchNewFaerd), userInfo: nil, repeats: true)
        fetchNewFaerd()
        
        newDay()
        updateTimeLabel()
        blurBackground()
        
        self.timer = Timer.scheduledTimer(timeInterval:backgroundUpdateTime, target: self, selector: #selector(ViewController.updateBackgroundImage), userInfo: nil, repeats: true)
        
        backgroundImages.append(UIImage(named: "plants")!)
        backgroundImages.append(UIImage(named: "leaves")!)
        backgroundImages.append(UIImage(named: "straws")!)
    }
    
    func setShowMillis(showMillis:Bool) {
        self.showMillis = showMillis
    }
    
    func setShowSeconds(showSeconds:Bool) {
        self.showSeconds = showSeconds
        if showSeconds {
            self.timeFormatter.timeStyle = .medium
        } else {
            self.timeFormatter.timeStyle = .short
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.progressCollectionController?.collectionViewLayout.invalidateLayout()
    }
    
    @objc func updateTimeLabel() {
        let date = Date()
                
        let formattedTime = timeFormatter.string(from: date)
        let formattedDate = dateFormatter.string(from: date)
        
        if self.showMillis && self.showSeconds {
            lblTime.text = formattedTime + "." + String(Calendar.current.component(.nanosecond, from: date) / 100000000)
        } else {
            lblTime.text = formattedTime
        }
        lblDate.text = formattedDate
        
        
        if !Calendar.current.isDate(lastDay, inSameDayAs: date) {
            newDay()
        }
        lastDay = date
        progressCollectionController?.updateProgressBars(date: Date())
    }
    
    @objc func updateBackgroundImage() {
        let id = backgroundImageId % backgroundImages.count
        UIView.transition(with: self.imgBackground,
                          duration: 10,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.imgBackground.image = self.backgroundImages[id]
                          },
                          completion: nil)
        self.backgroundImageId += 1
    }
    
    @objc func fetchNewFaerd() {
        guard let url = URL(string: "http://www.vegagerdin.is/vgdata/faerd/faerdarkort/sudvesturland.png") else {
            return
        }
        
        Downloader.downloadImage(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                self.færðImage = UIImage(data: data)!
                let croppingBox = CGRect(x: 0, y: 479, width: 1100, height: 240)
                let croppedImage = self.færðImage.cropped(boundingBox: croppingBox)
                self.imgFaerd.image = croppedImage
            }
        }

    }
    
    @objc func fetchNewTemperature() {
        let tempErrorMsg = "TMP ERR"
        
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 1
        formatter.minimumIntegerDigits = 1
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale.current
        timeFormatter.timeStyle = .short
        
        Vedurstofan.getTemperatureFor(station: 1473) {observation in
            if observation == nil {
                sleep(10)
                Vedurstofan.getTemperatureFor(station: 31475) {observation in
                    if observation?.temperature != nil {
                        let formattedNumber = formatter.string(from: NSNumber(value: (observation?.temperature)!))
                        DispatchQueue.main.async() {
                            self.lblTemp.text = formattedNumber! + "°C"
                            let checkTime = timeFormatter.string(from: Date())
                            let updateTime = timeFormatter.string(from: (observation?.time)!)
                            
                            self.lblStation.text = "Kauptún (\(updateTime)) (\(checkTime))"
                        }
                    } else {
                        DispatchQueue.main.async() {
                            self.lblTemp.text = tempErrorMsg
                            let checkTime = timeFormatter.string(from: Date())
                            
                            self.lblStation.text = "Engin stöð virk (\(checkTime))"
                        }
                    }
                }
            } else {
                let formattedNumber = formatter.string(from: NSNumber(value: (observation?.temperature)!))
                DispatchQueue.main.async() {
                    self.lblTemp.text = formattedNumber! + "°C"
                    let checkTime = timeFormatter.string(from: Date())
                    let updateTime = timeFormatter.string(from: (observation?.time)!)
                    
                    self.lblStation.text = "Straumsvík (\(updateTime)) (\(checkTime))"
                }
            }
            

        }
    }
    
    /*
     * Runs every time at midnight.
     */
    func newDay() {
        //barYear.progressItems = getMonthSeparation(for: components.year!)
        //barMonth.progressItems = getSeparation(start: 1, end: getNumberOfDaysIn(year: components.year!, month: components.month!))
        let sundayIsHoliday = UserDefaults.standard.bool(forKey: "SundayIsHoliday")

        let date = Date()

        let weekday = Calendar.current.component(.weekday, from: date)
        if let day = getDayName(date: date) {
            if let dayName = day["name"] as? String {
                lblDayName.text = dayName
            } else {
                lblDayName.text = ""
            }
            
            if let isHoliday = day["holiday"] as? Bool {
                var shouldHoliday:Bool
                
                if sundayIsHoliday {
                    shouldHoliday = weekday == 1 || isHoliday
                } else {
                    shouldHoliday = isHoliday
                }
                
                set(holiday: shouldHoliday)
            }
        } else {
            if sundayIsHoliday {
                set(holiday: weekday == 1)
            } else {
                set(holiday: false)
            }
            
            lblDayName.text = ""
        }
    }
    
    func set(holiday:Bool) {
        if holiday {
            lblDate.textColor = UIColor(red: 255.0/255.0, green: 75.0/255.0, blue: 75.0/255.0, alpha: 1.0)
        } else {
            lblDate.textColor = UIColor(red: 150.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1.0)
        }
    }
    
    func getDayName(date: Date) -> NSDictionary? {
        let dictionary = NSArray(contentsOfFile: Bundle.main.path(forResource: "Almanak", ofType: "plist")!);
        for day in dictionary! {
            guard let day = day as? NSDictionary else {
                return nil
            }
            
            guard let dayDate = day["date"] as? Date else {
                return nil
            }
            
            if dayDate > Date() {
                return nil
            }
            
            if Calendar.current.isDate(dayDate, inSameDayAs: Date()) {
                return day
            }
        }
        return nil
    }
    
    // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navController = segue.destination as! UINavigationController
        let settingsTVController = navController.topViewController as! SettingsTableViewController
        settingsTVController.coordinator = self.coordinator
     }
 
}

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
    var minuteTimer:Timer?
    var hourTimer:Timer?
    var dayTimer:Timer?
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
    var lastMonth = Date()
    var færðImage:UIImage = UIImage()
    var backgroundImages = [UIImage]()
    var backgroundImageId = 0
    var coordinator: MainCoordinator!
    
    // MARK: - Debug/Testing
    var testDate: Date? // Ef ekki nil, notum þessa dagsetningu í staðinn fyrir Date()
    
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
    
    // MARK: - Debug IBActions
    @IBAction func didTapPreviousDay(_ sender: Any) {
        let currentTestDate = testDate ?? Date()
        testDate = Calendar.current.date(byAdding: .day, value: -1, to: currentTestDate)
        updateForTestDate()
    }
    
    @IBAction func didTapNextDay(_ sender: Any) {
        let currentTestDate = testDate ?? Date()
        testDate = Calendar.current.date(byAdding: .day, value: 1, to: currentTestDate)
        updateForTestDate()
    }
    
    @IBAction func didTapResetToToday(_ sender: Any) {
        testDate = nil
        updateForTestDate()
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
                // Aðal timer fyrir tíma label - hægri uppfærsla
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateTimeLabel), userInfo: nil, repeats: true)
                
                // Mínútu progress bar - hraðasta uppfærsla
                self.minuteTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.updateMinuteProgressBar), userInfo: nil, repeats: true)
                
                // Klukkustund progress bar - miðlungs uppfærsla
                self.hourTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateHourProgressBar), userInfo: nil, repeats: true)
                
                // Dagur, mánuður og ár progress bars - hægasta uppfærsla
                self.dayTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.updateDayProgressBars), userInfo: nil, repeats: true)
                
                self.updateTimeLabel()
                self.updateMinuteProgressBar()
                self.updateHourProgressBar()
                self.updateDayProgressBars()
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
        
        // Setja upphafsgildi fyrir lastMonth
        lastMonth = Date()
        
        self.timer = Timer.scheduledTimer(timeInterval:backgroundUpdateTime, target: self, selector: #selector(ViewController.updateBackgroundImage), userInfo: nil, repeats: true)
        
        backgroundImages.append(UIImage(named: "gos")!)
        backgroundImages.append(UIImage(named: "irland")!)
        backgroundImages.append(UIImage(named: "herad")!)
        backgroundImages.append(UIImage(named: "eyvindara")!)
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
        let date = testDate ?? Date()
                
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
        
        // Athuga hvort mánuður hafi breyst
        if !Calendar.current.isDate(lastMonth, equalTo: date, toGranularity: .month) {
            newMonth()
        }
        
        lastDay = date
        lastMonth = date
    }
    
    @objc func updateMinuteProgressBar() {
        let date = testDate ?? Date()
        progressCollectionController?.updateMinuteProgressBar(date: date)
    }
    
    @objc func updateHourProgressBar() {
        let date = testDate ?? Date()
        progressCollectionController?.updateHourProgressBar(date: date)
    }
    
    @objc func updateDayProgressBars() {
        let date = testDate ?? Date()
        progressCollectionController?.updateDayProgressBars(date: date)
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
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 1
        formatter.minimumIntegerDigits = 1
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale.current
        timeFormatter.timeStyle = .short
        
        let weatherParser = WeatherXMLFetcher()
        weatherParser.fetchXML { weatherData in
            if let data = weatherData {
                DispatchQueue.main.async() {
                    self.lblTemp.text = data.temperature + "°C"
                    let checkTime = timeFormatter.string(from: Date())
                    let updateTime = timeFormatter.string(from: (data.time as Date))
                    
                    self.lblStation.text = "Straumsvík M:(\(updateTime)) A:(\(checkTime))"
                }
            } else {
                let checkTime = timeFormatter.string(from: Date())
                self.lblStation.text = "Engin stöð virk (\(checkTime))"
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

        let date = testDate ?? Date()

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
    
    func updateDayName() {
        // Uppfæra dagsetninguna strax
        newDay()
    }
    
    /*
     * Keyrir í hvert skipti sem mánuður breytist.
     */
    func newMonth() {
        let date = testDate ?? Date()
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        
        // Uppfæra mánaður progress bar með nýjum dagafjölda
        progressCollectionController?.updateMonthProgressBar(year: components.year!, month: components.month!)
        
        print("DEBUG: Mánuður breyttist - uppfærði progress bar fyrir \(components.year!)/\(components.month!)")
    }
    
    func updateForTestDate() {
        // Uppfæra alla skjái fyrir prófunardagsetningu
        let currentDate = testDate ?? Date()
        
        // Uppfæra tíma og dagsetningar (þetta kallar líka á newDay() ef dagurinn breyttist)
        updateTimeLabel()
        
        // Ef við erum að nota test dagsetningu, athuga hvort mánuður hafi breyst
        if testDate != nil {
            if !Calendar.current.isDate(lastMonth, equalTo: currentDate, toGranularity: .month) {
                newMonth()
                lastMonth = currentDate
            }
        }
    }

    func getDayName(date: Date) -> NSDictionary? {
        guard let dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Almanak_separated_by_type", ofType: "plist")!) else {
            return nil
        }
        
        // Fá báða array-a úr nýju skipulaginu
        guard let fastirDagar = dictionary["fastir_dagar"] as? NSArray,
              let breytilegirDagar = dictionary["breytilegir_dagar"] as? NSArray else {
            return nil
        }
        
        // Finna allar færslur fyrir sama dag
        var allEntries: [NSDictionary] = []
        var combinedName = ""
        var isHoliday = false
        
        // Leita í föstum dögum - bera saman aðeins dag og mánuð, ekki ár
        let currentDay = Calendar.current.component(.day, from: date)
        let currentMonth = Calendar.current.component(.month, from: date)
        
        for day in fastirDagar {
            guard let day = day as? NSDictionary else {
                continue
            }
            
            guard let dayDate = day["date"] as? Date else {
                continue
            }
            
            let entryDay = Calendar.current.component(.day, from: dayDate)
            let entryMonth = Calendar.current.component(.month, from: dayDate)
            
            // Bera saman aðeins dag og mánuð fyrir fasta daga
            if entryDay == currentDay && entryMonth == currentMonth {
                allEntries.append(day)
                
                // Sameina nöfn
                if let dayName = day["name"] as? String {
                    if !combinedName.isEmpty {
                        combinedName += "\n"
                    }
                    combinedName += dayName
                }
                
                // Ef einhver færsla er frídagur, þá er dagurinn frídagur
                if let holiday = day["holiday"] as? Bool, holiday {
                    isHoliday = true
                }
            }
        }
        
        // Leita í breytilegum dögum
        for day in breytilegirDagar {
            guard let day = day as? NSDictionary else {
                continue
            }
            
            guard let dayDate = day["date"] as? Date else {
                continue
            }
            
            if dayDate > date {
                continue
            }
            
            if Calendar.current.isDate(dayDate, inSameDayAs: date) {
                allEntries.append(day)
                
                // Sameina nöfn
                if let dayName = day["name"] as? String {
                    if !combinedName.isEmpty {
                        combinedName += "\n"
                    }
                    combinedName += dayName
                }
                
                // Ef einhver færsla er frídagur, þá er dagurinn frídagur
                if let holiday = day["holiday"] as? Bool, holiday {
                    isHoliday = true
                }
            }
        }
        
        // Bæta við vikunúmeri fyrir mánudaga
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        // Mánudagur er weekday == 2 (sunnudagur er 1)
        if weekday == 2 {
            let showWeekNumber = UserDefaults.standard.bool(forKey: "ShowWeekNumber")
            if showWeekNumber {
                let weekOfYear = calendar.component(.weekOfYear, from: date)
                if !combinedName.isEmpty {
                    combinedName += "\n"
                }
                combinedName += "\(weekOfYear). vika"
                print("DEBUG: Bætti við vikunúmeri: \(weekOfYear). vika fyrir mánudag")
            }
        }
                
        // Ef engar færslur fundust en við höfum vikunúmer
        if allEntries.isEmpty && combinedName.isEmpty {
            return nil
        }
        
        // Búa til sameinaða færslu
        let combinedEntry = NSMutableDictionary()
        combinedEntry["name"] = combinedName
        combinedEntry["holiday"] = isHoliday
        combinedEntry["date"] = date
        
        return combinedEntry
    }
    
    deinit {
        timer?.invalidate()
        minuteTimer?.invalidate()
        hourTimer?.invalidate()
        dayTimer?.invalidate()
        tempTimer?.invalidate()
        faerdTimer?.invalidate()
    }
    
    // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navController = segue.destination as! UINavigationController
        let settingsTVController = navController.topViewController as! SettingsTableViewController
        settingsTVController.coordinator = self.coordinator
     }
 
}

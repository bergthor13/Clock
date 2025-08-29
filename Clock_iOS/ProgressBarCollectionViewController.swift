//
//  ProgressBarCollectionViewController.swift
//  Clock_iOS
//
//  Created by Bergþór Þrastarson on 8.5.2018.
//  Copyright © 2018 Bergþór Þrastarson. All rights reserved.
//

import UIKit

private let reuseIdentifier = "progressCell"

struct BAR_ID {
    var YEAR = 0
    var MONTH = 1
    var DAY = 2
    var HOUR = 3
    var MINUTE = 4
}

class ProgressBarCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var heightConstraint:NSLayoutConstraint
    var dateFormatter = DateFormatter()
    var bars = [BTHProgressBar]()

    init(collectionViewLayout layout: UICollectionViewLayout, heightConstraint: NSLayoutConstraint) {
        self.heightConstraint = heightConstraint
        super.init(collectionViewLayout: layout)
        self.initialize()

    }
    
    required init?(coder aDecoder: NSCoder) {
        self.heightConstraint = NSLayoutConstraint()
        super.init(coder: aDecoder)
        self.initialize()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for bar in bars {
            bar.drawSeparators()
        }
    }
    
    func initialize() {
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "is_IS")
        for _ in 1...collectionView(collectionView!, numberOfItemsInSection: 0) {
            bars.append(BTHProgressBar())
        }

    }
    
    func configureMonth(pbar: BTHProgressBar) {
        let components = Calendar.current.dateComponents([.year, .month], from: Date())
        pbar.progressItems = getSeparation(start: 1, end: getNumberOfDaysIn(year: components.year!, month: components.month!))
    }
    
    func configureWeek(pbar: BTHProgressBar) {
        pbar.progressItems = getDayOfWeekSeparation()
    }
    
    func configureDay(pbar: BTHProgressBar) {
        pbar.progressItems = getSeparation(start: 0, end: 23)

    }
    
    func configureHour(pbar: BTHProgressBar) {
        pbar.progressItems = getSeparation(start: 0, end: 59)
    }
    
    func configureMinute(pbar: BTHProgressBar) {
        pbar.progressItems = getSeparation(start: 0, end: 59)
    }
    
    func getDayOfWeekSeparation() -> [ProgressItem]{
        let weekSeparation = getSeparation(start: 1, end: 7)
        for (i, wkd) in dateFormatter.weekdaySymbols.enumerated() {
            weekSeparation[i].name = wkd
        }
        return weekSeparation

    }
    
    func getMonthSeparation(for year:Int) -> [ProgressItem] {
        var monthSum = 0.0
        let daysInYear = getNumberOfDaysIn(year: year)
        var items = [ProgressItem]()
        for month in 1...getNumberOfMonthsIn(year: year) {
            monthSum += Double(getNumberOfDaysIn(year: year, month: month))
            
            let progressItem = ProgressItem(name: dateFormatter.shortStandaloneMonthSymbols[month-1], progress: monthSum/Double(daysInYear))
            items.append(progressItem)
        }
        
        return items
    }
    
    func getSeparation(start:Int, end:Int) -> [ProgressItem] {
        var items = [ProgressItem]()
        var index = 0
        for i in start...end {
            var name = String()
            if i < 10 {
                name = "0"
            }
            items.append(ProgressItem(name: name + String(i), progress: Double(index+1)/Double(end-start+1)))
            index = index + 1
        }
        return items
    }
    
    func getNumberOfMonthsIn(year:Int) -> Int {
        let dateComponents = DateComponents(year: year)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .month, in: .year, for: date)!
        return range.count
    }
    
    func getNumberOfDaysIn(year:Int) -> Int {
        let dateComponents = DateComponents(year: year)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .day, in: .year, for: date)!
        return range.count
    }
    
    func getNumberOfDaysIn(year:Int, month:Int) -> Int {
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    func updateProgressBars(date:Date) {
        updateMinuteProgressBar(date: date)
        updateHourProgressBar(date: date)
        updateDayProgressBars(date: date)
    }
    
    func updateMinuteProgressBar(date:Date) {
        let components = Calendar.current.dateComponents([.nanosecond, .second], from: date)
        let subSecond = Double(components.nanosecond!)/1000000000.0
        let second = Double(components.second!) + subSecond
        
        getProgressBar(id: BAR_ID().MINUTE).progress = second/60.0
    }
    
    func updateHourProgressBar(date:Date) {
        let components = Calendar.current.dateComponents([.nanosecond, .second, .minute], from: date)
        let subSecond = Double(components.nanosecond!)/1000000000.0
        let second = Double(components.second!) + subSecond
        let minute = Double(components.minute!) + second/60.0
        
        getProgressBar(id: BAR_ID().HOUR).progress = minute/60.0
    }
    
    func updateDayProgressBars(date:Date) {
        let components = Calendar.current.dateComponents([.nanosecond, .second, .minute, .hour, .day, .month, .year], from: date)
        let daysInYear = Double(getNumberOfDaysIn(year: components.year!))
        let subSecond = Double(components.nanosecond!)/1000000000.0
        let second = Double(components.second!) + subSecond
        let minute = Double(components.minute!) + second/60.0
        let hour = Double(components.hour!) + minute/60.0
        let day = Double(components.day!) + hour/24.0
        let dayOfYear = Double(Calendar.current.ordinality(of: .day, in: .year, for: date)!) + hour/24.0

        getProgressBar(id: BAR_ID().DAY).progress = hour/24.0
        getProgressBar(id: BAR_ID().MONTH).progress = ((day-1)/Double(getNumberOfDaysIn(year: components.year!, month: components.month!)))
        getProgressBar(id: BAR_ID().YEAR).progress = (dayOfYear - 1) / daysInYear
    }
    
    func updateMonthProgressBar(year: Int, month: Int) {
        let monthBar = getProgressBar(id: BAR_ID().MONTH)
        let daysInMonth = getNumberOfDaysIn(year: year, month: month)
        
        // Uppfæra progressItems með nýjum dagafjölda
        monthBar.progressItems = getSeparation(start: 1, end: daysInMonth)
        
        // Þvinga að teikna merkingarnar aftur
        DispatchQueue.main.async {
            monthBar.drawSeparators()
        }
    }
    
    func getProgressBar(id: Int) -> BTHProgressBar {
        return bars[id]
    }
    
    func removeProgressBar(barId:BAR_ID) {
        
    }
        
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProgressBarCollectionViewCell
        let components = Calendar.current.dateComponents([.year], from: Date())
        
        switch indexPath.row {
            case BAR_ID().YEAR:
                cell.progressView.progressItems = getMonthSeparation(for: components.year!)
                cell.progressView.decimals = 5
                break
            case BAR_ID().MONTH:
                configureMonth(pbar: cell.progressView)
                cell.progressView.decimals = 4
                break
            case BAR_ID().DAY:
                configureDay(pbar: cell.progressView)
                cell.progressView.decimals = 3
                break
            case BAR_ID().HOUR:
                configureHour(pbar: cell.progressView)
                cell.progressView.decimals = 1
                break
            case BAR_ID().MINUTE:
                configureMinute(pbar: cell.progressView)
                cell.progressView.decimals = 0
                break
            default: break
        }

        heightConstraint.constant = collectionView.contentSize.height
        bars[indexPath.row] = cell.progressView
        
        // Tryggja að merkingarnar séu teiknaðar strax þegar cella er búin til
        DispatchQueue.main.async {
            cell.progressView.drawSeparators()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30)
    }

}

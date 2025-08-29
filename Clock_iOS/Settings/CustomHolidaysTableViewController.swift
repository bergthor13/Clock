//
//  CustomHolidaysTableViewController.swift
//  Clock_iOS
//
//  Created by Bergþór Þrastarson on 5.5.2018.
//  Copyright © 2018 Bergþór Þrastarson. All rights reserved.
//

import UIKit

// MARK: - Data Model fyrir frídaga
struct Holiday {
    var name: String
    var date: Date
    var isHoliday: Bool
    let isFixed: Bool // fastir vs breytilegir dagar
    
    init(name: String, date: Date, isHoliday: Bool, isFixed: Bool) {
        self.name = name
        self.date = date
        self.isHoliday = isHoliday
        self.isFixed = isFixed
    }
}

class CustomHolidaysTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    // MARK: - Properties
    var allHolidays: [Holiday] = []
    var holidayDataSource: [Holiday] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setja upp navigation
        self.title = "Sérsniðnir frídagar"
        
        // Bæta við navigation buttons
        setupNavigationButtons()
        
        // Bæta við search bar
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Leita í frídögum..."
        searchController.searchBar.scopeButtonTitles = ["Allir", "Frídagar", "Aðrir dagar", "Breytilegir dagar"]
        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        // Hlaða gögnum
        loadHolidaysFromPlist()
    }
    
    private func setupNavigationButtons() {
        // Add button
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addHolidayTapped))
        
        // Edit button
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        
        navigationItem.rightBarButtonItems = [addButton, editButton]
    }
    
    @objc private func addHolidayTapped() {
        presentAddHolidayAlert()
    }
    
    @objc private func editButtonTapped() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        // Update navigation button
        if tableView.isEditing {
            navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editButtonTapped))]
        } else {
            setupNavigationButtons()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Data Loading
    private func loadHolidaysFromPlist() {
        // First try to load from Documents directory (user edits)
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let customPlistURL = documentsPath.appendingPathComponent("Almanak_separated_by_type.plist")
        
        var dictionary: NSDictionary?
        
        if FileManager.default.fileExists(atPath: customPlistURL.path) {
            dictionary = NSDictionary(contentsOf: customPlistURL)
            print("Hleð úr Documents: \(customPlistURL.path)")
        } else {
            // Fallback to bundle
            guard let bundlePath = Bundle.main.path(forResource: "Almanak_separated_by_type", ofType: "plist") else {
                print("Villa: Gat ekki fundið plist skrá í bundle")
                return
            }
            dictionary = NSDictionary(contentsOfFile: bundlePath)
            print("Hleð úr Bundle: \(bundlePath)")
        }
        
        guard let dict = dictionary else {
            print("Villa: Gat ekki lesið plist skrána")
            return
        }
        
        // Fá báða array-a úr plist skránni
        guard let fastirDagar = dict["fastir_dagar"] as? NSArray,
              let breytilegirDagar = dict["breytilegir_dagar"] as? NSArray else {
            print("Villa: Gat ekki fundið fastir_dagar eða breytilegir_dagar í plist")
            return
        }
        
        var tempHolidays: [Holiday] = []
        
        // Hlaða föstum dögum
        for day in fastirDagar {
            if let dayDict = day as? NSDictionary,
               let name = dayDict["name"] as? String,
               let date = dayDict["date"] as? Date,
               let isHoliday = dayDict["holiday"] as? Bool {
                
                let holiday = Holiday(name: name, date: date, isHoliday: isHoliday, isFixed: true)
                tempHolidays.append(holiday)
            }
        }
        
        // Hlaða breytilegum dögum
        for day in breytilegirDagar {
            if let dayDict = day as? NSDictionary,
               let name = dayDict["name"] as? String,
               let date = dayDict["date"] as? Date,
               let isHoliday = dayDict["holiday"] as? Bool {
                
                let holiday = Holiday(name: name, date: date, isHoliday: isHoliday, isFixed: false)
                tempHolidays.append(holiday)
            }
        }
        
        // Raða eftir dagsetningu
        allHolidays = tempHolidays.sorted { $0.date < $1.date }
        holidayDataSource = allHolidays
        
        print("Hlaðið \(allHolidays.count) frídögum/dögum úr plist skránni")
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return holidayDataSource.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let holidayCount = holidayDataSource.filter { $0.isHoliday }.count
        let totalCount = holidayDataSource.count
        
        if totalCount == allHolidays.count {
            return "\(totalCount) atburðir (\(holidayCount) frídagar)"
        } else {
            // Check what kind of filter is active
            let searchController = navigationItem.searchController
            let activeScope = searchController?.searchBar.scopeButtonTitles?[searchController?.searchBar.selectedScopeButtonIndex ?? 0] ?? "Allir"
            
            switch activeScope {
            case "Frídagar":
                return "\(totalCount) frídagar fundust"
            case "Aðrir dagar":
                return "\(totalCount) aðrir dagar fundust"
            case "Breytilegir dagar":
                return "\(totalCount) breytilegir dagar fundust (\(holidayCount) frídagar)"
            default:
                return "\(totalCount) atburðir fundust (\(holidayCount) frídagar)"
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "holidayCell", for: indexPath) ?? UITableViewCell(style: .subtitle, reuseIdentifier: "holidayCell")
        
        let holiday = holidayDataSource[indexPath.row]
        
        // Setja upp texta
        cell.textLabel?.text = holiday.name
        
        // Setja upp dagsetning í subtitle
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "is_IS")
        cell.detailTextLabel?.text = dateFormatter.string(from: holiday.date)
        
        // Lita texta ef þetta er frídagur
        if holiday.isHoliday {
            cell.textLabel?.textColor = loadHolidayColor()
        } else {
            if #available(iOS 13.0, *) {
                cell.textLabel?.textColor = UIColor.label
            } else {
                cell.textLabel?.textColor = UIColor.black
            }
        }
        
        // Bæta við vísbendingu um hvort þetta er fastur eða breytilegur dagur
        cell.accessoryType = holiday.isFixed ? .none : .detailButton

        return cell
    }
    
    // MARK: - Search and Filter Functions
    
    private func filterHolidays(searchText: String? = nil, scope: String = "Allir") {
        var filteredHolidays = allHolidays
        
        // Filter by scope (Allir, Frídagar, Aðrir dagar, Breytilegir dagar)
        switch scope {
        case "Frídagar":
            filteredHolidays = filteredHolidays.filter { $0.isHoliday }
        case "Aðrir dagar":
            filteredHolidays = filteredHolidays.filter { !$0.isHoliday }
        case "Breytilegir dagar":
            filteredHolidays = filteredHolidays.filter { !$0.isFixed }
        default:
            break // "Allir" - sýna alla
        }
        
        // Filter by search text
        if let searchText = searchText, !searchText.isEmpty {
            filteredHolidays = filteredHolidays.filter { holiday in
                holiday.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        holidayDataSource = filteredHolidays
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        let selectedScope = searchController.searchBar.scopeButtonTitles?[searchController.searchBar.selectedScopeButtonIndex] ?? "Allir"
        filterHolidays(searchText: searchText, scope: selectedScope)
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scopeTitle = searchBar.scopeButtonTitles?[selectedScope] ?? "Allir"
        filterHolidays(searchText: searchBar.text, scope: scopeTitle)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filterHolidays()
    }
 

    // MARK: - Table View Editing
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let holidayToDelete = holidayDataSource[indexPath.row]
            
            // Fjarlægja úr báðum arrays
            if let allIndex = allHolidays.firstIndex(where: { $0.name == holidayToDelete.name && $0.date == holidayToDelete.date }) {
                allHolidays.remove(at: allIndex)
            }
            holidayDataSource.remove(at: indexPath.row)
            
            // Uppfæra table view
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Vista breytingar
            saveToPlist()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if !tableView.isEditing {
            let holiday = holidayDataSource[indexPath.row]
            presentEditHolidayAlert(holiday: holiday, indexPath: indexPath)
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Add/Edit Holiday Functionality
    
    private func presentAddHolidayAlert() {
        let alert = UIAlertController(title: "Bæta við frídegi", message: "Sláðu inn upplýsingar um nýjan frídaga", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Nafn frídagsins"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Dagsetning (dd.mm.yyyy)"
        }
        
        let addAction = UIAlertAction(title: "Bæta við", style: .default) { _ in
            guard let nameText = alert.textFields?[0].text, !nameText.isEmpty,
                  let dateText = alert.textFields?[1].text, !dateText.isEmpty else {
                self.showErrorAlert(message: "Vinsamlegast fylltu út öll svæði")
                return
            }
            
            guard let date = self.parseDate(from: dateText) else {
                self.showErrorAlert(message: "Ógild dagsetning. Notaðu snið: dd.mm.yyyy")
                return
            }
            
            self.addHoliday(name: nameText, date: date)
        }
        
        let cancelAction = UIAlertAction(title: "Hætta við", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func presentEditHolidayAlert(holiday: Holiday, indexPath: IndexPath) {
        let alert = UIAlertController(title: "Breyta frídegi", message: "Breyttu upplýsingum um frídaginn", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = holiday.name
            textField.placeholder = "Nafn frídagsins"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dateString = dateFormatter.string(from: holiday.date)
        
        alert.addTextField { textField in
            textField.text = dateString
            textField.placeholder = "Dagsetning (dd.mm.yyyy)"
        }
        
        // Toggle fyrir holiday status
        let toggleAction = UIAlertAction(title: holiday.isHoliday ? "Gera að venjulegum degi" : "Gera að frídegi", style: .default) { _ in
            self.toggleHolidayStatus(holiday: holiday, indexPath: indexPath)
        }
        
        let saveAction = UIAlertAction(title: "Vista", style: .default) { _ in
            guard let nameText = alert.textFields?[0].text, !nameText.isEmpty,
                  let dateText = alert.textFields?[1].text, !dateText.isEmpty else {
                self.showErrorAlert(message: "Vinsamlegast fylltu út öll svæði")
                return
            }
            
            guard let date = self.parseDate(from: dateText) else {
                self.showErrorAlert(message: "Ógild dagsetning. Notaðu snið: dd.mm.yyyy")
                return
            }
            
            self.editHoliday(at: indexPath, name: nameText, date: date)
        }
        
        let deleteAction = UIAlertAction(title: "Eyða", style: .destructive) { _ in
            self.confirmDeleteHoliday(at: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: "Hætta við", style: .cancel)
        
        alert.addAction(toggleAction)
        alert.addAction(saveAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func addHoliday(name: String, date: Date) {
        let newHoliday = Holiday(name: name, date: date, isHoliday: true, isFixed: true)
        
        allHolidays.append(newHoliday)
        allHolidays.sort { $0.date < $1.date }
        
        filterHolidays() // Refresh filtered data
        saveToPlist()
    }
    
    private func editHoliday(at indexPath: IndexPath, name: String, date: Date) {
        var holiday = holidayDataSource[indexPath.row]
        holiday.name = name
        holiday.date = date
        
        // Update in both arrays
        if let allIndex = allHolidays.firstIndex(where: { $0.name == holidayDataSource[indexPath.row].name && $0.date == holidayDataSource[indexPath.row].date }) {
            allHolidays[allIndex] = holiday
        }
        holidayDataSource[indexPath.row] = holiday
        
        // Re-sort and refresh
        allHolidays.sort { $0.date < $1.date }
        filterHolidays()
        saveToPlist()
    }
    
    private func toggleHolidayStatus(holiday: Holiday, indexPath: IndexPath) {
        var updatedHoliday = holiday
        updatedHoliday.isHoliday = !updatedHoliday.isHoliday
        
        // Update in both arrays
        if let allIndex = allHolidays.firstIndex(where: { $0.name == holiday.name && $0.date == holiday.date }) {
            allHolidays[allIndex] = updatedHoliday
        }
        holidayDataSource[indexPath.row] = updatedHoliday
        
        // Refresh table
        tableView.reloadRows(at: [indexPath], with: .none)
        saveToPlist()
    }
    
    private func confirmDeleteHoliday(at indexPath: IndexPath) {
        let holiday = holidayDataSource[indexPath.row]
        let alert = UIAlertController(title: "Eyða frídegi", message: "Ertu viss um að þú viljir eyða '\(holiday.name)'?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Eyða", style: .destructive) { _ in
            // Delete logic (same as swipe to delete)
            if let allIndex = self.allHolidays.firstIndex(where: { $0.name == holiday.name && $0.date == holiday.date }) {
                self.allHolidays.remove(at: allIndex)
            }
            self.holidayDataSource.remove(at: indexPath.row)
            
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.saveToPlist()
        }
        
        let cancelAction = UIAlertAction(title: "Hætta við", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func parseDate(from string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "is_IS")
        return formatter.date(from: string)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Villa", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Í lagi", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Holiday Color
    
    private func loadHolidayColor() -> UIColor {
        // Try to load from UserDefaults
        if let colorData = UserDefaults.standard.data(forKey: "HolidayColor") {
            do {
                if let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
                    return color
                }
            } catch {
                print("Error loading holiday color: \(error)")
            }
        }
        
        // Default holiday color (red)
        return UIColor(red: 255.0/255.0, green: 75.0/255.0, blue: 75.0/255.0, alpha: 1.0)
    }
    
    // MARK: - Save to Plist
    
    private func saveToPlist() {
        guard let path = Bundle.main.path(forResource: "Almanak_separated_by_type", ofType: "plist"),
              let originalDict = NSMutableDictionary(contentsOfFile: path) else {
            print("Villa: Gat ekki lesið upprunalegu plist skrána")
            return
        }
        
        // Separate fixed and variable holidays
        let fixedHolidays = allHolidays.filter { $0.isFixed }
        let variableHolidays = allHolidays.filter { !$0.isFixed }
        
        // Convert to plist format
        let fixedArray = NSMutableArray()
        for holiday in fixedHolidays {
            let dict = NSMutableDictionary()
            dict["name"] = holiday.name
            dict["date"] = holiday.date
            dict["holiday"] = holiday.isHoliday
            fixedArray.add(dict)
        }
        
        let variableArray = NSMutableArray()
        for holiday in variableHolidays {
            let dict = NSMutableDictionary()
            dict["name"] = holiday.name
            dict["date"] = holiday.date
            dict["holiday"] = holiday.isHoliday
            variableArray.add(dict)
        }
        
        // Update the dictionary
        originalDict["fastir_dagar"] = fixedArray
        originalDict["breytilegir_dagar"] = variableArray
        
        // Save to documents directory (since we can't write to bundle)
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let plistURL = documentsPath.appendingPathComponent("Almanak_separated_by_type.plist")
        
        if originalDict.write(to: plistURL, atomically: true) {
            print("Vista í: \(plistURL.path)")
        } else {
            print("Villa við að vista plist skrá")
        }
    }

}

//
//  Readings.swift
//  Watts-ON
//
//  Created by Diego Silva on 10/21/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class Readings: NSObject {

    
    // ATTRIBUTES
    let dbu:DBUtils = DBUtils()
    
    fileprivate let DATE_FORMAT          = "dd-MM-yyyy"
    fileprivate let TIME_FORMAT          = "HH:mm:ss"
    fileprivate let DEVICE_TOKEN         = "deviceToken"
    fileprivate let LAST_UPDATED         = "lastUpdated"
    fileprivate let READING              = "readings"
    fileprivate let LAST_SUM_READING_VAL = "lastSumReadingVal"
    fileprivate let DEFAULT_SUM_LST_READ = 0.0
    
    fileprivate var directoryPath:String = ""
    fileprivate var filePath:String      = ""
    fileprivate var fileName:String      = ""
    fileprivate var lastUpdated:String   = ""
    fileprivate var locationId:String    = ""

    fileprivate var readings:[String: AnyObject]   = [String: AnyObject]()
    fileprivate var dailyReadings:[String: Double] = [String: Double]()
    fileprivate var days:Array<AnyObject>          = []
    fileprivate var times:Array<String>            = []
    fileprivate var values:Array<AnyObject>        = []
    fileprivate var lastSumReadingVal:Double       = 0.0
    
    
    
    // INITIALIZERS
    init(locationId:String) {
        super.init()

        self.locationId = locationId
        self.setFileName(self.locationId + "_history.json")
        self.loadFilePath()
    }
    
    
    
    /*
        Setters
    */
    internal func setFilePath(_ path:String){
        self.filePath = path
    }
    
    internal func setFileName(_ name:String){
        self.fileName = name
    }
    
    internal func setLastSumReadingVal(_ input:Double){
        print("lastSumReadingVal was \(self.lastSumReadingVal) and is now \(input)")
        self.lastSumReadingVal = input
    }
    
    
    /*
        Getters
    */
    internal func getFilePath() -> String{
        return self.filePath
    }
    
    internal func getFileName() -> String{
        return self.fileName
    }
    
    internal func getTimeOfReadings() -> Array<AnyObject>{
        return self.times as Array<AnyObject>
    }
    
    internal func getValuesOfReadings() -> Array<AnyObject>{
        return self.values
    }
    
    internal func getDays() -> Array<AnyObject>{
        return self.days
    }
    
    internal func getLastSumReadingVal() -> Double{
        return self.lastSumReadingVal
    }
    
    
    
    // FILE STRUCTURE OPERATIONS -  Operations done on class attributes
    /*
        Load the path used to access the path/<deviceId>_history.json file
    */
    internal func loadFilePath(){
        
        // try to access the app's directory to create a file path
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory,
            FileManager.SearchPathDomainMask.allDomainsMask,
            true
            ).first as NSString? {
                self.directoryPath = dir as String
                
                let path = dir.appendingPathComponent(self.getFileName());
                self.setFilePath(path)
        }else{
            "error creating history file"
        }
    }
    
    
    /*
        Check if the file path currently loaded exists
    */
    internal func isFileOk() -> Bool{
        print("\nChecking file at: \(self.getFilePath()) ...")
        
        let checkValidation = FileManager.default
        if (checkValidation.fileExists(atPath: self.getFilePath())){
            return true
        }else{
            return false
        }
    }
    
    
    /*
        Initialize readings file
    
        This class method creates the 'deviceHistory.json' file, once the user create a new device.
        This is file is going to be updated everytime the user adds a new reading or get readings
        sent by a device
    
        The update is done by taking the values of all currently loaded variables and overwriting
        the <device>_history.json
    */
    internal func save(){
        
        let date:String = Date().formattedWith(self.DATE_FORMAT)
        
        // create the file content
        let json = self.buildDatafile(date)
        
        // get local datafile path
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(
                FileManager.SearchPathDirectory.documentDirectory,
                FileManager.SearchPathDomainMask.allDomainsMask,
                true
        ).first as NSString? {
            
                // create a new file on the selected path
                let path = dir.appendingPathComponent(self.getFileName());
                self.setFilePath(path)
                
                // get the path of the file that is going to receive the readings history
                if(self.getFilePath() != ""){
                    
                    // try to write on the file
                    do {
                        try json.write(toFile: self.getFilePath(), atomically: false, encoding: String.Encoding.utf8)
                            print("updated datafile was saved.")
                        
                            // load the content of the newly created file into the the data structures of this class
                            self.loadDataStructure()
                            self.lastUpdated = date
                    }
                    catch {
                        print("error writing on \(self.getFilePath())\(self.getFileName()))")
                    }
                }else{
                    print("There was a problem creating file path")
                }
        }else{
            "error creating history file"
        }
        
    }
    
    
    
    /*
        Build the file content based on the
    */
    internal func buildDatafile(_ date:String) -> String{
        
        // initial history file of readings for a device
        var json:String = ""
        
        // if the file wasn't updated, create a new file, otherwise override existing file
        if(self.lastUpdated == ""){
            print("creating file ...")
            
            json = "{\"\(self.DEVICE_TOKEN)\": \"\(self.locationId)\",\"\(self.LAST_SUM_READING_VAL)\": \(self.DEFAULT_SUM_LST_READ), \"\(self.LAST_UPDATED)\": \"\(date)\", \"\(self.READING)\": {}}"
        }else{
            print("updating existing file ...")
            
            let updatedReadings:String = getUpdatedReadings()
            
            json = "{\"\(self.DEVICE_TOKEN)\": \"\(self.locationId)\",\"\(self.LAST_SUM_READING_VAL)\": \(self.getLastSumReadingVal()),\"\(self.LAST_UPDATED)\": \"\(self.lastUpdated)\",\"\(self.READING)\": \(updatedReadings)}"
        }
        
        return json
    }
    
    
    
    /*
        Load data from the local datafile <device>_history.json into a dictionary of readings divided by day
    */
    internal func loadDataStructure() -> Bool{
        print("\nloading datafile content into data structure ...")
        
        // get raw json file
        if let rawData:String = self.getRawDataFromJsonReadings(){
            
            // serialize json file into a better data structure
            let data = rawData.data(using: String.Encoding.utf8)
            let structuredJson = self.getStructuredJson(data!)
            
            // if dictionary is ok, open the data structure and load the object's variables
            if(structuredJson != nil){
                
                // get data from the locationId_history.json file
                if(!self.readDataFromJsonHistory(structuredJson!)){
                    print("error reading file in json structure")
                }else{
                    return true
                }
            }else{
                print("error serializing json file")
                return false
            }
        }else{
            print("error getting raw json file")
            return false
        }
        
        return false
    }
    
    
    /*
        Release class attributes to free memory to the system
    */
    internal func unloadDataStructure(){
        self.readings      = [String: AnyObject]()
        self.dailyReadings = [String: Double]()
        self.days          = []
        self.times         = []
        self.values        = []
    }
    
    
    
    /*
        Read data from .json
    
        This method gets a json string as input and serialize it, load the current object
        attributes with the that has been gathered from the .json string
    */
    internal func getRawDataFromJsonReadings() -> String?{
        do{
            let readings:NSString = try NSString(contentsOfFile: self.getFilePath(), encoding: String.Encoding.utf8.rawValue)
            
            return readings as String
        }
        catch {
            print("error reading from file")
            
            return nil
        }
    }
    
    
    /*
        Return a dictionary data structure, based on a NSData .json file, incoming from server
    */
    internal func getStructuredJson(_ data:Data) -> Dictionary<String, AnyObject>?{
        
        do {
            if let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? NSDictionary {
                
                if let structuredJson = jsonResult as? Dictionary<String, AnyObject> {
                    print("data dictionary sucessfully created")
                    return structuredJson
                }
            }
        } catch {
            return nil
        }
        
        return nil
    }
    
    
    /*
        Read data from local file <device>_history.json and load the readings data into better data
        structures
    */
    internal func readDataFromJsonHistory(_ json:Dictionary<String, AnyObject>) -> Bool{
        print("\nloading data from json history file into class variables ...")
        
        // load last updated date
        if let lastUpd = json[self.LAST_UPDATED] as? String{
            self.lastUpdated = lastUpd
        }else{
            print("error getting last updated date")
        }
        
        // load last reading value
        if let lastSumRngVal = json[self.LAST_SUM_READING_VAL] as? Double{
            self.setLastSumReadingVal(lastSumRngVal)
        }else{
            print("error converting lastSumReadingVal into an integer.")
        }
    
        // load daily readings
        if let allReadings:[String:AnyObject] = json[self.READING] as? [String:AnyObject]{
            self.readings = allReadings
            self.days = Array(self.readings.keys).sorted() as Array<AnyObject>
            
            return true
        }else{
            print("error loading all readings")
            return false
        }
    }
    
    
    
    /*
        Deletes the local history file from the phone
    */
    internal func deleteDeviceHistoryFile(){
        
        let fileManager = FileManager()
        
        if(self.isFileOk()) {
            do {
                try fileManager.removeItem(atPath: self.getFilePath())
                print("history file was deleted")
            }
            catch {
                print("error deleting file ...")
            }
        } else {
            print("file not found")
        }
    }
    
    
    /*
        Replace current history file by file that came from the cloud. Read the contents of a file
        overwrite it on the current datafile
    */
    internal func replaceCurrentHistoryFile(_ locationData:Data){
        print("\nupdating local datafile with content from the cloud file ...")
        
        // convert NSData into string
        let datastring = NSString(data: locationData, encoding: String.Encoding.utf8.rawValue)
        
        // try to write on file
        do {
            try datastring!.write(toFile: self.getFilePath(), atomically: false, encoding: String.Encoding.utf8.rawValue)
            
            // load the content of the newly created file into the the data structures of this class
            print("local datafile updated with cloud data, loading data structure ...")
            self.loadDataStructure()
        }
        catch {
            print("error writing on \(self.getFilePath())\(self.getFileName()))")
        }
    }
    
    
    /*
        Return the local <device>_history.json file, ready to be uploaded to the app backend
    */
    internal func getDataFile() -> PFFile?{
        print("\ntrying to convert datafile to PFFile ...")
        
        do{
            let readings:NSString = try NSString(contentsOfFile: self.getFilePath(), encoding: String.Encoding.utf8.rawValue)
            
            if let data = readings.data(using: String.Encoding.utf8.rawValue){
                let datafile:PFFile = PFFile(data:data)
                
                return datafile
            }else{
                print("problem converting NSString into NSData")
                return nil
            }
        }
        catch {
            print("problem getting raw datafile")
            return nil
        }
    }
    
    
    /*
        Build a string version of all updated readings for the current history file.
    */
    internal func getUpdatedReadings() -> String{
        
        // open updated readings
        var updatedReadings:String = "{"

        // in case the user deleted all days and all readings
        if(self.days.count == 0){
            updatedReadings += ""
            
        }else if(self.days.count > 0){
            
            // otherwise is a normal update. Get each day
            for i in 0...(self.days.count - 1){
                
                // get a date label
                let date = self.days[i] as! String
                
                // get each reading of a day
                if let dailyReadings:[String:Double] = self.readings[date] as? [String:Double]{
                    let times:Array<String>  = Array(dailyReadings.keys)
                    let values:Array<Double> = Array(dailyReadings.values)
                    
                    if(dailyReadings.count > 0){
                        updatedReadings += "\"\(date)\":{"
                        
                        // insert the value read for each time of the selected day
                        for r in 0...(dailyReadings.count - 1){
                            let time:String = times[r]
                            let value:Double = values[r]
                            
                            // if it is not the last reading of a day adds comma
                            if(r != (dailyReadings.count - 1)){
                                updatedReadings += "\"\(time)\": \(value), "
                            }else{
                                updatedReadings += "\"\(time)\": \(value)"
                            }
                        }
                    }else{
                        print("there are no readings for this day")
                    }
                }else{
                    print("problems selecting day")
                }
                    
                // if its not the last daily reading adds comma
                if(!(i == (self.days.count - 1))){
                    updatedReadings += "},"
                }else{
                    updatedReadings += "}"
                }
            }
        }
        
        // closes updated readings
        updatedReadings += "}"
        
        return updatedReadings
    }
    
    
    
    // FILE CONTENT OPERATIONS -  Operations done on class attributes
    /*
        Iterates through the redings array and show each none, ie, the readings by day
    */
    internal func showAllReadings(){
        print("\nprinting all readings ...")
        
        for dailyR in self.readings{
            print("reading: \(dailyR)")
        }
    }
    
    
    /*
        Get readings by day
    
        This method let the user query for readings of a specific day, load the time of the 
        readings in a the 'times' array and the values in a the 'values' array
    */
    internal func getReadingsByDayAndLoadTime(_ day:String) -> [String: Double]?{
        
        if let dailyR:[String: Double] = self.readings[day] as? [String:Double]{
            self.times  = Array(dailyR.keys)
            self.values = Array(dailyR.values) as Array<AnyObject>
                    
            return dailyR
        }else{
            print("error getting daily reading object")
            return nil
        }
    }
    
    
    
    /*
        Get daily readings
    
        Return a dictionary of objects that cointains all readings of a day
    */
    internal func getDailyReadings(_ day:String) -> [String:Double]? {
    
        if let dailyReadings = self.readings[day] as? [String:Double]{
            return dailyReadings
        }else{
            print("problem getting readings for the selected day")
        }
        
        return nil
    }
    
    
    
    /*
        Check if a date is in a period defined by a start and end dates
    */
    internal func isDateInPeriod(_ startDate:Date, endDate:Date, date:String) -> Bool{
    
        print("\nchecking if a date is in the current goal period ...")
        
        // create a new NSDate with the day label of the readings dictionary
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.DATE_FORMAT
        
        // normalize date format
        let sAuxDate:String = startDate.formattedWith(self.DATE_FORMAT)
        let eAuxDate:String = endDate.formattedWith(self.DATE_FORMAT)
        
        let sDate = dateFormatter.date(from: sAuxDate)
        let eDate = dateFormatter.date(from: eAuxDate)
        
        // get a NSDate object from the date string
        let testDate = dateFormatter.date(from: date)
            
        // get the result of the comparison between the start and end date and the dictionary date
        let resComStart = sDate?.compare(testDate!)
        let resComEnd   = eDate?.compare(testDate!)
            
        // if the date is later or equal to the start date return true
        var compStart = false
        if((resComStart!.hashValue == 0) || (resComStart!.hashValue == 1)){
            compStart = true
        }
            
        // if the date is ealier or equal to the end date return true
        var compEnd = false
        if((resComEnd!.hashValue == 1) || (resComEnd!.hashValue == 2)){
            compEnd = true
        }
        
        // if date beind processed is in the defined period sum the watts that were spent so far
        if(compEnd && compStart){
            return true
        }
        
        return false
    }
    
    
    
    /*
        Get readings by day
    
        This method let the user query for readings of a specific day, load the time of the 
        readings in a the 'times' array and the values in a the 'values' array
    */
    internal func getDaysWithReadingForGoal(_ startDate:Date, endDate:Date) -> Array<AnyObject>{
        
        print("\ngetting list of days within a period of time ...")
        
        // create an array of dates from the startDate to the endDate
        var daysInGoalPeriod:Array<AnyObject> = Array<AnyObject>()
        
        for day in Array(self.readings.keys).sorted(){
            
            // if the date failed one of the tests pops it from the resultant array
            if(self.isDateInPeriod(startDate, endDate: endDate, date: day)){
                daysInGoalPeriod.append(day as AnyObject)
            }
        }
        
        return daysInGoalPeriod
    }
    
    
    
    /*
    Get readings by day
    
        This method let the user query for readings of a specific day, load the time of the
        readings in a the 'times' array and the values in a the 'values' array. The labels are in a shorter format,
        showing only day and month
    */
    internal func getDaysWithReadingForGoalShortFormat(_ startDate:Date, endDate:Date) -> Array<AnyObject>{
        
        print("\ngetting list of days within a period of time ...")
        
        // create an array of dates from the startDate to the endDate
        var daysInGoalPeriod:Array<AnyObject> = Array<AnyObject>()
        
        for day in Array(self.readings.keys).sorted(){
            
            // if the date failed one of the tests pops it from the resultant array
            if(self.isDateInPeriod(startDate, endDate: endDate, date: day)){
                
                let dayInLongFormat = day as NSString
                
                daysInGoalPeriod.append(dayInLongFormat.substring(with: NSRange(location: 0, length: 5)) as AnyObject)
            }
        }
        
        return daysInGoalPeriod
    }
    
    
    
    
    /*
        Calculate and return the amount of watts spent in a period of time
    */
    internal func getWattsSpentInRange(_ startDate:Date, endDate:Date) -> Double{
        print("\ngetting watts spent in period \(startDate) -- \(endDate)")
        
        // create an array of dates from the startDate to the endDate
        var watts:Double = 0.0
        
        for day in Array(self.readings.keys).sorted(){
            print("day \(day)")
            
            // if date is contained in the defined period get the amount of watts of that day
            if(self.isDateInPeriod(startDate, endDate: endDate, date: day)){
                watts += self.getSumOfWattsForDay(day)
            }
        }
        
        print("watts \(watts)")
        
        return watts
    }
    
    
    /*
        Get the sum of watts spent for a day or -1, if the day has no reading
    */
    internal func getSumOfWattsForDay(_ day:String) -> Double{
    
        var dailyWatts = 0.0
        
        // get all readings of the day
        if let dailyReadings:[String:Double] = self.readings[day] as? [String:Double]{
            
            if(dailyReadings.count > 0){
            
                // get time of each reading in an array
                if let times:Array<String> = Array(dailyReadings.keys){
             
                    if(times.count > 0){
                        
                        // get each reading and increment the watts counter
                        for time in times{
                            
                            if let watts:Double = dailyReadings[time]{
                                dailyWatts += watts
                            }else{
                                print("invalid reading")
                            }
                        }
                    
                        return dailyWatts
                    }else{
                        print("there are no readings for the selected day")
                    }
                }
            }else{
                print("there are no daily readings.")
            }
        }
        
        return -1
    }
    
    
    /*
        Get list of values that represent the money spent by day
    */
    internal func getListSpentValuesByDay(_ days:Array<String>, kwh:NSNumber) -> Array<Double>{
        var valuesByDay:Array<Double> = Array<Double>()
    
        for day in days{
            valuesByDay.append(self.getSumOfWattsForDay(day) * kwh.doubleValue)
        }
        
        return valuesByDay
    }
    
    
    /*
        Get list of values that represent the money spent by month
    */
    internal func getListSpentValuesByMonth(_ year:Int, kwh:NSNumber) -> [String:Double]?{
        
        var monthlyExpenses:[String:Double] = [String:Double]()
        
        // initialize list of expenses per month
        monthlyExpenses["01"] = 0.0
        monthlyExpenses["02"] = 0.0
        monthlyExpenses["03"] = 0.0
        monthlyExpenses["04"] = 0.0
        monthlyExpenses["05"] = 0.0
        monthlyExpenses["06"] = 0.0
        monthlyExpenses["07"] = 0.0
        monthlyExpenses["08"] = 0.0
        monthlyExpenses["09"] = 0.0
        monthlyExpenses["10"] = 0.0
        monthlyExpenses["11"] = 0.0
        monthlyExpenses["12"] = 0.0
        
        // set "date" to be equal to the first day of the selected year
        let calendar = Calendar.current
        var components = DateComponents()
        
        components.day = 1
        components.month = 1
        components.year = year
        components.hour = 0
        components.minute = 0
        
        if let d:Date = calendar.date(from: components){
        
            var date = d
            
            // increment "date" by one year to calculate the ending date for the loop
            if let gregorian:Calendar = Calendar(identifier: Calendar.Identifier.gregorian){
                
                var dateComponents = DateComponents()
                dateComponents.year = 1
                
                let endingDate:Date! = (gregorian as NSCalendar).date(byAdding: dateComponents, to: date, options: .matchFirst)
                
                // loop through each date until the ending date is reached
                while(date.compare(endingDate) != ComparisonResult.orderedDescending) {
                    
                    // get the month date being processed
                    let month = date.formattedWith("MM")
                    
                    // get current sum of watts for the selected day
                    let value = self.getSumOfWattsForDay(date.formattedWith(self.DATE_FORMAT))
                    
                    if let montlySum = monthlyExpenses[month]{
                        
                        if(value != -1){
                            monthlyExpenses[month] = montlySum + value
                        }else{
                            monthlyExpenses[month] = montlySum + 0.0
                        }
                    }else{
                        print("weird, could not get montly sum")
                    }
                    
                    // increment the date by 1 day
                    var dateComponents = DateComponents()
                    dateComponents.day = 1
                    date = (gregorian as NSCalendar).date(byAdding: dateComponents, to: date, options: .matchFirst)!
                }
                
            }else{
                print("could not get date")
            }
            
            // aply taxes
            for key in monthlyExpenses.keys{
                
                if let valWithoutTax = monthlyExpenses[key]{
                    
                    monthlyExpenses[key] = valWithoutTax * kwh.doubleValue
                }
            }
            
            return monthlyExpenses
            
        }else{
            print("could not build date for first day of the year")
        }
        

        return nil
    }
    
    
    
    
    /*
        Get list of values that represent the money spent by day, the day being represented on a shorter format
    */
    internal func getListSpentValuesByDayShortFormat(_ days:Array<String>, kwh:NSNumber) -> Array<Double>{
        var valuesByDay:Array<Double> = Array<Double>()
        
        for day in days{
            
            valuesByDay.append(self.getSumOfWattsForDay(day) * kwh.doubleValue)
        }
        
        return valuesByDay
    }
    
    
    
    
    
    
    
    /*
        Let the user insert a new reading manually on a the readings file of a location, on a
        specific date and time. This method checks if the current date is new on the readings 
        array, if it is create a new reading day, otherwise append a new reading at the end of
        the selected daily readings array.
    
        There are two types of inputs, the input of a location with a device (the amount of kw
        spent from the last input until now) and the input of the location without a device, the
        (current value of the sum of 'all kw').
    
        To the input without a device, the lastSumOfReadingsValues is equal to the new input, and
        the reading is equal to (new input - lastSumOfReadingsValues).
    */
    internal func addReading(_ value:Double){
        print("\ntrying to add a new reading manually ...")
        
        if(self.getLastSumReadingVal() == self.DEFAULT_SUM_LST_READ){
            print("inserting first reading of a goal ...")
            
            self.setLastSumReadingVal(value)
            self.appendReading(0.0)
        }else{
            print("inserting new reading for an existent goal ...")
            
            self.appendReading(value - self.lastSumReadingVal)
            self.setLastSumReadingVal(value)
        }
        
        self.save()
    }
    
    
    /*
        If someone makes more than one insertion on the same day, get the specific day array 
        from all readings and insert the new reading at the end of it.
    */
    internal func appendReading(_ value:Double){
        
        let currentDateString = Date().formattedWith(self.DATE_FORMAT)
        let currentTimeString = Date().formattedWith(self.TIME_FORMAT)
        
        if var lastDailyReading:[String:Double] = self.readings[currentDateString] as? [String:Double]{
            
            // append new reading
            lastDailyReading[currentTimeString] = value
            
            self.readings[currentDateString] = lastDailyReading as AnyObject?
        }else{
            print("adding reading to a new day in the history file ...")
            
            var newReading:[String: Double]  = [String: Double]()
            newReading[currentTimeString] = value
            
            self.readings[currentDateString] = newReading as AnyObject?
        }
        
        // update the number of keys in the array
        self.days = Array(self.readings.keys).sorted() as Array<AnyObject>
    }
    
    
    /*
        Updates all readings of a specific day
    */
    internal func updateReadingsByDay(_ day:String, updatedReadings:[String: Double]) -> Bool{
        print("\ntrying to update readings by day ...")
        
        if let odr:[String: Double] = self.readings[day] as? [String:Double]{
            print("old daily readings: \(odr)")
            print("updated readings:   \(updatedReadings)")
            self.readings[day] = updatedReadings as AnyObject?
            
            self.days = Array(self.readings.keys).sorted() as Array<AnyObject>
            self.save()
                    
            return true
        }
        
        return false
    }
    
    
    /*
        Append readings to a specific day
    
        Return:
            true  - new readings were inserted into the local datafile
            false - there wasn't new readings.
    */
    internal func appendReadingsOfDay(_ day:String, newReadings:[String: Double]) -> Bool{
        print("trying to append a set of readings to readings of the day \(day) ..")
        
        var insertedNew:Bool = false
        
        // get current readings of the selected day
        if var cdr:[String: Double] = self.readings[day] as? [String:Double]{
            
            if(cdr.count > 0){
                
                // get time labels of the new readings
                if let serverReadingsTimes:Array<String> = Array(newReadings.keys){
                    
                    // get the time of the last reading for the selected day
                    if let lastReadingTime:String = self.getTimeLastReading(day){
                        
                        // append all readings that were gathered after the time of the last reading
                        for i in 0...(serverReadingsTimes.count - 1){
                            
                            if let time:String = serverReadingsTimes[i]{
                                
                                let result = self.dbu.compareTimeLabels(time, timeBLabel:lastReadingTime)
                                
                                if(result != -1){
                                    
                                    // time from server is later than the last time of the local datafile
                                    if(result == 0){
                                        cdr[time] = newReadings[time]
                                        insertedNew = true
                                        
                                        print("appended new reading into datafile")
                                    }else{
                                        //print("time label is earlier than time of last readings.")
                                    }
                                }else{
                                    //print("trying to insert value for an existing time.")
                                }
                            }else{
                                print("problem converting time label to an array.")
                            }
                        }
                        
                        if(insertedNew){
                            self.createNewDayWithInputs(day, readings:cdr)
                            
                            return true
                        }else{
                            print("there weren't new inputs in this batch of readings")
                        }
                    }else{
                        print("problem getting the time of the last reading of the day")
                    }
                }else{
                    print("problem getting time labels from readings that came from server")
                }
            }else{
                print("daily readings are empty, appending all new readings to daily readings ...")
                self.createNewDayWithInputs(day, readings:newReadings)
                
                return true
            }
        }else{
            print("readings are empty, inserting readings to local datafile ...")
            self.createNewDayWithInputs(day, readings:newReadings)
        
            return true
        }
        
        return false
    }
    
    
    
    /*
        Create a new day with reading values
    
    
        CHECAR ESTE METODO, ACHO QUE ESTÁ CALCULANDO O VALOR DE lastSumReadingVal ERRADO
    */
    internal func createNewDayWithInputs(_ day:String, readings:[String:Double]){
        
        // perfom local datafile insertion operations
        self.readings[day] = readings as AnyObject?
        self.days = Array(self.readings.keys).sorted() as Array<AnyObject>
        
        // get sum of watts from the collection of readings
        var sumWatts = 0.0
        let timeLabels = Array(readings.keys)
        for time in timeLabels{
            if let watts = readings[time]{
                sumWatts += watts
            }else{
                print("problem getting watts for time \(time)")
            }
        }
        
        self.setLastSumReadingVal(sumWatts)
        self.save()
    }
    
    
    
    /*
        Remove all the readings of the specified day
    */
    internal func removeReadingsOfDay(_ day:String){
        print("\nremoving readings of day \(day)...")
        
        self.readings.removeValue(forKey: day)
        
        // if the user erased all readings reset last sum reading val
        if(self.readings.count == 0){
            self.resetLastSumReadingVal()
        }
        
        self.days = Array(self.readings.keys).sorted() as Array<AnyObject>
        
        self.save()
    }
    
    
    /*
        Get the last value of the the last day in the readings array
    */
    internal func getLastReadingsValue() -> Double?{
        print("\ntrying to get the last input of the last day of readings ...")
        
        // get list of all days
        let days:Array<String> = Array(self.readings.keys).sorted()
        if(days.count > 0){
            let lastDay = days.last
            
            // try to get the last day of readings
            if let lastDayOfReadings:[String:Double] = self.readings[lastDay!] as? [String:Double]{
                
                // get the last reading of the last day
                let times:Array<String> = Array(lastDayOfReadings.keys)
                let lastReadingOfDay = lastDayOfReadings[times.last!]
                
                return lastReadingOfDay
            }else{
                print("problem converting last day of readings")
            }
        }else if(days.count == 0){
            return 0.0
        }
        
        return -1
    }
    
    
    
    /*
        Get the time of the last reading of a day
    */
    internal func getTimeLastReading(_ day:String) -> String?{
        print("\ntrying to get the time of the last reading of \(day)")
        
        // get readings of day
        if let readingsOfDay:[String: Double] = self.readings[day] as? [String:Double]{
            
            // get time labels
            if let times:Array<String> = Array(readingsOfDay.keys).sorted(){
            
                if(times.count > 0){
                    // last reading of day
                    
                    return times.last
                }else{
                    print("the selected day has no readings")
                }
            }else{
                print("problem converting time keys into array.")
            }
        }else{
            print("problem getting readings of the selected day")
        }
        
        return nil
    }
    
    
    /*
        Calculate the sum of all readings of the current goal for the last input of a selected day
    */
    internal func getSumLastReadingForDay(_ day:String) -> Double{
        print("\ncalculating the sum of all readings until the last reading of \(day)")
        
        var sumAllReadingsTilDay = 0.0
        
        // get the position of the selected day in the array of days
        var dayPos = -1
        for i in 0...(self.getDays().count - 1){
            
            // get day
            if let day = self.getDays()[i] as? String{
                
                // get the day position in the array
                if(self.getDays()[i] as! String == day){
                    dayPos = i
                }
            }else{
                print("problem converting value form list of days into a string")
            }
        }
        
        // if the selected day is the last one, return the current value of the last reading
        if(dayPos == (self.getDays().count - 1)){
            return self.getLastSumReadingVal()
        }else{
            
            // calculate the sum of reading values for the selected day
           
            
            return self.getLastSumReadingVal() - sumAllReadingsTilDay
        }
    }
    
    
    
    /*
        This method is called when the user was using the app with a monitoring device and
        started using it without it. The sumLastReadingVal is reset to 0 so the new reading (now
        made manually is going to be set as the sumLastReadingVal)
    */
    internal func resetLastSumReadingVal(){
        self.showAllReadings()
        self.setLastSumReadingVal(0.0)
    }
    
    
    
    /*
        Delete all the readings from the startDate until the endDate
    */
    internal func deleteAllReadingsInPeriod(_ startDate:Date, endDate:Date){
        
        for day in Array(self.readings.keys).sorted(){
            if(self.isDateInPeriod(startDate, endDate: endDate, date: day)){
                self.readings.removeValue(forKey: day)
            }
        }
        
        // update the app backend
        DBHelpers.updateLocationData(
            (DBHelpers.currentLocation?.getObId())!,
            dataManager: DBHelpers.currentLocationData!
        )
    }
    
}




// Extends the NSDate class to customize comparisons between NSDate objects
extension Date{
    
    // or an extension function to format your date
    func formattedWith(_ format:String)-> String {
        let formatter = DateFormatter()
        
        //formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)  // you can set GMT time
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
    
    
    // ... other extension methods in system
    
}




// BI FILES
/*
History of readings:

The 'history.json' file keeps the readings since the first day the user started receiving
data from the dataserver, or inserted reading data manually. This is a local file

The field 'lastSumReadingVal' is given by the initial reading from the user regular eletric
monitoring device or by 0, if the user started using the app with a device. This field is updated 
everytime the user make a new reading. It is the sum of all readings of the current location.

File example:
{
    "deviceToken": "asdf1234",
    "sentByDeviceAt": "02-10-2015 -> 06:04",
    "lastSumReadingVal:" 12001,
    "readings": {

            "01-10-2015": {
                "06:00": 30,
                "06:01": 26,
                "06:02": 29
            },
            "02-10-2015": {
                "06:00": 30,
                "06:01": 27,
                "06:02": 28
            }

    }
}
*/


/*
Reading file:

This is the file that comes from the server with readings of a specific device

File example:
{
    "deviceToken": "asdf1234",
    "date": "02-10-2015",
    "time": "06:04",
    "readings": {
        "06:00": 30,
        "06:01": 26,
        "06:02": 29
    }
}
*/

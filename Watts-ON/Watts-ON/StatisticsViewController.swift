//
//  StatisticsViewController.swift
//  Bolt
//
//  Created by Diego Silva on 12/3/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class StatisticsViewController: BaseViewController, UIPickerViewDataSource, UIPickerViewDelegate  {

    
    
    // VARIABLES AND CONSTANTS
    // Containeres
    @IBOutlet weak var todayReadingslineChartView : BarChartView!
    @IBOutlet weak var readingsOfGoalLineChartView : LineChartView!
    @IBOutlet weak var expensesPerCurrentYear: BarChartView!
    @IBOutlet weak var fullHistoryLineChart : LineChartView!
    
    @IBOutlet weak var statsPickder: UIPickerView!
    
    // Other variables
    internal let dbh:DBHelpers = DBHelpers()
    internal let selector:Selector = #selector(StatisticsViewController.goHome)
    
    internal var distanceFromGoal:Double   = 0.0
    internal var selectedStatistic:String  = ""
    internal var availableStatistics:Array<String> = [
        "Consumo de hoje",
        "Consumo durante o objetivo",
        "Gastos mensais",
        "Histórico completo",
    ]
    
    
    
    
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()

        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = self.feu.getHomeNavbarBtn(self.selector, parentVC: self)
        self.customizeStatusBar()
        
        // devices picker
        self.statsPickder.dataSource = self
        self.statsPickder.delegate = self
        
        // UI customizations
        self.feu.roundCorners(self.todayReadingslineChartView, color:self.feu.SUPER_LIGHT_WHITE)
        self.feu.roundCorners(self.readingsOfGoalLineChartView, color:self.feu.SUPER_LIGHT_WHITE)
        self.feu.roundCorners(self.expensesPerCurrentYear, color:self.feu.SUPER_LIGHT_WHITE)
        self.feu.roundCorners(self.fullHistoryLineChart, color:self.feu.SUPER_LIGHT_WHITE)
        
        self.todayReadingslineChartView.delegate = self
        self.readingsOfGoalLineChartView.delegate = self
        self.expensesPerCurrentYear.delegate = self
        self.fullHistoryLineChart.delegate = self
        
        if let distanceFromGoal:Float = self.dbh.getDistanceOfGoal(){
            
            // load daily expenses
            self.lockSwipeRight()
            
            self.distanceFromGoal = Double(distanceFromGoal)
        }else{
            print("could not get current goal")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        self.animateDailyExpenses(self.readingsOfGoalLineChartView, status: self.distanceFromGoal)
        self.statsPickder.selectRow(1, inComponent: 0, animated: true)
    }
    
    
    
    
    //UI
    /*
        Picker view delegate methods
    */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.availableStatistics.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        var msg:String = ""
        
        msg = self.availableStatistics[row]
        
        let formatedDeviceLabel = NSAttributedString(
            string: msg,
            attributes: [
                NSFontAttributeName:UIFont(name: self.feu.SYSTEM_FONT, size: 10.0)!,
                NSForegroundColorAttributeName:self.feu.DARK_WHITE
            ]
        )
        
        return formatedDeviceLabel
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch row{
            case 0:
                self.animateTodaysConsumption()
            
            case 1:
                self.animateDailyExpenses(
                    self.readingsOfGoalLineChartView,
                    status: self.distanceFromGoal
                )
            
            case 2:
                self.animateMonthlyExpenses()
            
            case 3:
                self.animateFullHistory()
            
            default:
                print("statistic is not in the stats list")
            
        }
    }
    
    
    
    
    /*
        Animate today's consumption
    */
    internal func animateTodaysConsumption(){
        
        print("\nanimating data consumption for today ...")
        self.feu.fadeOut(self.readingsOfGoalLineChartView, speed:0.5)
        self.feu.fadeOut(self.fullHistoryLineChart, speed: 0.5)
        self.feu.fadeOut(self.expensesPerCurrentYear, speed: 0.5)
        
        
        // try to get current location datafile manager
        if let curloc = DBHelpers.currentLocationData{
            
            let today:String = Date().formattedWith(self.feu.DATE_FORMAT)
            
            if let readingsOfToday = curloc.getDailyReadings(today){
            
                if(readingsOfToday.count > 0){
                    
                    self.feu.fadeIn(self.todayReadingslineChartView, speed:0.9)
                    
                    print("readings of today \(readingsOfToday)")
                    
                    // get data to fill chart
                    let times = Array(readingsOfToday.keys).sorted()
                    
                    var values:Array<Double> = Array<Double>()
                    
                    for time in times{
                        if let value = readingsOfToday[time]{
                            values.append(value)
                        }
                    }
                    
                    // prepare chart dataset and labels
                    var dataEntries: [BarChartDataEntry] = []
                    
                    for i in 0..<values.count {
                        let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
                        
                        dataEntries.append(dataEntry)
                    }
                    
                    let barChartDataSet = BarChartDataSet(yVals: dataEntries, label: "KW/horário")
                    
                    barChartDataSet.colors = [self.feu.SAFE_COLOR]
                    
                    let barChartData = BarChartData(xVals: times, dataSet: barChartDataSet)
                    
                    self.todayReadingslineChartView.data = barChartData
                    
                    self.todayReadingslineChartView.setVisibleXRangeMaximum(4)
                    
                    self.todayReadingslineChartView.setScaleEnabled(true)
                    
                    self.todayReadingslineChartView.dragEnabled = true
                    
                    self.todayReadingslineChartView.pinchZoomEnabled = true
                    
                    self.todayReadingslineChartView.noDataText = "Nenhuma leitura para hoje"
                    
                    self.todayReadingslineChartView.leftAxis.enabled = true
                    
                    self.todayReadingslineChartView.xAxis.labelPosition = .bottom
                    
                    self.todayReadingslineChartView.descriptionText = ""
                    
                    self.todayReadingslineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
                    
                    self.todayReadingslineChartView.rightAxis.enabled = false
                    
                    self.todayReadingslineChartView.setExtraOffsets(left: 0.0, top: 5.0, right: 30.0, bottom: 5.0)
                    
                    self.todayReadingslineChartView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
                    
                }else{
                    self.infoWindow("Nenhuma leitura foi realizada hoje", title: "Atenção", vc: self)
                }
            }else{
                self.infoWindow("Nenhuma leitura foi realizada hoje.", title: "Sem leituras por enquanto", vc: self)
            }
        }else{
            print("problem getting list of days within goal period")
        }
    }
    
    
    
    
    
    /*
        Animate Expenses x Day
    */
    internal func animateDailyExpenses(_ lineChartView: LineChartView, status:Double){
        
        print("\nanimating chart expenses per day ...")
        self.feu.fadeOut(self.todayReadingslineChartView, speed:0.5)
        self.feu.fadeOut(self.fullHistoryLineChart, speed: 0.5)
        self.feu.fadeOut(self.expensesPerCurrentYear, speed: 0.5)
        
        // if there is a current goal and there is data to build the chart
        if(DBHelpers.currentGoal != nil && (DBHelpers.currentLocationData!.getDays().count > 0)){
            
            self.feu.fadeIn(self.readingsOfGoalLineChartView, speed:0.9)
            
            
            // get the start date of a goal
            if let startDate:Date = (DBHelpers.currentGoal?.getStartingDate() as Date?){
                
                // get the end date of a goal
                if let endDate:Date = (DBHelpers.currentGoal?.getEndDate())! as Date{
                    
                    if let curloc = DBHelpers.currentLocationData{
                        
                        if let daysWithReadings:Array<String> = curloc.getDaysWithReadingForGoal(
                            startDate,
                            endDate: endDate
                            ) as? Array<String>{
                                
                                
                                // create labels for days of period
                                let nDays = Date.getDaysLeft(startDate, endDate: endDate)
                                
                                // get chart's labels
                                let dayLabels = self.feu.getDayLabels(startDate, nDays:nDays)
                                
                                if let kwh = (DBHelpers.currentGoal?.getKWH()){
                                    
                                    // plot the chart if it can get list of days and values
                                    if(dayLabels.count > 0){
                                        
                                        // get list of kwhs by day
                                        let kwhs = curloc.getListSpentValuesByDay(
                                            dayLabels,
                                            kwh:kwh
                                        )
                                        
                                        // build values for chart
                                        let dataset = self.feu.buildDailyReadingsValues(dayLabels, dayWithReadings:daysWithReadings, values:kwhs)
                                        
                                        // set the line chart
                                        self.setChart(
                                            lineChartView,
                                            dataPoints:dayLabels,
                                            values: dataset,
                                            status:status
                                        )
                                        
                                    }else{
                                        print("coult not get getDaysWithReadingForGoal")
                                    }
                                }else{
                                    print("problem to get kwh from current goal")
                                }
                        }else{
                            print("could not get datafile manager for current location")
                        }
                    }else{
                        print("problem getting list of days within goal period")
                    }
                }else{
                    print("problem getting end date")
                }
            }else{
                print("problem getting start date")
            }
        }else{
            print("selected location doesn't have a goal")
            
            self.goHome()
            
            let title = "Atenção"
            let msg = "Nenhuma leitura foi realizada até o momento."
            self.infoWindow(msg, title: title, vc: self)
        }
    }
    
    
    /*
        Set the barchart used to show how much money the user spent on each day in the period defined by the goal
    */
    func setChart(_ lineChartView:LineChartView,dataPoints: [String], values: [Double], status:Double) {
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            
            dataEntries.append(dataEntry)
        }
        
        //let currentYear = NSDate().formattedWith("YYYY")
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "KW/Dia")
        
        self.feu.setFinalProgressAnimationColor(status)
        lineChartDataSet.colors = [self.feu.finalProgressColor]
        lineChartDataSet.drawFilledEnabled = true
        
        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        lineChartView.data = lineChartData
        
        lineChartView.setVisibleXRangeMaximum(4)
        
        lineChartView.setScaleEnabled(true)
        
        lineChartView.dragEnabled = true
        
        lineChartView.pinchZoomEnabled = true
        
        lineChartView.noDataText = "Nenhum dado de leitura encontrado"
        
        lineChartView.leftAxis.enabled = true
        
        lineChartView.xAxis.labelPosition = .bottom
        
        lineChartView.descriptionText = ""
        
        lineChartView.rightAxis.enabled = false
        
        lineChartView.setExtraOffsets(left: 0.0, top: 5.0, right: 30.0, bottom: 5.0)
        
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        lineChartView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    }
    
    
    
    /*
        Montly expenses chart
    */
    internal func animateMonthlyExpenses(){
        
        print("\nanimating chart expenses per month ...")
        self.feu.fadeOut(self.todayReadingslineChartView, speed:0.5)
        self.feu.fadeOut(self.readingsOfGoalLineChartView, speed:0.5)
        self.feu.fadeOut(self.fullHistoryLineChart, speed: 0.5)
        
        // try to get current location datafile manager
        if let curloc = DBHelpers.currentLocationData{
            
            if let curGoal = DBHelpers.currentGoal{
            
                // get sum of expenses per month
                if(curGoal.getKWH() != -1){
                    
                    if let expensesPerMonth:[String:Double] = curloc.getListSpentValuesByMonth(2015, kwh: curGoal.getKWH()){
                    
                        
                        if(expensesPerMonth.count > 0){
                            
                            self.feu.fadeIn(self.expensesPerCurrentYear, speed: 0.9)
                            
                            // get data to build the chart dataset
                            let months         = Array(expensesPerMonth.keys.sorted())
                            var alphaNumLabels = Array<String>()
                            var values         = Array<Double>()
                            
                            // build labels and values
                            for m in months{
                                
                                // build xAxis labels
                                switch m{
                                case "01": alphaNumLabels.append("jan")
                                case "02": alphaNumLabels.append("fev")
                                case "03": alphaNumLabels.append("mar")
                                case "04": alphaNumLabels.append("abr")
                                case "05": alphaNumLabels.append("mai")
                                case "06": alphaNumLabels.append("jun")
                                case "07": alphaNumLabels.append("jul")
                                case "08": alphaNumLabels.append("ago")
                                case "09": alphaNumLabels.append("set")
                                case "10": alphaNumLabels.append("out")
                                case "11": alphaNumLabels.append("nov")
                                case "12": alphaNumLabels.append("dez")
                                default: print("i don't know this month :(")
                                }
                                
                                // build values
                                if let value = expensesPerMonth[m]{
                                    values.append(value)
                                }else{
                                    print("could not get value")
                                }
                            }
                            
                            // prepare chart dataset and labels
                            var dataEntries: [BarChartDataEntry] = []
                            
                            for i in 0..<values.count {
                                let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
                                
                                dataEntries.append(dataEntry)
                            }
                            
                            let barChartDataSet = BarChartDataSet(yVals: dataEntries, label: "R$/Mês")
                            barChartDataSet.colors = [self.feu.SAFE_COLOR]
                            
                            let barChartData = BarChartData(xVals: alphaNumLabels, dataSet: barChartDataSet)
                            
                            // bar chart UI customizations
                            self.expensesPerCurrentYear.data = barChartData
                            
                            self.expensesPerCurrentYear.setVisibleXRangeMaximum(6)
                            
                            self.expensesPerCurrentYear.setScaleEnabled(true)
                            
                            self.expensesPerCurrentYear.dragEnabled = true
                            
                            self.expensesPerCurrentYear.pinchZoomEnabled = true
                            
                            self.expensesPerCurrentYear.leftAxis.enabled = true
                            
                            self.expensesPerCurrentYear.xAxis.labelPosition = .bottom
                            
                            self.expensesPerCurrentYear.descriptionText = ""
                            
                            self.expensesPerCurrentYear.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
                            
                            self.expensesPerCurrentYear.rightAxis.enabled = false
                            
                            self.expensesPerCurrentYear.setExtraOffsets(left: 0.0, top: 5.0, right: 30.0, bottom: 5.0)
                            
                            self.expensesPerCurrentYear.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
                        }else{
                         
                            let title = "Atenção"
                            let msg = "Nenhuma leitura foi realizada até o momento para o objetivo atual"
                            self.infoWindow(msg, title: title, vc: self)
                        }
                    }else{
                        print("could not get expenses per month")
                    }
                }
            }else{
                print("could not get current goal as a Goal object")
            }
        }else{
            print("problem getting list of days within goal period")
        }
    }
    
    
    
    
    /*
        Animate full history chart
    */
    internal func animateFullHistory(){
        print("\nanimating full history of readings ...")
        
        self.feu.fadeOut(self.todayReadingslineChartView, speed:0.5)
        self.feu.fadeOut(self.readingsOfGoalLineChartView, speed:0.5)
        self.feu.fadeOut(self.expensesPerCurrentYear, speed: 0.5)
        
        // try to get current location datafile manager
        if let curloc = DBHelpers.currentLocationData{
            
            if let curGoal = DBHelpers.currentGoal{
                
                if let listOfDays:Array<String> = curloc.getDays() as? Array<String>{
                    
                    self.feu.fadeIn(self.fullHistoryLineChart, speed: 0.9)
                    
                    let expensesPerDay = curloc.getListSpentValuesByDay(listOfDays, kwh: curGoal.getKWH())
                        
                    var dataEntries: [BarChartDataEntry] = []
                        
                    for i in 0..<listOfDays.count {
                        let dataEntry = BarChartDataEntry(value: expensesPerDay[i], xIndex: i)
                        dataEntries.append(dataEntry)
                    }
                        
                    let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "R$/dia")
                        
                    lineChartDataSet.colors = [self.feu.SAFE_COLOR]
                    lineChartDataSet.drawCubicEnabled = true
                    lineChartDataSet.drawFilledEnabled = true
                    lineChartDataSet.drawCirclesEnabled = false
                        
                    let lineChartData = LineChartData(
                        xVals: listOfDays,
                        dataSet: lineChartDataSet
                    )
                        
                    self.fullHistoryLineChart.data = lineChartData
                        
                    self.fullHistoryLineChart.setVisibleXRangeMaximum(4)
                        
                    self.fullHistoryLineChart.setScaleEnabled(true)
                        
                    self.fullHistoryLineChart.dragEnabled = true
                        
                    self.fullHistoryLineChart.pinchZoomEnabled = true
                        
                    self.fullHistoryLineChart.noDataText = "Nenhuma leitura para hoje"
                        
                    self.fullHistoryLineChart.leftAxis.enabled = true
                        
                    self.fullHistoryLineChart.xAxis.labelPosition = .bottom
                        
                    self.fullHistoryLineChart.descriptionText = ""
                        
                    self.fullHistoryLineChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
                        
                    self.fullHistoryLineChart.rightAxis.enabled = false
                        
                    self.fullHistoryLineChart.setExtraOffsets(left: 20.0, top: 5.0, right: 30.0, bottom: 5.0)
                        
                    self.fullHistoryLineChart.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
                }else{
                    self.infoWindow("Nenhuma leitura foi realizada.", title: "Sem leituras por enquanto", vc: self)
                }
            }else{
                print("could not get current goal as a Goal object")
            }
        }else{
            print("problem getting list of days within goal period")
        }
    }
    
    
    
    
    
    
    // NAVIGATION
    /*
        Send the user back to the home screen by dismissing the current page from the pages stack
    */
    internal func goHome(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

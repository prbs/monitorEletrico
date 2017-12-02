//
//  FinishedWithFailureViewController.swift
//  x
//
//  Created by Diego Silva on 11/4/15.
//  Copyright © 2015 SudoCRUD. All rights reserved.
//

import UIKit

class FinishedWithFailureViewController: UIViewController {

    
    // VARIABLES
    // containers
    @IBOutlet weak var outterContainer: UIView!
    @IBOutlet weak var landmarkContainer: UIView!
    
    
    // custom progress bar
    @IBOutlet weak var landmark: UIView!
    @IBOutlet weak var finalLandmark: UIView!
    @IBOutlet weak var movingPointer: UIView!
    @IBOutlet weak var desiredValue: UILabel!
    @IBOutlet weak var progressBar: UIView!
    @IBOutlet weak var progressBarTrail: UIView!
    @IBOutlet weak var estimatedValue: UILabel!

    // bar chart "KW x Day"
    @IBOutlet weak var barChartView: BarChartView!
    internal let BARCHART_ARRAY_COLORS = [
        UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)
    ]
    
    internal let feu:FrontendUtilities = FrontendUtilities()
    internal let bvc:BaseViewController = BaseViewController()
    internal let dbh:DBHelpers = DBHelpers()
    internal var callerViewController:HomeViewController = HomeViewController()
        
        
        
    // INITIALIZERS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FinishedWithFailureViewController.dismissViewOnBackgroundTap))
        self.view.addGestureRecognizer(tapGesture)
        self.view.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
    }
        
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
        
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
        
    
    
    // UI
    /*
        Pop up dialog
    */
    func showInView(_ aView: UIView!, animated: Bool){
            
        aView.addSubview(self.view)
        if animated{
            self.showAnimate()
        }
    }
        
    func showAnimate(){
        
        self.view.frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.size.width,
            height: UIScreen.main.bounds.size.height - self.feu.getNavbarHeight()
        )
        
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
            self.feu.roundCorners(self.outterContainer, color: self.feu.MEDIUM_GREY)
            self.feu.roundCorners(self.landmarkContainer, color: self.feu.SUPER_LIGHT_WHITE)
        });
    }
        
        
    /*
        Close input dialog view
    */
    @IBAction func closePopupFromCloseBtn(_ sender: AnyObject) {
        self.removeAnimate()
    }
        
    func dismissViewOnBackgroundTap(){
        self.removeAnimate()
    }
        
    func removeAnimate(){
        UIView.animate(withDuration: 0.5, animations: {
            
            self.view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.view.alpha = 0;
                
            self.view.frame = CGRect(
                x: self.view.frame.origin.x,
                y: self.view.frame.origin.y + 600,
                width: self.view.frame.size.width,
                height: self.view.frame.size.height
            )
            }, completion:{
                (finished : Bool)  in
                    
                self.callerViewController.openTipDialog(true)
        });
            
    }

    
    /*
        Creates the progress bar animation with an intermediate landmark
    */
    func animateProgressBar(_ progressBar:UIView, progressBarTrail:UIView, progressPointer:UIView, landmark:UIView, finalLandmark:UIView, startValue:Float, landmarkValue:Float, endValue:Float){
        
        let LANDMARK_FADE_IN_SPEED       = 1.1
        let MOVING_POINTER_GROWING_RATIO = CGFloat(0.2)
        let FINAL_LANDMARK_FADE_IN_SPEED = 0.7
        let INITIAL_PROGRESS_COLOR       = self.feu.LIGHT_BLUE
        let INTERMEDIATE_PROGRESS_COLOR  = UIColor.orange
        let FINAL_PROGRESS_COLOR         = UIColor.red
        
        
        //let pBarWidth     = progressBarTrail.frame.width
        let pBarWidth:CGFloat = UIScreen.main.bounds.size.width * 0.8
        let progressRatio = pBarWidth * 0.01
        let valuePoints   = CGFloat(endValue - startValue)
        let landmarkLeftMov = CGFloat(CGFloat(landmarkValue * 100)/valuePoints) * progressRatio
        let landmarkPos = progressBar.frame.origin.x + landmarkLeftMov
        let finalLandmarkPos = progressBar.frame.origin.x + pBarWidth
        
        print("\n\nPROGRESS BAR ANIMATION")
        print("startValue: \(startValue)")
        print("landmarkValue: \(landmarkValue)")
        print("endValue: \(endValue)")
        
        print("\npBarWidth: \(pBarWidth)")
        print("progressRatio: \(progressRatio)")
        print("landmarkPos: \(landmarkPos)")
        print("finalLandmarkPos: \(finalLandmarkPos)")
        
        // Progress bar pointer animation
        UIView.animate(withDuration: 0.01, animations:{
            
            // set the initial value of the progress pointer
            progressPointer.frame = CGRect(
                x: progressPointer.frame.origin.x - landmarkLeftMov,
                y: progressPointer.frame.origin.y,
                width: progressPointer.frame.size.width - MOVING_POINTER_GROWING_RATIO,
                height: progressPointer.frame.size.height - MOVING_POINTER_GROWING_RATIO
            )
            
            // set the initial value of the landmark view
            landmark.frame = CGRect(
                x: landmark.frame.origin.x - landmarkLeftMov,
                y: landmark.frame.origin.y,
                width: landmark.frame.size.width - MOVING_POINTER_GROWING_RATIO,
                height: landmark.frame.size.height - MOVING_POINTER_GROWING_RATIO
            )
        }, completion: {
            (value: Bool) in
                
            // animate pointer to the intermediary position
            UIView.animate(withDuration: LANDMARK_FADE_IN_SPEED, animations:{
                progressPointer.frame = CGRect(
                    x: progressPointer.frame.origin.x + landmarkLeftMov,
                    y: progressPointer.frame.origin.y + (MOVING_POINTER_GROWING_RATIO/2),
                    width: progressPointer.frame.size.width + MOVING_POINTER_GROWING_RATIO,
                    height: progressPointer.frame.size.height + MOVING_POINTER_GROWING_RATIO
                )
                    
                // set the final position of the landmark view
                landmark.frame = CGRect(
                    x: landmark.frame.origin.x + landmarkLeftMov,
                    y: landmark.frame.origin.y,
                    width: landmark.frame.size.width - MOVING_POINTER_GROWING_RATIO,
                    height: landmark.frame.size.height - MOVING_POINTER_GROWING_RATIO
                )
                landmark.alpha = 0.0
                    
            }, completion: {
                (value: Bool) in
                        
                // fade in the intermediate landmark
                UIView.animate(withDuration: LANDMARK_FADE_IN_SPEED, animations:{
                    landmark.isHidden = false
                    landmark.alpha = 1.0
                }, completion: {
                    (value: Bool) in
                                
                    print("start second part of the animation")
                                
                    // animate progress bar to the final position
                    UIView.animate(withDuration: LANDMARK_FADE_IN_SPEED, animations:{
                        progressBar.frame = CGRect(
                            x: progressBar.frame.origin.x,
                            y: progressBar.frame.origin.y,
                            width: pBarWidth,
                            height: progressBar.frame.size.height
                        )
                                    
                        progressBar.backgroundColor = FINAL_PROGRESS_COLOR
                    })
                                
                    // animate pointer to the final position
                    UIView.animate(withDuration: LANDMARK_FADE_IN_SPEED, animations:{
                        progressPointer.frame = CGRect(
                            x: finalLandmarkPos,
                            y: progressPointer.frame.origin.y,
                            width: progressPointer.frame.size.width,
                            height: progressPointer.frame.size.height
                        )
                                    
                        finalLandmark.isHidden = true
                        finalLandmark.alpha = 0.0
                                    
                    }, completion:{
                        (value: Bool) in
                                        
                        // fade in the intermediate landmark
                        UIView.animate(withDuration: FINAL_LANDMARK_FADE_IN_SPEED, animations:{
                            finalLandmark.isHidden = false
                            finalLandmark.alpha = 1.0
                        }, completion:{
                            (value: Bool) in
                                                
                            self.animateExpensesDay()
                        })
                    })
                })
            })
        })

        
        // Progress bar animation
        UIView.animate(withDuration: 0.01, animations:{
            
            // set the initial value of the progress pointer
            progressBar.frame = CGRect(
                x: progressBar.frame.origin.x,
                y: progressBar.frame.origin.y,
                width: progressBar.frame.size.width - landmarkLeftMov,
                height: progressBar.frame.size.height
            )
            
            progressBar.backgroundColor = INITIAL_PROGRESS_COLOR
        }, completion: {
            (value: Bool) in
                
            // animate pointer to the intermediary position
            UIView.animate(withDuration: LANDMARK_FADE_IN_SPEED, animations:{
                progressBar.frame = CGRect(
                    x: progressBar.frame.origin.x,
                    y: progressBar.frame.origin.y,
                    width: progressBar.frame.size.width + landmarkLeftMov,
                    height: progressBar.frame.size.height
                )
                    
                progressBar.backgroundColor = INTERMEDIATE_PROGRESS_COLOR
            })
        })
        
    }
    
    
    
    /*
        Animate Expenses x Day
    */
    internal func animateExpensesDay(){
        
        // if there is a current goal and there is data to build the chart
        if(DBHelpers.currentGoal != nil && (DBHelpers.currentLocationData!.getDays().count > 0)){
            
            // get the start date of a goal
            if let startDate:Date = (DBHelpers.currentGoal?.getStartingDate() as Date?){
                
                // get the end date of a goal
                if let endDate:Date = (DBHelpers.currentGoal?.getStartingDate())! as Date{
                    
                    // animate expenses per day
                    if let days:Array<String> = DBHelpers.currentLocationData!.getDaysWithReadingForGoal(
                            startDate,
                            endDate: endDate
                        ) as? Array<String>{
                            
                            if let kwh = (DBHelpers.currentGoal?.getKWH()){
                                
                                // get list of kwhs by day
                                let kwhs = DBHelpers.currentLocationData!.getListSpentValuesByDay(
                                    days,
                                    kwh:kwh
                                )
                                
                                self.setChart(days, values: kwhs)
                            }else{
                                print("problem to get kwh from current goal")
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
        }
        
    }
    
    
    
    /*
        Set the barchart used to show how much money the user spent on each day in the period defined by the goal
    */
    func setChart(_ dataPoints: [String], values: [Double]) {
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let barChartDataSet = BarChartDataSet(yVals: dataEntries, label: "KW/Dia")
        barChartDataSet.colors = self.BARCHART_ARRAY_COLORS
        
        let barChartData = BarChartData(xVals: dataPoints, dataSet: barChartDataSet)
        self.barChartView.data = barChartData
        
        // customize chart
        self.barChartView.noDataText = "Nenhum dado de leitura encontrado"
        self.barChartView.leftAxis.enabled = false
        self.barChartView.leftAxis.gridColor = UIColor.white
        self.barChartView.xAxis.labelPosition = .bottom
        self.barChartView.descriptionText = ""
        self.barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }
    
    
    
    
    
    // MANDATORY METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



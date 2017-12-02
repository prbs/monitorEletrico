//
//  ChartXAxisRendererRadarChart.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 3/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics
import UIKit

open class ChartXAxisRendererRadarChart: ChartXAxisRenderer
{
    fileprivate weak var _chart: RadarChartView!
    
    public init(viewPortHandler: ChartViewPortHandler, xAxis: ChartXAxis, chart: RadarChartView)
    {
        super.init(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: nil)
        
        _chart = chart
    }
    
    open override func renderAxisLabels(context: CGContext)
    {
        if (!_xAxis.isEnabled || !_xAxis.isDrawLabelsEnabled)
        {
            return
        }
        
        let labelFont = _xAxis.labelFont
        let labelTextColor = _xAxis.labelTextColor
        
        let sliceangle = _chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value to pixels
        let factor = _chart.factor
        
        let center = _chart.centerOffsets
        
        let modulus = _xAxis.axisLabelModulus
        for var i = 0, count = _xAxis.values.count; i < count; i += modulus
        {
            let label = _xAxis.values[i]
            
            if (label == nil)
            {
                continue
            }
            
            let angle = (sliceangle * CGFloat(i) + _chart.rotationAngle).truncatingRemainder(dividingBy: 360.0)
            
            let p = ChartUtils.getPosition(center: center, dist: CGFloat(_chart.yRange) * factor + _xAxis.labelWidth / 2.0, angle: angle)
            
            drawLabel(context: context, label: label!, xIndex: i, x: p.x, y: p.y - _xAxis.labelHeight / 2.0, align: .center, attributes: [NSFontAttributeName: labelFont, NSForegroundColorAttributeName: labelTextColor])
        }
    }
    
    internal func drawLabel(context: CGContext, label: String, xIndex: Int, x: CGFloat, y: CGFloat, align: NSTextAlignment, attributes: [String: NSObject])
    {
        let formattedLabel = _xAxis.valueFormatter?.stringForXValue(xIndex, original: label, viewPortHandler: viewPortHandler) ?? label
        ChartUtils.drawText(context: context, text: formattedLabel, point: CGPoint(x: x, y: y), align: align, attributes: attributes)
    }
    
    open override func renderLimitLines(context: CGContext)
    {
        /// XAxis LimitLines on RadarChart not yet supported.
    }
}

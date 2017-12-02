//
//  BarLineChartViewBase.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 4/3/15.
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

/// Base-class of LineChart, BarChart, ScatterChart and CandleStickChart.
open class BarLineChartViewBase: ChartViewBase, BarLineScatterCandleBubbleChartDataProvider, UIGestureRecognizerDelegate
{
    /// the maximum number of entried to which values will be drawn
    internal var _maxVisibleValueCount = 100
    
    /// flag that indicates if auto scaling on the y axis is enabled
    fileprivate var _autoScaleMinMaxEnabled = false
    fileprivate var _autoScaleLastLowestVisibleXIndex: Int!
    fileprivate var _autoScaleLastHighestVisibleXIndex: Int!
    
    fileprivate var _pinchZoomEnabled = false
    fileprivate var _doubleTapToZoomEnabled = true
    fileprivate var _dragEnabled = true
    
    fileprivate var _scaleXEnabled = true
    fileprivate var _scaleYEnabled = true
    
    /// the color for the background of the chart-drawing area (everything behind the grid lines).
    open var gridBackgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
    
    open var borderColor = UIColor.black
    open var borderLineWidth: CGFloat = 1.0
    
    /// flag indicating if the grid background should be drawn or not
    open var drawGridBackgroundEnabled = true
    
    /// Sets drawing the borders rectangle to true. If this is enabled, there is no point drawing the axis-lines of x- and y-axis.
    open var drawBordersEnabled = false

    /// Sets the minimum offset (padding) around the chart, defaults to 10
    open var minOffset = CGFloat(10.0)
    
    /// the object representing the labels on the y-axis, this object is prepared
    /// in the pepareYLabels() method
    internal var _leftAxis: ChartYAxis!
    internal var _rightAxis: ChartYAxis!
    
    /// the object representing the labels on the x-axis
    internal var _xAxis: ChartXAxis!

    internal var _leftYAxisRenderer: ChartYAxisRenderer!
    internal var _rightYAxisRenderer: ChartYAxisRenderer!
    
    internal var _leftAxisTransformer: ChartTransformer!
    internal var _rightAxisTransformer: ChartTransformer!
    
    internal var _xAxisRenderer: ChartXAxisRenderer!
    
    internal var _tapGestureRecognizer: UITapGestureRecognizer!
    internal var _doubleTapGestureRecognizer: UITapGestureRecognizer!
    #if !os(tvOS)
    internal var _pinchGestureRecognizer: UIPinchGestureRecognizer!
    #endif
    internal var _panGestureRecognizer: UIPanGestureRecognizer!
    
    /// flag that indicates if a custom viewport offset has been set
    fileprivate var _customViewPortEnabled = false
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    deinit
    {
        stopDeceleration()
    }
    
    internal override func initialize()
    {
        super.initialize()
        
        _leftAxis = ChartYAxis(position: .left)
        _rightAxis = ChartYAxis(position: .right)
        
        _xAxis = ChartXAxis()
        
        _leftAxisTransformer = ChartTransformer(viewPortHandler: _viewPortHandler)
        _rightAxisTransformer = ChartTransformer(viewPortHandler: _viewPortHandler)
        
        _leftYAxisRenderer = ChartYAxisRenderer(viewPortHandler: _viewPortHandler, yAxis: _leftAxis, transformer: _leftAxisTransformer)
        _rightYAxisRenderer = ChartYAxisRenderer(viewPortHandler: _viewPortHandler, yAxis: _rightAxis, transformer: _rightAxisTransformer)
        
        _xAxisRenderer = ChartXAxisRenderer(viewPortHandler: _viewPortHandler, xAxis: _xAxis, transformer: _leftAxisTransformer)
        
        _highlighter = ChartHighlighter(chart: self)
        
        _tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BarLineChartViewBase.tapGestureRecognized(_:)))
        _doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BarLineChartViewBase.doubleTapGestureRecognized(_:)))
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2
        _panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(BarLineChartViewBase.panGestureRecognized(_:)))
        
        _panGestureRecognizer.delegate = self
        
        self.addGestureRecognizer(_tapGestureRecognizer)
        self.addGestureRecognizer(_doubleTapGestureRecognizer)
        self.addGestureRecognizer(_panGestureRecognizer)
        
        _doubleTapGestureRecognizer.isEnabled = _doubleTapToZoomEnabled
        _panGestureRecognizer.isEnabled = _dragEnabled

        #if !os(tvOS)
            _pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(BarLineChartViewBase.pinchGestureRecognized(_:)))
            _pinchGestureRecognizer.delegate = self
            self.addGestureRecognizer(_pinchGestureRecognizer)
            _pinchGestureRecognizer.isEnabled = _pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled
        #endif
    }
    
    open override func draw(_ rect: CGRect)
    {
        super.draw(rect)
        
        if (_dataNotSet)
        {
            return
        }
        
        let optionalContext = UIGraphicsGetCurrentContext()
        guard let context = optionalContext else { return }
        
        calcModulus()
        
        if (_xAxisRenderer !== nil)
        {
            _xAxisRenderer!.calcXBounds(chart: self, xAxisModulus: _xAxis.axisLabelModulus)
        }
        if (renderer !== nil)
        {
            renderer!.calcXBounds(chart: self, xAxisModulus: _xAxis.axisLabelModulus)
        }

        // execute all drawing commands
        drawGridBackground(context: context)
        
        if (_leftAxis.isEnabled)
        {
            _leftYAxisRenderer?.computeAxis(yMin: _leftAxis.axisMinimum, yMax: _leftAxis.axisMaximum)
        }
        if (_rightAxis.isEnabled)
        {
            _rightYAxisRenderer?.computeAxis(yMin: _rightAxis.axisMinimum, yMax: _rightAxis.axisMaximum)
        }
        
        _xAxisRenderer?.renderAxisLine(context: context)
        _leftYAxisRenderer?.renderAxisLine(context: context)
        _rightYAxisRenderer?.renderAxisLine(context: context)

        if (_autoScaleMinMaxEnabled)
        {
            let lowestVisibleXIndex = self.lowestVisibleXIndex,
                highestVisibleXIndex = self.highestVisibleXIndex
            
            if (_autoScaleLastLowestVisibleXIndex == nil || _autoScaleLastLowestVisibleXIndex != lowestVisibleXIndex ||
                _autoScaleLastHighestVisibleXIndex == nil || _autoScaleLastHighestVisibleXIndex != highestVisibleXIndex)
            {
                calcMinMax()
                calculateOffsets()
                
                _autoScaleLastLowestVisibleXIndex = lowestVisibleXIndex
                _autoScaleLastHighestVisibleXIndex = highestVisibleXIndex
            }
        }
        
        // make sure the graph values and grid cannot be drawn outside the content-rect
        context.saveGState()

        context.clip(to: _viewPortHandler.contentRect)
        
        if (_xAxis.isDrawLimitLinesBehindDataEnabled)
        {
            _xAxisRenderer?.renderLimitLines(context: context)
        }
        if (_leftAxis.isDrawLimitLinesBehindDataEnabled)
        {
            _leftYAxisRenderer?.renderLimitLines(context: context)
        }
        if (_rightAxis.isDrawLimitLinesBehindDataEnabled)
        {
            _rightYAxisRenderer?.renderLimitLines(context: context)
        }
        
        _xAxisRenderer?.renderGridLines(context: context)
        _leftYAxisRenderer?.renderGridLines(context: context)
        _rightYAxisRenderer?.renderGridLines(context: context)
        
        renderer?.drawData(context: context)
        
        if (!_xAxis.isDrawLimitLinesBehindDataEnabled)
        {
            _xAxisRenderer?.renderLimitLines(context: context)
        }
        if (!_leftAxis.isDrawLimitLinesBehindDataEnabled)
        {
            _leftYAxisRenderer?.renderLimitLines(context: context)
        }
        if (!_rightAxis.isDrawLimitLinesBehindDataEnabled)
        {
            _rightYAxisRenderer?.renderLimitLines(context: context)
        }

        // if highlighting is enabled
        if (valuesToHighlight())
        {
            renderer?.drawHighlighted(context: context, indices: _indicesToHighlight)
        }

        // Removes clipping rectangle
        context.restoreGState()
        
        renderer!.drawExtras(context: context)
        
        _xAxisRenderer.renderAxisLabels(context: context)
        _leftYAxisRenderer.renderAxisLabels(context: context)
        _rightYAxisRenderer.renderAxisLabels(context: context)

        renderer!.drawValues(context: context)

        _legendRenderer.renderLegend(context: context)
        // drawLegend()

        drawMarkers(context: context)

        drawDescription(context: context)
    }
    
    internal func prepareValuePxMatrix()
    {
        _rightAxisTransformer.prepareMatrixValuePx(chartXMin: _chartXMin, deltaX: _deltaX, deltaY: CGFloat(_rightAxis.axisRange), chartYMin: _rightAxis.axisMinimum)
        _leftAxisTransformer.prepareMatrixValuePx(chartXMin: _chartXMin, deltaX: _deltaX, deltaY: CGFloat(_leftAxis.axisRange), chartYMin: _leftAxis.axisMinimum)
    }
    
    internal func prepareOffsetMatrix()
    {
        _rightAxisTransformer.prepareMatrixOffset(_rightAxis.isInverted)
        _leftAxisTransformer.prepareMatrixOffset(_leftAxis.isInverted)
    }
    
    open override func notifyDataSetChanged()
    {
        if (_dataNotSet)
        {
            return
        }

        calcMinMax()
        
        _leftAxis?._defaultValueFormatter = _defaultValueFormatter
        _rightAxis?._defaultValueFormatter = _defaultValueFormatter
        
        _leftYAxisRenderer?.computeAxis(yMin: _leftAxis.axisMinimum, yMax: _leftAxis.axisMaximum)
        _rightYAxisRenderer?.computeAxis(yMin: _rightAxis.axisMinimum, yMax: _rightAxis.axisMaximum)
        
        _xAxisRenderer?.computeAxis(xValAverageLength: _data.xValAverageLength, xValues: _data.xVals)
        
        if (_legend !== nil)
        {
            _legendRenderer?.computeLegend(_data)
        }
        
        calculateOffsets()
        
        setNeedsDisplay()
    }
    
    internal override func calcMinMax()
    {
        if (_autoScaleMinMaxEnabled)
        {
            _data.calcMinMax(start: lowestVisibleXIndex, end: highestVisibleXIndex)
        }
        
        var minLeft = _data.getYMin(.left)
        var maxLeft = _data.getYMax(.left)
        var minRight = _data.getYMin(.right)
        var maxRight = _data.getYMax(.right)
        
        let leftRange = abs(maxLeft - (_leftAxis.isStartAtZeroEnabled ? 0.0 : minLeft))
        let rightRange = abs(maxRight - (_rightAxis.isStartAtZeroEnabled ? 0.0 : minRight))
        
        // in case all values are equal
        if (leftRange == 0.0)
        {
            maxLeft = maxLeft + 1.0
            if (!_leftAxis.isStartAtZeroEnabled)
            {
                minLeft = minLeft - 1.0
            }
        }
        
        if (rightRange == 0.0)
        {
            maxRight = maxRight + 1.0
            if (!_rightAxis.isStartAtZeroEnabled)
            {
                minRight = minRight - 1.0
            }
        }
        
        let topSpaceLeft = leftRange * Double(_leftAxis.spaceTop)
        let topSpaceRight = rightRange * Double(_rightAxis.spaceTop)
        let bottomSpaceLeft = leftRange * Double(_leftAxis.spaceBottom)
        let bottomSpaceRight = rightRange * Double(_rightAxis.spaceBottom)
        
        _chartXMax = Double(_data.xVals.count - 1)
        _deltaX = CGFloat(abs(_chartXMax - _chartXMin))
        
        // Consider sticking one of the edges of the axis to zero (0.0)
        
        if _leftAxis.isStartAtZeroEnabled
        {
            if minLeft < 0.0 && maxLeft < 0.0
            {
                // If the values are all negative, let's stay in the negative zone
                _leftAxis.axisMinimum = min(0.0, !isnan(_leftAxis.customAxisMin) ? _leftAxis.customAxisMin : (minLeft - bottomSpaceLeft))
                _leftAxis.axisMaximum = 0.0
            }
            else if minLeft >= 0.0
            {
                // We have positive values only, stay in the positive zone
                _leftAxis.axisMinimum = 0.0
                _leftAxis.axisMaximum = max(0.0, !isnan(_leftAxis.customAxisMax) ? _leftAxis.customAxisMax : (maxLeft + topSpaceLeft))
            }
            else
            {
                // Stick the minimum to 0.0 or less, and maximum to 0.0 or more (startAtZero for negative/positive at the same time)
                _leftAxis.axisMinimum = min(0.0, !isnan(_leftAxis.customAxisMin) ? _leftAxis.customAxisMin : (minLeft - bottomSpaceLeft))
                _leftAxis.axisMaximum = max(0.0, !isnan(_leftAxis.customAxisMax) ? _leftAxis.customAxisMax : (maxLeft + topSpaceLeft))
            }
        }
        else
        {
            // Use the values as they are
            _leftAxis.axisMinimum = !isnan(_leftAxis.customAxisMin) ? _leftAxis.customAxisMin : (minLeft - bottomSpaceLeft)
            _leftAxis.axisMaximum = !isnan(_leftAxis.customAxisMax) ? _leftAxis.customAxisMax : (maxLeft + topSpaceLeft)
        }
        
        if _rightAxis.isStartAtZeroEnabled
        {
            if minRight < 0.0 && maxRight < 0.0
            {
                // If the values are all negative, let's stay in the negative zone
                _rightAxis.axisMinimum = min(0.0, !isnan(_rightAxis.customAxisMin) ? _rightAxis.customAxisMin : (minRight - bottomSpaceRight))
                _rightAxis.axisMaximum = 0.0
            }
            else if minRight >= 0.0
            {
                // We have positive values only, stay in the positive zone
                _rightAxis.axisMinimum = 0.0
                _rightAxis.axisMaximum = max(0.0, !isnan(_rightAxis.customAxisMax) ? _rightAxis.customAxisMax : (maxRight + topSpaceRight))
            }
            else
            {
                // Stick the minimum to 0.0 or less, and maximum to 0.0 or more (startAtZero for negative/positive at the same time)
                _rightAxis.axisMinimum = min(0.0, !isnan(_rightAxis.customAxisMin) ? _rightAxis.customAxisMin : (minRight - bottomSpaceRight))
                _rightAxis.axisMaximum = max(0.0, !isnan(_rightAxis.customAxisMax) ? _rightAxis.customAxisMax : (maxRight + topSpaceRight))
            }
        }
        else
        {
            _rightAxis.axisMinimum = !isnan(_rightAxis.customAxisMin) ? _rightAxis.customAxisMin : (minRight - bottomSpaceRight)
            _rightAxis.axisMaximum = !isnan(_rightAxis.customAxisMax) ? _rightAxis.customAxisMax : (maxRight + topSpaceRight)
        }
        
        _leftAxis.axisRange = abs(_leftAxis.axisMaximum - _leftAxis.axisMinimum)
        _rightAxis.axisRange = abs(_rightAxis.axisMaximum - _rightAxis.axisMinimum)
    }
    
    internal override func calculateOffsets()
    {
        if (!_customViewPortEnabled)
        {
            var offsetLeft = CGFloat(0.0)
            var offsetRight = CGFloat(0.0)
            var offsetTop = CGFloat(0.0)
            var offsetBottom = CGFloat(0.0)
            
            // setup offsets for legend
            if (_legend !== nil && _legend.isEnabled)
            {
                if (_legend.position == .rightOfChart
                    || _legend.position == .rightOfChartCenter)
                {
                    offsetRight += min(_legend.neededWidth, _viewPortHandler.chartWidth * _legend.maxSizePercent) + _legend.xOffset * 2.0
                }
                if (_legend.position == .leftOfChart
                    || _legend.position == .leftOfChartCenter)
                {
                    offsetLeft += min(_legend.neededWidth, _viewPortHandler.chartWidth * _legend.maxSizePercent) + _legend.xOffset * 2.0
                }
                else if (_legend.position == .belowChartLeft
                    || _legend.position == .belowChartRight
                    || _legend.position == .belowChartCenter)
                {
                    // It's possible that we do not need this offset anymore as it
                    //   is available through the extraOffsets, but changing it can mean
                    //   changing default visibility for existing apps.
                    let yOffset = _legend.textHeightMax
                    
                    offsetBottom += min(_legend.neededHeight + yOffset, _viewPortHandler.chartHeight * _legend.maxSizePercent)
                }
                else if (_legend.position == .aboveChartLeft
                    || _legend.position == .aboveChartRight
                    || _legend.position == .aboveChartCenter)
                {
                    // It's possible that we do not need this offset anymore as it
                    //   is available through the extraOffsets, but changing it can mean
                    //   changing default visibility for existing apps.
                    let yOffset = _legend.textHeightMax
                    
                    offsetTop += min(_legend.neededHeight + yOffset, _viewPortHandler.chartHeight * _legend.maxSizePercent)
                }
            }
            
            // offsets for y-labels
            if (leftAxis.needsOffset)
            {
                offsetLeft += leftAxis.requiredSize().width
            }
            
            if (rightAxis.needsOffset)
            {
                offsetRight += rightAxis.requiredSize().width
            }

            if (xAxis.isEnabled && xAxis.isDrawLabelsEnabled)
            {
                let xlabelheight = xAxis.labelHeight * 2.0
                
                // offsets for x-labels
                if (xAxis.labelPosition == .bottom)
                {
                    offsetBottom += xlabelheight
                }
                else if (xAxis.labelPosition == .top)
                {
                    offsetTop += xlabelheight
                }
                else if (xAxis.labelPosition == .bothSided)
                {
                    offsetBottom += xlabelheight
                    offsetTop += xlabelheight
                }
            }
            
            offsetTop += self.extraTopOffset
            offsetRight += self.extraRightOffset
            offsetBottom += self.extraBottomOffset
            offsetLeft += self.extraLeftOffset

            _viewPortHandler.restrainViewPort(
                offsetLeft: max(self.minOffset, offsetLeft),
                offsetTop: max(self.minOffset, offsetTop),
                offsetRight: max(self.minOffset, offsetRight),
                offsetBottom: max(self.minOffset, offsetBottom))
        }
        
        prepareOffsetMatrix()
        prepareValuePxMatrix()
    }
   

    /// calculates the modulus for x-labels and grid
    internal func calcModulus()
    {
        if (_xAxis === nil || !_xAxis.isEnabled)
        {
            return
        }
        
        if (!_xAxis.isAxisModulusCustom)
        {
            _xAxis.axisLabelModulus = Int(ceil((CGFloat(_data.xValCount) * _xAxis.labelWidth) / (_viewPortHandler.contentWidth * _viewPortHandler.touchMatrix.a)))
        }
        
        if (_xAxis.axisLabelModulus < 1)
        {
            _xAxis.axisLabelModulus = 1
        }
    }
    
    open override func getMarkerPosition(entry e: ChartDataEntry, highlight: ChartHighlight) -> CGPoint
    {
        let dataSetIndex = highlight.dataSetIndex
        var xPos = CGFloat(e.xIndex)
        var yPos = CGFloat(e.value)
        
        if (self.isKind(of: BarChartView.self))
        {
            let bd = _data as! BarChartData
            let space = bd.groupSpace
            let setCount = _data.dataSetCount
            let i = e.xIndex
            
            if self is HorizontalBarChartView
            {
                // calculate the x-position, depending on datasetcount
                let y = CGFloat(i + i * (setCount - 1) + dataSetIndex) + space * CGFloat(i) + space / 2.0
                
                yPos = y
                
                if let entry = e as? BarChartDataEntry
                {
                    if entry.values != nil && highlight.range !== nil
                    {
                        xPos = CGFloat(highlight.range!.to)
                    }
                    else
                    {
                        xPos = CGFloat(e.value)
                    }
                }
            }
            else
            {
                let x = CGFloat(i + i * (setCount - 1) + dataSetIndex) + space * CGFloat(i) + space / 2.0
                
                xPos = x
                
                if let entry = e as? BarChartDataEntry
                {
                    if entry.values != nil && highlight.range !== nil
                    {
                        yPos = CGFloat(highlight.range!.to)
                    }
                    else
                    {
                        yPos = CGFloat(e.value)
                    }
                }
            }
        }
        
        // position of the marker depends on selected value index and value
        var pt = CGPoint(x: xPos, y: yPos * _animator.phaseY)
        
        getTransformer(_data.getDataSetByIndex(dataSetIndex)!.axisDependency).pointValueToPixel(&pt)
        
        return pt
    }
    
    /// draws the grid background
    internal func drawGridBackground(context: CGContext)
    {
        if (drawGridBackgroundEnabled || drawBordersEnabled)
        {
            context.saveGState()
        }
        
        if (drawGridBackgroundEnabled)
        {
            // draw the grid background
            context.setFillColor(gridBackgroundColor.cgColor)
            context.fill(_viewPortHandler.contentRect)
        }
        
        if (drawBordersEnabled)
        {
            context.setLineWidth(borderLineWidth)
            context.setStrokeColor(borderColor.cgColor)
            context.stroke(_viewPortHandler.contentRect)
        }
        
        if (drawGridBackgroundEnabled || drawBordersEnabled)
        {
            context.restoreGState()
        }
    }
    
    // MARK: - Gestures
    
    fileprivate enum GestureScaleAxis
    {
        case both
        case x
        case y
    }
    
    fileprivate var _isDragging = false
    fileprivate var _isScaling = false
    fileprivate var _gestureScaleAxis = GestureScaleAxis.both
    fileprivate var _closestDataSetToTouch: ChartDataSet!
    fileprivate var _panGestureReachedEdge: Bool = false
    fileprivate weak var _outerScrollView: UIScrollView?
    
    fileprivate var _lastPanPoint = CGPoint() /// This is to prevent using setTranslation which resets velocity
    
    fileprivate var _decelerationLastTime: TimeInterval = 0.0
    fileprivate var _decelerationDisplayLink: CADisplayLink!
    fileprivate var _decelerationVelocity = CGPoint()
    
    @objc fileprivate func tapGestureRecognized(_ recognizer: UITapGestureRecognizer)
    {
        if (_dataNotSet)
        {
            return
        }
        
        if (recognizer.state == UIGestureRecognizerState.ended)
        {
            let h = getHighlightByTouchPoint(recognizer.location(in: self))
            
            if (h === nil || h!.isEqual(self.lastHighlighted))
            {
                self.highlightValue(highlight: nil, callDelegate: true)
                self.lastHighlighted = nil
            }
            else
            {
                self.lastHighlighted = h
                self.highlightValue(highlight: h, callDelegate: true)
            }
        }
    }
    
    @objc fileprivate func doubleTapGestureRecognized(_ recognizer: UITapGestureRecognizer)
    {
        if (_dataNotSet)
        {
            return
        }
        
        if (recognizer.state == UIGestureRecognizerState.ended)
        {
            if (!_dataNotSet && _doubleTapToZoomEnabled)
            {
                var location = recognizer.location(in: self)
                location.x = location.x - _viewPortHandler.offsetLeft
                
                if (isAnyAxisInverted && _closestDataSetToTouch !== nil && getAxis(_closestDataSetToTouch.axisDependency).isInverted)
                {
                    location.y = -(location.y - _viewPortHandler.offsetTop)
                }
                else
                {
                    location.y = -(self.bounds.size.height - location.y - _viewPortHandler.offsetBottom)
                }
                
                self.zoom(isScaleXEnabled ? 1.4 : 1.0, scaleY: isScaleYEnabled ? 1.4 : 1.0, x: location.x, y: location.y)
            }
        }
    }
    
    #if !os(tvOS)
    @objc fileprivate func pinchGestureRecognized(_ recognizer: UIPinchGestureRecognizer)
    {
        if (recognizer.state == UIGestureRecognizerState.began)
        {
            stopDeceleration()
            
            if (!_dataNotSet && (_pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled))
            {
                _isScaling = true
                
                if (_pinchZoomEnabled)
                {
                    _gestureScaleAxis = .both
                }
                else
                {
                    let x = abs(recognizer.location(in: self).x - recognizer.location(ofTouch: 1, in: self).x)
                    let y = abs(recognizer.location(in: self).y - recognizer.location(ofTouch: 1, in: self).y)
                    
                    if (x > y)
                    {
                        _gestureScaleAxis = .x
                    }
                    else
                    {
                        _gestureScaleAxis = .y
                    }
                }
            }
        }
        else if (recognizer.state == UIGestureRecognizerState.ended ||
            recognizer.state == UIGestureRecognizerState.cancelled)
        {
            if (_isScaling)
            {
                _isScaling = false
                
                // Range might have changed, which means that Y-axis labels could have changed in size, affecting Y-axis size. So we need to recalculate offsets.
                calculateOffsets()
                setNeedsDisplay()
            }
        }
        else if (recognizer.state == UIGestureRecognizerState.changed)
        {
            let isZoomingOut = (recognizer.scale < 1)
            var canZoomMoreX = isZoomingOut ? _viewPortHandler.canZoomOutMoreX : _viewPortHandler.canZoomInMoreX
            var canZoomMoreY = isZoomingOut ? _viewPortHandler.canZoomOutMoreY : _viewPortHandler.canZoomInMoreY
            
            if (_isScaling)
            {
                canZoomMoreX = canZoomMoreX && _scaleXEnabled && (_gestureScaleAxis == .both || _gestureScaleAxis == .x);
                canZoomMoreY = canZoomMoreY && _scaleYEnabled && (_gestureScaleAxis == .both || _gestureScaleAxis == .y);
                if canZoomMoreX || canZoomMoreY
                {
                    var location = recognizer.location(in: self)
                    location.x = location.x - _viewPortHandler.offsetLeft

                    if (isAnyAxisInverted && _closestDataSetToTouch !== nil && getAxis(_closestDataSetToTouch.axisDependency).isInverted)
                    {
                        location.y = -(location.y - _viewPortHandler.offsetTop)
                    }
                    else
                    {
                        location.y = -(_viewPortHandler.chartHeight - location.y - _viewPortHandler.offsetBottom)
                    }
                    
                    let scaleX = canZoomMoreX ? recognizer.scale : 1.0
                    let scaleY = canZoomMoreY ? recognizer.scale : 1.0
                    
                    var matrix = CGAffineTransform(translationX: location.x, y: location.y)
                    matrix = matrix.scaledBy(x: scaleX, y: scaleY)
                    matrix = matrix.translatedBy(x: -location.x, y: -location.y)
                    
                    matrix = _viewPortHandler.touchMatrix.concatenating(matrix)
                    
                    _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: true)
                    
                    if (delegate !== nil)
                    {
                        delegate?.chartScaled?(self, scaleX: scaleX, scaleY: scaleY)
                    }
                }
                
                recognizer.scale = 1.0
            }
        }
    }
    #endif
    
    @objc fileprivate func panGestureRecognized(_ recognizer: UIPanGestureRecognizer)
    {
        if (recognizer.state == UIGestureRecognizerState.began && recognizer.numberOfTouches > 0)
        {
            stopDeceleration()
            
            if ((!_dataNotSet && _dragEnabled && !self.hasNoDragOffset) || !self.isFullyZoomedOut)
            {
                _isDragging = true
                
                _closestDataSetToTouch = getDataSetByTouchPoint(recognizer.location(ofTouch: 0, in: self))
                
                let translation = recognizer.translation(in: self)
                let didUserDrag = (self is HorizontalBarChartView) ? translation.y != 0.0 : translation.x != 0.0 
                
                // Check to see if user dragged at all and if so, can the chart be dragged by the given amount
                if (didUserDrag && !performPanChange(translation: translation))
                {
                    if (_outerScrollView !== nil)
                    {
                        // We can stop dragging right now, and let the scroll view take control
                        _outerScrollView = nil
                        _isDragging = false
                    }
                }
                else
                {
                    if (_outerScrollView !== nil)
                    {
                        // Prevent the parent scroll view from scrolling
                        _outerScrollView?.isScrollEnabled = false
                    }
                }
                
                _lastPanPoint = recognizer.translation(in: self)
            }
        }
        else if (recognizer.state == UIGestureRecognizerState.changed)
        {
            if (_isDragging)
            {
                let originalTranslation = recognizer.translation(in: self)
                let translation = CGPoint(x: originalTranslation.x - _lastPanPoint.x, y: originalTranslation.y - _lastPanPoint.y)
                
                performPanChange(translation: translation)
                
                _lastPanPoint = originalTranslation
            }
            else if (isHighlightPerDragEnabled)
            {
                let h = getHighlightByTouchPoint(recognizer.location(in: self))
                
                let lastHighlighted = self.lastHighlighted
                
                if ((h === nil && lastHighlighted !== nil) ||
                    (h !== nil && lastHighlighted === nil) ||
                    (h !== nil && lastHighlighted !== nil && !h!.isEqual(lastHighlighted)))
                {
                    self.lastHighlighted = h
                    self.highlightValue(highlight: h, callDelegate: true)
                }
            }
        }
        else if (recognizer.state == UIGestureRecognizerState.ended || recognizer.state == UIGestureRecognizerState.cancelled)
        {
            if (_isDragging)
            {
                if (recognizer.state == UIGestureRecognizerState.ended && isDragDecelerationEnabled)
                {
                    stopDeceleration()
                    
                    _decelerationLastTime = CACurrentMediaTime()
                    _decelerationVelocity = recognizer.velocity(in: self)
                    
                    _decelerationDisplayLink = CADisplayLink(target: self, selector: #selector(BarLineChartViewBase.decelerationLoop))
                    _decelerationDisplayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
                }
                
                _isDragging = false
            }
            
            if (_outerScrollView !== nil)
            {
                _outerScrollView?.isScrollEnabled = true
                _outerScrollView = nil
            }
        }
    }
    
    private func performPanChange(translation: CGPoint) -> Bool
    {
        var translation = translation
        if (isAnyAxisInverted && _closestDataSetToTouch !== nil
            && getAxis(_closestDataSetToTouch.axisDependency).isInverted)
        {
            if (self is HorizontalBarChartView)
            {
                translation.x = -translation.x
            }
            else
            {
                translation.y = -translation.y
            }
        }
        
        let originalMatrix = _viewPortHandler.touchMatrix
        
        var matrix = CGAffineTransform(translationX: translation.x, y: translation.y)
        matrix = originalMatrix.concatenating(matrix)
        
        matrix = _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: true)
        
        if (delegate !== nil)
        {
            delegate?.chartTranslated?(self, dX: translation.x, dY: translation.y)
        }
        
        // Did we managed to actually drag or did we reach the edge?
        return matrix.tx != originalMatrix.tx || matrix.ty != originalMatrix.ty
    }
    
    open func stopDeceleration()
    {
        if (_decelerationDisplayLink !== nil)
        {
            _decelerationDisplayLink.remove(from: RunLoop.main, forMode: RunLoopMode.commonModes)
            _decelerationDisplayLink = nil
        }
    }
    
    @objc fileprivate func decelerationLoop()
    {
        let currentTime = CACurrentMediaTime()
        
        _decelerationVelocity.x *= self.dragDecelerationFrictionCoef
        _decelerationVelocity.y *= self.dragDecelerationFrictionCoef
        
        let timeInterval = CGFloat(currentTime - _decelerationLastTime)
        
        let distance = CGPoint(
            x: _decelerationVelocity.x * timeInterval,
            y: _decelerationVelocity.y * timeInterval
        )
        
        if (!performPanChange(translation: distance))
        {
            // We reached the edge, stop
            _decelerationVelocity.x = 0.0
            _decelerationVelocity.y = 0.0
        }
        
        _decelerationLastTime = currentTime
        
        if (abs(_decelerationVelocity.x) < 0.001 && abs(_decelerationVelocity.y) < 0.001)
        {
            stopDeceleration()
            
            // Range might have changed, which means that Y-axis labels could have changed in size, affecting Y-axis size. So we need to recalculate offsets.
            calculateOffsets()
            setNeedsDisplay()
        }
    }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if (!super.gestureRecognizerShouldBegin(gestureRecognizer))
        {
            return false
        }
        
        if (gestureRecognizer == _panGestureRecognizer)
        {
            if (_dataNotSet || !_dragEnabled || !self.hasNoDragOffset ||
                (self.isFullyZoomedOut && !self.isHighlightPerDragEnabled))
            {
                return false
            }
        }
        else
        {
            #if !os(tvOS)
                if (gestureRecognizer == _pinchGestureRecognizer)
                {
                    if (_dataNotSet || (!_pinchZoomEnabled && !_scaleXEnabled && !_scaleYEnabled))
                    {
                        return false
                    }
                }
            #endif
        }
        
        return true
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        #if !os(tvOS)
        if ((gestureRecognizer.isKind(of: UIPinchGestureRecognizer.self) &&
            otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)) ||
            (gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) &&
                otherGestureRecognizer.isKind(of: UIPinchGestureRecognizer.self)))
        {
            return true
        }
        #endif
        
        if (gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) &&
            otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && (
                gestureRecognizer == _panGestureRecognizer
            ))
        {
            var scrollView = self.superview
            while (scrollView !== nil && !scrollView!.isKind(of: UIScrollView.self))
            {
                scrollView = scrollView?.superview
            }
            var foundScrollView = scrollView as? UIScrollView
            
            if (foundScrollView !== nil && !foundScrollView!.isScrollEnabled)
            {
                foundScrollView = nil
            }
            
            var scrollViewPanGestureRecognizer: UIGestureRecognizer!
            
            if (foundScrollView !== nil)
            {
                for scrollRecognizer in foundScrollView!.gestureRecognizers!
                {
                    if (scrollRecognizer.isKind(of: UIPanGestureRecognizer.self))
                    {
                        scrollViewPanGestureRecognizer = scrollRecognizer as! UIPanGestureRecognizer
                        break
                    }
                }
            }
            
            if (otherGestureRecognizer === scrollViewPanGestureRecognizer)
            {
                _outerScrollView = foundScrollView
                
                return true
            }
        }
        
        return false
    }
    
    /// MARK: Viewport modifiers
    
    /// Zooms in by 1.4, into the charts center. center.
    open func zoomIn()
    {
        let matrix = _viewPortHandler.zoomIn(x: self.bounds.size.width / 2.0, y: -(self.bounds.size.height / 2.0))
        _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: true)
        
        // Range might have changed, which means that Y-axis labels could have changed in size, affecting Y-axis size. So we need to recalculate offsets.
        calculateOffsets()
        setNeedsDisplay()
    }

    /// Zooms out by 0.7, from the charts center. center.
    open func zoomOut()
    {
        let matrix = _viewPortHandler.zoomOut(x: self.bounds.size.width / 2.0, y: -(self.bounds.size.height / 2.0))
        _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: true)
        
        // Range might have changed, which means that Y-axis labels could have changed in size, affecting Y-axis size. So we need to recalculate offsets.
        calculateOffsets()
        setNeedsDisplay()
    }

    /// Zooms in or out by the given scale factor. x and y are the coordinates
    /// (in pixels) of the zoom center.
    ///
    /// - parameter scaleX: if < 1 --> zoom out, if > 1 --> zoom in
    /// - parameter scaleY: if < 1 --> zoom out, if > 1 --> zoom in
    /// - parameter x:
    /// - parameter y:
    open func zoom(_ scaleX: CGFloat, scaleY: CGFloat, x: CGFloat, y: CGFloat)
    {
        let matrix = _viewPortHandler.zoom(scaleX: scaleX, scaleY: scaleY, x: x, y: -y)
        _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: false)
        
        // Range might have changed, which means that Y-axis labels could have changed in size, affecting Y-axis size. So we need to recalculate offsets.
        calculateOffsets()
        setNeedsDisplay()
    }

    /// Resets all zooming and dragging and makes the chart fit exactly it's bounds.
    open func fitScreen()
    {
        let matrix = _viewPortHandler.fitScreen()
        _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: false)
        
        // Range might have changed, which means that Y-axis labels could have changed in size, affecting Y-axis size. So we need to recalculate offsets.
        calculateOffsets()
        setNeedsDisplay()
    }
    
    /// Sets the minimum scale value to which can be zoomed out. 1 = fitScreen
    open func setScaleMinima(_ scaleX: CGFloat, scaleY: CGFloat)
    {
        _viewPortHandler.setMinimumScaleX(scaleX)
        _viewPortHandler.setMinimumScaleY(scaleY)
    }
    
    /// Sets the size of the area (range on the x-axis) that should be maximum visible at once (no further zomming out allowed).
    /// If this is e.g. set to 10, no more than 10 values on the x-axis can be viewed at once without scrolling.
    open func setVisibleXRangeMaximum(_ maxXRange: CGFloat)
    {
        let xScale = _deltaX / maxXRange
        _viewPortHandler.setMinimumScaleX(xScale)
    }
    
    /// Sets the size of the area (range on the x-axis) that should be minimum visible at once (no further zooming in allowed).
    /// If this is e.g. set to 10, no more than 10 values on the x-axis can be viewed at once without scrolling.
    open func setVisibleXRangeMinimum(_ minXRange: CGFloat)
    {
        let xScale = _deltaX / minXRange
        _viewPortHandler.setMaximumScaleX(xScale)
    }

    /// Limits the maximum and minimum value count that can be visible by pinching and zooming.
    /// e.g. minRange=10, maxRange=100 no less than 10 values and no more that 100 values can be viewed
    /// at once without scrolling
    open func setVisibleXRange(minXRange: CGFloat, maxXRange: CGFloat)
    {
        let maxScale = _deltaX / minXRange
        let minScale = _deltaX / maxXRange
        _viewPortHandler.setMinMaxScaleX(minScaleX: minScale, maxScaleX: maxScale)
    }
    
    /// Sets the size of the area (range on the y-axis) that should be maximum visible at once.
    /// 
    /// - parameter yRange:
    /// - parameter axis: - the axis for which this limit should apply
    open func setVisibleYRangeMaximum(_ maxYRange: CGFloat, axis: ChartYAxis.AxisDependency)
    {
        let yScale = getDeltaY(axis) / maxYRange
        _viewPortHandler.setMinimumScaleY(yScale)
    }

    /// Moves the left side of the current viewport to the specified x-index.
    /// This also refreshes the chart by calling setNeedsDisplay().
    open func moveViewToX(_ xIndex: Int)
    {
        if (_viewPortHandler.hasChartDimens)
        {
            var pt = CGPoint(x: CGFloat(xIndex), y: 0.0)
            
            getTransformer(.left).pointValueToPixel(&pt)
            _viewPortHandler.centerViewPort(pt: pt, chart: self)
        }
        else
        {
            _sizeChangeEventActions.append({[weak self] () in self?.moveViewToX(xIndex); })
        }
    }

    /// Centers the viewport to the specified y-value on the y-axis.
    /// This also refreshes the chart by calling setNeedsDisplay().
    /// 
    /// - parameter yValue:
    /// - parameter axis: - which axis should be used as a reference for the y-axis
    open func moveViewToY(_ yValue: CGFloat, axis: ChartYAxis.AxisDependency)
    {
        if (_viewPortHandler.hasChartDimens)
        {
            let valsInView = getDeltaY(axis) / _viewPortHandler.scaleY
            
            var pt = CGPoint(x: 0.0, y: yValue + valsInView / 2.0)
            
            getTransformer(axis).pointValueToPixel(&pt)
            _viewPortHandler.centerViewPort(pt: pt, chart: self)
        }
        else
        {
            _sizeChangeEventActions.append({[weak self] () in self?.moveViewToY(yValue, axis: axis); })
        }
    }

    /// This will move the left side of the current viewport to the specified x-index on the x-axis, and center the viewport to the specified y-value on the y-axis.
    /// This also refreshes the chart by calling setNeedsDisplay().
    /// 
    /// - parameter xIndex:
    /// - parameter yValue:
    /// - parameter axis: - which axis should be used as a reference for the y-axis
    open func moveViewTo(xIndex: Int, yValue: CGFloat, axis: ChartYAxis.AxisDependency)
    {
        if (_viewPortHandler.hasChartDimens)
        {
            let valsInView = getDeltaY(axis) / _viewPortHandler.scaleY
            
            var pt = CGPoint(x: CGFloat(xIndex), y: yValue + valsInView / 2.0)
            
            getTransformer(axis).pointValueToPixel(&pt)
            _viewPortHandler.centerViewPort(pt: pt, chart: self)
        }
        else
        {
            _sizeChangeEventActions.append({[weak self] () in self?.moveViewTo(xIndex: xIndex, yValue: yValue, axis: axis); })
        }
    }
    
    /// This will move the center of the current viewport to the specified x-index and y-value.
    /// This also refreshes the chart by calling setNeedsDisplay().
    ///
    /// - parameter xIndex:
    /// - parameter yValue:
    /// - parameter axis: - which axis should be used as a reference for the y-axis
    open func centerViewTo(xIndex: Int, yValue: CGFloat, axis: ChartYAxis.AxisDependency)
    {
        if (_viewPortHandler.hasChartDimens)
        {
            let valsInView = getDeltaY(axis) / _viewPortHandler.scaleY
            let xsInView = CGFloat(xAxis.values.count) / _viewPortHandler.scaleX
            
            var pt = CGPoint(x: CGFloat(xIndex) - xsInView / 2.0, y: yValue + valsInView / 2.0)
            
            getTransformer(axis).pointValueToPixel(&pt)
            _viewPortHandler.centerViewPort(pt: pt, chart: self)
        }
        else
        {
            _sizeChangeEventActions.append({[weak self] () in self?.centerViewTo(xIndex: xIndex, yValue: yValue, axis: axis); })
        }
    }

    /// Sets custom offsets for the current `ChartViewPort` (the offsets on the sides of the actual chart window). Setting this will prevent the chart from automatically calculating it's offsets. Use `resetViewPortOffsets()` to undo this.
    /// ONLY USE THIS WHEN YOU KNOW WHAT YOU ARE DOING, else use `setExtraOffsets(...)`.
    open func setViewPortOffsets(left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat)
    {
        _customViewPortEnabled = true
        
        if (Thread.isMainThread)
        {
            self._viewPortHandler.restrainViewPort(offsetLeft: left, offsetTop: top, offsetRight: right, offsetBottom: bottom)
            prepareOffsetMatrix()
            prepareValuePxMatrix()
        }
        else
        {
            DispatchQueue.main.async(execute: {
                self.setViewPortOffsets(left: left, top: top, right: right, bottom: bottom)
            })
        }
    }

    /// Resets all custom offsets set via `setViewPortOffsets(...)` method. Allows the chart to again calculate all offsets automatically.
    open func resetViewPortOffsets()
    {
        _customViewPortEnabled = false
        calculateOffsets()
    }

    // MARK: - Accessors
    
    /// - returns: the delta-y value (y-value range) of the specified axis.
    open func getDeltaY(_ axis: ChartYAxis.AxisDependency) -> CGFloat
    {
        if (axis == .left)
        {
            return CGFloat(leftAxis.axisRange)
        }
        else
        {
            return CGFloat(rightAxis.axisRange)
        }
    }

    /// - returns: the position (in pixels) the provided Entry has inside the chart view
    open func getPosition(_ e: ChartDataEntry, axis: ChartYAxis.AxisDependency) -> CGPoint
    {
        var vals = CGPoint(x: CGFloat(e.xIndex), y: CGFloat(e.value))

        getTransformer(axis).pointValueToPixel(&vals)

        return vals
    }

    /// is dragging enabled? (moving the chart with the finger) for the chart (this does not affect scaling).
    open var dragEnabled: Bool
    {
        get
        {
            return _dragEnabled
        }
        set
        {
            if (_dragEnabled != newValue)
            {
                _dragEnabled = newValue
            }
        }
    }
    
    /// is dragging enabled? (moving the chart with the finger) for the chart (this does not affect scaling).
    open var isDragEnabled: Bool
    {
        return dragEnabled
    }
    
    /// is scaling enabled? (zooming in and out by gesture) for the chart (this does not affect dragging).
    open func setScaleEnabled(_ enabled: Bool)
    {
        if (_scaleXEnabled != enabled || _scaleYEnabled != enabled)
        {
            _scaleXEnabled = enabled
            _scaleYEnabled = enabled
            #if !os(tvOS)
                _pinchGestureRecognizer.isEnabled = _pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled
            #endif
        }
    }
    
    open var scaleXEnabled: Bool
    {
        get
        {
            return _scaleXEnabled
        }
        set
        {
            if (_scaleXEnabled != newValue)
            {
                _scaleXEnabled = newValue
                #if !os(tvOS)
                    _pinchGestureRecognizer.isEnabled = _pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled
                #endif
            }
        }
    }
    
    open var scaleYEnabled: Bool
    {
        get
        {
            return _scaleYEnabled
        }
        set
        {
            if (_scaleYEnabled != newValue)
            {
                _scaleYEnabled = newValue
                #if !os(tvOS)
                    _pinchGestureRecognizer.isEnabled = _pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled
                #endif
            }
        }
    }
    
    open var isScaleXEnabled: Bool { return scaleXEnabled; }
    open var isScaleYEnabled: Bool { return scaleYEnabled; }
    
    /// flag that indicates if double tap zoom is enabled or not
    open var doubleTapToZoomEnabled: Bool
    {
        get
        {
            return _doubleTapToZoomEnabled
        }
        set
        {
            if (_doubleTapToZoomEnabled != newValue)
            {
                _doubleTapToZoomEnabled = newValue
                _doubleTapGestureRecognizer.isEnabled = _doubleTapToZoomEnabled
            }
        }
    }
    
    /// **default**: true
    /// - returns: true if zooming via double-tap is enabled false if not.
    open var isDoubleTapToZoomEnabled: Bool
    {
        return doubleTapToZoomEnabled
    }
    
    /// flag that indicates if highlighting per dragging over a fully zoomed out chart is enabled
    open var highlightPerDragEnabled = true
    
    /// If set to true, highlighting per dragging over a fully zoomed out chart is enabled
    /// You might want to disable this when using inside a `UIScrollView`
    /// 
    /// **default**: true
    open var isHighlightPerDragEnabled: Bool
    {
        return highlightPerDragEnabled
    }
    
    /// **default**: true
    /// - returns: true if drawing the grid background is enabled, false if not.
    open var isDrawGridBackgroundEnabled: Bool
    {
        return drawGridBackgroundEnabled
    }
    
    /// **default**: false
    /// - returns: true if drawing the borders rectangle is enabled, false if not.
    open var isDrawBordersEnabled: Bool
    {
        return drawBordersEnabled
    }
    
    /// - returns: the Highlight object (contains x-index and DataSet index) of the selected value at the given touch point inside the Line-, Scatter-, or CandleStick-Chart.
    open func getHighlightByTouchPoint(_ pt: CGPoint) -> ChartHighlight?
    {
        if (_dataNotSet || _data === nil)
        {
            print("Can't select by touch. No data set.", terminator: "\n")
            return nil
        }

        return _highlighter?.getHighlight(x: Double(pt.x), y: Double(pt.y))
    }

    /// - returns: the x and y values in the chart at the given touch point
    /// (encapsulated in a `CGPoint`). This method transforms pixel coordinates to
    /// coordinates / values in the chart. This is the opposite method to
    /// `getPixelsForValues(...)`.
    public func getValueByTouchPoint(pt: CGPoint, axis: ChartYAxis.AxisDependency) -> CGPoint
    {
        var pt = pt
        getTransformer(axis).pixelToValue(&pt)

        return pt
    }

    /// Transforms the given chart values into pixels. This is the opposite
    /// method to `getValueByTouchPoint(...)`.
    open func getPixelForValue(_ x: Double, y: Double, axis: ChartYAxis.AxisDependency) -> CGPoint
    {
        var pt = CGPoint(x: CGFloat(x), y: CGFloat(y))
        
        getTransformer(axis).pointValueToPixel(&pt)
        
        return pt
    }

    /// - returns: the y-value at the given touch position (must not necessarily be
    /// a value contained in one of the datasets)
    open func getYValueByTouchPoint(pt: CGPoint, axis: ChartYAxis.AxisDependency) -> CGFloat
    {
        return getValueByTouchPoint(pt: pt, axis: axis).y
    }
    
    /// - returns: the Entry object displayed at the touched position of the chart
    open func getEntryByTouchPoint(_ pt: CGPoint) -> ChartDataEntry!
    {
        let h = getHighlightByTouchPoint(pt)
        if (h !== nil)
        {
            return _data!.getEntryForHighlight(h!)
        }
        return nil
    }
    
    /// - returns: the DataSet object displayed at the touched position of the chart
    open func getDataSetByTouchPoint(_ pt: CGPoint) -> BarLineScatterCandleBubbleChartDataSet!
    {
        let h = getHighlightByTouchPoint(pt)
        if (h !== nil)
        {
            return _data.getDataSetByIndex(h!.dataSetIndex) as! BarLineScatterCandleBubbleChartDataSet!
        }
        return nil
    }

    /// - returns: the current x-scale factor
    open var scaleX: CGFloat
    {
        if (_viewPortHandler === nil)
        {
            return 1.0
        }
        return _viewPortHandler.scaleX
    }

    /// - returns: the current y-scale factor
    open var scaleY: CGFloat
    {
        if (_viewPortHandler === nil)
        {
            return 1.0
        }
        return _viewPortHandler.scaleY
    }

    /// if the chart is fully zoomed out, return true
    open var isFullyZoomedOut: Bool { return _viewPortHandler.isFullyZoomedOut; }

    /// - returns: the left y-axis object. In the horizontal bar-chart, this is the
    /// top axis.
    open var leftAxis: ChartYAxis
    {
        return _leftAxis
    }

    /// - returns: the right y-axis object. In the horizontal bar-chart, this is the
    /// bottom axis.
    open var rightAxis: ChartYAxis { return _rightAxis; }

    /// - returns: the y-axis object to the corresponding AxisDependency. In the
    /// horizontal bar-chart, LEFT == top, RIGHT == BOTTOM
    open func getAxis(_ axis: ChartYAxis.AxisDependency) -> ChartYAxis
    {
        if (axis == .left)
        {
            return _leftAxis
        }
        else
        {
            return _rightAxis
        }
    }

    /// - returns: the object representing all x-labels, this method can be used to
    /// acquire the XAxis object and modify it (e.g. change the position of the
    /// labels)
    open var xAxis: ChartXAxis
    {
        return _xAxis
    }
    
    /// flag that indicates if pinch-zoom is enabled. if true, both x and y axis can be scaled simultaneously with 2 fingers, if false, x and y axis can be scaled separately
    open var pinchZoomEnabled: Bool
    {
        get
        {
            return _pinchZoomEnabled
        }
        set
        {
            if (_pinchZoomEnabled != newValue)
            {
                _pinchZoomEnabled = newValue
                #if !os(tvOS)
                    _pinchGestureRecognizer.isEnabled = _pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled
                #endif
            }
        }
    }

    /// **default**: false
    /// - returns: true if pinch-zoom is enabled, false if not
    open var isPinchZoomEnabled: Bool { return pinchZoomEnabled; }

    /// Set an offset in dp that allows the user to drag the chart over it's
    /// bounds on the x-axis.
    open func setDragOffsetX(_ offset: CGFloat)
    {
        _viewPortHandler.setDragOffsetX(offset)
    }

    /// Set an offset in dp that allows the user to drag the chart over it's
    /// bounds on the y-axis.
    open func setDragOffsetY(_ offset: CGFloat)
    {
        _viewPortHandler.setDragOffsetY(offset)
    }

    /// - returns: true if both drag offsets (x and y) are zero or smaller.
    open var hasNoDragOffset: Bool { return _viewPortHandler.hasNoDragOffset; }

    /// The X axis renderer. This is a read-write property so you can set your own custom renderer here.
    /// **default**: An instance of ChartXAxisRenderer
    /// - returns: The current set X axis renderer
    open var xAxisRenderer: ChartXAxisRenderer
    {
        get { return _xAxisRenderer }
        set { _xAxisRenderer = newValue }
    }
    
    /// The left Y axis renderer. This is a read-write property so you can set your own custom renderer here.
    /// **default**: An instance of ChartYAxisRenderer
    /// - returns: The current set left Y axis renderer
    open var leftYAxisRenderer: ChartYAxisRenderer
    {
        get { return _leftYAxisRenderer }
        set { _leftYAxisRenderer = newValue }
    }
    
    /// The right Y axis renderer. This is a read-write property so you can set your own custom renderer here.
    /// **default**: An instance of ChartYAxisRenderer
    /// - returns: The current set right Y axis renderer
    open var rightYAxisRenderer: ChartYAxisRenderer
    {
        get { return _rightYAxisRenderer }
        set { _rightYAxisRenderer = newValue }
    }
    
    open override var chartYMax: Double
    {
        return max(leftAxis.axisMaximum, rightAxis.axisMaximum)
    }

    open override var chartYMin: Double
    {
        return min(leftAxis.axisMinimum, rightAxis.axisMinimum)
    }
    
    /// - returns: true if either the left or the right or both axes are inverted.
    open var isAnyAxisInverted: Bool
    {
        return _leftAxis.isInverted || _rightAxis.isInverted
    }
    
    /// flag that indicates if auto scaling on the y axis is enabled.
    /// if yes, the y axis automatically adjusts to the min and max y values of the current x axis range whenever the viewport changes
    open var autoScaleMinMaxEnabled: Bool
    {
        get { return _autoScaleMinMaxEnabled; }
        set { _autoScaleMinMaxEnabled = newValue; }
    }
    
    /// **default**: false
    /// - returns: true if auto scaling on the y axis is enabled.
    open var isAutoScaleMinMaxEnabled : Bool { return autoScaleMinMaxEnabled; }
    
    /// Sets a minimum width to the specified y axis.
    open func setYAxisMinWidth(_ which: ChartYAxis.AxisDependency, width: CGFloat)
    {
        if (which == .left)
        {
            _leftAxis.minWidth = width
        }
        else
        {
            _rightAxis.minWidth = width
        }
    }
    
    /// **default**: 0.0
    /// - returns: the (custom) minimum width of the specified Y axis.
    open func getYAxisMinWidth(_ which: ChartYAxis.AxisDependency) -> CGFloat
    {
        if (which == .left)
        {
            return _leftAxis.minWidth
        }
        else
        {
            return _rightAxis.minWidth
        }
    }
    /// Sets a maximum width to the specified y axis.
    /// Zero (0.0) means there's no maximum width
    open func setYAxisMaxWidth(_ which: ChartYAxis.AxisDependency, width: CGFloat)
    {
        if (which == .left)
        {
            _leftAxis.maxWidth = width
        }
        else
        {
            _rightAxis.maxWidth = width
        }
    }
    
    /// Zero (0.0) means there's no maximum width
    ///
    /// **default**: 0.0 (no maximum specified)
    /// - returns: the (custom) maximum width of the specified Y axis.
    open func getYAxisMaxWidth(_ which: ChartYAxis.AxisDependency) -> CGFloat
    {
        if (which == .left)
        {
            return _leftAxis.maxWidth
        }
        else
        {
            return _rightAxis.maxWidth
        }
    }

    /// - returns the width of the specified y axis.
    open func getYAxisWidth(_ which: ChartYAxis.AxisDependency) -> CGFloat
    {
        if (which == .left)
        {
            return _leftAxis.requiredSize().width
        }
        else
        {
            return _rightAxis.requiredSize().width
        }
    }
    
    // MARK: - BarLineScatterCandleBubbleChartDataProvider
    
    /// - returns: the Transformer class that contains all matrices and is
    /// responsible for transforming values into pixels on the screen and
    /// backwards.
    open func getTransformer(_ which: ChartYAxis.AxisDependency) -> ChartTransformer
    {
        if (which == .left)
        {
            return _leftAxisTransformer
        }
        else
        {
            return _rightAxisTransformer
        }
    }
    
    /// the number of maximum visible drawn values on the chart
    /// only active when `setDrawValues()` is enabled
    open var maxVisibleValueCount: Int
    {
        get
        {
            return _maxVisibleValueCount
        }
        set
        {
            _maxVisibleValueCount = newValue
        }
    }
    
    open func isInverted(_ axis: ChartYAxis.AxisDependency) -> Bool
    {
        return getAxis(axis).isInverted
    }
    
    /// - returns: the lowest x-index (value on the x-axis) that is still visible on he chart.
    open var lowestVisibleXIndex: Int
    {
        var pt = CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom)
        getTransformer(.left).pixelToValue(&pt)
        return (pt.x <= 0.0) ? 0 : Int(pt.x + 1.0)
    }
    
    /// - returns: the highest x-index (value on the x-axis) that is still visible on the chart.
    open var highestVisibleXIndex: Int
    {
        var pt = CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentBottom)
        getTransformer(.left).pixelToValue(&pt)
        return (_data != nil && Int(pt.x) >= _data.xValCount) ? _data.xValCount - 1 : Int(pt.x)
    }
}

/// Default formatter that calculates the position of the filled line.
internal class BarLineChartFillFormatter: NSObject, ChartFillFormatter
{
    internal override init()
    {
    }
    
    internal func getFillLinePosition(dataSet: LineChartDataSet, dataProvider: LineChartDataProvider) -> CGFloat
    {
        var fillMin = CGFloat(0.0)
        
        if (dataSet.yMax > 0.0 && dataSet.yMin < 0.0)
        {
            fillMin = 0.0
        }
        else
        {
            if let data = dataProvider.data
            {
                if !dataProvider.getAxis(dataSet.axisDependency).isStartAtZeroEnabled
                {
                    var max: Double, min: Double
                    
                    if (data.yMax > 0.0)
                    {
                        max = 0.0
                    }
                    else
                    {
                        max = dataProvider.chartYMax
                    }
                    
                    if (data.yMin < 0.0)
                    {
                        min = 0.0
                    }
                    else
                    {
                        min = dataProvider.chartYMin
                    }
                    
                    fillMin = CGFloat(dataSet.yMin >= 0.0 ? min : max)
                }
                else
                {
                    fillMin = 0.0
                }
            }
        }
        
        return fillMin
    }
}
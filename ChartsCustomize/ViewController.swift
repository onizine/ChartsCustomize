//
//  ViewController.swift
//  ChartsCustomize
//
//  Created by 鬼塚　峰行 on 2020/08/23.
//  Copyright © 2020 Mineyuki-onizuka. All rights reserved.
//

import UIKit
import Charts
class ViewController: UIViewController,CustomXAxisRenderDelegate  {

    var chartView:LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.makeChart()
    }
    
    
    private func makeChart() {
        self.chartView = LineChartView(frame: self.view.frame)
        var customRender = CustomXAxisRender(viewPortHandler: self.chartView.viewPortHandler,
                                              xAxis: self.chartView.xAxis,
                                              transformer: self.chartView.xAxisRenderer.transformer!)
        customRender.renderDelegate = self
        self.chartView.xAxisRenderer = customRender
    
        let xAxis = self.chartView.xAxis
        
        xAxis.labelPosition = .bottom
        
        chartView.data = self.createChartsData()
        self.view.addSubview(chartView)
        
    }

    
    private func createChartsData() -> LineChartData {
        let bellValues = [120,109,86,214,487,64,87]
        let day = [1,2,3,4,5,6,7]
        
        
        var datas:[ChartDataEntry] = []
        
        for i in 0..<day.count {
            datas.append(ChartDataEntry(x: Double(day[i]), y: Double(bellValues[i])))
        }
        
        var lineChart = LineChartDataSet(entries: datas)
        
        
        
        return LineChartData(dataSets: [lineChart])
    }
    
    func isRender(entry:Double) -> Bool{
        return Int(entry.truncatingRemainder(dividingBy: 2.0)) == 0
    }
    
}

protocol CustomXAxisRenderDelegate {
    func isRender(entry:Double) -> Bool
}

extension CustomXAxisRenderDelegate {
    func isRender(entry:Double) -> Bool{
        return true
    }
}

class CustomXAxisRender: XAxisRenderer {
    
    var renderDelegate:CustomXAxisRenderDelegate?
    
    override init(viewPortHandler: ViewPortHandler, xAxis: XAxis?, transformer: Transformer?) {
        super.init(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: transformer)
    }
    
    open override func renderGridLines(context: CGContext)
    {
        guard
            let xAxis = self.axis as? XAxis,
            let transformer = self.transformer
            else { return }
        
        if !xAxis.isDrawGridLinesEnabled || !xAxis.isEnabled
        {
            return
        }
        
        context.saveGState()
        defer { context.restoreGState() }
        context.clip(to: self.gridClippingRect)
        
        context.setShouldAntialias(xAxis.gridAntialiasEnabled)
        context.setStrokeColor(xAxis.gridColor.cgColor)
        context.setLineWidth(xAxis.gridLineWidth)
        context.setLineCap(xAxis.gridLineCap)
        
        if xAxis.gridLineDashLengths != nil
        {
            context.setLineDash(phase: xAxis.gridLineDashPhase, lengths: xAxis.gridLineDashLengths)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        let entries = xAxis.entries
        
        
        
        
        for i in stride(from: 0, to: entries.count, by: 1)
        {
            if let delegate = self.renderDelegate {
                if !delegate.isRender(entry:entries[i]) {
                    continue
                }
            }
            
            position.x = CGFloat(entries[i])
            position.y = position.x
            position = position.applying(valueToPixelMatrix)
            
            drawGridLine(context: context, x: position.x, y: position.y)
        }
    }
}


//
//  RhombManager.swift
//  Hexagon
//
//  Created by Niroshan Maheswaran on 18.02.19.
//  Copyright © 2019 Niroshan Maheswaran. All rights reserved.
//

import UIKit

class HexagonManager: NSObject {
    
    // MARK: - Public properties
    
    /// Number of hexagon.
    public var numberOfHexagon: Int
    
    /// Number of hexagon per row.
    public var hexagonsPerRow: Int {
        get {
            Int(floor(Double(self.numberOfHexagon) / Double(self.numberOfRows)))
        }
    }
    
    /// Number of rows.
    public var numberOfRows: Int
    
    /// Size of hexagon.
    public var hexagonSize: CGSize
    
    /// Scrollview where hexagons will be placed in.
    public var hexagonScrollView: UIScrollView
    
    /// Returns all hexagons.
    public lazy var hexagons: [HexagonView] = []
    
    // MARK: - Private properties
    
    /// Current row
    private var currentRow: Int = 1
    
    /// Current hexagon
    private var currentHexagon: Int = 1
    
    /// Root point of first hexagon
    private var rootPoint: CGPoint!
    
    // Intitalizer
    init(
        numberOfHexagons: Int = 6,
        numberOfRows: Int = 2,
        hexagonSize: CGSize = CGSize(width: 250, height: 250),
        scrollview: UIScrollView
    ) {
        self.hexagonScrollView = scrollview
        self.hexagonSize = hexagonSize
        self.numberOfRows = numberOfRows
        self.numberOfHexagon = numberOfHexagons
        super.init()
    }
    
    // MARK: - Public methods
    
    /// Setup hexagons.
    func setupHexagons(
        withControllers controllers: [UIViewController],
        hexagonColor color: UIColor = .lightGray
    ) {
        var newX: CGFloat = (hexagonScrollView.frame.width / 2 - hexagonSize.width / 2) * 2
        var newY: CGFloat = hexagonScrollView.frame.height / 2 - hexagonSize.height / 2
        rootPoint = CGPoint(x: newX, y: newY)
        
        for viewController in controllers {
            let frame = CGRect(
                x: newX,
                y: newY,
                width: hexagonSize.width,
                height: hexagonSize.height
            )
            
            let hexagon = HexagonView(frame: frame, color: color)
            viewController.view.frame = hexagonScrollView.frame
            hexagon.add(view: viewController.view)
            hexagonScrollView.addSubview(hexagon)
            hexagons.append(hexagon)
            
            let newPoint = calculateNewPosition(with: CGPoint(x: newX, y: newY))
            newX = newPoint.x
            newY = newPoint.y
        }
        setScrollViewContentSize()
        
        centerClosestHexagon(animated: false)
    }
}

// MARK: - Private methods

extension HexagonManager {
    
    /// Calculates new position with given current position
    private func calculateNewPosition(with currentPoint: CGPoint) -> CGPoint {
        var newX = currentPoint.x
        var newY = currentPoint.y
        if currentHexagon == hexagonsPerRow {
            currentRow += 1
            currentHexagon = 1
            if currentRow % 2 == 0 {
                newX = rootPoint.x - hexagonSize.width/2
            } else {
                newX = rootPoint.x
            }
            newY += hexagonSize.height * 3/4 + 25
        } else {
            currentHexagon += 1
            newX += hexagonSize.width
        }
        return CGPoint(x: newX, y: newY)
    }
    
    /// Centers Hexagon with closest distance to center point.
    private func centerClosestHexagon(animated: Bool = true) {
        guard let firstRhomb = hexagons.first else {
            return
        }
        hexagonScrollView.setContentOffset(
            firstRhomb.finalPoint,
            animated: animated
        )
    }
    
    /// Calculates new point of center with offset of scrollview.
    private func calculateCenterWithOffset() -> CGPoint {
        let offSet = hexagonScrollView.contentOffset
        let center = hexagonScrollView.center
        let newX = center.x + offSet.x
        let newY = center.y + offSet.y
        return CGPoint(x: newX, y: newY)
    }
    
    /// Sets scrollviews content size.
    private func setScrollViewContentSize() {
        let contentWidth = CGFloat(hexagonsPerRow) * hexagonSize.width +
            (hexagonScrollView.frame.width - hexagonSize.width)
        let contentHeight = CGFloat(numberOfRows) * hexagonSize.height +
            (hexagonScrollView.frame.height - hexagonSize.height)
        hexagonScrollView.contentSize = CGSize(
            width: CGFloat(contentWidth),
            height: CGFloat(contentHeight)
        )
    }
}

// MARK: - UIScrollViewDelegate

extension HexagonManager: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newCenter = calculateCenterWithOffset()
        for rhomb in hexagons {
            rhomb.calculateDistanceFromCenter(newCenter)
        }
        hexagons = hexagons.sorted(by: { $0.distance < $1.distance })
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        centerClosestHexagon()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            centerClosestHexagon()
        }
    }
}

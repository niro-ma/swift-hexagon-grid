//
//  HexagonView.swift
//  Hexagon
//
//  Created by Niroshan Maheswaran on 15.02.19.
//  Copyright © 2019 Niroshan Maheswaran. All rights reserved.
//

import UIKit

// MARK: - Extension UIView

extension UIView {
    
    /// Takes screenshot of current view.
    func takeScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(
            bounds.size,
            false,
            UIScreen.main.scale
        )
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let screenShot = image else {
            return UIImage()
        }
        
        return screenShot
    }
}

/// States of Hexagon view.
fileprivate enum AnimationState {
    
    /// Hexagon transforms to fullscreen view.
    case fullscreen
    
    /// Initial state of hexagon.
    case hexagon
}

class HexagonView: UIView, UIGestureRecognizerDelegate {
    
    // MARK: - Public properties
    
    /// Distance between hexagon to center of superview.
    public var distance: CGFloat!
    
    /// Point to center view.
    public var finalPoint: CGPoint = CGPoint()
    
    /// Frame of hexagon.
    public var hexagonFrame: CGRect!
    
    /// Default background color of hexagon rhomb.
    public var defaultBackgroundColor: UIColor = UIColor(
        red: 21/255,
        green: 21/255,
        blue: 21/255,
        alpha: 1.0
    )
    
    /// Default border color.
    public var defaultBorderColor: UIColor = .clear
    
    /// Default border width.
    public var defaultBoderWidth: Int = 0
    
    // MARK: - Private properties
    
    /// Current state of hexagon. Initival value is hexagon.
    private var currentState: AnimationState = .hexagon
    
    /// ImageView for screenshot of thumbnail
    private var screenShotView: UIImageView!
    
    /// Contains the ViewController passed by user
    private var containerView: UIView!
    
    /// Default title label appears when hexagon view is not in fullscreen mode.
    private var defaultTitleLabel: UILabel {
        let titleLabel = UILabel(
            frame: CGRect(
                x: 0,
                y: 0,
                width: frame.width,
                height: frame.height
            )
        )
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        titleLabel.font = UIFont(name: "KohinoorBangla-Semibold ", size: 12.0)
        titleLabel.text = "Double tap!"
        return titleLabel
    }
    
    /// Frame of superView.
    private var superViewFrame: CGRect!
    
    /// Tap recognizer for double tap to expand to fullscreen
    private var doubleTap: UITapGestureRecognizer!
    
    /// Tap recognizer for single tap to focus hexagon
    private var singleTap: UITapGestureRecognizer!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Initializer
    init(
        frame: CGRect,
        color: UIColor
    ) {
        super.init(frame: frame)
        self.hexagonFrame = frame
        self.defaultBackgroundColor = color
        
        setupHexagon()
    }
    
    // MARK: - Public methods
    
    /// Calculate point to center view
    public func calculateFinalPoint() {
        finalPoint.x = (hexagonFrame.origin.x + hexagonFrame.width/2) - superViewFrame.width/2
        finalPoint.y = (hexagonFrame.origin.y + hexagonFrame.height/2) - superViewFrame.height/2 + 18
    }
    
    /// Adds custom view to hexagon view and makes screenshot.
    public func add(view: UIView) {
        superViewFrame = CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: view.frame.height
        )
        calculateFinalPoint()
        calculateDistanceFromCenter(superViewFrame.origin)
        resize(superViewFrame)
        containerView.addSubview(view)
        screenShotView.image = takeScreenshot()
        resize(hexagonFrame)
        view.frame = CGRect(
            x: 0,
            y: 0,
            width: hexagonFrame.width,
            height: hexagonFrame.height
        )
        containerView.isHidden = true
        bringSubviewToFront(screenShotView)
    }
    
    /// Calculates distance from hexagon to superview center point.
    public func calculateDistanceFromCenter(_ center: CGPoint) {
        let distance1 = powf(Float((frame.origin.x + frame.width / 2) - center.x), 2)
        let distance2 = powf(Float((frame.origin.y + frame.height / 2) - center.y), 2)
        distance = CGFloat(sqrt(distance1 + distance2))
    }
}

// MARK: - Private methods

extension HexagonView {
    
    /// Resizes hexagon view and its content to given frame.
    private func resize(_ frame: CGRect) {
        self.frame = frame
        containerView.frame = CGRect(
            x: 0,
            y: 0,
            width: frame.width,
            height: frame.height
        )
        screenShotView.frame = CGRect(
            x: 0,
            y: 0,
            width: frame.width,
            height: frame.height
        )
    }
    
    /// Draws layer for hexagon view
    private func layerForHexagon() -> CALayer {
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = .evenOdd
        maskLayer.frame = bounds
        
        let width: CGFloat = frame.size.width
        let height: CGFloat = frame.size.height
        let hPadding: CGFloat = width / 8 / 2
        
        UIGraphicsBeginImageContext(frame.size)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: width / 2, y: 0))
        path.addLine(to: CGPoint(x: width - hPadding, y: height / 4))
        path.addLine(to: CGPoint(x: width - hPadding, y: height * 3 / 4))
        path.addLine(to: CGPoint(x: width / 2, y: height))
        path.addLine(to: CGPoint(x: hPadding, y: height * 3 / 4))
        path.addLine(to: CGPoint(x: hPadding, y: height / 4))
        path.close()
        path.fill()
        
        maskLayer.path = path.cgPath
        
        UIGraphicsEndImageContext()
        return maskLayer
    }
    
    /// Refreshs thumbnail after every animation.
    private func refreshThumbnail(state: AnimationState) {
        guard let superview = superview as? UIScrollView else {
            return
        }
        superview.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        screenShotView.isHidden = !(state == .fullscreen)
        containerView.isHidden = state == .fullscreen
        superview.isScrollEnabled = state == .fullscreen
    }
    
    /// Setup hexagon view
    private func setupHexagon() {
        containerView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: frame.width,
                height: frame.height)
        )
        containerView.backgroundColor = defaultBackgroundColor
        addSubview(containerView)
        
        screenShotView = UIImageView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: frame.width,
                height: frame.height)
        )
        screenShotView.contentMode = .scaleAspectFill
        screenShotView.layer.masksToBounds = true
        screenShotView.backgroundColor = defaultBackgroundColor
        screenShotView.layer.mask = layerForHexagon()
        addSubview(screenShotView)
        
        screenShotView.addSubview(defaultTitleLabel)
        
        /// Add double tap recognizer
        doubleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleDoubleTap(recognizer:))
        )
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        /// Add single tap recognizer
        singleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleSingleTap(recognzier:))
        )
        singleTap.numberOfTapsRequired = 1
        addGestureRecognizer(singleTap)
    }
    
    /// Handle single tap.
    @objc private func handleSingleTap(recognzier: UITapGestureRecognizer) {
        guard let scrollview = self.superview as? UIScrollView else {
            return
        }
        scrollview.setContentOffset(
            finalPoint,
            animated: true
        )
    }
    
    /// Handle double tap.
    @objc private func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        guard let scrollview = self.superview as? UIScrollView else {
            return
        }
        scrollview.setContentOffset(
            finalPoint,
            animated: true
        )
        
        superview?.bringSubviewToFront(self)
        endEditing(true)
        
        var destinationFrame = CGRect(
            x: 0,
            y: 0,
            width: superViewFrame.width,
            height: superViewFrame.height
        )
        var destinationState: AnimationState = .fullscreen
        if currentState == .fullscreen {
            screenShotView.image = takeScreenshot()
            currentState = .hexagon
            singleTap.isEnabled = true
            destinationState = .fullscreen
            destinationFrame = hexagonFrame
        } else {
            currentState = .fullscreen
            destinationState = .hexagon
            singleTap.isEnabled = false
        }
        
        UIView.animate(withDuration: 0.125, animations: { [weak self] in
            guard let self = self else { return }
            self.frame = destinationFrame
            
            var visibleRect = CGRect(origin: scrollview.contentOffset, size: scrollview.bounds.size)
            let scale = 1.0 / scrollview.contentScaleFactor
            visibleRect.origin.x *= scale
            visibleRect.origin.y *= scale
            visibleRect.size.width *= scale
            visibleRect.size.height *= scale
            
            self.containerView.frame = visibleRect
            self.containerView.frame.origin = .zero
            self.containerView.frame.size = CGSize(
                width: destinationFrame.width,
                height: destinationFrame.height
            )
            self.screenShotView.frame = CGRect(
                x: 0,
                y: 0,
                width: destinationFrame.width,
                height: destinationFrame.height
            )
            self.refreshThumbnail(state: destinationState)
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            if self.currentState == .hexagon {
                scrollview.setContentOffset(self.finalPoint, animated: true)
            }
        })
    }
}

// MARK: - UIGestureRecognizer delegate

extension HexagonView {
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}

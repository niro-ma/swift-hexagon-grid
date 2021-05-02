//
//  ViewController.swift
//  Hexagon
//
//  Created by Niroshan Maheswaran on 14.02.19.
//  Copyright © 2019 Niroshan Maheswaran. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var scrollview: UIScrollView!
    
    // MARK: - Private properties
    
    /// Array of ViewControllers.
    private var controllers: [UIViewController] = []
    
    /// Number of hexagons.
    private let numberOfHexagons: Int = 10
    
    /// Number of rows.
    private let numberOfRows: Int = 3
    
    /// Hexagon manager.
    private lazy var hexManager = HexagonManager(
        numberOfHexagons: numberOfHexagons,
        numberOfRows: 3,
        scrollview: scrollview
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 1...numberOfHexagons {
            let vc: TestViewController = getViewController(fromStoryboardWith: "TestVC\(i)") as! TestViewController
            controllers.append(vc)
        }
        scrollview.delegate = hexManager
        
        self.view.layoutIfNeeded()
        hexManager.setupHexagons(withControllers: controllers)
    }
    
    // Returns ViewController with identifier from storyboard.
    fileprivate func getViewController(fromStoryboardWith identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        return vc
    }
}


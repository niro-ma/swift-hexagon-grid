# swift-hexagon-grid
A grid with UIViews shaped as hexagons which represents an UIViewController. 
With a single tap on a hexagon view the view will be centered and a double tap expands it to fullscreen.

# Usage 

It is mandatory that your **ViewController** contains an **UIScrollView**.

```
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
```

## License

MIT license. See the [LICENSE](https://github.com/niro-ma/swift-hexagon-grid/blob/master/LICENSE) for details.

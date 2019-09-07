import Common

public class FavoritesCoordinator: Coordinator {
    
    private var tabBar: UITabBarController
    
    public init(tabBar: UITabBarController) {
        self.tabBar = tabBar
    }
    
    lazy var tabBarItem: UITabBarItem? = {
        return UITabBarItem(title: "Favorites",
                            image: Assets.Icons.Modules.Favorite,
                            selectedImage: nil)
    }()
    
    public lazy var viewController: UIViewController = {
//        guard let vc = MovieCatalogViewController.instantiate() else { return UIViewController() }
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.red
        if let tabBarItem = self.tabBarItem {
            vc.tabBarItem = tabBarItem
        }
        return vc
    }()

    public func start() {
        var viewControllers = tabBar.viewControllers ?? []
        viewControllers += [self.viewController]
        tabBar.viewControllers = viewControllers
        print("starting FavoritesCoordinator ... ")
    }
    
}

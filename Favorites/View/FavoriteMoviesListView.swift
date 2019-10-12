//    The MIT License (MIT)
//
//    Copyright (c) 2019 Inácio Ferrarini
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.
//

import UIKit
import Common
import Ness

protocol FavoriteMoviesListViewDelegate: AnyObject {

    func favoriteMoviesListView(_ favoriteMoviesListView: FavoriteMoviesListView, unfavorited movie: Movie)

    func favoriteMoviesListViewDidRemoveFilter(_ favoriteMoviesListView: FavoriteMoviesListView)

}

class FavoriteMoviesListView: UIView, LanguageAware {

    // MARK: - Outlets

    @IBOutlet weak private(set) var contentView: UIView!
    @IBOutlet weak private(set) var tableView: UITableView!
    @IBOutlet weak private(set) var removeFilterButton: UIButton!
    @IBOutlet weak private(set) var removeFilterButtonHeightConstraint: NSLayoutConstraint!

    // MARK: - Private Properties

    private var dataProvider = ArrayDataProvider<Movie>(section: [])
    private var tableViewDataSource: TableViewArrayDataSource<FavoriteMovieTableViewCell, Movie>?

    // MARK: - Properties

    var filter: FavoriteMovieFilter? {
        didSet {
            apply(filter: filter)
        }
    }

    var favoriteMovies: [Movie]? {
        didSet {
            if let favoriteMovies = favoriteMovies {
                dataProvider.elements = [favoriteMovies]
                tableViewDataSource?.refresh()
            }
        }
    }

    var appLanguage: Language? {
        didSet {
            setupTitles()
        }
    }

    weak var delegate: FavoriteMoviesListViewDelegate?

    var predicate: NSPredicate? {
        didSet {
            self.dataProvider.predicate = predicate
            tableViewDataSource?.refresh()
        }
    }

    // MARK: - Initialization

    ///
    /// Initializes the view with using `UIScreen.main.bounds` as frame.
    ///
    public required init() {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }

    ///
    /// Initializes the view with using the given `frame`.
    /// - Parameter frame: Initial view dimensions.
    ///
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    ///
    /// Initializes the view with using the given `coder`.
    /// - Parameter aDecoder: NSCoder to be used.
    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        let bundle = Bundle(for: type(of: self))
        let className = String(describing: type(of: self))
        bundle.loadNibNamed(className, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setup()
        setupTableView()
    }

    private func setup() {
        removeFilterButton.isHidden = false // true
        removeFilterButtonHeightConstraint.constant = 44 //0
        setNeedsLayout()
        layoutIfNeeded()
    }

    private func setupTitles() {
        removeFilterButton.setTitle(removeFilterButtonTitle, for: .normal)
    }

    private func setupTableView() {
        let nib = UINib(nibName: FavoriteMovieTableViewCell.simpleClassName(), bundle: Bundle(for: type(of: self)))
        tableView.register(nib, forCellReuseIdentifier: FavoriteMovieTableViewCell.simpleClassName())
        let dataSource = TableViewArrayDataSource<FavoriteMovieTableViewCell, Movie>(for: tableView, with: dataProvider)
        tableView.dataSource = dataSource
        self.tableViewDataSource = dataSource
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }

    private func apply(filter: FavoriteMovieFilter?) {
        var height: CGFloat = 0
        if let filter = filter, (filter.genre != nil || filter.year != nil) {
            height = 44
            print("has filter")
        }
        removeFilterButtonHeightConstraint.constant = height
        removeFilterButton.isHidden = (height == 0)
        setNeedsLayout()
        layoutIfNeeded()
    }

    @IBAction func removeFilters() {
        self.delegate?.favoriteMoviesListViewDidRemoveFilter(self)
    }

}

extension FavoriteMoviesListView: Internationalizable {

    var unfavoriteMovieActionText: String {
        guard let language = appLanguage?.rawValue else { return "#INVALID_LANGUAGE#" }
        return string("unfavoriteMovieActionText", languageCode: language)
    }

    var removeFilterButtonTitle: String {
        guard let language = appLanguage?.rawValue else { return "#INVALID_LANGUAGE#" }
        return string("removeFilterButtonTitle", languageCode: language)
    }

}

extension FavoriteMoviesListView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)
        -> UITableViewCell.EditingStyle {
            return .none
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let favoriteMovie = dataProvider[indexPath] else { return nil }
        let unfavoriteMovieAction = UIContextualAction(
            style: .destructive,
            title: unfavoriteMovieActionText,
            handler: { [unowned self] (_, _, completionHandler) in
                self.delegate?.favoriteMoviesListView(self, unfavorited: favoriteMovie)
                completionHandler(true)
        })
        return UISwipeActionsConfiguration(actions: [unfavoriteMovieAction])
    }

}

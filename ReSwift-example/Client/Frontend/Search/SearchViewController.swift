import UIKit
import ReSwift

final class SearchViewController: UIViewController {
    fileprivate var models = [GitHubModel]() {
        didSet {
            guard models != oldValue else {return}
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
    }
    @IBOutlet fileprivate weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib(nibName: String(describing: SearchTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: SearchTableViewCell.self))
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate var searchState: SearchState {
        return store.state.searchState
    }
    
    fileprivate let defaultquery = "Swift"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        store.dispatch(SearchAction.Creator.fetchSearchResult(query: defaultquery, page: 1))
        refreshControl.addTarget(self, action: #selector(type(of: self).refreshControlChanged(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        store.subscribe(self) { subcription in
            subcription.select({$0.searchState})
        }
        
        if searchState.needsToRefresh {
            tableView.contentOffset = CGPoint(x: 0, y: tableView.contentInset.top)
            store.dispatch(SearchAction.Creator.fetchSearchResult(query: defaultquery, page: 1))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    // MARK: - Actions
    func refreshControlChanged(_ sender: Any) {
        refreshControl.beginRefreshing()
        store.dispatch(SearchAction.Refresh())
        store.dispatch(SearchAction.Creator.fetchSearchResult(query: defaultquery, page: 1))
    }
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if tableView.contentOffset.y + tableView.frame.size.height > tableView.contentSize.height && tableView.isDragging {
            guard !store.state.searchState.isLoading else {
                return
            }
            store.dispatch(SearchAction.Creator.fetchSearchResult(query: defaultquery, page: store.state.searchState.page + 1))
        }
    }
}

// MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchTableViewCell.self), for: indexPath) as! SearchTableViewCell
        cell.fullNameLabel?.text = models[indexPath.row].fullName
        cell.startCountLabel.text = "⭐️" + models[indexPath.row].stargazersCount.description
        return cell
    }
}

// MARK: - StoreSubscriber
extension SearchViewController: StoreSubscriber {
    func newState(state: SearchState) {
        title = state.query ?? ""
        if state.needsToRefresh {
            indicatorView.isHidden = true
        } else {
            indicatorView.isHidden = !state.isLoading
        }
        
        if !indicatorView.isAnimating && state.isLoading {
            indicatorView.startAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        } else {
            refreshControl.endRefreshing()
            indicatorView.stopAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        models = state.models
    }
}


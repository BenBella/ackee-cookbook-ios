//
//  MasterViewController.swift
//  Cookbook-Test-Project
//
//  Created by Dominik Vesely on 12/01/2017.
//  Copyright © 2017 Dominik Vesely. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class MasterViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView()
    
    private let pullToRefreshControl = UIRefreshControl()
    
    var detailViewController: DetailViewController? = nil
    var objects = [Any]()

    var viewModel = MasterViewModel(api: CookbookAPIService(network: Network(), authHandler: nil))
    var disposable: Disposable?
    
    // MARK: - Lifecycle
    
    deinit {
        disposable?.dispose()
    }

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeConstraints()
        configureUI()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Bindings
    
    func bindViewModel() {
        self.title = viewModel.title
        
        viewModel.active <~ isActive()
        
        viewModel.contentChangesSignal.observe(on: UIScheduler()).observe { [unowned self]  signal in
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: signal.value!.deletions, with: .automatic)
            self.tableView.reloadRows(at: signal.value!.modifications, with: .automatic)
            self.tableView.insertRows(at: signal.value!.insertions, with: .automatic)
            self.tableView.endUpdates()
            if self.pullToRefreshControl.isRefreshing == true {
                self.pullToRefreshControl.endRefreshing()
            }
        }
        
        viewModel.isLoading.producer.observe(on: UIScheduler()).start { isLoading in
            UIApplication.shared.isNetworkActivityIndicatorVisible = isLoading.value ?? false
        }
 
        viewModel.alertMessageSignal.observe(on: UIScheduler()).observe { [unowned self] signal in
            switch signal {
            case let .failed(error):
                self.showErrorAlert(error: error)
            case let .value(value):
                self.showErrorAlert(error: value)
            case .completed, .interrupted:
                break
            }
        }
    }
    
    // MARK: Layout
    
    func makeConstraints() {
        let superview = self.view!
        
        superview.addSubview(tableView)
        tableView.isScrollEnabled = true
        tableView.backgroundColor = UIColor.theme.white
        tableView.snp.makeConstraints { (make) -> Void in
            make.size.equalToSuperview()
            make.top.equalToSuperview()
            make.left.equalToSuperview()
        }
    }
    
    // MARK: - UI behaviour setup
    
    func configureUI() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        tableView.register(RecipeItemCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonItemPressed(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openButtonItemPressed(_:)))
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = pullToRefreshControl
        } else {
            tableView.addSubview(pullToRefreshControl)
        }
        
        pullToRefreshControl.reactive.controlEvents(.valueChanged).observeValues { [unowned self] _ in
            self.viewModel.refreshObserver.send(value: ())
        }
    }
    
    // MARK: - Navigation
    
    @objc
    func editButtonItemPressed(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        if tableView.isEditing == true {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(editButtonItemPressed(_:)))
        }else{
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonItemPressed(_:)))
        }
    }
    
    @objc
    func openButtonItemPressed(_ sender: Any) {
        self.splitViewController?.showDetailViewController(EditViewController(viewModel: viewModel.editViewModel()), sender: nil)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {   
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.viewModel = viewModel.detailViewModelForRecipeAt(indexPath)
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfMatchesInSection(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecipeItemCell
        cell.updateName(viewModel.recipeNameAt(indexPath))
        cell.updateDuration(viewModel.recipeDurationAt(indexPath))
        cell.updateScoreView(viewModel.recipeScoreAt(indexPath))
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteAction.apply(indexPath).start()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowDetail", sender: nil)
    }

}


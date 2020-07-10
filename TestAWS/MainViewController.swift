//
//  ViewController.swift
//  TestAWS
//
//  Created by Volodymyr Rykhva on 09.07.2020.
//  Copyright © 2020 Volodymyr Rykhva. All rights reserved.
//

import UIKit

final class MainTableViewController: UITableViewController {

    @IBOutlet var dataProvider: SettingsDataProvider!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Teams"
        tableView.tableFooterView = UIView(frame: .zero)
        addNavigationBarItem()
        tableView.refreshControl?.addTarget(self, action: #selector(onRefresh), for: .valueChanged)

        dataProvider.delegate = self
        dataProvider.load()
    }

    // MARK - Private

    @objc private func onRefresh() {
        dataProvider.load()
        tableView.refreshControl?.endRefreshing()
    }

    private func addNavigationBarItem() {
        let rightBarButton = UIBarButtonItem(title: "Update",
                                             style: .plain,
                                             target: self,
                                             action: #selector(onUpdateDidTouch))
        navigationItem.rightBarButtonItem = rightBarButton
    }

    @objc private func onUpdateDidTouch(_ sender: UIBarButtonItem!) {
        dataProvider.update(onCompletion: {
            let alert = UIAlertController(title: "AWS", message: "You have successfully uploaded FotaSettings-Volodymyr-Rykhva.json file", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            DispatchQueue.main.async { [weak self] in
                self?.present(alert, animated: true, completion: nil)
            }
        })
    }
}

extension MainTableViewController: SettingsDataProviderDelegate {

    func goToVersion(index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "VersionViewController") as? VersionViewController
        viewController?.setup(version: dataProvider.props.versionListByTeams[index].majorVersion,
                              isFotaEnabled: dataProvider.props.versionListByTeams[index].fotaEnabled)
        viewController?.onUpdate = { [weak self] (majorVersion, isFotaEnabled) in
            self?.dataProvider.props.versionListByTeams[index].majorVersion = majorVersion
            self?.dataProvider.props.versionListByTeams[index].fotaEnabled = isFotaEnabled
            self?.render()
        }
        if let viewController = viewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    func render() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}


/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Storage

class BlurTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var profile: Profile!
    var site: Site!
    var tableView = UITableView()
    lazy var tapRecognizer: UITapGestureRecognizer = {
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(BlurTableViewController.dismiss(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        return tapRecognizer
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        visualEffectView.frame = view.bounds
        view.addSubview(visualEffectView)

        view.addGestureRecognizer(tapRecognizer)


        view.addSubview(tableView)
        tableView.snp_makeConstraints { make in
            make.edges.equalTo(self.view).inset(80)
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        tableView.backgroundColor = UIConstants.PanelBackgroundColor
        tableView.scrollEnabled = false
        tableView.separatorColor = UIConstants.SeparatorColor
        tableView.layer.cornerRadius = 10
        tableView.accessibilityIdentifier = "SiteTable"
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

        if #available(iOS 9, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }

        // Set an empty footer to prevent empty cells from appearing in the list.
        tableView.tableFooterView = UIView()
    }

    func dismiss(gestureRecognizer: UIGestureRecognizer) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    deinit {
        // The view might outlive this view controller thanks to animations;
        // explicitly nil out its references to us to avoid crashes. Bug 1218826.
        tableView.dataSource = nil
        tableView.delegate = nil
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(tableView: UITableView, hasFullWidthSeparatorForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SiteTableViewControllerUX.RowHeight
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero

        switch indexPath.row {
            case 0:
                cell.textLabel?.text = "SITE TITLE AND URL"
                return cell
            case 1:
                cell.textLabel?.text = "bookmark"
                cell.textLabel?.textColor = UIConstants.SystemBlueColor

                let image = UIImage(named: "action_bookmark")!.imageWithRenderingMode(.AlwaysTemplate)
                cell.imageView?.image = image
                cell.imageView?.tintColor = UIConstants.SystemBlueColor
                return cell
            case 2:
                cell.textLabel?.text = "share"
                return cell
            case 3:
                cell.textLabel?.text = "dismiss"
                return cell
            case 4:
                cell.textLabel?.text = "delete"
                return cell
            default:
                return cell
        }
    }

    func isBookmarked(site: Site) -> Bool {
        profile.bookmarks.modelFactory >>== { bookmark in
            $0.isBookmarked(site.url)
                .uponQueue(dispatch_get_main_queue()) {
                    guard let isBookmarked = $0.successValue else {
                        log.error("Error getting bookmark status: \($0.failureValue).")
                        return false
                    }
            }
        }
        return true
    }
}
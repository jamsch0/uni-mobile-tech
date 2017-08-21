//
//  ReportTableViewController.swift
//  lexicon
//
//  Created by James Chapman on 02/03/2017.
//  Copyright © 2017 James Chapman. All rights reserved.
//

import PromiseKit
import UIKit

class ReportsTableViewCell: UITableViewCell {
    @IBOutlet weak var completedDateLabel: UILabel!
    @IBOutlet weak var correctCountLabel: UILabel!
}

class ReportsViewController: UITableViewController {
    let formatter = DateFormatter()
    
    var completedTests: [Test] = []
    var incompleteTests: [Test] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = true
        
        self.formatter.dateStyle = DateFormatter.Style.long
        self.formatter.timeStyle = DateFormatter.Style.short
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.incompleteTests.count > 0 {
            return 2
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.incompleteTests.count > 0 && section == 0 {
            return self.incompleteTests.count
        } else {
            return self.completedTests.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.incompleteTests.count > 0 && section == 0 {
            return "Incomplete Tests"
        } else {
            return "Completed Tests"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportsTableViewCell", for: indexPath) as! ReportsTableViewCell
        
        if self.incompleteTests.count > 0 && indexPath.section == 0 {
            let test = self.incompleteTests[indexPath.row]
            
            cell.completedDateLabel.text = Date.timeAgo(since: test.created)
            cell.correctCountLabel.text = "\(test.attempted) of \(test.questions.count) attempted"
        } else {
            let test = self.completedTests[indexPath.row]
            
            cell.completedDateLabel.text = Date.timeAgo(since: test.completed!)
            cell.correctCountLabel.text = "\(test.correct) of \(test.questions.count) correct"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [UITableViewRowAction(style: .destructive, title: "Delete", handler: { (action, indexPath) in
            let hasIncompleteTests = self.incompleteTests.count > 0
            let test: Test
            
            if hasIncompleteTests && indexPath.section == 0 {
                test = self.incompleteTests.remove(at: indexPath.row)
            } else {
                test = self.completedTests.remove(at: indexPath.row)
            }
            
            if hasIncompleteTests && self.incompleteTests.count == 0 {
                self.tableView.deleteSections([0], with: .automatic)
            } else {
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
			
			if test.id != nil {
				ServerHelper.deleteTest(test).then { _ in
					test.delete()
				}.catch { _ in
					test.markedForDeletion = true
				}
			}
			
			CoreDataHelper.saveContext()
        })]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.incompleteTests.count > 0 && indexPath.section == 0 {
            self.performSegue(withIdentifier: "startTestSegue", sender: nil)
        } else {
            self.performSegue(withIdentifier: "showTestSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = self.tableView.indexPathForSelectedRow else {
            return
        }
        
        if let destination = segue.destination as? ReportViewController {
            if self.incompleteTests.count > 0 && indexPath.section == 0 {
                destination.test = self.incompleteTests[indexPath.row]
            } else {
                destination.test = self.completedTests[indexPath.row]
            }
        } else if let destination = (segue.destination as? UINavigationController)?.topViewController as? TestViewController {
            destination.test = self.incompleteTests[indexPath.row]
            destination.unwindDestination = self
        }
    }
    
    func loadReports() {
		let tests: [Test] = Test.fetchAll(forUser: ServerHelper.user!)
		
		// Some weird type inference issues with `when(resolved:).then()`, so we store it in a variable and specify the type
		let promise: Promise<[Result<Void>]> = when(resolved: tests.map { test in
			if test.markedForDeletion {
				return ServerHelper.deleteTest(test).then { _ in test.delete() }
			} else if test.markedForSync {
				return ServerHelper.sendTest(test).then { newTest -> Void in
					if newTest != nil {
						test.delete()
					}
				}
			} else {
				return Promise(value: ())
			}
		})
		
		_ = promise.then { _ -> Void in
			_ = ServerHelper.getTests().then { tests -> [Test] in
				let updateString = "Last Updated \(self.formatter.string(from: Date()))"
				self.refreshControl!.attributedTitle = NSAttributedString(string: updateString)
				
				return tests
			}.recover { error -> [Test] in
				Test.fetchAll(forUser: ServerHelper.user!).filter { !$0.markedForDeletion }
			}.then { tests -> Void in
				self.incompleteTests = tests.filter { $0.completed == nil }.sorted { $0.0.created.compare($0.1.created) == .orderedDescending }
				self.completedTests = tests.filter { $0.completed != nil }.sorted { $0.0.completed!.compare($0.1.completed!) == .orderedDescending }
				
				self.tableView.reloadData()
				
				if self.refreshControl!.isRefreshing {
					self.refreshControl!.endRefreshing()
				}
			}
		}
    }
	
    func refresh(_ sender: Any?) {
        self.loadReports()
    }
    
    @IBAction func unwindFromTest(_ sender: UIStoryboardSegue) {
        guard let source = sender.source as? TestViewController else {
            return
        }
        
        if source.test.completed != nil {
            self.incompleteTests.remove(at: self.incompleteTests.index(where: { $0 === source.test })!)
            self.completedTests.insert(source.test, at: 0)
            
            self.tableView.reloadData()
        }
    }
}

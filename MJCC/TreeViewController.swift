//
//  TreeViewController.swift
//  MJCC
//
//  Created by MJsaka on 16/6/22.
//  Copyright © 2016年 MJsaka. All rights reserved.
//

import UIKit

class TreeViewController: UIViewController , UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    var tree : EquationTree!
    var treeView : TreeView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var size = TreeView.minimumSize(tree.root )
        if size.height < self.view.frame.height {
            size.height = self.view.frame.height
        }

        treeView = TreeView(frame: CGRect(origin: CGPoint(x: 0 , y: 0), size: size))
        treeView.backgroundColor = UIColor.whiteColor()
        treeView.root = tree.root;
        self.scrollView.contentSize = size
        self.scrollView.delegate = self
        self.scrollView.addSubview(treeView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return treeView
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

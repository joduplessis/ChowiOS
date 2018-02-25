//
//  TutorialViewController.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/08/25.
//  Copyright © 2016 CHOW. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UIScrollViewDelegate {

    @IBAction func skipButtonAction(_ sender: AnyObject) {
        // Dismiss
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet var skipButton: UIButton!
    @IBOutlet var headingText: UILabel!
    @IBOutlet var tutorialText: UILabel!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var scrollView: UIScrollView!
    
    var scrollViewWidth: CGFloat = 0.0
    var scrollViewHeight: CGFloat = 300
    let screenSize: CGRect = UIScreen.main.bounds
    let images = [
        "tutorial1.jpg",
        "tutorial2.jpg",
        "tutorial3.jpg",
        "tutorial4.jpg",
        "tutorial5.jpg",
    ]
    let texts = [
        "\nSearch and find CHOW accredited\n restaurants near you\n",
        "\nSelect your CHOW meal\n\n",
        "\nAdd the unique code found on the\n tillslip - coming soon\n",
        "\nCheck the number of CHOW bucks you\n have earned - coming soon\n",
        "\nUse your CHOW bucks to buy awesome\n stuff - coming soon\n"
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the page control
        self.pageControl.numberOfPages = images.count
        self.pageControl.currentPage = 0
        self.pageControl.pageIndicatorTintColor = UIColor.darkGray
        self.pageControl.currentPageIndicatorTintColor = UIColor.gray
        
        // Configure the scrollview
        self.scrollView.isPagingEnabled = true
        self.scrollView.delegate = self
        
        // Set the intial text
        self.headingText.text = texts[pageControl.currentPage]
        
        // Get the width
        // self.scrollViewWidth = self.scrollView.frame.size.width
        self.scrollViewWidth = screenSize.width-20
        
        for index in 0..<5 {
            // Create a frame to use for each image
            var frame: CGRect = CGRect(x: 0, y: 0, width: self.scrollViewWidth, height: scrollViewHeight)
            frame.origin.x = self.scrollViewWidth * CGFloat(index)
            
            // Create the image
            let image = UIImage(named: images[index])
            let imageView = UIImageView(image: image!)
            
            // Frame
            imageView.frame = frame
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            
            self.scrollView.addSubview(imageView)
        }
        
        self.scrollView.contentSize = CGSize(width: scrollViewWidth * 5, height: scrollViewHeight)
        self.pageControl.addTarget(self, action: #selector(changePage), for: UIControlEvents.valueChanged)

        // Still general font stuff
        let fontTutorial = UIFont(name: "JennaSue", size: 40)
        let fontHeading = UIFont(name: "JennaSue", size: 30)
        
        // Assign the textview the font & text
        headingText.font = fontHeading
        tutorialText.font = fontTutorial
        
        // Hide the tutorial text
        self.tutorialText.isHidden = true;
    }
    
    func changePage(_ sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        self.headingText.text = texts[pageControl.currentPage]
        if pageControl.currentPage == texts.count-1 {
            self.skipButton.setTitle("I got it, let's start!", for: UIControlState())        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

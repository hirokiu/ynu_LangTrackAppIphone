//
//  MultipleChoiceViewController.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-01-30.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit

class MultipleChoiceViewController: UIViewController {
    
    @IBOutlet weak var nextButton: NextButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var multiTableView: SelfSizedTableView!
    @IBOutlet weak var theIcon: UIImageView!
    @IBOutlet weak var tableviewContainer: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var topViewBottomConstraint: NSLayoutConstraint!
    
    var listener: QuestionListener?
    var theQuestion = Question()
    var theAnswer: Answer?
    var selectedAnswers = [Int]()
    let fontInCell = UIFont.systemFont(ofSize: 18)
    var cellWidth: CGFloat = 100
    var showingTopShadow = false
    var showingBottomShadow = false
    var headerHeight: CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previousButton.layer.cornerRadius = 8
        nextButton.layer.cornerRadius = 8
        theIcon.clipsToBounds = false
        theIcon.setSmallViewShadow()
        multiTableView.delegate = self
        multiTableView.rowHeight = UITableView.automaticDimension
        multiTableView.estimatedRowHeight = 60
        multiTableView.separatorStyle = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        multiTableView.maxHeight = tableviewContainer.frame.height - 26
        multiTableView.reloadData()
        DispatchQueue.main.async {
            self.bottomView.setSmallBottomViewShadow()
            if self.multiTableView.maxHeight < self.multiTableView.contentSize.height - 2{
                if (self.multiTableView.contentOffset.y + self.multiTableView.maxHeight) >= (self.multiTableView.contentSize.height){
                    self.bottomView.removeShadow()
                    self.showingBottomShadow = false
                }else{
                    if !self.showingBottomShadow{
                        self.bottomView.setSmallBottomViewShadow()
                        self.showingBottomShadow = true
                    }
                }
            }else{
                self.bottomView.removeShadow()
                self.showingBottomShadow = false
            }
            if self.multiTableView.contentOffset.y < 5{
                self.topView.removeShadow()
                self.showingTopShadow = false
            }else{
                self.topView.setLabelShadow()
                self.showingTopShadow = true
            }
        }
    }
    
    func setInfo(question: Question){
        self.theQuestion = question
        setTableviewWidth()
        nextButton.setEnabled(enabled: false)
        setSelectedAnswer()
        multiTableView.reloadData()
        self.view.layoutIfNeeded()
        setTableviewWidth()
        multiTableView.reloadData()
        
        topViewBottomConstraint.constant = -headerHeight
    }
    
    func setListener(listener: QuestionListener) {
        self.listener = listener
    }
    
    func setSelectedAnswer(){
        if theAnswer != nil {
            if theAnswer?.index == theQuestion.index{
                if theAnswer!.multipleChoiceAnswer != nil {
                    selectedAnswers = theAnswer!.multipleChoiceAnswer!
                    if theAnswer!.multipleChoiceAnswer?.isEmpty ?? false {
                        nextButton.setEnabled(enabled: false)
                    }else{
                        nextButton.setEnabled(enabled: true)
                    }
                }
            }
        }
    }
    
    func setTableviewWidth(){
        let longest = theQuestion.multipleChoisesAnswers?.sorted(by: {$0.count > $1.count}).first
        let longestWidth = (longest?.width(withConstrainedHeight: 21, font: UIFont.systemFont(ofSize: 18, weight: .regular)) ?? 0) + 100
        if longestWidth > tableviewContainer.frame.width{
            cellWidth = tableviewContainer.frame.width - 25
        }else{
            cellWidth = longestWidth
        }
        topViewWidthConstraint.constant = cellWidth * 0.9
        bottomViewWidthConstraint.constant = cellWidth * 0.9
    }
    
    func saveAnswers(){
        listener?.setMultipleAnswersAnswer(selected: selectedAnswers)
    }

    @IBAction func previousButtonPressed(_ sender: Any) {
        DispatchQueue.main.async {
            self.bottomView.removeShadow()
            self.topView.removeShadow()
        }
        saveAnswers()
        selectedAnswers.removeAll()
        listener?.previousQuestion(current: theQuestion)
    }

    @IBAction func nextButtonPressed(_ sender: Any) {
        DispatchQueue.main.async {
            self.bottomView.removeShadow()
            self.topView.removeShadow()
        }
        saveAnswers()
        selectedAnswers.removeAll()
        listener?.nextQuestion(current: theQuestion)
    }
}

extension MultipleChoiceViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 5{
            if !showingTopShadow {
                topView.setLabelShadow()
                showingTopShadow = true
            }
        }else{
            topView.removeShadow()
            showingTopShadow = false
        }
        
        //bottom
        if (scrollView.contentOffset.y + multiTableView.maxHeight) >= (scrollView.contentSize.height){
            self.bottomView.removeShadow()
            showingBottomShadow = false
        }else{
            if !showingBottomShadow{
                bottomView.setSmallBottomViewShadow()
                showingBottomShadow = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theQuestion.multipleChoisesAnswers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "multi", for: indexPath)
        
        if let cell = cell as? MultiItemTableViewCell{
            
            cell.choiceLabel.text = theQuestion.multipleChoisesAnswers?[indexPath.row]
            cell.choiceLabel.font = fontInCell
            cell.checkBox.bgColorSelected = KirokunTheme.action
            cell.checkBox.borderColor = KirokunTheme.action
            cell.checkBox.color = .white
            cell.checkBox.borderWidth = 1.5
            cell.tag = indexPath.row
            cell.selectionStyle = .none
            if selectedAnswers.contains(indexPath.row){
                cell.setCheck(enabled: true)
                nextButton.setEnabled(enabled: true)
            }else{
                cell.setCheck(enabled: false)
            }
            cell.cellWithConstraint.constant = self.cellWidth
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !selectedAnswers.contains(indexPath.row){
            selectedAnswers.append(indexPath.row)
        }else{
            selectedAnswers.removeAll(where: {$0 == indexPath.row})
        }
        if selectedAnswers.isEmpty{
            self.nextButton.setEnabled(enabled: false)
        }else{
            self.nextButton.setEnabled(enabled: true)
        }
        multiTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let theTitle = theQuestion.text
        headerHeight = theTitle.height(withConstrainedWidth: multiTableView.frame.width - 10, font: UIFont.systemFont(ofSize: 20, weight: .medium)) + 25
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel()
        headerLabel.numberOfLines = 0
        headerLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        headerLabel.textAlignment = .center
        headerLabel.contentMode = .top
        headerLabel.text = theQuestion.text
        headerLabel.backgroundColor = UIColor.white

        return headerLabel
    }
    
}

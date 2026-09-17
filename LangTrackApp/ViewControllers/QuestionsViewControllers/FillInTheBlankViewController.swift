//
//  FillInTheBlankViewController.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-01-30.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit

class FillInTheBlankViewController: UIViewController {

    @IBOutlet weak var theIcon: UIImageView!
    @IBOutlet weak var tableviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fillTableview: UITableView!
    @IBOutlet weak var nextButton: NextButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var selectedWordContainer: UIView!
    @IBOutlet weak var containerArrow: UILabel!
    @IBOutlet weak var selectedWordLabel: UILabel!
    @IBOutlet weak var arrowTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedWordBottomView: UIView!
    
    var listener: QuestionListener?
    var theQuestion = Question()
    var dropDownOpen = false
    let radious:CGFloat = 8
    var arrowUp = false
    var rowheight: CGFloat = 35
    var theSentence: FillInWordSentence? = nil
    var theChosenWordIndex : Int? = nil
    var theAnswer: Answer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previousButton.layer.cornerRadius = radious
        nextButton.layer.cornerRadius = radious
        tableviewHeightConstraint.constant = radious
        let touch = UITapGestureRecognizer(target: self, action: #selector(self.selectedWordTouched))
        selectedWordContainer.addGestureRecognizer(touch)
        fillTableview.rowHeight = rowheight
        theIcon.clipsToBounds = false
        theIcon.setSmallViewShadow()
        selectedWordBottomView.layer.cornerRadius = 8
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if #available(iOS 11.0, *) {
            self.selectedWordContainer.clipsToBounds = true
            selectedWordContainer.layer.cornerRadius = radious
            selectedWordContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            self.fillTableview.clipsToBounds = true
            fillTableview.layer.cornerRadius = radious
            fillTableview.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    func getTextAsList(){
        let arrayWithWords = theQuestion.text.components(separatedBy: " ")
        if !arrayWithWords.isEmpty{
            var ind = -99
            for (i,word) in arrayWithWords.enumerated() {
                 #warning ("TODO: Handle when missing word is last with dot direct after")
                if word == "_____" || word == "_____."{
                    ind = i
                }
            }
            theSentence = FillInWordSentence()
            theSentence?.listWithWords = arrayWithWords
            theSentence?.indexForMissingWord = ind
        }
    }
    
    func setInfo(question: Question){
        self.theQuestion = question
        nextButton.setEnabled(enabled: false)
        if question.index == theQuestion.index{
            getTextAsList()
            if (theSentence != nil){
                setSentence()
                fillTableview.reloadData()
            }
        }
    }
    
    func setSentence(){
        let theAttributedSentence = NSMutableAttributedString()
        if theAnswer != nil && theAnswer?.fillBlankAnswer != nil{
            if theAnswer?.index == theQuestion.index{
                // show previous answer
                let selectedWord = theQuestion.fillBlanksChoises?[theAnswer!.fillBlankAnswer!] ?? "_____"
                theSentence!.listWithWords[theSentence!.indexForMissingWord] = selectedWord
                selectedWordLabel.text = selectedWord
                
                
                if selectedWord != "_____"{
                    for word in theSentence!.listWithWords{
                        if word == selectedWord{
                            //underline and add word
                            theAttributedSentence.append(underLineText(text: word))
                        }else{
                            //just add word
                            theAttributedSentence.append(NSAttributedString(string: word))
                        }
                        
                        if word != theSentence!.listWithWords.last{
                            theAttributedSentence.append(NSAttributedString(string: " "))
                        }
                    }
                }
            }
        }
        if theAttributedSentence.string == ""{
            //no choice selected - show org
            questionTextLabel.text = theSentence?.listWithWords.joined(separator: " ")
        }else{
            //choice made - show
            nextButton.setEnabled(enabled: true)
            questionTextLabel.text = ""
            questionTextLabel.attributedText = theAttributedSentence
        }
        
    }
    
    func underLineText(text: String)-> NSMutableAttributedString{
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(NSMutableAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedText.length))
        return attributedText
    }
    
    func setListener(listener: QuestionListener) {
        self.listener = listener
    }
    
    func openProjectDropDown(){
        turnArrow()
        var dropDownHeight = CGFloat(Int(rowheight) * (self.theQuestion.fillBlanksChoises?.count ?? 0))
        if dropDownHeight > 190{
            dropDownHeight = 190
        }
        let arrowCenter = (selectedWordContainer.frame.width / 2) - 15
        UIView.animate(withDuration: 0.3,animations: {
            self.tableviewHeightConstraint.constant = dropDownHeight
            self.selectedWordLabel.alpha = 0
            self.arrowTrailingConstraint.constant = arrowCenter
            self.fillTableview.alpha = 1
            self.view.layoutIfNeeded()
        }){_ in
            self.dropDownOpen = true
        }
    }
    
    func closeProjectDropDown(){
        turnArrow()
        UIView.animate(withDuration: 0.3, animations:  {
            self.tableviewHeightConstraint.constant = self.radious
            self.selectedWordLabel.alpha = 1
            self.arrowTrailingConstraint.constant = 10
            self.fillTableview.alpha = 0
            self.view.layoutIfNeeded()
        }){_ in
            self.dropDownOpen = false
        }
    }
    
    func turnArrow(){
        if arrowUp{
            UIView.animate(withDuration: 0.3, animations: {
                self.containerArrow.transform = CGAffineTransform(rotationAngle: 0)
                self.view.layoutIfNeeded()
            })
            arrowUp = false
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.containerArrow.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                self.view.layoutIfNeeded()
            })
            arrowUp = true
        }
    }
    
    @objc func selectedWordTouched(sender: UITapGestureRecognizer){
        if dropDownOpen{
            closeProjectDropDown()
        }else{
            openProjectDropDown()
        }
    }
    
    func resetBlankView(){
        theQuestion = Question()
        theAnswer = nil
        selectedWordLabel.text = NSLocalizedString("Select a word from the list", comment: "Word selection prompt")
        if self.tableviewHeightConstraint.constant != self.radious{
            closeProjectDropDown()
        }
    }
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        let temp = theQuestion
        resetBlankView()
        listener?.previousQuestion(current: temp)
        fillTableview.reloadData()
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        let temp = theQuestion
        resetBlankView()
        listener?.nextQuestion(current: temp)
        fillTableview.reloadData()
    }
    
}

//MARK:- TableViewDelegate
extension FillInTheBlankViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theQuestion.fillBlanksChoises?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fillCell", for: indexPath)
        if let cell = cell as? FillInBlankCell{
            cell.theText.text = theQuestion.fillBlanksChoises?[indexPath.row] ?? ""
            cell.selectionStyle = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tempAnswer = Answer(type: "open", index: theQuestion.index)
        tempAnswer.fillBlankAnswer = indexPath.row
        theAnswer = tempAnswer
        closeProjectDropDown()
        setSentence()
        nextButton.setEnabled(enabled: true)
        listener?.setFillBlankAnswer(selected: indexPath.row)
    }
}

//MARK:- FillInBlankCell class

class FillInBlankCell: UITableViewCell {
    
    @IBOutlet weak var theText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class FillInWordSentence {
    var listWithWords = [String]()
    var indexForMissingWord: Int = -99
}

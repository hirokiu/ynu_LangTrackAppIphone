//
//  OverviewViewController.swift
//  LangTrackApp
//
//  Created by Stephan Björck on 2020-03-20.
//  Copyright © 2020 Stephan Björck. All rights reserved.
//

import UIKit

struct OverviewListItem {
    var question: Question
    var answer: Answer
}

class OverviewViewController: UIViewController {
    
    @IBOutlet weak var topViewNumberOfQuestionsLabel: UILabel!
    @IBOutlet weak var topViewAnsweredLabel: UILabel!
    @IBOutlet weak var topViewPublishedLabel: UILabel!
    @IBOutlet weak var topViewTitleLabel: UILabel!
    @IBOutlet weak var topViewContainer: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var overviewTableview: UITableView!
    
    
    var theAssignment: Assignment? = nil
    var questionsWithAnswers = [OverviewListItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = KirokunTheme.action
        KirokunTheme.styleModalHeader(topView)
        topViewContainer.backgroundColor = KirokunTheme.brand.withAlphaComponent(0.10)
        overviewTableview.delegate = self
        overviewTableview.rowHeight = UITableView.automaticDimension
        overviewTableview.estimatedRowHeight = 60
        overviewTableview.separatorStyle = .singleLine
        
        topViewTitleLabel.text = theAssignment?.survey.title
        if theAssignment != nil{
            //DateParser.displayString(for: DateParser.getDate(dateString: assignment.published)!)
            //topViewPublishedLabel.text = DateParser.getLocalTime(date: DateParser.getDate(dateString: theAssignment!.published)!)
            topViewPublishedLabel.text = DateParser.displayString(for: DateParser.getDate(dateString: theAssignment!.published)!)
            if theAssignment!.dataset != nil{
                //topViewAnsweredLabel.text = DateParser.getLocalTime(date: DateParser.getDate(dateString: theAssignment!.dataset!.createdAt)!)
                topViewAnsweredLabel.text = DateParser.displayString(for: DateParser.getDate(dateString: theAssignment!.dataset!.createdAt)!)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        topViewContainer.layer.cornerRadius = 7
        if questionsWithAnswers.isEmpty{
            if theAssignment != nil{
                if let header = theAssignment!.survey.questions.first(where: { $0.type == Type.header.rawValue}){
                    let answer = Answer(type: Type.header.rawValue, index: header.index)
                    questionsWithAnswers.append(OverviewListItem(question: header, answer: answer))
                }
                for que in theAssignment!.survey.questions{
                    if que.type != Type.header.rawValue &&
                        que.type != Type.footer.rawValue{
                        if let answers = theAssignment!.dataset?.answers{
                            if let answer = answers.first(where: {$0.index == que.index}){
                                questionsWithAnswers.append(OverviewListItem(question: que, answer: answer))
                            }
                        }
                    }
                }
                //MARK: add footer too?
            }
            questionsWithAnswers.sort(by: {$0.question.index < $1.question.index})
            topViewNumberOfQuestionsLabel.text = "\(questionsWithAnswers.count - 1) \(translatedNumberEnding)"//minus header...
            overviewTableview.reloadData()
        }
    }
    
    /*func showSurvey(){
        if theAssignment != nil{
            let height: Int = 50
            for (i, question) in theAssignment!.survey.questions.enumerated() {
                let likertView = LikertView()
                likertView.frame = CGRect(x: 0, y: (height * i), width: Int(questionContainer.frame.width), height: height)
                likertView.setInfo(question: question)
                questionContainer.addSubview(likertView)
            }

            questionContainerHeightConstraint.constant = CGFloat(theAssignment!.survey.questions.count * height)
        }
    }*/
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension OverviewViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionsWithAnswers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listObject = questionsWithAnswers[indexPath.row]
        switch questionsWithAnswers[indexPath.row].question.type {
            
        case Type.header.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath)
            if let cell = cell as? OverviewHeaderTableViewCell{
                cell.setValues(item: listObject)
                cell.selectionStyle = .none
            }
            return cell
            
        case Type.likertScales.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "likert", for: indexPath)
            if let cell = cell as? OverviewLikertTableViewCell{
                cell.setValues(item: listObject)
                cell.selectionStyle = .none
            }
            return cell
        case Type.multipleChoice.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "single", for: indexPath)
            if let cell = cell as? OverviewSingleTableViewCell{
                cell.setValues(item: listObject, single: false)
                cell.selectionStyle = .none
            }
            return cell
        case Type.singleMultipleAnswers.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "single", for: indexPath)//multi
            if let cell = cell as? OverviewSingleTableViewCell{
                cell.setValues(item: listObject, single: true)
                cell.selectionStyle = .none
            }
            return cell
        case Type.timeDuration.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "duration", for: indexPath)
            if let cell = cell as? OverviewDurationTableViewCell{
                cell.setValues(item: listObject)
                cell.selectionStyle = .none
            }
            return cell
        case Type.openEndedTextResponses.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "open", for: indexPath)
            if let cell = cell as? OverviewOpenTableViewCell{
                cell.setValues(item: listObject)
                cell.selectionStyle = .none
            }
            return cell
        case Type.fillInTheBlank.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "blanks", for: indexPath)
            if let cell = cell as? OverviewBlanksTableViewCell{
                cell.setValues(item: listObject)
                cell.selectionStyle = .none
            }
            return cell
        case Type.sliderScale.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "slider", for: indexPath)
            if let cell = cell as? OverviewSliderTableViewCell{
                cell.setValues(item: listObject)
                cell.selectionStyle = .none
            }
            return cell
        case Type.footer.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "likert", for: indexPath)
            if let cell = cell as? OverviewLikertTableViewCell{
                cell.setValues(item: listObject)
                cell.selectionStyle = .none
            }
            return cell
        default://header
            let cell = tableView.dequeueReusableCell(withIdentifier: "likert", for: indexPath)
            if let cell = cell as? OverviewLikertTableViewCell{
                cell.setValues(item: listObject)
                cell.selectionStyle = .none
            }
            return cell
        }
        
    }
    
    
}
